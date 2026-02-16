//
//  OffersModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - OfferListModel
//struct OfferListModel : Codable {
//    var id, user_id, product_id : Int?
//    var amount: String?
//    var status, created_at: String?
//    var user: UserDetail?
//    var product: ProductModel?
//    var schedule_show_id : Int?
//    var bid_price : Int?
//    var created_by : Int?
//}

struct OfferListModel: Codable {
    let id: Int?
    let order_id: String?
    let user_id: Int?
    let product_id: Int?
    let shipping_address: String?
    let card_id: String?
    let customer_payment_profile_id: String?
    let promo_code: String?
    let send_as_gift: Bool?
    let gift_user_id: String?
    let gift_msg: String?
    let status: String?
    let created_at: String?
    let product: ProductDataDetailsModel?
    let user: UserDetailDataModel?
}

struct ProductDataDetailsModel: Codable {
    let id: Int?
    let user_id: Int?
    let category_id: Int?
    let sub_category_id: Int?
    let title: String?
    let variant: String?
    let width: Int?
    let length: Int?
    let weight: Int?
    let height: Int?
    let mail_class: String?
    let processing_category: String?
    let description: String?
    let quantity: String?
    let purchased_quantity: String?
    let pricing: String?
    let flash_sale: Bool?
    let auction: Bool?
    let accept_offers: Bool?
    let reserve_for_live: Bool?
    let shipping_profile_id: Int?
    let type: String?
    let status: String?
    let product_show: String?
    let images: [String]?
    let thumbnail: [String]?
    let created_at: String?
    let seller: SellerDetailsModel?
}

struct SellerDetailsModel: Codable {
    let id: Int?
    let name: String?
    let username: String?
    let profile_image: String?
    let email: String?
}

struct UserDetailDataModel: Codable {
    let id: Int?
    let name: String?
    let username: String?
    let profile_image: String?
    let email: String?
}



// MARK: - ProductModel
struct ProductModel: Codable {
    var id: Int?
    var title: String?
    var pricing: String?
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



// MARK: - Datum
struct PurchasedOrderModel: Codable {
    var id: Int?
    var orderID: String?
    var userID, productID: Int?
    var shippingAddress: String?
    var cardID: String?
    var customerPaymentProfileID: String?
    var promoCode: String?
    var sendAsGift: Bool?
    var giftUserID: Int?
    var giftMsg: String?
    var status, paymentStatus: String?
    var orderSource: String?
    var createdAt: String?
    var product: ProductDataModel1?
    var user: UserDataModel?
    var productSet: ProductSetModel?
    var productSetItem: ProductSetItemModel?
    var productSetItemUnit: ProductSetItemUnitModel?
    var seller: UserDataModel?

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
        case paymentStatus = "payment_status"
        case orderSource = "order_source"
        case createdAt = "created_at"
        case product, user
        case productSet = "product_set"
        case seller
        case productSetItem = "product_set_item"
        case productSetItemUnit = "product_set_item_unit"
    }
}
