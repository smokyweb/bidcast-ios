//
//  InquiryModels.swift
//  BidCast
//
//  Buyer↔Seller REST Inquiry Messaging — Codable model layer.
//  Spec: /workspace/memory/bidcast-inquiry-messaging-spec.md
//  API base: https://backend.bidcast.betaplanets.com/api
//  Verified against LIVE API 2026-05-31 (buyer qa_buyer1 / seller jack1 thread_id=5).
//

import Foundation

// MARK: - GET /api/inquiries  →  list of threads

struct InquiryListResponse: Codable {
    let status: String
    let message: String
    let data: [InquiryThread]?
}

struct InquiryThread: Codable, Identifiable {
    let id: Int
    let subject: String?
    let productId: Int?
    let orderId: Int?
    let role: String?
    let otherUser: InquiryUser
    let lastMessageAt: String?
    let lastMessageSenderId: Int?
    let unreadCount: Int
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id, subject, role, status
        case productId          = "product_id"
        case orderId            = "order_id"
        case otherUser          = "other_user"
        case lastMessageAt      = "last_message_at"
        case lastMessageSenderId = "last_message_sender_id"
        case unreadCount        = "unread_count"
    }
}

struct InquiryUser: Codable, Identifiable {
    let id: Int
    let name: String?
    let username: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case id, name, username
        case profileImage = "profile_image"
    }

    var displayName: String {
        if let n = name, !n.isEmpty { return n }
        if let u = username, !u.isEmpty { return u }
        return "User \(id)"
    }
}

// MARK: - GET /api/inquiries/unread-count

struct InquiryUnreadCountResponse: Codable {
    let status: String
    let message: String
    let data: InquiryUnreadCount?
}

struct InquiryUnreadCount: Codable {
    let unreadTotal: Int
    let asBuyer: Int
    let asSeller: Int

    enum CodingKeys: String, CodingKey {
        case unreadTotal = "unread_total"
        case asBuyer     = "as_buyer"
        case asSeller    = "as_seller"
    }
}

// MARK: - GET /api/inquiries/{thread}  →  messages (also marks read)

struct InquiryThreadResponse: Codable {
    let status: String
    let message: String
    let data: InquiryThreadData?
}

struct InquiryThreadData: Codable {
    let threadId: Int
    let subject: String?
    let productId: Int?
    let orderId: Int?
    let messages: [InquiryMessage]

    enum CodingKeys: String, CodingKey {
        case threadId  = "thread_id"
        case subject
        case productId = "product_id"
        case orderId   = "order_id"
        case messages
    }
}

struct InquiryMessage: Codable, Identifiable {
    let id: Int
    let senderId: Int
    let mine: Bool
    let body: String
    let readAt: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case senderId  = "sender_id"
        case mine, body
        case readAt    = "read_at"
        case createdAt = "created_at"
    }
}

// MARK: - POST /api/inquiries  and  POST /api/inquiries/{thread}/reply

struct InquirySendResponse: Codable {
    let status: String
    let message: String
    let data: InquirySendData?
}

struct InquirySendData: Codable {
    let threadId: Int
    let messageId: Int

    enum CodingKeys: String, CodingKey {
        case threadId  = "thread_id"
        case messageId = "message_id"
    }
}
