//
//  NotificationModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation


// MARK: - DeleteNotificationModel
struct DeleteNotificationModel: Codable {
 
}

// MARK: - SendChatNotificationModel
struct SendChatNotificationModel: Codable {
 
}

// MARK: - NotificationListingModel
struct NotificationListingModel: Codable {
    var id, senderID, receiverID: Int?
    var title, message, type: String?
    var isSeen: Int?
    var createdAt, updatedAt: String?
    // Trey QA 2026-05-31: inquiry notification deep-link.
    // Backend stores reference_id = (string) thread_id for type=inquiry_message.
    // NOTE: Live API showed reference_id=null on older inquiry notifications —
    // gracefully fall back to inbox when nil.
    var referenceId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case senderID = "sender_id"
        case receiverID = "receiver_id"
        case title, message, type
        case isSeen = "is_seen"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case referenceId = "reference_id"
    }
}
