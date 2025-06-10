//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var getProfileDict = ResponseModel<ProfileModel>()
    @Published var productDetailsResponseDict: ResponseModalPaginate<[ProductListingDataModel]>?
    @Published var followDict = ResponseModel<[String]>()
    @Published var errorMessage: String? = nil
    @Published var requestType = ""
    
    // MARK: - Store Address
    func storeAddress(parameters: AddressRequest) async {
        do {
            self.requestType = "store"
            _ = try await APIManager.shared.request(
                type: APIEndPoint.storeAddress(param: parameters),
                header: true
            ) as ResponseModel<AddressModel>
            // No property update here, you can add if needed
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Get Profile
    func getProfile(param: ProfileParamRequest) async {
        do {
            self.requestType = "get"
            let response: ResponseModel<ProfileModel> = try await APIManager.shared.request(
                type: APIEndPoint.getProfileById(param: param),
                header: true
            )
            self.getProfileDict = response
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Product Details
    func productDetails(parameters: UserProductRequest) async {
        do {
            self.requestType = "product"
            let response: ResponseModalPaginate<[ProductListingDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getUserProduct(param: parameters),
                header: true
            )
            self.productDetailsResponseDict = response
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Follow / Unfollow
    func followUnfollow(parameters: FollowRequest) async {
        do {
            self.requestType = "follow"
            _ = try await APIManager.shared.request(
                type: APIEndPoint.followUnfollow(param: parameters),
                header: true
            ) as ResponseModel<[String]>
            
            // Refresh profile after follow/unfollow
            await getProfile(param: ProfileParamRequest(id: parameters.following_id))
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
