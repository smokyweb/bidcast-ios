//
//  OtpViewModel.swift
//  BidCast
//
//  Created by Vivek-JAM-E-328 on 05/09/24.
//

import Foundation


final class OtpViewModel {
    
    //MARK: - variables
    enum RequestType {
        case verifyOtp
        case none
    }
    
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none
    
    var OTPDict : ResponseModel<VerifyOTPModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    @MainActor
    func verifyOTP(parameters: VerifyOtpRequest)  {
        Task {
            do {
                let userResponseArray: ResponseModel<VerifyOTPModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.verifyOTP(param: parameters),
                    header: false)
                self.requestType = .verifyOtp
                self.OTPDict = userResponseArray
            }
            catch(let error) {
                if let dataError = error as? DataError {
                    let errorMessage = dataError.getErrorMessage()
                    self.userDelegate?.showError(error: errorMessage)
                }
                else {
                    self.userDelegate?.showError(error: error.localizedDescription)
                }
            }
        }
    }
}
