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
    @Published var mailClassResponse: ResponseModal<MailClassesData>?
    @Published var storeImageResponse: ResponseModal<[ImageModel]>?
    @Published var errorMessage: String?
    @Published var addressesResponse : ResponseModal<[AddressModel]>?
    @Published var requestType: String = ""
    
    // MARK: - Get Category List
    func getSubCategoryList(param:CategoryRequest) async throws{
        requestType = "Category"
        do {
            let response: ResponseModal<[CategoryDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.category(param:param),
                header: true
            )
            self.categoryResponse = response
        } catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // MARK: - Get Category List
    func getMailClasses() async throws{
        requestType = "mail"
        do {
            let response: ResponseModal<MailClassesData> = try await APIManager.shared.request(
                type: APIEndPoint.getMailClass,
                header: true
            )
            self.mailClassResponse = response
        } catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    
    
    func storeProduct(productId: Int? = nil, param: [String:Any]) async throws{
        self.requestType = "store"
        
        do {
            
            if let response: ResponseModal<StoreProductModel> = try await APIManager.shared.requestWithJSONBody(
                type: APIEndPoint.storeProduct(productId: productId, param: param),
                parameters: param,
                modalType: ResponseModal<StoreProductModel>?.self,
                header: true){
                self.storeProductResponse = response
            }
        }catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func uploadStoreImage(images: [String], key: String) async throws{
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

        } catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }

    
    // MARK: - Get Addresses
    func getAddresses() async throws{
       
        do {
           if  let response: ResponseModal<[AddressModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getAddress,
                header: true
           ){
               addressesResponse = response
           }
        } catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
       
    }


// MARK: - Centralized Error Handler
private func handle(error: Error) {
    if let dataError = error as? DataError {
        switch dataError {
        case .invalidCode(let message):
            self.errorMessage = message ?? "Invalid code error"
        case .invalidResponse(let data):
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                self.errorMessage = "Invalid response: \(json)"
            } else {
                self.errorMessage = "Invalid response with no data"
            }
        default:
            self.errorMessage = error.localizedDescription
        }
    } else {
        self.errorMessage = error.localizedDescription
    }
}
}
