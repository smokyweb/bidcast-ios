//
//  DeleteProfileViewModel.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-174 on 19/09/24.
//

import Foundation

final class DeleteProfileViewModel {
    
    //MARK: - variable
    weak var userDelegate: UserServices?
    var deleteAccountDict : ResponseModel<DeleteProfileModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    @MainActor
    func deleteAccount(parameters: DeleteProfileRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<DeleteProfileModel> = try await APIManager.shared.request(
                    type: APIEndPoint.deleteAccountRequest(param: parameters),
                    header: true)
                self.deleteAccountDict = userResponseArray
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

