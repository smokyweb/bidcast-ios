//
//  ChatViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/07/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import SwiftUI

struct ChatModel {
    // USER VALUES
    var currentUserId: String = ""
    var currentUserName: String = ""
    var currentUserImage: String = ""
    
    var otherUserId: String = ""
    var otherUserName: String = ""
    var otherUserImage: String = ""
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessageModel] = []
    @Published var messageText: String = ""

    private var ref = Database.database().reference()
    private var messageListenerHandle: DatabaseHandle?

    // USER VALUES
    var currentUserId: String
    var currentUserName: String
    var currentUserImage: String

    var otherUserId: String
    var otherUserName: String
    var otherUserImage: String

    // Clean sorted chat id
    var sortedChatId: String {
        let first = min(currentUserId, otherUserId)
        let second = max(currentUserId, otherUserId)
        return "\(first)_chats_\(second)"
    }

    // FINAL computed chat path
    var chatPath: String {
        "chats/\(sortedChatId)"
    }

    // INIT (no binding needed)
    init(
        currentUserId: String,
        currentUserName: String,
        currentUserImage: String,
        otherUserId: String,
        otherUserName: String,
        otherUserImage: String
    ) {
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.currentUserImage = currentUserImage
        self.otherUserId = otherUserId
        self.otherUserName = otherUserName
        self.otherUserImage = otherUserImage
    }

    deinit {
        removeMessageListener()
    }

    // MARK: - Listen for Messages
    func fetchMessages() {
        removeMessageListener()
        messages.removeAll()

        messageListenerHandle = ref.child(chatPath).observe(.childAdded) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }

            let message = ChatMessageModel(id: snapshot.key, from: dict)

            DispatchQueue.main.async {
                self.messages.append(message)
                self.messages.sort { $0.timestamp < $1.timestamp }
            }
        }
    }

    func removeMessageListener() {
        if let handle = messageListenerHandle {
            ref.child(chatPath).removeObserver(withHandle: handle)
        }
        messageListenerHandle = nil
    }

    // MARK: - Send Message
    func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let messageId = UUID().uuidString
        let timestamp = Int(Date().timeIntervalSince1970)

        let messageData: [String: Any] = [
            "message": trimmed,
            "senderId": currentUserId,
            "receiverId": otherUserId,
            "timestamp": timestamp
        ]

        // Save message under chat path
        ref.child(chatPath).child(messageId).setValue(messageData)

        // Attachments
        let attachment: [String: Any] = [
            "audio": "", "image": "", "thumbnail": "", "video": ""
        ]

        // Sender view
        let senderUsers: [String: Any] = [
            "receiverId": otherUserId,
            "receiverImage": otherUserImage,
            "receiverName": otherUserName,
            "senderId": currentUserId,
            "senderImage": currentUserImage,
            "senderName": currentUserName
        ]

        // Receiver view
        let receiverUsers: [String: Any] = [
            "receiverId": currentUserId,
            "receiverImage": currentUserImage,
            "receiverName": currentUserName,
            "senderId": otherUserId,
            "senderImage": otherUserImage,
            "senderName": otherUserName
        ]

        let senderPreview: [String: Any] = [
            "attachment": attachment,
            "id": sortedChatId,
            "isReply": false,
            "message": trimmed,
            "seen": false,
            "timestamp": timestamp,
            "timezone": TimeZone.current.identifier,
            "type": "text",
            "users": senderUsers
        ]

        let receiverPreview: [String: Any] = [
            "attachment": attachment,
            "id": sortedChatId,
            "isReply": false,
            "message": trimmed,
            "seen": false,
            "timestamp": timestamp,
            "timezone": TimeZone.current.identifier,
            "type": "text",
            "users": receiverUsers
        ]

        ref.child("chat_list").child(currentUserId).child(otherUserId).setValue(senderPreview)
        ref.child("chat_list").child(otherUserId).child(currentUserId).setValue(receiverPreview)

        messageText = ""
    }
}
