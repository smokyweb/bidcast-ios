//    //
//    //  ResetPasswordScreen.swift
//    // BidSwipe
//    //
//    //  Created by Abdul-JAM-E-157 on 19/01/24.
//    //
//
import SwiftUI
import BottomSheet
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD

struct ResetPasswordScreen: View {

    // MARK: - Static Properties
    
    @EnvironmentObject var appRootManager: AppRootManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State var isRemeber: Bool = false
    @State var isLoading: Bool = false
    @State var confPassword: String = ""
    @State var password: String = ""
    @State var navigateToLogin: Bool = false

    // MARK: - View Model & Request
    @State var request: ResetPasswordRequest = ResetPasswordRequest(email: "", password: "", password_confirmation: "")
    var viewModel = ResetPasswordViewModel()

    // MARK: - Custom Alert
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showhud: Bool = false
    @State var hudMsg: String = ""

    var body: some View {
        VStack {
            VStack{
                PrimaryHeader(
                    title: AppString.resetPassword,
                    leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        withAnimation {
                            appRootManager.currentRoot = .authentication
                        }
                    },
                    count: .constant(0)
                )
                 
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Color.clear.frame(height: 5)

                    TitleWithLine(title: AppString.resetPassword, lineLength: 48)
                    SingleTitleLabel(title: AppString.successNewPassword.localized, textColor: .mediumLightGray, fontValue: 13.0)
                    AuthTextField(
                        floatingLabel: AppString.enterPassword.localized,
                        placeholder: AppString.enterPassword.localized,
                        icon: .bag,
                        text: $password,
                        isPassword: true, enteredText:  { password in
                            request.password = password
                        })

                    AuthTextField(
                        floatingLabel: AppString.confirmPassword.localized,
                        placeholder: AppString.confirmPassword.localized,
                        icon: .bag,
                        text: $confPassword,
                        isPassword: true, enteredText:  { password in
                            confPassword = password
                        })
                    .padding(.bottom, 16)

                    PrimaryButton(title: AppString.submit.localized, isOutLine: false,onButtonClick: {
                        UIApplication.shared.endEditing()
                        
                        guard !networkMonitor.isConnected else {
                            hudMsg = "No Internet Connection"
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

                        guard request.password == confPassword else {
                            hudMsg = AppString.passwordNotMatched.localized
                            showhud = true
                            return
                        }

                        if let mail: String = UserDefaultsManager.shared.value(forKey: .mailId) {
                            request.email = mail
                            request.password = password
                            request.password_confirmation = confPassword
                            Task{
                                SVProgressHUD.show()
                                self.viewModel.errorMessage?.removeAll()
                                await viewModel.resetPassword(parameters: request)
                                await SVProgressHUD.dismiss()
                                if viewModel.errorMessage == nil {
                                    handleSuccess()
                                }else{
                                    alertType = .sheetType(
                                        icon: .alert,
                                        title: "Failed",
                                        message: viewModel.errorMessage ?? "",
                                        primaryBtnText: "",
                                        secondaryBtnText: AppString.ok.localized,
                                        sheetThemeColor: .secondary
                                    )
                                    withAnimation(.snappy) {
                                        showError = true
                                    }
                                }
                            }
                        }
                    },btnTextColor: .white)
                }
            }
            
           

            CusNavLink(doNavigate: $navigateToLogin, destination: LoginScreen())
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
      
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            if viewModel.errorMessage != nil || viewModel.errorMessage != ""{
                showError = true
            }else{
                withAnimation{
                    showError = false
                }
               
            }
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if alertType.primaryBtnText == AppString.proceedToLogin.localized {
                        withAnimation {
                            appRootManager.currentRoot = .authentication
                        }
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }

  

    func handleSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.resetPasswordResponse
        if response.status == "success" {
            withAnimation(.snappy) {
                alertType = .sheetType(
                    icon: .success,
                    title: response.status.capitalized,
                    message: response.message.capitalized,
                    primaryBtnText: AppString.proceedToLogin.localized,
                    secondaryBtnText: "",
                    sheetThemeColor: .secondary
                )
                showError = true
            }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Failed",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized,
                sheetThemeColor: .secondary
            )
            withAnimation(.snappy) {
                showError = true
            }
        }
    }
}

#Preview {
    ResetPasswordScreen()
}
