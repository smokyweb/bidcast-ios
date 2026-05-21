//
//  StoreProductModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 19/05/25.
//

import Foundation

//struct StoreProductModel : Codable {
//    var category_id : Int?
//    var title : String?
//    var description : String?
//    var quantity : Int?
//    var pricing : Int?
//    var flash_sale : Bool? = false
//    var accept_offers : Bool? = false
//    var reserve_for_live : Bool? = false
//    var shipping_profile_id : Int?
//    var status : String?
//    var images : [String]?
//    var id : Int?
//}


//toDo: needed to aad width, height, length, weight in future if required
// MARK: - StoreProductModel
struct StoreProductModel: Codable {
    var description: String?
    var quantity : String?
        var id: Int?
    var flashSale: Bool?
    var shippingProfileID, categoryID: Int?
    var createdAt: String?
    var pricing: String?
    var userID: Int?
    var acceptOffers: Bool?
    var title: String?
    var reserveForLive: Bool?
    var images: [String]?
    var thumbnail: [String]?
    var status: String?

    enum CodingKeys: String, CodingKey {
        case description, quantity, id
        case flashSale = "flash_sale"
        case shippingProfileID = "shipping_profile_id"
        case categoryID = "category_id"
        case createdAt = "created_at"
        case pricing
        case userID = "user_id"
        case acceptOffers = "accept_offers"
        case title
        case reserveForLive = "reserve_for_live"
        case images, thumbnail, status
    }
}

// MARK: - DataClass
struct ImageModel: Codable {
    var images: [ImagesModel]?
    var videos: [VideosModel]?
}

// MARK: - Image
struct ImagesModel: Codable {
    var images, thumbnail: String?
}

// MARK: - Video
struct VideosModel: Codable {
    var videos: String?
}


struct MailClassesData: Codable {
    var mail_classes: [MailClass]
}

struct MailClass: Codable {
    var label: String
    var max_weight_lbs: Double?
    var max_length_in: Double?
    var max_width_in: Double?
    var max_height_in: Double?
    var max_length_plus_girth_in: Double?
    var notes: String?
}

// MARK: - OrderDetailsModel
struct OrderDetailsModel: Codable {
    var sellerDetails: SellerDetails?
    var ratingAvg, soldCount: Int?
    var review, avgShip: String?
    var isFollowing: Bool?
    var shippingAddress: ShippingAddressModel?
    var order: Order?
    var bidVideoURL: String?
    
    enum CodingKeys: String, CodingKey {
        case sellerDetails = "seller_details"
        case ratingAvg = "rating_avg"
        case soldCount = "sold_count"
        case review
        case avgShip = "avg_ship"
        case isFollowing = "is_following"
        case shippingAddress = "shipping_address"
        case order
        case bidVideoURL = "bid_video_url"
    }
}
    

// MARK: - Order
struct Order: Codable {
    var id: Int?
    var orderID: String?
    var userID, productID: Int?
    var shippingAddress: String?
    var cardID, customerPaymentProfileID, promoCode: String?
    var sendAsGift: Bool?
    var giftUserID, giftMsg: String?
    var status, createdAt: String?
    var product: ProductDetailModel?
    var giftUser: String?
    // MC task cmpex02ro000psahg2n1zn7wz (Larry 2026-05-21, video Part 1 @ 01:16):
    // OrderTrackingView (called via Profile → My Orders) shows the Order Details
    // card with the new Item Title / Cost / Taxes / Shipping / Total rows.
    // The v1 `get-order-details` endpoint already eager-loads the transaction
    // relation (see ApiV1Controller@getOrderDetails on prod), but this struct
    // had no field to decode it into — the data was being silently dropped.
    // Accepts either array (one or more transaction rows) or single object
    // (legacy shape from older orders) via a custom decoder below.
    var transaction: [TransactionModel]?

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
        case giftUser = "gift_user"
        case transaction
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decodeIfPresent(Int.self, forKey: .id)
        orderID = try? c.decodeIfPresent(String.self, forKey: .orderID)
        userID = try? c.decodeIfPresent(Int.self, forKey: .userID)
        productID = try? c.decodeIfPresent(Int.self, forKey: .productID)
        shippingAddress = try? c.decodeIfPresent(String.self, forKey: .shippingAddress)
        cardID = try? c.decodeIfPresent(String.self, forKey: .cardID)
        customerPaymentProfileID = try? c.decodeIfPresent(String.self, forKey: .customerPaymentProfileID)
        promoCode = try? c.decodeIfPresent(String.self, forKey: .promoCode)
        sendAsGift = try? c.decodeIfPresent(Bool.self, forKey: .sendAsGift)
        giftUserID = try? c.decodeIfPresent(String.self, forKey: .giftUserID)
        giftMsg = try? c.decodeIfPresent(String.self, forKey: .giftMsg)
        status = try? c.decodeIfPresent(String.self, forKey: .status)
        createdAt = try? c.decodeIfPresent(String.self, forKey: .createdAt)
        product = try? c.decodeIfPresent(ProductDetailModel.self, forKey: .product)
        giftUser = try? c.decodeIfPresent(String.self, forKey: .giftUser)
        // cmpex02ro: transaction comes as an array from the v1 endpoint
        // (Order::with('transaction')… → HasMany), but accept a single object
        // too for legacy/older orders that pre-date the array shape — same
        // pattern MyOrderModel uses for its transaction decoder.
        if let txArr = try? c.decodeIfPresent([TransactionModel].self, forKey: .transaction) {
            transaction = txArr
        } else if let txOne = try? c.decodeIfPresent(TransactionModel.self, forKey: .transaction) {
            transaction = [txOne]
        } else {
            transaction = nil
        }
    }
}

// MARK: - Product
struct ProductDetailModel: Codable {
    var id, userID, categoryID, subCategoryID: Int?
    var title: String?
    var variant: [ProductVariant]?
    var width, length, weight, height: Int?
    var mailClass, processingCategory, description, quantity: String?
    var purchasedQuantity, pricing: String?
    var flashSale, auction, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var type: String?
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
        case auction
        case acceptOffers = "accept_offers"
        case reserveForLive = "reserve_for_live"
        case shippingProfileID = "shipping_profile_id"
        case type, status
        case productShow = "product_show"
        case images, thumbnail
        case createdAt = "created_at"
        case category
    }
}
