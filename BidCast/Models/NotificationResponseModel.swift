//
//  NotificationResponseModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 20/02/24.
//

import Foundation


struct NotificationListModel:Codable {
    var id: Int?
    var sender_id, title, message, type: String?
    var receiver_id, job_id: String?
    var match_id, user_job_id: String?
    var isSeen, created_at, updated_at: String?
    var sender: Sender?
}

// MARK: - Sender
struct Sender:Codable {
    var id: Int?
    var name, profile_image: String?
}
