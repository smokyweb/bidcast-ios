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

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessageModel] = []
    @Published var messageText: String = ""

    private var ref = Database.database().reference()
    private var messageListenerHandle: DatabaseHandle?

    var currentUserId: String
    var currentUserName: String
    var currentUserImage: String

    var otherUserId: String
    var otherUserName: String
    var otherUserImage: String

    @Binding var chatPath: String // This should be a Binding to modify it in the view

    var sortedChatId: String {
        let first = min(currentUserId, otherUserId)
        let second = max(currentUserId, otherUserId)
        return "\(first)_chats_\(second)"
    }

    // This computes the chat path based on the sorted chat ID
    var chatPathValue: String {
        return "chats/\(sortedChatId)"
    }

    init(currentUserId: String, currentUserName: String, currentUserImage: String,
         otherUserId: String, otherUserName: String, otherUserImage: String, chatPath: Binding<String>) {
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.currentUserImage = currentUserImage
        self.otherUserId = otherUserId
        self.otherUserName = otherUserName
        self.otherUserImage = otherUserImage
        self._chatPath = chatPath // Binding assigned here
    }

    deinit {
        if let handle = messageListenerHandle {
            ref.child(chatPath).removeObserver(withHandle: handle)
        }
    }

    // MARK: - Fetch + Listen
    func fetchMessages() {
        if let handle = messageListenerHandle {
            ref.child(chatPath).removeObserver(withHandle: handle)
            messageListenerHandle = nil
        }
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
            messageListenerHandle = nil
        }
    }

    // MARK: - Send Message
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let messageId = UUID().uuidString
        let timestamp = Int(Date().timeIntervalSince1970)

        let messageData: [String: Any] = [
            "message": messageText,
            "senderId": currentUserId,
            "receiverId": otherUserId,
            "timestamp": timestamp
        ]
        ref.child("chats").child(sortedChatId).child(messageId).setValue(messageData)

        // Prepare chat preview data and save to chat list
        let attachment: [String: Any] = ["audio": "", "image": "", "thumbnail": "", "video": ""]

        let senderUsers: [String: Any] = [
            "receiverId": otherUserId,
            "receiverImage": otherUserImage,
            "receiverName": otherUserName,
            "senderId": currentUserId,
            "senderImage": currentUserImage,
            "senderName": currentUserName
        ]

        let receiverUsers: [String: Any] = [
            "receiverId": currentUserId,
            "receiverImage": currentUserImage,
            "receiverName": currentUserName,
            "senderId": otherUserId,
            "senderImage": otherUserImage,
            "senderName": otherUserName
        ]

        let senderData: [String: Any] = [
            "attachment": attachment,
            "id": sortedChatId,
            "isReply": false,
            "message": messageText,
            "seen": false,
            "timestamp": timestamp,
            "timezone": TimeZone.current.identifier,
            "type": "text",
            "users": senderUsers
        ]

        let receiverData: [String: Any] = [
            "attachment": attachment,
            "id": sortedChatId,
            "isReply": false,
            "message": messageText,
            "seen": false,
            "timestamp": timestamp,
            "timezone": TimeZone.current.identifier,
            "type": "text",
            "users": receiverUsers
        ]

        // Update chat_list for both users
        ref.child("chat_list").child(currentUserId).child(otherUserId).setValue(senderData)
        ref.child("chat_list").child(otherUserId).child(currentUserId).setValue(receiverData)

        messageText = ""
    }
}



