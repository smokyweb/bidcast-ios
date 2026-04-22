//
//  ChatStore.swift
//  BidCast — iOS parity Phase 3c (2026-04-22)
//
//  Chat storage abstraction. Android uses Firebase Realtime Database to
//  back 1:1 messaging. iOS does not have Firebase integrated yet, so this
//  store exposes the surface the UI expects, backed by an in-memory mock
//  with a REST sidecar (`send-chat-notification`) that Android uses to
//  trigger the push. When Phase 4 brings Firebase in, swap
//  `InMemoryChatStore` for `FirebaseChatStore` without touching the VMs.
//

import Foundation

// MARK: - Abstraction

protocol ChatStore {
    func observeConversations(currentUserId: Int,
                              onUpdate: @escaping ([Conversation]) -> Void)
    func observeMessages(conversationId: String,
                         onUpdate: @escaping ([ChatMessage]) -> Void)
    func sendMessage(conversationId: String,
                     senderId: Int,
                     body: String,
                     completion: @escaping (Result<ChatMessage, Error>) -> Void)
    func markAsRead(conversationId: String, userId: Int)
    func blockUser(userId: Int,
                   completion: @escaping (Result<Void, Error>) -> Void)
    func unblockUser(userId: Int,
                     completion: @escaping (Result<Void, Error>) -> Void)
    func reportUser(userId: Int,
                    reason: String,
                    completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - In-memory chat store (Phase 3 scaffolding)

/// Thread-safe in-memory chat store. Enough to prove out the UI, but not
/// cross-device. `FirebaseChatStore` will replace this in Phase 4 without
/// any VM change.
final class InMemoryChatStore: ChatStore {
    static let shared = InMemoryChatStore()

    private let lock = NSLock()
    private var conversationSinks: [(Int, ([Conversation]) -> Void)] = []
    private var messageSinks: [(String, ([ChatMessage]) -> Void)] = []
    private var conversationsByUserId: [Int: [Conversation]] = [:]
    private var messagesByConversationId: [String: [ChatMessage]] = [:]

    func observeConversations(currentUserId: Int,
                              onUpdate: @escaping ([Conversation]) -> Void) {
        lock.lock()
        conversationSinks.append((currentUserId, onUpdate))
        let snap = conversationsByUserId[currentUserId] ?? []
        lock.unlock()
        DispatchQueue.main.async { onUpdate(snap) }
    }

    func observeMessages(conversationId: String,
                         onUpdate: @escaping ([ChatMessage]) -> Void) {
        lock.lock()
        messageSinks.append((conversationId, onUpdate))
        let snap = messagesByConversationId[conversationId] ?? []
        lock.unlock()
        DispatchQueue.main.async { onUpdate(snap) }
    }

    func sendMessage(conversationId: String,
                     senderId: Int,
                     body: String,
                     completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        let msg = ChatMessage(
            id: UUID().uuidString,
            conversationId: conversationId,
            senderId: senderId,
            body: body,
            mediaUrl: nil, mediaType: nil,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            isRead: false,
            isDeleted: false
        )
        lock.lock()
        var msgs = messagesByConversationId[conversationId] ?? []
        msgs.append(msg)
        messagesByConversationId[conversationId] = msgs
        let sinks = messageSinks.filter { $0.0 == conversationId }.map { $0.1 }
        lock.unlock()

        DispatchQueue.main.async {
            sinks.forEach { $0(msgs) }
            completion(.success(msg))
        }

        // REST sidecar — fire-and-forget push notification to the other user.
        // TODO-PHASE4: Once Firebase is integrated, remove this path in favor
        // of native FCM from the server via Cloud Functions.
        Task {
            do {
                // Naive: infer recipient from conversationId "a_b" where a<b.
                let parts = conversationId.split(separator: "_").compactMap { Int($0) }
                let recipient = parts.first(where: { $0 != senderId }) ?? 0
                if recipient > 0 {
                    let body = SendChatNotificationRequest(
                        userId: recipient, message: body, type: "chat",
                        conversationId: conversationId
                    )
                    let _: APIEmptyResponse = try await APIManager.shared.request(
                        type: .sendChatNotification(param: body),
                        header: true
                    )
                }
            } catch {
                debugLog("sendChatNotification error: \(error.localizedDescription)")
            }
        }
    }

    func markAsRead(conversationId: String, userId: Int) {
        lock.lock()
        defer { lock.unlock() }
        guard var msgs = messagesByConversationId[conversationId] else { return }
        msgs = msgs.map { msg in
            if msg.senderId != userId, msg.isRead != true {
                return ChatMessage(
                    id: msg.id, conversationId: msg.conversationId,
                    senderId: msg.senderId, body: msg.body,
                    mediaUrl: msg.mediaUrl, mediaType: msg.mediaType,
                    createdAt: msg.createdAt, isRead: true, isDeleted: msg.isDeleted
                )
            }
            return msg
        }
        messagesByConversationId[conversationId] = msgs
    }

    // MARK: - Block / Report via REST

    func blockUser(userId: Int,
                   completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let req = BlockUnblockRequest(userId: userId, action: "block")
                let _: BlockedUnblockedResponse = try await APIManager.shared.request(
                    type: .blockUnblockUser(param: req), header: true
                )
                await MainActor.run { completion(.success(())) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }

    func unblockUser(userId: Int,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let req = BlockUnblockRequest(userId: userId, action: "unblock")
                let _: BlockedUnblockedResponse = try await APIManager.shared.request(
                    type: .blockUnblockUser(param: req), header: true
                )
                await MainActor.run { completion(.success(())) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }

    func reportUser(userId: Int, reason: String,
                    completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let req = ReportSellerRequest(
                    sellerId: userId,
                    categoryId: 0,     // "Other" fallback; UI should replace
                    description: reason
                )
                let _: APIEmptyResponse = try await APIManager.shared.request(
                    type: .reportSeller(param: req), header: true
                )
                await MainActor.run { completion(.success(())) }
            } catch {
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }
}

// TODO-PHASE4: Replace InMemoryChatStore with FirebaseChatStore that hooks
// /conversations/{id}/messages -> snapshot listeners and /conversations
// where `participants` contains the current user. Use the same method
// signatures above. Reuse `Conversation`, `ChatMessage`, `TypingIndicator`
// Codables unchanged — they already mirror the Firebase schema in
// Android's ChatFragment.
