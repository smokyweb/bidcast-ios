//
//  SignUpScreen.swift
//  imperium
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
//    @State var request: RegisterRequest = RegisterRequest(first_name: "", last_name: "", user_name: "", email: "", password: "", password_confirmation: "", location: "", role_id: "", linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: ""))
    @State var request : SignUpRequest = SignUpRequest(firstName: "", lastName: "", email: "", password: "", passwordConf: "", roleID: 2)
    @State var requestCompany: CreateCompanyRequest = CreateCompanyRequest(company_id: "", name: "", website_link: "", industry: "", address: "", phone: "", size: "", type: "", tag_line: "", logo: "")
    
    @State var requestUserName: CreateUserRequest = CreateUserRequest(user_name: "")
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var navigateToEmployer: Bool = false
    @State var navigatetoUser: Bool = false
    @State var AppleLogin: Bool = false
    @State var appleUserFirstname: String = ""
    @State var appleUserLastname: String = ""
    @State var appleUserEmail: String = ""

    
    @State var locationArr: [String] = []
    
    @State var isLinkedIn: Bool = false
    @State var linkedInDetail: LinkedInStatusModel = LinkedInStatusModel(sub: "", email_verified: false, name: "", given_name: "", family_name: "", email: "", locale: LocaleModel(country: "", language: ""), linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: ""))
    
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
                        Text(AppString.createYourAccount.localized)
                            .font(.custom(nunitoBlack, fixedSize: 18))
                            .fontWeight(.bold)
                            .frame(width: screenWidth - 50, alignment: .leading)
                        
//                        if AppleLogin{
//                            AuthTextField(floatingLabel: "First Name", placeholder: UserDefaults.userFirstNameWithApple, icon: .menuProfile, text: $appleUserFirstname, enteredText: {
//                                value in
//                                request.first_name = value
//                            })
//                            .disabled(true)
//                            .textContentType(.givenName)
//
//                        }else{
                        AuthTextField(floatingLabel: AppString.firstName.localized, placeholder: AppString.enterFirstName.localized, icon: .menuProfile, text: $request.firstName, enteredText: {
                                value in
                                request.firstName = value
                            })
                            .textContentType(.givenName)

//                        }
                        
                        
//                        if AppleLogin{
//                            AuthTextField(floatingLabel: "Last Name", placeholder: UserDefaults.userLastNameWithApple, icon: .menuProfile, text: $appleUserLastname, enteredText: {
//                                value in
//                                request.last_name = value
//                            })
//                            .disabled(true)
//                            .textContentType(.givenName)
//
//                        }else{
                            
                        AuthTextField(floatingLabel: AppString.lastName.localized, placeholder: AppString.enterLastName.localized, icon: .menuProfile, text: $request.lastName, enteredText: {
                                value in
                                request.lastName = value
                            })
                            .textContentType(.familyName)
                            
//                        }
                        
//                        if AppleLogin{
//                            
//                            if appleUserEmail == ""{
//                                AuthTextField(floatingLabel: "Email Address", placeholder: "Enter Email Address", icon: .mail, text: $request.email, enteredText: {
//                                    value in
//                                    request.email = value
//                                }).textContentType(.username)
//                                .disabled(false)
//                            }else{
//                                AuthTextField(floatingLabel: "Email Address", placeholder: UserDefaults.userEmailWithApple, icon: .mail, text: $appleUserEmail, enteredText: {
//                                    value in
//                                    request.email = value
//                                }).textContentType(.username)
//                                .disabled(true)
//                            }

                            
//                        }else{
                        AuthTextField(floatingLabel: AppString.email.localized, placeholder: AppString.pleaseEnterEmail.localized, icon: .icMail, text: $request.email, enteredText: {
                                value in
                                request.email = value
                            }).textContentType(.username)
//                        }
                        
//                        AuthTextField(floatingLabel: "User Name", placeholder: "Enter User Name", icon: .menuProfile, text: $request.user_name, enteredText: {
//                            value in
//                            request.user_name = value
//                            requestUserName.user_name = value
//                        }).textContentType(.username)
                        
                        AuthTextField(floatingLabel: AppString.password.localized, placeholder: AppString.enterPassword.localized, icon: .passwordLock, text: $request.password, isPassword: true, enteredText: {
                            value in
                            request.password = value
                        }).textContentType(.password)
                        
                        AuthTextField(floatingLabel: AppString.confirmPassword.localized, placeholder: AppString.pleaseConfirmPassword.localized, icon: .passwordLock, text: $request.passwordConf, isPassword: true, enteredText: {
                            value in
                            request.passwordConf = value
                        }).textContentType(.newPassword)
                            
                        
                    }.padding([.leading, .trailing])
                    
//                    DropDown(hint: "Select Role", options: ["Candidate", "Employer"], anchor: .top,floatingLabel: "Select Role", cornerRadius: 25, showLeadingIcon : true, leadingIcon:.menuProfile, onOptionSelected: {
//                        option in
//                        if option == "Candidate" {
//                            request.role_id = "2"
//                        } else {
//                            request.role_id = "3"
//                        }
//                    })
//                    .padding(.vertical)
//                    .textContentType(.jobTitle)

                    
                    VStack {
//                        Text("Location")
//                            .font(.custom(nunitoBlack, fixedSize: 18))
//                            .frame(width: screenWidth - 30, alignment: .leading)
//                        
//                        DropDownTextField(
//                            hint: "Confirm your location",
//                            floatingLabel: "Confirm your location",
//                            text: $request.location,
//                            options: $locationArr,
//                            leadingIcon: .location,
//                            showLeadingIcon: true,
//                            showTrailingIcon: false,
//                            onOptionSelected: { text in
//                                    ////                                langArray[ind].name = text
//                            },
//                            anchor: .top)
//                        .textContentType(.location)
//                        .onChange(of: request.location) { newValue in
//                            GooglePlacesManager.shared.findPlaces(query: newValue) { result in
//                                switch result {
//                                    case .success(let places):
//                                        withAnimation(.easeIn(duration: 0.5)) {
//                                            locationArr.removeAll()
//                                            places.forEach { place in
//                                                locationArr.append(place.name)
//                                            }
//                                        }
//                                    case .failure(let error):
//                                        print(error)
//                                }
//                            }
//                        }
                        
                        
                        PrimaryButton(title: AppString.submit.localized, isOutLine: false, onButtonClick: {
                            
                            UIApplication.shared.endEditing()
//                            if AppleLogin{
//                                guard !appleUserFirstname.isEmpty else {
//                                    hudMsg = "Email address is required"
//                                    showhud = true
//                                    return
//                                }
//                            }else{
                            guard !request.firstName.isEmpty else {
                                hudMsg = AppString.pleaseEnterFirstName.localized
                                    showhud = true
                                    return
                                }
//                            }
//                            if AppleLogin{
//                                guard !appleUserLastname.isEmpty else {
//                                    hudMsg = "Last Name is required"
//                                    showhud = true
//                                    return
//                                }
//                                
//                            }else{
                            guard !request.lastName.isEmpty else {
                                hudMsg = AppString.pleaseEnterLastName.localized
                                    showhud = true
                                    return
                                }
//                            }
                            
//                            if AppleLogin{
//                                
//                                if appleUserEmail == ""{
//                                    guard !request.email.isEmpty else {
//                                        hudMsg = "Email address is required"
//                                        showhud = true
//                                        return
//                                    }
//                                }else{
//                                    guard !appleUserEmail.isEmpty else {
//                                        hudMsg = "Email address is required"
//                                        showhud = true
//                                        return
//                                    }
//                                }
//                            }else{
                                
                                guard !request.email.isEmpty else {
                                    hudMsg = AppString.pleaseEnterEmail.localized
                                    showhud = true
                                    return
                                }
//                            }
                            
//                            guard !request.user_name.isEmpty else {
//                                hudMsg = "User Name is required"
//                                showhud = true
//                                return
//                            }
                            
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
                            
//                            guard !request.role_id.isEmpty else {
//                                hudMsg = "User role is required"
//                                showhud = true
//                                return
//                            }
                            
//                            guard !request.location.isEmpty else {
//                                hudMsg = "Location is required"
//                                showhud = true
//                                return
//                            }

//                            if request.role_id == "2" {
//                                navigatetoUser = true
//
//                            } else if request.role_id == "3"{
//                                navigateToEmployer = true
//                            }
                            print("Parameters for register user :- \(request)")
                            self.viewModel.registerUser(parameters: request)
                            
                            
                      
                                UserDefaults.userEmail = request.email
                                UserDefaults.firstName = request.firstName
                            UserDefaults.lastName = request.lastName

//
//                            UserDefaults.userNameAdd = request.user_name

                            UserDefaults.userRole = "\(request.roleID)"
                            UserDefaults.password = request.password
                        })
                    }
                    .padding([.top, .bottom], 30)
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
            

            
            
//            CusNavLink(doNavigate: $navigatetoUser, destination: UserCreateProfile(firstName: request.first_name,lastName: request.last_name, email:request.email, password:request.location, role:request.role_id, location:request.location))
//                
//            CusNavLink(doNavigate: $navigateToEmployer, destination: EmployerCreateCompany(requestSignUp: RegisterRequest(first_name: request.first_name, last_name: request.last_name, user_name: request.user_name, email: request.email, password: request.password, password_confirmation: request.password_confirmation, location: request.location, role_id: request.role_id, linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: "")), isLoginFlow: true))
                

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
        
//        if viewModel.requestType == "LinkedInDetail" {
//            if let response = viewModel.linkedInResponse {
//                if response.status == "success" {
//                    UserDefaultsManager.shared.setValue(true, forKey: .isLinkedInLogin)
//                    UserDefaultsManager.shared.setModel(response.data, forKey: .linkedInData)
//                    if let signUpResponse = response.data.signup {
//                        linkedInDetail = signUpResponse
//                        request.first_name = response.data.signup?.given_name ?? ""
//                        request.last_name = response.data.signup?.family_name ?? ""
//                        request.email = response.data.signup?.email ?? ""
//                        request.linkedin_sub_id = response.data.signup?.sub ?? ""
//                        request.linkedin_access = response.data.signup?.linkedin_access ?? LinkedInAccessModel()
//                    } else if response.data.login != nil {
//                        alertType = .sheetType(icon: .alert, title: "Error", message: "User already exist with this account. Please Login with LinkedIn.", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                        withAnimation(.snappy) { showError = true }
//                    } else {
//                        alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                        withAnimation(.snappy) { showError = true }
//                    }
//                } else {
//                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    withAnimation(.snappy) { showError = true }
//                }
//            } else {
//                alertType = .sheetType(icon: .alert, title: "Error", message: "Can not proceed further.", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                withAnimation(.snappy) { showError = true }
//            }
//        } else
        if viewModel.requestType == "RegisterUserName" {
            let response = viewModel.userNameDict
            if response?.status == "success" {
                UserDefaults.isFirstLogin = 1
               
//                    UserDefaultsManager.shared.setValue("employee", forKey: .userRole)
                alertType = .sheetType(icon: .success, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: AppString.backToLogin.localized, secondaryBtnText: "", sheetThemeColor: .secondary)
                showError = true
//                    navigatetoUser = true
                  
                
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
