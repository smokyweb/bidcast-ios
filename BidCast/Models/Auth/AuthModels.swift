//  AuthModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - LoginResponse.kt
//    - SignUpResponse.kt
//    - UserProfileResponse.kt
//    - UserDeviceResponse.kt
//    - GetUserProfileResponse.kt
//
//  Request bodies already exist on iOS (SignInRequest, SignUpRequest,
//  VerifyOtpRequest, ResetPasswordRequest, UpdatePasswordRequest,
//  ForgetRequest, LogoutRequest, DeviceDetailParam) under each screen's
//  Model/ folder. Phase 2 adds the matching *Response* structs here so
//  Phase 3 can call `APIResponse<LoginData>` / etc.

import Foundation

// MARK: - LoginResponse (POST api/login)

typealias LoginResponse = APIResponse<LoginData>

struct LoginData: Codable, Hashable {
    let id: Int?
    let roleId: String?
    let firstName: String?
    let lastName: String?
    let name: String?
    let email: String?
    let username: String?
    let profileImage: String?
    let isFirsttimeLogin: Bool?
    let token: String?
    let role: Role?

    enum CodingKeys: String, CodingKey {
        case id, name, email, username, token, role
        case roleId = "role_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
        case isFirsttimeLogin = "is_FirsttimeLogin"
        // QA-NOTE: Android uses the camelCase-inside-snake_case literal
        // "is_FirsttimeLogin" — don't normalize.
    }
}

// MARK: - SignUpResponse (POST api/register)

typealias SignUpResponse = APIResponse<SignUpData>

struct SignUpData: Codable, Hashable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let name: String?
    let email: String?
    let roleId: Int?       // QA-NOTE: Int here vs String in LoginData.roleId
    let token: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, token
        case firstName = "first_name"
        case lastName = "last_name"
        case roleId = "role_id"
    }
}

// MARK: - UserProfileResponse (GET api/get-profile)

typealias UserProfileResponse = APIResponse<UserProfileData>

struct UserProfileData: Codable, Hashable {
    let id: Int?
    let roleId: Int?
    let firstName: String?
    let lastName: String?
    let name: String?
    let email: String?
    let username: String?
    let bio: String?
    let profileImage: String?
    let thumbnail: AnyCodable?
    let referralCode: String?
    let isActive: Bool?
    let isFirstShowCreated: Bool?
    let sellerIdentityStatus: String?
    let buyerIdentityStatus: String?
    let hasShippingAddress: Bool?
    let hasCardAdded: Bool?
    let walletAmount: AnyCodable?
    let couponCount: Int?
    let role: Role?
    let defaultCard: DefaultCard?
    let defaultShippingAddress: ShippingAddress?
    let preferences: SettingListData?

    enum CodingKeys: String, CodingKey {
        case id, name, email, username, bio, thumbnail, role
        case roleId = "role_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
        case referralCode = "referral_code"
        case isActive = "is_active"
        case isFirstShowCreated = "is_FirstShowCreated"    // QA-NOTE: Android literal preserved
        case sellerIdentityStatus = "seller_identity_status"
        case buyerIdentityStatus = "buyer_identity_status"
        case hasShippingAddress = "has_shipping_address"
        case hasCardAdded = "has_card_added"
        case walletAmount = "wallet_amount"
        case couponCount = "coupon_count"
        case defaultCard = "default_card"
        case defaultShippingAddress = "default_shipping_address"
        case preferences = "preference"
    }
}

struct DefaultCard: Codable, Hashable {
    let cardId: String?
    let expDate: String?
    let last4: String?

    enum CodingKeys: String, CodingKey {
        case last4
        case cardId = "card_id"
        case expDate = "exp_date"
    }
}

// MARK: - GetUserProfileResponse (POST api/get-profile-by-id)
// Android GetUserProfileResponse extends the profile shape with social
// metrics (followers, followings, etc.).

typealias GetUserProfileResponse = APIResponse<PublicUserProfile>

struct PublicUserProfile: Codable, Hashable {
    let id: Int?
    let name: String?
    let firstName: String?
    let lastName: String?
    let username: String?
    let email: String?
    let bio: String?
    let profileImage: String?
    let thumbnail: AnyCodable?
    let roleId: Int?
    let isActive: Bool?
    let isFollowed: Bool?
    let followers: Int?
    let followings: Int?
    let profileVisits: Int?
    let rating: String?
    let avgShip: String?
    let soldCount: Int?
    let isBlocked: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, username, email, bio, thumbnail, rating, followers, followings
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
        case roleId = "role_id"
        case isActive = "is_active"
        case isFollowed = "is_followed"
        case profileVisits = "profile_visits"
        case avgShip = "avg_ship"
        case soldCount = "sold_count"
        case isBlocked = "is_blocked"
    }
}

// MARK: - UserDeviceResponse (POST api/upsert-device-details)

typealias UserDeviceResponse = APIResponse<UserDeviceData>

struct UserDeviceData: Codable, Hashable {
    let id: Int?
    let userId: Int?
    let deviceToken: String?
    let platform: String?
    let appVersion: String?
    let timeZone: String?

    enum CodingKeys: String, CodingKey {
        case id, platform
        case userId = "user_id"
        case deviceToken = "device_token"
        case appVersion = "app_version"
        case timeZone = "time_zone"
    }
}

// MARK: - Request bodies (additive — some already exist on iOS screens)

/// POST api/upsert-device-details — canonical iOS request shape.
struct DeviceDetailsRequest: Encodable {
    let deviceToken: String
    let platform: String
    let appVersion: String
    let timeZone: String

    enum CodingKeys: String, CodingKey {
        case platform
        case deviceToken = "device_token"
        case appVersion = "app_version"
        case timeZone = "time_zone"
    }
}
