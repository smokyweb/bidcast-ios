//
//  InventoryViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class InventoryViewModel: ObservableObject {
    
    @Published var inventoryDict: ResponseModalPaginate<[InventoryDataModel]>?
    @Published var deleteProductResponse = ResponseModel<DeleteProductModel>()
    @Published var changeProductStatusResponse: ResponseModel<ChangeProductStatusModel>?
    @Published var errorMessage: String? = nil
    var request: String = ""
    
//    // MARK: - Get Inventory List
//    func getInventoryList(param: InventoryRequest) async throws {
//        self.request = "Inventory"
//        do {
//            let response: ResponseModalPaginate<[InventoryDataModel]> = try await APIManager.shared.request(
//                type: APIEndPoint.getInventory(param: param),
//                header: true
//            )
//            self.inventoryDict = response
//        } catch(let error) {
//            if let dataError = error as? DataError {
//                self.errorMessage = dataError.getErrorMessage()
//            }
//            else {
//                self.errorMessage = error.localizedDescription
//            }
//            throw error
//        }
//    }

    
    // MARK: - DeleteProductRequest.
    func deleteProductRequest(parameters: DeleteProduct) async {
        do {
            let response: ResponseModel<DeleteProductModel> = try await APIManager.shared.request(
                type: APIEndPoint.deleteProduct(param: parameters),
                header: true
            )
            self.deleteProductResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    // MARK: - Update Prooduct Status
    func updateProductStatus(param: UpdateProductStatusRequest) async throws {
        self.request = "Inventory"
        do {
            let response: ResponseModel<ChangeProductStatusModel> = try await APIManager.shared.request(
                type: APIEndPoint.updateProductStatus(param: param),
                header: true
            )
            self.changeProductStatusResponse = response
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
    
    // MARK: - Centralized Error Handler
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
