//
//  ShippingsViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation
import SwiftUI

@MainActor
final class ShippingViewModel: ObservableObject {
    
    enum RequestType {
        case storeShipping
        case editShipping
        case deleteShippingProfile
        case getShippingProfiles
        case none
    }
    
    @Published var storeShippingResponse: ResponseModal<StoreShippingModel>?
    @Published var deleteShippingResponse: ResponseModal<DeleteShippingModel>?
    @Published var getShippingProfilesResponse: ResponseModal<[StoreShippingModel]>?
    @Published var requestType: RequestType = .none
    @Published var errorMessage: String? = nil
    
    // MARK: - storeShippingProfile
    func storeShippingProfile(request: StoreShippingRequest) async throws{
        requestType = .storeShipping
        do {
            let response: ResponseModal<StoreShippingModel> = try await APIManager.shared.request(
                type: APIEndPoint.storeShipping(param: request),
                header: true)
            self.storeShippingResponse = response
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
    
    // MARK: - storeShippingProfile
    func deleteShippingProfile(request: DeleteShippingProfileRequest) async throws{
        requestType = .deleteShippingProfile
        do {
            let response: ResponseModal<DeleteShippingModel> = try await APIManager.shared.request(
                type: APIEndPoint.deleteShippingProfile(param: request),
                header: true)
            self.deleteShippingResponse = response
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
    
    // MARK: - getShippingProfiles
    func getShippingProfiles() async throws{
        requestType = .getShippingProfiles
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
}
