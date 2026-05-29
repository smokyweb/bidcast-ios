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

    // Basecamp #9933301500 (2026-05-29): accept the full BrowseFilters set so
    // the search-results filter sheet's Apply actually constrains results.
    // Previously only categoryIds + subCategoryIds were forwarded; show_format,
    // tag, shipping, premier_shop, ship_country, ship_state were silently
    // dropped, which is why "filter sheet appears but does nothing on apply."
    func search(query: String, page: Int = 1,
                categoryIds: [Int]? = nil,
                subCategoryIds: [Int]? = nil,
                filters: BrowseFilters? = nil) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            shows = []; products = []; users = []
            return
        }
        Task {
            await performSearch(query: query, page: page,
                                categoryIds: categoryIds,
                                subCategoryIds: subCategoryIds,
                                filters: filters)
        }
    }

    private func performSearch(query: String, page: Int,
                               categoryIds: [Int]?,
                               subCategoryIds: [Int]?,
                               filters: BrowseFilters?) async {
        isLoading = true
        errorMessage = nil
        do {
            // Basecamp #9938023997 (2026-05-28): pass category + subcategory
            // filter params to POST /api/v1/search.
            var searchRequest = UnifiedSearchRequest(search: query, page: String(page))
            searchRequest.category_ids     = categoryIds?.isEmpty == false ? categoryIds : nil
            searchRequest.sub_category_ids = subCategoryIds?.isEmpty == false ? subCategoryIds : nil
            // Basecamp #9933301500 (2026-05-29): wire the remaining 5 filters.
            if let f = filters {
                searchRequest.show_format  = f.showFormat
                let trimmedTag = f.tag.trimmingCharacters(in: .whitespacesAndNewlines)
                searchRequest.tag          = trimmedTag.isEmpty ? nil : trimmedTag
                searchRequest.shipping     = f.shipping
                searchRequest.premier_shop = f.premierShop ? true : nil
                searchRequest.ship_country = f.shipCountry
                let trimmedState = f.shipState.trimmingCharacters(in: .whitespacesAndNewlines)
                searchRequest.ship_state   = trimmedState.isEmpty ? nil : trimmedState
            }
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
