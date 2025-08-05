//
//  BuyNowViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class BuyNowViewModel: ObservableObject {
    
    @Published var buyNowResponse = ResponseModel<BuyNowModel>()
    @Published var productOrderResponse = ResponseModel<ProductOrderModel>()
    @Published var errorMessage: String? = nil

    // MARK: - getMyOrderList.
    func getMyOrderList(parameters: ProductOrderDetailRequest) async {
        do {
            let response: ResponseModel<BuyNowModel> = try await APIManager.shared.request(
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
        } catch {
            self.handle(error: error)
        }
    }
    

    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}



