//
//  SelectCategoryViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation
import StoreKit


@MainActor
final class SelectCategoryViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var categoryResponse = ResponseModel<[CategoryDataModel]>()
    @Published var auctionResponse = ResponseModel<[AuctionDataModel]>()
    @Published var errorMessage: String? = nil
    @Published var request: String = ""

    // MARK: - Fetch Categories
    func getCategoryList() async {
        do {
            let response: ResponseModel<[CategoryDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.category,
                header: true
            )
            self.categoryResponse = response
            self.request = "Category"
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Fetch Auctions
    func getAuctionList() async {
        do {
            let response: ResponseModel<[AuctionDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.auctionType,
                header: true
            )
            self.auctionResponse = response
            self.request = "Auction"
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
