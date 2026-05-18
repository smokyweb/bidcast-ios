//
//  LiveShowsModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 02/06/25.
//

import Foundation

// MC build-fix (parent cmp495j7i00md3mx1pjv9qjq1): the HomeModel extension
// below uses decodeBoolFlexible. Codemagic build 249 failed because the
// helper was declared `private` in LiveShowsModel.swift only, so it wasn't
// visible across files. Each consumer file declares its own private copy.
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

struct HomeModel: Codable, Identifiable {
    var id: Int?
    var title: String?
    var date: String?
    var time: String?
    var language: String?
    var repeat_value: String?
    var is_repeat: Bool?
    var is_explicit: Bool?
    var user_id: Int?
    var show_discoverability: String?
    var category_id: Int?
    var product_ids: [String]?
    var auction_type_id: Int?
    var thumbnail: [String]?
    var products : [ProductDataModel1]?
    var img_thumbnail: [String]?
    var is_live: Bool?
    var viewer_count: Int?
    var latest_viewer_count: Int?
    var promoted_at: String?
    var rtc_token: String?
    var promote_show_id: Int?
    var started_at: String?
    var share_count: Int?
    var recording_resource_id: String?
    var recording_sid: String?
    var room_id: String?
    var category: Category?
    var user: User?
    var auction : AuctionData?
    var sub_category_id: Int?
    var is_promote: String?
    var is_promoted: Bool?
    var promotion_start_at: String?
    var promotion_end_at: String?
    var sub_category: SubCategoryDataModel?
    // MC wave-2 #26: show duration for past shows (mapped from video_duration)
    var video_duration: String?
}

struct AuctionData : Codable {
    var id : Int?
    var name : String?
}

struct ClipModel: Codable {
    var id: Int?
    var clipURL: String?
    var userID: Int?
    var showID: String?

    enum CodingKeys: String, CodingKey {
        case id
        case clipURL = "clip_url"
        case userID = "user_id"
        case showID = "show_id"
    }
}

extension HomeModel {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        date = try c.decodeIfPresent(String.self, forKey: .date)
        time = try c.decodeIfPresent(String.self, forKey: .time)
        language = try c.decodeIfPresent(String.self, forKey: .language)
        repeat_value = try c.decodeIfPresent(String.self, forKey: .repeat_value)
        is_repeat = try decodeBoolFlexible(c, forKey: .is_repeat)
        is_explicit = try decodeBoolFlexible(c, forKey: .is_explicit)
        user_id = try c.decodeIfPresent(Int.self, forKey: .user_id)
        show_discoverability = try c.decodeIfPresent(String.self, forKey: .show_discoverability)
        category_id = try c.decodeIfPresent(Int.self, forKey: .category_id)
        product_ids = try c.decodeIfPresent([String].self, forKey: .product_ids)
        auction_type_id = try c.decodeIfPresent(Int.self, forKey: .auction_type_id)
        thumbnail = try c.decodeIfPresent([String].self, forKey: .thumbnail)
        products = try c.decodeIfPresent([ProductDataModel1].self, forKey: .products)
        img_thumbnail = try c.decodeIfPresent([String].self, forKey: .img_thumbnail)
        is_live = try decodeBoolFlexible(c, forKey: .is_live)
        viewer_count = try c.decodeIfPresent(Int.self, forKey: .viewer_count)
        latest_viewer_count = try c.decodeIfPresent(Int.self, forKey: .latest_viewer_count)
        promoted_at = try c.decodeIfPresent(String.self, forKey: .promoted_at)
        rtc_token = try c.decodeIfPresent(String.self, forKey: .rtc_token)
        promote_show_id = try c.decodeIfPresent(Int.self, forKey: .promote_show_id)
        started_at = try c.decodeIfPresent(String.self, forKey: .started_at)
        share_count = try c.decodeIfPresent(Int.self, forKey: .share_count)
        recording_resource_id = try c.decodeIfPresent(String.self, forKey: .recording_resource_id)
        recording_sid = try c.decodeIfPresent(String.self, forKey: .recording_sid)
        room_id = try c.decodeIfPresent(String.self, forKey: .room_id)
        category = try c.decodeIfPresent(Category.self, forKey: .category)
        user = try c.decodeIfPresent(User.self, forKey: .user)
        auction = try c.decodeIfPresent(AuctionData.self, forKey: .auction)
        sub_category_id = try c.decodeIfPresent(Int.self, forKey: .sub_category_id)
        is_promote = try c.decodeIfPresent(String.self, forKey: .is_promote)
        is_promoted = try decodeBoolFlexible(c, forKey: .is_promoted)
        promotion_start_at = try c.decodeIfPresent(String.self, forKey: .promotion_start_at)
        promotion_end_at = try c.decodeIfPresent(String.self, forKey: .promotion_end_at)
        sub_category = try c.decodeIfPresent(SubCategoryDataModel.self, forKey: .sub_category)
        video_duration = try c.decodeIfPresent(String.self, forKey: .video_duration)
    }
}
