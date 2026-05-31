//
//  UnifiedSearchResponse.swift
//  BidCast
//

import Foundation

// MARK: - UnifiedSearchResponse
struct UnifiedSearchResponse: Codable {
    let status: String
    let message: String
    let data: SearchResultData?
}

// MARK: - SearchResultData
struct SearchResultData: Codable {
    let shows: [SearchResultShow]
    let products: [SearchResultProduct]
    let users: [SearchResultUser]
    // Trey QA 2026-05-31: numbered pager — backend returns pagination alongside results.
    // Shape verified against LIVE POST /api/v1/search 2026-05-31.
    let pagination: SearchPagination?
}

// MARK: - SearchPagination (from POST /api/v1/search response)
// Live shape: { page, per_page, shows:{total,last_page}, products:{total,last_page}, users:{total,last_page} }
struct SearchPagination: Codable {
    let page: Int
    let perPage: Int
    let shows: SearchSectionPagination
    let products: SearchSectionPagination
    let users: SearchSectionPagination

    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case shows, products, users
    }
}

struct SearchSectionPagination: Codable {
    let total: Int
    let lastPage: Int

    enum CodingKeys: String, CodingKey {
        case total
        case lastPage = "last_page"
    }
}

// MARK: - SearchResultShow
struct SearchResultShow: Codable, Identifiable {
    let id: Int
    let title: String
    let date: String?
    let time: String?
    let thumbnail: [String]?
    let user: SearchResultUser?
}

// MARK: - SearchResultProduct
struct SearchResultProduct: Codable, Identifiable {
    let id: Int
    let title: String
    let pricing: String?
    let thumbnail: [String]?
    let images: [String]?
    let user: SearchResultUser?
}

// MARK: - SearchResultUser
struct SearchResultUser: Codable, Identifiable {
    let id: Int
    let name: String?
    let username: String?
    let profile_image: String?
}
