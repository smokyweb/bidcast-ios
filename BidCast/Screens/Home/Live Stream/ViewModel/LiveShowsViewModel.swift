//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//

import Foundation


@MainActor
final class LiveShowsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var addressResponse = ResponseModel<AddressModel>()
    @Published var liveShowsResponse = ResponseModel<[LiveShowsModel]>()
    @Published var countResponse = countModel()
    @Published var errorMessage: String?
    @Published var BidResponse = ResponseModel<BidModel>()
    @Published var followDict = ResponseModel<FolloweModel>()
    @Published var requestType: String = ""
    @Published var titleStream : String = "Stream Ended"
    @Published var messageStream : String = "The live stream has ended."
    
    // MARK: - Store Address
    func storeAddress(parameters: AddressRequest) async {
        requestType = "store"
        do {
            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.storeAddress(param: parameters),
                header: true
            )
            self.addressResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Get Live Shows
    func getLiveShows(param:GetLiveShowsRequest) async {
        requestType = "get"
        do {
            let response: ResponseModel<[LiveShowsModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLiveShows(param:param),
                header: true
            )
            self.liveShowsResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Set Default Address
//    func setDefaultAddress(parameters: AddressDefaultParam) async {
//        requestType = "default"
//        do {
//            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
//                type: APIEndPoint.setDefaultAddress(param: parameters),
//                header: true
//            )
//            self.addressResponse = response
//        } catch {
//            self.errorMessage = error.localizedDescription
//        }
//    }
//
//    // MARK: - Delete Address
//    func deleteAddress(parameters: AddressDefaultParam) async {
//        requestType = "delete"
//        do {
//            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
//                type: APIEndPoint.deleteAddress(param: parameters),
//                header: true
//            )
//           
//        } catch {
//            self.errorMessage = error.localizedDescription
//        }
//    }
    
    func CountUppdate(parameters: countRequest) async {
        requestType = "count"
        do {
           if let response: countModel = try await APIManager.shared.request(
                type: APIEndPoint.countUpdate(param: parameters),
                header: true
           ){
               self.countResponse = response
           }
           
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func storeBid(parameters: StoreBidRequest) async {
        requestType = "store"
        do {
            let response: ResponseModel<BidModel> = try await APIManager.shared.request(
                type: APIEndPoint.storeBid(param: parameters),
                header: true
            )
            self.BidResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func followUnfollow(parameters: FollowRequest) async {
        do {
            self.requestType = "follow"
            if let response : ResponseModel<FolloweModel> = try await APIManager.shared.request(
                type: APIEndPoint.followUnfollow(param: parameters),
                header: true
           ) {
                followDict = response
           }
            
            // Refresh profile after follow/unfollow
//            await getProfile(param: ProfileParamRequest(id: parameters.following_id))
        } catch {
            handle(error: error)
        }
    }
    
    
    func handle(error: Error) {
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
