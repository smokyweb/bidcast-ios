//
//  ResetPasswordViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import Foundation


@MainActor
final class ResetPasswordViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var resetPasswordResponse = LoginResponce()
    @Published var errorMessage: String? = nil

    // MARK: - Reset Password Method
    func resetPassword(parameters: ResetPasswordRequest) async {
        do {
            let response: LoginResponce = try await APIManager.shared.request(
                type: APIEndPoint.resetPassword(param: parameters),
                header: false
            )
            self.resetPasswordResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
