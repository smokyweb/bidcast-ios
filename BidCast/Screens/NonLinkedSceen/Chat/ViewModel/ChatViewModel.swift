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

    var currentUserId: String
    var currentUserName: String
    var currentUserImage: String

    var otherUserId: String
    var otherUserName: String
    var otherUserImage: String

    private var ref = Database.database().reference()

    var chatPath: String {
        let first = min(currentUserId, otherUserId)
        let second = max(currentUserId, otherUserId)
        return "chats/\(first)_chats_\(second)"
    }

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

    
    func fetchMessages() {
        ref.child(chatPath).observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let message = ChatMessageModel(id: snapshot.key, from: dict)
                DispatchQueue.main.async {
                    self.messages.append(message)
                    self.messages.sort(by: { $0.timestamp < $1.timestamp })
                }
            }
        })
    }




    func sendMessage() {
        let messageId = UUID().uuidString
        let timestamp = Int(Date().timeIntervalSince1970)

        // 1. Save actual chat message to chat thread
        let messageData: [String: Any] = [
            "message": messageText,
            "senderId": currentUserId,
            "receiverId": otherUserId,
            "timestamp": timestamp
        ]
        ref.child(chatPath).child(messageId).setValue(messageData)

        // 2. Prepare attachment (empty for now)
        let attachment: [String: Any] = [
            "audio": "",
            "image": "",
            "thumbnail": "",
            "video": ""
        ]

        // 3. Prepare users node for sender
        let senderUsers: [String: Any] = [
            "receiverId": otherUserId,
            "receiverImage": otherUserImage,
            "receiverName": otherUserName,
            "senderId": currentUserId,
            "senderImage": currentUserImage,
            "senderName": currentUserName
        ]

        // 4. Main chat_list data (matches screenshot)
        let senderChatListData: [String: Any] = [
            "attachment": attachment,
            "id": "\(currentUserId)_chats_\(otherUserId)",
            "isReply": false,
            "message": messageText,
            "seen": false,
            "timestamp": timestamp,
            "timezone": TimeZone.current.identifier,
            "type": "text",
            "users": senderUsers
        ]

        // 5. Receiver users node
        let receiverUsers: [String: Any] = [
            "receiverId": currentUserId,
            "receiverImage": currentUserImage,
            "receiverName": currentUserName,
            "senderId": otherUserId,
            "senderImage": otherUserImage,
            "senderName": otherUserName
        ]

        let receiverChatListData: [String: Any] = [
            "attachment": attachment,
            "id": "\(otherUserId)_chats_\(currentUserId)",
            "isReply": false,
            "message": messageText,
            "seen": false,
            "timestamp": timestamp,
            "timezone": TimeZone.current.identifier,
            "type": "text",
            "users": receiverUsers
        ]

        // 6. Set data in chat_list for both sender and receiver
        ref.child("chat_list").child(currentUserId).child(otherUserId).setValue(senderChatListData)
        ref.child("chat_list").child(otherUserId).child(currentUserId).setValue(receiverChatListData)

        // 7. Clear input
        messageText = ""
    }


}
