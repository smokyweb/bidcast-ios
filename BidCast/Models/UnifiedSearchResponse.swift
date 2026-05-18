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
