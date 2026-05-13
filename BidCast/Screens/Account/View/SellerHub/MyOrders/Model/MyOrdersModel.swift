//
//  MyOrdersModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation
    
// MARK: - MyOrderModel
struct MyOrderModel: Codable {
    var id: Int?
    var orderID: String?
    var orderSource: String?
    var userID: Int?
    var productID: Int?
    var shippingAddress: String?
    var cardID: Int?
    var customerPaymentProfileID: Int?
    var promoCode: String?
    var sendAsGift: Bool?
    var giftUserID: Int?
    var giftMsg: String?
    var status: String?
    var paymentStatus: String?
    var createdAt: String?

    var product: ProductDetails?
    var shippingTracking: [ShippingTrackingModel]?
    var user: UserShortModel?
    
    var productSetID: Int?
       var productSetItemID: Int?
       var productSetItemUnitID: Int?

       // Nested Objects
       var transaction: [TransactionModel]?
       var productSet: ProductSetModel?
       var productSetItem: ProductSetItemModel?
       var productSetItemUnit: ProductSetItemUnitModel?


    enum CodingKeys: String, CodingKey {
        case id
        case orderID = "order_id"
        case orderSource = "order_source"
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
        case createdAt = "created_at"
        case product
        case shippingTracking = "shipping_tracking"
        case user
        case productSet = "product_set"
        case transaction
        case productSetItem = "product_set_item"
        case productSetItemUnit = "product_set_item_unit"
    }
}
struct ProductSetModel: Codable {
    var id: Int?
    var description: String?
    var autoRandomizer: Int?
    var shippingProfileID: Int?
    var createdAt: String?
    var userID: Int?
    var type: String?
    var quickSpin: Int?
    var price: Double?
    var isLiveBid: Int?
    var updatedAt: String?
    var name: String?
    var status: String?
    var seller: UserDataModel?

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case autoRandomizer = "auto_randomizer"
        case shippingProfileID = "shipping_profile_id"
        case createdAt = "created_at"
        case userID = "user_id"
        case type
        case quickSpin = "quick_spin"
        case price
        case isLiveBid = "is_live_bid"
        case updatedAt = "updated_at"
        case name
        case status
        case seller
    }
}

struct ProductSetItemModel: Codable {
    var id: Int?
    var status: String?
    var quantity: Int?
    var price: Double?
    var soldQuantity: Int?
    var productSetID: Int?
    var description: String?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case quantity
        case price
        case soldQuantity = "sold_quantity"
        case productSetID = "product_set_id"
        case description
        case name
    }
}

struct ProductSetItemUnitModel: Codable {
    var id: Int?
    var status: String?
    var price: Double?
    var productSetItemID: Int?
    var name: String?
    var description: String?

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case price
        case productSetItemID = "product_set_item_id"
        case name
        case description
    }
}



extension MyOrderModel {
    static func convertToMyOrderModel(from details: OrderDetailsModel?) -> MyOrderModel {
        
        guard let details = details,
              let order = details.order else {
            return MyOrderModel(
                id: nil,
                orderID: nil,
                userID: nil,
                productID: nil,
                shippingAddress: nil,
                cardID: nil,
                customerPaymentProfileID: nil,
                promoCode: nil,
                sendAsGift: nil,
                giftUserID: nil,
                giftMsg: nil,
                status: nil,
                createdAt: nil,
                product: nil,
                shippingTracking: nil,
                user: nil
            )
        }
        
        // Build: MyOrderModel
        return MyOrderModel(
            id: order.id,
            orderID: order.orderID,
            userID: order.userID,
            productID: order.productID,
            shippingAddress: order.shippingAddress,
            cardID: Int(order.cardID ?? ""),
            customerPaymentProfileID: Int(order.customerPaymentProfileID ?? ""),
            promoCode: order.promoCode,
            sendAsGift: order.sendAsGift,
            giftUserID: Int(order.giftUserID ?? "0") ?? 0,
            giftMsg: order.giftMsg,
            status: order.status,
            createdAt: order.createdAt,
            
            // IMPORTANT: Product model mapping
            product: convertProductModel(order.product),
            
            // Shipping tracking (we get only 1 address → create 1 tracking entry)
            shippingTracking: convertShippingTracking(details.shippingAddress),
            
            // Seller/User information
            user: UserShortModel(
                id: details.sellerDetails?.id,
                name: details.sellerDetails?.name,
                username: details.sellerDetails?.username,
                profileImage: details.sellerDetails?.profile_image,
                email: details.sellerDetails?.email
            )
        )
    }
    
    static func convertProductModel(_ product: ProductDetailModel?) -> ProductDetails? {
        guard let p = product else { return nil }
        
        return ProductDetails(
            id: p.id,
            userID: p.userID,
            categoryID: p.categoryID,
            subCategoryID: p.subCategoryID,
            title: p.title,
            variant: p.variant,
            weight: p.weight.map { Double(($0)) },
            width: p.width.map { ($0) },
            length: p.length.map { ($0) },
            height: p.height.map { ($0) },
            mailClass: p.mailClass,
            processingCategory: p.processingCategory,
            description: p.description,
            quantity: p.quantity,
            purchasedQuantity: p.purchasedQuantity,
            pricing: p.pricing,
            flashSale: p.flashSale,
            acceptOffers: p.acceptOffers,
            reserveForLive: p.reserveForLive,
            shippingProfileID: p.shippingProfileID,
            status: p.status,
            productShow: p.productShow,
            images: p.images,
            thumbnail: p.thumbnail,
            createdAt: p.createdAt,
            category: p.category
        )
    }

    static func convertShippingTracking(_ address: ShippingAddressModel?) -> [ShippingTrackingModel]? {
        guard let address = address else { return nil }
        
        let line = [
            address.streetAddress,
            address.city,
            address.state,
            address.pincode
        ]
            .compactMap { $0 }
            .joined(separator: ", ")
        
        return [
            ShippingTrackingModel(
                id: address.id,
                orderID: address.userID,
                title: address.name,
                createdAt: nil
            )
        ]
    }


}


// MC sub-task cmp49349500lh3mx146ck78co + cmp4935la00lv3mx1uoosj9qj
// (Trey 2026-05-13): Android serialises tinyint(1) bool flags as 0/1 ints.
// Swift's synthesised Codable init rejects that shape and the whole order /
// product / show payload fails to decode — user sees a generic API error.
// Decode bools flexibly so both shapes work.
private func decodeBoolFlexible<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) throws -> Bool? {
    if let b = try? c.decodeIfPresent(Bool.self, forKey: key) { return b }
    if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return i != 0 }
    if let s = try? c.decodeIfPresent(String.self, forKey: key) {
        let v = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if ["1", "true", "yes"].contains(v) { return true }
        if ["0", "false", "no"].contains(v) { return false }
    }
    return nil
}

extension MyOrderModel {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        orderID = try c.decodeIfPresent(String.self, forKey: .orderID)
        orderSource = try c.decodeIfPresent(String.self, forKey: .orderSource)
        userID = try c.decodeIfPresent(Int.self, forKey: .userID)
        productID = try c.decodeIfPresent(Int.self, forKey: .productID)
        shippingAddress = try c.decodeIfPresent(String.self, forKey: .shippingAddress)
        cardID = try c.decodeIfPresent(Int.self, forKey: .cardID)
        customerPaymentProfileID = try c.decodeIfPresent(Int.self, forKey: .customerPaymentProfileID)
        promoCode = try c.decodeIfPresent(String.self, forKey: .promoCode)
        sendAsGift = try decodeBoolFlexible(c, forKey: .sendAsGift)
        giftUserID = try c.decodeIfPresent(Int.self, forKey: .giftUserID)
        giftMsg = try c.decodeIfPresent(String.self, forKey: .giftMsg)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        paymentStatus = try c.decodeIfPresent(String.self, forKey: .paymentStatus)
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        product = try c.decodeIfPresent(ProductDetails.self, forKey: .product)
        shippingTracking = try c.decodeIfPresent([ShippingTrackingModel].self, forKey: .shippingTracking)
        user = try c.decodeIfPresent(UserShortModel.self, forKey: .user)
        productSetID = try? c.decodeIfPresent(Int.self, forKey: .productSet)
        productSetItemID = try? c.decodeIfPresent(Int.self, forKey: .productSetItem)
        productSetItemUnitID = try? c.decodeIfPresent(Int.self, forKey: .productSetItemUnit)
        transaction = try c.decodeIfPresent([TransactionModel].self, forKey: .transaction)
        productSet = try c.decodeIfPresent(ProductSetModel.self, forKey: .productSet)
        productSetItem = try c.decodeIfPresent(ProductSetItemModel.self, forKey: .productSetItem)
        productSetItemUnit = try c.decodeIfPresent(ProductSetItemUnitModel.self, forKey: .productSetItemUnit)
    }
}

// MARK: - ProductDetails
struct ProductDetails: Codable {
    var id, userID, categoryID, subCategoryID: Int?
    var title: String?
    var variant: [ProductVariant]?
    var weight: Double?
    var width, length,height: Int?
    var  mailClass, processingCategory: String?
    var description: String?
    var quantity, purchasedQuantity: String?
    var pricing: String?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
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
        case acceptOffers = "accept_offers"
        case reserveForLive = "reserve_for_live"
        case shippingProfileID = "shipping_profile_id"
        case status
        case productShow = "product_show"
        case images, thumbnail
        case createdAt = "created_at"
        case category
    }
}

extension ProductDetails {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        userID = try c.decodeIfPresent(Int.self, forKey: .userID)
        categoryID = try c.decodeIfPresent(Int.self, forKey: .categoryID)
        subCategoryID = try c.decodeIfPresent(Int.self, forKey: .subCategoryID)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        variant = try c.decodeIfPresent([ProductVariant].self, forKey: .variant)
        weight = try c.decodeIfPresent(Double.self, forKey: .weight)
        width = try c.decodeIfPresent(Int.self, forKey: .width)
        length = try c.decodeIfPresent(Int.self, forKey: .length)
        height = try c.decodeIfPresent(Int.self, forKey: .height)
        mailClass = try c.decodeIfPresent(String.self, forKey: .mailClass)
        processingCategory = try c.decodeIfPresent(String.self, forKey: .processingCategory)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        quantity = try c.decodeIfPresent(String.self, forKey: .quantity)
        purchasedQuantity = try c.decodeIfPresent(String.self, forKey: .purchasedQuantity)
        pricing = try c.decodeIfPresent(String.self, forKey: .pricing)
        flashSale = try decodeBoolFlexible(c, forKey: .flashSale)
        acceptOffers = try decodeBoolFlexible(c, forKey: .acceptOffers)
        reserveForLive = try decodeBoolFlexible(c, forKey: .reserveForLive)
        shippingProfileID = try c.decodeIfPresent(Int.self, forKey: .shippingProfileID)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        productShow = try c.decodeIfPresent(String.self, forKey: .productShow)
        images = try c.decodeIfPresent([String].self, forKey: .images)
        thumbnail = try c.decodeIfPresent([String].self, forKey: .thumbnail)
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt)
        category = try c.decodeIfPresent(Category.self, forKey: .category)
    }
}


// MARK: - ShippingTrackingModel
struct ShippingTrackingModel: Codable {
    var id, orderID: Int?
    var title, createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case orderID = "order_id"
        case title
        case createdAt = "created_at"
    }
}


// MARK: - User
struct UserShortModel: Codable {
    var id: Int?
    var name, username: String?
    var profileImage: String?
    var email: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case profileImage = "profile_image"
        case email
    }
}


struct ResponseModelOrder<T: Codable>: Codable {
    var status, message, error_type: String?
    var data: T?
    var new_order_count, completed_order_count,processing_order_count: Int?
    var total,totalPage,currentPage,perPage : Int?
}

