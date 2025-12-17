//
//  SellerAnalyticsViewModel.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 07/10/25.
//

import Foundation

@MainActor
final class SellerAnalyticsViewModel: ObservableObject {

    @Published var visitorsAnalyticsResponse: ResponseModel<VisitorsAnalyticsModel>?
    @Published var sellerAnalyticsResponse: ResponseModel<SellerAnalyticsModel>?
    @Published var salesPerformanceResponse: ResponseModel<SalesPerformanceModel>?
    
    @Published var errorMessage: String? = nil

    func getVisitorsAnalyticsReport(request: VisitorsAnalyticsRequest) async throws {
        do {
            let response: ResponseModel<VisitorsAnalyticsModel>? = try await APIManager.shared.request(
                type: APIEndPoint.getVisitorsAnalytic(param: request),
                header: true
            )
            self.visitorsAnalyticsResponse = response
        }
        catch(let error) {
           if let dataError = error as? DataError {
               self.errorMessage = dataError.getErrorMessage()
           }
           else {
               self.errorMessage = error.localizedDescription
           }
           throw error
       }
    }
    
    func getSellerAnalyticsReport(request: SellerAnalyticsRequest) async throws {
        do {
            let response: ResponseModel<SellerAnalyticsModel>? = try await APIManager.shared.request(
                type: APIEndPoint.getSellerAnalytic(param: request),
                header: true
            )
            self.sellerAnalyticsResponse = response
        }
        catch(let error) {
           if let dataError = error as? DataError {
               self.errorMessage = dataError.getErrorMessage()
           }
           else {
               self.errorMessage = error.localizedDescription
           }
           throw error
       }
    }
    
    func getSalesPreformanceReport(request: SalesPerformanceRequest) async throws{
        do {
            let response: ResponseModel<SalesPerformanceModel>? = try await APIManager.shared.request(
                type: APIEndPoint.getSalesPerformace(param: request),
                header: true
            )
            self.salesPerformanceResponse = response
        }
        catch(let error) {
            if let dataError = error as? DataError {
                self.errorMessage = dataError.getErrorMessage()
            }
            else {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    func getExportDetailsReport(request: ExportDetailsRequest) async throws {
        do {
            let response: ResponseModel<SellerAnalyticsModel>? = try await APIManager.shared.request(
                type: APIEndPoint.getExportDetails(param: request),
                header: true
            )
            self.sellerAnalyticsResponse = response
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
    

    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
//
//import Foundation
//import Combine
//
//@MainActor
//final class SellerAnalyticsViewModel: ObservableObject {
//    
//    // MARK: - Published Properties (Observable by UI)
//    @Published var visitorsAnalyticsResponse: ResponseModel<VisitorsAnalyticsModel>?
//    @Published var sellerAnalyticsResponse: ResponseModel<SellerAnalyticsModel>?
//    @Published var salesPerformanceResponse: ResponseModel<SalesPerformanceModel>?
//    @Published var errorMessage: String?
//    @Published var isLoading: Bool = false
//
//    // MARK: - Dependencies
//    private let apiManager: APIManaging
//    private var cancellables = Set<AnyCancellable>()
//
//    // MARK: - Init with DI
//    init(apiManager: APIManaging = APIManager.shared) {
//        self.apiManager = apiManager
//    }
//
//    // MARK: - Fetch Visitors Analytics
//    func fetchVisitorsAnalytics(using request: VisitorsAnalyticsRequest) {
//        isLoading = true
//        apiManager
//            .request(type: .getVisitorsAnalytic(param: request), header: true)
//            .sink { [weak self] completion in
//                self?.isLoading = false
//                if case let .failure(error) = completion {
//                    self?.handle(error: error)
//                }
//            } receiveValue: { [weak self] (response: ResponseModel<VisitorsAnalyticsModel>) in
//                self?.visitorsAnalyticsResponse = response
//            }
//            .store(in: &cancellables)
//    }
//
//    // MARK: - Fetch Seller Analytics
//    func fetchSellerAnalytics(using request: SellerAnalyticsRequest) {
//        isLoading = true
//        apiManager
//            .request(type: .getSellerAnalytic(param: request), header: true)
//            .sink { [weak self] completion in
//                self?.isLoading = false
//                if case let .failure(error) = completion {
//                    self?.handle(error: error)
//                }
//            } receiveValue: { [weak self] (response: ResponseModel<SellerAnalyticsModel>) in
//                self?.sellerAnalyticsResponse = response
//            }
//            .store(in: &cancellables)
//    }
//
//    // MARK: - Fetch Sales Performance
//    func fetchSalesPerformance(using request: SalesPerformanceRequest) {
//        isLoading = true
//        apiManager
//            .request(type: .getSalesPerformace(param: request), header: true)
//            .sink { [weak self] completion in
//                self?.isLoading = false
//                if case let .failure(error) = completion {
//                    self?.handle(error: error)
//                }
//            } receiveValue: { [weak self] (response: ResponseModel<SalesPerformanceModel>) in
//                self?.salesPerformanceResponse = response
//            }
//            .store(in: &cancellables)
//    }
//
//    // MARK: - Error Handling
//    private func handle(error: Error) {
//        if let apiError = error as? DataError {
//            errorMessage = apiError.localizedDescription
//        } else {
//            errorMessage = "Something went wrong. Please try again."
//        }
//    }
//}
//
