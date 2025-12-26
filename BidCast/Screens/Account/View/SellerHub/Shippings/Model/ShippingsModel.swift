//
//  ShippingsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - StoreShippingModel
struct StoreShippingModel: Codable {
    var userID: Int?
    var name, size: String?
    var weight: String?
    var id: Int?
    var additionalWeight: Bool?
    var maxItems: Bool?

    enum CodingKeys: String, CodingKey {
        case userID
        case name, size, weight, id
        case additionalWeight, maxItems
    }
}
