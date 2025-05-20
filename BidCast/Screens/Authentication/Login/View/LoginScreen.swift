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
            ZStack(alignment: .bottom) {
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    Image(.mainLogo)
//                        .resizable()
//                        .scaledToFill()
                        .frame(width: screenWidth - 50, height: screenHeight/3)
                        .edgesIgnoringSafeArea(.top)
//                        .overlay(alignment: .top, content: {
//                            Image(.appName)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: screenWidth/2, height: screenHeight/12)
//                                .padding(.top, screenHeight/20)
//                        })
                    Spacer()
                }
                    //ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Sign In")
//                            .font(.custom(nunitoBlack, fixedSize: 21))
//                            .bold()
//                            .foregroundStyle(.text)
//                        Divider()
//                            .frame(width: 28, height: 5)
//                            .background(.red)
//                    }.padding(.bottom, 12)
                    
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
                        
//                        SecAddSharedWebCredential(
//                            "io.knoxweb.imperium" as CFString,
//                            request.user_name as CFString,
//                            request.password as CFString) { error in
//                                Log.e("Error >> \(String(describing: error))")
//                            }
                        
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
//                                navigatetoUser = true
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
                    Loader(isLoading: $isLoading)
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
//            if loginDetailList.count > 0 {
//                request.user_name = loginDetailList.first?.mailId ?? ""
//                request.password = loginDetailList.first?.password ?? ""
//            }
           
            observe()
        }
//        .fullScreenCover(isPresented: $navigateToSignUp, content: {
//            SignUpScreen()
//        })
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
                
//                    if isRemeber {
//                        saveLoginDetail(mail: request.email, password: request.password)
//                    } else {
//                        saveLoginDetail(mail: "", password: "")
//                    }
                    UserDefaultsManager.shared.setValue(true, forKey: .isLoggedIn)
                   
                    UserDefaultsManager.shared.setValue(dict?.data.role_id, forKey: .userRoleId)
                UserDefaultsManager.shared.setValue(dict?.data.roles?.name ??  "", forKey: .userRole)
//                    let id = dict!.data.id!.description
//                    OneSignal.login(id)
//                    let observer = MyPushSubscriptionObserver()
//                    OneSignal.User.pushSubscription.addObserver(observer)
//                    if OneSignal.User.pushSubscription.optedIn {
//                        if let id = OneSignal.User.pushSubscription.id {
//                            Log.i("FCM token: \(id)")
//                            UserDefaultsManager.shared.setValue(id , forKey: .deviceToken)
//                        }
//                            // User is opted in for push notifications
//                            // Update your UI or perform other actions here
//                    } else {
//                        Log.i("User is opted out of push notifications")
//                            // User is opted out of push notifications
//                            // Update your UI or perform other actions here
//                    }
                    
                    if let token: String = UserDefaultsManager.shared.value(forKey: .deviceToken) {
                        print("Device Token \(token)")
//                        viewModel.saveDeviceDetail(parameter: DeviceDetailModal(device_token: token, device_platform: UIDevice.current.systemName.lowercased(), device_version: UIDevice.current.systemVersion))
                    }
//                }else{
                alertType = .sheetType(icon: .success, title: dict?.status?.capitalized ?? "", message: AppString.chooseLanguage.localized, primaryBtnText: AppString.continueBtn.localized , secondaryBtnText: "", sheetThemeColor: .secondary)
                withAnimation(.snappy) { navigateTotab = true }
               
//                }
            }else{
                alertType = .sheetType(icon: .alert, title: dict?.status?.capitalized ?? "", message: dict?.message ?? "", primaryBtnText: AppString.ok.localized, secondaryBtnText: "", sheetThemeColor: .secondary)
                withAnimation(.snappy) { showError = true }
            }
//        } else if viewModel.requestType == "SaveDeviceDetail" {
////            viewModel.getCombineDetail()
//        } else if viewModel.requestType == "CombineDetail" {
//            if loginDetail.role_id == "2" && loginDetail.is_student ?? "" == "" {
//                if viewModel.loginResponceDict?.data.is_first_login ?? -1 == 1{
//                    navigatetoUser = true
//                }else{
//                    appRootManager.currentRoot = .user
//                }
//            } else if loginDetail.role_id == "3" && loginDetail.emp_company_created ?? false == false {
//                if viewModel.loginResponceDict?.data.is_first_login  ?? -1  == 1{
//                    navigateToEmployer = true
//                }else{
//                    appRootManager.currentRoot = .employer
//                }
//            } else if loginDetail.role_id == "4"{
//                navigateToCompanyUser = true
//
//            } else{
//                if viewModel.loginResponceDict?.data.user_role == "employee"{
//                    
//                    
//                    
//                    DispatchQueue.main.async {
//                        if viewModel.loginResponceDict?.data.is_first_login  ?? -1  == 1{
//                            appRootManager.currentRoot = .welcome
//                        }else{
//                            appRootManager.currentRoot = .user
//                        }
//                    }
//                }else{
//                    if viewModel.loginResponceDict?.data.subscription == nil || viewModel.loginResponceDict?.data.subscription?.is_expired == "yes"{
//                    DispatchQueue.main.async {
//                        appRootManager.currentRoot = .subscription
//                    }
//                }else{
//                    DispatchQueue.main.async {
//                        if viewModel.loginResponceDict?.data.is_first_login  ?? -1  == 1{
//                            appRootManager.currentRoot = .welcome
//                        }else{
//                            appRootManager.currentRoot = .employer
//                        }
//                    }
//                }
//                }
//            }
        }
    }
    
    func saveLoginDetail(mail: String, password: String) {
//        let detail = loginDetailList.count == 0 ? Login(context: self.viewContext) : loginDetailList.first
//        detail?.mailId = mail
//        detail?.password = password
//        
//        do {
//            try self.viewContext.save()
//            print("Login Detail saved!")
//        } catch {
//            print("whoops \(error.localizedDescription)")
//        }
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

