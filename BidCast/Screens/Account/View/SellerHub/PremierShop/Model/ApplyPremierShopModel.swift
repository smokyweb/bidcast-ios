
//
//  PremierShopModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - ApplyPremierShopModel
struct ApplyPremierShopModel: Codable {
    var id, userID: Int?
    var idCard, image: String?
    var phoneNumber, otp: String?
    var numberOtpVerified: Int?
    var cardID, status, premierStatus: String?
    var isPremierApplied: Int?
    var reason: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case idCard = "id_card"
        case image
        case phoneNumber = "phone_number"
        case otp
        case numberOtpVerified = "number_otp_verified"
        case cardID = "card_id"
        case status
        case premierStatus = "premier_status"
        case isPremierApplied = "is_premier_applied"
        case reason
    }
}
