//
//  BuyNowViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class BuyNowViewModel: ObservableObject {
    
    @Published var buyNowResponse = ResponseModel<MyOrderModel>()
    @Published var productOrderResponse = ResponseModel<ProductOrderModel>()
    @Published var purchaseDetailResponse = ResponseModel<ProductPurchaseModel>()
    @Published var recieptResponse = ResponseModel<String>()
    @Published var userList = ResponseModel<[UserModel]>()
   
    @Published var errorMessage: String? = nil

    // MARK: - getMyOrderList.
    func getMyOrderList(parameters: ProductOrderDetailRequest) async {
        do {
            let response: ResponseModel<MyOrderModel> = try await APIManager.shared.request(
                type: APIEndPoint.productOrderDetails(param: parameters),
                header: true
            )
            self.buyNowResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - BuyProductRequest.
    func BuyProductRequest(parameters: ProductOrderRequest) async {
        do {
            let response: ResponseModel<ProductOrderModel> = try await APIManager.shared.request(
                type: APIEndPoint.productOrder(param: parameters),
                header: true
            )
            self.productOrderResponse = response
            // Basecamp #9904579913 + #9922137437 (Trey 2026-05-21): broadcast
            // an order-placed event on successful Buy Now so product detail +
            // inventory screens can refetch and reflect the post-purchase
            // quantity immediately (backend decrements correctly, but the
            // client-side caches were stale until app restart).
            if response.status == "success" {
                NotificationCenter.default.post(
                    name: .bidcastOrderPlaced,
                    object: nil,
                    userInfo: ["productId": parameters.product_id]
                )
            }
        } catch {
            self.handle(error: error)
        }
    }
    
    
    func getPurchaseDetail(parameters: ProductPurchaseDetailRequest) async {
        do {
            let response: ResponseModel<ProductPurchaseModel> = try await APIManager.shared.request(
                type: APIEndPoint.productPurchaseDetail(param: parameters),
                header: true
            )
            self.purchaseDetailResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    func getUserSearch(parameters: SearchingRequest) async {
        do {
            let response: ResponseModel<[UserModel]> = try await APIManager.shared.request(
                type: APIEndPoint.searching(param: parameters),
                header: true
            )
            self.userList = response
        } catch {
            self.handle(error: error)
        }
    }
    

    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
