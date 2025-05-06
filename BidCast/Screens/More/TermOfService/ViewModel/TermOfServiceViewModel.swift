//
//  TermOfServiceViewModel.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

final class TermConditionViewModel {
    
    //MARK: - variables
    
    //MARK: - variables
    enum RequestType {
        case termCondition
        case none
    }
    
    var requestType: RequestType = .none
    
    weak var userDelegate: UserServices?
    
    var termConditionDict : ResponseModel<TermAndConditionModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    @MainActor
    func getTermConditionData() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<TermAndConditionModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.termsCondition,
                    header: false)
                self.requestType = .termCondition
                self.termConditionDict = userResponseArray
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


