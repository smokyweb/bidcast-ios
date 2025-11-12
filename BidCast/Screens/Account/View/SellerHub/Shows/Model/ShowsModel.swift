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
        var quantity: String?
        var purchased_quantity: Int?
        var pricing: String?
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

    
struct ProductData : Codable, Equatable {
    var category: String?
    var id: String?
    var image: String?
    var name: String?
    var price: String?
    var status : String?
    var isCurrent: Bool
    var quantity: String?
    
    func toDictionary() -> [String: Any] {
            return [
                "id": id,
                "category": category,
                "image": image, 
                "name": name,
                "price": price,
                "status":status,
                "is_current" : isCurrent,
                "quantity" : quantity
            ]
        }
    enum CodingKeys: String, CodingKey {
           case category
           case id
           case image
           case name
           case price
           case status
           case isCurrent = "is_current"
           case quantity
       }
}

extension ProductData {
    static let example = ProductData(
        category: "Sports & Lifestyle",
        id: "001",
        image: "https://via.placeholder.com/80",
        name: "Football",
        price: "29.99",
        status: "Available",
        isCurrent: true,
        quantity: "10"
    )
}

struct SellerModel : Codable {
    var isFollowed: Bool?
    var id: String?
    var name: String?
    var rating: String?
    var image : String?
    
    func toDictionary() -> [String: Any] {
        return [
            "isFollowed": isFollowed,
            "id": id,
            "name": name,
            "rating": rating,
            "image":image
        ]
    }
    
}

struct BoostModel : Codable {
    var id: Int?
    var title: String?
    var sub_title: String?
    var description: String?
    var price: String?
    var gradient_colors: String?
    var icon: String?
    var colors: Colors?
    var action: (() -> Void)?
    
    enum CodingKeys: String, CodingKey {
           case id, title, sub_title, description, price, gradient_colors, icon, colors
       }
}

struct Colors: Codable {
    var start: String?
    var end: String?
}
