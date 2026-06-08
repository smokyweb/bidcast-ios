//
//  AddressViewModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var addressResponse = ResponseModel<AddressModel>()
    @Published var liveShowsResponse = ResponseModelPaginate<[HomeModel]>()
    @Published var accountInfo = ResponseModel<ProfileModel>()
    // Basecamp #9933973683 (2026-05-29): flash-sale row data for the home page.
    @Published var flashSalesResponse = ResponseModel<[FlashSaleProduct]>()
    @Published var errorMessage: String? = ""
    @Published var requestType = ""


    // MARK: - Get Live Shows
    func getLiveShows(param:GetLiveShowsRequest) async {
        self.requestType = "get"
        self.errorMessage = nil
        do {
            let response: ResponseModelPaginate<[HomeModel]> = try await APIManager.shared.request(
                type: APIEndPoint.getLiveShows(param: param),
                header: true
            )
            self.errorMessage = nil
            self.liveShowsResponse = response
        } catch {
            handle(error)
        }
    }
    
    // MARK: - Get Flash Sales (Basecamp #9933973683)
    // GET /api/product/flash-sales — cross-seller active flash items.
    func getFlashSales() async {
        do {
            let response: ResponseModel<[FlashSaleProduct]> = try await APIManager.shared.request(
                type: APIEndPoint.listFlashSales,
                header: true
            )
            self.flashSalesResponse = response
        } catch {
            // Non-fatal: the home feed should still load even if flash sales fail.
            if let dataError = error as? DataError {
                print("⚠️ flash-sales fetch failed:", dataError.getErrorMessage())
            } else {
                print("⚠️ flash-sales fetch failed:", error.localizedDescription)
            }
        }
    }

    func getProfile() async {
        requestType = "get"
        errorMessage = ""
        do {
            let response: ResponseModel<ProfileModel> = try await APIManager.shared.request(
                type: APIEndPoint.getprofile,
                header: true
            )
            self.accountInfo = response
        } catch let error as DataError {
            let message = error.getErrorMessage()
            print("❌ HomeViewModel.getProfile DataError:", message)
            self.errorMessage = message
        } catch {
            print("❌ HomeViewModel.getProfile Error:", error.localizedDescription)
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - Handle Error
    private func handle(_ error: Error) {
        if let dataError = error as? DataError {
            let message = dataError.getErrorMessage()
            print("❌ HomeViewModel error:", message)
            self.errorMessage = message
        } else {
            print("❌ HomeViewModel error:", error.localizedDescription)
            self.errorMessage = error.localizedDescription
        }
    }
}
