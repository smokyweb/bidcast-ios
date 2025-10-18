//
//  InventoryModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - InventoryModel
struct InventoryModel: Codable {
    var status, message, errorType: String?
    var data: [InventoryDataModel]?
    var total, totalPage, currentPage, perPage: Int?
}


// MARK: - InventoryDataModel
struct InventoryDataModel: Codable {
    var id: Int?
    var categoryID: Int?
    var subCategoryID: Int?
    var title, description: String?
    var quantity: String?
    var pricing: Double?
    var flashSale: Bool?
    var acceptOffers: Bool?
    var reserveForLive: Bool?
    var shippingProfileID: Int?
    var status: String?
    var images: [String]?
    var thumbnails: [String]?
    var offer: String?
    var weight, length, width, height: Float?
    var productShow: String?
    var processingCategory: String?
    var purchasedQuantity: Int?
    var createdAt: String?
    var userID: Int?
    var user: UserDataModel?
    var shippingAddress: ShippingAddressModel?
    var category : CategoryDataModel?
    var sub_category : CategoryDataModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryID = "category_id"
        case subCategoryID = "sub_category_id"
        case title, description, quantity, pricing
        case flashSale = "flash_sale"
        case acceptOffers = "accept_offers"
        case reserveForLive = "reserve_for_live"
        case shippingProfileID = "shipping_profile_id"
        case status, images
        case thumbnails = "thumbnail"
        case offer, weight, length, width, height
        case productShow = "product_show"
        case processingCategory = "processing_category"
        case purchasedQuantity = "purchased_quantity"
        case createdAt = "created_at"
        case userID = "user_id"
        case user
        case shippingAddress = "shipping_adress"
    }
}

// MARK: - UserDataModel
struct UserDataModel: Codable {
    var id: Int?
    var username, email, name: String?
    var profileImage: String?
    var sellerVerification: Bool?

    enum CodingKeys: String, CodingKey {
        case id, username, email, name
        case profileImage = "profile_image"
        case sellerVerification = "seller_verification"
    }
}

// MARK: - ShippingAddressModel
struct ShippingAddressModel: Codable {
    var id: Int?
    var userID: Int?
    var name, streetAddress, city, state, pincode, type, phoneNumber: String?
    var isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case streetAddress = "street_address"
        case city, state, pincode, type
        case phoneNumber = "phone_number"
        case isDefault = "is_default"
    }
}
