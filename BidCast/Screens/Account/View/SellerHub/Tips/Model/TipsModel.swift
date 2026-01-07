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
    var totalTips: Int?
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
    var username: String?
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

// MARK: - DataClass
struct SendTipAmountModel: Codable {
    var userID: Int?
    var sellerID, sourceType, type, status: String?
    var date: String?
    var subTotal, taxAmount, shippingCharges, discount: Int?
    var total, cardNumber, createdAt: String?
    var id: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case sellerID = "seller_id"
        case sourceType = "source_type"
        case type, status, date
        case subTotal = "sub_total"
        case taxAmount = "tax_amount"
        case shippingCharges = "shipping_charges"
        case discount, total
        case cardNumber = "card_number"
        case createdAt = "created_at"
        case id
    }
}
