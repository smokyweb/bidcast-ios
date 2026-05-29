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
    // Basecamp #9933973683 (2026-05-29 RETURN): flash sales list for Explore page.
    @Published var flashSaleProducts: [FlashSaleProduct] = []
    @Published var isLoadingFlashSales: Bool = false

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
   
    // MARK: - Get Category List
    func getSubCategoryList(param:CategoryRequest) async throws{
        request = "SubCategory"
        do {
            let response: ResponseModel<[CategoryDataModel]> = try await APIManager.shared.request(
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
    func getSubCategoryList1(param: [String:Any]) async {
        self.request = "SubCategory"
        
        do {
            
            if let response: ResponseModal<[SubCategoryDataModel]> = try await APIManager.shared.requestWithJSONBody(type: APIEndPoint.getSubCategories(param: param), parameters: param, modalType: ResponseModal<[SubCategoryDataModel]>?.self, header: true){
//                DispatchQueue.main.async {
                    self.subCategoryResponse = response
//                }
            }
        } catch {
//            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
//            }
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

    // Basecamp #9933973683 (2026-05-29 RETURN): fetch active flash-sale
    // products from GET /api/product/flash-sales for the Explore page.
    func fetchFlashSaleProducts() async {
        isLoadingFlashSales = true
        do {
            let response: ResponseModel<[FlashSaleProduct]> = try await APIManager.shared.request(
                type: APIEndPoint.listFlashSales,
                header: true
            )
            self.flashSaleProducts = response.data ?? []
        } catch {
            self.flashSaleProducts = []
            self.errorMessage = error.localizedDescription
        }
        isLoadingFlashSales = false
    }

}
