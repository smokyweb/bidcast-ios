//
//  ProfileModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 02/06/25.
//

struct ProfileModel : Codable{
    var id : Int?
    var role_id : Int?
    var first_name : String?
    var last_name : String?
    var name : String?
    var username : String?
    var email : String?
    var profile_image : String?
    var bio : String?
    var follower_count : Int?
    var following_count : Int?
    var is_following : Bool?
}


struct ProductListingDataModel: Codable {
    var id, userID, categoryID: Int?
    var title, description: String?
    var quantity : Int?
    var pricing: Float?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var status: String?
    var images: [String]?
    var createdAt: String?
 
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case categoryID = "category_id"
        case title, description, quantity, pricing
        case flashSale = "flash_sale"
        case acceptOffers = "accept_offers"
        case reserveForLive = "reserve_for_live"
        case shippingProfileID = "shipping_profile_id"
        case status, images
        case createdAt = "created_at"
    }
}


struct FolloweModel : Codable{
    var status : Bool?
}
