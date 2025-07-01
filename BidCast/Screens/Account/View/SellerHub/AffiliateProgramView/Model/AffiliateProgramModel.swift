//
//  AffiliateProgramModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - ReferalModel
struct ReferalModel: Codable {
    var id: Int?
    var name: String
    var username: String?
    var referralCode: String?
    var totalReferred: Int?
    var totalEarnings: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case referralCode = "referral_code"
        case totalReferred = "total_referred"
        case totalEarnings = "total_earnings"
    }
}
