//  ShowModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - CreateShowResponse.kt / GetMyShowResponse.kt
//    - GetShowDetailsResponse.kt / GetShowOverviewResponse.kt
//    - CheckScheduleShowResponse.kt
//    - UpdateLiveStatusResponse.kt
//    - GenerateTokenResponse.kt / GetAgoraTokenResponse.kt
//    - GetLiveSellerResponse.kt
//    - FetchBidResponse.kt / CreateBidResponse.kt
//    - GetAllTipsResponse.kt / SentTipAmountResponse.kt / GetTipAmountResponse.kt
//    - LiveShowModel.kt / LiveShowModelOld.kt / LiveChatModel.kt / LiveSocketModel.kt
//    - StreamModel.kt / PollModel.kt / PollOptionModel.kt
//    - Socket responses: AuctionStartedResponse, AuctionStartedBreakSpotResponse,
//      GetFreebieObject, NotLiveShowResponse

import Foundation

// MARK: - Show (reused across MyShow / ShowDetails / Overview)

struct Show: Codable, Identifiable, Hashable {
    let id: Int?
    let userId: Int?
    let title: String?
    let date: String?
    let time: String?
    let categoryId: Int?
    let subCategoryId: Int?
    let auctionTypeId: Int?
    let isLive: Bool?
    let isExplicit: Bool?
    let isRepeat: Bool?
    let isPromote: String?
    let language: String?
    let repeatValue: String?
    let rtcToken: String?
    let roomId: String?
    let showDiscoverability: String?
    let startedAt: AnyCodable?
    let promoteShowId: AnyCodable?
    let promotedAt: AnyCodable?
    let recordingResourceId: AnyCodable?
    let recordingSid: AnyCodable?
    let shareCount: Int?
    let viewerCount: Int?
    let latestViewerCount: Int?
    let totalOrders: Int?
    let totalSalesAmount: Double?
    let productIds: [String?]?
    let products: [WireProduct?]?
    let thumbnail: [String?]?
    let imgThumbnail: [String?]?
    let category: Category?
    let subCategory: SubCategory?
    let user: UserPublic?
    let auction: ShowAuction?

    /// BUGFIX 2026-04-29 (MC task cmohlxj0h): the backend `is_live` flag has
    /// historically been set to `true` for scheduled shows that have not yet
    /// started streaming, which caused the red "LIVE" badge to appear on
    /// upcoming shows on the iOS home feed. Treat a show as actually live only
    /// when it ALSO has the streaming primitives the viewer screen needs
    /// (a non-empty rtc_token AND room_id) AND a non-null started_at.
    var isActuallyLive: Bool {
        guard isLive == true else { return false }
        let hasToken = (rtcToken?.isEmpty == false)
        let hasRoom  = (roomId?.isEmpty == false)
        let started: Bool = (startedAt?.value != nil)
        return hasToken && hasRoom && started
    }

    enum CodingKeys: String, CodingKey {
        case id, title, date, time, language, products, thumbnail, category, user, auction
        case userId = "user_id"
        case categoryId = "category_id"
        case subCategoryId = "sub_category_id"
        case auctionTypeId = "auction_type_id"
        case isLive = "is_live"
        case isExplicit = "is_explicit"
        case isRepeat = "is_repeat"
        case isPromote = "is_promote"
        case repeatValue = "repeat_value"
        case rtcToken = "rtc_token"
        case roomId = "room_id"
        case showDiscoverability = "show_discoverability"
        case startedAt = "started_at"
        case promoteShowId = "promote_show_id"
        case promotedAt = "promoted_at"
        case recordingResourceId = "recording_resource_id"
        case recordingSid = "recording_sid"
        case shareCount = "share_count"
        case viewerCount = "viewer_count"
        case latestViewerCount = "latest_viewer_count"
        case totalOrders = "total_orders"
        case totalSalesAmount = "total_sales_amount"
        case productIds = "product_ids"
        case imgThumbnail = "img_thumbnail"
        case subCategory = "sub_category"
    }
}

struct ShowAuction: Codable, Hashable {
    let id: Int?
    let name: String?
}

// MARK: - CreateShow / GetMyShow / Show Details

typealias CreateShowResponse = APIResponse<Show>
typealias GetMyShowResponse = APIPaginatedResponse<Show>
typealias GetShowDetailsResponse = APIResponse<Show>

// MARK: - GetShowOverviewResponse (GET api/get-show-overview)

typealias GetShowOverviewResponse = APIResponse<ShowOverviewData>

struct ShowOverviewData: Codable, Hashable {
    let contributionsCount: Double?
    let newFollowers: Int?
    let fileUrl: String?
    let orderCount: Int?
    let shareCount: Int?
    let totalBids: Int?
    let totalSales: String?
    let videoDuration: String?
    let viewerCount: Int?

    enum CodingKeys: String, CodingKey {
        case contributionsCount = "contributions_count"
        case newFollowers = "new_followers"
        case fileUrl = "file_url"
        case orderCount = "order_count"
        case shareCount = "share_count"
        case totalBids = "total_bids"
        case totalSales = "total_sales"
        case videoDuration = "video_duration"
        case viewerCount = "viewer_count"
    }
}

// MARK: - CheckScheduleShowResponse (POST api/check-schedule-show)

typealias CheckScheduleShowResponse = APIResponse<CheckScheduleShowData>

struct CheckScheduleShowData: Codable, Hashable {
    let isExists: Bool?
}

// MARK: - UpdateLiveStatusResponse (POST api/schedule-show/update-live-status)

typealias UpdateLiveStatusResponse = APIResponse<Show>

// MARK: - GenerateTokenResponse (POST api/generate-token)

typealias GenerateTokenResponse = APIResponse<ZegoTokenData>

/// QA-NOTE: Android uses `app_sing` (typo in backend) — preserved.
struct ZegoTokenData: Codable, Hashable {
    let appId: String?
    let appSing: String?
    let roomId: String?
    let token: String?
    let userId: Int?

    enum CodingKeys: String, CodingKey {
        case appId = "app_id"
        case appSing = "app_sing"
        case roomId = "room_id"
        case token
        case userId = "user_id"
    }
}

// MARK: - GetAgoraTokenResponse (POST api/agora-token)

typealias GetAgoraTokenResponse = APIResponse<AgoraTokenData>

struct AgoraTokenData: Codable, Hashable {
    let channel: String?
    let expiresAt: Int?
    let token: String?
    let uid: Int?

    enum CodingKeys: String, CodingKey {
        case channel, token, uid
        case expiresAt = "expires_at"
    }
}

// MARK: - GetLiveSellerResponse (GET api/get-live-seller)

typealias GetLiveSellerResponse = APIListResponse<LiveSellerEntry>

struct LiveSellerEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let email: String?
    let profileImage: String?
    let roomId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case profileImage = "profile_image"
        case roomId = "room_id"
    }
}

// MARK: - Bids

typealias FetchBidResponse = APIPaginatedResponse<BidEntry>

struct BidEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let bidPrice: Double?
    let createdAt: String?
    let createdBy: Int?
    let scheduleShowId: Int?
    let productId: Int?
    let userId: Int?
    let product: WireProduct?
    let user: UserPublic?

    enum CodingKeys: String, CodingKey {
        case id, product, user
        case bidPrice = "bid_price"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case scheduleShowId = "schedule_show_id"
        case productId = "product_id"
        case userId = "user_id"
    }
}

typealias CreateBidResponse = APIResponse<CreateBidData>

struct CreateBidData: Codable, Hashable {
    let id: Int?
    let bidPrice: Int?
    let createdBy: Int?
    let productId: Int?
    let scheduleShowId: Int?
    let userId: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case bidPrice = "bid_price"
        case createdBy = "created_by"
        case productId = "product_id"
        case scheduleShowId = "schedule_show_id"
        case userId = "user_id"
    }
}

// MARK: - Tips

typealias GetAllTipsResponse = APIResponse<GetAllTipsData>

struct GetAllTipsData: Codable, Hashable {
    let example: [String?]?
    let tips: [TipSetting]?
}

struct TipSetting: Codable, Hashable {
    let title: String?
    let description: String?
    let icon: String?
    let color: String?
}

typealias SentTipAmountResponse = APIResponse<SentTipData>

struct SentTipData: Codable, Hashable {
    let id: Int?
    let cardNumber: String?
    let date: String?
    let discount: Int?
    let sellerId: String?
    let userId: Int?
    let shippingCharges: Int?
    let sourceType: String?
    let status: String?
    let subTotal: Int?
    let taxAmount: Int?
    let total: Int?
    let type: String?

    enum CodingKeys: String, CodingKey {
        case id, date, discount, status, type, total
        case cardNumber = "card_number"
        case sellerId = "seller_id"
        case userId = "user_id"
        case shippingCharges = "shipping_charges"
        case sourceType = "source_type"
        case subTotal = "sub_total"
        case taxAmount = "tax_amount"
    }
}

typealias GetTipAmountResponse = APIResponse<GetTipAmountData>

struct GetTipAmountData: Codable, Hashable {
    let summary: TipSummary?
    let tips: [TipEntry]?
}

struct TipSummary: Codable, Hashable {
    let todayTips: Int?
    let totalTips: String?

    enum CodingKeys: String, CodingKey {
        case todayTips = "today_tips"
        case totalTips = "total_tips"
    }
}

struct TipEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let createdAt: String?
    let total: String?
    let userId: Int?
    let user: UserPublic?
    let showId: Int?
    let show: Show?

    enum CodingKeys: String, CodingKey {
        case id, total, user, show
        case createdAt = "created_at"
        case userId = "user_id"
        case showId = "show_id"
    }
}

// MARK: - Live chat (Firebase-backed ZIM/ChatModel)

// NOTE 2026-04-22: the former lightweight `LiveChatMessage` stub here collided
// with the Phase 5 parity version in `BidCast/Live/Chat/LiveChatMessage.swift`
// (richer model with Kind enum + `fromChatPayload` + `LiveChatBuffer`).
// The Phase 5 version is what the view controllers / cells actually use, so
// the stub has been removed. If a Firebase-backed lightweight wire model is
// needed later, add it under a distinct name (e.g. `LiveChatWire`).

// MARK: - Poll / Randomizer / Raid (local UI state models)

struct Poll: Codable, Identifiable, Hashable {
    let id: String?
    let question: String?
    let options: [PollOption]?
    let isOpen: Bool?
    let durationSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case id, question, options
        case isOpen = "is_open"
        case durationSeconds = "duration_seconds"
    }
}

struct PollOption: Codable, Identifiable, Hashable {
    let id: String?
    let label: String?
    let votes: Int?
}

struct PollVote: Codable, Hashable {
    let pollId: String?
    let optionId: String?
    let userId: Int?

    enum CodingKeys: String, CodingKey {
        case pollId = "poll_id"
        case optionId = "option_id"
        case userId = "user_id"
    }
}

struct PollResult: Codable, Hashable {
    let pollId: String?
    let options: [PollOption]?
    let totalVotes: Int?

    enum CodingKeys: String, CodingKey {
        case options
        case pollId = "poll_id"
        case totalVotes = "total_votes"
    }
}

struct RandomizerWinner: Codable, Hashable {
    let user: UserPublic?
    let showId: String?
    let productSetId: Int?

    enum CodingKeys: String, CodingKey {
        case user
        case showId = "show_id"
        case productSetId = "product_set_id"
    }
}

struct RaidPayload: Codable, Hashable {
    let fromRoomId: String?
    let toRoomId: String?
    let fromUserId: Int?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case message
        case fromRoomId = "from_room_id"
        case toRoomId = "to_room_id"
        case fromUserId = "from_user_id"
    }
}

// MARK: - Room / Channel (Agora + ZIM)

struct LiveRoom: Codable, Hashable {
    let roomId: String?
    let channelName: String?
    let token: String?
    let userId: Int?

    enum CodingKeys: String, CodingKey {
        case token
        case roomId = "room_id"
        case channelName = "channel_name"
        case userId = "user_id"
    }
}

// MARK: - Socket responses

struct AuctionStartedSocket: Codable, Hashable {
    let auctionStartedAt: String?
    let auctionTypeId: Int?
    let counterBidTime: Int?
    let product: WireProduct?
    let productIds: [String?]?
    let requireTime: Int?
    let roomId: String?
    let startingBidAmount: String?
    let status: String?
    let suddenDeath: Bool?

    enum CodingKeys: String, CodingKey {
        case product, status
        case auctionStartedAt = "auction_started_at"
        case auctionTypeId = "auction_type_id"
        case counterBidTime = "counter_bid_time"
        case productIds = "product_ids"
        case requireTime = "require_time"
        case roomId = "room_id"
        case startingBidAmount = "starting_bid_amount"
        case suddenDeath = "sudden_death"
    }
}

struct AuctionStartedBreakSpotSocket: Codable, Hashable {
    let auctionStartedAt: String?
    let counterBidTime: Int?
    let productSetId: String?
    let productSetItemId: String?
    let productSetItemUnitId: String?
    let requireTime: Int?
    let roomId: String?
    let startingBidAmount: String?
    let status: String?
    let suddenDeath: Bool?
    let surpriseSetDetails: SurpriseSetDetails?

    enum CodingKeys: String, CodingKey {
        case productSetId, productSetItemId, productSetItemUnitId, status
        case auctionStartedAt = "auction_started_at"
        case counterBidTime = "counter_bid_time"
        case requireTime = "require_time"
        case roomId = "room_id"
        case startingBidAmount = "starting_bid_amount"
        case suddenDeath = "sudden_death"
        case surpriseSetDetails = "surprise_set_details"
    }
}

struct SurpriseSetDetails: Codable, Hashable {
    let productSet: OrderProductSet?
    let productSetItem: OrderProductSetItem?
    let soldQuantity: Int?
    let totalQuantity: Int?

    enum CodingKeys: String, CodingKey {
        case productSet = "product_set"
        case productSetItem = "product_set_item"
        case soldQuantity = "sold_quantity"
        case totalQuantity = "total_quantity"
    }
}

struct FreebiePayload: Codable, Hashable {
    let freebie: FreebieEntry?
    let usersList: [UserPublic]?

    enum CodingKeys: String, CodingKey {
        case freebie
        case usersList = "users_list"
    }
}

struct FreebieEntry: Codable, Hashable {
    let id: Int?
    let duration: String?
    let productId: Int?
    let showId: String?
    let roomId: String?

    enum CodingKeys: String, CodingKey {
        case id, duration
        case productId = "product_id"
        case showId = "show_id"
        case roomId = "room_id"
    }
}

/// Matches Android's NotLiveShowResponse socket shape. QA-NOTE: `productIds`
/// can come back either as array or object on the wire — Android has a
/// custom Gson deserializer. On Swift we accept an array only for now —
/// TODO-PHASE3: handle object form if backend still sends it.
struct NotLiveShowSocket: Codable, Hashable {
    let id: Int?
    let showId: String?
    let roomId: String?
    let userId: Int?
    let title: String?
    let date: String?
    let time: String?
    let categoryId: Int?
    let isLive: Int?
    let isExplicit: Int?
    let isRepeat: Int?
    let isPromote: String?
    let isPromoted: Int?
    let isRoomCreated: Bool?
    let language: String?
    let latestViewerCount: Int?
    let productIds: [String?]?
    let thumbnail: String?
    let imgThumbnail: String?
    let auctionTypeId: Int?
    let shareCount: Int?
    let viewerCount: Int?
    let seller: NotLiveSeller?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, date, time, language, thumbnail, seller
        case showId = "show_id"
        case roomId = "room_id"
        case userId = "user_id"
        case categoryId = "category_id"
        case isLive = "is_live"
        case isExplicit = "is_explicit"
        case isRepeat = "is_repeat"
        case isPromote = "is_promote"
        case isPromoted = "is_promoted"
        case isRoomCreated = "is_room_created"
        case latestViewerCount = "latest_viewer_count"
        case productIds = "product_ids"
        case imgThumbnail = "img_thumbnail"
        case auctionTypeId = "auction_type_id"
        case shareCount = "share_count"
        case viewerCount = "viewer_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct NotLiveSeller: Codable, Hashable {
    let id: Int?
    let username: String?
    let profileImage: String?
    let rating: String?

    enum CodingKeys: String, CodingKey {
        case id, username, rating
        case profileImage = "profile_image"
    }
}

// MARK: - Clips

typealias GetClipsResponse = APIPaginatedResponse<ClipEntry>
typealias MakeClipResponse = APIResponse<ClipEntry>

struct ClipEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let clipUrl: String?
    let thumbnailUrl: String?
    let showId: String?
    let userId: AnyCodable?
    let isPublic: String?

    enum CodingKeys: String, CodingKey {
        case id
        case clipUrl = "clip_url"
        case thumbnailUrl = "thumbnail_url"
        case showId = "show_id"
        case userId = "user_id"
        case isPublic = "is_public"
    }
}

// MARK: - Live stream message (generic ZIM payload)

struct LiveStreamMessage: Codable, Hashable {
    let type: String?
    let message: String?
    let userId: String?
    let userName: String?
    let userImage: String?
    let timestamp: Int?

    enum CodingKeys: String, CodingKey {
        case type, message, timestamp
        case userId = "user_id"
        case userName = "user_name"
        case userImage = "user_image"
    }
}
