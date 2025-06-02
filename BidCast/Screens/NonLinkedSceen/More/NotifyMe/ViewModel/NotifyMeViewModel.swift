//
//  NotifyMeViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

final class NotifyMeViewModel : ObservableObject {
    
    var notifyLiveUserResponseDict : ResponseModal<[String]>?
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    func notifyLiveUser(parameter : NotifyLiveUserRequest){
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<[String]>.self,
            type: APIEndPoint.notifyLiveUser(param: parameter),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.notifyLiveUserResponseDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}



