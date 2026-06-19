//
//  ShowsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

private func decodeStringArrayFlexible<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) throws -> [String]? {
    if let values = try? c.decodeIfPresent([String].self, forKey: key) { return values }
    if let values = try? c.decodeIfPresent([Int].self, forKey: key) { return values.map(String.init) }
    if let values = try? c.decodeIfPresent([Double].self, forKey: key) {
        return values.map { value in
            value.rounded() == value ? String(Int(value)) : String(value)
        }
    }
    if let value = try? c.decodeIfPresent(String.self, forKey: key) {
        return value
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    return nil
}

private func decodeBoolFlexible<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) throws -> Bool? {
    if let value = try? c.decodeIfPresent(Bool.self, forKey: key) { return value }
    if let value = try? c.decodeIfPresent(Int.self, forKey: key) { return value != 0 }
    if let value = try? c.decodeIfPresent(Double.self, forKey: key) { return value != 0 }
    if let value = try? c.decodeIfPresent(String.self, forKey: key) {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if ["1", "true", "yes", "y", "live"].contains(normalized) { return true }
        if ["0", "false", "no", "n", "ended", "inactive"].contains(normalized) { return false }
    }
    return nil
}


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

        enum CodingKeys: String, CodingKey {
            case id, title, date, time, user_id, category_id, product_ids, auction_type_id
            case thumbnail, img_thumbnail, is_live, viewer_count, products, bid_won_user
            case highest_bid, user, category
        }

        init(
            id: Int? = nil,
            title: String? = nil,
            date: String? = nil,
            time: String? = nil,
            user_id: Int? = nil,
            category_id: Int? = nil,
            product_ids: [String]? = nil,
            auction_type_id: Int? = nil,
            thumbnail: [String]? = nil,
            img_thumbnail: [String]? = nil,
            is_live: Bool? = nil,
            viewer_count: Int? = nil,
            products: [ProductModelData]? = nil,
            bid_won_user: String? = nil,
            highest_bid: String? = nil,
            user: User? = nil,
            category: Category? = nil
        ) {
            self.id = id
            self.title = title
            self.date = date
            self.time = time
            self.user_id = user_id
            self.category_id = category_id
            self.product_ids = product_ids
            self.auction_type_id = auction_type_id
            self.thumbnail = thumbnail
            self.img_thumbnail = img_thumbnail
            self.is_live = is_live
            self.viewer_count = viewer_count
            self.products = products
            self.bid_won_user = bid_won_user
            self.highest_bid = highest_bid
            self.user = user
            self.category = category
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            id = try c.decodeIfPresent(Int.self, forKey: .id)
            title = try c.decodeIfPresent(String.self, forKey: .title)
            date = try c.decodeIfPresent(String.self, forKey: .date)
            time = try c.decodeIfPresent(String.self, forKey: .time)
            user_id = try c.decodeIfPresent(Int.self, forKey: .user_id)
            category_id = try c.decodeIfPresent(Int.self, forKey: .category_id)
            product_ids = try decodeStringArrayFlexible(c, forKey: .product_ids)
            auction_type_id = try c.decodeIfPresent(Int.self, forKey: .auction_type_id)
            thumbnail = try c.decodeIfPresent([String].self, forKey: .thumbnail)
            img_thumbnail = try c.decodeIfPresent([String].self, forKey: .img_thumbnail)
            is_live = try decodeBoolFlexible(c, forKey: .is_live)
            viewer_count = try c.decodeIfPresent(Int.self, forKey: .viewer_count)
            products = try c.decodeIfPresent([ProductModelData].self, forKey: .products)
            bid_won_user = try c.decodeIfPresent(String.self, forKey: .bid_won_user)
            highest_bid = try c.decodeIfPresent(String.self, forKey: .highest_bid)
            user = try c.decodeIfPresent(User.self, forKey: .user)
            category = try c.decodeIfPresent(Category.self, forKey: .category)
        }
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
