//  ProductResponses.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - Product.kt (the shared Product struct reused across many responses)
//    - GetProductsResponse.kt / GetProductsByStatusResponse.kt
//    - GetProductDetailsResponse.kt
//    - GetMyInventoryResponse.kt
//    - CreateProductResponse.kt / StoreProductMetaResponse.kt
//
//  NOTE: A condensed ExploreProduct / ExploreProductFilter already exists
//  from the Phase 1 explore work (see BidCast/Screens/Main/Explore/Model/).
//  The models here are the *full* product wire shape used for inventory,
//  details, my-orders-by-status, auctions, etc. Don't merge with the
//  condensed explore version — they'll diverge again.
//
//  QA-NOTE: Android has TWO Product-field naming conventions in-flight:
//    - snake_case (accept_offers, flash_sale, created_at, ...) used on
//      GetProductDetails / GetMyInventory / FetchOrderDetail / etc.
//    - camelCase (acceptOffers, flashSale, createdAt, ...) used on
//      Product.kt and GetProductsByStatusResponse.kt.
//  Backend quirk — mirrored here via a `WireProduct` that declares BOTH
//  key sets and prefers whichever is present. Phase 3+ should push the
//  backend team to pick one.

import Foundation

// MARK: - Product (canonical wire shape)

struct WireProduct: Codable, Identifiable, Hashable {
    let id: Int?
    let userId: Int?
    let title: String?
    let description: String?
    let pricing: String?
    let quantity: String?
    let purchasedQuantity: String?
    let status: String?
    let sku: String?
    let productCondition: String?
    let processingCategory: String?
    let productShow: String?
    let mailClass: String?
    let acceptOffers: Bool?
    let auction: Bool?
    let flashSale: Bool?
    let reserveForLive: Bool?
    let hazardousMaterial: Bool?
    let shippingProfileId: Int?
    let categoryId: Int?
    let subCategoryId: AnyCodable?
    let type: AnyCodable?
    let height: Double?
    let width: Double?
    let length: Double?
    let weight: Double?
    let images: [String?]?
    let thumbnail: [AnyCodable]?
    let videos: [String?]?
    let variant: AnyCodable?
    let createdAt: String?
    let bidCount: Int?
    let category: Category?
    let subCategory: SubCategory?
    let user: UserPublic?

    enum CodingKeys: String, CodingKey {
        case id, title, description, pricing, quantity, status, sku
        case acceptOffers = "accept_offers"
        case auction
        case flashSale = "flash_sale"
        case reserveForLive = "reserve_for_live"
        case hazardousMaterial = "hazardous_material"
        case shippingProfileId = "shipping_profile_id"
        case categoryId = "category_id"
        case subCategoryId = "sub_category_id"
        case productCondition = "product_condition"
        case processingCategory = "processing_category"
        case productShow = "product_show"
        case mailClass = "mail_class"
        case purchasedQuantity = "purchased_quantity"
        case height, width, length, weight
        case images, videos, variant, thumbnail, type
        case createdAt = "created_at"
        case userId = "user_id"
        case bidCount = "bid_count"
        case category, user
        case subCategory = "sub_category"
    }
}

// MARK: - GetProductsResponse (POST api/v1/get-product)

/// QA-NOTE: Android uses `"data"` key but names the property `products` —
/// so the wire key is still `data` and the Swift alias here matches.
struct GetProductsResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let totalPage: Int?
    let products: [WireProduct?]?

    enum CodingKeys: String, CodingKey {
        case status, message, currentPage, perPage, total, totalPage
        case errorType = "error_type"
        case products = "data"
    }
}

// MARK: - GetProductsByStatusResponse (POST api/v1/get-my-purchases-orders)

typealias GetProductsByStatusResponse = APIPaginatedResponse<ProductsByStatusItem>

struct ProductsByStatusItem: Codable, Identifiable, Hashable {
    let id: Int?
    let orderId: String?
    let orderSource: String?
    let paymentStatus: String?
    let status: String?
    let createdAt: String?
    let shippingAddress: String?
    let sendAsGift: Bool?
    let userId: Int?
    let productId: Int?
    let product: WireProduct?
    let productSetId: Int?
    let productSet: AnyCodable?
    let productSetItem: AnyCodable?
    let productSetItemUnit: AnyCodable?
    let user: UserPublic?

    enum CodingKeys: String, CodingKey {
        case id, status, product, user
        case orderId = "order_id"
        case orderSource = "order_source"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
        case shippingAddress = "shipping_address"
        case sendAsGift = "send_as_gift"
        case userId = "user_id"
        case productId = "product_id"
        case productSetId = "product_set_id"
        case productSet = "product_set"
        case productSetItem = "product_set_item"
        case productSetItemUnit = "product_set_item_unit"
    }
}

// MARK: - GetProductDetailsResponse (POST api/v1/get-product-details)

typealias GetProductDetailsResponse = APIResponse<ProductDetailsData>

struct ProductDetailsData: Codable, Hashable {
    // Flatten to WireProduct's fields + a few details-specific additions.
    let id: Int?
    let title: String?
    let description: String?
    let pricing: String?
    let quantity: String?
    let purchasedQuantity: String?
    let status: String?
    let sku: String?
    let productCondition: String?
    let processingCategory: String?
    let productShow: String?
    let mailClass: String?
    let acceptOffers: Bool?
    let auction: Bool?
    let flashSale: Bool?
    let reserveForLive: Bool?
    let hazardousMaterial: Bool?
    let shippingProfileId: Int?
    let categoryId: Int?
    let subCategoryId: Int?
    let type: String?
    let height: Double?
    let width: Double?
    let length: Double?
    let weight: Double?
    let images: [String?]?
    let thumbnail: [String?]?
    let videos: [String?]?
    let variant: AnyCodable?
    let createdAt: String?
    let userId: Int?
    let category: Category?
    let subCategory: SubCategory?
    let user: UserPublic?
    let offer: ProductOffer?
    let shippingAdress: ShippingAddress?   // QA-NOTE: Android typo preserved.
    let productSaveStatus: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, description, pricing, quantity, status, sku, type
        case acceptOffers = "accept_offers"
        case auction
        case flashSale = "flash_sale"
        case reserveForLive = "reserve_for_live"
        case hazardousMaterial = "hazardous_material"
        case shippingProfileId = "shipping_profile_id"
        case categoryId = "category_id"
        case subCategoryId = "sub_category_id"
        case productCondition = "product_condition"
        case processingCategory = "processing_category"
        case productShow = "product_show"
        case mailClass = "mail_class"
        case purchasedQuantity = "purchased_quantity"
        case height, width, length, weight
        case images, videos, variant, thumbnail
        case createdAt = "created_at"
        case userId = "user_id"
        case category, user, offer
        case subCategory = "sub_category"
        case shippingAdress = "shipping_adress"
        case productSaveStatus = "product_save_status"
    }
}

struct ProductOffer: Codable, Hashable {
    let id: Int?
    let amount: String?
    let productId: Int?
    let userId: Int?
    let status: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, amount, status
        case productId = "product_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

// MARK: - GetMyInventoryResponse (POST api/get-user-product, seller inventory)

typealias GetMyInventoryResponse = APIPaginatedResponse<WireProduct>

// MARK: - CreateProductResponse (POST api/store-product)

typealias CreateProductResponse = APIResponse<WireProduct>

// MARK: - StoreProductMetaResponse (POST api/store-product-meta)

typealias StoreProductMetaResponse = APIResponse<StoreProductMetaData>

struct StoreProductMetaData: Codable, Hashable {
    let images: [ProductMetaImage]?
    let videos: [ProductMetaVideo]?
}

struct ProductMetaImage: Codable, Hashable {
    let images: String?
    let thumbnail: String?
}

struct ProductMetaVideo: Codable, Hashable {
    let videos: String?
}

// MARK: - StoreProductRequest (POST api/store-product)

struct StoreProductRequest: Encodable {
    let categoryId: String?
    let title: String?
    let description: String?
    let quantity: String?
    let pricing: String?
    let flashSale: Bool?
    let acceptOffers: Bool?
    let reserveForLive: Bool?
    let shippingProfileId: String?
    let status: String?
    let images: [[String: String?]]?
    let videos: [[String: String?]]?
    let subCategoryId: Int?
    let variant: [[String: AnyCodable?]]?
    let width: String?
    let height: String?
    let length: String?
    let weight: String?
    let mailClass: String?
    let processingCategory: String?
    let productCondition: String?
    let hazardousMaterial: Bool?
    let sku: String?
    let costPerItem: String?

    enum CodingKeys: String, CodingKey {
        case title, description, quantity, pricing, status, images, videos, variant
        case width, height, length, weight, sku
        case categoryId = "category_id"
        case flashSale = "flash_sale"
        case acceptOffers = "accept_offers"
        case reserveForLive = "reserve_for_live"
        case shippingProfileId = "shipping_profile_id"
        case subCategoryId = "sub_category_id"
        case mailClass = "mail_class"
        case processingCategory = "processing_category"
        case productCondition = "product_condition"
        case hazardousMaterial = "hazardous_material"
        case costPerItem = "cost_per_item"
    }
}

// MARK: - GetSubCategoriesRequest (POST api/get-subcategories)

struct GetSubCategoriesRequest: Encodable {
    let categoryIds: [Int]
    let subcategoryIds: [Int]?

    enum CodingKeys: String, CodingKey {
        case categoryIds = "category_ids"
        case subcategoryIds = "sub_category_ids"
    }
}

// MARK: - GetSubCategoriesResponse (POST api/get-subcategories)

typealias GetSubCategoriesResponse = APIListResponse<SubCategoryGroup>

struct SubCategoryGroup: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let image: String?
    let thumbnail: String?
    let color: String?
    let extraFields: [AnyCodable]?
    let subcategories: [SubCategory]?

    enum CodingKeys: String, CodingKey {
        case id, name, image, thumbnail, color, subcategories
        case extraFields = "extra_fields"
    }
}
