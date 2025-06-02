//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//

import Foundation

final class ProfileViewModel {
    
    var getProfileDict = ResponseModel<ProfileModel>()
    var productDetailsResponceDict : ResponseModalPaginate<[ProductListingDataModel]>?
    var followDict = ResponseModel<[String]>()
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
//                    self.addressDict = data
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    
    func getProfile(param:ProfileParamRequest) {
        self.eventHandler?(.loading)
        self.requestType = "get"
        APIManager.shared.requestPost(
                modelType: ResponseModel<ProfileModel>.self,
                type: APIEndPoint.getProfileById(param: param),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.getProfileDict = data
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
        
    }
    
    func productDetails(parameters: UserProductRequest) {
        self.requestType = "product"
           self.eventHandler?(.loading)
           APIManager.shared.requestPost(
               modelType: ResponseModalPaginate<[ProductListingDataModel]>.self,
               type: APIEndPoint.getUserProduct(param: parameters),
               header: true) { result in
                   self.eventHandler?(.stopLoading)
                   switch result {
                   case .success(let data):
                       self.productDetailsResponceDict = data
                       self.eventHandler?(.dataLoaded)
                   case .failure(let error):
                       self.eventHandler?(.error(error))
                   }
               }
       }
    
    func followUnfollow(parameters: FollowRequest) {
        self.requestType = "follow"
           self.eventHandler?(.loading)
           APIManager.shared.requestPost(
            modelType: ResponseModel<[String]>.self,
               type: APIEndPoint.followUnfollow(param: parameters),
               header: true) { result in
                   self.eventHandler?(.stopLoading)
                   switch result {
                   case .success(let data):
//                       self.followDict = data
                       self.getProfile(param: ProfileParamRequest(id: parameters.following_id))
                       self.eventHandler?(.dataLoaded)
                   case .failure(let error):
                       self.eventHandler?(.error(error))
                   }
               }
       }
   
}


extension ProfileViewModel {
    
    enum Event {
        case loading
        case stopLoading
        case dataLoaded
        case error(Error?)
        
    }
    
}

