//
//  OurSubscriptionModel.swift
//  Rise Shine Swing App
//
//  Created by JAM-E-329 on 27/12/24.
//

import Foundation

// MARK: - SubscriptionsListModel
struct SubscriptionsListModel: Codable {
    var id: Int?
    var title, plan, benefits: String?
    var planIDIos, planIDAndroid: String?
    var planType: String?
    var isPaid, isBestOffer: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, plan, benefits
        case planIDIos = "plan_id_ios"
        case planIDAndroid = "plan_id_android"
        case planType = "plan_type"
        case isPaid, isBestOffer
    }
}




// MARK: - SubscriptionValidationModel
struct SubscriptionValidationModel: Codable {
    var isSubscribed: Bool?
    var subscription: SubscriptionDetail?

    enum CodingKeys: String, CodingKey {
        case isSubscribed = "is_subscribed"
        case subscription
    }
}


// MARK: - SubscriptionDetail
struct SubscriptionDetail: Codable {
    var purchaseToken: String?
    var originalTransactionID, subscriptionStatus, expiresDatePst, subscriptionType: String?
    var isExpired, platform: String?
    
    enum CodingKeys: String, CodingKey {
        case purchaseToken
        case originalTransactionID = "original_transaction_id"
        case subscriptionStatus = "subscription_status"
        case expiresDatePst = "expires_date_pst"
        case subscriptionType = "subscription_type"
        case isExpired = "is_expired"
        case platform
    }
}


//MARK: SubscriptionModel.
struct SubscriptionModel : Codable{
    
}





