//
//  SubscriptionViewModal.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 22/04/24.
//

import Foundation
import StoreKit

final class SubscriptionViewModal {
    
    var response: ResponseModal<SubscriptionStatus>?
    var responseProduct: ResponseModal<[SubscriptionProduct]>?
    var responseRightSwipe: ResponseModal<RightSwipeStatus>?
    var request : String = ""
    var receipt: String = ""
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    func saveSubscription(param: SubscriptionRequestModal) {
        self.eventHandler?(.loading)
        self.request = "EmployerProduct"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModal<SubscriptionStatus>.self,
                type: APIEndPoint.subscription(param: param),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.response = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    func purchaseRightSwipe(param: RightSwipeRequestModal) {
        self.eventHandler?(.loading)
        self.request = "RightSwipe"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModal<RightSwipeStatus>.self,
                type: APIEndPoint.SaveRightSwipe(param: param),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.responseRightSwipe = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    
    func fetchSubscriptionEmployer() {
        self.eventHandler?(.loading)
        self.request = "EmployerSubscription"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModal<[SubscriptionProduct]>.self,
                type: APIEndPoint.getProductEmployer,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.responseProduct = data
                        print(data)
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
    
    func fetchProductCandidate() {
        self.eventHandler?(.loading)
        self.request = "CandidateSubscription"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModal<[SubscriptionProduct]>.self,
                type: APIEndPoint.getProductCandidate,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.responseProduct = data
                        print(data)
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
    }
}
