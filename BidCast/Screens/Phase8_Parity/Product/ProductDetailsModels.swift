//
//  ProductDetailsModels.swift
//  BidCast — iOS Parity Phase 8 / P0.1 (2026-04-23)
//
//  Codable models for `api/v1/get-product-details`. Mirrors Android's
//  `GetProductDetailsResponse` (io.bidswipe.app.network.response).
//  All fields optional on purpose; backend occasionally omits keys.
//

import Foundation

struct ProductDetailsResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: ParityProductDetailsData?

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorType = "error_type"
    }
}

struct ParityProductDetailsData: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let pricing: String?
    let quantity: String?
    let purchasedQuantity: String?
    let productCondition: String?
    let status: String?
    let type: String?                 // "buy_now" | "auction" | "surprise_set" (backend varies)
    let sku: String?
    let mailClass: String?
    let auction: Bool?
    let acceptOffers: Bool?
    let flashSale: Bool?
    let reserveForLive: Bool?
    let hazardousMaterial: Bool?
    let productSaveStatus: Bool?
    let images: [String?]?
    let thumbnail: [String?]?
    let videos: [String?]?
    let category: ProductDetailsCategory?
    let subCategory: ProductDetailsCategory?
    let user: ProductDetailsUser?
    let userId: Int?
    let createdAt: String?
    let weight: Double?
    let height: Double?
    let length: Double?
    let width: Double?

    enum CodingKeys: String, CodingKey {
        case id, title, description, pricing, quantity, status, type, sku,
             auction, images, thumbnail, videos, category, user,
             weight, height, length, width
        case purchasedQuantity = "purchased_quantity"
        case productCondition = "product_condition"
        case mailClass = "mail_class"
        case acceptOffers = "accept_offers"
        case flashSale = "flash_sale"
        case reserveForLive = "reserve_for_live"
        case hazardousMaterial = "hazardous_material"
        case productSaveStatus = "product_save_status"
        case subCategory = "sub_category"
        case userId = "user_id"
        case createdAt = "created_at"
    }

    /// Display helper — `$123.00`. Backend sends pricing as a bare string.
    var displayPrice: String {
        guard let p = pricing, !p.isEmpty else { return "" }
        return p.hasPrefix("$") ? p : "$\(p)"
    }

    /// Best-effort merged media list (images + videos). Videos are flagged
    /// with `isVideo=true` so the gallery can swap to AVPlayer.
    var galleryItems: [ProductMediaItem] {
        var items: [ProductMediaItem] = []
        for img in (images ?? []).compactMap({ $0 }) where !img.isEmpty {
            items.append(.init(url: img, isVideo: false))
        }
        for vid in (videos ?? []).compactMap({ $0 }) where !vid.isEmpty {
            items.append(.init(url: vid, isVideo: true))
        }
        // Fallback to thumbnails when nothing else
        if items.isEmpty {
            for t in (thumbnail ?? []).compactMap({ $0 }) where !t.isEmpty {
                items.append(.init(url: t, isVideo: false))
            }
        }
        return items
    }

    /// "Buy Now" / "Auction" / "Surprise Set" badge text for the pricing row.
    var pricingBadgeText: String {
        if auction == true { return "Auction" }
        if (type ?? "").lowercased() == "surprise_set" { return "Surprise Set" }
        return "Buy Now"
    }
}

struct ProductDetailsCategory: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let thumbnail: String?
    let color: String?
}

struct ProductDetailsUser: Codable {
    let id: Int?
    let name: String?
    let email: String?
    let username: String?
    let profileImage: String?
    let sellerVerification: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, email, username
        case profileImage = "profile_image"
        case sellerVerification = "seller_verification"
    }
}

struct ProductMediaItem: Equatable {
    let url: String
    let isVideo: Bool
}
