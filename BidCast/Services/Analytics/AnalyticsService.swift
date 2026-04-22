//
//  AnalyticsService.swift
//  BidCast
//
//  iOS Parity Phase 7a (2026-04-22): thin Firebase Analytics wrapper.
//
//  Matches Android event names (see Android `AnalyticsHelper.kt` convention).
//  All calls are wrapped in `#if canImport(FirebaseAnalytics)` so the repo
//  compiles before `pod install` runs and never crashes on local dev.
//
//  Keep event names + param keys in sync with Android:
//    - event: snake_case, lower-cased, <= 40 chars, letters/numbers/underscore
//    - param keys: snake_case, <= 40 chars
//    - param values: String / Int / Double / Bool (Firebase auto-handles)
//
//  Funnel events shipped in Phase 7a:
//    sign_up / sign_in (method)
//    view_item (product_id, content_type)
//    add_payment_info
//    begin_checkout / purchase (value, currency, transaction_id)
//    view_live_show (show_id)
//    place_bid / set_max_bid (show_id, amount_cents)
//    send_tip (show_id, amount_cents)
//    start_show (show_id)
//    end_show (show_id)
//    create_poll / run_randomizer / start_raid (show_id)
//    follow_user / unfollow_user (target_user_id)
//
//  app_open is automatic via Firebase's SDK on launch.

import Foundation

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

/// Thin wrapper over Firebase Analytics. Use the static `AnalyticsService.shared`
/// singleton or the convenience static methods on `Analytics` enum below.
final class AnalyticsService {

    static let shared = AnalyticsService()
    private init() {}

    // MARK: - Core log

    /// Log a custom analytics event. No-op when Firebase isn't linked.
    func log(_ eventName: String, params: [String: Any]? = nil) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(eventName, parameters: params)
        #else
        #if DEBUG
        print("[Analytics] \(eventName) params=\(params ?? [:])")
        #endif
        _ = eventName; _ = params
        #endif
    }

    /// Set a user property. No-op when Firebase isn't linked.
    func setUserProperty(_ value: String?, forName name: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserProperty(value, forName: name)
        #else
        _ = value; _ = name
        #endif
    }

    /// Identify the current user.
    func setUserID(_ userId: String?) {
        #if canImport(FirebaseAnalytics)
        Analytics.setUserID(userId)
        #else
        _ = userId
        #endif
    }

    // MARK: - Auth funnel

    func logSignIn(method: String) {
        log("sign_in", params: ["method": method])
    }

    func logSignUp(method: String) {
        log("sign_up", params: ["method": method])
    }

    // MARK: - Catalog / checkout funnel

    func logViewItem(productId: String) {
        log("view_item", params: ["product_id": productId, "content_type": "product"])
    }

    func logAddPaymentInfo() {
        log("add_payment_info")
    }

    func logBeginCheckout(valueCents: Int?, currency: String = "USD") {
        var params: [String: Any] = ["currency": currency]
        if let v = valueCents { params["value"] = Double(v) / 100.0 }
        log("begin_checkout", params: params)
    }

    func logPurchase(transactionId: String?, valueCents: Int?, currency: String = "USD") {
        var params: [String: Any] = ["currency": currency]
        if let tx = transactionId { params["transaction_id"] = tx }
        if let v = valueCents { params["value"] = Double(v) / 100.0 }
        log("purchase", params: params)
    }

    // MARK: - Live funnel

    func logViewLiveShow(showId: String) {
        log("view_live_show", params: ["show_id": showId])
    }

    func logPlaceBid(showId: String, amountCents: Int) {
        log("place_bid", params: ["show_id": showId, "amount_cents": amountCents])
    }

    func logSetMaxBid(showId: String, amountCents: Int) {
        log("set_max_bid", params: ["show_id": showId, "amount_cents": amountCents])
    }

    func logSendTip(showId: String, amountCents: Int) {
        log("send_tip", params: ["show_id": showId, "amount_cents": amountCents])
    }

    // MARK: - Host funnel

    func logStartShow(showId: String) {
        log("start_show", params: ["show_id": showId])
    }

    func logEndShow(showId: String) {
        log("end_show", params: ["show_id": showId])
    }

    func logCreatePoll(showId: String) {
        log("create_poll", params: ["show_id": showId])
    }

    func logRunRandomizer(showId: String) {
        log("run_randomizer", params: ["show_id": showId])
    }

    func logStartRaid(showId: String, targetShowId: String?) {
        var params: [String: Any] = ["show_id": showId]
        if let t = targetShowId { params["target_show_id"] = t }
        log("start_raid", params: params)
    }

    // MARK: - Social

    func logFollowUser(targetUserId: String) {
        log("follow_user", params: ["target_user_id": targetUserId])
    }

    func logUnfollowUser(targetUserId: String) {
        log("unfollow_user", params: ["target_user_id": targetUserId])
    }
}
