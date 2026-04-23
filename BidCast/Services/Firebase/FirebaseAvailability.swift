//
//  FirebaseAvailability.swift
//  BidCast — iOS parity Phase 4k hotfix (2026-04-23)
//
//  Centralized "is the shipped GoogleService-Info.plist a real Firebase
//  registration or the committed placeholder?" check. AppDelegate uses this
//  to decide whether to call FirebaseApp.configure(); FirebaseChatStore
//  uses it to decide whether to even INSTANTIATE (which would trigger
//  Database.database() → implicit FIRApp.configure → NSException on a
//  placeholder plist and crash the app).
//
//  Crash signature this guards against (TestFlight build 181 / 2026-04-23):
//    +[FIRApp configure]
//    +[FIRApp configureWithOptions:]
//    +[FIRApp configureWithName:options:]
//    +[FIRApp addAppToAppDictionary:]
//    -[NSException raise:format:]
//    abort()
//
//  Until the iOS app is registered in the bidcast-a527c Firebase console
//  and the real GoogleService-Info.plist is dropped in, every Firebase
//  subsystem (Chat via RTDB, FCM push, Analytics) must be gated through
//  `FirebaseAvailability.isConfiguredPlistReal` and silently fall back to
//  its in-memory / no-op equivalent.
//

import Foundation

enum FirebaseAvailability {
    /// True only when `GoogleService-Info.plist` looks like a real Firebase
    /// registration (non-empty, non-"REPLACE…" GOOGLE_APP_ID that matches
    /// the `1:NNN:ios:HHHHH` format Firebase expects).
    ///
    /// Evaluated lazily and cached — the plist can't change at runtime.
    static let isConfiguredPlistReal: Bool = {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
            let appId = dict["GOOGLE_APP_ID"] as? String,
            !appId.isEmpty
        else {
            return false
        }
        if appId.uppercased().contains("REPLACE") { return false }
        // Firebase expects GOOGLE_APP_ID of the form `1:NNN:ios:HHHHH`.
        let pattern = "^[0-9]+:[0-9]+:(ios|android):[0-9a-f]+$"
        return appId.range(of: pattern, options: .regularExpression) != nil
    }()
}
