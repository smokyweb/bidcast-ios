//
//  ProductFilter.swift
//  BidCast
//
//  Created by Trey Difficult Task Agent on 2026-04-21.
//
//  State container for the Explore filter sheet.
//
//  ⚠️ QA-FIX-cmo93i6gp: `minPrice` / `maxPrice` are `Int?` (not `Int`). `nil`
//  means "not set" — the field was left empty by the user. `0` is a legal
//  filter value and is preserved; empty input is NEVER coerced to 0. See
//  `FilterViewController.bindPriceTextField(_:to:)` for the input-handling
//  contract that makes this work.
//

import Foundation

struct ProductFilter: Equatable {
    var search: String = ""
    var categoryID: Int? = nil
    var minPrice: Int? = nil   // nil == not set; 0 is a real, user-chosen value
    var maxPrice: Int? = nil
    var sortBy: ProductSort = .newest
    var page: Int = 1

    static let empty = ProductFilter()

    mutating func resetKeepingSearch() {
        let currentSearch = search
        self = ProductFilter()
        self.search = currentSearch
    }

    /// Params for `api/v1/get-product` multipart form body. Any `nil`/empty
    /// field is OMITTED — Laravel treats omitted multipart fields as absent,
    /// which is exactly what we want so the backend does not filter on them.
    func formFields() -> [String: String] {
        var fields: [String: String] = [:]
        fields["page"] = String(page)
        if !search.trimmingCharacters(in: .whitespaces).isEmpty {
            fields["search"] = search
        }
        if let c = categoryID {
            // Android sends as a comma-separated list under `category_ids`.
            fields["category_ids"] = String(c)
        }
        if let mn = minPrice {
            fields["min_price"] = String(mn)
        }
        if let mx = maxPrice {
            fields["max_price"] = String(mx)
        }
        fields["sort_by"] = sortBy.apiValue
        // Marketplace tab — Android defaults this to "marketplace" for the
        // public Explore view (non-user-specific product listings).
        fields["marketplace"] = "marketplace"
        return fields
    }
}

// MARK: - Sort options (mirrors Android's sort_by strings)

enum ProductSort: String, CaseIterable {
    case newest
    case priceLowToHigh
    case priceHighToLow
    case popular

    var apiValue: String {
        switch self {
        case .newest:           return "newest"
        case .priceLowToHigh:   return "price_low_to_high"
        case .priceHighToLow:   return "price_high_to_low"
        case .popular:          return "popular"
        }
    }

    var displayName: String {
        switch self {
        case .newest:           return "Newest"
        case .priceLowToHigh:   return "Price: Low to High"
        case .priceHighToLow:   return "Price: High to Low"
        case .popular:          return "Popular"
        }
    }
}
