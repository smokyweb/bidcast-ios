//
//  NewsViewModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//


import Foundation

@MainActor
final class NewsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var newsResponse = ResponseModel<[NewsResponseModel]>()
    @Published var errorMessage: String? = nil

    // MARK: - Get News Content
    func getNewsContent() async {
        do {
            let response: ResponseModel<[NewsResponseModel]> = try await APIManager.shared.request(
                type: APIEndPoint.get_news,
                header: true
            )
            newsResponse = response
        } catch {
            handle(error: error)
        }
    }

    // MARK: - Centralized Error Handler
    private func handle(error: Error) {
        errorMessage = error.localizedDescription
    }
}
