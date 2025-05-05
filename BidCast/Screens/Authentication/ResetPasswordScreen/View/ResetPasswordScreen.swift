//    //
//    //  ResetPasswordScreen.swift
//    //  imperium
//    //
//    //  Created by Abdul-JAM-E-157 on 19/01/24.
//    //
//
//import SwiftUI
//import BottomSheet
//import AlertToast
//
//struct ResetPasswordScreen: View {
//    
//        //MARK: - Static Properties
//    @State var isRemeber: Bool = false
//    @State var isLoading: Bool = false
//    @State var confPassword: String = ""
//    @State var navigateToLogin: Bool = false
//    
//        //MARK: - View Modal & Request
//    @State var request: ResetPasswordRequest = ResetPasswordRequest(user_name: "", password: "")
//    var viewModel = ResetPasswordViewModel()
//    
//        //MARK: - Custom Alert
//    @State var showError: Bool = false
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            ZStack() {
//                VStack(alignment: .center) {
//                    Image(.halfBackground)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: screenWidth, height: screenHeight/3)
//                        .edgesIgnoringSafeArea(.top)
//                        .overlay(alignment: .top, content: {
//                            Image(.appName)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: screenWidth/2, height: screenHeight/12)
//                                .padding(.top, screenHeight/20)
//                        })
//                    Spacer()
//                }
//                
//                VStack(alignment: .leading, spacing: 25) {
//                    TitleWithLine(title: "Reset Password", lineLength: 48)
//                    
//                    AuthTextField(floatingLabel: "Enter Password", placeholder: "Enter New Password", icon: .bag, text: $request.password, isPassword: true) { password in
//                        request.password = password
//                    }
//                    
//                    AuthTextField(floatingLabel: "Confirm Password", placeholder: "Confirm New Password", icon: .bag, text: $confPassword, isPassword: true) { password in
//                        confPassword = password
//                    }.padding(.bottom,16)
//                    
//                    PrimaryButton(title: "Submit") {
//                        
//                        UIApplication.shared.endEditing()
//                        
//                        guard !request.password.isEmpty else {
//                            hudMsg = "Password can not be empty"
//                            showhud = true
//                            return
//                        }
//                        
//                        guard request.password.count > 7 else {
//                            hudMsg = "Password can not be less than 8 digit"
//                            showhud = true
//                            return
//                        }
//                        
//                        guard request.password == confPassword else {
//                            hudMsg = "Password and Confirm Password can not be different"
//                            showhud = true
//                            return
//                        }
//                        
//                        if let mail: String = UserDefaultsManager.shared.value(forKey: .mailId) {
//                            request.user_name = mail
//                            request.password = confPassword
//                            
//                            viewModel.resetPassword(parameters: request)
//                        }
//                        
//                    }
//                    
//                    HStack(spacing:4) {
//                        Spacer()
//                        Text("Back to")
//                            .font(.system(size: 14))
//                            .foregroundStyle(.gray)
//                        Button(action: {
//                            navigateToLogin = true
//                        }, label: {
//                            Text("Login!").font(.system(size: 14))
//                                .bold()
//                                .foregroundStyle(.red)
//                        })
//                        Spacer()
//                    }.padding([.top, .bottom], 16)
//                    
//                }
//                .padding([.leading, .trailing])
//                
//                .padding(.top, screenHeight/3)
//                
//                if isLoading {
//                    Loader(isLoading: $isLoading)
//                }
//                
//                    //            if showError {
//                    //                AlertPopUp(presentAlert: $showError, alertType: alertType, rightButtonAction: {
//                    //                    withAnimation(.snappy) {
//                    //                        if alertType.rightActionText == "Proceed to Login" {
//                    //                            showError = false
//                    //                            navigateToLogin = true
//                    //                        } else {
//                    //                            showError = false
//                    //                        }
//                    //                    }
//                    //                })
//                    //            }
//                
//                CusNavLink(doNavigate: $navigateToLogin, destination: LoginScreen())
//            }.frame(width: screenWidth, height: screenHeight)
//        }
//        .onAppear(){
//            observe()
//        }
//        .onTapGesture {
//            UIApplication.shared.endEditing()
//        }
//        .toast(isPresenting: $showhud) {
//            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
//        .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
//            CommonBottomSheet(
//                sheetType: $alertType,
//                onPrimaryClick: {
//                    withAnimation { showError = false }
//                    if alertType.primaryBtnText == "Proceed to Login" {
//                        navigateToLogin = true
//                    }
//                }, onSecondaryClick: {
//                    withAnimation { showError = false }
//                })
//        })
//    }
//    
//        //MARK: VM Handler
//    func observe() {
//        self.viewModel.eventHandler = { event in
//            switch event {
//                case .loading:
//                    self.isLoading = true
//                case .stopLoading:
//                    self.isLoading = false
//                case .dataLoaded:
//                    handleSuccess()
//                case .error(let error):
//                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    print(error as Any)
//            }
//        }
//    }
//    
//    func handleSuccess() {
//        let response = viewModel.resetPasswordResponceDict
//        if response.status == "success" {
//            withAnimation(.snappy) {
//                alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "Proceed to Login", secondaryBtnText: "", sheetThemeColor: .green)
//                showError = true
//            }
//        } else {
//            alertType = .sheetType(icon: .alert, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//            withAnimation(.snappy) { showError = true }
//        }
//    }
//}
//
//#Preview {
//    ResetPasswordScreen()
//}
