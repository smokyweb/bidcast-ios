//
//  ForgotScreen.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import SwiftUI
import BottomSheet
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD

struct ForgotScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var isRemeber: Bool = false
   
    @State var request: ForgetRequest = ForgetRequest(email: "")
    @State var navigateToOTP: Bool = false
    @State var showError: Bool = false
    @State var isPassword: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    var viewModel = ForgotViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(spacing: 0) {
                PrimaryHeader(
                    title: AppString.forgetPassword.localized,
                    leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 25) {
                        Color.clear.frame(height: 5)
                        TitleWithLine(title: AppString.forgetPassword, lineLength: sepratorLine)
                        SingleTitleLabel(title: AppString.emailAddressNotAssociated.localized, textColor: .mediumLightGray, fontValue: 13.0)
                        
                        AuthTextField(
                            floatingLabel: AppString.email.localized,
                            placeholder: AppString.enterEmail.localized,
                            icon: .icMail,
                            text: $request.email, enteredText:  { email in
                                self.request.email = email
                            })
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                        
                        PrimaryButton(
                            title: AppString.submit.localized,
                            isOutLine: false,
                            onButtonClick: {
                                UIApplication.shared.endEditing()
                                
                                guard !request.email.isEmpty else {
                                    hudMsg = AppString.pleaseEnterEmail.localized
                                    showhud = true
                                    return
                                }
                                
                                guard request.email.isValidEmail() else {
                                    hudMsg = AppString.pleaseEnterValidEmailAddress.localized
                                    showhud = true
                                    return
                                }
                                Task{
                                    SVProgressHUD.show()
                                    await  self.viewModel.forgotEmail(parameters: self.request)
                                    handleSuccess()
                                }
                               
                            },
                            btnTextColor: .white
                        )
                    }
//                    .padding(.horizontal)
//                    .padding(.bottom, 32)
                }
//                .padding(.top, 20)
            }

            CusNavLink(doNavigate: $navigateToOTP, destination: VerifyOtpScreen())
        }
        .frame(width: screenWidth, height: screenHeight)
        .onAppear {
            UIScrollView.appearance().bounces = false
           
        }
        .onDisappear {
            DispatchQueue.main.async {
                UIScrollView.appearance().bounces = true
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    if isPassword {
                        withAnimation(.snappy) { navigateToOTP = true }
                    } else {
                        withAnimation { showError = false }
                    }
                }
            )
        }
    }

  
    func handleSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.forgotResponseDict
        
        if response.status == "success" {
            UserDefaultsManager.shared.setValue(request.email, forKey: .mailId)
            alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .green)
            showError = true
            isPassword = true
            withAnimation(.snappy) { navigateToOTP = true }
        } else {
            alertType = .sheetType(icon: .alert, title: "Failed", message: viewModel.errorMessage ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
}




