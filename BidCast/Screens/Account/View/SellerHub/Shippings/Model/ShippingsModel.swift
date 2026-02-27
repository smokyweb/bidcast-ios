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
