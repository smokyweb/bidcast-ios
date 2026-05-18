//
//  SearchModels.swift
//  BidCast
//
//  Created by Larry Difficult Task Agent on 2026-05-17.
//

import Foundation

struct SearchResponse: Codable {
    let status: String
    let message: String
    let data: SearchData?
}

struct SearchData: Codable {
    let shows: [SearchShow]
    let products: [SearchProduct]
    let users: [SearchUserItem]
}

struct SearchShow: Codable, Identifiable {
    let id: Int
    let title: String
    let date: String
    let time: String
    let thumbnail: [String]
    let img_thumbnail: [String]
    let user: SearchUserItem?
}

struct SearchProduct: Codable, Identifiable {
    let id: Int
    let title: String
    let pricing: String
    let thumbnail: [String]
    let images: [String]
    let user: SearchUserItem?
}

struct SearchUserItem: Codable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let profile_image: String?
}
