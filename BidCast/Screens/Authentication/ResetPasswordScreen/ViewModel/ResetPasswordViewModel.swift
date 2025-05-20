//
//  ResetPasswordViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import Foundation


final class ResetPasswordViewModel {
    
    var resetPasswordResponceDict = LoginResponce()
    
    var eventHandler: ((_ event: Event) -> Void)?

    func resetPassword(parameters: ResetPasswordRequest) {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: LoginResponce.self,
            type: APIEndPoint.resetPassword(param: parameters),
            header: false) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.resetPasswordResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

}
