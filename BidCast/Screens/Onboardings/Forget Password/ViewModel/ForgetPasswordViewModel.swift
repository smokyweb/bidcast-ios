//
//  ForgetPasswordViewModel.swift
//  Rise Shine Swing
//
//  Created by JAM-E-328 on 31/08/24.
//
import Foundation

final class ForgetPasswordViewModel {
    
    //MARK: - variables

    
    enum RequestType {
        case forgetPassword
        case none
    }
    
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none
    
    weak var forgetPasswordDelegate: UserServices?
    
    var forgetPasswordDict : ResponseModel<ForgetPasswordModel?>?{
        didSet {
            self.forgetPasswordDelegate?.reloadData()
        }
    }
    
    @MainActor
    func forgetPassword(parameters: ForgetRequest)  {
        Task {
            do {
                let userResponseArray: ResponseModel<ForgetPasswordModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.forgotPassword(param: parameters),
                    header: false)
                self.requestType = .forgetPassword
                self.forgetPasswordDict = userResponseArray
            }catch(let error) {
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
