//
//  ForgetPasswordViewModel.swift
//  BidCast
//
//  Created by JAM-E-328 on 31/08/24.
//
import Foundation

final class ForgetPasswordViewModel {
    
    
    //MARK: - variables
    enum RequestType {
        case forgotPassword
        case none
    }
    //MARK: - variables
    weak var userDelegate: UserServices?
    
    var forgetPasswordDict : ResponseModel<ForgetPasswordModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var requestType: RequestType = .none
    
    @MainActor
    func forgetPassword(parameters: ForgetRequest)  {
        Task {
            do {
                let userResponseArray: ResponseModel<ForgetPasswordModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.forgotPassword(param: parameters),
                    header: false)
                self.requestType = .forgotPassword
                self.forgetPasswordDict = userResponseArray
            }catch(let error) {
                self.requestType = .forgotPassword
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
