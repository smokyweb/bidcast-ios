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
    var impression_per_hours: Int?
    var total_taps_and_clicks: Int?
    var ctr: Double?
    var sustained_watches: Int?
    var sustained_watches_rate: Double?
    var follows_from_promotion: Int?
    var first_time_buyers_from_promotion: Int?
    var direct_sales_form_promotion: String?
    var spend: Double?
    var immediate_return_on_spend: Double?
    var seven_day_return_on_spend: Double?
    var bids_from_promotion: Int?
}
