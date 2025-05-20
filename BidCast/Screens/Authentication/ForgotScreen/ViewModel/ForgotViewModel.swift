//
//  FortotViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import Foundation

final class ForgotViewModel {
    
    var forgotResponceDict = LoginResponce()
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    func forgotEmail(parameters: ForgetRequest) {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: LoginResponce.self,
            type: APIEndPoint.forgotPassword(param: parameters),
            header: false) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.forgotResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
}

