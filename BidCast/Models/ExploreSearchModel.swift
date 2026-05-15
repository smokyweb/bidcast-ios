//
//  ExploreSearchModel.swift
//  BidCast
//
//  Created for MC task cmp5w1v7i019qm61hhld1uiul on 2026-05-15.
//
//  Response model for `POST /api/explore-search` — unified explore search
//  across scheduled shows, products, and usernames.
//

import Foundation

struct ExploreSearchData: Codable {
    var shows: [ExploreSearchShow]?
    var products: [ExploreSearchProduct]?
    var users: [ExploreSearchUser]?
}

struct ExploreSearchShow: Codable, Identifiable {
    var id: Int?
    var title: String?
    var thumbnail: [String]?
    var is_live: Int?
    var show_discoverability: String?
    var user_id: Int?
    var user: ExploreSearchShowUser?
}

struct ExploreSearchShowUser: Codable {
    var id: Int?
    var name: String?
    var username: String?
    var profile_image: String?
}

struct ExploreSearchProduct: Codable, Identifiable {
    var id: Int?
    var name: String?
    var price: Double?
    var image: String?
    var user: ExploreSearchProductUser?
}

struct ExploreSearchProductUser: Codable {
    var id: Int?
    var name: String?
}

struct ExploreSearchUser: Codable, Identifiable {
    var id: Int?
    var name: String?
    var username: String?
    var profile_image: String?
}
