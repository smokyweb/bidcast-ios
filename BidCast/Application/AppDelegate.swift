//
//  AppDelegate.swift
//  BidCast
//
//  Created by Abdul-JAM-E-157 on 06/05/25.
//
//  iOS parity phase 1c (2026-04-22): wired Firebase + FCM + APNs registration
//  scaffolding. This is scaffolding only \u2014 full FCM channel / deep-link /
//  notification-tap payload routing lands in later phases (see TODOs).
//

import UIKit
import CoreData
import SVProgressHUD
import IQKeyboardManagerSwift
import UserNotifications

// FCM + Firebase are conditionally imported so that the iOS repo still compiles
// if someone builds before `pod install` has added Firebase pods (local
// builds are not supported anyway \u2014 Codemagic is the source of truth \u2014 but
// this keeps the scaffolding from becoming a hard compile-break during the
// first CI run when Podfile.lock is being regenerated).
#if canImport(FirebaseCore)
import FirebaseCore
#endif
#if canImport(FirebaseMessaging)
import FirebaseMessaging
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window : UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setupSVProgressHUD()
        self.configureFirebase()
        // iOS parity Phase 4a (2026-04-22): Stripe SDK bootstrap. Reads the
        // publishable key from Info.plist; no-op if the key still contains
        // the TODO-TREY placeholder.
        StripeService.shared.configure()
        self.registerForRemoteNotifications(application: application)
        // iOS parity phase 3i: install the Sell-tab swizzle so the empty
        // 29-line SellViewController stub embeds our real Phase 3 hub.
        P3SellSwizzle.installIfNeeded()
        // iOS parity Job A: route Home / Activity / Account tabs into Phase 3/4 VCs.
        JobAHomeSwizzle.installIfNeeded()
        JobAActivitySwizzle.installIfNeeded()
        JobAAccountSwizzle.installIfNeeded()
        // Phase 7i (2026-04-22): wire the .bidcastLiveAuthExpired notification
        // so any 401/403 from the live-stream socket or HTTP layer kicks the
        // user back to sign-in. Phase 5 published the notification from
        // LiveAuthGuard; this is the app-wide listener.
        self.observeLiveAuthExpired()
        return true
    }

    // MARK: - Phase 7i: live auth-expired observer

    private var liveAuthExpiredObserver: NSObjectProtocol?

    private func observeLiveAuthExpired() {
        liveAuthExpiredObserver = NotificationCenter.default.addObserver(
            forName: .bidcastLiveAuthExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.presentSessionExpiredAlert()
        }
    }

    private func presentSessionExpiredAlert() {
        guard let topVC = Self.topMostViewController() else { return }
        // Avoid stacking duplicate alerts if multiple 401s fire at once.
        if topVC is UIAlertController { return }
        let alert = UIAlertController(
            title: L10n("session_expired"),
            message: L10n("session_expired_message"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n("ok"), style: .default) { [weak self] _ in
            self?.navigateToSignIn()
        })
        topVC.present(alert, animated: true)
    }

    private static func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let root = base ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        if let nav = root as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return root
    }

    private func navigateToSignIn() {
        // Clear any cached session; storyboard-based SceneDelegate owns the
        // actual root-swap on SignIn. For now, dismiss any presented modals
        // and instantiate the Onboardings storyboard as root.
        _ = KeychainHelper.delete(forKey: "authToken")
        let window = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first ?? self.window
        guard let window = window else { return }
        window.rootViewController?.dismiss(animated: false)
        let storyboard = UIStoryboard(name: "Onboardings", bundle: nil)
        if let signIn = storyboard.instantiateInitialViewController() {
            window.rootViewController = signIn
        }
    }

    func setupSVProgressHUD(){
        // iOS parity phase 1: removed IAPManager call (StoreKit IAP was WellGenius template cruft, not a Bidcast feature)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setDefaultAnimationType(.flat)
        SVProgressHUD.setForegroundColor(#colorLiteral(red: 0.1019607843, green: 0.3215686275, blue: 0.6823529412, alpha: 1))
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setBackgroundLayerColor(.black.withAlphaComponent(0.8))
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        window?.overrideUserInterfaceStyle = .light
    }

    // MARK: - Firebase configure (iOS parity phase 1c scaffold)
    //
    // Loads GoogleService-Info.plist and bootstraps FirebaseApp. Because the
    // committed plist is a placeholder until the real values are dropped in
    // from the Firebase console, this call will succeed but none of the FCM
    // or Analytics features will actually reach the Firebase backend. That's
    // intentional for Phase 1 \u2014 we are only wiring scaffolding, not
    // connecting to Firebase yet.
    private func configureFirebase() {
        #if canImport(FirebaseCore)
        // QA-FIX-cmoafjxce002xzl1hgb5uj1l8: GoogleService-Info.plist on the QA branch
        // still contains placeholder strings (e.g. REPLACE-FROM-FIREBASE-CONSOLE-ios)
        // because the iOS app entry in the Firebase console hasn't been created yet.
        // FirebaseApp.configure() calls [FIROptions validateWithTarget:] which
        // raises an NSException on an invalid GOOGLE_APP_ID format and crashes the
        // app on launch. Guard the configure call so we only bootstrap Firebase
        // when the plist looks real. Push/analytics will silently no-op until the
        // real plist is dropped in, but the app will at least launch.
        guard isFirebaseOptionsPlistValid() else {
            NSLog("[BidCast] Skipping FirebaseApp.configure(): GoogleService-Info.plist has placeholder values")
            return
        }
        FirebaseApp.configure()
        #if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
        #endif
        #endif
    }

    private func isFirebaseOptionsPlistValid() -> Bool {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any]
        else {
            return false
        }
        guard let appId = dict["GOOGLE_APP_ID"] as? String, !appId.isEmpty else {
            return false
        }
        if appId.uppercased().contains("REPLACE") { return false }
        // Firebase expects GOOGLE_APP_ID of the form `1:NNN:ios:HHHHH`.
        // Do a lightweight format check so we don't trigger the framework's
        // fatal NSException on obviously-bogus values.
        let pattern = "^[0-9]+:[0-9]+:(ios|android):[0-9a-f]+$"
        return appId.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: - APNs + FCM registration (iOS parity phase 1c scaffold)
    //
    // Asks the user for notification permission and, if granted, registers
    // the app with APNs. When APNs delivers the device token, Firebase
    // Messaging uses it to mint an FCM registration token; we forward that
    // FCM token to the backend's `device-details` endpoint (same wiring
    // Android uses). Payload-format and notification-tap handling land in a
    // later phase.
    private func registerForRemoteNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                debugLog("APNs authorization error: \(error)")
                return
            }
            debugLog("APNs authorization granted: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }

    // MARK: UIApplicationDelegate \u2014 APNs token callbacks

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenHex = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        debugLog("APNs device token (raw hex): \(tokenHex)")
        // iOS parity Phase 4l: hand the APNs token to the PushRegistrationService,
        // which forwards to Firebase Messaging + registers with the backend.
        PushRegistrationService.shared.didReceiveApnsToken(deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugLog("APNs registration failed: \(error)")
    }

    // MARK: - Silent / background push (iOS parity Phase 4l)

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushRegistrationService.shared.handleSilentPush(userInfo, completion: completionHandler)
    }

    // MARK: - URL scheme + Universal Links (iOS parity Phase 4m)

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        DeepLinkRouter.shared.route(url: url)
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return DeepLinkRouter.shared.routeUniversalLink(userActivity) != nil
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "BidCast")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

// MARK: - UNUserNotificationCenterDelegate (iOS parity phase 1c scaffold)
//
// Minimal handlers so that foreground push still shows a banner and tapping
// a push logs the payload. Real deep-link / tap routing lands in phase 2+.
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        let opts = PushRegistrationService.shared.handleForegroundNotification(notification)
        completionHandler(opts)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // iOS parity Phase 4l+4m: route to the appropriate VC via DeepLinkRouter.
        PushRegistrationService.shared.handleNotificationTap(response)
        completionHandler()
    }
}

// MARK: - MessagingDelegate (iOS parity phase 1c scaffold)
//
// Receives the FCM registration token whenever Firebase mints or rotates it,
// and forwards it to the backend via device-details.
#if canImport(FirebaseMessaging)
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        debugLog("FCM registration token: \(token)")
        // iOS parity Phase 4l: PushRegistrationService persists + auto-syncs
        // with the backend on every token rotation, matching Android's
        // MyFirebaseMessagingService.
        PushRegistrationService.shared.didReceiveFcmToken(token)
    }
}
#endif
