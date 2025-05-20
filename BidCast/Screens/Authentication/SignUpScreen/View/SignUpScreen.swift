//
//  SignUpScreen.swift
// BidSwipe
//
//  Created by JAM-E-282 on 19/01/24.
//

import SwiftUI
//import OneSignalFramework
//import SafariServices
//import BottomSheet
import AlertToast

struct SignUpScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @State var isLoading: Bool = false
    @State var searchText = ""
    @State var selectedCountry : String?
    @State var showingDropdown: Bool = false
    @State var request : SignUpRequest = SignUpRequest(firstName: "", lastName: "", email: "", password: "", passwordConf: "", roleID: 2)
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var navigateToEmployer: Bool = false
    @State var navigatetoUser: Bool = false
    @State var navigateToLinkedIn: Bool = false
    
    @State var role: String = ""
    
    var viewModel = SignupViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(title: AppString.createAccount.localized, leadingImgArr: [.icBack], onClickLeading:  { _ in
                   
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        TitleWithLine(title: AppString.createYourAccount, lineLength: sepratorLine)
                        AuthTextField(floatingLabel: AppString.firstName.localized, placeholder: AppString.enterFirstName.localized, icon: .menuProfile, text: $request.firstName, enteredText: {
                                value in
                                request.firstName = value
                            })
                            .textContentType(.givenName)
                        AuthTextField(floatingLabel: AppString.lastName.localized, placeholder: AppString.enterLastName.localized, icon: .menuProfile, text: $request.lastName, enteredText: {
                                value in
                                request.lastName = value
                            })
                            .textContentType(.familyName)

                        AuthTextField(floatingLabel: AppString.email.localized, placeholder: AppString.enterEmail.localized, icon: .icMail, text: $request.email, enteredText: {
                                value in
                                request.email = value
                            }).textContentType(.username)
                        
                        AuthTextField(floatingLabel: AppString.password.localized, placeholder: AppString.enterPassword.localized, icon: .passwordLock, text: $request.password, isPassword: true, enteredText: {
                            value in
                            request.password = value
                        }).textContentType(.password)
                        
                        AuthTextField(floatingLabel: AppString.confirmPassword.localized, placeholder: AppString.confirmPassword.localized, icon: .passwordLock, text: $request.passwordConf, isPassword: true, enteredText: {
                            value in
                            request.passwordConf = value
                        }).textContentType(.newPassword)
                            
                        
                    }.padding([.leading, .trailing])
                    VStack {
                        PrimaryButton(title: AppString.submit.localized, isOutLine: false, onButtonClick: {
                            
                            UIApplication.shared.endEditing()
                            guard !request.firstName.isEmpty else {
                                hudMsg = AppString.pleaseEnterFirstName.localized
                                    showhud = true
                                    return
                                }
                            guard !request.lastName.isEmpty else {
                                hudMsg = AppString.pleaseEnterLastName.localized
                                    showhud = true
                                    return
                                }
                                guard !request.email.isEmpty else {
                                    hudMsg = AppString.pleaseEnterEmail.localized
                                    showhud = true
                                    return
                                }
                            guard !request.password.isEmpty else {
                                hudMsg = AppString.pleaseEnterPassword.localized
                                showhud = true
                                return
                            }
                            
                            guard request.password.count >= 8 else {
                                hudMsg = AppString.passwordNotLessThan.localized
                                showhud = true
                                return
                            }
                            
                            guard !request.passwordConf.isEmpty else {
                                hudMsg = AppString.pleaseConfirmPassword.localized
                                showhud = true
                                return
                            }
                            
                            guard request.password == request.passwordConf else {
                                hudMsg = AppString.passwordNotMatched.localized
                                showhud = true
                                return
                            }
                            print("Parameters for register user :- \(request)")
                            self.viewModel.registerUser(parameters: request)
                            },btnTextColor: .white)
                    }
                    .padding([.top, .bottom], 16)
                    .padding([.leading, .trailing])
                    .zIndex(1300.0)
                    
                }
                .padding(.top, -topPadding)
                .onTapGesture(perform: {
                    UIApplication.shared.endEditing()
                })
                
                Spacer()
                
            }
            .onAppear(){
                
                
                observe()
            }
           
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
			.bottomSheet(isPresented: $showError, height: screenHeight/2.5, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showError = false }
                        if alertType.primaryBtnText == AppString.proceedToLogin.localized {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        let response = viewModel.userNameDict
                        if response?.status == "success" {
                            self.presentationMode.wrappedValue.dismiss()
                        }else{
                            withAnimation { showError = false }
                        }
                    },
                    onSecondaryClick: {
                        withAnimation { showError = false }
                    })
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
        }
    }
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                handleSuccess()
            case .error(let error):
                alertType = .sheetType(icon: .alert, title: AppString.error.localized, message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .pinkBtn)
                withAnimation(.easeInOut) { showError = true }
            }
        }
    }
    
    func handleSuccess() {
        if viewModel.requestType == "RegisterUserName" {
            let response = viewModel.userNameDict
            if response?.status == "success" {
                UserDefaults.isFirstLogin = 1
                let userData = response?.data
                UserDefaults.userEmail = userData?.email ?? ""
                UserDefaults.firstName = userData?.first_name ?? ""
                UserDefaults.lastName = userData?.last_name ?? ""
                UserDefaults.userRole = "\(userData?.role_id ?? 0)"
                alertType = .sheetType(icon: .success, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: AppString.backToLogin.localized, secondaryBtnText: "", sheetThemeColor: .secondary)
                showError = true
                  
                
            } else {
                alertType = .sheetType(icon: .alert, title: response?.error_type?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .secondary)
                showError = true
            }
        }
    }
}
#Preview {
    SignUpScreen()
}
