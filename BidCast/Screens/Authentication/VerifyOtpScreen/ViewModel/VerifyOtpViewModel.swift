//
//  VerifyOtpViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import Foundation


@MainActor
final class VerifyOtpViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var verifyResponse = LoginResponce()
    @Published var errorMessage: String? = nil

    // MARK: - Resend OTP Code
    func resendOTPCode(parameters: ForgetRequest) async {
        do {
            let response: LoginResponce = try await APIManager.shared.request(
                type: APIEndPoint.forgotPassword(param: parameters),
                header: false
            )
            self.verifyResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Verify OTP Code
    func verifyCode(parameters: VerifyOtpRequest) async {
        do {
            let response: LoginResponce = try await APIManager.shared.request(
                type: APIEndPoint.verifyOTP(param: parameters),
                header: false
            )
            self.verifyResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        if let dataError = error as? DataError {
            switch dataError {
            case .invalidCode(let message):
                self.errorMessage = message ?? "Invalid code error"
            case .invalidResponse(let data):
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    self.errorMessage = "Invalid response: \(json)"
                } else {
                    self.errorMessage = "Invalid response with no data"
                }
            default:
                self.errorMessage = error.localizedDescription
            }
        } else {
            self.errorMessage = error.localizedDescription
        }
    }
}
