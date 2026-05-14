//
//  OrderStatusModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//


import Foundation

// MARK: - ProductPurchaseModel
struct ProductPurchaseModel: Codable {
    var product: ProductDataModel1?
    var shippingAddress: ShippingAddress?
    var price: String?
    var tax_amount: String?
    var shipping_charges: String?
    var total: String?
    var tax_percent: String?
    var sub_total: String?
    var discount_amount : String?
}

// MARK: - ProductPurchaseDetail
struct ProductPurchaseDetail: Codable {
    var id, userID, categoryID: Int?
    var title, description: String?
    var quantity, purchasedQuantity, pricing: String?
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

// MARK: - ShippingAddress
struct ShippingAddress: Codable {
    var id, userID: Int?
    var type, name, phoneNumber, streetAddress: String?
    // MC sub-task cmp4932vk00l13mx1du6mmebo: optional 2nd line.
    var addressLine2: String?
    var pincode: String?
    var isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case type, name
        case phoneNumber = "phone_number"
        case streetAddress = "street_address"
        // MC sub-task cmp4932vk00l13mx1du6mmebo: decode address_line_2.
        case addressLine2 = "address_line_2"
        case pincode
        case isDefault = "is_default"
    }
}

