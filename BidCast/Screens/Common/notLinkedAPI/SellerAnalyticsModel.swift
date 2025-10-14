
//
//  SellerAnalyticsViewModel.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 07/10/25.
//

import Foundation

// MARK: - DataClass
struct SellerAnalyticsModel: Codable {
    var seller: Seller?
    var stats: Stats?
}

// MARK: - Seller
struct Seller: Codable {
    var id: Int?
    var name, since: String?
    var profile: String?
}

// MARK: - Stats
struct Stats: Codable {
    var totalItems: Int?
    var revenue: String?
    var rating, followers, liveSessions, totalSales: Int?

    enum CodingKeys: String, CodingKey {
        case totalItems = "total_items"
        case revenue, rating, followers
        case liveSessions = "live_sessions"
        case totalSales = "total_sales"
    }
}

// MARK: - DataClass
struct VisitorsAnalyticsModel: Codable {
    var filter: String?
    var chart: [Chart]?
}

// MARK: - Chart
struct Chart: Codable {
    var label, totalVisitors: String?

    enum CodingKeys: String, CodingKey {
        case label
        case totalVisitors = "total_visitors"
    }
}

// MARK: - DataClass
struct SalesPerformanceModel: Codable {
    var filter: String?
    var chart: [SalesChart]?
}

// MARK: - Chart
struct SalesChart: Codable {
    var label: String?
    var totalSales: Int?
    var totalRevenue: String?

    enum CodingKeys: String, CodingKey {
        case label
        case totalSales = "total_sales"
        case totalRevenue = "total_revenue"
    }
}
