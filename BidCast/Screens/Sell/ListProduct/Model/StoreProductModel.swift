//
//  StoreProductModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 19/05/25.
//

import Foundation

struct StoreProductModel : Codable {
    var category_id : Int?
          var title : String?
    var description : String?
    var quantity : Int?
    var pricing : Int?
    var flash_sale : Bool? = false
    var accept_offers : Bool? = false
    var reserve_for_live : Bool? = false
    var shipping_profile_id : Int?
    var status : String?
    var images : [String]?
    var id : Int?
}
