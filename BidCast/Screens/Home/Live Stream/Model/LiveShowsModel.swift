//
//  LiveShowsModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 02/06/25.
//

import Foundation


struct LiveShowsModel: Codable,Identifiable {
    var id: Int?
    var title: String?
    var date: String?
    var time: String?
    var user_id: Int?
    var category_id: Int?
    var product_ids: [String]?
    var room_id : String?
    var auction_type_id: Int?
    var thumbnail: [String]?
    var img_thumbnail : [String]?
    var is_live : Bool?
    var category: Category?
    var user: User?
    var viewer_count : Int?
    var product : ProductData?
    var seller : SellerModel?
}

// MARK: - Category
struct Category: Codable {
    var id: Int?
    var name: String?
    var image: String?
    var thumbnail: String?
    var extraFields: [ExtraFieldModel]?
    var color: String?

    enum CodingKeys: String, CodingKey {
        case id, name, image, thumbnail
        case extraFields = "extra_fields"
        case color
    }
}

struct User: Codable,Identifiable {
    var id: Int?
    var role_id: Int?
    var first_name: String?
    var last_name: String?
    var name: String?
    var username: String?
    var email: String?
    var profile_image: String?
    var thumbnail: String?
    var bio: String?
    var is_active: Bool?
    var referral_code: String?
    var rating: String?
    var is_followed: Bool?
}

struct BiddingModel: Codable,Identifiable {
    var id: Int?
    var title: String?
    var date: String?
    var time: String?
    var user_id: Int?
    var category_id: Int?
    var room_id : String?
    var auction_type_id: Int?
    var is_live : Bool?
    var category: Category?
    var user: User?
    var viewer_count : Int?
    var products : [ProductData]?
    var seller : SellerModel?
}

struct countModel : Codable {
    var status : String?
    var viewer_count : Int?
}

struct BidModel : Codable {
    var schedule_show_id : Int?
    var user_id : Int?
    var bid_price : Double?
    var product_id :Int?
    var created_by : Int?
    var created_at : String?
    var id : Int?
}
