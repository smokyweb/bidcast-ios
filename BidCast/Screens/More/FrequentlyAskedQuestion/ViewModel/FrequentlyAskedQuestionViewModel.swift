//
//  FrequentlyAskedQuestionViewModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25
//

import Foundation

final class FAQViewModel {
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    var FAQDict : ResponseModel<[FAQModel]?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    @MainActor
    func getFAQData() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<[FAQModel]?>? = try await APIManager.shared.request(
                    type: APIEndPoint.faq,
                    header: true)
                self.FAQDict = userResponseArray
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


