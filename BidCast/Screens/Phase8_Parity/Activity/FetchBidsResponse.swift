//
//  FetchBidsResponse.swift
//  BidCast — iOS parity Phase 8 / P1.7 (2026-04-23)
//
//  Mirror of Android `FetchBidResponse.kt` — wire type returned from
//  GET api/bid/fetch?page=N used by `BidsListViewController` (and
//  potentially a buyer "bids for this product" view).
//
//  Android adapter uses `product.images.first` as thumbnail and
//  `product.title` + `bid_price` as the primary row text; we keep the
//  same field names.
//

import Foundation

struct FetchBidsResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let totalPage: Int?
    let data: [FetchedBid?]?

    enum CodingKeys: String, CodingKey {
        case status, message, currentPage, perPage, total, totalPage, data
        case errorType = "error_type"
    }
}

struct FetchedBid: Codable, Identifiable, Hashable {
    let id: Int?
    let bidPrice: Double?
    let createdAt: String?
    let createdBy: Int?
    let productId: Int?
    let scheduleShowId: Int?
    let userId: Int?
    let product: FetchedBidProduct?
    let user: FetchedBidUser?

    enum CodingKeys: String, CodingKey {
        case id, product, user
        case bidPrice = "bid_price"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case productId = "product_id"
        case scheduleShowId = "schedule_show_id"
        case userId = "user_id"
    }
}

struct FetchedBidProduct: Codable, Hashable {
    let id: Int?
    let title: String?
    let description: String?
    let pricing: String?
    let quantity: Int?
    let purchasedQuantity: Int?
    let status: String?
    let images: [String?]?
    let productShow: String?
    let categoryId: Int?
    let shippingProfileId: Int?
    let userId: Int?
    let acceptOffers: Bool?
    let flashSale: Bool?
    let reserveForLive: Bool?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description, pricing, quantity, status, images
        case productShow = "product_show"
        case purchasedQuantity = "purchased_quantity"
        case categoryId = "category_id"
        case shippingProfileId = "shipping_profile_id"
        case userId = "user_id"
        case acceptOffers = "accept_offers"
        case flashSale = "flash_sale"
        case reserveForLive = "reserve_for_live"
        case createdAt = "created_at"
    }
}

struct FetchedBidUser: Codable, Hashable {
    let id: Int?
    let name: String?
    let firstName: String?
    let lastName: String?
    let username: String?
    let email: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username, email
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
    }
}
