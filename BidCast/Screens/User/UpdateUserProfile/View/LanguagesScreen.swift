//
//  LanguagesScreen.swift
//  imperium
//
//  Created by JAM-E-265 on 24/01/24.
//

import SwiftUI
import AlertToast
import BottomSheet

struct LanguagesScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
        //MARK: - Variable Initialized
    @State var langArray: [Languages] = []
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var optionList: [String] = []
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
        //MARK: - View Modal
    var viewModal = UpdateUserProfileViewModal()
    
        //MARK: - Primary View Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    title: "My Languages",
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                VStack(spacing: 0) {
                    TitleWithLine(
                        title: "My Languages",
                        lineLength: 0)
                    .padding([.top, .leading])
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(langArray.indices, id: \.self) {
                                ind in
                                DropDownTextField(
                                    hint: "Language Example",
                                    text: $langArray[ind].name,
                                    options: $optionList,
                                    showCancel: true,
                                    onOptionSelected: { text in
                                        langArray[ind].name = text },
                                    onCancelClicked: { text in
                                        withAnimation(.easeIn) {
                                            if langArray.count > 0 {
                                                langArray.removeAll(where: { $0.name == text })
                                            }
                                        }
                                    }).zIndex(1000.0 - Double(ind))
                            }
                            
                            HStack {
                                Button(action: {
                                    withAnimation(.easeOut) {
                                        langArray.append(Languages(name: ""))
                                    }
                                }, label: {
                                    Image(systemName: "plus.circle.fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.text)
                                    
                                    Text("Add Language")
                                        .font(.custom(nunitoBold, fixedSize: 14))
                                        .foregroundStyle(.text)
                                })
                                
                                Spacer()
                            }.padding(.vertical, 10)
                            
                            PrimaryButton(
                                title: "Save",
                                isOutLine: false,
                                onButtonClick: {
                                    print("Lang Array >> \(langArray)")
                                    validate()
                                })
                            PrimaryButton(
                                title: "Cancel",
                                onButtonClick: {
                                    self.presentationMode.wrappedValue.dismiss()
                                })
                        }.padding(.all)
                    }
                }
                Spacer()
            }
            .padding(.top, -topPadding)
            .onAppear(perform: {
                isLoading = true
                self.viewModal.getLanguageList()
                observe()
                if let userDetail: UserDetailModal
                    = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                    userDetail.language?.forEach({ data in
                        withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                            langArray.append(Languages(name: data.name))
                        }
                    })
                }
            })
            .onDisappear(perform: {
                self.viewModal.languageListResponse = nil
                self.viewModal.langUpdResponse = nil
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
            
                //MARK: - Loading
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
                //MARK: - Alert Pop Up
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.easeIn) { showAlert = false } },
//                    rightButtonAction: {
//                        withAnimation(.easeIn) { showAlert = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    })
//            }
            
        }
    }
    
    //MARK: - Validate Languages
    func validate() {
        var isValid: Bool = true
        
        langArray.forEach({
            data in
            if data.name == "" {
                isValid = false
            }
        })
        
        if isValid {
            var langList: [EmpLanguageRequest] = []
            
            langArray.forEach({
                lang in
                let ele = self.viewModal.languageListResponse?.data.first(where: { $0.name == lang.name })
                langList.append(EmpLanguageRequest(language_id: "\(ele?.id! ?? 0)"))
            })
            print("Lang List >> \(langList)")
            self.viewModal.updateEmployeeLanguage(parameter: langList)
        } else {
            hudMsg = "Please add new Language to save."
            showHud = true
        }
    }
    
    
        //MARK: - View Modal Observer
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
                case .loading:
                    isLoading = true
                case .stopLoading:
                    isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation { showAlert = true }
            }
        }
    }
    
        //MARK: - View Modal Handle Success
    func handleSuccess() {
        if let response = viewModal.languageListResponse {
            response.data.forEach({
                data in
                optionList.append(data.name ?? "")
            })
        }
        
        if let res = viewModal.langUpdResponse {
            if res.status == "success" {
                alertType = .sheetType(icon: .success, title: res.status?.capitalized ?? "", message: res.message?.capitalized ?? "", primaryBtnText: "OK", secondaryBtnText: "", sheetThemeColor: .green)
                withAnimation { showAlert = true }
            } else {
                alertType = .sheetType(icon: .alert, title: res.status?.capitalized ?? "", message: res.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                withAnimation { showAlert = true }
            }
        }
    }
}

#Preview {
    LanguagesScreen()
}
