//
//  ScheduleModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import Foundation

struct LessonModel : Codable {
    var id: Int?
    var title : String?
    var video : String?
    var description : String?
    var status : String?
    var image : String?
    var isDone: Bool? = false

     var isLocked: Bool {
         status?.lowercased() == "locked"
     }
}


struct TitleTipsModel : Codable {
    var tips: [TipsData]?
    var example : [String]?
    
}

struct TipsData : Codable {
    var icon: String?
    var title: String?
    var description: String?
}

//// MARK: - ProductDataModel
struct ProductDataModel: Codable {
    var id, userID, category_id: Int?
    var subCategoryID: Int?
    var title: String?
    var variant: String?
    var width, length: Double?
    var weight, height: Double?
    var mailClass, processingCategory: String?
    var description, quantity, purchasedQuantity, pricing: String?
    var flashSale, acceptOffers, reserveForLive: Bool?
    var shippingProfileID: Int?
    var status: String?
    var productShow: String?
    var images: [String]?
    var thumbnail: [String]?
    var createdAt: String?
    var category: ProductCategoryModel?
    var subCategory: ProductCategoryModel?
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case category_id
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
        case subCategory = "sub_category"
    }
}

struct ProductVariant: Codable, Identifiable {
    let id = UUID()
    let title: String
    let value: VariantValue
}

enum VariantValue: Codable {
    case string(String)
    case options(VariantOptions)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let options = try? container.decode(VariantOptions.self) {
            self = .options(options)
        } else {
            self = .string("")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .options(let options):
            try container.encode(options)
        }
    }
}

struct VariantOptions: Codable {
    let option1: String?
    let option2: String?
    let selected: String?

    enum CodingKeys: String, CodingKey {
        case option1 = "option_1"
        case option2 = "option_2"
        case selected
    }
}

//// MARK: - Datum
//struct ProductDataModel1: Codable {
//    var id: Int?
//    var title: String?
//    var image: String?
//    var thumbanail: String?
//    var condition, category: String?
//    var sellerID: Int?
//    var sellerName: String?
//    var price: String?
//    var status: String?
//    var bids: Int?
//    var quantity: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, title, image, thumbanail, condition, category
//        case sellerID = "seller_id"
//        case sellerName = "seller_name"
//        case price, status, bids, quantity
//    }
//}

// MARK: - ProductDataModel1
struct ProductDataModel1: Codable, Identifiable {
    var id: Int?
    
    var title: String?
    var description: String?
    var pricing: String?
    var quantity: String?
    var purchasedQuantity: String?

    var sku: String?
    var status: String?
    var type: String?
    var saleFormat: String?
    var isAuction: Bool?
    var variant: [ProductVariant]?
    var productCondition: String?
    var productShow: String?

    var acceptOffers: Bool?
    var auction: Bool?
    var flashSale: Bool?
    // Basecamp #9933973683 (2026-05-27): flash sale price + window.
    var flashSalePrice: Double?
    var flashSaleStartsAt: String?
    var flashSaleEndsAt: String?
    var reserveForLive: Bool?
    var hazardousMaterial: Bool?

    var bidCount: Int?

    var height: Double?
    var length: Double?
    var width: Double?
    var weight: Double?

    var mailClass: String?
    var processingCategory: String?

    var shippingProfileId: Int?
    var subCategoryId: Int?
    var userId: Int?

    var images: [String]?
    var thumbnail: [String]?
    var videos: [String]?

    var createdAt: String?

    var category: ProductCategory?
    var user: ProductUser?

    // Basecamp #9963271582 (2026-06-04): the seller-facing "Qty" shown on cards must be
    // AVAILABLE stock (listed quantity minus units already purchased), NOT the raw listed
    // `quantity`. The server marks a product sold-out for scheduling when
    // `quantity <= purchased_quantity` (ApiController scheduleShow), so a product can show a
    // positive raw quantity yet still be rejected as sold-out. Mirror the server rule here so
    // the card never disagrees with the scheduling error.
    var availableQuantity: Int {
        let listed = Int(quantity ?? "0") ?? 0
        let purchased = Int(purchasedQuantity ?? "0") ?? 0
        return max(0, listed - purchased)
    }

    // True when there is no available stock left to sell — matches the server's
    // `quantity <= purchased_quantity` sold-out determination used at schedule time.
    var isSoldOut: Bool {
        let listed = Int(quantity ?? "0") ?? 0
        let purchased = Int(purchasedQuantity ?? "0") ?? 0
        return listed <= purchased
    }
    
    
//    enum CodingKeys: String, CodingKey {
//        case id
//        case title
//        case description
//        case pricing
//        case quantity
//        case purchasedQuantity = "purchased_quantity"
//        case sku
//        case bidCount = "bid_count"
//        case status
//        case type
//        case variant
//        case productCondition = "product_condition"
//        case productShow = "product_show"
//        case acceptOffers = "accept_offers"
//        case auction
//        case flashSale = "flash_sale"
//        case reserveForLive = "reserve_for_live"
//        case hazardousMaterial = "hazardous_material"
//        case height
//        case length
//        case width
//        case weight
//        case mailClass = "mail_class"
//        case processingCategory = "processing_category"
//        case shippingProfileId = "shipping_profile_id"
//        case subCategoryId = "sub_category_id"
//        case userId = "user_id"
//        case images
//        case thumbnail
//        case videos
//        case createdAt = "created_at"
//        case category
//        case user
//    }
}

// MARK: - Flexible decoders (MC cmp5ehs9b00o656kd3otm7w1m)
//
// Cross-platform decoding: the Android client sends some product fields as
// `Any?` via Gson — specifically `height`, `length`, `width`, `weight`,
// `type`, `videos`, `variant`, and `category.liveCount`. Android may put a
// Double, Int, String, or null into those slots depending on how the product
// was created (iOS sends Doubles, Android sometimes serialises a manually-
// entered string as a String, the server occasionally normalises to Int).
//
// The iOS `ProductDataModel1` declared these as strict `Double?` / `String?`,
// so Swift's automatic `Codable` decoder threw `DecodingError.typeMismatch`
// whenever the iOS viewer joined an Android-hosted live show — the viewer
// saw the iOS standard "the data couldn’t be read" message and never made
// it onto the auction screen.
//
// The helpers below decode the most common runtime representations safely,
// returning `nil` instead of throwing when the value is present but the wrong
// type. The companion `init(from:)` further down wraps every property in `try?`
// so a single bad field can't poison decoding for the entire product.
private func decodeFlexibleDouble<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) -> Double? {
    if let d = try? c.decodeIfPresent(Double.self, forKey: key) { return d }
    if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return Double(i) }
    if let s = try? c.decodeIfPresent(String.self, forKey: key) {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty || t.lowercased() == "null" { return nil }
        return Double(t)
    }
    return nil
}

private func decodeFlexibleInt<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) -> Int? {
    if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return i }
    if let d = try? c.decodeIfPresent(Double.self, forKey: key) { return Int(d) }
    if let s = try? c.decodeIfPresent(String.self, forKey: key) {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty || t.lowercased() == "null" { return nil }
        return Int(t)
    }
    return nil
}

private func decodeFlexibleString<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) -> String? {
    if let s = try? c.decodeIfPresent(String.self, forKey: key) { return s.isEmpty ? nil : s }
    if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return String(i) }
    if let d = try? c.decodeIfPresent(Double.self, forKey: key) { return String(d) }
    if let b = try? c.decodeIfPresent(Bool.self, forKey: key) { return b ? "true" : "false" }
    return nil
}

private func decodeFlexibleBool<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) -> Bool? {
    if let b = try? c.decodeIfPresent(Bool.self, forKey: key) { return b }
    if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return i != 0 }
    if let s = try? c.decodeIfPresent(String.self, forKey: key) {
        let v = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if ["1", "true", "yes"].contains(v) { return true }
        if ["0", "false", "no"].contains(v) { return false }
    }
    return nil
}

extension ProductDataModel1 {
    // Local CodingKeys for the custom init.
    // QA #11 — backend (wave3) emits `purchased_quantity` for sellers; iOS payloads emit `purchasedQuantity`. Accept either.
    private enum FlexCodingKeys: String, CodingKey {
        case id, title, description, pricing, quantity, purchasedQuantity, sku, status, type
        case purchased_quantity
        case saleFormat, sale_format, isAuction, is_auction
        case variant, productCondition, product_condition, productShow, product_show
        case acceptOffers, accept_offers, auction, flashSale, flash_sale
        case flashSalePrice, flash_sale_price, flashSaleStartsAt, flash_sale_starts_at
        case flashSaleEndsAt, flash_sale_ends_at
        case reserveForLive, reserve_for_live, hazardousMaterial, hazardous_material, bidCount, bid_count
        case height, length, width, weight
        case mailClass, mail_class, processingCategory, processing_category
        case shippingProfileId, shipping_profile_id, subCategoryId, sub_category_id, userId, user_id
        case images, thumbnail, videos, createdAt, created_at, category, user
    }

    init(from decoder: Decoder) throws {
        // Single keyed container; every field is wrapped in try? so a mismatched
        // type for any one field just defaults to nil instead of throwing
        // "the data couldn't be read" for the whole product. (MC cmp5ehs9b00o656kd3otm7w1m)
        let c = try decoder.container(keyedBy: FlexCodingKeys.self)

        self.id = decodeFlexibleInt(c, forKey: .id)
        self.title = decodeFlexibleString(c, forKey: .title)
        self.description = decodeFlexibleString(c, forKey: .description)
        self.pricing = decodeFlexibleString(c, forKey: .pricing)
        self.quantity = decodeFlexibleString(c, forKey: .quantity)
        // QA #11 — accept both `purchasedQuantity` (legacy) and `purchased_quantity` (backend wave3) so the
        // available-stock badge in the inventory screen reflects post-purchase remaining count.
        self.purchasedQuantity = decodeFlexibleString(c, forKey: .purchasedQuantity) ?? decodeFlexibleString(c, forKey: .purchased_quantity)
        self.sku = decodeFlexibleString(c, forKey: .sku)
        self.status = decodeFlexibleString(c, forKey: .status)
        self.type = decodeFlexibleString(c, forKey: .type)
        self.saleFormat = decodeFlexibleString(c, forKey: .saleFormat) ?? decodeFlexibleString(c, forKey: .sale_format)
        self.isAuction = decodeFlexibleBool(c, forKey: .isAuction) ?? decodeFlexibleBool(c, forKey: .is_auction)
        self.variant = try? c.decodeIfPresent([ProductVariant].self, forKey: .variant)
        self.productCondition = decodeFlexibleString(c, forKey: .productCondition) ?? decodeFlexibleString(c, forKey: .product_condition)
        self.productShow = decodeFlexibleString(c, forKey: .productShow) ?? decodeFlexibleString(c, forKey: .product_show)
        self.acceptOffers = decodeFlexibleBool(c, forKey: .acceptOffers) ?? decodeFlexibleBool(c, forKey: .accept_offers)
        self.auction = decodeFlexibleBool(c, forKey: .auction)
        self.flashSale = decodeFlexibleBool(c, forKey: .flashSale) ?? decodeFlexibleBool(c, forKey: .flash_sale)
        self.flashSalePrice = decodeFlexibleDouble(c, forKey: .flashSalePrice) ?? decodeFlexibleDouble(c, forKey: .flash_sale_price)
        self.flashSaleStartsAt = decodeFlexibleString(c, forKey: .flashSaleStartsAt) ?? decodeFlexibleString(c, forKey: .flash_sale_starts_at)
        self.flashSaleEndsAt = decodeFlexibleString(c, forKey: .flashSaleEndsAt) ?? decodeFlexibleString(c, forKey: .flash_sale_ends_at)
        self.reserveForLive = decodeFlexibleBool(c, forKey: .reserveForLive) ?? decodeFlexibleBool(c, forKey: .reserve_for_live)
        self.hazardousMaterial = decodeFlexibleBool(c, forKey: .hazardousMaterial) ?? decodeFlexibleBool(c, forKey: .hazardous_material)
        // bid_count from server, bidCount from iOS-emitted payloads; accept either.
        self.bidCount = decodeFlexibleInt(c, forKey: .bidCount) ?? decodeFlexibleInt(c, forKey: .bid_count)
        self.height = decodeFlexibleDouble(c, forKey: .height)
        self.length = decodeFlexibleDouble(c, forKey: .length)
        self.width = decodeFlexibleDouble(c, forKey: .width)
        self.weight = decodeFlexibleDouble(c, forKey: .weight)
        self.mailClass = decodeFlexibleString(c, forKey: .mailClass) ?? decodeFlexibleString(c, forKey: .mail_class)
        self.processingCategory = decodeFlexibleString(c, forKey: .processingCategory) ?? decodeFlexibleString(c, forKey: .processing_category)
        self.shippingProfileId = decodeFlexibleInt(c, forKey: .shippingProfileId) ?? decodeFlexibleInt(c, forKey: .shipping_profile_id)
        self.subCategoryId = decodeFlexibleInt(c, forKey: .subCategoryId) ?? decodeFlexibleInt(c, forKey: .sub_category_id)
        self.userId = decodeFlexibleInt(c, forKey: .userId) ?? decodeFlexibleInt(c, forKey: .user_id)
        self.images = try? c.decodeIfPresent([String].self, forKey: .images)
        self.thumbnail = try? c.decodeIfPresent([String].self, forKey: .thumbnail)
        self.videos = try? c.decodeIfPresent([String].self, forKey: .videos)
        self.createdAt = decodeFlexibleString(c, forKey: .createdAt) ?? decodeFlexibleString(c, forKey: .created_at)
        self.category = try? c.decodeIfPresent(ProductCategory.self, forKey: .category)
        self.user = try? c.decodeIfPresent(ProductUser.self, forKey: .user)
    }
}

extension ProductDataModel1 {
    
    static let sampleProducts: [ProductDataModel1] = [
        
        ProductDataModel1(
            id: 1,
            title: "iPhone 14 Pro",
            pricing: "999",
            quantity: "10",
            productCondition: "New",
            bidCount: 25,
            category: ProductCategory(
                id: 101,
                name: "Mobiles"
            )
        ),
        
        ProductDataModel1(
            id: 2,
            title: "MacBook Air M2",
            pricing: "1199",
            quantity: "5",
            productCondition: "Like New",
            bidCount: 12,
            category: ProductCategory(
                id: 102,
                name: "Laptops"
            )
        ),
        
        ProductDataModel1(
            id: 3,
            title: "Sony WH-1000XM5 Headphones",
            pricing: "399",
            quantity: "20",
            productCondition: "Used",
            bidCount: 8,
            category: ProductCategory(
                id: 103,
                name: "Electronics"
            )
        ),
        
        ProductDataModel1(
            id: 4,
            title: "Apple Watch Series 8",
            pricing: "499",
            quantity: "15",
            productCondition: "New",
            bidCount: 18,
            category: ProductCategory(
                id: 104,
                name: "Wearables"
            )
        )
    ]
}

struct ProductUser: Codable, Identifiable {
    var id: Int?
    var name: String?
    var username: String?
    var email: String?
    var profileImage: String?
    var sellerVerification: Bool?
}

struct ProductCategory: Codable, Identifiable {
    var id: Int?
    var name: String?
    var image: String?
    var thumbnail: String?
    var color: String?
}





// MARK: - Category
struct ProductCategoryModel: Codable {
    var id: Int?
    var name: String?
    var image: String?
    var thumbnail: String?
    var extraFields: [ExtraFieldModel]?
    var color: String?
    var deletedAt: String?
    var categoryID: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, image, thumbnail
        case extraFields = "extra_fields"
        case color
        case deletedAt = "deleted_at"
        case categoryID = "category_id"
    }
}

// MARK: - Variant
struct Variant: Codable {
    var title: String?
    var value: ValueUnion?
}

enum ValueUnion: Codable {
    case string(String)
    case valueClass(ValueClass)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode(ValueClass.self) {
            self = .valueClass(x)
            return
        }
        throw DecodingError.typeMismatch(ValueUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ValueUnion"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .valueClass(let x):
            try container.encode(x)
        }
    }
}

// MARK: - ValueClass
struct ValueClass: Codable {
    var option1, option2, selected: String?

    enum CodingKeys: String, CodingKey {
        case option1 = "option_1"
        case option2 = "option_2"
        case selected
    }
}

struct StoreScheduleShowModel : Codable{
   var user_id : Int?
    var title : String?
    var category_id : Int?
    var product_ids : [String]?
    var date : String?
    var time : String?
    var auction_type_id : Int?
    var thumbnail : [String]?
    var img_thumbnail : [String]?
    var id : Int?
    var products : [ProductDataModel]?
}

extension ProductDataModel {
    
//    StoreProductParam(category_id: "",
//                      title: "", description: "", quantity: "", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"")
//    func toStoreProductParam() -> StoreProductParam {
//        return StoreProductParam(
//            category_id: "\(category_id ?? 0)",
//            
//            title: title ?? "",
//            description: description ?? "",
//            quantity: quantity ?? "",
//            pricing: pricing ?? "",
//            flash_sale: (flash_sale ?? false) ? "1" : "0",
//            accept_offers: (accept_offers ?? false) ? "1" : "0",
//            reserve_for_live: (reserve_for_live ?? false) ? "1" : "0",
//            shipping_profile_id: "\(shipping_profile_id ?? 0)",
//            status: status ?? "active",        // ✅ Default if nil
//            sub_category_id: nil,              // ✅ optional (customize if needed)
//            width: "0",                        // ✅ Placeholder values
//            length: "0",
//            weight: "0",
//            height: "0",
//            mail_class: "standard",            // ✅ Replace with your defaults
//            processing_category: "regular"     // ✅ Replace with your defaults
//        )
//        
//        Missing Field    Description
//        sub_category_id    Not available in ProductDataModel
//        width    Not available in ProductDataModel
//        length    Not available in ProductDataModel
//        weight    Not available in ProductDataModel
//        height    Not available in ProductDataModel
//        mail_class    Not available in ProductDataModel
//        processing_category
//    }
}

struct ScheduleModel : Codable {
    var isExists : Bool?
}
