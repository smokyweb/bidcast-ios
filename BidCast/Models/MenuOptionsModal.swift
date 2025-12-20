//
//  MenuOptionsModal.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 07/02/24.
//

import Foundation

struct MenuOptionsModal: Codable {
    var id: Int?
    var page_name, page_content, page_url: String?
}

// MARK: - DataClass
struct SellerhubInfoModel: Codable {
    var items: Int?
    var revenue, rating: Double?
    var upcomingShow: HomeModel?
    var accountHealth: AccountHealth?
    var payouts, totalOrders: Int?
    var vacationMode: String?

    enum CodingKeys: String, CodingKey {
        case items, revenue, rating
        case upcomingShow = "upcoming_show"
        case accountHealth = "account_health"
        case payouts
        case totalOrders = "total_orders"
        case vacationMode = "vacation_mode"
    }
}


// MARK: - AccountHealth
struct AccountHealth: Codable {
    var onTimeScanRate, defectFreeOrderRate, policyStanding: String?

    enum CodingKeys: String, CodingKey {
        case onTimeScanRate = "on_time_scan_rate"
        case defectFreeOrderRate = "defect_free_order_rate"
        case policyStanding = "policy_standing"
    }
}
