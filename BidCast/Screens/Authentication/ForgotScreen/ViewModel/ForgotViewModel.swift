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
            self.errorMessage = error.localizedDescription
        }
    }
}
