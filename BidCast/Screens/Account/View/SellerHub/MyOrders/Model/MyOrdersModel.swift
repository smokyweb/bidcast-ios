//
//  MyOrdersModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - MyOrderModel
struct MyOrderModel: Codable {
    var id: Int?
    var orderID: String?
    var userID, productID: Int?
    var shippingAddress, cardID: String?
    var promoCode: String?
    var sendAsGift: Bool?
    var giftUserID: Int?
    var giftMsg: String?
    var status: String?
    var product: ProductDetails?
    var shippingTracking: [ShippingTrackingModel]?

    enum CodingKeys: String, CodingKey {
        case id
        case orderID = "order_id"
        case userID = "user_id"
        case productID = "product_id"
        case shippingAddress = "shipping_address"
        case cardID = "card_id"
        case promoCode = "promo_code"
        case sendAsGift = "send_as_gift"
        case giftUserID = "gift_user_id"
        case giftMsg = "gift_msg"
        case status, product
        case shippingTracking = "shipping_tracking"
    }
}

// MARK: - ProductDetails
struct ProductDetails: Codable {
    var id, userID, categoryID: Int?
    var title, description: String?
    var quantity, purchasedQuantity: Int?
    var pricing: Double?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var status, productShow: String?
    var images: [String]?
    var thumbnail: [String]?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case categoryID = "category_id"
        case title, description, quantity
        case purchasedQuantity = "purchased_quantity"
        case pricing
        case flashSale = "flash_sale"
        case acceptOffers = "accept_offers"
        case reserveForLive = "reserve_for_live"
        case shippingProfileID = "shipping_profile_id"
        case status
        case productShow = "product_show"
        case images, thumbnail
        case createdAt = "created_at"
    }
}


// MARK: - ShippingTrackingModel
struct ShippingTrackingModel: Codable {
    var id, orderID: Int?
    var title, createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case orderID = "order_id"
        case title
        case createdAt = "created_at"
    }
}

struct ResponseModelOrder<T: Codable>: Codable {
    var status, message, error_type: String?
    var data: T?
    var new_order_count, completed_order_count,processing_order_count: Int?
    var total,totalPage,currentPage,perPage : Int?
}
