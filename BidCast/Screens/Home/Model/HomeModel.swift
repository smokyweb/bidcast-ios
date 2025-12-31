//
//  LiveShowsModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 02/06/25.
//

import Foundation

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
}

struct AuctionData : Codable {
    var id : Int?
    var name : String?
}
