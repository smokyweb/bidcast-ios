//
//  FortotViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import Foundation

@MainActor
final class ForgotViewModel: ObservableObject {
    
    @Published var forgotResponseDict = LoginResponce()
    @Published var errorMessage: String?
    
    func forgotEmail(parameters: ForgetRequest) async {
        do {
            let response: LoginResponce = try await APIManager.shared.request(
                type: APIEndPoint.forgotPassword(param: parameters),
                header: false
            )
            self.forgotResponseDict = response
        } catch {
            self.handle(error: error)
        }
    }
    
    
    // MARK: - Centralized Error Handler
     func handle(error: Error) {
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
