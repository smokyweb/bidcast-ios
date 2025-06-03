//
//  AddCardViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/06/25.
//


import Foundation

final class AddCardViewModel {
    
    var addressDict = ResponseModel<AddressModel>()
    var cardDict = ResponseModel<[CardModel]>()
   var addCardDict = ResponseModel<CardModel>()
    var requestType = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func addCard(parameters: AddCardRequest) {
        self.requestType = "add"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModel<CardModel>.self, // response type
            type: APIEndPoint.AddCard(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
                    self.addCardDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    
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
    
}


extension AddCardViewModel {
    
    enum Event {
        case loading
        case stopLoading
        case dataLoaded
        case error(Error?)
        
    }
    
}

