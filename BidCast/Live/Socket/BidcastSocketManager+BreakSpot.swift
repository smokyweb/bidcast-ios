//
//  BidcastSocketManager+BreakSpot.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  Fill the "break spot" half of Android SocketManager.kt that was absent in
//  the initial Phase 2 iOS port. Break-spot is Bidcast's breakout auction
//  flow (parallel to the main auction pipeline) that Android fires via
//  `start_auction_break_spot`, `place_bid_break_spot`, and listens on
//  `auction_started_break_spot`, `bid_timer_update_break_spot`,
//  `get_highest_bid_break_spot`, `bid_finalized_break_spot`.
//
//  Matching the exact event names is mandatory so iOS viewers/hosts
//  participate in the same socket room as Android/PWA during break-spot
//  auctions.
//
//  References:
//    - bidcast-android/.../SocketManager.kt lines 886, 890, 924, 929, 939, 949
//

import Foundation

public extension BidcastSocketManager {

    // MARK: - Emits (break-spot variants)

    /// Android: `socket?.emit("start_auction_break_spot", payload)` (line 886)
    func emitStartAuctionBreakSpot(
        roomId: String,
        productIds: [String],
        startingBidAmount: String,
        requireTime: Int?,
        counterBidTime: Int?,
        suddenDeath: Bool?,
        auctionTypeId: Int?
    ) {
        performEmit("start_auction_break_spot", [
            "room_id": roomId,
            "products": productIds,
            "starting_bid_amount": startingBidAmount,
            "require_time": requireTime ?? NSNull(),
            "counter_bid_time": counterBidTime ?? NSNull(),
            "sudden_death": suddenDeath ?? NSNull(),
            "auction_type_id": auctionTypeId ?? NSNull()
        ])
    }

    /// Android: `socket?.emit("place_bid_break_spot", payload)` (line 925)
    func emitPlaceBidBreakSpot(
        roomId: String,
        userId: String,
        userName: String,
        userImage: String,
        productId: String?,
        bidAmount: String?,
        auctionTypeId: Int?
    ) {
        performEmit("place_bid_break_spot", [
            "room_id": roomId,
            "bid_amount": bidAmount ?? NSNull(),
            "user_name": userName,
            "user_image": userImage,
            "user_id": userId,
            "product_id": productId ?? NSNull(),
            "auction_type_id": auctionTypeId ?? NSNull()
        ])
    }

    // MARK: - Listeners (break-spot variants)

    /// Android: `socket?.on("auction_started_break_spot", ...)` (line 891)
    func onAuctionStartedBreakSpot(_ handler: @escaping ([String: Any]) -> Void) {
        performListen("auction_started_break_spot", handler: handler)
    }

    /// Android: `socket?.on("bid_timer_update_break_spot", ...)` (line 929)
    func onBidTimerUpdateBreakSpot(_ handler: @escaping ([String: Any]) -> Void) {
        performListen("bid_timer_update_break_spot", handler: handler)
    }

    /// Android: `socket?.on("get_highest_bid_break_spot", ...)` (line 939)
    func onHighestBidBreakSpot(_ handler: @escaping ([String: Any]) -> Void) {
        performListen("get_highest_bid_break_spot", handler: handler)
    }

    /// Android: `socket?.on("bid_finalized_break_spot", ...)` (line 949)
    func onBidFinalizedBreakSpot(_ handler: @escaping ([String: Any]) -> Void) {
        performListen("bid_finalized_break_spot", handler: handler)
    }

    // MARK: - Listener helpers (bridges to private shape of the main class)

    /// Public-facing raw emit used by this extension. Wraps the private
    /// `emit(_:_:)` by routing through `emitRaw(event:payload:)` so callers
    /// can use any event name without touching the private API.
    internal func performEmit(_ event: String, _ payload: [String: Any]) {
        emitRaw(event: event, payload: payload)
    }

    internal func performListen(_ event: String, handler: @escaping ([String: Any]) -> Void) {
        listenRaw(event: event, handler: handler)
    }
}

// MARK: - Internal bridges

public extension BidcastSocketManager {

    /// Generic raw emit used by this file and future extensions. Public so
    /// feature-specific call sites that haven't been typed yet can still
    /// emit arbitrary events matching Android's contract.
    func emitRaw(event: String, payload: [String: Any]) {
        #if canImport(SocketIO)
        _emitBridge(event, payload)
        #else
        #if DEBUG
        print("[BidcastSocket] emitRaw(\(event)) skipped — SocketIO pod missing")
        #endif
        #endif
    }

    /// Generic raw listener. Replaces any existing listener for `event`.
    func listenRaw(event: String, handler: @escaping ([String: Any]) -> Void) {
        #if canImport(SocketIO)
        _listenBridge(event, handler)
        #endif
    }

    /// Decoded listener: auto-decodes the JSON payload into a `Codable` model
    /// and dispatches on main thread. Parse errors are silently dropped in
    /// release builds; DEBUG builds log the error + raw payload for
    /// diagnosis. Matches Android's `Moshi.adapter(...).fromJson(...)` style.
    func listen<T: Decodable>(event: String, as _: T.Type, handler: @escaping (T) -> Void) {
        listenRaw(event: event) { payload in
            do {
                let data = try JSONSerialization.data(withJSONObject: payload, options: [])
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let value = try decoder.decode(T.self, from: data)
                handler(value)
            } catch {
                #if DEBUG
                print("[BidcastSocket] decode failed for \(event):", error, "payload:", payload)
                #endif
            }
        }
    }
}
