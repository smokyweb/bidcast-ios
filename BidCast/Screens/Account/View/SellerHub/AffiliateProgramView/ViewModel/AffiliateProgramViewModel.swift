//
//  AffiliateProgramViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class AffiliateProgramViewModel: ObservableObject {
    
    @Published var referralResponse = ResponseModel<ReferalModel>()
    @Published var errorMessage: String? = nil

    // MARK: - Get Preference
    func getReferralCode() async {
        do {
            let response: ResponseModel<ReferalModel> = try await APIManager.shared.request(
                type: APIEndPoint.getReferralCode,
                header: true
            )
            self.referralResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
