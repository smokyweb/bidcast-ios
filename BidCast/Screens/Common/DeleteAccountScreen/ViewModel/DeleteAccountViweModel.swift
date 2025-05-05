//
//  DeleteAccountViweModel.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 01/03/24.
//

import Foundation

class DeleteAccountViweModel {
    
    var deleteResponceDict : ResponseModal<[String]>?
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func postDeleteRequest(param:DeleteParam){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[String]>.self, // response type
            type: APIEndPoint.deleteAccount(param:param),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.deleteResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}


struct DeleteParam: Codable{
    var reason : String?
}
