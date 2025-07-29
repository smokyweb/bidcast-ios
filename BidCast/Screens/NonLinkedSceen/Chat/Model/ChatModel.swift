//
//  ChatModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/07/25.
//

import Foundation

struct ChatMessageModel: Identifiable {
    var id: String
    var message: String
    var senderId: String
    var receiverId: String
    var timestamp: Int

    init(id: String = UUID().uuidString, message: String, senderId: String, receiverId: String, timestamp: Int) {
        self.id = id
        self.message = message
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
    }

    init(id: String, from dict: [String: Any]) {
        self.id = id
        self.message = dict["message"] as? String ?? ""
        self.senderId = dict["senderId"] as? String ?? ""
        self.receiverId = dict["receiverId"] as? String ?? ""
        self.timestamp = dict["timestamp"] as? Int ?? 0
    }
}


struct ChatMessage: Codable, Identifiable {
    var id: String
    var message: String
    var timestamp: Double
    var type: String
    var isReply: Bool
    var seen: Bool
    var users: ChatUsers
}

struct ChatUsers: Codable {
    var receiverId: String
    var receiverName: String
    var receiverImage: String
    var senderId: String
    var senderName: String
    var senderImage: String
}
