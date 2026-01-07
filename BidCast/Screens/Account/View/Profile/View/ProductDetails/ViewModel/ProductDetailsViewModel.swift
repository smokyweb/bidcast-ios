//
//  ProductDetailsViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation
enum RequestKind: String {
    case none
    case productDetails
    case sellerInfo
    case makeOffer
    case storeBid
    case followUnfollow
    case getSellerInfo
    case storeScheduleShow
    // add more as needed
}

@MainActor
final class ProductDetailsViewModel: ObservableObject {
    
    @Published var productDetailsResponseDict: ResponseModal<ProductDetailsModel>?
    @Published var offerResponse: ResponseModal<Offer>?
    @Published var sellerInfo: ResponseModel<SellerInfoResponse>?
    @Published var errorMessage: String? = nil
//    private var inflightTasks: [RequestKind: Task<Void, Never>] = [:]
//    @Published var requestKind: RequestKind = .none
//
//    // MARK: - Generic request helper
//    /// Centralized wrapper around APIManager.request to reduce duplication.
//    private func performRequest<T: Decodable>(
//        endpoint: APIEndPoint,
//        assignTo published: @escaping (ResponseModel<T>?) -> Void,
//        for kind: RequestKind
//    ) async {
//        // Cancel previous same-kind task if present
//        inflightTasks[kind]?.cancel()
//
//        // Create a Task to allow cancellation
//        let task = Task { @MainActor in
//            self.requestKind = kind
//            self.errorMessage = nil
//        }
//
//        inflightTasks[kind] = task
//
//        await task.value // ensure initial state set (non-blocking)
//
//        // Actual network call off the main actor (APIManager presumably is async)
//        do {
//            let response: ResponseModel<T> = try await APIManager.shared.request(
//                type: endpoint,
//                header: true
//            )
//
//            // Update UI on main actor
//            await MainActor.run {
//                published(response)
//                self.errorMessage = nil
//                self.requestKind = .none
//            }
//        } catch {
//            await MainActor.run {
//                if let dataError = error as? DataError {
//                    self.errorMessage = dataError.getErrorMessage()
//                } else {
//                    self.errorMessage = error.localizedDescription
//                }
//                // reset requestKind so UI knows call finished
//                self.requestKind = .none
//            }
//        }
//
//        // remove inflight
//        inflightTasks[kind] = nil
//    }
    
    // MARK: - Get Product Details
    func getProductDetails(parameters: FetchProductRequest) async {
        do {
            let response: ResponseModal<ProductDetailsModel> = try await APIManager.shared.request(
                type: APIEndPoint.fetchProduct(param: parameters),
                header: true
            )
            self.productDetailsResponseDict = response
        } catch {
            handle(error: error)
        }
    }
    /// Get seller info safely. Uses SellerInfoRequest (which has `seller_id`).
    func getSellerInfo(sellerID: String) async {
        let req = SellerInfoRequest(seller_id: sellerID)
        do {
                let response: ResponseModel<SellerInfoResponse> = try await APIManager.shared.request(
                    type: APIEndPoint.getSellerInfo(param: req),
                    header: true
                )
                self.sellerInfo = response
        
        } catch {
            handle(error: error)
        }
    }
    
    func MakeOffer(param:MakeOfferRequest) async {
        do {
            if let response: ResponseModal<Offer> = try await APIManager.shared.request(
                type: APIEndPoint.makeOffer(param: param),
                header: true
            ){
                self.offerResponse = response
            }
        } catch {
            handle(error: error)
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
