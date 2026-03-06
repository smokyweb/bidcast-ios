//
//  ShippingsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - StoreShippingModel
struct StoreShippingModel: Codable {
    var id: Int?
    var userID: Int?
    var name: String?
    var size: String?
    var weight: String?
    var maxItems: Bool?
    var additionalWeight: Bool?
    var length: String?
    var height: String?
    var width: String?
    var incrementWeight: String?
    var incrementWeightScale: String?
    var scale: String?
    var maxItemUnit: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case size
        case weight
        case maxItems
        case additionalWeight
        case length
        case height
        case width
        case incrementWeight = "increment_weight"
        case incrementWeightScale = "increment_weight_scale"
        case scale
        case maxItemUnit = "max_item_unit"
    }
}



struct DomesticShipmentData: Codable {
    let id: Int?
    let userId: Int?
    let domesticShipmentForm1To5Lbs: String?
    let domesticShipmentOver5Lbs: String?
    let uspsFirstClassMailLetter: Bool?
    let alsoApplyScheduleShow: Bool?
    let shippingCosts: String?
    let shippingCostAlsoApplyScheduleShow: String?
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case domesticShipmentForm1To5Lbs = "domestic_shipment_form_1_to_5_lbs"
        case domesticShipmentOver5Lbs = "domestic_shipment_over_5_lbs"
        case uspsFirstClassMailLetter = "usps_first_class_mail_letter"
        case alsoApplyScheduleShow = "also_apply_schedule_show"
        case shippingCosts = "shipping_costs"
        case shippingCostAlsoApplyScheduleShow = "shipping_cost_also_apply_schedule_show"
        case price
    }
}

struct DeleteShippingModel: Codable {
}

struct EmptyResponse: Codable {}

struct ShippingSettingsDataModel: Codable {
    let freePickup: Bool?
    let instruction: String?
    let shippingAddress: ShippingAddressModel?
    let domesticShipmentSetting: DomesticShipmentSettingModel?
    let shippingProfilesCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case freePickup = "free_pickup"
        case instruction
        case shippingAddress = "shipping_address"
        case domesticShipmentSetting = "domestic_shipment_setting"
        case shippingProfilesCount = "shipping_profiles_count"
    }
}

struct DomesticShipmentSettingModel: Codable {
    let id: Int?
    let userId: Int?
    let domesticShipmentForm1To5Lbs: String?
    let domesticShipmentOver5Lbs: String?
    let uspsFirstClassMailLetter: String?
    let alsoApplyScheduleShow: String?
    let shippingCosts: String?
    let shippingCostAlsoApplyScheduleShow: String?
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case domesticShipmentForm1To5Lbs = "domestic_shipment_form_1_to_5_lbs"
        case domesticShipmentOver5Lbs = "domestic_shipment_over_5_lbs"
        case uspsFirstClassMailLetter = "usps_first_class_mail_letter"
        case alsoApplyScheduleShow = "also_apply_schedule_show"
        case shippingCosts = "shipping_costs"
        case shippingCostAlsoApplyScheduleShow = "shipping_cost_also_apply_schedule_show"
        case price
    }
}

struct AppSettingDataModel: Codable {
    var id: Int?
    var userId: Int?
    var countryOfResidence: String?
    
    var directMessage: Bool?
    var receiveGifts: Bool?
    var enablePrivateEntry: Bool?
    var showRewardStatus: Bool?
    var showSellerTools: Bool?
    var enableClips: Bool?
    var savePastShows: Bool?
    var activityStatus: Bool?
    var syncPhoneContacts: Bool?
    var suggestMyAccount: Bool?
    var hapticFeedback: Bool?
    
    var freeShipping: Bool?
    var shippingAddressId: Int?
    var instruction: String?
    
    var shippingAddress: ShippingAddressModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
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
        case freeShipping = "free_shipping"
        case shippingAddressId = "shipping_address_id"
        case instruction
        case shippingAddress = "shipping_address"
    }
}

