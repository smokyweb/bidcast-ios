//
//  BidcastSocketManager.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 2, milestone 1:
//  Swift port of Android `app/src/main/java/io/bidswipe/app/utils/SocketManager.kt`.
//
//  Contract: every emit and every listener name + payload shape MUST match
//  the Android SocketManager exactly, because both clients talk to the same
//  Node Socket.IO server at `Const.SOCKET_URL`. If a field name differs, the
//  server-side handler will silently drop it or fail.
//
//  This file deliberately does NOT introduce new event names — all event
//  strings are copied verbatim from the Android source so there is no chance
//  of drift (see inline citations next to each emit/listener).
//

import Foundation
#if canImport(SocketIO)
import SocketIO
#endif

/// iOS mirror of Android `SocketManager`. Single-connection model: one
/// `SocketManager` backing a single `SocketIOClient` at a time, created from
/// `BidcastSocketManager.shared.connect(userId:)`.
///
/// Reference: Android `SocketManager.kt` singleton-style usage from
/// `App.kt` `socketManager?.initialize(Const.SOCKET_URL, mapOf("uid" to userId))`.
///
/// Build note: every `SocketIO`-typed reference is wrapped in
/// `#if canImport(SocketIO)` so the file compiles even before CocoaPods
/// installs the pod (fresh clones, local Xcode previews, Codemagic
/// pre-`pod install` checks, etc.). When the pod is absent, every emit/
/// listener becomes a no-op that logs in DEBUG — production builds always
/// carry the pod so this path never ships.
public final class BidcastSocketManager {

    public static let shared = BidcastSocketManager()

    // MARK: Private state

    #if canImport(SocketIO)
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    #endif
    private var currentUserId: String = ""
    private let queue = DispatchQueue(label: "com.bidcast.socket", qos: .userInitiated)

    /// Bag of registered closures so callers can observe `isConnected`
    /// without needing a full Combine/ObservableObject stack yet.
    private var connectionObservers: [(Bool) -> Void] = []

    private init() {}

    // MARK: - Lifecycle

    /// Equivalent to Android `socketManager?.initialize(Const.SOCKET_URL, ...)`
    /// in `App.kt`. Safe to call multiple times with the same userId.
    public func connect(userId: String) {
        #if canImport(SocketIO)
        queue.async { [weak self] in
            guard let self = self else { return }
            if self.socket?.status == .connected && self.currentUserId == userId {
                return
            }
            self.disconnectInternal()

            self.currentUserId = userId
            let config: SocketIOClientConfiguration = [
                .log(false),
                .compress,
                .reconnects(true),
                .reconnectAttempts(-1),
                .reconnectWait(2),
                .forceWebsockets(true),
                .connectParams(["uid": userId])
            ]

            let manager = SocketManager(
                socketURL: LiveConstants.socketURL,
                config: config
            )
            let socket = manager.defaultSocket

            self.manager = manager
            self.socket = socket

            socket.on(clientEvent: .connect) { [weak self] _, _ in
                self?.notifyConnection(true)
            }
            socket.on(clientEvent: .disconnect) { [weak self] _, _ in
                self?.notifyConnection(false)
            }
            socket.on(clientEvent: .error) { data, _ in
                #if DEBUG
                print("[BidcastSocket] error:", data)
                #endif
            }

            socket.connect()
        }
        #else
        self.currentUserId = userId
        #if DEBUG
        print("[BidcastSocket] SocketIO pod missing; connect is a no-op.")
        #endif
        #endif
    }

    public func disconnect() {
        queue.async { [weak self] in
            self?.disconnectInternal()
        }
    }

    private func disconnectInternal() {
        #if canImport(SocketIO)
        socket?.disconnect()
        socket = nil
        manager = nil
        #endif
    }

    public var isConnected: Bool {
        #if canImport(SocketIO)
        return socket?.status == .connected
        #else
        return false
        #endif
    }

    public func onConnectionChange(_ handler: @escaping (Bool) -> Void) {
        queue.async { [weak self] in
            self?.connectionObservers.append(handler)
            DispatchQueue.main.async { handler(self?.isConnected ?? false) }
        }
    }

    private func notifyConnection(_ connected: Bool) {
        let observers = connectionObservers
        DispatchQueue.main.async {
            for observer in observers { observer(connected) }
        }
    }

    // MARK: - Helpers

    @discardableResult
    private func emit(_ event: String, _ payload: [String: Any]) -> Bool {
        #if canImport(SocketIO)
        guard let socket = socket, socket.status == .connected else {
            #if DEBUG
            print("[BidcastSocket] dropped emit \(event) (not connected)")
            #endif
            return false
        }
        socket.emit(event, payload)
        return true
        #else
        #if DEBUG
        print("[BidcastSocket] emit(\(event)) skipped — SocketIO pod missing")
        #endif
        return false
        #endif
    }

    private func listen(
        _ event: String,
        handler: @escaping ([String: Any]) -> Void
    ) {
        #if canImport(SocketIO)
        guard let socket = socket else { return }
        socket.off(event)
        socket.on(event) { data, _ in
            guard let first = data.first as? [String: Any] else { return }
            DispatchQueue.main.async { handler(first) }
        }
        #endif
    }

    // MARK: - Emits (Android parity, see SocketManager.kt line refs)

    /// Android: `socket?.emit("room_create", liveShowData.toJson())` (line ~120)
    public func emitRoomCreate(payload: [String: Any]) {
        emit("room_create", payload)
    }

    /// Android: `socket?.emit("join_room", payload)` (line ~198)
    public func emitJoinRoom(roomId: String, userId: String) {
        emit("join_room", ["room_id": roomId, "user_id": userId])
    }

    /// Android: `socket?.emit("leave_room", payload)` (line ~208)
    public func emitLeaveRoom(roomId: String, userId: String) {
        emit("leave_room", ["room_id": roomId, "user_id": userId])
    }

    /// Android: `socket?.emit("endRoom", payload)` (line ~227)
    public func emitEndRoom(roomId: String) {
        emit("endRoom", ["room_id": roomId])
    }

    /// Android: `socket?.emit("place_bid", payload)` (line ~264).
    /// Payload must include `room_id, bid_amount, user_name, user_image,
    /// user_id, product_id, auction_type_id`.
    public func emitPlaceBid(
        roomId: String,
        userId: String,
        userName: String,
        userImage: String,
        productId: String?,
        bidAmount: String?,
        auctionTypeId: Int?
    ) {
        emit("place_bid", [
            "room_id": roomId,
            "bid_amount": bidAmount ?? NSNull(),
            "user_name": userName,
            "user_image": userImage,
            "user_id": userId,
            "product_id": productId ?? NSNull(),
            "auction_type_id": auctionTypeId ?? NSNull()
        ])
    }

    /// Android: `socket?.emit("set_max_bid", payload)` (line ~295).
    public func emitSetMaxBid(
        roomId: String,
        userId: String,
        productId: String?,
        maxBid: String?
    ) {
        emit("set_max_bid", [
            "room_id": roomId,
            "user_id": userId,
            "product_id": productId ?? NSNull(),
            "max_bid": maxBid ?? NSNull()
        ])
    }

    /// Android: `socket?.emit("set_next_product", payload)` (line ~341).
    public func emitSetNextProduct(roomId: String, productId: String?) {
        emit("set_next_product", [
            "room_id": roomId,
            "product_id": productId ?? NSNull()
        ])
    }

    /// Android: `socket?.emit("liveScheduler", payload)` (line ~364).
    public func emitLiveScheduler(roomId: String) {
        emit("liveScheduler", ["room_id": roomId])
    }

    /// Android: `socket?.emit("allow_bid_for_all", payload)` (line ~378).
    public func emitAllowBidForAll(roomId: String, allowBidForAll: Bool) {
        emit("allow_bid_for_all", [
            "room_id": roomId,
            "allow_bid_for_all": allowBidForAll
        ])
    }

    /// Android: `socket?.emit("createRaid", payload)` (line ~398).
    public func emitCreateRaid(
        sourceRoomId: String,
        targetRoomId: String,
        sourceHostId: String,
        targetHostId: String
    ) {
        emit("createRaid", [
            "source_room_id": sourceRoomId,
            "target_room_id": targetRoomId,
            "source_host_id": sourceHostId,
            "target_host_id": targetHostId
        ])
    }

    /// Android: `socket?.emit("add_show_note", payload)` (line ~408).
    public func emitAddShowNote(roomId: String, note: String) {
        emit("add_show_note", [
            "room_id": roomId,
            "show_note": note
        ])
    }

    /// Android: `socket?.emit("chat", payload)` (line ~500).
    public func emitChat(
        roomId: String,
        userId: String,
        userName: String,
        userImage: String?,
        message: String
    ) {
        var payload: [String: Any] = [
            "room_id": roomId,
            "user_id": userId,
            "user_name": userName,
            "message": message
        ]
        if let image = userImage, !image.isEmpty {
            payload["user_image"] = image
        }
        emit("chat", payload)
    }

    /// Android: `socket?.emit("follow_unfollow", payload)` (line ~514).
    public func emitFollowUnfollow(roomId: String, userId: String, sellerId: String, isFollowed: Bool) {
        emit("follow_unfollow", [
            "room_id": roomId,
            "user_id": userId,
            "seller_id": sellerId,
            "is_followed": isFollowed
        ])
    }

    /// Android: `socket?.emit("create_poll", payload)` (line ~541).
    public func emitCreatePoll(
        roomId: String,
        question: String,
        options: [String],
        durationSeconds: Int
    ) {
        emit("create_poll", [
            "room_id": roomId,
            "question": question,
            "options": options,
            "duration": durationSeconds
        ])
    }

    /// Android: `socket?.emit("vote_poll", payload)` (line ~586).
    public func emitVotePoll(roomId: String, pollId: Int, optionIndex: Int, userId: String) {
        emit("vote_poll", [
            "poll_id": pollId,
            "option_index": optionIndex,
            "user_id": userId,
            "room_id": roomId
        ])
    }

    /// Android: `socket?.emit("end_poll", payload)` (line ~618).
    public func emitEndPoll(roomId: String, pollId: String) {
        emit("end_poll", [
            "poll_id": pollId,
            "room_id": roomId
        ])
    }

    /// Android: `socket?.emit("tip_setting_save", payload)` (line ~629).
    public func emitSaveTipSetting(showId: String, tipMessage: String, showInLiveChat: Bool) {
        emit("tip_setting_save", [
            "show_id": showId,
            "tip_message": tipMessage,
            "show_in_live_chat": showInLiveChat
        ])
    }

    /// Android: `socket?.emit("send_tip", payload)` (line ~656).
    public func emitSendTip(
        roomId: String,
        showId: String,
        userId: String,
        sellerId: String,
        amount: String
    ) {
        emit("send_tip", [
            "room_id": roomId,
            "show_id": showId,
            "seller_id": sellerId,
            "user_id": userId,
            "amount": amount
        ])
    }

    /// Android: `socket?.emit("start_auction", payload)` (line ~683).
    public func emitStartAuction(
        roomId: String,
        productIds: [String],
        startingBidAmount: String,
        requireTime: Int?,
        counterBidTime: Int?,
        suddenDeath: Bool?,
        auctionTypeId: Int?
    ) {
        emit("start_auction", [
            "room_id": roomId,
            "products": productIds,
            "starting_bid_amount": startingBidAmount,
            "require_time": requireTime ?? NSNull(),
            "counter_bid_time": counterBidTime ?? NSNull(),
            "sudden_death": suddenDeath ?? NSNull(),
            "auction_type_id": auctionTypeId ?? NSNull()
        ])
    }

    /// Android: `socket?.emit("pin_product", payload)` (line ~707).
    public func emitPinProduct(roomId: String, productId: String) {
        emit("pin_product", [
            "room_id": roomId,
            "product_id": productId
        ])
    }

    /// Android: `socket?.emit("run_next_product", payload)` (line ~737).
    public func emitRunNextProduct(roomId: String) {
        emit("run_next_product", ["room_id": roomId])
    }

    /// Android: `socket?.emit("set_promotion_data", payload)` (line ~769).
    public func emitSetPromotionData(payload: [String: Any]) {
        emit("set_promotion_data", payload)
    }

    /// Android: `socket?.emit("join_show", payload)` (line ~778).
    public func emitJoinShow(roomId: String, userId: String) {
        emit("join_show", ["room_id": roomId, "user_id": userId])
    }

    /// Android: `socket?.emit("sustained_watches", payload)` (line ~790).
    public func emitSustainedWatches(userId: String?, showId: String?) {
        emit("sustained_watches", [
            "user_id": userId ?? NSNull(),
            "show_id": showId ?? NSNull()
        ])
    }

    /// Android: `socket?.emit("create-freebie", payload)` (line ~800).
    public func emitCreateFreebie(roomId: String, productId: String, timeSeconds: String) {
        emit("create-freebie", [
            "room_id": roomId,
            "product_id": productId,
            "time": timeSeconds
        ])
    }

    /// Android: `socket?.emit("enter-in-freebie", payload)` (line ~809).
    public func emitEnterInFreebie(roomId: String, userId: String) {
        emit("enter-in-freebie", [
            "room_id": roomId,
            "user_id": userId
        ])
    }

    /// Android: `socket?.emit("finalize-freebie", payload)` (line ~839).
    public func emitFinalizeFreebie(roomId: String) {
        emit("finalize-freebie", ["room_id": roomId])
    }

    /// Android: `socket?.emit("remove-freebie-user", payload)` (line ~859).
    public func emitRemoveFreebieUser(roomId: String, userId: String) {
        emit("remove-freebie-user", [
            "room_id": roomId,
            "user_id": userId
        ])
    }

    // MARK: - Listeners (Android parity, see SocketManager.kt line refs)

    public func onRoomCreated(_ handler: @escaping ([String: Any]) -> Void) { listen("room_create_get", handler: handler) }
    public func onShowTimerUpdate(_ handler: @escaping ([String: Any]) -> Void) { listen("show_timer_update", handler: handler) }
    public func onRoomEnded(_ handler: @escaping ([String: Any]) -> Void) { listen("roomEnded", handler: handler) }
    public func onBidTimerUpdate(_ handler: @escaping ([String: Any]) -> Void) { listen("bid_timer_update", handler: handler) }
    public func onHighestBid(_ handler: @escaping ([String: Any]) -> Void) { listen("get_highest_bid", handler: handler) }
    public func onBidFinalized(_ handler: @escaping ([String: Any]) -> Void) { listen("bid_finalized", handler: handler) }
    public func onNextProductSet(_ handler: @escaping ([String: Any]) -> Void) { listen("next_product_set", handler: handler) }
    public func onAllowBidForAllUpdate(_ handler: @escaping ([String: Any]) -> Void) { listen("allow_bid_for_all_get", handler: handler) }
    public func onShowNote(_ handler: @escaping ([String: Any]) -> Void) { listen("get_show_note", handler: handler) }
    public func onRaidReceived(_ handler: @escaping ([String: Any]) -> Void) { listen("receiveRaid", handler: handler) }
    public func onViewerCount(_ handler: @escaping ([String: Any]) -> Void) { listen("viewerCount", handler: handler) }
    public func onChat(_ handler: @escaping ([String: Any]) -> Void) { listen("chat_get", handler: handler) }
    public func onUserFollowStatus(_ handler: @escaping ([String: Any]) -> Void) { listen("user_follow_status", handler: handler) }
    public func onPollCreated(_ handler: @escaping ([String: Any]) -> Void) { listen("poll_created", handler: handler) }
    public func onPollUpdate(_ handler: @escaping ([String: Any]) -> Void) { listen("poll_vote_update", handler: handler) }
    public func onPollEnded(_ handler: @escaping ([String: Any]) -> Void) { listen("poll_ended", handler: handler) }
    public func onPollVoteResult(_ handler: @escaping ([String: Any]) -> Void) { listen("poll_vote_result", handler: handler) }
    public func onVoteError(_ handler: @escaping ([String: Any]) -> Void) { listen("vote_error", handler: handler) }
    public func onTipSettingUpdated(_ handler: @escaping ([String: Any]) -> Void) { listen("tip_setting_updated", handler: handler) }
    public func onAuctionStarted(_ handler: @escaping ([String: Any]) -> Void) { listen("auction_started", handler: handler) }
    public func onProductPinned(_ handler: @escaping ([String: Any]) -> Void) { listen("product_pinned", handler: handler) }
    public func onProductUnpinned(_ handler: @escaping ([String: Any]) -> Void) { listen("product_unpinned", handler: handler) }
    public func onAuctionNextProduct(_ handler: @escaping ([String: Any]) -> Void) { listen("auction_next_product", handler: handler) }
    public func onRunNextProductError(_ handler: @escaping ([String: Any]) -> Void) { listen("run_next_product_error", handler: handler) }
    public func onFreebie(_ handler: @escaping ([String: Any]) -> Void) { listen("get-freebie", handler: handler) }
    public func onActiveShowUsers(_ handler: @escaping ([String: Any]) -> Void) { listen("active_show_users", handler: handler) }
    public func onFreebieWinner(_ handler: @escaping ([String: Any]) -> Void) { listen("get-freebie-winner", handler: handler) }
}
