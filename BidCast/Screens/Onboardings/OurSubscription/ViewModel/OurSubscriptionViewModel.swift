//
// OurSubscriptionViewModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import Foundation


import Foundation

final class SubscriptionViewModel {
    
    enum RequestType {
        case getSubscription
        case validateSubscriptions
        case addSubscription
        case none
    }
    
    //MARK: - variables
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none
    
    //MARK: - getSubscriptionDict
    var getSubscriptionDict : ResponseModel<[SubscriptionsListModel]?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    //MARK: - validateSubscriptionDict
    var validateSubscriptionDict : ResponseModel<SubscriptionValidationModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    
    
    //MARK: - deleteAlarmDict
    var addSubscriptionDict : ResponseModel<SubscriptionModel?>?{
        didSet {
            self.userDelegate?.reloadData()
        }
    }
    

    @MainActor
    //MARK: - getSubscriptionData
    func getSubscriptionData() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<[SubscriptionsListModel]?>? = try await APIManager.shared.request(
                    type: APIEndPoint.getSubscriptionList,
                    header: true)
                self.requestType = .getSubscription
                self.getSubscriptionDict = userResponseArray
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

 
    @MainActor
    //MARK: - addSubscription
    func addSubscription(parameters: AddSubscriptionsRequest) {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<SubscriptionModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.addSubscriptionRequest(param: parameters),
                    header: true)
                self.requestType = .addSubscription
                self.addSubscriptionDict = userResponseArray
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
    
    @MainActor
    //MARK: - validateSubscriptionRequest
    func validateSubscriptionRequest() {
        Task { // @MainActor in
            do {
                let userResponseArray: ResponseModel<SubscriptionValidationModel?>? = try await APIManager.shared.request(
                    type: APIEndPoint.validateSubscription,
                    header: true)
                self.requestType = .validateSubscriptions
                self.validateSubscriptionDict = userResponseArray
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


