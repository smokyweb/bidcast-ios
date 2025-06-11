//
//  BuyNowModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

// MARK: - BuyNowModel
struct BuyNowModel: Codable {
    var id: Int?
    var orderID: String?
    var userID, productID: Int?
    var shippingAddress, cardID, promoCode: String?
    var sendAsGift: Bool?
    var giftUserID: Int?
    var giftMsg, status: String?
    var product: ProductDetails?
    var giftUser, user: UserDetails?
    var shippingTracking: [ShippingTracking]?

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
        case giftUser = "gift_user"
        case user
        case shippingTracking = "shipping_tracking"
    }
}

// MARK: - UserDetails
struct UserDetails: Codable {
    var id, roleID: Int?
    var firstName, lastName, name: String?
    var username: String?
    var email: String?
    var profileImage: String?
    var thumbnail: String?
    var bio: String?
    var isActive: Bool?
    var referralCode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case roleID = "role_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case name, username, email
        case profileImage = "profile_image"
        case thumbnail, bio
        case isActive = "is_active"
        case referralCode = "referral_code"
    }
}

// MARK: - ShippingTracking
struct ShippingTracking: Codable {
    var id, orderID: Int?
    var title, createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case orderID = "order_id"
        case title
        case createdAt = "created_at"
    }
}

// MARK: - ProductOrderModel
struct ProductOrderModel: Codable {
    var userID: Int?
    var orderID: String?
    var productID: Int?
    var shippingAddress, cardID, promoCode: String?
    var sendAsGift: Bool?
    var giftUserID: Int?
    var giftMsg, status: String?
    var id: Int?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case orderID = "order_id"
        case productID = "product_id"
        case shippingAddress = "shipping_address"
        case cardID = "card_id"
        case promoCode = "promo_code"
        case sendAsGift = "send_as_gift"
        case giftUserID = "gift_user_id"
        case giftMsg = "gift_msg"
        case status, id
    }
}
