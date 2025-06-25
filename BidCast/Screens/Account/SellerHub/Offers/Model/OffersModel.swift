//
//  OffersModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - OfferListModel
struct OfferListModel : Codable {
    var id, user_id, product_id : Int?
    var amount: String?
    var status, created_at: String?
    var user: UserDetail?
    var product: ProductModel?
    var schedule_show_id : Int?
    var bid_price : Int?
    var created_by : Int?
             
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


// MARK: - ItemListModel
struct ItemListModel : Codable {
    var id: Int?
    var orderID: String?
    var userID, productID: Int?
    var shippingAddress, cardID: String?
    var promoCode: String?
    var sendAsGift: Bool?
    var giftUserID: Int?
    var giftMsg: String?
    var status: String?
    var createdAt: String?
    var product: ProductDetails?
    var user: UserDetails?

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
        case status
        case createdAt = "created_at"
        case product, user
    }
}



//// MARK: - UserDetails
//struct UserDetails: Codable {
//    let id: Int
//    let name: Name
//    let username: Username?
//    let profileImage: String?
//    let email: Email
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, username
//        case profileImage = "profile_image"
//        case email
//    }
//}
