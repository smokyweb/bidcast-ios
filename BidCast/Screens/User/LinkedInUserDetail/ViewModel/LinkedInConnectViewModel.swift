//
//  LinkedInConnectViewModel.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 06/04/24.
//

import Foundation

final class LinkedInConnectViewModel {
    var response: ResponseModal<[String?]>?
    
        //MARK: - Handler
    var eventHandler: ((_ event: Event) -> Void)?
    
    func storeLinkedInDetail(param: LinkedInUserDetail){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[String?]>.self,
            type: APIEndPoint.storeLinkedIn(param: param),
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
}
