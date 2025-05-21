//
//  InventoryViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

final class InventoryViewModel {
    
    var InventoryDict: ResponseModalPaginate<[InventoryDataModel]>?
    var request : String = ""
    
    var eventHandler: ((_ event: Event) -> Void)?
    
    //MARK: getInventoryList
    func getInventoryList(param : InventoryRequest) {
        self.eventHandler?(.loading)
        self.request = "Inventory"
        APIManager.shared
            .requestPost(
                modelType: ResponseModalPaginate<[InventoryDataModel]>.self,
                type: APIEndPoint.getInventory(param: param),
                header: true) {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                    case .success(let data):
                        self.InventoryDict = data
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

