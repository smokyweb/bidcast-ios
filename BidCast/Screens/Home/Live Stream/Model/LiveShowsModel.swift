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
    var deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, image, thumbnail
        case extraFields = "extra_fields"
        case color
        case deletedAt = "deleted_at"
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

// MARK: - StorePromoteShowModel
struct StorePromoteShowModel: Codable {
    var id: Int?
    var title, date, time: String?
    var userID, categoryID: Int?
    var productIDS: [String]?
    var auctionTypeID: Int?
    var thumbnail, imgThumbnail: [String]?
    var isLive: Bool?
    var promoteShowID, viewerCount, latestViewerCount: Int?
    var promotedAt, startedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, date, time
        case userID = "user_id"
        case categoryID = "category_id"
        case productIDS = "product_ids"
        case auctionTypeID = "auction_type_id"
        case thumbnail
        case imgThumbnail = "img_thumbnail"
        case isLive = "is_live"
        case promoteShowID = "promote_show_id"
        case viewerCount = "viewer_count"
        case latestViewerCount = "latest_viewer_count"
        case promotedAt = "promoted_at"
        case startedAt = "started_at"
    }
}

struct SellerUserModel : Codable {
    var id : Int?
    var name : String?
    var email : String?
    var profile_image : String?
    var room_id : String?
}


struct SellerInfoResponse: Codable {
    var seller_details: SellerDetails?
    var rating_avg: Double?
    var sold_count: Int?
    var review: String?
    var avg_ship: String?
    var is_following: Bool?
}

struct SellerDetails: Codable {
    var id: Int
    var role_id: Int?
    var first_name: String?
    var last_name: String?
    var name: String?
    var username: String?
    var email: String?
    var marketplace_vendor_status: String?
    var live_sell_vendor_status: String?
    var authorize_net_cid: String?
    var profile_image: String?
    var thumbnail: String?
    var bio: String?
    var jwt_token: String?
    var is_active: Bool?
    var profile_visits: Int?
    var is_FirsttimeLogin: Bool?
    var default_card_id: String?
    var referral_code: String?
}

// MARK: - Datum
struct SellerCategoryDetailsModel: Codable {
    var id: Int?
    var name, description, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


// MARK: - GetShowOverviewModel
struct GetShowOverviewModel: Codable {
    var orderCount : Int?
    var videoDuration, totalSales: String?
    var shareCount, viewerCount, newFollowers : Int?
    var contributionsCount : String?
    var totalBids: Int?
    var fileURL: String?

    enum CodingKeys: String, CodingKey {
        case orderCount = "order_count"
        case totalSales = "total_sales"
        case videoDuration = "video_duration"
        case shareCount = "share_count"
        case viewerCount = "viewer_count"
        case newFollowers = "new_followers"
        case contributionsCount = "contributions_count"
        case totalBids = "total_bids"
        case fileURL = "file_url"
    }
}


// MARK: - GetShowOverviewModel
struct ShowOverviewModel: Codable {
    var orderCount: Int = 0
    var totalSales: String = ""
    var videoDuration: String = ""
    var shareCount: Int = 0
    var viewerCount: Int = 0
    var newFollowers: Int = 0
    var contributionsCount: Int = 0
    var totalBids: Int = 0

    enum CodingKeys: String, CodingKey {
        case orderCount
        case totalSales
        case videoDuration
        case shareCount
        case viewerCount
        case newFollowers
        case contributionsCount
        case totalBids
    }
}
