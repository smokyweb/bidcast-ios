//
//  SurpriseViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/02/26.
//


import Foundation
import SwiftUI

@MainActor
final class SurpriseViewModel: ObservableObject {
    
    enum RequestType {
        case shipping
        case create
        case product
        case none
    }
   
    @Published var getShippingProfilesResponse: ResponseModal<[StoreShippingModel]>?
    @Published var surpriseResponse: ResponseModal<ProductSurpriseData>?
  
    @Published var requestType: RequestType = .none
    @Published var errorMessage: String? = nil
    
    
    // MARK: - getShippingProfiles
    func getShippingProfiles() async throws{
        requestType = .create
        do {
            let response: ResponseModal<[StoreShippingModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getShippinProfiles,
                header: true)
            self.getShippingProfilesResponse = response
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
   
    func storeSurpriseSet(param:SurpriseRequest) async throws {
        requestType = .shipping
        do {
            let response: ResponseModal<ProductSurpriseData> = try await APIManager.shared.request(
                type: APIEndPoint.createSurprise(param: param),
                header: true)
            self.surpriseResponse = response
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
    
}
