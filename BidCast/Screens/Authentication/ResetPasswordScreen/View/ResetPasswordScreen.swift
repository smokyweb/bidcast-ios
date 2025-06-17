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
                        self.navigateToLogin = true
                    },
                    count: .constant(0)
                )
                 
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    Color.clear.frame(height: 5)

                    TitleWithLine(title: AppString.resetPassword, lineLength: 48)

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
                                await viewModel.resetPassword(parameters: request)
                                await SVProgressHUD.dismiss()
                                handleSuccess()
                            }
                        }
                    },btnTextColor: .white)
                }
//                .padding(.horizontal)
//                .padding(.top, 80)
//                .padding(.bottom, 32)
            }
            
           

            CusNavLink(doNavigate: $navigateToLogin, destination: LoginScreen())
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
      
        .bottomSheet(isPresented: $showError, height: screenHeight / 2, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if alertType.primaryBtnText == AppString.proceedToLogin.localized {
                        navigateToLogin = true
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
