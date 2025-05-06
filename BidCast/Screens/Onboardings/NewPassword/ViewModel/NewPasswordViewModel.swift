//
//  NewPasswordViewModel.swift
//  BidCast
//
//  Created by Vivek-JAM-E-328 on 05/09/24.
//

import Foundation

enum RequestType {
    case none
    case newPassword
    case updatePassword
    
}
final class NewPasswordViewModel {
    
    weak var userDelegate: UserServices?
    
    var updatePasswordDict : ResponseModel<UpdatePasswordModel?>? {
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    var newPasswordDict : ResponseModel<ResetPasswordModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    var requestType: RequestType = .none
    
    @MainActor
    func newPassword(parameters: newPasswordRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<ResetPasswordModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.resetPassword(param: parameters),
                    header: false)
                self.requestType = .newPassword
                self.newPasswordDict = userResponseArray
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
    
    
    func updatePassword(parameters: UpdatePasswordRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<UpdatePasswordModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.changePassword(param: parameters),
                    header: true)
                self.requestType = .updatePassword
                self.updatePasswordDict = userResponseArray
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


