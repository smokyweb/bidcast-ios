//
//  LiveShowsModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 02/06/25.
//

import Foundation

// MC sub-task cmp49331h00l33mx1cc9a8vqf / cmp4936yl00m93mx1pjyhcegi:
// Android-side payloads sometimes serialise bool flags as 0/1 ints instead of
// JSON booleans. Swift's synthesised Codable init rejects that shape. Decode
// both representations so coming-soon / live-show payloads from Android sellers
// don't fail the entire response on iOS_Staging_V1.
private func decodeBoolFlexible<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) throws -> Bool? {
    if let b = try? c.decodeIfPresent(Bool.self, forKey: key) { return b }
    if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return i != 0 }
    if let s = try? c.decodeIfPresent(String.self, forKey: key) {
        let v = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if ["1", "true", "yes"].contains(v) { return true }
        if ["0", "false", "no"].contains(v) { return false }
    }
    return nil
}

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

struct SavedModel : Codable{
    var is_saved : Bool?
}

extension LiveShowsModel {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        date = try c.decodeIfPresent(String.self, forKey: .date)
        time = try c.decodeIfPresent(String.self, forKey: .time)
        user_id = try c.decodeIfPresent(Int.self, forKey: .user_id)
        category_id = try c.decodeIfPresent(Int.self, forKey: .category_id)
        product_ids = try c.decodeIfPresent([String].self, forKey: .product_ids)
        room_id = try c.decodeIfPresent(String.self, forKey: .room_id)
        auction_type_id = try c.decodeIfPresent(Int.self, forKey: .auction_type_id)
        thumbnail = try c.decodeIfPresent([String].self, forKey: .thumbnail)
        img_thumbnail = try c.decodeIfPresent([String].self, forKey: .img_thumbnail)
        is_live = try decodeBoolFlexible(c, forKey: .is_live)
        category = try c.decodeIfPresent(Category.self, forKey: .category)
        user = try c.decodeIfPresent(User.self, forKey: .user)
        viewer_count = try c.decodeIfPresent(Int.self, forKey: .viewer_count)
        product = try c.decodeIfPresent(ProductData.self, forKey: .product)
        seller = try c.decodeIfPresent(SellerModel.self, forKey: .seller)
    }
}

extension BiddingModel {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        date = try c.decodeIfPresent(String.self, forKey: .date)
        time = try c.decodeIfPresent(String.self, forKey: .time)
        user_id = try c.decodeIfPresent(Int.self, forKey: .user_id)
        category_id = try c.decodeIfPresent(Int.self, forKey: .category_id)
        room_id = try c.decodeIfPresent(String.self, forKey: .room_id)
        auction_type_id = try c.decodeIfPresent(Int.self, forKey: .auction_type_id)
        is_live = try decodeBoolFlexible(c, forKey: .is_live)
        category = try c.decodeIfPresent(Category.self, forKey: .category)
        user = try c.decodeIfPresent(User.self, forKey: .user)
        viewer_count = try c.decodeIfPresent(Int.self, forKey: .viewer_count)
        products = try c.decodeIfPresent([ProductData].self, forKey: .products)
        seller = try c.decodeIfPresent(SellerModel.self, forKey: .seller)
    }
}

extension StorePromoteShowModel {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        date = try c.decodeIfPresent(String.self, forKey: .date)
        time = try c.decodeIfPresent(String.self, forKey: .time)
        userID = try c.decodeIfPresent(Int.self, forKey: .userID)
        categoryID = try c.decodeIfPresent(Int.self, forKey: .categoryID)
        productIDS = try c.decodeIfPresent([String].self, forKey: .productIDS)
        auctionTypeID = try c.decodeIfPresent(Int.self, forKey: .auctionTypeID)
        thumbnail = try c.decodeIfPresent([String].self, forKey: .thumbnail)
        imgThumbnail = try c.decodeIfPresent([String].self, forKey: .imgThumbnail)
        isLive = try decodeBoolFlexible(c, forKey: .isLive)
        promoteShowID = try c.decodeIfPresent(Int.self, forKey: .promoteShowID)
        viewerCount = try c.decodeIfPresent(Int.self, forKey: .viewerCount)
        latestViewerCount = try c.decodeIfPresent(Int.self, forKey: .latestViewerCount)
        promotedAt = try c.decodeIfPresent(String.self, forKey: .promotedAt)
        startedAt = try c.decodeIfPresent(String.self, forKey: .startedAt)
    }
}

extension User {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        role_id = try c.decodeIfPresent(Int.self, forKey: .role_id)
        first_name = try c.decodeIfPresent(String.self, forKey: .first_name)
        last_name = try c.decodeIfPresent(String.self, forKey: .last_name)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        username = try c.decodeIfPresent(String.self, forKey: .username)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        profile_image = try c.decodeIfPresent(String.self, forKey: .profile_image)
        thumbnail = try c.decodeIfPresent(String.self, forKey: .thumbnail)
        bio = try c.decodeIfPresent(String.self, forKey: .bio)
        is_active = try decodeBoolFlexible(c, forKey: .is_active)
        referral_code = try c.decodeIfPresent(String.self, forKey: .referral_code)
        rating = try c.decodeIfPresent(String.self, forKey: .rating)
        is_followed = try decodeBoolFlexible(c, forKey: .is_followed)
    }
}
