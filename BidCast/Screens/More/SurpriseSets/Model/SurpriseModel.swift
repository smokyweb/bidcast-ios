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
    var price: String? = nil
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

struct ProductSurpriseData: Codable {
    var name: String?
    var type: String?
    var description: String?
    var price: Int?
    var shippingProfileId: Int?
    var quickSpin: Int?
    var autoRandomizer: Int?
    var userId: Int?
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
        case id
        case items
    }
}

struct ProductItemResponse: Codable {
    var id: Int
    var productSurpriseId: Int?
    var name: String?
    var quantity: Int?
    var description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case productSurpriseId = "product_surprise_id"
        case name
        case quantity
        case description
    }
}
