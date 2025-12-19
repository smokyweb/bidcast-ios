//
//  WalletModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - TransactionModel
struct TransactionModel: Codable {
    var id, userID, sellerID: Int?
    var orderID: Int?
    var showID: Int?
    var promoteShowID: Int?
    var cardNumber, accountNumber: String?
    var sourceType: String?
    var type: String?
    var date: String?
    var status: String?
    var productPrice: Int?
    var total: String?
    var subTotal, taxAmount, shippingCharges, discount: Int?
    var paymentIntentID, chargeID: String?
    var createdAt: String?
    var counterpartyName: String?
    var buyer: Buyer?
    var receiver, sender: Receiver?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case sellerID = "seller_id"
        case orderID = "order_id"
        case showID = "show_id"
        case promoteShowID = "promote_show_id"
        case cardNumber = "card_number"
        case accountNumber = "account_number"
        case sourceType = "source_type"
        case type, date, status
        case productPrice = "product_price"
        case total
        case subTotal = "sub_total"
        case taxAmount = "tax_amount"
        case shippingCharges = "shipping_charges"
        case discount
        case paymentIntentID = "payment_intent_id"
        case chargeID = "charge_id"
        case createdAt = "created_at"
        case counterpartyName = "counterparty_name"
        case buyer, receiver, sender
    }
}

// MARK: - Buyer
struct Buyer: Codable {
    var id: Int?
    var name: String?
    var email: String?
}

// MARK: - Receiver
struct Receiver: Codable {
    var id: Int?
    var name: String?
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
struct PayOutHistoryModel: Codable, Identifiable {
    var id, userID: Int?
    var sellerID, orderID: Int?
    var cardNumber: String?
    var accountNumber, sourceType, type, date: String?
    var status: String?
    var productPrice: String?
    var total: String?
    var subTotal, taxAmount, shippingCharges, discount: Int?
    var paymentIntentID, chargeID: String?
    var createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case sellerID = "seller_id"
        case orderID = "order_id"
        case cardNumber = "card_number"
        case accountNumber = "account_number"
        case sourceType = "source_type"
        case type, date, status
        case productPrice = "product_price"
        case total
        case subTotal = "sub_total"
        case taxAmount = "tax_amount"
        case shippingCharges = "shipping_charges"
        case discount
        case paymentIntentID = "payment_intent_id"
        case chargeID = "charge_id"
        case createdAt = "created_at"
    }
}
