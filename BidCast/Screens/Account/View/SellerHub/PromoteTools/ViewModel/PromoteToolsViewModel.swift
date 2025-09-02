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

    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}
