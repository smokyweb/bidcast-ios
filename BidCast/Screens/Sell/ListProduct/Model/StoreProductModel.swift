//
//  StoreProductModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 19/05/25.
//

import Foundation

//struct StoreProductModel : Codable {
//    var category_id : Int?
//    var title : String?
//    var description : String?
//    var quantity : Int?
//    var pricing : Int?
//    var flash_sale : Bool? = false
//    var accept_offers : Bool? = false
//    var reserve_for_live : Bool? = false
//    var shipping_profile_id : Int?
//    var status : String?
//    var images : [String]?
//    var id : Int?
//}


// MARK: - StoreProductModel
struct StoreProductModel: Codable {
    var description: String?
    var quantity, id: Int?
    var flashSale: Bool?
    var shippingProfileID, categoryID: Int?
    var createdAt: String?
    var pricing: Double?
    var userID: Int?
    var acceptOffers: Bool?
    var title: String?
    var reserveForLive: Bool?
    var images: [String]?
    var thumbnail: [String]?
    var status: String?

    enum CodingKeys: String, CodingKey {
        case description, quantity, id
        case flashSale = "flash_sale"
        case shippingProfileID = "shipping_profile_id"
        case categoryID = "category_id"
        case createdAt = "created_at"
        case pricing
        case userID = "user_id"
        case acceptOffers = "accept_offers"
        case title
        case reserveForLive = "reserve_for_live"
        case images, thumbnail, status
    }
}

struct ImageModel : Codable {
    var images : String?
    var thumbnail: String?
}
