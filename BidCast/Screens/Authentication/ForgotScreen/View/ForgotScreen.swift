//
//  ForgotScreen.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import SwiftUI
import BottomSheet
import AlertToast

struct ForgotScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var isRemeber: Bool = false
    @State var isLoading: Bool = false
    @State var request: ForgetRequest = ForgetRequest(user_name: "")
    @State var navigateToOTP: Bool = false
    @State var showError: Bool = false
    @State var isPassword: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    var viewModel = ForgotViewModel()
    
    var body: some View {
        ScrollView {
            ZStack {
                
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
                
                
                VStack(alignment: .leading, spacing: 25) {
                    
                    TitleWithLine(title: "Forgot Password", lineLength: 48)
                    
                    Text("Please enter the email address associated with your account")
                        .font(.custom(nunitoMedium, fixedSize: 16))
                        .foregroundStyle(.black)
                    
                    AuthTextField(floatingLabel: "E-Mail", placeholder: "Enter Email address", icon: .bag, text: $request.user_name) { email in
                        self.request.user_name = email
                    }
                    
                    PrimaryButton(title: "Submit",isOutLine: false) {
                        
                        UIApplication.shared.endEditing()
                        
                        guard !request.user_name.isEmpty else {
                            hudMsg = "User Name cannot be empty"
                            showhud = true
                            return
                        }
                        
//                        guard request.user_name.isValidEmail() else {
//                            hudMsg = "Please enter a valid mail id."
//                            showhud = true
//                            return
//                        }
                        
//                        self.viewModel.forgotEmail(parameters: self.request)
                    }
                    
                    HStack(spacing:4) {
                        Spacer()
                        Text("Back to")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                        Button(action: {
                            withAnimation {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }, label: {
                            Text("Login!").font(.system(size: 14))
                                .bold()
                                .foregroundStyle(.red)
                        })
                        Spacer()
                    }.padding([.top, .bottom], 16)
                    
                }.padding([.leading, .trailing])
                
                    .padding(.top, screenHeight/3)
                
                
                if isLoading {
                    Loader(isLoading: $isLoading)
                }

                
                
                //            if showError {
                //                AlertPopUp(presentAlert: $showError, alertType: alertType, rightButtonAction: {
                //                    withAnimation(.snappy) {
                //                        showError = false
                //                    }
                //                })
                //            }
                
//                CusNavLink(doNavigate: $navigateToOTP, destination: VerifyOtpScreen())
            }.frame(width: screenWidth, height: screenHeight)
        }
        .onAppear(){
            observe()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight/2.3, topBarCornerRadius: 25, showTopIndicator: false, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                }, onSecondaryClick: {
                    if isPassword == true{
                        withAnimation(.snappy){ navigateToOTP = true }
                    }else{
                        withAnimation { showError = false }
                    }
                })
        })
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
                showError = true
            }
        }
    }
    
    func handleSuccess() {
        let response = viewModel.forgotResponceDict
        
        if response.status == "success" {
            UserDefaultsManager.shared.setValue(request.user_name, forKey: .mailId)
            alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .green)
            showError = true
            isPassword = true
            //            withAnimation(.snappy) { navigateToOTP = true }
        } else {
            alertType = .sheetType(icon: .alert, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
            withAnimation(.snappy) { showError = true }
        }
    }
}

//#Preview {
//    ForgotScreen()
//}
