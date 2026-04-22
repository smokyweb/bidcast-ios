//  ChatModels.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Android stores chat data in Firebase Realtime Database (no REST DTOs).
//  The only REST-backed chat action is `send-chat-notification` which is
//  fire-and-forget. These models exist so iOS can persist chat state in a
//  Firebase mirror and send push pings with the same payload shape.
//
//  Ported / inferred from Android:
//    - ApiInterface.kt `sendChatNotification` (see request)
//    - Firebase conversation schema in chat fragment source
//
// TODO-PHASE3: once chat wiring lands, cross-check the exact Firebase node
// names (conversations / messages / typing / blocked) with the Android
// ChatFragment to make sure both clients write to identical paths.

import Foundation

// MARK: - Conversation (Firebase node: /conversations/{conversationId})

struct Conversation: Codable, Identifiable, Hashable {
    let id: String
    let participants: [Int]?          // [userId, otherUserId]
    let lastMessage: String?
    let lastMessageAt: String?
    let unreadCount: Int?
    let otherUser: UserPublic?
    let isMuted: Bool?

    enum CodingKeys: String, CodingKey {
        case id, participants
        case lastMessage = "last_message"
        case lastMessageAt = "last_message_at"
        case unreadCount = "unread_count"
        case otherUser = "other_user"
        case isMuted = "is_muted"
    }
}

// MARK: - ChatMessage (Firebase node: /conversations/{id}/messages/{messageId})

struct ChatMessage: Codable, Identifiable, Hashable {
    let id: String
    let conversationId: String?
    let senderId: Int?
    let body: String?
    let mediaUrl: String?
    let mediaType: String?
    let createdAt: String?
    let isRead: Bool?
    let isDeleted: Bool?

    var createdDate: Date? { ISO8601DateFormatter().date(from: createdAt ?? "") }

    enum CodingKeys: String, CodingKey {
        case id, body
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case mediaUrl = "media_url"
        case mediaType = "media_type"
        case createdAt = "created_at"
        case isRead = "is_read"
        case isDeleted = "is_deleted"
    }
}

// MARK: - SendChatNotificationRequest (POST api/send-chat-notification)

struct SendChatNotificationRequest: Encodable {
    let userId: Int           // recipient
    let message: String
    let type: String?
    let conversationId: String?

    enum CodingKeys: String, CodingKey {
        case message, type
        case userId = "user_id"
        case conversationId = "conversation_id"
    }
}

// MARK: - Typing indicator (Firebase ephemeral node)

struct TypingIndicator: Codable, Hashable {
    let userId: Int?
    let isTyping: Bool?
    let conversationId: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isTyping = "is_typing"
        case conversationId = "conversation_id"
    }
}
