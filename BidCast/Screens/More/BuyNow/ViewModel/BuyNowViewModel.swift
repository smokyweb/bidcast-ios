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
