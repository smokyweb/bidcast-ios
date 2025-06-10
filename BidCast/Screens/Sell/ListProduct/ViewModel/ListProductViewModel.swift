//
//  SelectCategoryViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation
import StoreKit

@MainActor
final class ListProductViewModel: ObservableObject {
    
    @Published var categoryResponse: ResponseModal<[CategoryDataModel]>?
    @Published var storeProductResponse: ResponseModal<StoreProductModel>?
    @Published var errorMessage: String?
    @Published var requestType: String = ""
    
    // MARK: - Get Category List
    func getCategoryList() async {
        requestType = "Category"
        do {
            let response: ResponseModal<[CategoryDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.category,
                header: true
            )
            self.categoryResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
 
    @MainActor
    final class ListProductViewModel: ObservableObject {
        
        @Published var storeProductResponse: ResponseModal<StoreProductModel>?
        @Published var errorMessage: String?
        @Published var requestType: String = ""
        
        func storeProduct(param: StoreProductParam, images: [String], key: String) {
            self.requestType = "store"
            var parameters = [String: Any]()
            
            do {
                parameters = try param.asDictionary()
            } catch {
                self.errorMessage = "Invalid parameters: \(error.localizedDescription)"
                return
            }
            
            APIManager.shared.uploadImage(
                type: APIEndPoint.storeProduct(param: param),
                urlArray: images,
                mimeType: "image/png",
                keyName: key,
                parameters: parameters,
                modelType: ResponseModal<StoreProductModel>.self,
                header: true
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.storeProductResponse = data
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

}
