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
    @Published var myOrderResponse = ResponseModel<MyOrderModel>()
    @Published var recieptResponse = ResponseModel<String>()
    // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): cherry-picked from
    // Wave 4 `989c7ffd2`. Holds the response from POST /api/tax-exemption/apply.
    @Published var taxExemptionResponse = ResponseModel<TaxExemptionApplicationData>()
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
    
    // MARK: - getMyOrderList.
    func getMyOrderList(parameters: ProductOrderDetailRequest) async {
        do {
            let response: ResponseModel<MyOrderModel> = try await APIManager.shared.request(
                type: APIEndPoint.productOrderDetails(param: parameters),
                header: true
            )
            self.myOrderResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - getReceipt.
    func getReceipt(parameters: getOrderReceiptRequest) async {
        self.errorMessage = nil // Clear previous error
        do {
            let response: ResponseModel<String> = try await APIManager.shared.request(
                type: APIEndPoint.orderReceipt(param: parameters),
                header: true
            )
            self.recieptResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - taxExemptionApply (MC Wave 4 #41 cmpbefoaj00033ghgs38av42u)
    // Cherry-picked back from `989c7ffd2` on 2026-05-24 via MC
    // cmpaj2fex0000w5hgq64jp9k4 — Larry caught SalesTaxScreen still showing
    // the placeholder UI (Tax_Exemption_2025.pdf + fake Active status).
    func taxExemptionApply(parameters: TaxExemptionApplyRequest) async {
        self.errorMessage = nil
        do {
            let response: ResponseModel<TaxExemptionApplicationData> = try await APIManager.shared.request(
                type: APIEndPoint.taxExemptionApply(param: parameters),
                header: true
            )
            self.taxExemptionResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Error Handling
    private func handle(error: Error) {
        if let dataError = error as? DataError {
            switch dataError {
            case .invalidCode(let message):
                self.errorMessage = message ?? "Invalid code error"
            case .invalidResponse(let data):
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    self.errorMessage = "Invalid response: \(json)"
                } else {
                    self.errorMessage = "Invalid response with no data"
                }
            default:
                self.errorMessage = error.localizedDescription
            }
        } else {
            self.errorMessage = error.localizedDescription
        }
    }
}



