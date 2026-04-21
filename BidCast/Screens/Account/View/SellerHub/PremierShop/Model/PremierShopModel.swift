//
//  PremierShopModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - PremierShopModel
struct PremierShopModel: Codable {
    var id: Int?
    var pageLogo: String?
    var pageTitle, pageDetails: String?
    var shopLogo: String?
    var shopTitle, shopDetails: String?
    var shopOptions: ShopOptions?
    var features: [PremierFeatureModel]?
    var requirements: [PremierRequirement]?
    var reviewLogo: String?
    var reviewTitle, reviewDetails, nextReview, currentProgress: String?
    var outForDeliveryOrderNumbers: [String]?   // ✅ NEW
       var isPremierApplied: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case pageLogo = "page_logo"
        case pageTitle = "page_title"
        case pageDetails = "page_details"
        case shopLogo = "shop_logo"
        case shopTitle = "shop_title"
        case shopDetails = "shop_details"
        case shopOptions = "shop_options"
        case features, requirements
        case reviewLogo = "review_logo"
        case reviewTitle = "review_title"
        case reviewDetails = "review_details"
        case nextReview = "next_review"
        case currentProgress = "current_progress"
        case outForDeliveryOrderNumbers = "out_for_delivery_order_numbers" // ✅ NEW
        case isPremierApplied = "is_premier_applied"                       // ✅ NEW
    }
}

// MARK: - PremierFeatureModel
struct PremierFeatureModel: Codable {
    var title, description: String?
    var icon: String?
}

// MARK: - PremierRequirement
struct PremierRequirement: Codable {
    var platform, url: String?
}

// MARK: - ShopOptions
struct ShopOptions: Codable {
    let rating: Double
    let response, delivery: String

    enum CodingKeys: String, CodingKey {
        case rating = "Rating"
        case response = "Response"
        case delivery = "Delivery"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // API can return "Rating" as either a number or a numeric string.
        if let doubleRating = try? container.decode(Double.self, forKey: .rating) {
            rating = doubleRating
        } else if let stringRating = try? container.decode(String.self, forKey: .rating),
                  let parsed = Double(stringRating) {
            rating = parsed
        } else {
            rating = 0.0
        }
        
        response = (try? container.decode(String.self, forKey: .response)) ?? ""
        delivery = (try? container.decode(String.self, forKey: .delivery)) ?? ""
    }
}
