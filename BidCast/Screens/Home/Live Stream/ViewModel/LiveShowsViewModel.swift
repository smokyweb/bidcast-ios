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
    @Published var errorMessage: String?
    @Published var requestType: String = ""
    
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
    func getLiveShows() async {
        requestType = "get"
        do {
            let response: ResponseModel<[LiveShowsModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLiveShows,
                header: true
            )
            self.liveShowsResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Set Default Address
    func setDefaultAddress(parameters: AddressDefaultParam) async {
        requestType = "default"
        do {
            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.setDefaultAddress(param: parameters),
                header: true
            )
            self.addressResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete Address
    func deleteAddress(parameters: AddressDefaultParam) async {
        requestType = "delete"
        do {
            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.deleteAddress(param: parameters),
                header: true
            )
           
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
