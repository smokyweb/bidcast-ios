//
//  SelectCategoryViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation
import StoreKit


@MainActor
final class SelectCategoryViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var categoryResponse = ResponseModel<[CategoryDataModel]>()
    @Published var subCategoryResponse: ResponseModal<[SubCategoryDataModel]>?
    @Published var auctionResponse = ResponseModel<[AuctionDataModel]>()
    @Published var storeFavCategoryResponse: ResponseModal<[FavCategoryDataModel]>?
    @Published var errorMessage: String? = nil
    @Published var request: String = ""

    // MARK: - Fetch Categories
    func getCategoryList(param:CategoryRequest) async {
        do {
            let response: ResponseModel<[CategoryDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.category(param:param),
                header: true
            )
            self.categoryResponse = response
            self.request = "Category"
        } catch {
            self.handle(error: error)
        }
    }
    
    func getSubCategoryList(param: [String:Any]) async {
        self.request = "SubCategory"
        
        do {
            
            if let response: ResponseModal<[SubCategoryDataModel]> = try await APIManager.shared.requestWithJSONBody(type: APIEndPoint.getSubCategories(param: param), parameters: param, modalType: ResponseModal<[SubCategoryDataModel]>?.self, header: true){
                DispatchQueue.main.async {
                    self.subCategoryResponse = response
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func storeFavCategoryList(param: [String:Any]) async {
        self.request = "FavCategory"
        
        do {
            
            if let response: ResponseModal<[FavCategoryDataModel]> = try await APIManager.shared.requestWithJSONBody(type: APIEndPoint.storeFavCategories(param: param), parameters: param, modalType: ResponseModal<[FavCategoryDataModel]>?.self, header: true){
                DispatchQueue.main.async {
                    self.storeFavCategoryResponse = response
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Fetch Auctions
    func getAuctionList() async {
        do {
            let response: ResponseModel<[AuctionDataModel]> = try await APIManager.shared.request(
                type: APIEndPoint.auctionType,
                header: true
            )
            self.auctionResponse = response
            self.request = "Auction"
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
