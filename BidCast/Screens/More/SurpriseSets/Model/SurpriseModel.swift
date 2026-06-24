//
//  SurpriseModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/02/26.
//

import Foundation

private extension KeyedDecodingContainer {
    func decodeFlexibleIntIfPresent(forKey key: Key) -> Int? {
        if let value = try? decodeIfPresent(Int.self, forKey: key) {
            return value
        }
        if let doubleValue = try? decodeIfPresent(Double.self, forKey: key) {
            return Int(doubleValue)
        }
        if let stringValue = try? decodeIfPresent(String.self, forKey: key) {
            let normalized = stringValue
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if let intValue = Int(normalized) {
                return intValue
            }
            if let doubleValue = Double(normalized) {
                return Int(doubleValue)
            }
        }
        return nil
    }
}

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

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.decodeFlexibleIntIfPresent(forKey: .id) ?? 0
        productSetItemId = c.decodeFlexibleIntIfPresent(forKey: .productSetItemId)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        description = try? c.decodeIfPresent(String.self, forKey: .description)
        status = try? c.decodeIfPresent(String.self, forKey: .status)
        price = c.decodeFlexibleIntIfPresent(forKey: .price)
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

    init(
        id: Int,
        productSetId: Int? = nil,
        name: String? = nil,
        quantity: Int? = nil,
        soldQuantity: Int? = nil,
        description: String? = nil,
        status: String? = nil,
        units: [ProductSetUnit]? = nil
    ) {
        self.id = id
        self.productSetId = productSetId
        self.name = name
        self.quantity = quantity
        self.soldQuantity = soldQuantity
        self.description = description
        self.status = status
        self.units = units
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.decodeFlexibleIntIfPresent(forKey: .id) ?? 0
        productSetId = c.decodeFlexibleIntIfPresent(forKey: .productSetId)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        quantity = c.decodeFlexibleIntIfPresent(forKey: .quantity)
        soldQuantity = c.decodeFlexibleIntIfPresent(forKey: .soldQuantity)
        description = try? c.decodeIfPresent(String.self, forKey: .description)
        status = try? c.decodeIfPresent(String.self, forKey: .status)
        units = try? c.decodeIfPresent([ProductSetUnit].self, forKey: .units)
    }
}

struct EditProductUnitResponse: Codable {
    let id: Int
    let productSetItemId: Int
    let name: String
    let description: String
    let status: String
    let price: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case productSetItemId = "product_set_item_id"
        case name
        case description
        case status
        case price
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

    init(
        name: String? = nil,
        type: String? = nil,
        description: String? = nil,
        price: Int? = nil,
        shippingProfileId: Int? = nil,
        quickSpin: Int? = nil,
        autoRandomizer: Int? = nil,
        userId: Int? = nil,
        isLiveBid: Int? = nil,
        id: Int,
        items: [ProductItemResponse]? = nil
    ) {
        self.name = name
        self.type = type
        self.description = description
        self.price = price
        self.shippingProfileId = shippingProfileId
        self.quickSpin = quickSpin
        self.autoRandomizer = autoRandomizer
        self.userId = userId
        self.isLiveBid = isLiveBid
        self.id = id
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        type = try? c.decodeIfPresent(String.self, forKey: .type)
        description = try? c.decodeIfPresent(String.self, forKey: .description)
        price = c.decodeFlexibleIntIfPresent(forKey: .price)
        shippingProfileId = c.decodeFlexibleIntIfPresent(forKey: .shippingProfileId)
        quickSpin = c.decodeFlexibleIntIfPresent(forKey: .quickSpin)
        autoRandomizer = c.decodeFlexibleIntIfPresent(forKey: .autoRandomizer)
        userId = c.decodeFlexibleIntIfPresent(forKey: .userId)
        isLiveBid = c.decodeFlexibleIntIfPresent(forKey: .isLiveBid)
        id = c.decodeFlexibleIntIfPresent(forKey: .id) ?? 0
        items = try? c.decodeIfPresent([ProductItemResponse].self, forKey: .items)
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

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, type
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.decodeFlexibleIntIfPresent(forKey: .id)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        description = try? c.decodeIfPresent(String.self, forKey: .description)
        price = c.decodeFlexibleIntIfPresent(forKey: .price)
        type = try? c.decodeIfPresent(String.self, forKey: .type)
    }
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
