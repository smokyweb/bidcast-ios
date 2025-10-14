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

    func getVisitorsAnalyticsReport(request: VisitorsAnalyticsRequest) async {
        do {
            let response: ResponseModel<VisitorsAnalyticsModel>? = try await APIManager.shared.request(
                type: APIEndPoint.getVisitorsAnalytic(param: request),
                header: true
            )
            self.visitorsAnalyticsResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    func getSellerAnalyticsReport(request: SellerAnalyticsRequest) async {
        do {
            let response: ResponseModel<SellerAnalyticsModel>? = try await APIManager.shared.request(
                type: APIEndPoint.getSellerAnalytic(param: request),
                header: true
            )
            self.sellerAnalyticsResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    
    func getSalesPreformanceReport(request: SalesPerformanceRequest) async {
        do {
            let response: ResponseModel<SalesPerformanceModel>? = try await APIManager.shared.request(
                type: APIEndPoint.getSalesPerformace(param: request),
                header: true
            )
            self.salesPerformanceResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
