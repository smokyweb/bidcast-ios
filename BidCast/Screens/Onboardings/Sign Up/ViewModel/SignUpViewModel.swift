//
//  ViewModel.swift
//  Rise Shine Swing
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
    
    @MainActor
    func signUp(parameters: SignUpRequest) {
        Task {
            do {
                let userResponseArray: ResponseModel<SignUpDataModel> = try await APIManager.shared.request(
                    type: APIEndPoint.singUp(param: parameters),
                    header: false)
                self.requestType = .signUp
                self.signUpDict = userResponseArray
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
