//  NotificationModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Ported from Android:
//    - GetNotificationResponse.kt
//    - SettingListResponse.kt (notification + privacy preferences;
//      referenced from UserProfileData.preferences in AuthModels.swift)

import Foundation

// MARK: - GetNotificationResponse (POST api/notification/listing)

typealias GetNotificationResponse = APIPaginatedResponse<NotificationEntry>

struct NotificationEntry: Codable, Identifiable, Hashable {
    let id: Int?
    let title: String?
    let message: String?
    let type: String?
    let senderId: Int?
    let receiverId: Int?
    let isSeen: Int?             // QA-NOTE: Android keeps Int (0/1); not Bool.
    let createdAt: String?
    let updatedAt: String?

    var createdDate: Date? { ISO8601DateFormatter().date(from: createdAt ?? "") }

    enum CodingKeys: String, CodingKey {
        case id, title, message, type
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case isSeen = "is_seen"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - SettingListResponse (GET api/setting/list, POST api/setting/store)

typealias SettingListResponse = APIResponse<SettingListData>

/// Backs `UserProfileData.preferences`. Android mirrors every privacy +
/// notification + shop-level toggle here in one record.
struct SettingListData: Codable, Hashable {
    let id: Int?
    let userId: Int?
    let activityStatus: Bool?
    let countryOfResidence: String?
    let directMessage: Bool?
    let enableClips: Bool?
    let enablePrivateEntry: Bool?
    let freeShipping: Bool?
    let hapticFeedback: Bool?
    let instruction: String?
    let receiveGifts: Bool?
    let savePastShows: Bool?
    let shippingAddress: ShippingAddress?
    let shippingAddressId: Int?
    let showRewardStatus: Bool?
    let showSellerTools: Bool?
    let suggestMyAccount: Bool?
    let syncPhoneContacts: Bool?

    enum CodingKeys: String, CodingKey {
        case id, instruction
        case userId = "user_id"
        case activityStatus = "activity_status"
        case countryOfResidence = "country_of_residence"
        case directMessage = "direct_message"
        case enableClips = "enable_clips"
        case enablePrivateEntry = "enable_private_entry"
        case freeShipping = "free_shipping"
        case hapticFeedback = "haptic_feedback"
        case receiveGifts = "receive_gifts"
        case savePastShows = "save_past_shows"
        case shippingAddress = "shipping_address"
        case shippingAddressId = "shipping_address_id"
        case showRewardStatus = "show_reward_status"
        case showSellerTools = "show_seller_tools"
        case suggestMyAccount = "suggest_my_account"
        case syncPhoneContacts = "sync_phone_contacts"
    }
}

// MARK: - Notification settings request (POST api/setting/store)
// QA-NOTE: Android uses a multipart form with the same keys as
// SettingListData. Most flows only set one toggle at a time — we keep all
// optional so partial updates round-trip cleanly.

struct SettingStoreRequest: Encodable {
    let activityStatus: Bool?
    let directMessage: Bool?
    let enableClips: Bool?
    let enablePrivateEntry: Bool?
    let hapticFeedback: Bool?
    let receiveGifts: Bool?
    let savePastShows: Bool?
    let showRewardStatus: Bool?
    let showSellerTools: Bool?
    let suggestMyAccount: Bool?
    let syncPhoneContacts: Bool?
    let countryOfResidence: String?
    let instruction: String?
    let freeShipping: Bool?
    let shippingAddressId: Int?

    enum CodingKeys: String, CodingKey {
        case instruction
        case activityStatus = "activity_status"
        case directMessage = "direct_message"
        case enableClips = "enable_clips"
        case enablePrivateEntry = "enable_private_entry"
        case hapticFeedback = "haptic_feedback"
        case receiveGifts = "receive_gifts"
        case savePastShows = "save_past_shows"
        case showRewardStatus = "show_reward_status"
        case showSellerTools = "show_seller_tools"
        case suggestMyAccount = "suggest_my_account"
        case syncPhoneContacts = "sync_phone_contacts"
        case countryOfResidence = "country_of_residence"
        case freeShipping = "free_shipping"
        case shippingAddressId = "shipping_address_id"
    }
}
