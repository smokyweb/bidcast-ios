//
//  AboutUsViewModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import Foundation

final class AboutUsViewModel {
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    var aboutUsDict : ResponseModel<AboutUsModel>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    @MainActor
    func getAboutUsData() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<AboutUsModel>? = try await APIManager.shared.request(
                    type: APIEndPoint.aboutUs,
                    header: true)
                self.aboutUsDict = userResponseArray
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


