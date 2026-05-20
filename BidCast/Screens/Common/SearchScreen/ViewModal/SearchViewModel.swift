//
//  SearchViewModel.swift
//  BidCast
//
//  Created by JAM-E-265 on 02/02/24.
//

import Foundation

@MainActor
final class SearchViewModel: ObservableObject {

    @Published var shows: [SearchResultShow] = []
    @Published var products: [SearchResultProduct] = []
    @Published var users: [SearchResultUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func search(query: String, page: Int = 1) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            shows = []; products = []; users = []
            return
        }
        Task {
            await performSearch(query: query, page: page)
        }
    }

    private func performSearch(query: String, page: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let response: UnifiedSearchResponse = try await APIManager.shared.request(
                type: APIEndPoint.unifiedSearch(param: UnifiedSearchRequest(search: query, page: String(page))),
                header: true
            )
            shows    = response.data?.shows    ?? []
            products = response.data?.products ?? []
            users    = response.data?.users    ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
