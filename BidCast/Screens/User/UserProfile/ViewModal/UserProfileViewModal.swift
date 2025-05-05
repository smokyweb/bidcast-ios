//
//  UserProfileViewModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 29/01/24.
//

import Foundation

final class UserProfileViewModal {
    
    var response = UserResponseModal()
    var linkedInResponse: ResponseModal<[String?]>?
    var linkedInUserResponse: ResponseModal<LinkedInUserDetail>?
    
    var eventHandler: ((_ event: Event) -> Void)?
    var requestType: String = ""
    
    func getProfile() {
        self.eventHandler?(.loading)
        self.requestType = "GetProfile"
        APIManager.shared
            .requestPost(
                modelType: UserResponseModal.self,
                type: APIEndPoint.getProfile,
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.response = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
        //MARK: Link Account with LinkedIn
    func linkLinkedIn(param: LinkedInLinkModel) {
        self.eventHandler?(.loading)
        self.requestType = "LinkLinkedIn"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<[String?]>.self,
                type: APIEndPoint.linkLinkedIn(param: param),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.linkedInResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
    
    func linkedInAccConnect(param: LinkedInURL) {
        self.eventHandler?(.loading)
        self.requestType = "ConnectLinkedIn"
        APIManager.shared
            .requestPost(
                modelType: ResponseModal<LinkedInUserDetail>.self,
                type: APIEndPoint.linkedInConnect(param: param),
                header: true) { result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                            self.linkedInUserResponse = data
                            self.eventHandler?(.dataLoaded)
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                }
    }
}
