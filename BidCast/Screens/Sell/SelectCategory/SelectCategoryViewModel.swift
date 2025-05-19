//
//  SelectCategoryViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation
import StoreKit

final class SelectCategoryViewModel {
    
    var categoryDict: ResponseModal<[CategoryDataModel]>?
    var AuctionDict: ResponseModal<[AuctionDataModel]>?
    var request : String = ""
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    //MARK: getCategory
    func getCategoryList() {
        self.eventHandler?(.loading)
        self.request = "Category"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModal<[CategoryDataModel]>.self,
                type: APIEndPoint.category,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.categoryDict = data
                        print(data)
                        self.eventHandler?(.dataLoaded)
                        return
                    case .failure(let error):
                        self.eventHandler?(.error(error))
                        return
                        
                    }
                }
        
    }
    
    //MARK: getAuction
    func getAuctionList() {
        self.eventHandler?(.loading)
        self.request = "Auction"
        APIManager.shared
            .dictionaryRequest(
                modelType: ResponseModal<[AuctionDataModel]>.self,
                type: APIEndPoint.auctionType,
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.AuctionDict = data
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
