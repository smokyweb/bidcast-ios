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
    var shippingAddress: String?
    var cardID, customerPaymentProfileID, promoCode: String?
    var sendAsGift: Bool?
    var giftUserID: Int?
    var giftMsg: String?
    var status, createdAt: String?
    var product: ProductDetails?
    var shippingTracking: [ShippingTrackingModel]?
    var user: UserShortModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case orderID = "order_id"
        case userID = "user_id"
        case productID = "product_id"
        case shippingAddress = "shipping_address"
        case cardID = "card_id"
        case customerPaymentProfileID = "customer_payment_profile_id"
        case promoCode = "promo_code"
        case sendAsGift = "send_as_gift"
        case giftUserID = "gift_user_id"
        case giftMsg = "gift_msg"
        case status
        case createdAt = "created_at"
        case product
        case shippingTracking = "shipping_tracking"
        case user
    }
}


// MARK: - ProductDetails
struct ProductDetails: Codable {
    var id, userID, categoryID, subCategoryID: Int?
    var title: String?
    var variant: String?
    var width, length, weight: String?
    var height, mailClass, processingCategory: String?
    var description: String?
    var quantity, purchasedQuantity, pricing: Int?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var status, productShow: String?
    var images: [String]?
    var thumbnail: [String]?
    var createdAt: String?
    var category: Category?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case categoryID = "category_id"
        case subCategoryID = "sub_category_id"
        case title, variant, width, length, weight, height
        case mailClass = "mail_class"
        case processingCategory = "processing_category"
        case description, quantity
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
        case category
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


// MARK: - User
struct UserShortModel: Codable {
    var id: Int?
    var name, username: String?
    var profileImage: String?
    var email: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case profileImage = "profile_image"
        case email
    }
}


struct ResponseModelOrder<T: Codable>: Codable {
    var status, message, error_type: String?
    var data: T?
    var new_order_count, completed_order_count,processing_order_count: Int?
    var total,totalPage,currentPage,perPage : Int?
}

