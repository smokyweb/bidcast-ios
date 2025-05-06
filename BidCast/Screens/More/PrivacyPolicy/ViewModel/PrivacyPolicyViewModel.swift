//
//  PrivacyPolicyViewModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import Foundation

final class PrivacyPolicyViewModel {
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    var privacyPolicyDict : ResponseModel<PrivacyPolicyModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    @MainActor
    func getPrivacyPolicyData() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<PrivacyPolicyModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.privacyPolicy,
                    header: false)
                self.privacyPolicyDict = userResponseArray
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


