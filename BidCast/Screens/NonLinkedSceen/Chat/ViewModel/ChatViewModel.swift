//
//  ChatViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/07/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

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

    // MARK: ✅ Shared sorted ID (used for both chat and chat_list)
    var sortedChatId: String {
        let first = min(currentUserId, otherUserId)
        let second = max(currentUserId, otherUserId)
        return "\(first)_chats_\(second)"
    }

    // MARK: ✅ Firebase chat path (matches Firebase DB structure)
    var chatPath: String {
        return "chats/\(sortedChatId)"
    }

    // MARK: - Init
    init(currentUserId: String, currentUserName: String, currentUserImage: String,
         otherUserId: String, otherUserName: String, otherUserImage: String) {
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.currentUserImage = currentUserImage
        self.otherUserId = otherUserId
        self.otherUserName = otherUserName
        self.otherUserImage = otherUserImage

        fetchMessages()
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
print("chatpath \(chatPath)")
        messages.removeAll()

        messageListenerHandle = ref.child(chatPath).observe(.childAdded) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            let message = ChatMessageModel(id: snapshot.key, from: dict)
            print("messagesCheck\(message)")
            DispatchQueue.main.async {
                self.messages.append(message)
                self.messages.sort { $0.timestamp < $1.timestamp }
                print("messages\(self.messages)")
            }
            
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

        // ✅ Save message to chat path
        print("send chatpath \(chatPath)")
        ref.child(chatPath).child(messageId).setValue(messageData)

        // ✅ Prepare chat preview data
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

        // ✅ Update chat_list for both users
        ref.child("chat_list").child(currentUserId).child(otherUserId).setValue(senderData)
        ref.child("chat_list").child(otherUserId).child(currentUserId).setValue(receiverData)

        messageText = ""
    }
}
