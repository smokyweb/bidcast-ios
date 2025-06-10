//
//  OffersModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - OfferListModel
struct OfferListModel : Codable {
    var id, userID, productID, amount: Int?
    var status, createdAt: String?
    var user: UserDetail?
    var product: ProductModel?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case productID = "product_id"
        case amount, status
        case createdAt = "created_at"
        case user, product
    }
}

// MARK: - ProductModel
struct ProductModel: Codable {
    var id: Int?
    var title: String?
    var pricing: Float?
    var images: [String]?
}

// MARK: - UserDetail
struct UserDetail: Codable {
    var id: Int?
    var name: String?
    var profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImage = "profile_image"
    }
}


//MARK: OfferUpdateStatus
struct OfferUpdateStatus: Codable {
    var id, userID, productID, amount: Int?
    var status, createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case productID = "product_id"
        case amount, status
        case createdAt = "created_at"
    }
}
