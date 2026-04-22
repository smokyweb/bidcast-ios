//
//  LiveAuthGuard.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  Shared authorization-failure handling for live-stream backend calls.
//  When go-live / join-room / agora-token hits 401 or 403, callers post
//  a notification that the AppDelegate (or root VC) can observe to kick
//  the user back to the login screen.
//
//  We avoid a hard import dependency on a specific login screen here;
//  posting a notification lets whatever navigation owner currently holds
//  the root viewController decide how to respond.
//

import Foundation

public extension Notification.Name {
    /// Posted when any live-stream backend call returns 401 or 403.
    /// UserInfo: { "message": String, "source": String }
    static let bidcastLiveAuthExpired = Notification.Name("BidcastLiveAuthExpired")
}

public enum LiveAuthGuard {

    /// Inspect an error; if it looks like an auth failure, post the
    /// notification and return true so callers can short-circuit the
    /// user-facing error alert.
    @discardableResult
    public static func handleIfAuthFailure(error: Error, source: String) -> Bool {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        if isAuthFailure(message: message) {
            NotificationCenter.default.post(
                name: .bidcastLiveAuthExpired,
                object: nil,
                userInfo: [
                    "message": message,
                    "source": source
                ]
            )
            return true
        }
        return false
    }

    public static func isAuthFailure(message: String) -> Bool {
        let lower = message.lowercased()
        return lower.contains("not authorized") ||
            lower.contains("unauthorized") ||
            lower.contains("401") ||
            lower.contains("403") ||
            lower.contains("token expired") ||
            lower.contains("please log in again")
    }
}
