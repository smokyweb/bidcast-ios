//
//  PromoteToolsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

struct AnalyticsData: Codable {
    var number_of_boost: Int?
    var number_of_show_promote: Int?
    var community_boost: Int?
    var impressions: Int?
    var promote_hours: String?
    
    var impressions_per_hour: Int?            // ✅ UPDATED (was: impression_per_hours)

    var total_taps_and_clicks: Int?
    var ctr: String?
    var sustained_watches: Int?
    var sustained_watches_rate: Double?
    var follows_from_promotion: Int?
    var first_time_buyers_from_promotion: Int?
    
    var direct_sales_form_promotion: String?     

    var spend: Double?
    var immediate_return_on_spend: Int?
    var seven_day_return_on_spend: Int?    // ✅ NEW MAPPING REQUIRED

    var bids_from_promotion: Int?

    enum CodingKeys: String, CodingKey {
        case number_of_boost
        case number_of_show_promote
        case community_boost
        case impressions
        case promote_hours
        case impressions_per_hour
        case total_taps_and_clicks
        case ctr
        case sustained_watches
        case sustained_watches_rate
        case follows_from_promotion
        case first_time_buyers_from_promotion
        case direct_sales_form_promotion
        case spend
        case immediate_return_on_spend
        case bids_from_promotion

        case seven_day_return_on_spend = "7_day_return_on_spend" // ✅ NEW KEY MAP
    }
}
