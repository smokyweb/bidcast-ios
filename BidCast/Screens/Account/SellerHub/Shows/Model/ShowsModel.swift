//
//  ShowsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation



struct UpdateStatusModel : Codable {
        var id: Int?
        var title: String?
        var date: String?
        var time: String?
        var user_id: Int?
        var category_id: Int?
        var product_ids: [String]?
        var auction_type_id: Int?
        var thumbnail: [String]?
        var img_thumbnail: [String]?
        var is_live: Bool?
        var viewer_count: Int?
        var products: [ProductModelData]?
        var bid_won_user: String?
        var highest_bid: String?
        var user: User?
        var category: Category?
    }

    struct ProductModelData: Codable {
        var id: Int?
        var user_id: Int?
        var category_id: Int?
        var title: String?
        var description: String?
        var quantity: Int?
        var purchased_quantity: Int?
        var pricing: Double?
        var flash_sale: Bool?
        var accept_offers: Bool?
        var reserve_for_live: Bool?
        var shipping_profile_id: Int?
        var status: String?
        var product_show: String?
        var images: [String]?
        var thumbnail: [String]?
        var created_at: String?
    }

    
struct ProductData {
    let category: String
    let id: String
    let image: String
    let name: String
    let price: String
    
    func toDictionary() -> [String: Any] {
        return [
            "category": category,
            "id": id,
            "image": image,
            "name": name,
            "price": price
        ]
    }
}

struct SellerModel {
    let followed: Bool
    let id: String
    let name: String
    let rating: String
    
    func toDictionary() -> [String: Any] {
        return [
            "followed": followed,
            "id": id,
            "name": name,
            "rating": rating
        ]
    }
}
