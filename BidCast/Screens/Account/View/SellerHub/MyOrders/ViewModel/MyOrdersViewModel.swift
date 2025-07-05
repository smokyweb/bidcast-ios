//
//  MyOrdersViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class MyOrdersViewModel: ObservableObject {
    
    @Published var myOrderResponse = ResponseModelOrder<[MyOrderModel]>()
    @Published var errorMessage: String? = nil

    // MARK: - getMyOrderList.
    func getMyOrderList(parameters: ProductOrderListingRequest) async {
        do {
            let response: ResponseModelOrder<[MyOrderModel]> = try await APIManager.shared.request(
                type: APIEndPoint.productOrderListing(param: parameters),
                header: true
            )
            self.myOrderResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}



