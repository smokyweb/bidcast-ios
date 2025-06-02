//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//

import Foundation

final class LiveShowsViewModel {
    
    var addressDict = ResponseModel<AddressModel>()
    var getLiveShowsDict = ResponseModel<[LiveShowsModel]>()
   
    var requestType = ""
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure

    func storeAddress(parameters: AddressRequest) {
        self.requestType = "store"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModel<AddressModel>.self, // response type
            type: APIEndPoint.storeAddress(param: parameters),
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
    
    
    func getLiveShows() {
        self.eventHandler?(.loading)
        self.requestType = "get"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModel<[LiveShowsModel]>.self,
                type: APIEndPoint.getLiveShows,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.getLiveShowsDict = data
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
        self.requestType = "delete"
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModel<AddressModel>.self, // response type
            type: APIEndPoint.deleteAddress(param: parameters),
            header: true) { result in
                self.eventHandler?(.stopLoading)
                switch result {
                case .success(let data):
//                    self.addressDict = data
//                    self.getAddresses()
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
}


extension LiveShowsViewModel {
    
    enum Event {
        case loading
        case stopLoading
        case dataLoaded
        case error(Error?)
        
    }
    
}

