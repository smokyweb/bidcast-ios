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
    var auction_type_id: Int?
    var thumbnail: [String]?
    var category: Category?
    var user: User?
}

struct Category: Codable,Identifiable {
    var id: Int?
    var name: String?
    var image: String?
    var color: String?
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
}
