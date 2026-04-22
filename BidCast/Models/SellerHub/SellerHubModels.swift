//  SellerHubModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - SellerHubResponse.kt
//    - SellerStatusResponse.kt
//    - SellerInfoResponse.kt
//    - SellerAnalyticsResponse.kt
//    - SalesAnalyticsResponse.kt
//    - VisitorsAnalyticsResponse.kt
//    - GetOffersResponse.kt
//    - UpdateOfferResponse.kt
//    - GetShippingProfilesResponse.kt
//    - GetShippingDetailsResponse.kt
//    - GetUSPSboxDimensionsResponse.kt
//    - GetMailClassesResponse.kt

import Foundation

// MARK: - Seller hub summary (GET api/seller-hub-info)

typealias SellerHubResponse = APIResponse<SellerHubData>

struct SellerHubData: Codable, Hashable {
    let items: Int?
    let totalOrders: Int?
    let revenue: Double?
    let payouts: Double?
    let rating: Double?
    let vacationMode: Bool?
    let accountHealth: AccountHealth?
    let upcomingShow: Show?

    enum CodingKeys: String, CodingKey {
        case items, revenue, payouts, rating
        case totalOrders = "total_orders"
        case vacationMode = "vacation_mode"
        case accountHealth = "account_health"
        case upcomingShow = "upcoming_show"
    }
}

struct AccountHealth: Codable, Hashable {
    let defectFreeOrderRate: String?
    let onTimeScanRate: String?
    let policyStanding: String?

    enum CodingKeys: String, CodingKey {
        case defectFreeOrderRate = "defect_free_order_rate"
        case onTimeScanRate = "on_time_scan_rate"
        case policyStanding = "policy_standing"
    }
}

// MARK: - Seller status (GET api/seller-status)

typealias SellerStatusResponse = APIResponse<SellerStatusData>

struct SellerStatusData: Codable, Hashable {
    let marketplaceVendor: MarketplaceVendor?
    let liveSellVendor: LiveSellVendor?

    enum CodingKeys: String, CodingKey {
        case marketplaceVendor = "marketplace_vendor"
        case liveSellVendor = "live_sell_vendor"
    }
}

struct MarketplaceVendor: Codable, Hashable {
    let title: String?
    let status: String?
    let vendorSince: String?
    let sellerRating: Int?

    enum CodingKeys: String, CodingKey {
        case title, status
        case vendorSince = "vendor_since"
        case sellerRating = "seller_rating"
    }
}

struct LiveSellVendor: Codable, Hashable {
    let title: String?
    let status: String?
    let submitted: String?
}

// MARK: - Seller info (GET api/get-seller-info)

typealias SellerInfoResponse = APIResponse<SellerInfoData>

struct SellerInfoData: Codable, Hashable {
    let avgShip: AnyCodable?
    let isFollowing: Bool?
    let ratingAvg: Double?
    let review: AnyCodable?
    let sellerDetails: SellerDetails?
    let soldCount: Double?

    enum CodingKeys: String, CodingKey {
        case review
        case avgShip = "avg_ship"
        case isFollowing = "is_following"
        case ratingAvg = "rating_avg"
        case sellerDetails = "seller_details"
        case soldCount = "sold_count"
    }
}

struct SellerDetails: Codable, Hashable {
    let id: Int?
    let name: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let username: String?
    let profileImage: String?
    let thumbnail: String?
    let profileVisits: Int?
    let referralCode: String?
    let roleId: Int?
    let isActive: Bool?
    let isFirsttimeLogin: Bool?
    let liveSellVendorStatus: String?
    let marketplaceVendorStatus: String?
    let bio: AnyCodable?
    let authorizeNetCid: AnyCodable?
    let defaultCardId: AnyCodable?
    let jwtToken: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case id, name, email, username, bio, thumbnail
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
        case profileVisits = "profile_visits"
        case referralCode = "referral_code"
        case roleId = "role_id"
        case isActive = "is_active"
        case isFirsttimeLogin = "is_FirsttimeLogin"    // QA-NOTE: Android literal preserved
        case liveSellVendorStatus = "live_sell_vendor_status"
        case marketplaceVendorStatus = "marketplace_vendor_status"
        case authorizeNetCid = "authorize_net_cid"
        case defaultCardId = "default_card_id"
        case jwtToken = "jwt_token"
    }
}

// MARK: - Seller analytics (GET api/seller-analytic)

typealias SellerAnalyticsResponse = APIResponse<SellerAnalyticsData>

struct SellerAnalyticsData: Codable, Hashable {
    let seller: AnalyticsSellerStub?
    let stats: AnalyticsStats?
    let topBuyersByOrders: [AnalyticsTopBuyer?]?
    let topBuyersBySales: [AnalyticsTopBuyer?]?
    let totalAllOrders: Int?
    let totalAllSales: String?

    enum CodingKeys: String, CodingKey {
        case seller, stats
        case topBuyersByOrders = "top_buyers_by_orders"
        case topBuyersBySales = "top_buyers_by_sales"
        case totalAllOrders = "total_all_orders"
        case totalAllSales = "total_all_sales"
    }
}

struct AnalyticsSellerStub: Codable, Hashable {
    let id: Int?
    let name: String?
    let profile: String?
    let since: String?
}

struct AnalyticsStats: Codable, Hashable {
    let followers: Int?
    let liveSessions: Int?
    let rating: Int?
    let revenue: String?
    let totalItems: Int?
    let totalSales: Int?

    enum CodingKeys: String, CodingKey {
        case followers, rating, revenue
        case liveSessions = "live_sessions"
        case totalItems = "total_items"
        case totalSales = "total_sales"
    }
}

struct AnalyticsTopBuyer: Codable, Hashable {
    let userId: Int?
    let totalOrders: Int?
    let totalSales: String?
    let user: UserPublic?

    enum CodingKeys: String, CodingKey {
        case user
        case userId = "user_id"
        case totalOrders = "total_orders"
        case totalSales = "total_sales"
    }
}

// MARK: - Sales analytics (GET api/seller/sales-performance)

typealias SalesAnalyticsResponse = APIResponse<SalesAnalyticsData>

struct SalesAnalyticsData: Codable, Hashable {
    let filter: String?
    let range: [String?]?
    let chart: [SalesChartPoint?]?
}

struct SalesChartPoint: Codable, Hashable {
    let label: String?
    let totalRevenue: String?
    let totalSales: Int?

    enum CodingKeys: String, CodingKey {
        case label
        case totalRevenue = "total_revenue"
        case totalSales = "total_sales"
    }
}

// MARK: - Visitors analytics (GET api/seller/visitor-analytics)

typealias VisitorsAnalyticsResponse = APIResponse<VisitorsAnalyticsData>

struct VisitorsAnalyticsData: Codable, Hashable {
    let filter: String?
    let range: [AnyCodable]?
    let chart: [VisitorsChartPoint?]?
}

struct VisitorsChartPoint: Codable, Hashable {
    let label: String?
    let totalVisitors: String?

    enum CodingKeys: String, CodingKey {
        case label
        case totalVisitors = "total_visitors"
    }
}

// MARK: - Offers (POST api/offer/lists / make / update-status, api/user/favorite)

/// QA-NOTE: Android top-level envelope adds status-count fields
/// (pending / accepted / declined) alongside the pagination keys.
struct GetOffersResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let totalPage: Int?
    let pending: Int?
    let accepted: Int?
    let declined: Int?
    let data: [OfferEntry?]?

    enum CodingKeys: String, CodingKey {
        case status, message, data, currentPage, perPage, total, totalPage, pending, accepted, declined
        case errorType = "error_type"
    }
}

struct OfferEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let amount: String?
    let status: String?
    let productId: Int?
    let userId: Int?
    let product: OfferProductStub?
    let user: OfferUserStub?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, amount, status, product, user
        case productId = "product_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct OfferProductStub: Codable, Identifiable, Hashable {
    let id: Int?
    let title: String?
    let pricing: String?
    let images: [String?]?
}

struct OfferUserStub: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profileImage = "profile_image"
    }
}

struct MakeOfferRequest: Encodable {
    let productId: Int
    let amount: String

    enum CodingKeys: String, CodingKey {
        case amount
        case productId = "product_id"
    }
}

struct UpdateOfferStatusRequest: Encodable {
    let offerId: Int
    let status: String       // accepted / declined / counter

    enum CodingKeys: String, CodingKey {
        case status
        case offerId = "offer_id"
    }
}

typealias UpdateOfferResponse = APIResponse<OfferEntry>

// MARK: - Shipping profiles (GET api/get-shipping-profile, POST api/store-shipping-profile)

typealias GetShippingProfilesResponse = APIListResponse<ShippingProfile>

struct ShippingProfile: Codable, Identifiable, Hashable {
    let id: Int?
    let userId: Int?
    let name: String?
    let size: String?
    let scale: String?
    let height: String?
    let width: String?
    let length: String?
    let weight: String?
    let incrementWeight: String?
    let incrementWeightScale: String?
    let maxItemUnit: String?
    let additionalWeight: Bool?
    let maxItems: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, size, scale, height, width, length, weight
        case userId = "user_id"
        case incrementWeight = "increment_weight"
        case incrementWeightScale = "increment_weight_scale"
        case maxItemUnit = "max_item_unit"
        case additionalWeight = "additionalWeight"
        case maxItems = "maxItems"
    }
}

// MARK: - Shipping details (GET api/get-shipping-details)

typealias GetShippingDetailsResponse = APIResponse<ShippingDetailsData>

struct ShippingDetailsData: Codable, Hashable {
    let domesticShipmentSetting: DomesticShipmentSetting?
    let freePickup: Bool?
    let shippingAddress: ShippingAddress?
    let instruction: String?
    let shippingProfilesCount: Int?

    enum CodingKeys: String, CodingKey {
        case instruction
        case domesticShipmentSetting = "domestic_shipment_setting"
        case freePickup = "free_pickup"
        case shippingAddress = "shipping_address"
        case shippingProfilesCount = "shipping_profiles_count"
    }
}

struct DomesticShipmentSetting: Codable, Hashable {
    let id: Int?
    let userId: Int?
    let alsoApplyScheduleShow: Bool?
    let shippingCostsAlsoApplyToScheduledShows: Bool?
    let shippingCosts: String?
    let domesticShipmentForm1To5Lbs: AnyCodable?
    let domesticShipmentOver5Lbs: AnyCodable?
    let uspsFirstClassMailLetter: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case alsoApplyScheduleShow = "also_apply_schedule_show"
        case shippingCostsAlsoApplyToScheduledShows = "shipping_cost_also_apply_schedule_show"
        case shippingCosts = "shipping_costs"
        case domesticShipmentForm1To5Lbs = "domestic_shipment_form_1_to_5_lbs"
        case domesticShipmentOver5Lbs = "domestic_shipment_over_5_lbs"
        case uspsFirstClassMailLetter = "usps_first_class_mail_letter"
    }
}

// MARK: - USPS box dimensions (GET api/get-usps-shipping-price)

typealias GetUSPSBoxDimensionsResponse = APIListResponse<USPSBoxDimension>

struct USPSBoxDimension: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let type: String?
    let unit: String?
    let height: String?
    let length: String?
    let width: String?
    let shippingPrice: String?
    let greatFor: String?

    enum CodingKeys: String, CodingKey {
        case id, name, type, unit, height, length, width
        case shippingPrice = "shipping_price"
        case greatFor = "great _for"     // QA-NOTE: Android literal preserved (space before _for)
    }
}

// MARK: - Mail classes (GET api/usps/mail-classes)

typealias GetMailClassesResponse = APIResponse<MailClassesData>

struct MailClassesData: Codable, Hashable {
    let mailClasses: [MailClass?]?

    enum CodingKeys: String, CodingKey {
        case mailClasses = "mail_classes"
    }
}

struct MailClass: Codable, Hashable {
    let label: String?
    let maxWeightLbs: Double?
    let maxLengthIn: Double?
    let maxWidthIn: Double?
    let maxHeightIn: Double?
    let maxLengthPlusGirthIn: Double?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case label, notes
        case maxWeightLbs = "max_weight_lbs"
        case maxLengthIn = "max_length_in"
        case maxWidthIn = "max_width_in"
        case maxHeightIn = "max_height_in"
        case maxLengthPlusGirthIn = "max_length_plus_girth_in"
    }
}

// MARK: - Surprise product sets (POST/GET api/store-surprise-product, api/get-surprise-product, api/get-set-details)

typealias GetSurpriseProductsResponse = APIPaginatedResponse<SurpriseProductSet>

struct SurpriseProductSet: Codable, Identifiable, Hashable {
    let id: Int?
    let userId: Int?
    let name: String?
    let description: String?
    let price: Double?
    let autoRandomizer: Int?
    let isLiveBid: Int?
    let quickSpin: Int?
    let shippingProfileId: Int?
    let status: String?
    let type: String?
    let items: [SurpriseProductSetItem?]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, status, type, items
        case userId = "user_id"
        case autoRandomizer = "auto_randomizer"
        case isLiveBid = "is_live_bid"
        case quickSpin = "quick_spin"
        case shippingProfileId = "shipping_profile_id"
    }
}

struct SurpriseProductSetItem: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let description: String?
    let productSetId: Int?
    let quantity: Int?
    let soldQuantity: Int?
    let status: String?
    let units: [SurpriseProductSetItemUnit?]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, quantity, status, units
        case productSetId = "product_set_id"
        case soldQuantity = "sold_quantity"
    }
}

struct SurpriseProductSetItemUnit: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let description: String?
    let price: Double?
    let productSetItemId: Int?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, status
        case productSetItemId = "product_set_item_id"
    }
}

typealias ProductSetDetailsResponse = APIResponse<ProductSetDetailsData>

struct ProductSetDetailsData: Codable, Hashable {
    let id: Int?
    let userId: Int?
    let name: String?
    let description: String?
    let price: Int?
    let autoRandomizer: Int?
    let isLiveBid: Int?
    let quickSpin: Int?
    let shippingProfileId: Int?
    let status: String?
    let type: String?
    let items: [SurpriseProductSetItem?]?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, price, status, type, items
        case userId = "user_id"
        case autoRandomizer = "auto_randomizer"
        case isLiveBid = "is_live_bid"
        case quickSpin = "quick_spin"
        case shippingProfileId = "shipping_profile_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
