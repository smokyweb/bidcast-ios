//
//  SelectCategoryViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation
import StoreKit

final class ListProductViewModel {
    
    var categoryDict: ResponseModal<[CategoryDataModel]>?
    var storeProductDict: ResponseModal<StoreProductModel>?
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
    func storeProduct(param: StoreProductParam, images: [String],key : String) {
        self.eventHandler?(.loading)
        self.request = "store"
        var parameters = [String:Any]()
        do { parameters = try param.asDictionary() } catch {print(error.localizedDescription)}
        
        APIManager.shared
            .uploadFile(
                type: APIEndPoint.storeProduct(param: param),
                urlArray: images,
                mimeType: "image/png",
                modalType: ResponseModal<StoreProductModel>.self,
                key: key,
                parameters: parameters,
                header: true,
                completion: {
                    result in
                    self.eventHandler?(.stopLoading)
                    switch result {
                        case .success(let data):
                        self.storeProductDict = data
                        case .failure(let error):
                            self.eventHandler?(.error(error))
                    }
                })
    }
}
