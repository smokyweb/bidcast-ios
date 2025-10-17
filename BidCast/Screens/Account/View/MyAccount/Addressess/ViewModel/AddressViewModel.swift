//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//

import Foundation


@MainActor
final class AddressViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var addressResponse = ResponseModel<AddressModel>()
    @Published var stateResponse = ResponseModel<[StateModel]>()
    @Published var addressesResponse = ResponseModel<[AddressModel]>()
    @Published var errorMessage: String? = nil
    
    // MARK: - Store Address
    func storeAddress(parameters: AddressRequest) async {
       
        do {
            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.storeAddress(param: parameters),
                header: true
            )
            errorMessage = nil
            addressResponse = response
        } catch {
            handle(error: error)
        }
      
    }
    
    // MARK: - Get Addresses
    func getAddresses() async {
       
        do {
            let response: ResponseModel<[AddressModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getAddress,
                header: true
            )
            errorMessage = nil
            addressesResponse = response
        } catch {
            handle(error: error)
        }
       
    }
    
    func getState() async {
       
        do {
            let response: ResponseModel<[StateModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getState,
                header: true
            )
            errorMessage = nil
            stateResponse = response
        } catch {
            handle(error: error)
        }
       
    }
    
    // MARK: - Set Default Address
    func setDefaultAddress(parameters: AddressDefaultParam) async {
       
        do {
            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.setDefaultAddress(param: parameters),
                header: true
            )
            errorMessage = nil
            addressResponse = response
        } catch {
            handle(error: error)
        }
       
    }
    
    // MARK: - Delete Address
    func deleteAddress(parameters: AddressDefaultParam) async {
       
        do {
            let response: ResponseModel<AddressModel> = try await APIManager.shared.request(
                type: APIEndPoint.deleteAddress(param: parameters),
                header: true
            )
            // Refresh list after deletion
            await getAddresses()
        } catch {
            handle(error: error)
        }
       
    }
    
    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        // Customize error handling as per your app's needs
        errorMessage = error.localizedDescription
    }
}
