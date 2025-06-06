//
//  PaymentViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 06/06/25.
//

import Foundation

final class PaymentViewModel {
    var addressDict = ResponseModel<AddressModel>()
    var getAddressDict = ResponseModel<[AddressModel]>()
    var cardDict = ResponseModel<[CardModel]>()
    var requestType = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    
    
    func getCard() {
        self.eventHandler?(.loading)
        self.requestType = "get"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModel<[CardModel]>.self,
                type: APIEndPoint.getCard,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.cardDict = data
                        print(data)
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
        
    }
    
   
    func deleteCard(parameters: DeleteCardRequest) {
        self.requestType = "delete"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModel<CardModel>.self, // response type
            type: APIEndPoint.deleteCard(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
//                    self.addressDict = data
                    self.getCard()
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func getAddresses() {
        self.eventHandler?(.loading)
        self.requestType = "getAddress"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModel<[AddressModel]>.self,
                type: APIEndPoint.getAddress,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.getAddressDict = data
                        print(data)
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
        
    }
    func setDefaultAddress(parameters: AddressDefaultParam) {
        self.requestType = "default"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModel<AddressModel>.self, // response type
            type: APIEndPoint.setDefaultAddress(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.addressDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func DeleteAddress(parameters: AddressDefaultParam) {
        self.requestType = "deleteAddress"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModel<AddressModel>.self, // response type
            type: APIEndPoint.deleteAddress(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
//                    self.addressDict = data
                    self.getAddresses()
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}


extension PaymentViewModel {
    
    enum Event {
        case loading
        case stopLoading
        case dataLoaded
        case error(Error?)
        
    }
    
}

