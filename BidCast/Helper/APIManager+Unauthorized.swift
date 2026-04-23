//
//  APIManager+Unauthorized.swift
//  BidCast — iOS Parity Phase 8 / P2.17 (2026-04-23)
//
//  Global 401 handling to match Android's `BaseRepository.getHttpErrorMessage(401)`:
//  when any API call returns HTTP 401 we broadcast a single notification, the
//  active scene clears `UserDefaults.accessToken`, surfaces a "Session expired.
//  Please login again." alert, and pops back to SignInViewController.
//
//  Why a notification instead of a coupling to the UI layer?
//    - APIManager lives in Helper/ and must not import UIKit.
//    - A Notification lets SceneDelegate (which already owns the root
//      navigation stack) react on the main thread without the networking
//      layer knowing anything about UIWindow.
//    - This also keeps us safe in non-UI contexts (Task, tests, watchOS).
//
//  Call sites inside APIManager post this notification from every status-code
//  guard that throws `DataError.invalidCode`. Only a single toast is shown
//  per "session", debounced inside the responder so multiple simultaneous
//  failing requests don't spam the user.
//
//  Android reference:
//    app/src/main/java/io/bidswipe/app/base/BaseRepository.kt:121
//        `401 -> "Session expired. Please login again."`
//

import Foundation

/// Posted from `APIManager` whenever any API response returns HTTP 401.
///
/// SceneDelegate listens for this in `sceneDidBecomeActive` (wired early so
/// background-launched 401s still fire on return) and shows a single alert
/// then pops to SignInViewController.
extension Notification.Name {
    static let bidcastAPISessionExpired = Notification.Name("bidcast.api.session_expired")
}

extension APIManager {

    /// Examines an HTTPURLResponse and, if it indicates an expired session,
    /// clears the stored access token and broadcasts
    /// `.bidcastAPISessionExpired`. Safe to call from any thread; the
    /// notification is dispatched on the main queue so UI-layer listeners
    /// can update state directly.
    ///
    /// Callers should invoke this before throwing `DataError.invalidCode`
    /// for any non-2xx response.
    static func handleStatusCodeIfNeeded(_ statusCode: Int) {
        guard statusCode == 401 else { return }
        // Clear token so any in-flight requests that re-check auth are also
        // treated as signed-out. Matches Android's behaviour. The string
        // key matches `UserDefaultsKeys.accessToken` verified in
        // BidCast/Helper/UserDefaultKeys.swift.
        UserDefaults.accessToken = ""
        UserDefaults.standard.synchronize()
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .bidcastAPISessionExpired,
                object: nil,
                userInfo: ["statusCode": statusCode]
            )
        }
    }
}
