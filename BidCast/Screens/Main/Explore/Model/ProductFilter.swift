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
    /// P2.15 — optional sub-category drill-down. `nil` means "all sub-categories
    /// under the selected category"; a non-nil value maps to Android's
    /// `sub_category_ids` multipart field on `v1/get-product`.
    var subCategoryID: Int? = nil
    var minPrice: Int? = nil   // nil == not set; 0 is a real, user-chosen value
    var maxPrice: Int? = nil
    var sortBy: ProductSort = .newest
    /// P2.15 — Explore type tab. Mirrors Android's `type` query param on
    /// `get-category`: "all" (default), "recommended", or "popular".
    var exploreType: ExploreType = .all
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
        if let sc = subCategoryID {
            fields["sub_category_ids"] = String(sc)
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
        // P2.15 — Explore type tab. Omit for "all" to mirror Android: their
        // "All" tab passes no `type` (it posts only "all" to get-category
        // for the rail refresh but doesn't include it on v1/get-product).
        // We send it for completeness so backend teams can filter later.
        if exploreType != .all {
            fields["type"] = exploreType.rawValue
        }
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

// MARK: - Explore type tabs (P2.15)

/// Mirrors Android's `type` query parameter on `get-category`. The
/// backend uses this to gate the product list (recommended = curated,
/// popular = trending). Sent as a form field on `v1/get-product` calls
/// through `ProductFilter.formFields()`.
enum ExploreType: String, CaseIterable {
    case all        = "all"
    case recommended = "recommended"
    case popular    = "popular"

    var displayName: String {
        switch self {
        case .all:          return "All"
        case .recommended:  return "Recommended"
        case .popular:      return "Popular"
        }
    }
}
