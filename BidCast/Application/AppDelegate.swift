//
//  AppDelegate.swift
// BidSwipe
//
//  Created by JAM-E-282 on 20/01/24.
//

import Foundation
import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import Stripe
//import ZegoExpressEngine
import FirebaseCore
import FirebaseMessaging



class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.languageSelection()
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setForegroundColor(.secondary)
        SVProgressHUD.setBackgroundColor(.bg)
        SVProgressHUD.setBackgroundLayerColor(.black.withAlphaComponent(0.4))
        
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistance = 10
        IQKeyboardManager.shared.enableAutoToolbar = true
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
//        STPAPIClient.shared.publishableKey = "pk_test_51RQLxjQEbmPLLc7GaDeFTplB9lwTK5t9ZvpHVd1CtK4XtWsmktQvN3hoZW0ZZ0kSu0PFJ6R63D9X3PSMAq8tg5Sh00Vzh05MeU"
        STPAPIClient.shared.publishableKey =
 "pk_test_51SjiEtQzmy9jx34KXrnMJIwqLx5IfCN69oZsNCptlyBfChq7NrJVc8OjS5q16nvnuobjjp3Run8icoXQHn0D9eVG00nJyhk9zM"
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        
        NSSetUncaughtExceptionHandler { exception in
            Log.e("Error Handling: \(exception)")
            Log.e("Error Handling callStackSymbols: \(exception.callStackSymbols)")
        }
        
        
        UITextField.appearance().tintColor = .text
        UIScrollView.appearance().bounces = true
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting authorization: \(error)")
            }
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        registerNotificationCategory()
        return true
    }
    
    func registerNotificationCategory() {
        let openAction = UNNotificationAction(identifier: "OPEN_FILE", title: "Open File", options: [.foreground])
        let category = UNNotificationCategory(identifier: "DOWNLOAD_COMPLETE", actions: [openAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    
    func languageSelection(){
        if LanguageManager.shared.selectedLanguage == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}

//MARK: AppDelegate, UNUserNotificationCenterDelegate, MessagingDelegate.
extension AppDelegate: UNUserNotificationCenterDelegate,MessagingDelegate {

    //MARK: Redirect other screen
    private func redirectNotification(with payload: [AnyHashable: Any]) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: Notification.Name("Notification"),
                        object: nil,
                        userInfo: payload
                    )
                }
            } else {
                print("❌ Notification permission denied")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Called when FCM token is received or updated
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("FCM token: \(token)")
            UserDefaults.FCMToken = token
            
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("will Receive \(userInfo)")
        
        // Extract values safely
        let title = userInfo["title"] as? String
        let type = userInfo["type"] as? String
        
        if type == "Seller Identity" {
               if title == "Identity Verified" {
                   UserDefaults.sellerVerafied = "verified"
//                   NotificationCenter.default.post(name: .sellerVerifiedUpdated, object: nil)
               } else if title == "Identity Rejected" {
                   UserDefaults.sellerVerafied = "rejected"
//                   NotificationCenter.default.post(name: .sellerVerifiedUpdated, object: nil)
               }
           }
        
        let userId = userInfo["sender_id"] as? String
        if userId  == UserDefaults.userId.description {
            completionHandler([])
        }else{
            completionHandler([.alert, .sound, .badge]) // Or customize as needed
        }
        
        // Present the notification normally
        
    }
    
    
    // MARK: Use for app kill state and background
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        self.redirectNotification(with: userInfo) // ✅ Pass directly
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == "OPEN_FILE" {
            if let filePath = response.notification.request.content.userInfo["filePath"] as? String {
                let url = URL(fileURLWithPath: filePath)
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        }
        // #9960387225 — Push tap-through. This completion-handler delegate is the
        // one iOS actually invokes on a notification TAP (when both this and the
        // async didReceive variant exist, UIKit calls THIS one). Previously it only
        // called redirectNotification(), which posts a generic event with NO
        // type-based routing — so every tap fell through to the default screen
        // (home). Route by type here so cancellation→orders, offer→Offers, etc.
        self.routeNotificationByType(userInfo)
        self.redirectNotification(with: userInfo)
        completionHandler()
    }
}

//MARK: AppDelegate.
extension AppDelegate {
    // #9960387225 — Shared push tap-through router. Called from the active
    // completion-handler didReceive delegate so taps actually route by type.
    // (Previously this switch lived only in an `async didReceive` variant that
    // UIKit never invokes when the completion-handler variant is also present,
    // making the whole routing dead code — every tap landed on home.)
    func routeNotificationByType(_ userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return }
        if let filePath = userInfo["filePath"] as? String {
            let fileURL = URL(fileURLWithPath: filePath)

            DispatchQueue.main.async {
                UIApplication.shared.open(fileURL)
            }
        }

        // #9960387225 — Push notification tap-through for all notification types.
        // Each case below posts an NSNotification that TabbarScreen (or ActivityScreen)
        // observes to switch to the correct tab/screen.
        //
        // Backend data-key reference (confirmed from Laravel ApiController +
        // InquiryController + bidcast-node/notification.js):
        //   Live Room Started   room_id, sender_id
        //   message             sender_id, sender_name, sender_imagee
        //   inquiry_message     thread_id, sender_id
        //   bid                 bid_id, product_id, sender_id
        //   bid_won             bid_id, product_id, show_id
        //   offer_received      offer_id, product_id, sender_id
        //   offer_accepted /    offer_id, product_id, sender_id
        //     offer_declined
        //   purchase            order_id, product_id, sender_id
        //   sold                order_id, product_id, sender_id
        //   cancellation_*      order_id, product_id, sender_id
        //   cohost_invite       cohost_invite_id, schedule_show_id, show_title
        //   credited/debited    DB-only, no FCM push (handled defensively)
        switch type {

        // ── Peer DM chat ──────────────────────────────────────────────────
        case "message":
            // Switches to Activity tab; existing observer in ActivityScreen
            // wires the DM list.
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavToActivityScreen"), object: nil)
            }

        // ── Buyer↔Seller inquiry thread ─────────────────────────────────
        case "inquiry_message":
            // Trey QA 2026-05-31: buyer↔seller REST inquiry deep-link.
            // Push payload carries data.type="inquiry_message" + data.thread_id.
            let rawThreadId = userInfo["thread_id"]
            let threadId: Int?
            if let intId = rawThreadId as? Int {
                threadId = intId
            } else if let strId = rawThreadId as? String {
                threadId = Int(strId)
            } else {
                threadId = nil
            }
            if let tid = threadId {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavToInquiryThread"),
                        object: tid
                    )
                }
            } else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavToInquiryInbox"),
                        object: nil
                    )
                }
            }

        // ── Live room ───────────────────────────────────────────────────
        // BUG FIX: was routing to a generic screen.  Now routes to Home tab
        // with the room_id so HomeViewScreen can open the live viewer.
        // Context: a buyer tapping this notification is a VIEWER; the live
        // stream viewer is opened from the Home tab by passing room_id.
        case "Live Room Started":
            let roomIdRaw = userInfo["room_id"]
            let roomId: String
            if let r = roomIdRaw as? String { roomId = r }
            else if let r = roomIdRaw as? Int { roomId = String(r) }
            else { roomId = "" }
            guard !roomId.isEmpty else { break }
            DispatchQueue.main.async {
                // "NavToLiveRoom" — TabbarScreen switches to Home tab and
                // passes the room_id to HomeViewScreen via selectedShowId.
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavToLiveRoom"),
                    object: roomId
                )
            }

        // ── Bid placed (seller receives) / bid won (buyer wins) ──────────
        // Routes to Activity tab → Bids segment (index 1).
        case "bid", "bid_won", "bid_placed":
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavToActivityTab"),
                    object: 1   // Segment.bid.index
                )
            }

        // ── Offer received / accepted / declined ───────────────────────
        // Routes to Activity tab → Offers segment (index 2).
        // Backend sends "offer_received", "offer_accepted", "offer_declined".
        case _ where type.hasPrefix("offer_") || type == "offer":
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavToActivityTab"),
                    object: 2   // Segment.offer.index
                )
            }

        // ── Purchase / sale / cancellation / order status ──────────────
        // Routes to Activity tab → Purchases segment (index 3).
        // Note: OrderStatusScreen requires a MyOrderModel binding, so we route
        // to the Purchases list rather than deep-linking to a specific order.
        // A future improvement can carry order_id here and open OrderStatusScreen
        // directly once ActivityScreen exposes a push-driven orderId binding.
        case "purchase", "sold",
             "cancellation_requested", "cancellation_approved", "cancellation_rejected",
             "order_placed", "order_confirmed", "Order Status Updated":
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("NavToActivityTab"),
                    object: 3   // Segment.purchases.index
                )
            }

        // ── Co-host invite ───────────────────────────────────────────
        case "cohost_invite":
            let rawInviteId = userInfo["cohost_invite_id"]
            let inviteId: Int?
            if let intId = rawInviteId as? Int {
                inviteId = intId
            } else if let strId = rawInviteId as? String {
                inviteId = Int(strId)
            } else if let doubleId = rawInviteId as? Double {
                inviteId = Int(doubleId)
            } else {
                inviteId = nil
            }
            if let inviteId {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("NavToCoHostInvite"),
                        object: inviteId
                    )
                }
            }

        // ── Wallet credited / debited ─────────────────────────────
        // These are DB / transaction-history only; no FCM push confirmed.
        // Handled defensively: no routing action needed.
        case "credited", "debited":
            break

        // ── Account onboarding / promote show (DB-only, no FCM push) ──
        case "account_onboarding", "promote_show":
            break

        default:
            break
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        print("Will Present User Info: \(userInfo)")
        // Return how you want the notification to be presented when the app is in the foreground
        
        let userId = userInfo["sender_id"] as? Int
        if userId  == UserDefaults.userId {
            return []
        }else{
            return [.banner, .sound, .badge] // Or customize as needed
        }
    }
}

