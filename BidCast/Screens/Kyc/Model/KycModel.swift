//
//  KycModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - KycDetailsModel.
struct KycDetailsModel: Codable {
    var accountID: String?
    var phone, city, country, postalCode: String?
    var bankID, rountingNumber, currency: String?

    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case phone, city, country
        case postalCode = "postal_code"
        case bankID = "bank_id"
        case rountingNumber = "rounting_number"
        case currency
    }
}

// MARK: - CheckKycModel.
struct CheckKycModel: Codable {
    var object: String?
    var created, expiresAt: Int?
    var url: String?
    var res: Bool?
    var msg, kycStatus: String?
    var kycDetails: KycDetailsModel?

    enum CodingKeys: String, CodingKey {
        case object, created
        case expiresAt = "expires_at"
        case url, res, msg
        case kycStatus = "kyc_status"
        case kycDetails = "kyc_details"
    }
}

// MARK: - FundTransferModel
struct FundTransferModel : Codable{
    
}
