//
//  AddressModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/05/25.
//

import Foundation

struct AddressModel  : Codable {
    var id : Int?
    var user_id : Int?
    var type : String?
    var name : String?
    var phone_number : String?
    var street_address : String?
    // MC sub-task cmp4932vk00l13mx1du6mmebo (Trey 2026-05-13): optional
    // second street-address line (apartment / unit / suite). Backed by
    // shipping_addresses.address_line_2 on the Laravel side (added the
    // same session via SSH-first migration).
    var address_line_2 : String?
    var pincode : String?
    var is_default : Bool?
}

struct StateModel : Codable {
   var  id : Int?
    var  name : String?
    var iso2 : String?
}
