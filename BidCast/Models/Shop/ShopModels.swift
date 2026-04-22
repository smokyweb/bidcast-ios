//  ShopModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - GetCategoryResponse.kt
//    - GetAuctionTypeResponse.kt
//    - GetHowToSellResponse.kt
//    - GetLessonsResponse.kt
//    - GetPrepareStepResponse.kt
//    - GetCouponsResponse.kt
//    - GetPremierShopResponse.kt
//    - GetPromoteToolsResponse.kt
//    - GetPromoteToolsDetailsResponse.kt
//    - GetPromotePlansResponse.kt
//    - GetStatesResponse.kt
//    - FAQResponse.kt
//    - AboutUsResponse.kt / TermsConditionResponse.kt
//    - PageUrlResponse.kt
//    - GetShippingAddressResponse.kt (shipping address list)
//    - SetDefaultAddressResponse.kt
//
//  NOTE: Category / SubCategory themselves live in Common/SharedTypes.swift
//  because they're referenced everywhere. Shop-specific response wrappers
//  live here.

import Foundation

// MARK: - Category list (GET api/get-category)

typealias GetCategoryResponse = APIListResponse<Category>

// MARK: - Auction types (GET api/get-auction-type)

typealias GetAuctionTypeResponse = APIListResponse<AuctionTypeEntry>

struct AuctionTypeEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
}

/// Mirrors Android's AuctionType enum constants.
enum AuctionTypeId: Int {
    case buyNow = 5
    case live = 8
    case sportsCardBreak = 9
}

// MARK: - How to sell / Prepare / Lessons

typealias GetHowToSellResponse = APIListResponse<HowToSellStep>

struct HowToSellStep: Codable, Identifiable, Hashable {
    let id: Int?
    let title: String?
    let description: String?
    let image: String?
}

typealias GetPrepareStepResponse = APIListResponse<PrepareStep>

struct PrepareStep: Codable, Identifiable, Hashable {
    let id: Int?
    let title: String?
    let description: String?
    let status: String?
}

typealias GetLessonsResponse = APIListResponse<LessonEntry>

struct LessonEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let title: String?
    let description: String?
    let video: String?
}

// MARK: - Coupons (GET api/get-coupon)

typealias GetCouponsResponse = APIListResponse<UserCoupon>

struct UserCoupon: Codable, Identifiable, Hashable {
    let id: Int?
    let userId: Int?
    let couponId: Int?
    let status: Int?
    let assignedCount: Int?
    let coupon: Coupon?

    enum CodingKeys: String, CodingKey {
        case id, status, coupon
        case userId = "user_id"
        case couponId = "coupon_id"
        case assignedCount = "assigned_count"
    }
}

struct Coupon: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let description: String?
    let type: String?
    let value: Int?
    let minAmount: Int?
    let maxUsers: Int?
    let perUserLimit: Int?
    let usedCount: Int?
    let expDate: String?
    let startDate: String?
    let status: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, description, type, value, status
        case minAmount = "min_amount"
        case maxUsers = "max_users"
        case perUserLimit = "per_user_limit"
        case usedCount = "used_count"
        case expDate = "exp_date"
        case startDate = "start_date"
    }
}

// MARK: - Premier shop (GET api/get-premier-shop, POST api/apply-premier-shop)

typealias GetPremierShopResponse = APIResponse<PremierShopData>

struct PremierShopData: Codable, Hashable {
    let id: Int?
    let currentProgress: String?
    let pageTitle: String?
    let pageLogo: String?
    let pageDetails: String?
    let nextReview: String?
    let reviewTitle: String?
    let reviewLogo: String?
    let reviewDetails: String?
    let shopTitle: String?
    let shopLogo: String?
    let shopDetails: String?
    let features: [PremierShopFeature?]?
    let requirements: [PremierShopRequirement?]?
    let shopOptions: AnyCodable?         // TODO-PHASE2: concrete shape unclear, Android leaves fields open

    enum CodingKeys: String, CodingKey {
        case id, features, requirements
        case currentProgress = "current_progress"
        case pageTitle = "page_title"
        case pageLogo = "page_logo"
        case pageDetails = "page_details"
        case nextReview = "next_review"
        case reviewTitle = "review_title"
        case reviewLogo = "review_logo"
        case reviewDetails = "review_details"
        case shopTitle = "shop_title"
        case shopLogo = "shop_logo"
        case shopDetails = "shop_details"
        case shopOptions = "shop_options"
    }
}

struct PremierShopFeature: Codable, Hashable {
    let title: String?
    let description: String?
    let icon: String?
}

struct PremierShopRequirement: Codable, Hashable {
    let platform: String?
    let url: String?
}

// MARK: - Promote tools (GET api/get-promote-tools / api/promote-tool-details / GET api/get-promote-show)

typealias GetPromoteToolsResponse = APIResponse<PromoteToolsData>

struct PromoteToolsData: Codable, Hashable {
    let id: Int?
    let promoteTitle: String?
    let promoteDetails: String?
    let showTitle: String?
    let showIcon: String?
    let showDetails: String?
    let features: [PremierShopFeature?]?       // same shape as premier-shop features
    let showOptions: PromoteShowOptions?

    enum CodingKeys: String, CodingKey {
        case id, features
        case promoteTitle = "promote_title"
        case promoteDetails = "promote_details"
        case showTitle = "show_title"
        case showIcon = "show_icon"
        case showDetails = "show_details"
        case showOptions = "show_options"
    }
}

struct PromoteShowOptions: Codable, Hashable {
    let followers: Int?
    let shows: Int?
    let views: Int?

    enum CodingKeys: String, CodingKey {
        case followers = "Followers"             // QA-NOTE: Android preserves capitalization
        case shows = "Shows"
        case views = "Views"
    }
}

typealias GetPromoteToolsDetailsResponse = APIResponse<PromoteToolsDetailsData>

struct PromoteToolsDetailsData: Codable, Hashable {
    let bidsFromPromotion: Int?
    let communityBoot: Int?
    let ctr: AnyCodable?
    let dayReturnOnSpend: AnyCodable?
    let directSalesFormPromotion: AnyCodable?
    let firstTimeBuyersFromPromotion: AnyCodable?
    let followsFromPromotion: AnyCodable?
    let immediateReturnOnSpend: AnyCodable?
    let impessionPerHours: AnyCodable?
    let impressions: Int?
    let numberOfBoost: Int?
    let numberOfShowPromote: AnyCodable?
    let promoteHours: AnyCodable?
    let spend: AnyCodable?
    let sustainedWatches: AnyCodable?
    let sustainedWatchesRate: AnyCodable?
    let totalTapsaAndClicks: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case ctr, impressions, spend
        case bidsFromPromotion = "bids_from_promotion"
        case communityBoot = "community_boot"
        case dayReturnOnSpend = "7_day_return_on_spend"
        case directSalesFormPromotion = "direct_sales_form_promotion"
        case firstTimeBuyersFromPromotion = "first_time_buyers_from_promotion"
        case followsFromPromotion = "follows_from_promotion"
        case immediateReturnOnSpend = "immediate_return_on_spend"
        case impessionPerHours = "impession_per_hours"     // QA-NOTE: Android typo preserved
        case numberOfBoost = "number_of_boost"
        case numberOfShowPromote = "number_of_show_promote"
        case promoteHours = "promote_hours"
        case sustainedWatches = "sustained_watches"
        case sustainedWatchesRate = "sustained_watches_rate"
        case totalTapsaAndClicks = "total_tapsa_and_clicks"
    }
}

typealias GetPromotePlansResponse = APIListResponse<PromotePlan>

struct PromotePlan: Codable, Identifiable, Hashable {
    let id: Int?
    let title: String?
    let subTitle: String?
    let description: String?
    let price: String?
    let icon: String?
    let gradientColors: String?
    let colors: PromotePlanColors?

    enum CodingKeys: String, CodingKey {
        case id, title, description, price, icon, colors
        case subTitle = "sub_title"
        case gradientColors = "gradient_colors"
    }
}

struct PromotePlanColors: Codable, Hashable {
    let start: String?
    let end: String?
}

struct PromoteShowRequest: Encodable {
    let showId: Int
    let promotePlanId: Int?

    enum CodingKeys: String, CodingKey {
        case showId = "show_id"
        case promotePlanId = "promote_plan_id"
    }
}

// MARK: - States (GET api/get-states)

typealias GetStatesResponse = APIListResponse<USState>

struct USState: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let iso2: String?
}

// MARK: - Static pages

typealias FAQResponse = APIListResponse<FAQEntry>

struct FAQEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let question: String?
    let answer: String?
}

typealias AboutUsResponse = APIResponse<StaticPageData>
typealias TermsConditionResponse = APIResponse<StaticPageData>
typealias PrivacyPolicyResponse = APIResponse<StaticPageData>

struct StaticPageData: Codable, Hashable {
    let id: Int?
    let title: String?
    let content: String?
}

typealias PageUrlResponse = APIResponse<PageUrlData>

struct PageUrlData: Codable, Hashable {
    let url: String?
    let slug: String?
}

// MARK: - Shipping addresses list (GET api/get-shipping-address)

typealias GetShippingAddressResponse = APIListResponse<ShippingAddress>

// MARK: - Set default address (POST api/set-default-shipping-address)

typealias SetDefaultAddressResponse = APIResponse<ShippingAddress>
