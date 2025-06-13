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
    var user_id: Int?
    var category_id: Int?
    var product_ids: [String]? 
    var auction_type_id: Int?
    var thumbnail: [String]?
    var img_thumbnail: [String]?
    var is_live: Bool?
    var viewer_count: Int?
    var room_id: String?
    
    var category: Category?
    var user: User?
}


