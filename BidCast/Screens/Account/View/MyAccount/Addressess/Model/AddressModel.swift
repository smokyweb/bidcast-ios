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
    var pincode : String?
    var is_default : Bool? = false
}
