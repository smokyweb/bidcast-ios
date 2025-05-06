//
// LogOutViewModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import Foundation

final class LogoutViewModel {
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    
    enum RequestType {
        case logout
        case none
    }
    
    var requestType: RequestType = .none
    
    var logoutDict : ResponseModel<ResetPasswordModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }

    @MainActor
    func logout(parameters: LogoutRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<ResetPasswordModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.logout(param: parameters),
                    header: true)
                self.requestType = .logout
                self.logoutDict = userResponseArray
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
