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
    var userID, productID: Int?
    var shippingAddress: String?
    var cardID, customerPaymentProfileID, promoCode: String?
    var sendAsGift: Bool?
    var giftUserID: Int?
    var giftMsg: String?
    var status, createdAt: String?
    var product: ProductDetails?
    var shippingTracking: [ShippingTrackingModel]?
    var user: UserShortModel?
    
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
        case shippingTracking = "shipping_tracking"
        case user
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
            cardID: order.cardID,
            customerPaymentProfileID: order.customerPaymentProfileID,
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
            width: p.width.map { "\($0)" },
            length: p.length.map { "\($0)" },
            weight: p.weight.map { "\($0)" },
            height: p.height.map { "\($0)" },
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


// MARK: - ProductDetails
struct ProductDetails: Codable {
    var id, userID, categoryID, subCategoryID: Int?
    var title: String?
    var variant: String?
    var width, length, weight: String?
    var height, mailClass, processingCategory: String?
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

