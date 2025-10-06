//
//  PremierShopViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class PremierShopViewModel: ObservableObject {

    @Published var premierShopResponse = ResponseModel<PremierShopModel>()
    @Published var applyPremierShopResponse: ResponseModel<ApplyPremierShopModel>?
    @Published var errorMessage: String? = nil

    func getPremierShopContent() async {
        do {
            let response: ResponseModel<PremierShopModel> = try await APIManager.shared.request(
                type: APIEndPoint.premierShop,
                header: true
            )
            self.premierShopResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    func applyForPremierShop() async {
        do {
            let response: ResponseModel<ApplyPremierShopModel> = try await APIManager.shared.request(
                type: APIEndPoint.applyPremierShop,
                header: true
            )
            self.applyPremierShopResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
