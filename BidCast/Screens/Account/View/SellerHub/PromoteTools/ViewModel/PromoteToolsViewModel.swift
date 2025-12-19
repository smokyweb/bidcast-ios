//
//  PromoteToolsViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class PromoteToolsViewModel: ObservableObject {

    @Published var promoteToolResponse = ResponseModel<PromoteToolModel>()
    @Published var promoteDetailResponse = ResponseModel<AnalyticsData>()
    
    @Published var errorMessage: String? = nil

    func getPromoteToolContent() async {
        do {
            let response: ResponseModel<PromoteToolModel> = try await APIManager.shared.request(
                type: APIEndPoint.promoteTool,
                header: true
            )
            self.promoteToolResponse = response
        } catch {
            self.handle(error: error)
        }
    }
    func getPromoteToolDetails(param:promoteToolRequest) async {
        do {
            let response: ResponseModel<AnalyticsData> = try await APIManager.shared.request(
                type: APIEndPoint.getPromoteToolDetails(param: param),
                header: true
            )
            self.promoteDetailResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
