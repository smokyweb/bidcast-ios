//
//  AddCardModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/06/25.
//


struct CardModel : Codable{
    var card_id : String?
    var exp_year : Int?
    var exp_month : Int?
    var last4 :  String?
    var fingerprint :  String?
    var card_holder_name :  String?
    var is_default : Bool?
}
