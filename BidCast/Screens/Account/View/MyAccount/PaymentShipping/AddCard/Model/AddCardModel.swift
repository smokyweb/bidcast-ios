//
//  AddCardModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/06/25.
//


//struct CardModel : Codable{
//    var card_id : String?
//    var exp_year : Int?
//    var exp_month : Int?
//    var last4 :  String?
//    var fingerprint :  String?
//    var card_holder_name :  String?
//    var is_default : Bool?
//}

struct CardModel : Codable {
    var merchantCustomerId: String?
      var description: String?
      var email: String?
      var customerProfileId: String?
      var paymentProfiles: [PaymentProfile]?
      var profileType: String?
    var payment_profile_id : String?
}

struct PaymentProfile: Codable {
    var customerType: String?
    var customerPaymentProfileId: String?
    var payment: PaymentMethod?
}

struct PaymentMethod: Codable {
    var creditCard: CreditCard?
}

struct CreditCard: Codable {
    var cardNumber: String?
    var expirationDate: String?
    var cardType: String?
}
