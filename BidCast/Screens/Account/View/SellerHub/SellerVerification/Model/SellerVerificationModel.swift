//
//  SellerVerificationModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

//MARK: StoreIDCardModel
struct StoreIDCardModel: Codable {
    var id, userID: Int?
    var idCard: String?
    var image: String?
    var phoneNumber, otp: String?
    var numberOtpVerified: Int?
    var cardID, status: String?
    var reason: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case idCard = "id_card"
        case image
        case phoneNumber = "phone_number"
        case otp
        case numberOtpVerified = "number_otp_verified"
        case cardID = "card_id"
        case status, reason
    }
}


// MARK: - SellerPhoneNumberModel
struct SellerPhoneNumberModel: Codable {
    var otp: Int?
    var phoneNumer: String?

    enum CodingKeys: String, CodingKey {
        case otp
        case phoneNumer = "phone_numer"
    }
}


// MARK: - SellerOtpVerifyModel
struct SellerOtpVerifyModel: Codable {

}


// MARK: - BuyerIdentityStoreModel
struct BuyerIdentityStoreModel: Codable {
    var id, userID: Int?
    var image: String?
    var status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case image, status
    }
}


// MARK: - BuyerIdentityListModel
struct BuyerIdentityListModel: Codable {
    var id, userID: Int?
    var image: String?
    var status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case image, status
    }
}



// MARK: - SellerIdentityFetch
struct SellerIdentityFetch: Codable {
    var id, userID: Int?
    var idCard: String?
    var image: String?
    var phoneNumber, otp: String?
    var numberOtpVerified: Int?
    var cardID, status: String?
    var reason: String?
    var cardDetails: CardDetails?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case idCard = "id_card"
        case image
        case phoneNumber = "phone_number"
        case otp
        case numberOtpVerified = "number_otp_verified"
        case cardID = "card_id"
        case status, reason
        case cardDetails = "card_details"
    }
}

// MARK: - CardDetails
struct CardDetails: Codable {
    var expMonth, expYear: Int?
    var last4: String?

    enum CodingKeys: String, CodingKey {
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case last4
    }
}


//MARK: SellerVerificationModel.
struct SellerVerificationModel: Codable {
    var id: Int?
    var user_id: Int?
    var id_card: String?
    var image: String?
    var phone_number: String?
    var otp: String?
    var number_otp_verified: Int?
    var card_id: String?
    var status: String?
    var reason: String?
//    var card_detail: CardModel?
}

