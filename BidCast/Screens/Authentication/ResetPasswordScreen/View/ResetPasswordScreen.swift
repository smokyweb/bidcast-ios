//    //
//    //  ResetPasswordScreen.swift
//    //  imperium
//    //
//    //  Created by Abdul-JAM-E-157 on 19/01/24.
//    //
//
import SwiftUI
import BottomSheet
import AlertToast

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
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    Color.clear.frame(height: 5)

                    TitleWithLine(title: "Reset Password", lineLength: 48)

                    AuthTextField(
                        floatingLabel: "Enter Password",
                        placeholder: "Enter New Password",
                        icon: .bag,
                        text: $password,
                        isPassword: true
                    ) { password in
                        request.password = password
                    }

                    AuthTextField(
                        floatingLabel: "Confirm Password",
                        placeholder: "Confirm New Password",
                        icon: .bag,
                        text: $confPassword,
                        isPassword: true
                    ) { password in
                        confPassword = password
                    }
                    .padding(.bottom, 16)

                    PrimaryButton(title: "Submit", isOutLine: false) {
                        UIApplication.shared.endEditing()

                        guard !request.password.isEmpty else {
                            hudMsg = "Password can not be empty"
                            showhud = true
                            return
                        }

                        guard request.password.count > 7 else {
                            hudMsg = "Password can not be less than 8 digit"
                            showhud = true
                            return
                        }

                        guard request.password == confPassword else {
                            hudMsg = "Password and Confirm Password can not be different"
                            showhud = true
                            return
                        }

                        if let mail: String = UserDefaultsManager.shared.value(forKey: .mailId) {
                            request.email = mail
                            request.password = password
                            request.password_confirmation = confPassword
                            viewModel.resetPassword(parameters: request)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 80)
                .padding(.bottom, 32)
            }

            PrimaryHeader(
                title: "Reset Password",
                leadingImgArr: [.icBack],
                onClickLeading: { _ in
                    self.navigateToLogin = true
                },
                count: .constant(0)
            )
            .frame(height: 80)
            .background(Color.white)
            .shadow(radius: 2)

            if isLoading {
                Loader(isLoading: $isLoading)
            }

            CusNavLink(doNavigate: $navigateToLogin, destination: LoginScreen())
        }
        .frame(width: screenWidth, height: screenHeight)
        .onAppear {
            observe()
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
                    if alertType.primaryBtnText == "Proceed to Login" {
                        navigateToLogin = true
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }

    // MARK: - ViewModel Observer
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
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: error?.localizedDescription ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: "Ok",
                    sheetThemeColor: .pinkBtn
                )
                showError = true
                print(error as Any)
            }
        }
    }

    func handleSuccess() {
        let response = viewModel.resetPasswordResponceDict
        if response.status == "success" {
            withAnimation(.snappy) {
                alertType = .sheetType(
                    icon: .success,
                    title: response.status.capitalized,
                    message: response.message.capitalized,
                    primaryBtnText: "Proceed to Login",
                    secondaryBtnText: "",
                    sheetThemeColor: .green
                )
                showError = true
            }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.status.capitalized,
                message: response.message.capitalized,
                primaryBtnText: "",
                secondaryBtnText: "Ok",
                sheetThemeColor: .pinkBtn
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
