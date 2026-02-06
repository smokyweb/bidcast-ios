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


struct AuctionStartedBreakSpotResponse: Codable {
    var status: String?
    var suddenDeath: Bool?
    var auctionStartedAt: String?
    var productSetItemId: Int?
    var productSetId: Int?
    var startingBidAmount: Int?
    var requireTime: Int?
    var roomId: String?
    var productSetItemUnitId: Int?
    var counterBidTime: Int?
    var surpriseSetDetails: SurpriseSetDetails?

    enum CodingKeys: String, CodingKey {
        case status
        case suddenDeath = "sudden_death"
        case auctionStartedAt = "auction_started_at"
        case productSetItemId
        case productSetId
        case startingBidAmount = "starting_bid_amount"
        case requireTime = "require_time"
        case roomId = "room_id"
        case productSetItemUnitId
        case counterBidTime = "counter_bid_time"
        case surpriseSetDetails = "surprise_set_details"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        status = try? container.decode(String.self, forKey: .status)
        auctionStartedAt = try? container.decode(String.self, forKey: .auctionStartedAt)
        productSetItemId = try? container.decode(Int.self, forKey: .productSetItemId)
        productSetId = try? container.decode(Int.self, forKey: .productSetId)
        startingBidAmount = try? container.decode(Int.self, forKey: .startingBidAmount)
        requireTime = try? container.decode(Int.self, forKey: .requireTime)
        roomId = try? container.decode(String.self, forKey: .roomId)
        productSetItemUnitId = try? container.decode(Int.self, forKey: .productSetItemUnitId)
        counterBidTime = try? container.decode(Int.self, forKey: .counterBidTime)
        surpriseSetDetails = try? container.decode(SurpriseSetDetails.self, forKey: .surpriseSetDetails)

        // ✅ Handle sudden_death as Bool or Int
        if let boolValue = try? container.decode(Bool.self, forKey: .suddenDeath) {
            suddenDeath = boolValue
        } else if let intValue = try? container.decode(Int.self, forKey: .suddenDeath) {
            suddenDeath = intValue == 1
        } else {
            suddenDeath = nil
        }
    }
}
struct SurpriseSetDetails: Codable {
    var productSet: ProductSet?
    var productSetItem: ProductSetItem?
    var soldQuantity: Int?
    var totalQuantity: Int?

    enum CodingKeys: String, CodingKey {
        case productSet = "product_set"
        case productSetItem = "product_set_item"
        case soldQuantity = "sold_quantity"
        case totalQuantity = "total_quantity"
    }
}

struct ProductSet: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var price: Int?
    var type: String?
}

struct ProductSetItem: Codable {
    var id: Int?
    var name: String?
    var description: String?
    var quantity: Int?
    var soldQuantity: Int?
    var status: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, quantity, status
        case soldQuantity = "sold_quantity"
    }
}
