//
//  SellerStatusModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

struct SellerDataModel : Codable {
    var live_sell_vendor : LiveSellModel?
    var marketplace_vendor : MarketPlaceModel?
}
struct LiveSellModel : Codable {
    var title : String?
    var status : String?
    var submitted : String?
}

struct MarketPlaceModel : Codable {
    var status : String?
    var seller_rating : Int?
    var title : String?
    var vendor_since : String?
}
