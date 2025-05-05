//
//  LoginScreen.swift
//  imperium
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI
import OneSignalCore
import OneSignalFramework
import CoreData
import BottomSheet
import AlertToast
import AuthenticationServices

struct LoginScreen: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @EnvironmentObject var coreDataManager: CoreDataProvider
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(sortDescriptors: []) private var loginDetailList: FetchedResults<Login>
    
    @State var isRemeber: Bool = true
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var navigateToForgot: Bool = false
    @State var navigateToSignUp: Bool = false
    @State var navigateToLinkedIn: Bool = false
    @State var signInWithApple: Bool = false
    @State private var isLoggedIn = false

    @State var navigateToEmployer: Bool = false
    @State var navigateToCompanyUser: Bool = false

    @State var navigatetoUser: Bool = false
    @State private var coordinator: AppleSignInCoordinator? // Strong reference to the coordinator

    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var request: LoginRequest = LoginRequest(user_name: "", password: "")
    
    @State var loginDetail: UserDetailModal = UserDetailModal()
    
    var viewModel = LoginViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .bottom) {
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    Image(.halfBackground)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth, height: screenHeight/3)
                        .edgesIgnoringSafeArea(.top)
                        .overlay(alignment: .top, content: {
                            Image(.appName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth/2, height: screenHeight/12)
                                .padding(.top, screenHeight/20)
                        })
                    Spacer()
                }
                    //            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sign In")
                            .font(.custom(nunitoBlack, fixedSize: 23))
                            .bold()
                            .foregroundStyle(.text)
                        Divider()
                            .frame(width: 28, height: 5)
                            .background(.red)
                    }.padding(.bottom, 25)
                    
                    Group {
                        AuthTextField(floatingLabel: "User Name", placeholder: "Enter User Name", icon: .menuProfile, text: $request.user_name) { email in
                            self.request.user_name = email
                        }
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        
                        AuthTextField(floatingLabel: "Password", placeholder: "Enter Password", icon: .passwordLock, text: $request.password, isPassword: true) { password in
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
                            
                            Text("Remember Me")
                                .font(.custom(nunitoMedium, fixedSize: 14))
                                .foregroundStyle(.gray)
                        })
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                navigateToForgot = true
                            }
                        }, label: {
                            Text("Forgot password?")
                                .font(.custom(nunitoRegular, fixedSize: 14))
                                .foregroundStyle(.text)
                        })
                    }.padding([.top, .bottom], 10)
                    
                    
                    PrimaryButton(title: "Sign In", isOutLine: false) {
                        UIApplication.shared.endEditing()
                        
                        SecAddSharedWebCredential(
                            "io.knoxweb.imperium" as CFString,
                            request.user_name as CFString,
                            request.password as CFString) { error in
                                Log.e("Error >> \(String(describing: error))")
                            }
                        
                        guard !request.user_name.isEmpty else {
                            hudMsg = "User name can not be empty."
                            showhud = true
                            return
                        }
                        
//                        guard request.user_name else {
//                            hudMsg = "Please enter a valid mail id or user name."
//                            showhud = true
//                            return
//                        }
                        
                        guard !request.password.isEmpty else {
                            hudMsg = "Password can not be empty."
                            showhud = true
                            return
                        }
                        
                        guard request.password.count > 7 else {
                            hudMsg = "Password can not be less than 8 characters."
                            showhud = true
                            return
                        }
                        
                        self.viewModel.logIn(parameters: self.request)
                    }
                    
                    ButtonWithImage(title: "Sign In with LinkedIn") {
                        UIApplication.shared.endEditing()
                        navigateToLinkedIn = true
                    }
					
					ButtonWithImage(title: "Sign In with Apple", imageRes: .appleLogo) {
						UIApplication.shared.endEditing()
						performSignInWithApple()
					}
                    
                    HStack(spacing: 6) {
                        Spacer()
                        Text("New to Imperium? ")
                            .font(.custom(nunitoMedium, fixedSize: 14))
                            .foregroundStyle(.gray)
                        Button(action: {
                            withAnimation(.easeInOut) {
                                navigateToSignUp = true
//                                navigatetoUser = true
                            }
                        }, label: {
                            Text("Sign Up today!")
                                .font(.custom(nunitoBold, fixedSize: 14))
                                .foregroundStyle(.red)
                        })
                        Spacer()
                    }.padding([.top, .bottom], 25)
                    
                }
                .padding([.leading, .trailing])
                .padding(.top, screenHeight/3.5)
                .fullScreenCover(isPresented: $navigateToLinkedIn) {
                    ZStack {
                        VStack(spacing: 0) {
                            PrimaryHeader(
                                title: "LinkedIn",
                                trailingImgArr: [.cancel],
                                onClickTrailing: { _ in
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        navigateToLinkedIn = false
                                    }
                                }, count: .constant(0))
                            LinkedInViewContainer(url: LinkedInConstants.AUTHURL + "?response_type=code&client_id=" + LinkedInConstants.CLIENT_ID + "&scope=" + LinkedInConstants.SCOPE + "&client_secret=" + LinkedInConstants.CLIENT_SECRET + "&redirect_uri=" + LinkedInConstants.REDIRECT_URI) { result in
                                switch result {
                                    case .success(authCode: let authCode):
                                        if authCode != "" {
                                            navigateToLinkedIn = false
                                            viewModel.getLinkedInDetails(param: result.message())
                                            observe()
                                        }
                                    case .inProgress:
                                        isLoading = true
                                        return
                                    case .stopLoading:
                                        isLoading = false
                                        return
                                    case .aceessDenied, .loginCancel, .loginFailed:
                                        navigateToLinkedIn = false
                                        hudMsg = result.message()
                                        showhud = true
                                        return
                                    case .error(error: _):
                                        navigateToLinkedIn = false
                                        hudMsg = result.message()
                                        showhud = true
                                        return
                                }
                            }
                        }
                        
                        if isLoading {
                            Loader(isLoading: $isLoading)
                        }
                    }
                }
                .toast(isPresenting: $showhud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
                }
                
                if isLoading {
                    Loader(isLoading: $isLoading)
                }
                
                
                CusNavLink(doNavigate: $navigateToForgot, destination: ForgotScreen())
                
                CusNavLink(doNavigate: $navigateToEmployer, destination: CreateEmployerProfile())
                
                CusNavLink(doNavigate: $navigatetoUser, destination: WelcomeScreen())
                CusNavLink(doNavigate: $navigateToSignUp, destination: SignUpScreen())

                CusNavLink(doNavigate: $signInWithApple, destination: SignUpScreen(AppleLogin: true))

                CusNavLink(doNavigate: $navigateToEmployer, destination: SubscriptionScreen(isLoginFlow: true))
                CusNavLink(doNavigate: $navigateToCompanyUser, destination: EmployerHomeScreen())

            }
        }
        .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if alertType.primaryBtnText == "Continue" {
                        navigateToSignUp = true
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
            if loginDetailList.count > 0 {
                request.user_name = loginDetailList.first?.mailId ?? ""
                request.password = loginDetailList.first?.password ?? ""
            }
            UserDefaultsManager.shared.remove(forKey: .isLinkedInLogin)
            observe()
        }
//        .fullScreenCover(isPresented: $navigateToSignUp, content: {
//            SignUpScreen()
//        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    func performSignInWithApple() {
           let request = ASAuthorizationAppleIDProvider().createRequest()
           request.requestedScopes = [.fullName, .email]
           
           coordinator = AppleSignInCoordinator { success in
               if success {
                   signInWithApple = true
               }
           }
           
           let controller = ASAuthorizationController(authorizationRequests: [request])
           controller.delegate = coordinator
           controller.performRequests()
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
                        alertType = .sheetType(icon: .alert, title: "Login Failed", message: "Fail to login with current credentials", primaryBtnText: "", secondaryBtnText: "Retry Login", sheetThemeColor: .pinkBtn)
                        showError = true
                        Log.e(error as Any)
                    } else {
                        alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                        showError = true
                        Log.e(error as Any)
                    }
            }
        }
    }

    
    func success() {
        
        if viewModel.requestType == "LinkedInDetail" {
            if let response = viewModel.linkedInResponse {
                if response.status == "success" {
                    if let data: UserDetailModal = response.data.login {
                        if (data.id ?? 0 != 0) {
                            if( data.role_id ?? "") != "1" {
                                UserDefaultsManager.shared.setValue(data.token, forKey: .token)
                                UserDefaultsManager.shared.setValue(true, forKey: .rememberMe)
                                UserDefaultsManager.shared.setValue(true, forKey: .isLoggedIn)
                                UserDefaultsManager.shared.setValue(true, forKey: .isLinkedInLogin)
                                UserDefaultsManager.shared.setValue(data.role_id, forKey: .userRoleId)
                                if let roleID = data.role_id {
                                    let userRole: String
                                    switch roleID {
                                    case "1":
                                        userRole = "admin"
                                    case "2":
                                        userRole = "employee"
                                    case "3":
                                        userRole = "employer"
                                    default:
                                        userRole = "user"
                                    }
                                    UserDefaultsManager.shared.setValue(userRole, forKey: .userRole)
                                }

                                let userData: SignInData = SignInData(id: data.id, name: data.name, first_name: data.first_name, last_name: data.last_name, role_id: data.role_id, location: data.location, profile_image: data.profile_image, video_resume: data.video_resume, email: data.email, created_at: data.created_at, token: data.token, user_role: data.roles?.user_role)
                                UserDefaultsManager.shared.setModel(userData, forKey: .userDetail)
                                
                                let id = data.id!.description
                                OneSignal.login(id)
                                let observer = MyPushSubscriptionObserver()
                                OneSignal.User.pushSubscription.addObserver(observer)
                                if OneSignal.User.pushSubscription.optedIn {
                                    if let id = OneSignal.User.pushSubscription.id {
                                        Log.i("FCM token: \(id)")
                                        UserDefaultsManager.shared.setValue(id , forKey: .deviceToken)
                                    }
                                        // User is opted in for push notifications
                                        // Update your UI or perform other actions here
                                } else {
                                    Log.i("User is opted out of push notifications")
                                        // User is opted out of push notifications
                                        // Update your UI or perform other actions here
                                }
                                if let token: String = UserDefaultsManager.shared.value(forKey: .deviceToken) {
                                    viewModel.saveDeviceDetail(parameter: DeviceDetailModal(device_token: token, device_platform: UIDevice.current.systemName.lowercased(), device_version: UIDevice.current.systemVersion))
                                }
                            } else {
                                alertType = .sheetType(icon: .alert, title: "Access Denied", message: "Admin not authorized for App Login.", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                                withAnimation(.snappy) { showError = true }
                            }
                        } else {
                            UserDefaultsManager.shared.setValue(true, forKey: .isLinkedInLogin)
                            UserDefaultsManager.shared.setModel(response.data, forKey: .linkedInData)
                            navigateToSignUp = true
                        }
                    } else if let data: LinkedInStatusModel = response.data.signup {
                        UserDefaultsManager.shared.setValue(true, forKey: .isLinkedInLogin)
                        UserDefaultsManager.shared.setModel(data, forKey: .linkedInData)
                        alertType = .sheetType(icon: .success, title: "LinkedIn SignUp", message: "Please continue SignUp Process.", primaryBtnText: "Continue", secondaryBtnText: "Cancel", sheetThemeColor: .text)
                        withAnimation(.snappy) { showError = true }
                    }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.snappy) { showError = true }
                }
            }
        } else if viewModel.requestType == "Login" {
            let dict = viewModel.loginResponceDict
            if dict?.status == "success" {
                UserDefaults.isFirstLogin = dict?.data.is_first_login ?? 0
                if dict?.data.role_id != "1" {
                    loginDetail = dict!.data
                    UserDefaultsManager.shared.setValue(dict?.data.token, forKey: .token)
                    UserDefaultsManager.shared.setModel(dict?.data, forKey: .userDetail)
                    UserDefaultsManager.shared.setValue(isRemeber, forKey: .rememberMe)
                    if isRemeber {
                        saveLoginDetail(mail: request.user_name, password: request.password)
                    } else {
                        saveLoginDetail(mail: "", password: "")
                    }
                    UserDefaultsManager.shared.setValue(true, forKey: .isLoggedIn)
//                    UserDefaultsManager.shared.setValue(dict?.data.right_swipes, forKey: .employerRightSwipe)
                    UserDefaults.EmployerRightSwipe = dict?.data.right_swipes
                    UserDefaultsManager.shared.setValue(dict?.data.role_id, forKey: .userRoleId)
                    UserDefaultsManager.shared.setValue(dict?.data.roles?.user_role ??  "", forKey: .userRole)
                    if dict?.data.employer_matches_count ?? "" != "" {
                        if let count: Int = Int(dict?.data.employer_matches_count ?? "0") {
                            UserDefaultsManager.shared.setValue(count > 0, forKey: .isSubscribed)
                            if count > 0 {
                                UserDefaultsManager.shared.setValue(dict?.data.subscription?.product_id ?? "", forKey: .subscriptionType)
                            }
                        }
                    }
                    let id = dict!.data.id!.description
                    OneSignal.login(id)
                    let observer = MyPushSubscriptionObserver()
                    OneSignal.User.pushSubscription.addObserver(observer)
                    if OneSignal.User.pushSubscription.optedIn {
                        if let id = OneSignal.User.pushSubscription.id {
                            Log.i("FCM token: \(id)")
                            UserDefaultsManager.shared.setValue(id , forKey: .deviceToken)
                        }
                            // User is opted in for push notifications
                            // Update your UI or perform other actions here
                    } else {
                        Log.i("User is opted out of push notifications")
                            // User is opted out of push notifications
                            // Update your UI or perform other actions here
                    }
                    
                    if let token: String = UserDefaultsManager.shared.value(forKey: .deviceToken) {
                        viewModel.saveDeviceDetail(parameter: DeviceDetailModal(device_token: token, device_platform: UIDevice.current.systemName.lowercased(), device_version: UIDevice.current.systemVersion))
                    }
                }else{
                    alertType = .sheetType(icon: .alert, title: "Access Denied", message: "Admin not authorized for App Login.", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.snappy) { showError = true }
                }
            }else{
                alertType = .sheetType(icon: .alert, title: dict?.status?.capitalized ?? "", message: dict?.message ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                withAnimation(.snappy) { showError = true }
            }
        } else if viewModel.requestType == "SaveDeviceDetail" {
            viewModel.getCombineDetail()
        } else if viewModel.requestType == "CombineDetail" {
            if loginDetail.role_id == "2" && loginDetail.is_student ?? "" == "" {
                if viewModel.loginResponceDict?.data.is_first_login ?? -1 == 1{
                    navigatetoUser = true
                }else{
                    appRootManager.currentRoot = .user
                }
            } else if loginDetail.role_id == "3" && loginDetail.emp_company_created ?? false == false {
                if viewModel.loginResponceDict?.data.is_first_login  ?? -1  == 1{
                    navigateToEmployer = true
                }else{
                    appRootManager.currentRoot = .employer
                }
            } else if loginDetail.role_id == "4"{
                navigateToCompanyUser = true

            } else{
                if viewModel.loginResponceDict?.data.user_role == "employee"{
                    
                    
                    
                    DispatchQueue.main.async {
                        if viewModel.loginResponceDict?.data.is_first_login  ?? -1  == 1{
                            appRootManager.currentRoot = .welcome
                        }else{
                            appRootManager.currentRoot = .user
                        }
                    }
                }else{
                    if viewModel.loginResponceDict?.data.subscription == nil || viewModel.loginResponceDict?.data.subscription?.is_expired == "yes"{
                    DispatchQueue.main.async {
                        appRootManager.currentRoot = .subscription
                    }
                }else{
                    DispatchQueue.main.async {
                        if viewModel.loginResponceDict?.data.is_first_login  ?? -1  == 1{
                            appRootManager.currentRoot = .welcome
                        }else{
                            appRootManager.currentRoot = .employer
                        }
                    }
                }
                }
            }
        }
    }
    
    func saveLoginDetail(mail: String, password: String) {
        let detail = loginDetailList.count == 0 ? Login(context: self.viewContext) : loginDetailList.first
        detail?.mailId = mail
        detail?.password = password
        
        do {
            try self.viewContext.save()
            print("Login Detail saved!")
        } catch {
            print("whoops \(error.localizedDescription)")
        }
    }
}

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate {
    private let completion: (Bool) -> Void

    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = appleIDCredential.user
            let fullName = appleIDCredential.fullName ?? PersonNameComponents()
            let firstName = appleIDCredential.fullName?.givenName ?? ""
            let lastName = appleIDCredential.fullName?.familyName ?? ""
            let email = appleIDCredential.email ?? ""
            
            print("User ID: \(userID),Name : \(fullName), Email : \(email)")
            
           
            if firstName != "" && lastName != ""{
                UserDefaults.userFirstNameWithApple = firstName
                UserDefaults.userLastNameWithApple = lastName
                UserDefaults.userEmailWithApple = email
            }
            
            // Call the completion handler with success
            completion(true)
        }
    }
    
    
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple failed: \(error.localizedDescription)")
        // Call the completion handler with failure
        completion(false)
    }
}

#Preview {
    LoginScreen()
}
