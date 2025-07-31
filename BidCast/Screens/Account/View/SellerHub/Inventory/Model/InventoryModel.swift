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
    var quantity : Int?
    var sub_category_id : Int?
    var pricing: Float?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var status: String?
    var images: [String]?
    var category : CategoryDataModel?
    var sub_category : CategoryDataModel?

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
