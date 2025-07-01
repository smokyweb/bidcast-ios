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
import SVProgressHUD
//import AuthenticationServices

struct LoginScreen: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
//    @EnvironmentObject var coreDataManager: CoreDataProvider
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var languageManager = LanguageManager.shared

    
//    @FetchRequest(sortDescriptors: []) private var loginDetailList: FetchedResults<Login>
    
    @State var isRemeber: Bool = true
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
                    Image(.logo1)
                        .frame(width: screenWidth, height: screenHeight/3.8)
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
                                .tint(.defaultTheme)
                            
                            Text(AppString.rememberMe.localized)
                                .font(.custom(poppinsMedium, fixedSize: placeHolder))
                                .foregroundStyle(.defaultTheme)
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
                        Task{
                            SVProgressHUD.show()
                            await self.viewModel.logIn(parameters: self.request)
                            await SVProgressHUD.dismiss()
                            await success()
                        }
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
                                .foregroundStyle(.defaultTheme)
                        })
                        Spacer()
                    }.padding([.top, .bottom], 12)

                }
                .padding([.leading, .trailing])
                .padding(.top, screenHeight/3)
                
                .toast(isPresenting: $showhud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
                }
                
                CusNavLink(doNavigate: $navigateToForgot, destination: ForgotScreen())
//                CusNavLink(doNavigate: $navigateTotab, destination: TabbarScreen())
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

        
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    func success() async {
        
        await SVProgressHUD.dismiss()
           let dict = viewModel.loginResponse
            if dict.status == "success" {
                UserDefaults.isFirstLogin = 1
//                if dict?.data.role_id != "1" {
                loginDetail = dict.data ?? LoginModel()
                UserDefaults.accessToken = dict.data?.token ?? ""
                UserDefaults.userId = dict.data?.id ?? 0
                UserDefaults.userName = dict.data?.name ?? ""
                UserDefaults.profileURL = dict.data?.profile_image ?? ""
                await self.saveDeviceDetail()
                UserDefaultsManager.shared.setValue(dict.data?.token, forKey: .token)
                UserDefaultsManager.shared.setModel(dict.data, forKey: .userDetail)
                    UserDefaultsManager.shared.setValue(isRemeber, forKey: .rememberMe)
                    if isRemeber {
                        saveLoginDetail(mail: request.email, password: request.password)
                    } else {
                        saveLoginDetail(mail: "", password: "")
                    }
                    UserDefaultsManager.shared.setValue(true, forKey: .isLoggedIn)
                   
                UserDefaultsManager.shared.setValue(dict.data?.role_id, forKey: .userRoleId)
                UserDefaultsManager.shared.setValue(dict.data?.roles?.name ??  "", forKey: .userRole)
                  
                alertType = .sheetType(icon: .success, title: dict.status?.capitalized ?? "", message: AppString.chooseLanguage.localized, primaryBtnText: AppString.continueBtn.localized , secondaryBtnText: "", sheetThemeColor: .secondary)
//                withAnimation(.snappy) { navigateTotab = true }
                DispatchQueue.main.async {
                           withAnimation {
                               appRootManager.currentRoot = .tabBar
                           }
                       }
            }else{
                alertType = .sheetType(icon: .alert, title: "Failed".capitalized, message: viewModel.errorMessage ?? "", primaryBtnText: AppString.ok.localized, secondaryBtnText: "", sheetThemeColor: .secondary)
                withAnimation(.snappy) { showError = true }
            }
        
    }
    
    func saveLoginDetail(mail: String, password: String) {
        UserDefaults.userEmail = mail
        UserDefaults.password = password
    }
    
    //MARK: saveDeviceDetail.
    func saveDeviceDetail() async{
        let deviceTimeZone = getDeviceTimeZone()
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let param = DeviceDetailRequest(device_token: UserDefaults.accessToken, platform: UIDevice.current.systemName.lowercased(), app_version: bundleVersion, time_zone: deviceTimeZone)
        print("Device Detail is:- \(param)")
        await self.viewModel.saveDeviceDetail(parameters: param)
    }
}

extension LoginScreen{
    func isValidPhone(phone: String) -> Bool {
        if Set(phone).count == 1 && phone.first == "0" {
            return false
        }
        
        let phoneRegex = "^[0-9]{10,12}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        return phoneTest.evaluate(with: phone)
    }
}

//
//#Preview {
//    LoginScreen()
//}
//
