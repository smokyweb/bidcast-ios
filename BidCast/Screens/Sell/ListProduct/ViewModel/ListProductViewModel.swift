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
    @Published var storeImageResponse: ResponseModal<[ImageModel]>?
    @Published var errorMessage: String?
    @Published var addressesResponse : ResponseModal<[AddressModel]>?
    @Published var requestType: String = ""
    
    // MARK: - Get Category List
    func getCategoryList(param:CategoryRequest) async {
        requestType = "Category"
        do {
            let response: ResponseModal<[CategoryDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.category(param:param),
                header: true
            )
            self.categoryResponse = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    
    
    func storeProduct(param: [String:Any]) async {
        self.requestType = "store"
        
        do {
            
            if let response: ResponseModal<StoreProductModel> = try await APIManager.shared.requestWithJSONBody(type: APIEndPoint.storeProduct(param: param), parameters: param, modalType: ResponseModal<StoreProductModel>?.self, header: true){
                DispatchQueue.main.async {
                    self.storeProductResponse = response
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func uploadStoreImage(images: [String], key: String) async {
        self.requestType = "store"
        
        do {
//            let parameters = try param.asDictionary()
            
           if let response = try await APIManager.shared.uploadImage(
                type: APIEndPoint.uploadProductImage,
                urlArray: images,
                mimeType: "image/jpeg",
                keyName: "images[]",
                parameters: [:],
                modalType: ResponseModal<[ImageModel]>?.self,
                header: true
           ){
                self.storeImageResponse = response
            }

        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    
    // MARK: - Get Addresses
    func getAddresses() async {
       
        do {
           if  let response: ResponseModal<[AddressModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getAddress,
                header: true
           ){
               addressesResponse = response
           }
        } catch {
            self.errorMessage = error.localizedDescription
        }
       
    }
}
