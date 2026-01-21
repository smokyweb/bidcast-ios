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
    @Published var followDict = ResponseModel<FolloweModel>()
    @Published var getMyScheduleShowResponseDict: ResponseModalPaginate<[GetMyScheduleShowModel]>?
    @Published var getTotalRatingResponseDict: ResponseModal<TotalRating>?
    @Published var addRatingResponseDict: ResponseModal<AddRatigModel>?
    @Published var blockUserResponseDict: ResponseModal<BlockUserModel>?
    @Published var errorMessage: String? = nil
    @Published var requestType = ""
    @Published var getClipsResponseDict: ResponseModalPaginate<[GetClipModel]>?

    // MARK: - Store Address
    func storeAddress(parameters: AddressRequest) async {
        errorMessage?.removeAll()
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
    
    // MARK: - Block User
    func blockUser(param: BlockUserRequest) async {
        errorMessage?.removeAll()
        do {
            self.requestType = "blockUser"
            let response: ResponseModal<BlockUserModel> = try await APIManager.shared.request(
                type: APIEndPoint.blockUser(param: param),
                header: true
            )
            self.blockUserResponseDict = response
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - Get Profile
    func getProfile(param: ProfileParamRequest) async {
        errorMessage?.removeAll()
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
//    
//    // MARK: - Product Details
//    func productDetails(parameters: UserProductRequest) async {
//        do {
//           if let response: ResponseModalPaginate<[ProductListingDataModel]> = try await APIManager.shared.request(
//                type: APIEndPoint.getUserProduct(param: parameters),
//                header: true
//           ){
//               self.productDetailsResponseDict = response
//           }
//        } catch {
//            handle(error: error)
//        }
//    }
    
    // MARK: - Follow / Unfollow
    func followUnfollow(parameters: FollowRequest) async {
        errorMessage?.removeAll()
        self.requestType = "follow"
        do {
            
            if let response : ResponseModel<FolloweModel> = try await APIManager.shared.request(
                type: APIEndPoint.followUnfollow(param: parameters),
                header: true
            ) {
                self.followDict = response
            }
            
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - GetMyScheduleShowRequest
    func getMyScheduleShow(parameters: GetMyScheduleShowRequest) async {
        self.errorMessage?.removeAll()
        self.requestType = "scheduleShow"
        do {
            
            if let response : ResponseModalPaginate<[GetMyScheduleShowModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getMyScheduleShow(param: parameters),
                header: true
            ) {
                self.getMyScheduleShowResponseDict = response
            }
            
        } catch {
            handle(error: error)
        }
    }
    
    func getClips(parameters: clipRequest) async {
        self.errorMessage?.removeAll()
        self.requestType = "getClips"
        do {
            
            if let response : ResponseModalPaginate<[GetClipModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getclip(param: parameters),
                header: true
            ) {
                self.getClipsResponseDict = response
            }
            
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - getTotalRating
    func getTotalRating(parameters: GetTotalRatingRequest) async {
        self.errorMessage?.removeAll()
        self.requestType = "totalRating"
        do {
            
            if let response : ResponseModal<TotalRating> = try await APIManager.shared.request(
                type: APIEndPoint.getTotalRating(param: parameters),
                header: true
            ) {
                self.getTotalRatingResponseDict = response
            }
            
        } catch {
            handle(error: error)
        }
    }
    
    // MARK: - addRating
    func addRating(parameters: AddRatingRequest) async {
        self.errorMessage?.removeAll()
        self.requestType = "addRating"
        do {
            
            if let response : ResponseModal<AddRatigModel> = try await APIManager.shared.request(
                type: APIEndPoint.addRating(param: parameters),
                header: true
            ) {
                self.addRatingResponseDict = response
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
                    print(errorMessage)
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
