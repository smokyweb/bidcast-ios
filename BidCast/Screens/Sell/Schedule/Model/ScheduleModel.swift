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
    var variant: [ProductVariant]?
    var productCondition: String?
    var productShow: String?

    var acceptOffers: Bool?
    var auction: Bool?
    var flashSale: Bool?
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

extension ProductDataModel1 {

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
