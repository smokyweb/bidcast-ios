//
//  InventoryModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - InventoryModel
struct InventoryModel: Codable {
    var status, message, errorType: String?
    var data: [InventoryDataModel]?
    var total, totalPage, currentPage, perPage: Int?
}


// MARK: - InventoryDataModel
struct InventoryDataModel: Codable {
    var id, categoryID: Int?
    var title, description: String?
    var quantity, pricing: Int?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var status: String?
    var images: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case categoryID = "category_id"
        case title, description, quantity, pricing
        case flashSale = "flash_sale"
        case acceptOffers = "accept_offers"
        case reserveForLive = "reserve_for_live"
        case shippingProfileID = "shipping_profile_id"
        case status, images
    }
}
