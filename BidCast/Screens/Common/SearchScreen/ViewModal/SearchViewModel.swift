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

    func search(query: String, page: Int = 1,
                categoryIds: [Int]? = nil,
                subCategoryIds: [Int]? = nil) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            shows = []; products = []; users = []
            return
        }
        Task {
            await performSearch(query: query, page: page,
                                categoryIds: categoryIds,
                                subCategoryIds: subCategoryIds)
        }
    }

    private func performSearch(query: String, page: Int,
                               categoryIds: [Int]?,
                               subCategoryIds: [Int]?) async {
        isLoading = true
        errorMessage = nil
        do {
            // Basecamp #9938023997 (2026-05-28): pass category + subcategory
            // filter params to POST /api/v1/search.
            var searchRequest = UnifiedSearchRequest(search: query, page: String(page))
            searchRequest.category_ids     = categoryIds?.isEmpty == false ? categoryIds : nil
            searchRequest.sub_category_ids = subCategoryIds?.isEmpty == false ? subCategoryIds : nil
            let response: UnifiedSearchResponse = try await APIManager.shared.request(
                type: APIEndPoint.unifiedSearch(param: searchRequest),
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
