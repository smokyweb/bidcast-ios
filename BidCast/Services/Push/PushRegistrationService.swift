//
//  PushRegistrationService.swift
//  BidCast — iOS parity Phase 4l (2026-04-22)
//
//  Completes the FCM registration scaffolding that Phase 1c started:
//    - APNs token -> hand to Firebase Messaging
//    - Firebase mints FCM registration token -> cached in UserDefaults
//    - Whenever we have an FCM token AND the user is logged in, POST it
//      to `/api/upsert-device-details` (Android's canonical register
//      endpoint).
//
//  Notification payload routing (foreground + background + tap) is handled
//  here and forwards into `DeepLinkRouter` so the same router services both
//  URL schemes and remote notifications.
//

import Foundation
import UIKit
import UserNotifications

#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

final class PushRegistrationService {

    static let shared = PushRegistrationService()
    private init() {}

    // MARK: - Token persistence

    private let fcmTokenKey = "fcmDeviceToken"
    private let lastRegisteredKey = "fcmLastRegisteredToken"

    var cachedFcmToken: String? {
        UserDefaults.standard.string(forKey: fcmTokenKey)
    }

    // MARK: - APNs token -> FCM

    /// Call from `didRegisterForRemoteNotificationsWithDeviceToken`.
    func didReceiveApnsToken(_ deviceToken: Data) {
        #if canImport(FirebaseMessaging)
        Messaging.messaging().apnsToken = deviceToken
        #endif
    }

    // MARK: - FCM token received (from Firebase)

    /// Call from `MessagingDelegate.didReceiveRegistrationToken`.
    func didReceiveFcmToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: fcmTokenKey)
        // Fire-and-forget: register with backend if we have an auth token.
        Task { await registerWithBackend(force: false) }
    }

    /// Call when the user logs in (or on cold launch if already logged in).
    /// Will send a POST to `/api/upsert-device-details` with whatever FCM
    /// token we have cached.
    func registerWithBackend(force: Bool) async {
        guard let token = cachedFcmToken, !token.isEmpty else {
            debugLog("[Push] No FCM token cached; skip register")
            return
        }
        if !force,
           let last = UserDefaults.standard.string(forKey: lastRegisteredKey),
           last == token {
            return  // already registered with this exact token
        }
        let accessToken = UserDefaults.accessToken
        guard !accessToken.isEmpty else {
            debugLog("[Push] User not logged in; deferring device register")
            return
        }
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let tz = TimeZone.current.identifier
        let fields: [String: String] = [
            "device_token": token,
            "platform": "ios",
            "app_version": appVersion,
            "time_zone": tz
        ]
        do {
            let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                type: .upsertDeviceDetails(param: DeviceDetailsRequest(
                    deviceToken: token, platform: "ios",
                    appVersion: appVersion, timeZone: tz
                )),
                fields: fields,
                header: true
            )
            UserDefaults.standard.setValue(token, forKey: lastRegisteredKey)
            debugLog("[Push] Device token registered with backend")
        } catch {
            debugLog("[Push] upsert-device-details failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Incoming notification routing

    /// Foreground: decide presentation + record analytics. Deep-link routing
    /// only happens on tap (didReceive response).
    func handleForegroundNotification(
        _ notification: UNNotification
    ) -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        debugLog("[Push] FG payload: \(userInfo)")
        return [.banner, .sound, .badge, .list]
    }

    /// Tap: dispatch deep-link.
    func handleNotificationTap(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        debugLog("[Push] TAP payload: \(userInfo)")
        DeepLinkRouter.shared.routeFromPushPayload(userInfo)
    }

    /// didReceiveRemoteNotification (silent push + content-available).
    func handleSilentPush(
        _ userInfo: [AnyHashable: Any],
        completion: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        debugLog("[Push] SILENT payload: \(userInfo)")
        // No-op for now; backend will use silent pushes for unread badge counts etc.
        completion(.newData)
    }
}
