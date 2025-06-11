//
//  OrderStatusViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class OrderStatusViewModel: ObservableObject {
    
    @Published var purchaseDetailResponse = ResponseModel<ProductPurchaseModel>()
    @Published var recieptResponse = ResponseModel<String>()
    @Published var errorMessage: String? = nil

    // MARK: - getPurchaseDetail.
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
    
    // MARK: - getReceipt.
    func getReceipt(parameters: OrderRecieptRequest) async {
        do {
            let response: ResponseModel<String> = try await APIManager.shared.request(
                type: APIEndPoint.orderReciept(param: parameters),
                header: true
            )
            self.recieptResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}



