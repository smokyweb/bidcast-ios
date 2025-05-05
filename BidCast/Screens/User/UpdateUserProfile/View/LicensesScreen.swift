//
//  LicensesScreen.swift
//  imperium
//
//  Created by JAM-E-265 on 24/01/24.
//

import SwiftUI
import BottomSheet
import AlertToast

struct LicensesScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
        //MARK: - Variable Used
    @State var licCerArray: [LicenseCertification] = []
    @State var showLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
    var viewModal = UpdateUserProfileViewModal()
    
        //MARK: - Primary View
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(title: "Licenses & Certificates",trailingImgArr: [.cancel], onClickTrailing: {
                    _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                VStack(spacing: 0) {
                    TitleWithLine(title: "Licenses & Certificates", lineLength: 0)
                        .padding([.top, .leading])
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(licCerArray.indices, id: \.self) {
                                ind in
                                DropDownTextField(
                                    hint: "Licenses or Certificate Example",
                                    text: $licCerArray[ind].license_certificate,
                                    options: .constant([]),
                                    showCancel: true,
                                    onOptionSelected: { text in
                                        licCerArray[ind].license_certificate = text
                                    },
                                    onCancelClicked: { text in
                                        withAnimation(.easeIn) {
                                            if licCerArray.count > 0 {
                                                licCerArray.removeAll(where: { $0.license_certificate == text })
                                            }
                                        }
                                    })
                            }
                            
                            HStack {
                                Button(action: {
                                    withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                                        licCerArray.append(LicenseCertification(license_certificate: ""))
                                    }
                                }, label: {
                                    Image(systemName: "plus.circle.fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.text)
                                    
                                    Text("Add Licenses & Certificates")
                                        .font(.custom(nunitoBold, fixedSize: 14))
                                        .foregroundStyle(.text)
                                })
                                
                                Spacer()
                            }.padding(.vertical, 10)
                            
                            PrimaryButton(title: "Save", isOutLine: false){
                                UIApplication.shared.endEditing()
                                validateLicCer()
                            }
                            PrimaryButton(title: "Cancel"){
                                UIApplication.shared.endEditing()
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }.padding(.all)
                    }
                }
                Spacer()
            }
            .padding(.top, -topPadding)
            .onAppear {
                if let userDetail: UserDetailModal
                    = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                    userDetail.license_certifications?.forEach({ data in
                        withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                            licCerArray.append(LicenseCertification(license_certificate: data.license_certificate))
                        }
                    })
                }
            }
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                        self.presentationMode.wrappedValue.dismiss()
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
                //MARK: - Loader
            if showLoading {
                Loader(isLoading: $showLoading)
            }
            
                //MARK: - Alert Pop Up
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.easeIn) { showAlert = false }
//                    },
//                    rightButtonAction: {
//                        withAnimation(.easeIn) { showAlert = false }
//                        withAnimation(.bouncy) { self.presentationMode.wrappedValue.dismiss() }
//                    })
//            }
        }
    }
    
        //MARK: - Validation of All Fields
    func validateLicCer() {
        if licCerArray.count > 0 {
            
            var allValid = true
            
            licCerArray.forEach { skill in
                if skill.license_certificate == "" {
                    allValid = false
                    return
                }
            }
            
            if allValid {
                self.viewModal.updateEmployeeLicCer(parameter: licCerArray)
                self.observe()
            } else {
                hudMsg = "Please enter Skill to continue"
                showHud = true
            }
        } else {
            hudMsg = "Please add your skills to save"
            showHud = true
        }
    }
    
        //MARK: - Observing API Request
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
                case .loading:
                    self.showLoading = true
                case .stopLoading:
                    self.showLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.easeIn) { showAlert = true }
            }
        }
    }
    
        //MARK: - Handle API Response
    func handleSuccess() {
        if let response = viewModal.skillResponse {
            if response.status == "success" {
                alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                withAnimation(.easeIn) { showAlert = true }
            } else {
                alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                withAnimation(.easeIn) { showAlert = true }
            }
        }
    }
}

#Preview {
    LicensesScreen()
}
