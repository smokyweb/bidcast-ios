//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var addressResponse = ResponseModel<AddressModel>()
    @Published var liveShowsResponse = ResponseModel<[HomeModel]>()
    @Published var errorMessage: String?
    @Published var requestType = ""

    // MARK: - Store Address
//    func storeAddress(parameters: AddressRequest) async {
//        self.requestType = "store"
//        do {
//            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
//                type: APIEndPoint.storeAddress(param: parameters),
//                header: true
//            )
//            self.addressResponse = response
//        } catch {
//            handle(error)
//        }
//    }

    // MARK: - Get Live Shows
    func getLiveShows(param:GetLiveShowsRequest) async {
        self.requestType = "get"
        do {
            let response: ResponseModel<[HomeModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLiveShows(param: param),
                header: true
            )
            self.liveShowsResponse = response
        } catch {
            handle(error)
        }
    }

//    // MARK: - Set Default Address
//    func setDefaultAddress(parameters: AddressDefaultParam) async {
//        self.requestType = "default"
//        do {
//            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
//                type: APIEndPoint.setDefaultAddress(param: parameters),
//                header: true
//            )
//            self.addressResponse = response
//        } catch {
//            handle(error)
//        }
//    }

//    // MARK: - Delete Address
//    func deleteAddress(parameters: AddressDefaultParam) async {
//        self.requestType = "delete"
//        do {
//            let response:  ResponseModel<AddressModel> = try await APIManager.shared.request(
//                type: APIEndPoint.deleteAddress(param: parameters),
//                header: true
//            )
//            // Optional: refetch addresses or update UI state
//        } catch {
//            handle(error)
//        }
//    }

    // MARK: - Handle Error
    private func handle(_ error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
