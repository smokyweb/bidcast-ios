//
//  WalletModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - TransactionModel
struct TransactionModel : Codable {
    var id : Int?
    var user_id : Int?
    var order_id : Int?
    var card_number : String?
    var source_type : String?
    var type : String?
    var date : String?
    var total : String?
    var sub_total : Int?
    var tax_amount : Int?
    var shipping_charges : Int?
    var discount : Int?
    var payment_intent_id : String?
    var charge_id : String?
}

// MARK: - WalletInfoModel
struct WalletInfoModel: Codable {
    var processing: Double?
    var avaiableForPayout: Int?
    var avaiableBalance: Double?

    enum CodingKeys: String, CodingKey {
        case processing
        case avaiableForPayout = "avaiable_for_payout"
        case avaiableBalance = "avaiable_balance"
    }
}


// MARK: - PayOutHistoryModel
struct PayOutHistoryModel: Codable {

}
