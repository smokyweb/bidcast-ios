//
//  ProductDetailsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - ProductDetailsModel
struct ProductDetailsModel: Codable {
    var id, userID, categoryID, subCategoryID: Int?
    var title: String?
    var variant: String? //toDo: not clear about its type
    var width, length, weight, height: Double?
    var mailClass, processingCategory: String?
    var description, quantity, purchasedQuantity, pricing: String?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var status, productShow: String?
    var images: [String]?
    var thumbnail: [String]?
    var createdAt: String?
    var offer: Offer?
    var user: SellerUser?
    var shippingAdress: ShippingAdress?

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
        case offer, user
        case shippingAdress = "shipping_adress"
    }
}

extension ProductDetailsModel {
    func toProductDataModel() -> ProductDataModel {
        return ProductDataModel(
            id: self.id,
            userID: self.userID,
            category_id: self.categoryID,
            subCategoryID: self.subCategoryID,
            title: self.title,
            
            variant: nil, // 🚨 You can parse JSON string into [Variant] later if needed
            
            // Convert String dimensions → Double safely
            width: self.width ?? 0.0,
            length: self.length ?? 0.0,
            weight: self.weight ?? 0.0,
            height: self.height ?? 0.0,
            
            mailClass: self.mailClass,
            processingCategory: self.processingCategory,
            
            description: self.description,
            quantity: self.quantity,
            purchasedQuantity: self.purchasedQuantity,
            pricing: self.pricing,
            flashSale: self.flashSale,
            acceptOffers: self.acceptOffers,
            reserveForLive: self.reserveForLive,
            shippingProfileID: self.shippingProfileID,
            status: self.status,
            productShow: self.productShow,
            images: self.images,
            thumbnail: self.thumbnail,
            createdAt: self.createdAt,
            
            // These can be nil — details endpoint may not provide them
            category: nil,
            subCategory: nil
        )
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
