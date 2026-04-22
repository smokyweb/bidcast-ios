//  OrderModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - GetOrdersResponse.kt
//    - GetOrderDetailsResponse.kt
//    - FetchOrderDetailResponse.kt
//    - CreateOrderResponse.kt
//    - GetPurchaseDetail.kt
//    - RaiseTicketResponse.kt

import Foundation

// MARK: - Order (reused across list/detail)

struct Order: Codable, Identifiable, Hashable {
    let id: Int?
    let orderId: String?
    let status: String?
    let orderSource: String?
    let paymentStatus: String?
    let createdAt: String?
    let shippingAddress: String?
    let sendAsGift: Bool?
    let giftMsg: String?
    let giftUserId: Int?
    let giftUser: UserPublic?
    let promoCode: String?
    let cardId: String?
    let productId: Int?
    let product: WireProduct?
    let productSetId: Int?
    let productSet: OrderProductSet?
    let productSetItemId: Int?
    let productSetItem: OrderProductSetItem?
    let productSetItemUnitId: Int?
    let productSetItemUnit: OrderProductSetItemUnit?
    let userId: Int?
    let user: UserPublic?
    let shippingTracking: [ShippingTracking]?
    let transaction: [OrderTransaction]?
    let orderStatusPercentage: Int?

    var createdDate: Date? { ISO8601DateFormatter().date(from: createdAt ?? "") }

    enum CodingKeys: String, CodingKey {
        case id, status, product, user, transaction
        case orderId = "order_id"
        case orderSource = "order_source"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
        case shippingAddress = "shipping_address"
        case sendAsGift = "send_as_gift"
        case giftMsg = "gift_msg"
        case giftUser = "gift_user"
        case giftUserId = "gift_user_id"
        case promoCode = "promo_code"
        case cardId = "card_id"
        case productId = "product_id"
        case productSetId = "product_set_id"
        case productSet = "product_set"
        case productSetItemId = "product_set_item_id"
        case productSetItem = "product_set_item"
        case productSetItemUnitId = "product_set_item_unit_id"
        case productSetItemUnit = "product_set_item_unit"
        case userId = "user_id"
        case shippingTracking = "shipping_tracking"
        case orderStatusPercentage = "order_status_percentage"
    }
}

struct OrderProductSet: Codable, Identifiable, Hashable {
    let id: Int?
    let autoRandomizer: Int?
    let description: String?
    let isLiveBid: Int?
    let name: String?
    let price: Int?
    let quickSpin: Int?
    let shippingProfileId: Int?
    let status: String?
    let type: String?
    let userId: Int?
    let createdAt: String?
    let updatedAt: String?
    let items: [OrderProductSetItem]?

    enum CodingKeys: String, CodingKey {
        case id, description, name, price, status, type, items
        case autoRandomizer = "auto_randomizer"
        case isLiveBid = "is_live_bid"
        case quickSpin = "quick_spin"
        case shippingProfileId = "shipping_profile_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct OrderProductSetItem: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let description: AnyCodable?
    let price: Int?
    let productSetId: Int?
    let quantity: Int?
    let soldQuantity: Int?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, quantity, status
        case productSetId = "product_set_id"
        case soldQuantity = "sold_quantity"
    }
}

struct OrderProductSetItemUnit: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let description: AnyCodable?
    let price: Int?
    let productSetItemId: Int?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, status
        case productSetItemId = "product_set_item_id"
    }
}

struct ShippingTracking: Codable, Identifiable, Hashable {
    let id: Int?
    let orderId: Int?
    let title: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case orderId = "order_id"
        case createdAt = "created_at"
    }
}

struct OrderTransaction: Codable, Identifiable, Hashable {
    let id: Int?
    let orderId: Int?
    let sellerId: Int?
    let userId: Int?
    let chargeId: String?
    let paymentIntentId: String?
    let productPrice: Double?
    let subTotal: Double?
    let taxAmount: Double?
    let shippingCharges: Double?
    let discount: Double?
    let total: String?
    let date: String?
    let createdAt: String?
    let status: String?
    let type: String?
    let sourceType: String?
    let cardNumber: String?
    let accountNumber: AnyCodable?
    let couponId: AnyCodable?
    let payoutId: AnyCodable?
    let promoteShowId: AnyCodable?
    let showId: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case id, date, total, status, type, discount
        case orderId = "order_id"
        case sellerId = "seller_id"
        case userId = "user_id"
        case chargeId = "charge_id"
        case paymentIntentId = "payment_intent_id"
        case productPrice = "product_price"
        case subTotal = "sub_total"
        case taxAmount = "tax_amount"
        case shippingCharges = "shipping_charges"
        case createdAt = "created_at"
        case sourceType = "source_type"
        case cardNumber = "card_number"
        case accountNumber = "account_number"
        case couponId = "coupon_id"
        case payoutId = "payout_id"
        case promoteShowId = "promote_show_id"
        case showId = "show_id"
    }
}

// MARK: - GetOrdersResponse (POST api/v1/get-my-orders)

struct GetOrdersResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: [Order]?
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let totalPage: Int?
    let completedOrderCount: Int?
    let newOrderCount: Int?
    let processingOrderCount: Int?

    enum CodingKeys: String, CodingKey {
        case status, message, data, currentPage, perPage, total, totalPage
        case errorType = "error_type"
        case completedOrderCount = "completed_order_count"
        case newOrderCount = "new_order_count"
        case processingOrderCount = "processing_order_count"
    }
}

// MARK: - GetOrderDetailsResponse (POST api/v1/get-order-status)

typealias GetOrderDetailsResponse = APIResponse<Order>

// MARK: - FetchOrderDetailResponse (POST api/v1/get-order-details)

typealias FetchOrderDetailResponse = APIResponse<FetchOrderDetailData>

struct FetchOrderDetailData: Codable, Hashable {
    let order: Order?
    let sellerDetails: UserPublic?
    let shippingAddress: ShippingAddress?
    let avgShip: String?
    let ratingAvg: String?
    let review: String?
    let soldCount: Int?
    let isFollowing: Bool?
    let bidVideoUrl: String?

    enum CodingKeys: String, CodingKey {
        case order, review
        case sellerDetails = "seller_details"
        case shippingAddress = "shipping_address"
        case avgShip = "avg_ship"
        case ratingAvg = "rating_avg"
        case soldCount = "sold_count"
        case isFollowing = "is_following"
        case bidVideoUrl = "bid_video_url"
    }
}

// MARK: - CreateOrderResponse (POST api/v1/place-order)

typealias CreateOrderResponse = APIResponse<CreateOrderData>

struct CreateOrderData: Codable, Hashable {
    let id: Int?
    let orderId: String?
    let status: String?
    let productId: Int?
    let userId: Int?
    let cardId: String?
    let sendAsGift: Bool?
    let giftMsg: AnyCodable?
    let giftUserId: AnyCodable?
    let promoCode: AnyCodable?
    let shippingAddress: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, status
        case orderId = "order_id"
        case productId = "product_id"
        case userId = "user_id"
        case cardId = "card_id"
        case sendAsGift = "send_as_gift"
        case giftMsg = "gift_msg"
        case giftUserId = "gift_user_id"
        case promoCode = "promo_code"
        case shippingAddress = "shipping_address"
        case createdAt = "created_at"
    }
}

// MARK: - GetPurchaseDetail (POST api/v1/checkout-product-detail)

typealias GetPurchaseDetailResponse = APIResponse<PurchaseDetailData>

struct PurchaseDetailData: Codable, Hashable {
    let product: WireProduct?
    let shippingAddress: ShippingAddress?
    let shippingCharges: String?
    let subTotal: String?
    let taxAmount: String?
    let taxPercent: String?
    let total: String?
    let discountAmount: String?

    enum CodingKeys: String, CodingKey {
        case product, total
        case shippingAddress
        case shippingCharges = "shipping_charges"
        case subTotal = "sub_total"
        case taxAmount = "tax_amount"
        case taxPercent = "tax_percent"
        case discountAmount = "discount_amount"
    }
}

// MARK: - RaiseTicketResponse (POST api/raise-ticket)

typealias RaiseTicketResponse = APIResponse<RaiseTicketData>

struct RaiseTicketData: Codable, Hashable {
    let id: Int?
    let userId: Int?
    let productId: String?
    let subject: String?
    let message: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, subject, message
        case userId = "user_id"
        case productId = "product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - ReturnRequest (future endpoint — placeholder for Phase 3)
// TODO-PHASE3: No Android endpoint yet — check backend with seller team.
struct ReturnRequest: Codable, Hashable {
    let orderId: Int?
    let reason: String?
    let description: String?
    let images: [String]?

    enum CodingKeys: String, CodingKey {
        case reason, description, images
        case orderId = "order_id"
    }
}
