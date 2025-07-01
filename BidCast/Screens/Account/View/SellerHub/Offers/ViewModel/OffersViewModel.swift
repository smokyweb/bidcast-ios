//
//  OffersViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class OffersViewModel: ObservableObject {
    
    @Published var offerListResponse = ResponseModelOffer<[OfferListModel]>()
    @Published var offerUpdateResponse = ResponseModel<OfferUpdateStatus>()
    @Published var itemListResponse = ResponseModelOffer<[OfferListModel]>()
    @Published var errorMessage: String? = nil

    // MARK: - Get Preference
    func getOfferList() async {
        do {
            let response: ResponseModelOffer<[OfferListModel]> = try await APIManager.shared.request(
                type: APIEndPoint.makeOfferList,
                header: true
            )
            self.offerListResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - Get Preference
    func getBidList() async {
        do {
            let response: ResponseModelOffer<[OfferListModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getBidList,
                header: true
            )
            self.offerListResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - getItemList
    func getItemList(parameters: ItemListRequest) async {
        do {
            let response: ResponseModelOffer<[OfferListModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getItemList(param: parameters),
                header: true
            )
            self.itemListResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    
    
    // MARK: - updateOfferList Preference
    func updateOfferStatus(parameters: OfferUpdateStatusRequest) async {
        do {
            let response: ResponseModel<OfferUpdateStatus> = try await APIManager.shared.request(
                type: APIEndPoint.offerUpdateStatus(param: parameters),
                header: true
            )
            self.offerUpdateResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
