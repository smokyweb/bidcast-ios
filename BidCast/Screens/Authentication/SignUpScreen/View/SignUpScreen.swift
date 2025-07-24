//
//  SignUpScreen.swift
// BidSwipe
//
//  Created by JAM-E-282 on 19/01/24.
//

import SwiftUI
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD

struct SignUpScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
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
        VStack(spacing: 0) {
            VStack{
                PrimaryHeader(title: AppString.createAccount.localized, leadingImgArr: [.icBack], onClickLeading:  { _ in
                    
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    Image(.logo1)
                        .frame(width: screenWidth, height: screenHeight/3.8)
                        .edgesIgnoringSafeArea(.top)
                }
                VStack(alignment: .leading, spacing: 15) {
                    TitleWithLine(title: AppString.createYourAccount, lineLength: sepratorLine)
                    AuthTextField(floatingLabel: AppString.firstName.localized, placeholder: AppString.enterFirstName.localized, icon: .menuProfile, text: $request.firstName, enteredText: {
                        value in
                        request.firstName = value
                    })
                    .textContentType(.givenName)
                    .keyboardType(.alphabet)
                    AuthTextField(floatingLabel: AppString.lastName.localized, placeholder: AppString.enterLastName.localized, icon: .menuProfile, text: $request.lastName, enteredText: {
                        value in
                        request.lastName = value
                    })
                    .keyboardType(.alphabet)
                    
                    AuthTextField(floatingLabel: AppString.email.localized, placeholder: AppString.enterEmail.localized, icon: .icMail, text: $request.email, enteredText: {
                        value in
                        request.email = value
                    }).textContentType(.username)
                        .keyboardType(.emailAddress)
                    
                    AuthTextField(floatingLabel: AppString.password.localized, placeholder: AppString.enterPassword.localized, icon: .passwordLock, text: $request.password, isPassword: true, enteredText: {
                        value in
                        request.password = value
                    }).textContentType(.password)
                        .keyboardType(.alphabet)
                    
                    AuthTextField(floatingLabel: AppString.confirmPassword.localized, placeholder: AppString.confirmPassword.localized, icon: .passwordLock, text: $request.passwordConf, isPassword: true, enteredText: {
                        value in
                        request.passwordConf = value
                    }).textContentType(.newPassword)
                        .keyboardType(.alphabet)
                    
                }
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
                        guard request.email.isValidEmail() else{
                            hudMsg = AppString.pleaseEnterValidEmailAddress.localized
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
                        Task{
                           guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            SVProgressHUD.show()
                            viewModel.errorMessage?.removeAll()
                            await self.viewModel.registerUser(parameters: request)
                            await SVProgressHUD.dismiss()
                            if viewModel.errorMessage == nil{
                                handleSuccess()
                            }else{
                                alertType = .sheetType(icon: .alert, title: "Failed", message:viewModel.errorMessage ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .secondary)
                                showError = true
                            }
                        }
                    },btnTextColor: .white)
                }
                .padding([.top, .bottom], 16)
                .zIndex(1300.0)
                
            }
            .onTapGesture(perform: {
                UIApplication.shared.endEditing()
            })
            
            Spacer()
            
        }
        
        
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        
        
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
        .bottomSheet(isPresented: $showError, height: screenHeight/2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            if viewModel.errorMessage == nil{
                let response = viewModel.signUpResponse
                if response.status == "success" {
                    self.presentationMode.wrappedValue.dismiss()
                }else{
                    withAnimation { showError = false }
                }
            }else{
                withAnimation { showError = false }
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if alertType.primaryBtnText == AppString.proceedToLogin.localized {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    let response = viewModel.signUpResponse
                    if response.status == "success" {
                        self.presentationMode.wrappedValue.dismiss()
                    }else{
                        withAnimation { showError = false }
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                })
        })
    }
    
    
    
    func handleSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.signUpResponse
        if response.status == "success" {
            UserDefaults.isFirstLogin = 1
            let userData = response.data
            UserDefaults.userEmail = userData?.email ?? ""
            UserDefaults.firstName = userData?.first_name ?? ""
            UserDefaults.lastName = userData?.last_name ?? ""
            UserDefaults.userRole = "\(userData?.role_id ?? 0)"
            alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: AppString.backToLogin.localized, secondaryBtnText: "", sheetThemeColor: .secondary)
            showError = true
            
            
        } else {
            alertType = .sheetType(icon: .alert, title: response.error_type?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .secondary)
            showError = true
        }
        
    }
}
#Preview {
    SignUpScreen()
}
