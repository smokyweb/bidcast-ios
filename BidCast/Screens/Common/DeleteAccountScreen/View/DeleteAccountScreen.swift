//
//  DeleteAccountScreen.swift
//  BidCast
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct DeleteAccountScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager

    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var reason: String = ""
    @State private var showDeleteSheet: Bool = false
    @State private var isDeleting: Bool = false

    @StateObject private var viewModel = DeleteAccountViewModel()

    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "Delete Account",
                leadingImgArr: ["chevron.left"],
                onClickLeading: { _ in
                    presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    TitleWithLine(title: "Delete Account", lineLength: 42)

                    Text("Deleting your account is irreversible and will permanently erase all your data. This action cannot be undone. Please consider carefully before proceeding.")
                        .font(.custom(poppinsRegular, fixedSize: 13))
                        .foregroundColor(.darkGray)
                        .padding(.horizontal, Leading)

                    Text("Reason for deletion")
                        .font(.custom(poppinsSemiBold, fixedSize: 14))
                        .foregroundColor(.black)
                        .padding(.horizontal, Leading)

                    ZStack(alignment: .topLeading) {
                        if reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Type your message here")
                                .font(.custom(poppinsRegular, fixedSize: 13))
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.top, 14)
                                .padding(.leading, 14)
                        }

                        TextEditor(text: $reason)
                            .font(.custom(poppinsRegular, fixedSize: 14))
                            .foregroundColor(.black)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                    }
                    .frame(height: 160)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                    .padding(.horizontal, Leading)

                    PrimaryButton(title: "Submit", isOutLine: false, onButtonClick: {
                        UIApplication.shared.endEditing()
                        if reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            hudMsg = "Please provide a reason."
                            showhud = true
                            return
                        }
                        showDeleteSheet = true
                    }, btnTextColor: .white)
                    .padding(.top, 8)
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
            .background(Color.backGround)
        }
        .background(Color.backGround)
        .edgesIgnoringSafeArea(.bottom)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showDeleteSheet,
            height: screenHeight / 3,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: { showDeleteSheet = false },
            content: {
                DeleteAccountSheet(
                    onDeleteClick: {
                        Task {
                            await deleteAccount()
                        }
                    },
                    onCancelClick: {
                        showDeleteSheet = false
                    }
                )
            }
        )
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }

    private func deleteAccount() async {
        UIApplication.shared.endEditing()
        let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            hudMsg = "Please provide a reason."
            showhud = true
            return
        }

        isDeleting = true
        showDeleteSheet = false
        defer { isDeleting = false }
        SVProgressHUD.show()
        await viewModel.postDeleteRequest(param: DeleteParam(reason: trimmed))
        await SVProgressHUD.dismiss()
        if let resp = viewModel.deleteResponseDict, resp.status == "success" {
            performLocalLogoutAndRouteToLogin()
            return
        }

        hudMsg = viewModel.errorMessage ?? (viewModel.deleteResponseDict?.message ?? "Delete account failed.")
        showhud = true
    }

    private func performLocalLogoutAndRouteToLogin() {
        // Clear local auth/session, then go back to Authentication root.
        let rememberMe = UserDefaults.rememberMe
        if !rememberMe {
            _ = KeychainManager.shared.delete(email: UserDefaults.userEmail)
        }

        UserDefaultsManager.shared.setValue(false, forKey: .isLoggedIn)
        UserDefaults.accessToken = ""
        UserDefaults.fullName = ""
        UserDefaults.userName = ""
        UserDefaults.profileURL = ""
        UserDefaults.userId = -1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                appRootManager.currentRoot = .authentication
            }
        }
    }
}

#Preview {
    DeleteAccountScreen()
}
