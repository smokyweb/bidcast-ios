//
//  VerifyOtpViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import Foundation

final class VerifyOtpViewModel {
    
    var verifyResponceDict = LoginResponce()
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    func resendOTPCode(parameters: ForgetRequest) {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: LoginResponce.self,
            type: APIEndPoint.forgotPassword(param: parameters),
            header: false) {
                result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.verifyResponceDict = data
                    //                        self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

    func verifyCode(parameters: VerifyOtpRequest) {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: LoginResponce.self, // response type
            type: APIEndPoint.verifyOTP(param: parameters),
            header: false) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.verifyResponceDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

}
