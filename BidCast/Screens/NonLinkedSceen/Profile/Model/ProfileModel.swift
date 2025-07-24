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
    var is_FirstShowCreated : Bool?
    var seller_identity_status : String?
    var buyer_identity_status : String?
    var is_active : Bool?
    var has_shipping_address : Bool?
    var has_card_added : Bool?
    var role : RoleModel?
    var default_shipping_address : AddressModel?
    var default_card : CardModel?
    
}


struct RoleModel : Codable {
    var created_at : String?
    var id : Int?
    var name : String?
    var updated_at : String?
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

// MARK: - GetMyScheduleShow
struct GetMyScheduleShowModel : Codable {
    var id: Int?
    var title, date, time: String?
    var userID, categoryID: Int?
    var productIDS: [String]?
    var auctionTypeID: Int?
    var thumbnail: [String]?
    var imgThumbnail: [String]?
    var isLive: Bool?
    var viewerCount, latestViewerCount: Int?
    var category: Category?
    var user: User?

    enum CodingKeys: String, CodingKey {
        case id, title, date, time
        case userID = "user_id"
        case categoryID = "category_id"
        case productIDS = "product_ids"
        case auctionTypeID = "auction_type_id"
        case thumbnail
        case imgThumbnail = "img_thumbnail"
        case isLive = "is_live"
        case viewerCount = "viewer_count"
        case latestViewerCount = "latest_viewer_count"
        case category, user
    }
}

// MARK: - TotalRating
struct TotalRating: Codable {
    var totalReviews: Int?
    var ratings: [RatingDetail]?

    enum CodingKeys: String, CodingKey {
        case totalReviews = "total_reviews"
        case ratings
    }
}

// MARK: - RatingDetail
struct RatingDetail: Codable {
    var id, userID, sellerID: Int?
    var overallRating, shippingRating, packagingRating, accuracyRating: String?
    var comment, createdAt, updatedAt: String?
    var user: User

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case sellerID = "seller_id"
        case overallRating = "overall_rating"
        case shippingRating = "shipping_rating"
        case packagingRating = "packaging_rating"
        case accuracyRating = "accuracy_rating"
        case comment
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case user
    }
}

// MARK: - AddRatigModel
struct AddRatigModel: Codable {
    var id, userID, sellerID: Int?
    var overallRating, shippingRating, packagingRating, accuracyRating: Double?
    var comment, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case sellerID = "seller_id"
        case overallRating = "overall_rating"
        case shippingRating = "shipping_rating"
        case packagingRating = "packaging_rating"
        case accuracyRating = "accuracy_rating"
        case comment
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}





