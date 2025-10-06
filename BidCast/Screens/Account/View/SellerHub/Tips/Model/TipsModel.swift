//
//  TipsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - DataClass
struct TipsModel: Codable {
    var summary: Summary?
    var tips: [Tip]?
}

// MARK: - Summary
struct Summary: Codable {
    var totalTips: String?
    var todayTips: Int?

    enum CodingKeys: String, CodingKey {
        case totalTips = "total_tips"
        case todayTips = "today_tips"
    }
}

// MARK: - Tip
struct Tip: Codable {
    var id, userID: Int?
    var total, createdAt: String?
    var user: UserModel?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case total
        case createdAt = "created_at"
        case user
    }
}

// MARK: - User
struct UserModel: Codable {
    var id: Int?
    var name, email: String?
    var profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case profileImage = "profile_image"
    }
}

struct TipSummaryItem: Hashable, CustomStringConvertible {
    let title: String
    let value: String

    var description: String { value } // For bottom label binding
}
