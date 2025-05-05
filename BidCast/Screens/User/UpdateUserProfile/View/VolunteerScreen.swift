//
//  VolunteerScreen.swift
//  imperium
//
//  Created by JAM-E-265 on 24/01/24.
//

import SwiftUI
import AlertToast
import BottomSheet

struct VolunteerScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var volunExpArray: [VolunteerExperience] = []
    @State var showLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
    var viewModal = UpdateUserProfileViewModal()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(title: "Volunteer Experience",trailingImgArr: [.cancel], onClickTrailing: {
                    _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                VStack(spacing: 0) {
                    TitleWithLine(title: "Volunteer Experience", lineLength: 0)
                        .padding([.top, .leading])
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(volunExpArray.indices, id: \.self) {
                                ind in
                                DropDownTextField(
                                    hint: "Volunteer Experience Example",
                                    text: $volunExpArray[ind].volunteer_experience,
                                    options: .constant([]),
                                    showCancel: true,
                                    onOptionSelected: { text in
                                        volunExpArray[ind].volunteer_experience = text
                                    },
                                    onCancelClicked: { text in
                                        withAnimation(.easeIn) {
                                            if volunExpArray.count > 0 {
                                                volunExpArray.removeAll(where: { $0.volunteer_experience == text })
                                            }
                                        }
                                    })
                            }
                            
                            HStack {
                                Button(action: {
                                    withAnimation(.easeOut) {
                                        volunExpArray.append(VolunteerExperience(volunteer_experience: ""))
                                    }
                                }, label: {
                                    Image(systemName: "plus.circle.fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.text)
                                    
                                    Text("Add Volunteer Experience")
                                        .font(.custom(nunitoBold, fixedSize: 14))
                                        .foregroundStyle(.text)
                                })
                                
                                Spacer()
                            }.padding(.vertical, 10)
                            
                            PrimaryButton(title: "Save", isOutLine: false){
                                UIApplication.shared.endEditing()
                                validateVolExp()
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
            .onAppear(perform: {
                observe()
                if let userDetail: UserDetailModal
                    = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                    userDetail.volunteer_experiences?.forEach({ data in
                        withAnimation(.interactiveSpring(duration: 0.75, extraBounce: 0.3, blendDuration: 0.5)) {
                            volunExpArray.append(VolunteerExperience(volunteer_experience: data.volunteer_experience))
                        }
                    })
                }
            })
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
    func validateVolExp() {
        if volunExpArray.count > 0 {
            
            var allValid = true
            
            volunExpArray.forEach { skill in
                if skill.volunteer_experience == "" {
                    allValid = false
                    return
                }
            }
            
            if allValid {
                self.viewModal.updateEmployeeVolExp(parameter: volunExpArray)
                self.observe()
            } else {
                hudMsg = "Please enter experience to continue"
                showHud = true
            }
        } else {
            hudMsg = "Please add your volunteer experience to save"
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
                alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .green)
                withAnimation(.easeIn) { showAlert = true }
            }
        }
    }
}

#Preview {
    VolunteerScreen()
}
