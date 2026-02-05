//
//  SurpriseModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/02/26.
//

import Foundation

struct SurpriseRequest: Encodable {
    var name: String
    var type: String
    var description: String
    var price: String
    var shippingProfileId: Int
    var quickSpin: Int
    var autoRandomizer: Int
    var items: [ProductItem]

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case description
        case price
        case shippingProfileId = "shipping_profile_id"
        case quickSpin = "quick_spin"
        case autoRandomizer = "auto_randomizer"
        case items
    }
}

struct ProductItem: Encodable {
    var name: String
    var quantity: Int
    var description: String
}

// MARK: - Product Set Unit (Individual unit within an item)
struct ProductSetUnit: Codable {
    var id: Int
    var productSetItemId: Int?
    var name: String?
    var description: String?
    var status: String?
    var price: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case productSetItemId = "product_set_item_id"
        case name
        case description
        case status
        case price
    }
}

// MARK: - Product Item Response (Updated)
struct ProductItemResponse: Codable {
    var id: Int
    var productSetId: Int?
    var name: String?
    var quantity: Int?
    var soldQuantity: Int?
    var description: String?
    var status: String?
    var units: [ProductSetUnit]?

    enum CodingKeys: String, CodingKey {
        case id
        case productSetId = "product_set_id"
        case name
        case quantity
        case soldQuantity = "sold_quantity"
        case description
        case status
        case units
    }
}

// MARK: - Product Surprise Data (Updated)
struct ProductSurpriseData: Codable {
    var name: String?
    var type: String?
    var description: String?
    var price: Int?
    var shippingProfileId: Int?
    var quickSpin: Int?
    var autoRandomizer: Int?
    var userId: Int?
    var isLiveBid: Int?
    var id: Int
    var items: [ProductItemResponse]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case type
        case description
        case price
        case shippingProfileId = "shipping_profile_id"
        case quickSpin = "quick_spin"
        case autoRandomizer = "auto_randomizer"
        case userId = "user_id"
        case isLiveBid = "is_live_bid"
        case id
        case items
    }
    
}
