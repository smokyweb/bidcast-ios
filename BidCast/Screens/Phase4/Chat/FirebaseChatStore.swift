//
//  FirebaseChatStore.swift
//  BidCast — iOS parity Phase 4k (2026-04-22)
//
//  Firebase Realtime Database-backed ChatStore. Replaces Phase 3's
//  InMemoryChatStore for production. Uses the **same** Android RTDB schema
//  so iOS and Android users can converse in the same threads:
//
//    /chat_list/{userId}/{otherUserId}
//      -> latest-message mirror (message preview, timestamp, unreadCount, …)
//
//    /chats/{chatKey}/{autoPushKey}
//      -> individual message payloads (see ChatModel.kt)
//
//  chatKey = "${max(u1,u2)}_chats_${min(u1,u2)}"
//  (verified from Android's ChatActivity.kt:246)
//
//  Message fields (verified from Android's ChatModel.kt):
//    id, type, seen (Bool), unreadCount, message, timezone, timestamp (Long sec),
//    isReply, users{senderId, senderName, senderImage, receiverId, receiverName, receiverImage},
//    replyMessage{type, message, senderId, senderName, messageId},
//    attachment{audio, image, video, thumbnail}
//
//  Wrapped in `#if canImport(FirebaseDatabase)` so the repo still compiles
//  before Firebase pods are installed.
//

import Foundation

#if canImport(FirebaseDatabase)
import FirebaseDatabase
#endif

/// Firebase-backed ChatStore. Only instantiated when Firebase pods are
/// installed; otherwise the app falls back to InMemoryChatStore.
final class FirebaseChatStore: ChatStore {

    static let shared: ChatStore = {
        #if canImport(FirebaseDatabase)
        // QA hotfix 2026-04-23: `Database.database()` (called by our
        // stored-property initializer below) internally triggers
        // `+[FIRApp defaultApp]` which, if Firebase isn't configured yet,
        // calls `+[FIRApp configure]` — and that raises an NSException on
        // the placeholder GOOGLE_APP_ID we ship until the iOS app gets
        // registered in the bidcast-a527c Firebase console. Gate on the
        // same plist-validity check AppDelegate uses so we never even
        // instantiate FirebaseChatStore when the plist is fake.
        guard FirebaseAvailability.isConfiguredPlistReal else {
            NSLog("[BidCast] FirebaseChatStore unavailable (placeholder GoogleService-Info.plist) — falling back to InMemoryChatStore")
            return InMemoryChatStore.shared
        }
        return FirebaseChatStore()
        #else
        return InMemoryChatStore.shared
        #endif
    }()

    #if canImport(FirebaseDatabase)
    private let db = Database.database().reference()
    private var chatListHandles: [UInt: DatabaseReference] = [:]
    private var messageHandles: [UInt: DatabaseReference] = [:]
    #endif

    // MARK: - Path builders

    /// Android: `"${users[1]}_chats_${users[0]}"` where
    /// `val users = listOf(userId, otherUserId).sorted()` — so the larger
    /// id comes first. Match exactly.
    static func chatKey(me: Int, other: Int) -> String {
        let a = min(me, other)
        let b = max(me, other)
        return "\(b)_chats_\(a)"
    }

    /// Client-side ids for the `Conversation` Swift model. We reuse the
    /// chatKey verbatim so iOS + Android clients share the same id.
    static func conversationId(me: Int, other: Int) -> String {
        chatKey(me: me, other: other)
    }

    // MARK: - Observe conversations

    func observeConversations(
        currentUserId: Int,
        onUpdate: @escaping ([Conversation]) -> Void
    ) {
        #if canImport(FirebaseDatabase)
        let ref = db.child("chat_list").child("\(currentUserId)").queryOrdered(byChild: "timestamp")
        ref.observe(.value) { snap in
            var items: [Conversation] = []
            for case let child as DataSnapshot in snap.children {
                let otherIdStr = child.key   // other user id
                let otherId = Int(otherIdStr) ?? 0
                let dict = child.value as? [String: Any] ?? [:]
                let convId = FirebaseChatStore.conversationId(me: currentUserId, other: otherId)
                let users = dict["users"] as? [String: Any]
                let otherName = users?["senderId"] as? String == "\(currentUserId)"
                    ? users?["receiverName"] as? String
                    : users?["senderName"] as? String
                let otherImg = users?["senderId"] as? String == "\(currentUserId)"
                    ? users?["receiverImage"] as? String
                    : users?["senderImage"] as? String
                let conv = Conversation(
                    id: convId,
                    participants: [currentUserId, otherId],
                    lastMessage: dict["message"] as? String,
                    lastMessageAt: (dict["timestamp"] as? Int64).map { "\($0)" },
                    unreadCount: (dict["unreadCount"] as? Int) ?? 0,
                    otherUser: UserPublic(
                        id: otherId, bio: nil, email: nil,
                        firstName: nil, lastName: nil,
                        name: otherName, username: nil,
                        profileImage: otherImg, thumbnail: nil,
                        referralCode: nil, roleId: nil,
                        isActive: nil, rating: nil, isFollowed: nil
                    ),
                    isMuted: nil
                )
                items.append(conv)
            }
            // Most recent first
            items.sort { (a, b) in
                (a.lastMessageAt.flatMap(Int64.init) ?? 0) > (b.lastMessageAt.flatMap(Int64.init) ?? 0)
            }
            DispatchQueue.main.async { onUpdate(items) }
        }
        #else
        InMemoryChatStore.shared.observeConversations(currentUserId: currentUserId, onUpdate: onUpdate)
        #endif
    }

    // MARK: - Observe messages

    func observeMessages(
        conversationId: String,
        onUpdate: @escaping ([ChatMessage]) -> Void
    ) {
        #if canImport(FirebaseDatabase)
        // conversationId IS chatKey here (constructed the same way).
        let ref = db.child("chats").child(conversationId).queryOrderedByKey()
        ref.observe(.value) { snap in
            var msgs: [ChatMessage] = []
            for case let child as DataSnapshot in snap.children {
                guard let dict = child.value as? [String: Any] else { continue }
                let sender = (dict["users"] as? [String: Any])?["senderId"] as? String
                let senderId = Int(sender ?? "") ?? 0
                let attachment = dict["attachment"] as? [String: Any]
                let mediaUrl = (attachment?["image"] as? String)
                    ?? (attachment?["video"] as? String)
                    ?? (attachment?["audio"] as? String)
                let mediaType = dict["type"] as? String // "text"/"image"/"video"/"audio"
                let timestamp = (dict["timestamp"] as? Int64) ?? 0
                let msg = ChatMessage(
                    id: (dict["id"] as? String) ?? child.key,
                    conversationId: conversationId,
                    senderId: senderId,
                    body: dict["message"] as? String,
                    mediaUrl: (mediaUrl?.isEmpty ?? true) ? nil : mediaUrl,
                    mediaType: mediaType,
                    createdAt: "\(timestamp)",
                    isRead: (dict["seen"] as? Bool) ?? false,
                    isDeleted: false
                )
                // Skip the Android "date separator" rows (`type == "date"`).
                if msg.mediaType != "date" {
                    msgs.append(msg)
                }
            }
            DispatchQueue.main.async { onUpdate(msgs) }
        }
        #else
        InMemoryChatStore.shared.observeMessages(conversationId: conversationId, onUpdate: onUpdate)
        #endif
    }

    // MARK: - Send

    func sendMessage(
        conversationId: String,
        senderId: Int,
        body: String,
        completion: @escaping (Result<ChatMessage, Error>) -> Void
    ) {
        #if canImport(FirebaseDatabase)
        // Parse the other user id out of the chatKey "{max}_chats_{min}"
        let parts = conversationId.split(separator: "_")
        guard parts.count == 3,
              let a = Int(parts[0]), let b = Int(parts[2]) else {
            completion(.failure(NSError(domain: "FirebaseChatStore", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Bad conversationId"])))
            return
        }
        let receiverId = (a == senderId) ? b : a

        let ref = db.child("chats").child(conversationId)
        let msgKey = ref.childByAutoId().key ?? UUID().uuidString
        let tz = TimeZone.current.identifier
        let ts = Int64(Date().timeIntervalSince1970) // Android uses seconds

        let users: [String: Any] = [
            "senderId": "\(senderId)",
            "senderName": UserDefaults.standard.string(forKey: "name") ?? "",
            "senderImage": UserDefaults.standard.string(forKey: "image") ?? "",
            "receiverId": "\(receiverId)",
            "receiverName": "",
            "receiverImage": ""
        ]
        let attachment: [String: Any] = [
            "audio": "", "image": "", "video": "", "thumbnail": ""
        ]
        let replyMessage: [String: Any] = [
            "type": "text", "message": "", "senderId": "", "senderName": "", "messageId": ""
        ]
        let payload: [String: Any] = [
            "id": msgKey,
            "type": "text",
            "seen": false,
            "unreadCount": 0,
            "message": body,
            "timezone": tz,
            "timestamp": ts,
            "isReply": false,
            "users": users,
            "replyMessage": replyMessage,
            "attachment": attachment
        ]
        ref.child(msgKey).setValue(payload) { err, _ in
            if let err = err {
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            let msg = ChatMessage(
                id: msgKey,
                conversationId: conversationId,
                senderId: senderId,
                body: body,
                mediaUrl: nil, mediaType: "text",
                createdAt: "\(ts)",
                isRead: false,
                isDeleted: false
            )
            DispatchQueue.main.async { completion(.success(msg)) }

            // Update chat_list mirrors for both sender + receiver.
            self.updateChatList(
                conversationId: conversationId,
                senderId: senderId,
                receiverId: receiverId,
                payload: payload
            )
        }

        // REST sidecar — push notification. Same as InMemoryChatStore did.
        Task {
            do {
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .sendChatNotification(param: SendChatNotificationRequest(
                        userId: receiverId, message: body, type: "chat",
                        conversationId: conversationId
                    )),
                    fields: [
                        "receiver_id": "\(receiverId)",
                        "message": body
                    ],
                    header: true
                )
            } catch {
                debugLog("sendChatNotification error: \(error.localizedDescription)")
            }
        }
        #else
        InMemoryChatStore.shared.sendMessage(
            conversationId: conversationId, senderId: senderId, body: body, completion: completion
        )
        #endif
    }

    #if canImport(FirebaseDatabase)
    private func updateChatList(
        conversationId: String,
        senderId: Int,
        receiverId: Int,
        payload: [String: Any]
    ) {
        // Sender mirror (unread=0)
        var mine = payload
        mine["unreadCount"] = 0
        db.child("chat_list").child("\(senderId)").child("\(receiverId)").setValue(mine)

        // Receiver mirror (unread = existing + 1)
        let rxRef = db.child("chat_list").child("\(receiverId)").child("\(senderId)")
        rxRef.observeSingleEvent(of: .value) { snap in
            let existing = (snap.value as? [String: Any])?["unreadCount"] as? Int ?? 0
            var theirs = payload
            theirs["unreadCount"] = existing + 1
            rxRef.setValue(theirs)
        }
    }
    #endif

    // MARK: - Read

    func markAsRead(conversationId: String, userId: Int) {
        #if canImport(FirebaseDatabase)
        // Mark all messages NOT sent by me as seen = true
        let ref = db.child("chats").child(conversationId)
        ref.observeSingleEvent(of: .value) { snap in
            for case let child as DataSnapshot in snap.children {
                guard let dict = child.value as? [String: Any] else { continue }
                let senderIdStr = (dict["users"] as? [String: Any])?["senderId"] as? String ?? ""
                if senderIdStr != "\(userId)" {
                    child.ref.child("seen").setValue(true)
                }
            }
        }
        // Reset my side of the chat_list unreadCount to 0.
        let parts = conversationId.split(separator: "_")
        guard parts.count == 3, let a = Int(parts[0]), let b = Int(parts[2]) else { return }
        let other = (a == userId) ? b : a
        db.child("chat_list").child("\(userId)").child("\(other)").child("unreadCount").setValue(0)
        #else
        InMemoryChatStore.shared.markAsRead(conversationId: conversationId, userId: userId)
        #endif
    }

    // MARK: - Block / Report — delegate to REST (InMemory already does this)

    func blockUser(userId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        InMemoryChatStore.shared.blockUser(userId: userId, completion: completion)
    }
    func unblockUser(userId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        InMemoryChatStore.shared.unblockUser(userId: userId, completion: completion)
    }
    func reportUser(userId: Int, reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        InMemoryChatStore.shared.reportUser(userId: userId, reason: reason, completion: completion)
    }
}

// MARK: - Chat store registry
//
// Phase 3's VMs reach for `InMemoryChatStore.shared` directly. Switching
// them to `ChatStoreRegistry.active` keeps the boundary in one place.

enum ChatStoreRegistry {
    /// Returns the best available ChatStore. Defaults to InMemory until
    /// Firebase pod is installed + configured, at which point it flips to
    /// FirebaseChatStore automatically via `#if canImport`.
    static var active: ChatStore = {
        #if canImport(FirebaseDatabase)
        // QA hotfix 2026-04-23: FirebaseChatStore.shared now self-gates on
        // FirebaseAvailability.isConfiguredPlistReal and returns
        // InMemoryChatStore when the committed GoogleService-Info.plist is
        // still a placeholder. Safe to route through it unconditionally.
        return FirebaseChatStore.shared
        #else
        return InMemoryChatStore.shared
        #endif
    }()
}
