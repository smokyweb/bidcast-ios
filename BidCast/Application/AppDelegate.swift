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
        self.registerForRemoteNotifications(application: application)
        // iOS parity phase 3i: install the Sell-tab swizzle so the empty
        // 29-line SellViewController stub embeds our real Phase 3 hub.
        P3SellSwizzle.installIfNeeded()
        return true
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
        FirebaseApp.configure()
        #if canImport(FirebaseMessaging)
        Messaging.messaging().delegate = self
        #endif
        #endif
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
        #if canImport(FirebaseMessaging)
        // Hand the raw APNs token to Firebase so it can mint an FCM token.
        Messaging.messaging().apnsToken = deviceToken
        #endif
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugLog("APNs registration failed: \(error)")
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
        debugLog("Foreground push received: \(notification.request.content.userInfo)")
        completionHandler([.banner, .sound, .badge, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        debugLog("Notification tapped: \(response.notification.request.content.userInfo)")
        // TODO(phase 2+): parse payload and route to the appropriate VC
        // (live show, chat thread, order detail, etc.) to match Android's
        // MyFirebaseMessagingService + DashActivity deep-link handling.
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
        // Persist locally so SignIn + any future "send device details" call
        // can include it in the device-details payload.
        UserDefaults.standard.setValue(token, forKey: "fcmDeviceToken")
        // TODO(phase 2): once APIManager auth-token refresh lands, POST this
        // token via APIEndPoint.sendDeviceDetails (already wired) on every
        // rotation. Android triggers this from MyFirebaseMessagingService.
    }
}
#endif
