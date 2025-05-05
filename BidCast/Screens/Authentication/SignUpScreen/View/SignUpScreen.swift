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
    @State var request: RegisterRequest = RegisterRequest(first_name: "", last_name: "", user_name: "", email: "", password: "", password_confirmation: "", location: "", role_id: "", linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: ""))
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
                PrimaryHeader(title: "Create Account",leadingImgArr: [.cancel], onClickLeading:  { _ in
//                    UserDefaultsManager.shared.setValue(false, forKey: .isLinkedInLogin)
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                
                ScrollView(showsIndicators: false) {
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
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Create an Account")
                            .font(.custom(nunitoBlack, fixedSize: 18))
                            .frame(width: screenWidth - 50, alignment: .leading)
                        
                    
                            AuthTextField(floatingLabel: "Name", placeholder: "Enter Name", icon: .menuProfile, text: $request.first_name, enteredText: {
                                value in
                                request.first_name = value
                            })
                            .textContentType(.givenName)

                                AuthTextField(floatingLabel: "Email Address", placeholder: "Enter Email Address", icon: .mail, text: $request.email, enteredText: {
                                    value in
                                    request.email = value
                                }).textContentType(.username)
                                .disabled(false)
                           
                         
                        AuthTextField(floatingLabel: "Password", placeholder: "Enter Password", icon: .passwordLock, text: $request.password, isPassword: true, enteredText: {
                            value in
                            request.password = value
                        }).textContentType(.password)
                        
                        AuthTextField(floatingLabel: "Confirm Password", placeholder: "Reenter Password", icon: .passwordLock, text: $request.password_confirmation, isPassword: true, enteredText: {
                            value in
                            request.password_confirmation = value
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

                    
                    VStack(spacing: 15) {
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
////                            GooglePlacesManager.shared.findPlaces(query: newValue) { result in
////                                switch result {
////                                    case .success(let places):
////                                        withAnimation(.easeIn(duration: 0.5)) {
////                                            locationArr.removeAll()
////                                            places.forEach { place in
////                                                locationArr.append(place.name)
////                                            }
////                                        }
////                                    case .failure(let error):
////                                        print(error)
////                                }
////                            }
//                        }
//                        
                        
                        PrimaryButton(title: "Create an Account", isOutLine: false, onButtonClick: {
                            
                           
                                guard !request.first_name.isEmpty else {
                                    hudMsg = "First Name is required"
                                    showhud = true
                                    return
                                }
                            
                           
                                guard !request.last_name.isEmpty else {
                                    hudMsg = "Last Name is required"
                                    showhud = true
                                    return
                                }
                            
                            
                                guard !request.email.isEmpty else {
                                    hudMsg = "Email address is required"
                                    showhud = true
                                    return
                                }
                            
                            
                           
                            guard !request.password.isEmpty else {
                                hudMsg = "Password is required"
                                showhud = true
                                return
                            }
                            
                            guard request.password.count >= 8 else {
                                hudMsg = "Password can not be less than 8 characters"
                                showhud = true
                                return
                            }
                            
                            guard !request.password_confirmation.isEmpty else {
                                hudMsg = "Confirm Password is required"
                                showhud = true
                                return
                            }
                            
                            guard request.password == request.password_confirmation else {
                                hudMsg = "Password and Confirm Password are  not matching"
                                showhud = true
                                return
                            }
                            
                            
//                            self.viewModel.registerUser(parameters: requestUserName)
                            
                            
//                            
//                            
//                                UserDefaults.userEmail = request.email
//                                UserDefaults.firstName = request.first_name
//                                UserDefaults.lastName = request.last_name
//
//                            
//                            
//                            UserDefaults.userNameAdd = request.user_name
//
//
//                            UserDefaults.password = request.password
//                            UserDefaults.userLocaion = request.location
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
//            .onAppear(){
//                
////                appleUserFirstname = UserDefaults.userFirstNameWithApple
////                appleUserLastname = UserDefaults.userLastNameWithApple
////                appleUserEmail = UserDefaults.userEmailWithApple
//                
//                observe()
//
//                if let isLinkedInFlow: Bool = UserDefaultsManager.shared.value(forKey: .isLinkedInLogin) {
//                    if isLinkedInFlow {
//                        if let detail: LinkedInStatusModel = UserDefaultsManager.shared.getModel(forKey: .linkedInData) {
//                            linkedInDetail = detail
//                            request.first_name = detail.given_name ?? ""
//                            request.last_name = detail.family_name ?? ""
//                            request.email = detail.email ?? ""
//                            request.linkedin_sub_id = detail.sub ?? ""
//                            request.linkedin_access = detail.linkedin_access ?? LinkedInAccessModel()
//                        }
//                    }
//                }
//            }
//            .onDisappear(perform: {
//                request = RegisterRequest(first_name: "", last_name: "", email: "", password: "", password_confirmation: "", location: "", role_id: "", linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: ""))
//            })
//            .fullScreenCover(isPresented: $navigateToLinkedIn, content: {
//                ZStack {
//                    VStack(spacing: 0) {
//                        PrimaryHeader(
//                            title: "LinkedIn",
//                            trailingImgArr: [.cancel],
//                            onClickTrailing: { _ in
//                                withAnimation(.easeInOut(duration: 0.25)) {
//                                    navigateToLinkedIn = false
//                                }
//                            }, count: .constant(0))
////                        LinkedInViewContainer(url: LinkedInConstants.AUTHURL + "?response_type=code&client_id=" + LinkedInConstants.CLIENT_ID + "&scope=" + LinkedInConstants.SCOPE + "&client_secret=" + LinkedInConstants.CLIENT_SECRET + "&redirect_uri=" + LinkedInConstants.REDIRECT_URI) { result in
////                            switch result {
////                                case .success(authCode: let authCode):
////                                    if authCode != "" {
////                                        navigateToLinkedIn = false
////                                        viewModel.getLinkedInDetails(param: result.message())
////                                        observe()
////                                    }
////                                case .inProgress:
////                                    isLoading = true
////                                    return
////                                case .stopLoading:
////                                    isLoading = false
////                                    return
////                                case .aceessDenied, .loginCancel, .loginFailed:
////                                    navigateToLinkedIn = false
////                                    hudMsg = result.message()
////                                    showhud = true
////                                    return
////                                case .error(error: _):
////                                    navigateToLinkedIn = false
////                                    alertType = .sheetType(icon: .alert, title: "Error", message: result.message(), primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
////                                    showError = true
////                                    return
////                            }
////                        }
//                    }
//                    
//                    if isLoading {
//                        Loader(isLoading: $isLoading)
//                    }
//                }
//            })
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
                        if alertType.primaryBtnText == "Proceed to Login" {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        let response = viewModel.signUpResponceDict
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
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                withAnimation(.easeInOut) { showError = true }
            }
        }
    }
    
    func handleSuccess() {
        
        if viewModel.requestType == "LinkedInDetail" {
            if let response = viewModel.linkedInResponse {
                if response.status == "success" {
                    UserDefaultsManager.shared.setValue(true, forKey: .isLinkedInLogin)
                    UserDefaultsManager.shared.setModel(response.data, forKey: .linkedInData)
                    if let signUpResponse = response.data.signup {
                        linkedInDetail = signUpResponse
                        request.first_name = response.data.signup?.given_name ?? ""
                        request.last_name = response.data.signup?.family_name ?? ""
                        request.email = response.data.signup?.email ?? ""
                        request.linkedin_sub_id = response.data.signup?.sub ?? ""
                        request.linkedin_access = response.data.signup?.linkedin_access ?? LinkedInAccessModel()
                    } else if response.data.login != nil {
                        alertType = .sheetType(icon: .alert, title: "Error", message: "User already exist with this account. Please Login with LinkedIn.", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                        withAnimation(.snappy) { showError = true }
                    } else {
                        alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                        withAnimation(.snappy) { showError = true }
                    }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.snappy) { showError = true }
                }
            } else {
                alertType = .sheetType(icon: .alert, title: "Error", message: "Can not proceed further.", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                withAnimation(.snappy) { showError = true }
            }
        } else if viewModel.requestType == "RegisterUserName" {
            let response = viewModel.userNameDict
            if response?.status == "success" {
               
                if request.role_id == "2" {

//                    UserDefaultsManager.shared.setValue("employee", forKey: .userRole)
//                    alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "Back to Login", secondaryBtnText: "", sheetThemeColor: .green)
                    
                    navigatetoUser = true

                } else if request.role_id == "3"{
//                    UserDefaultsManager.shared.setValue("employer", forKey: .userRole)
//                    alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "Back to Login", secondaryBtnText: "", sheetThemeColor: .green)
                    navigateToEmployer = true

                }else{
                    
                    
                }
            } else {
                alertType = .sheetType(icon: .alert, title: response?.error_type?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showError = true
            }
        }
    }
}
#Preview {
    SignUpScreen()
}
