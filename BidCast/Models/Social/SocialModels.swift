//  SocialModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - FollowUnfollowResponse.kt
//    - FetchReferralResponse.kt
//    - UserSearchingResponse.kt
//    - GetRatingResponse.kt

import Foundation

// MARK: - FollowUnfollowResponse (POST api/follow-unfollow)

typealias FollowUnfollowResponse = APIResponse<FollowUnfollowData>

struct FollowUnfollowData: Codable, Hashable {
    let status: Bool?
}

struct FollowUnfollowRequest: Encodable {
    let followId: Int

    enum CodingKeys: String, CodingKey {
        case followId = "follow_id"
    }
}

// MARK: - FetchReferralResponse (GET api/referral-code/fetch)

typealias FetchReferralResponse = APIResponse<ReferralData>

struct ReferralData: Codable, Hashable {
    let id: Int?
    let name: String?
    let referralCode: String?
    let totalEarnings: Int?
    let totalReferred: Int?
    let username: AnyCodable?       // QA-NOTE: Android types as Any?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case referralCode = "referral_code"
        case totalEarnings = "total_earnings"
        case totalReferred = "total_referred"
    }
}

// MARK: - UserSearchingResponse (POST api/user/searching)

typealias UserSearchingResponse = APIListResponse<SearchUserEntry>

struct SearchUserEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let username: String?
    let profileImage: String?
    let isFollowed: Bool?
    let followers: Int?
    let rating: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username, followers, rating, bio
        case profileImage = "profile_image"
        case isFollowed = "is_followed"
    }
}

struct SearchRequest: Encodable {
    let search: String
    let page: Int?

    enum CodingKeys: String, CodingKey {
        case search, page
    }
}

// MARK: - GetRatingResponse (GET api/get-seller-rating)

typealias GetRatingResponse = APIPaginatedResponse<SellerRatingEntry>

struct SellerRatingEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let rating: Int?
    let review: String?
    let userId: Int?
    let sellerId: Int?
    let createdAt: String?
    let user: UserPublic?

    enum CodingKeys: String, CodingKey {
        case id, rating, review, user
        case userId = "user_id"
        case sellerId = "seller_id"
        case createdAt = "created_at"
    }
}

struct StoreSellerRatingRequest: Encodable {
    let sellerId: Int
    let rating: Int
    let review: String?

    enum CodingKeys: String, CodingKey {
        case rating, review
        case sellerId = "seller_id"
    }
}

// MARK: - Block / Unblock (POST api/block-unblock, GET api/blocked-users)

typealias BlockedUnblockedResponse = APIResponse<BlockedUnblockedData>

struct BlockedUnblockedData: Codable, Hashable {
    let status: Bool?
}

typealias GetBlockedUsersResponse = APIResponse<GetBlockedUsersData>

struct GetBlockedUsersData: Codable, Hashable {
    let blockedByMe: [BlockedUser?]?
    let blockedMe: [BlockedUser?]?

    enum CodingKeys: String, CodingKey {
        case blockedByMe = "blocked_by_me"
        case blockedMe = "blocked_me"
    }
}

struct BlockedUser: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let image: String?
}

struct BlockUnblockRequest: Encodable {
    let userId: Int
    let action: String?

    enum CodingKeys: String, CodingKey {
        case action
        case userId = "user_id"
    }
}

// MARK: - Report (POST api/report-seller, GET api/report-categories)

typealias GetReportCategoriesResponse = APIListResponse<ReportCategoryEntry>

struct ReportCategoryEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let description: String?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ReportSellerRequest: Encodable {
    let sellerId: Int
    let categoryId: Int
    let description: String?

    enum CodingKeys: String, CodingKey {
        case description
        case sellerId = "seller_id"
        case categoryId = "category_id"
    }
}
