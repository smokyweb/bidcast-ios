//
//  ProductDetailsViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

final class ProductDetailsViewModel : ObservableObject{
    
    var productDetailsResponceDict : ResponseModal<ProductDetailsModel>?
    
    var eventHandler: ((_ event: Event) -> Void)? // Data Binding Closure
    
    //MARK: getProductDetails.
    func getProductDetails(parameters: FetchProductRequest) {
        self.eventHandler?(.loading)
        APIManager.shared.requestPost(
            modelType: ResponseModal<ProductDetailsModel>.self,
            type: APIEndPoint.fetchProduct(param: parameters),
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
}





