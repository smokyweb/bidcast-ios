//
//  MySkillScreen.swift
//  imperium
//
//  Created by JAM-E-265 on 24/01/24.
//

import SwiftUI
import AlertToast
import BottomSheet

struct MySkillScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
        //MARK: - Variable Used
    @State var skillArray: [Skill] = []
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
                PrimaryHeader(title: "My Skills",trailingImgArr: [.cancel], onClickTrailing: {
                    _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                VStack(spacing: 0) {
                    TitleWithLine(title: "Skills you excel at", lineLength: 0)
                        .padding([.top, .leading])
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(skillArray.indices, id: \.self) {
                                ind in
                                DropDownTextField(
                                    hint: "Enter Skill",
                                    text: $skillArray[ind].skill,
                                    options: .constant([]),
                                    showCancel: true, onOptionSelected: { value in
                                        skillArray[ind].skill = value
                                    },
                                    onCancelClicked: { text in
                                        withAnimation(.easeIn) {
                                            if skillArray.count > 0 {
                                                skillArray.removeAll(where: { $0.skill == text })
                                            }
                                        }
                                    })
                            }
                            
                            HStack {
                                Button(action: {
                                    withAnimation(.easeOut) {
                                        withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                                            skillArray.append(Skill(skill: ""))
                                        }
                                    }
                                }, label: {
                                    Image(systemName: "plus.circle.fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.text)
                                    
                                    Text("Add Skill")
                                        .font(.custom(nunitoBold, fixedSize: 14))
                                        .foregroundStyle(.text)
                                })
                                
                                Spacer()
                            }.padding(.vertical, 10)
                            
                            PrimaryButton(title: "Save", isOutLine: false){
                                UIApplication.shared.endEditing()
                                validateSkills()
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
                    userDetail.skills?.forEach({ data in
                        withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                            skillArray.append(Skill(skill: data.skill))
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
    func validateSkills() {
        if skillArray.count > 0 {
            
            var allValid = true
            
            skillArray.forEach { skill in
                if skill.skill == "" {
                    allValid = false
                    return
                }
            }
            
            if allValid {
                self.viewModal.updateEmployeeSkill(parameter: skillArray)
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
                alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .green)
                withAnimation(.easeIn) { showAlert = true }
            } else {
                alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                withAnimation(.easeIn) { showAlert = true }
            }
        }
    }
}

#Preview {
    MySkillScreen()
}
