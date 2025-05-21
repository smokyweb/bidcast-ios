//
//  LoginScreen.swift
// BidSwipe
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI
//import OneSignalCore
//import OneSignalFramework
import CoreData
import BottomSheet
import AlertToast
import SwiftfulLoadingIndicators
//import AuthenticationServices

struct LoginScreen: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
//    @EnvironmentObject var coreDataManager: CoreDataProvider
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var languageManager = LanguageManager.shared

    
//    @FetchRequest(sortDescriptors: []) private var loginDetailList: FetchedResults<Login>
    
    @State var isRemeber: Bool = true
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var navigateToForgot: Bool = false
    @State var navigateToLanguage: Bool = false
    @State var navigateToSignUp: Bool = false
    @State var navigateTotab: Bool = false
    @State var signInWithApple: Bool = false
    @State private var isLoggedIn = false
    @State var navigateToEmployer: Bool = false
    @State var navigateToCompanyUser: Bool = false
    @State var navigatetoUser: Bool = false

    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var request: SignInRequest = SignInRequest(email: "", password: "")
    
    @State var loginDetail: LoginModel = LoginModel()
    
    var viewModel = LoginViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    Image(.mainLogo)
                        .frame(width: screenWidth - 50, height: screenHeight/3)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        AuthTextField(floatingLabel: AppString.email.localized, placeholder: AppString.enterEmail.localized, icon: .menuProfile, text: $request.email) { email in
                            self.request.email = email
                        }
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        
                        AuthTextField(floatingLabel: AppString.password.localized, placeholder: AppString.enterPassword.localized, icon: .passwordLock, text: $request.password, isPassword: true) { password in
                            self.request.password = password
                        }
                        .textContentType(.password)
                    }
                    
                    HStack {
                        Button(action: {
                            withAnimation{
                                isRemeber.toggle()
                            }
                        }, label: {
                            Image(systemName: isRemeber ? "checkmark.square.fill" : "square")
                                .frame(width: 25, height: 25)
                                .tint(.red)
                            
                            Text(AppString.rememberMe.localized)
                                .font(.custom(poppinsMedium, fixedSize: placeHolder))
                                .foregroundStyle(.gray)
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                navigateToForgot = true
                            }
                        }, label: {
                            Text(AppString.forgotPassword.localized)
                                .font(.custom(poppinsRegular, fixedSize: placeHolder))
                                .foregroundStyle(.defaultTheme)
                        })
                    }.padding([.top, .bottom], 10)
                        .padding([.leading,.trailing] , Leading)
                    
                    
                    PrimaryButton(title: AppString.login.localized, isOutLine: false,onButtonClick: {
                        UIApplication.shared.endEditing()
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
                        
                        guard request.password.count > 7 else {
                            hudMsg = AppString.passwordNotLessThan.localized
                            showhud = true
                            return
                        }
                        print("Parameters used for login:- \(self.request)")
                        self.viewModel.logIn(parameters: self.request)
                    }, btnTextColor: .white)
                    
                    
                    HStack(spacing: 6) {
                        Spacer()
                        Text(AppString.newUser.localized)
                            .font(.custom(poppinsMedium, fixedSize: placeHolder))
                            .foregroundStyle(.gray)
                        Button(action: {
                            withAnimation(.easeInOut) {
                                navigateToSignUp = true
                            }
                        }, label: {
                            Text(AppString.createAccount.localized)
                                .font(.custom(poppinsBold, fixedSize: placeHolder))
                                .foregroundStyle(.red)
                        })
                        Spacer()
                    }.padding([.top, .bottom], 12)

                }
                .padding([.leading, .trailing])
                .padding(.top, screenHeight/3)
                
                .toast(isPresenting: $showhud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
                }
                
                if isLoading {
                   
                        
                    LoadingIndicator()
                        .edgesIgnoringSafeArea(.all)
//                    Color.black.opacity(0.4)
                }
            
                CusNavLink(doNavigate: $navigateToForgot, destination: ForgotScreen())
                CusNavLink(doNavigate: $navigateTotab, destination: TabbarScreen())
                CusNavLink(doNavigate: $navigateToLanguage, destination: LanguagePickerView())
                CusNavLink(doNavigate: $navigateToSignUp, destination: SignUpScreen())

            }
           
        }.id(languageManager.languageChanged)
        .bottomSheet(isPresented: $showError, height: screenHeight/2.3, topBarCornerRadius: 25, showTopIndicator: false, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if alertType.primaryBtnText == AppString.continueBtn.localized {
                        navigateToLanguage = true
                    }
                }, onSecondaryClick: {
                    withAnimation { showError = false }
                })
        })
        .onAppear {
            UIScrollView.appearance().bounces = false
        }
        .onDisappear(perform: {
            DispatchQueue.main.async {
                UIScrollView.appearance().bounces = true
            }
        })

        .onAppear(){
           
            observe()
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
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
                    success()
                case .error(let error):
                    if error?.localizedDescription == DataError.tokenExpired.localizedDescription {
                        alertType = .sheetType(icon: .alert, title: AppString.loginFailed.localized, message: AppString.failedToLogin.localized , primaryBtnText: "", secondaryBtnText: AppString.retryLogin.localized, sheetThemeColor: .secondary)
                        showError = true
                        Log.e(error as Any)
                    } else {
                        alertType = .sheetType(icon: .alert, title: AppString.error.localized, message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: AppString.error.localized, sheetThemeColor: .secondary)
                        showError = true
                        Log.e(error as Any)
                    }
            }
        }
    }

    
    func success() {
        
       if viewModel.requestType == "Login" {
            let dict = viewModel.loginResponceDict
            if dict?.status == "success" {
                UserDefaults.isFirstLogin = 1
//                if dict?.data.role_id != "1" {
                    loginDetail = dict!.data
                    UserDefaultsManager.shared.setValue(dict?.data.token, forKey: .token)
                    UserDefaultsManager.shared.setModel(dict?.data, forKey: .userDetail)
                    UserDefaultsManager.shared.setValue(isRemeber, forKey: .rememberMe)
                    if isRemeber {
                        saveLoginDetail(mail: request.email, password: request.password)
                    } else {
                        saveLoginDetail(mail: "", password: "")
                    }
                    UserDefaultsManager.shared.setValue(true, forKey: .isLoggedIn)
                   
                    UserDefaultsManager.shared.setValue(dict?.data.role_id, forKey: .userRoleId)
                UserDefaultsManager.shared.setValue(dict?.data.roles?.name ??  "", forKey: .userRole)
                    if let token: String = UserDefaultsManager.shared.value(forKey: .deviceToken) {
                        print("Device Token \(token)")
                    }
                alertType = .sheetType(icon: .success, title: dict?.status?.capitalized ?? "", message: AppString.chooseLanguage.localized, primaryBtnText: AppString.continueBtn.localized , secondaryBtnText: "", sheetThemeColor: .secondary)
                withAnimation(.snappy) { navigateTotab = true }
            }else{
                alertType = .sheetType(icon: .alert, title: dict?.status?.capitalized ?? "", message: dict?.message ?? "", primaryBtnText: AppString.ok.localized, secondaryBtnText: "", sheetThemeColor: .secondary)
                withAnimation(.snappy) { showError = true }
            }
        }
    }
    
    func saveLoginDetail(mail: String, password: String) {
        UserDefaults.userEmail = mail
        UserDefaults.password = password
    }
}
extension LoginScreen{
    func isValidPhone(phone: String) -> Bool {
        // Reject if the phone number is all zeros
        if Set(phone).count == 1 && phone.first == "0" {
            return false
        }
        
        // Regex pattern: Only digits, length between 7 and 12
        let phoneRegex = "^[0-9]{10,12}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        // Check if the phone number matches the regex pattern
        return phoneTest.evaluate(with: phone)
    }
}

//
#Preview {
    LoginScreen()
}

