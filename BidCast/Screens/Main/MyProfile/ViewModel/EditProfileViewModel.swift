//
//  EditProfileViewModel.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-174 on 19/09/24.
//

import Foundation

final class EditProfileViewModel {
    
    var editProfileDict: ResponseModel<EditProfileModel>?
    var deleteProfileDict: ResponseModel<String?>?
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
    var requestType = ""
    
//    func editProfileDetails(param: EditProfileDetailsRequest) {
//        self.eventHandler?(.loading)
//        APIManager.shared.request(
//            modelType: ResponseModel<EditProfileModel>.self, // response type
//            type: APIEndPoint.editProfileDetails(parameter: param),
//            header: true) { result in
//                self.eventHandler?(.stopLoading)
//                switch result {
//                case .success(let data):
//                    self.requestType = "EditProfileDetails"
//                    self.editProfileDict = data
//                    self.eventHandler?(.dataLoaded)
//                case .failure(let error):
//                    self.eventHandler?(.error(error))
//                }
//            }
//        
//    }
    //MARK: deleteProfileViewModel.
    func deleteProfile() {
        self.eventHandler?(.loading)
        APIManager.shared.request(
            modelType: ResponseModel<String?>?.self, // response type
            type: APIEndPoint.deleteProfile,
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.requestType = "deleteProfile"
                    self.deleteProfileDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    //MARK: editProfileDetailsViewModel.
    func editProfileDetails(parameters: [String:Any],image: String? = nil) {
        self.eventHandler?(.loading)
        DispatchQueue.global(qos: .userInteractive).async {
            APIManager.shared
                .uploadFile(type: APIEndPoint.editProfileDetails(param: parameters), urlArray: image, mimeType: "image/png", keyName: "profile_image", parameters: parameters, modalType:ResponseModel<EditProfileModel>.self, header: true,
                            
                            completion: {
                    result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let data):
                            self.requestType = "EditProfileDetails"
                            self.editProfileDict = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                        }
                    }
                })
        }
    }
    
}
