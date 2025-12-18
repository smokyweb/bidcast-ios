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
    @Published var purchasedOrderListResponse = ResponseModelOffer<[PurchasedOrderModel]>()
    @Published var purchaseOrderDetailsResponse: ResponseModel<OrderDetailsModel>?
    @Published var errorMessage: String? = nil

    // MARK: - Get Preference
    func getOfferList(param : PageRequest) async {
        do {
            let response: ResponseModelOffer<[OfferListModel]> = try await APIManager.shared.request(
                type: APIEndPoint.makeOfferList(param: param),
                header: true
            )
            self.offerListResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - Get Preference
    func getBidList(param : PageRequest) async {
        do {
            let response: ResponseModelOffer<[OfferListModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getBidList(param: param),
                header: true
            )
            self.offerListResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
//    // MARK: - getItemList
    func getMyPurchasedOrderList(parameters: PurchaseOrderRequuest) async {
        do {
            let response: ResponseModelOffer<[PurchasedOrderModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getMyPurchasedOrder(param: parameters),
                header: true
            )
            self.purchasedOrderListResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    
    // MARK: - getOrderDetails
    func getPurchasedOrderDetails(request: PurchaseOrderDetailsRequest) async throws{
        do {
           if  let response: ResponseModel<OrderDetailsModel> = try await APIManager.shared.request(
            type: APIEndPoint.getPurchasedOrderDetails(param: request),
                header: true
           ){
               purchaseOrderDetailsResponse = response
           }
        } catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
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
