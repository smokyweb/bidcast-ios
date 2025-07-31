//
//  ProductDetailsViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation


@MainActor
final class ProductDetailsViewModel: ObservableObject {
    
    @Published var productDetailsResponseDict: ResponseModal<ProductDetailsModel>?
    @Published var offerResponse: ResponseModal<Offer>?
    @Published var errorMessage: String? = nil
    
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
