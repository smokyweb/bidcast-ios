//
//  ContactUsViewModel.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

final class ContactUsViewModel {
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    var contactUs : ResponseModel<ContactUsModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    @MainActor
    func contactUs(parameters: ContactUsRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<ContactUsModel> = try await APIManager.shared.request(
                    type: APIEndPoint.contact(param: parameters),
                    header: true)
                self.contactUs = userResponseArray
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


