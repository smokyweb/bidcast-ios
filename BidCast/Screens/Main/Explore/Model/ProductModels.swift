//
//  ProductModels.swift
//  BidCast
//
//  Created by Trey Difficult Task Agent on 2026-04-21.
//
//  Codable models for the Explore / Products feature. Shapes match the Android
//  `GetProductsResponse` and `GetCategoryResponse` payloads served by
//  `backend.bidcast.betaplanets.com` (endpoints `api/v1/get-product` and
//  `api/get-category`). Keeping the field set tolerant (all optional) so the
//  UI does not crash when the backend omits a field.
//
//  NOTE 2026-04-22: the parity work (Phase 2c/2g) introduced canonical
//  `GetProductsResponse` / `GetCategoryResponse` names in
//  `BidCast/Models/Product/ProductResponses.swift` and
//  `BidCast/Models/Shop/ShopModels.swift`. To avoid symbol collisions while
//  keeping the Explore feature compiling against its existing `ProductModel` /
//  `CategoryModel` shapes, the Explore-specific response types are renamed
//  with an `Explore` prefix here. Call sites in ExploreViewModel updated to
//  match.
//

import Foundation

// MARK: - Product list response

struct ExploreGetProductsResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: [ProductModel]?
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let totalPage: Int?

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorType = "error_type"
        case currentPage, perPage, total, totalPage
    }
}

struct ProductModel: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let pricing: String?
    let quantity: String?
    let productCondition: String?
    let status: String?
    let images: [String]?
    let thumbnail: [String]?
    let category: ProductCategoryRef?
    let user: ProductUserRef?
    let auction: Bool?
    let acceptOffers: Bool?
    let flashSale: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, pricing, quantity
        case productCondition, status, images, thumbnail, category, user
        case auction, acceptOffers, flashSale, createdAt
    }

    /// Best-effort first image URL for thumbnails.
    var primaryImageURL: String? {
        if let t = thumbnail?.compactMap({ $0 }).first, !t.isEmpty { return t }
        if let i = images?.compactMap({ $0 }).first, !i.isEmpty { return i }
        return nil
    }

    /// Display price with `$` prefix. Backend returns pricing as string.
    var displayPrice: String {
        guard let p = pricing, !p.isEmpty else { return "" }
        return p.hasPrefix("$") ? p : "$\(p)"
    }
}

struct ProductCategoryRef: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let thumbnail: String?
    let color: String?
}

struct ProductUserRef: Codable {
    let id: Int?
    let name: String?
    let email: String?
    let profileImage: String?
}

// MARK: - Category list response

struct ExploreGetCategoryResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: [CategoryModel]?

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorType = "error_type"
    }
}

struct CategoryModel: Codable {
    let id: Int?
    let name: String?
    let image: String?
    let thumbnail: String?
    let color: String?
    let liveCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, image, thumbnail, color, liveCount
    }
}
