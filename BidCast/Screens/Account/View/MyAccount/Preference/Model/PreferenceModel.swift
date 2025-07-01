//
//  PreferenceModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 02/06/25.
//

import Foundation


struct PreferenceDataModel: Codable {
    var id, userID: Int?
    var countryOfResidence: String?
    var directMessage, receiveGifts, enablePrivateEntry, showRewardStatus: Bool?
    var showSellerTools, enableClips, savePastShows, activityStatus: Bool?
    var syncPhoneContacts, suggestMyAccount, hapticFeedback: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case countryOfResidence = "country_of_residence"
        case directMessage = "direct_message"
        case receiveGifts = "receive_gifts"
        case enablePrivateEntry = "enable_private_entry"
        case showRewardStatus = "show_reward_status"
        case showSellerTools = "show_seller_tools"
        case enableClips = "enable_clips"
        case savePastShows = "save_past_shows"
        case activityStatus = "activity_status"
        case syncPhoneContacts = "sync_phone_contacts"
        case suggestMyAccount = "suggest_my_account"
        case hapticFeedback = "haptic_feedback"
    }
}



