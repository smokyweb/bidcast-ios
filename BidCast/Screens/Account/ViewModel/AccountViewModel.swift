//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//

import Foundation


@MainActor
final class AccountViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var accountInfo = ResponseModel<ProfileModel>()
    @Published var liveShowsResponse = ResponseModel<[LiveShowsModel]>()
    @Published var errorMessage: String?
    @Published var requestType: String = ""
    
    // MARK: - Get Live Shows
    func getProfile() async {
        requestType = "get"
        do {
            let response: ResponseModel<ProfileModel> = try await APIManager.shared.request(
                type: APIEndPoint.getprofile,
                header: true
            )
            self.accountInfo = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func UpdateProfile(param: UpdateProfileRequest, images: [String], key: String) async {
        self.requestType = "store"
        
        do {
            let parameters = try param.asDictionary()

            let response: ResponseModel<ProfileModel> = try await APIManager.shared.uploadImage(
                type: APIEndPoint.updateProfile(param: param),
                urlArray: images,
                mimeType: "image/jpeg",
                keyName: key,
                parameters: parameters,
                modalType: ResponseModel<ProfileModel>.self,
                header: true
            )
            
            self.accountInfo = response
            
        } catch {
            self.errorMessage = "Error: \(error.localizedDescription)"
          
        }
    }
}
