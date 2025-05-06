//
//  SignInViewModel.swift
//  Rise Shine Swing
//
//  Created by Vivek-JAM-E-328 on 31/08/24.
//

import Foundation

protocol UserServices: AnyObject {
    func reloadData()
    func showError(error: String)
}

final class SignInViewModel {
    
    //MARK: - variables
    
    enum RequestType {
        case signIn
        case none
    }
    
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none

    var signInDict : ResponseModel<SignInDataModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
//    @MainActor
//    func signIn(parameters: SignInRequest) {
//        Task { // @MainActor in
//            do {
//                let userResponseArray: ResponseModel<SignInDataModel> = try await APIManager.shared.request(
//                    type: APIEndPoint.login(param: parameters),
//                    header: false)
//                self.requestType = .signIn
//                self.signInDict = userResponseArray
//            }catch let error as DataError { // Catching the custom DataError enum
//                switch error {
//                case .ErrorMessage(let message):
//                    debugLog("Error Message: \(message ?? "Unknown error!")")
//                    self.userDelegate?.showError(error: message ?? "Unknown error!")
//                    
//                default:
//                    debugLog("Other error: \(error)")
//                    self.userDelegate?.showError(error: "An unexpected error occurred")
//                    
//                }
//            }
//        }
//    }
    
    @MainActor
    func signIn(parameters: SignInRequest) {
        Task {
            do {
                let userResponseArray: ResponseModel<SignInDataModel> = try await APIManager.shared.request(
                    type: APIEndPoint.login(param: parameters),
                    header: true)
                self.requestType = .signIn
                self.signInDict = userResponseArray
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
