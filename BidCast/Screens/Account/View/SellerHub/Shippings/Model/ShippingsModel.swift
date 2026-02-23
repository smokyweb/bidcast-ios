//
//  ShippingsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - StoreShippingModel
struct StoreShippingModel: Codable {
    var id: Int?
    var userID: Int?
    var name: String?
    var size: String?
    var weight: String?
    var maxItems: Bool?
    var additionalWeight: Bool?
    var length: String?
    var height: String?
    var width: String?
    var incrementWeight: String?
    var incrementWeightScale: String?
    var scale: String?
    var maxItemUnit: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case size
        case weight
        case maxItems
        case additionalWeight
        case length
        case height
        case width
        case incrementWeight = "increment_weight"
        case incrementWeightScale = "increment_weight_scale"
        case scale
        case maxItemUnit = "max_item_unit"
    }
}

struct DeleteShippingModel: Codable {
}
