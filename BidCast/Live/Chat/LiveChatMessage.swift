//
//  LiveChatMessage.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  In-stream chat message model + ring-buffer storage for both the host
//  (HostPublisherViewController) and the viewer (WatchStreamViewController).
//
//  Android parity:
//    - MessagesAdapter.kt keeps chat in memory only; does not persist.
//    - Trailing window is ~200 messages (implicit; no strict limit in
//      SocketManager, but the RecyclerView is clamped by backend paging).
//    - Deduplication on messageId when present; socket emits sometimes
//      repeat on reconnect so a naive append doubles entries.
//
//  This module keeps both behaviors in a single place so the two VCs share
//  the same semantics.
//

import Foundation

public struct LiveChatMessage: Equatable {
    public enum Kind {
        case user
        case system
    }
    public let id: String
    public let kind: Kind
    public let senderName: String
    public let senderImage: String?
    public let body: String
    public let timestamp: Date

    public init(
        id: String = UUID().uuidString,
        kind: Kind = .user,
        senderName: String,
        senderImage: String? = nil,
        body: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.senderName = senderName
        self.senderImage = senderImage
        self.body = body
        self.timestamp = timestamp
    }

    /// Build from the raw socket payload of `chat_get`.
    /// Android payload keys (see SocketManager.kt):
    ///   message_id / id, user_name, user_image, message, timestamp
    public static func fromChatPayload(_ payload: [String: Any]) -> LiveChatMessage {
        let messageId = (payload["message_id"] as? String)
            ?? (payload["id"] as? String)
            ?? {
                if let i = payload["message_id"] as? Int { return String(i) }
                if let i = payload["id"] as? Int { return String(i) }
                return UUID().uuidString
            }()
        let name = payload["user_name"] as? String ?? "User"
        let image = payload["user_image"] as? String
        let body = payload["message"] as? String ?? payload["content"] as? String ?? ""

        var ts = Date()
        if let epoch = payload["timestamp"] as? TimeInterval {
            ts = Date(timeIntervalSince1970: epoch > 10_000_000_000 ? epoch / 1000 : epoch)
        } else if let epochS = payload["timestamp"] as? String, let epoch = TimeInterval(epochS) {
            ts = Date(timeIntervalSince1970: epoch > 10_000_000_000 ? epoch / 1000 : epoch)
        }

        return LiveChatMessage(
            id: messageId,
            kind: .user,
            senderName: name,
            senderImage: image,
            body: body,
            timestamp: ts
        )
    }

    /// System entries (auction started, you won, etc.). We deliberately
    /// generate a fresh id each time so identical system lines still show
    /// as two rows when the backend emits twice.
    public static func system(_ body: String) -> LiveChatMessage {
        return LiveChatMessage(
            id: UUID().uuidString,
            kind: .system,
            senderName: "",
            senderImage: nil,
            body: body,
            timestamp: Date()
        )
    }
}

/// Bounded ring-buffer for live chat. Caps the visible window at
/// `capacity` (default 200) and drops the oldest entries first so the
/// UITableView never crosses into "thousands of rows" territory during
/// a multi-hour show.
public final class LiveChatBuffer {

    public let capacity: Int
    private(set) public var messages: [LiveChatMessage] = []
    private var seenIds = Set<String>()

    public init(capacity: Int = 200) {
        self.capacity = max(capacity, 20)
    }

    /// Append a message. Returns `true` if the message was added, `false`
    /// if it was a duplicate by id and therefore dropped. Duplicate
    /// detection only applies to `.user` messages; system lines are
    /// always appended (see LiveChatMessage.system).
    @discardableResult
    public func append(_ message: LiveChatMessage) -> Bool {
        if message.kind == .user {
            if seenIds.contains(message.id) { return false }
            seenIds.insert(message.id)
        }
        messages.append(message)
        // Trim oldest if we exceed capacity.
        let overflow = messages.count - capacity
        if overflow > 0 {
            let dropped = messages.prefix(overflow)
            for m in dropped where m.kind == .user {
                seenIds.remove(m.id)
            }
            messages.removeFirst(overflow)
        }
        return true
    }

    public func clear() {
        messages.removeAll(keepingCapacity: true)
        seenIds.removeAll(keepingCapacity: true)
    }
}
