//
//  ViewModel.swift
//  BidCast
//
//  Created by Vivek-JAM-E-328 on 31/08/24.
//

import Foundation

final class SignUpViewModel {
    
    enum RequestType {
        case signUp
        case none
    }
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none
    
    var signUpDict : ResponseModel<SignUpDataModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }

    // QA-FIX (deleted-account signup): store the most recent ApiError (with
    // error_type) so the view controller can branch on it in showError and
    // render friendlier copy for known cases like ACCOUNT_DELETED /
    // EMAIL_TAKEN, instead of surfacing the raw backend string.
    var lastSignUpApiError: ApiError?

    @MainActor
    func signUp(parameters: SignUpRequest) {
        Task {
            do {
                let userResponseArray: ResponseModel<SignUpDataModel> = try await APIManager.shared.request(
                    type: APIEndPoint.singUp(param: parameters),
                    header: false)
                self.requestType = .signUp
                self.lastSignUpApiError = nil
                self.signUpDict = userResponseArray
                // Phase 7a analytics
                AnalyticsService.shared.logSignUp(method: "password")
            }catch(let error) {
                if let dataError = error as? DataError {
                    // QA-FIX: capture the decoded ApiError so the VC can branch on error_type.
                    self.lastSignUpApiError = dataError.getApiError()
                    let errorMessage = dataError.getErrorMessage()
                    self.userDelegate?.showError(error: errorMessage)
                }
                else {
                    self.lastSignUpApiError = nil
                    self.userDelegate?.showError(error: error.localizedDescription)
                }
            }
        }
    }
}
