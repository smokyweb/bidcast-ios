//
//  ProductDetailsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - ProductDetailsModel
struct ProductDetailsModel: Codable {
    var id, userID, categoryID: Int?
    var title, description: String?
    var quantity, pricing: Int?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var status: String?
    var images: [String]?
    var createdAt: String?
    var offer: Offer?
    var user: SellerUser?
    var shippingAdress: ShippingAdress?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case categoryID = "category_id"
        case title, description, quantity, pricing
        case flashSale = "flash_sale"
        case acceptOffers = "accept_offers"
        case reserveForLive = "reserve_for_live"
        case shippingProfileID = "shipping_profile_id"
        case status, images
        case createdAt = "created_at"
        case offer, user
        case shippingAdress = "shipping_adress"
    }
}

struct SellerUser: Codable {
    var id: Int?
    var name, username: String?
    var profileImage: String?
    var sellerVerification: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case profileImage = "profile_image"
        case sellerVerification = "seller_verification"
    }
}

// MARK: - Offer
struct Offer: Codable {
    var id, userID, productID: Int?
    var status, createdAt,amount: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case productID = "product_id"
        case amount, status
        case createdAt = "created_at"
    }
}

// MARK: - ShippingAdress
struct ShippingAdress: Codable {
    var id, userID: Int?
    var type, name, phoneNumber, streetAddress: String?
    var pincode: String?
    var isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case type, name
        case phoneNumber = "phone_number"
        case streetAddress = "street_address"
        case pincode
        case isDefault = "is_default"
    }
}
