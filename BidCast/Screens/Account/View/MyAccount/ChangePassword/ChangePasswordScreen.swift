//
//  ChangePasswordScreen.swift
//  BidCast
//
//  Account Security — Change Password screen.
//  Basecamp FIX-2 (2026-05-30): Screen was absent; endpoint already existed at
//  ProjectEndPoint.swift (case changePassword → POST /change-password).
//
//  Wired from AccountScreen via AccountMenuSection.accountSecurity row.
//

import SwiftUI
import BottomSheet
import AlertToast
import SVProgressHUD

struct ChangePasswordScreen: View {

    // MARK: - Environment
    @Environment(\.presentationMode) var presentationMode

    // MARK: - State — field values
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    // MARK: - State — UI feedback
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var showError: Bool = false
    @State private var alertType: BottomSheetType = .sheetType(
        icon: .alert, title: "", message: "",
        primaryBtnText: "", secondaryBtnText: ""
    )

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Nav bar
            PrimaryHeader(
                title: "Account Security",
                leadingImgArr: ["chevron.left"],
                onClickLeading: { _ in
                    presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Color.clear.frame(height: 8)

                    TitleWithLine(title: "Change Password", lineLength: 60)

                    // Current password
                    AuthTextField(
                        floatingLabel: "Current Password",
                        placeholder: "Enter current password",
                        icon: .bag,
                        text: $currentPassword,
                        isPassword: true,
                        enteredText: { value in
                            currentPassword = value
                        }
                    )

                    // New password
                    AuthTextField(
                        floatingLabel: "New Password",
                        placeholder: "Enter new password",
                        icon: .bag,
                        text: $newPassword,
                        isPassword: true,
                        enteredText: { value in
                            newPassword = value
                        }
                    )

                    // Confirm new password
                    AuthTextField(
                        floatingLabel: "Confirm New Password",
                        placeholder: "Re-enter new password",
                        icon: .bag,
                        text: $confirmPassword,
                        isPassword: true,
                        enteredText: { value in
                            confirmPassword = value
                        }
                    )
                    .padding(.bottom, 8)

                    // Save button
                    PrimaryButton(
                        title: "Save",
                        isOutLine: false,
                        onButtonClick: {
                            UIApplication.shared.endEditing()
                            submitChangePassword()
                        },
                        btnTextColor: .white
                    )
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(Color.backGround)
        .navigationBarHidden(true)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(
                displayMode: .hud,
                type: .regular,
                title: hudMsg,
                style: alertStlye
            )
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: { }
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if alertType.primaryBtnText == "Done" {
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }

    // MARK: - Submit
    private func submitChangePassword() {
        // Basic validation
        guard !currentPassword.isEmpty else {
            hudMsg = "Please enter your current password"
            showhud = true
            return
        }
        guard !newPassword.isEmpty else {
            hudMsg = "Please enter a new password"
            showhud = true
            return
        }
        guard newPassword.count >= 8 else {
            hudMsg = AppString.passwordNotLessThan.localized
            showhud = true
            return
        }
        guard newPassword == confirmPassword else {
            hudMsg = AppString.passwordNotMatched.localized
            showhud = true
            return
        }
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }

        let request = UpdatePasswordRequest(
            current_password: currentPassword,
            password: newPassword,
            password_confirmation: confirmPassword
        )

        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            do {
                let response: ResponseModel<String> = try await APIManager.shared.request(
                    type: APIEndPoint.changePassword(param: request),
                    header: true
                )
                await SVProgressHUD.dismiss()
                if response.status == "success" {
                    alertType = .sheetType(
                        icon: .success,
                        title: "Success",
                        message: response.message ?? "Password updated successfully.",
                        primaryBtnText: "Done",
                        secondaryBtnText: "",
                        sheetThemeColor: .secondary
                    )
                    withAnimation(.snappy) { showError = true }
                } else {
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Failed",
                        message: response.message ?? "Could not update password. Please try again.",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized,
                        sheetThemeColor: .secondary
                    )
                    withAnimation(.snappy) { showError = true }
                }
            } catch {
                await SVProgressHUD.dismiss()
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: error.localizedDescription,
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized,
                    sheetThemeColor: .secondary
                )
                withAnimation(.snappy) { showError = true }
            }
        }
    }
}
