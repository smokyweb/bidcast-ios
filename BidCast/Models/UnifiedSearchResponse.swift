//
//  UnifiedSearchResponse.swift
//  BidCast
//
//  Created by Larry Difficult Task Agent on 2026-05-18.
//

import Foundation

// MARK: - UnifiedSearchResponse
struct UnifiedSearchResponse: Codable {
    let status: String
    let message: String
    let data: SearchData
}

// MARK: - SearchData
struct SearchData: Codable {
    let shows: [Show]
    let products: [Product]
    let users: [User]
}

// MARK: - Show (simplified for search results)
struct Show: Codable, Identifiable {
    let id: Int
    let title: String
    let date: String?
    let time: String?
    let thumbnail: [String]?
    let user: User?
    
    // Using CodingKeys to handle potential name mismatches if any
    enum CodingKeys: String, CodingKey {
        case id, title, date, time, thumbnail, user
    }
}

// MARK: - Product (simplified for search results)
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let pricing: String
    let thumbnail: [String]?
    let images: [String]?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case id, title, pricing, thumbnail, images, user
    }
}

// MARK: - User (simplified for search results)
struct User: Codable, Identifiable {
    let id: Int
    let name: String?
    let username: String?
    let profile_image: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, username, profile_image
    }
}
