//
//  UserPersonalInfoScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 31/01/24.
//

import SwiftUI
import AlertToast
import BottomSheet

struct UserPersonalInfoScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var isLoading: Bool = false
    @State var request: UserPersonalInfo = UserPersonalInfo(first_name: "", last_name: "", email: "", location: "", password: "", phone: "", description: "", profile_image: "")
    
    @State var confPass: String = ""
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
    var viewModal = UpdateUserProfileViewModal()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    title: "Account Info & Location",
                    trailingImgArr: [.cancel],
                    onClickTrailing:  { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Account Info")
                            .font(.custom(nunitoBlack, fixedSize: 18))
                            .frame(width: screenWidth - 50, alignment: .leading)
                        
                        AuthTextField(floatingLabel: "First Name", placeholder: "Enter First Name", icon: .bag, text: $request.first_name, enteredText: {
                            value in
                            request.first_name = value
                        })
                        
                        AuthTextField(floatingLabel: "Last Name", placeholder: "Enter Last Name", icon: .bag, text: $request.last_name, enteredText: {
                            value in
                            request.last_name = value
                        })
                        
                        AuthTextField(floatingLabel: "Email Address", placeholder: "Enter Email Address", icon: .bag, text: $request.email, enteredText: {
                            value in
                            request.email = value
                        })
                        
                        AuthTextField(floatingLabel: "Password", placeholder: "Enter Password", icon: .bag, text: $request.password, isPassword: true, enteredText: {
                            value in
                            request.password = value
                        })
                        
                        AuthTextField(floatingLabel: "Confirm Password", placeholder: "Reenter Password", icon: .bag, text: $confPass, isPassword: true, enteredText: {
                            value in
                            confPass = value
                        })
                        
                    }.padding([.leading, .trailing, .vertical])
                    
                    VStack(spacing: 15) {
                        Text("Location")
                            .font(.custom(nunitoBlack, fixedSize: 18))
                            .frame(width: screenWidth - 30, alignment: .leading)
                        
                        AuthTextField(floatingLabel: "Confirm your location", placeholder: "Enter Location", icon: .location, text: $request.location, enteredText: {
                            value in
                            request.location = value
                        })
                        
                        PrimaryButton(title: "Save", isOutLine: false, onButtonClick: {
                            
                            UIApplication.shared.endEditing()
                            
                            guard !request.first_name.isEmpty else {
                                hudMsg = "First Name is required"
                                showHud = true
                                return
                            }
                            
                            guard !request.last_name.isEmpty else {
                                hudMsg = "Last Name is required"
                                showHud = true
                                return
                            }
                            
                            guard request.email.isValidEmail() else {
                                hudMsg = "Email address is required"
                                showHud = true
                                return
                            }
                            
                            if request.password != "" {
                                guard request.password.count == 8 else {
                                    hudMsg = "Password can not be less than 8 characters"
                                    showHud = true
                                    return
                                }
                                
                                guard !confPass.isEmpty else {
                                    hudMsg = "Confirm Password is required"
                                    showHud = true
                                    return
                                }
                                
                                guard request.password == confPass else {
                                    hudMsg = "Password and Confirm Password are not matching"
                                    showHud = true
                                    return
                                }
                            }
                            
                            guard !request.location.isEmpty else {
                                hudMsg = "Location is required"
                                showHud = true
                                return
                            }
                            
                            self.viewModal.updateProfileInfo(parameter: [request])
                        })
                        
                        PrimaryButton(title: "Cancel", onButtonClick: {
                            UIApplication.shared.endEditing()
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    }
                    .padding([.top, .bottom], 30)
                    .padding([.leading, .trailing])
                    .background(.text.opacity(0.1))
                    
                }.padding(.top, -topPadding)
                
                
                
                Spacer()
            }
            .onAppear {
                if let userDetail: UserDetailModal
                    = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                    request.first_name = userDetail.first_name ?? ""
                    request.last_name = userDetail.last_name ?? ""
                    request.email = userDetail.email ?? ""
                    request.location = userDetail.location ?? ""
                    request.profile_image = userDetail.profile_image ?? ""
                }
                
                observe()
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showError = false }
                        self.presentationMode.wrappedValue.dismiss()
                    }, onSecondaryClick: {
                        withAnimation { showError = false }
                    })
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
//            if showError {
//                AlertPopUp(
//                    presentAlert: $showError,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.snappy) { showError = false }
//                    },
//                    rightButtonAction: {
//                        withAnimation(.snappy) { showError = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    })
//            }
        }
    }
    
    func observe() {
        self.viewModal.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = true
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.easeInOut) { showError = true }
                    print(error as Any)
            }
        }
    }
    
    func handleSuccess() {
        if let response = viewModal.profileInfoResponse {
            if response.status == "success" {
                alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                showError = true
            } else {
                alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showError = true
            }
        }
    }
}

#Preview {
    UserPersonalInfoScreen()
}
