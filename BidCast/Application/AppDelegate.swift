//
//  AppDelegate.swift
// BidSwipe
//
//  Created by JAM-E-282 on 20/01/24.
//

import Foundation
import UIKit
//import OneSignalFramework
//import OneSignalCore
//import OneSignalExtension
//import Firebase
//import FirebaseCore
//import GooglePlaces
import IQKeyboardManagerSwift



class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.languageSelection()
//        STPAPIClient.shared.publishableKey = "pk_test_51RQLxjQEbmPLLc7GaDeFTplB9lwTK5t9ZvpHVd1CtK4XtWsmktQvN3hoZW0ZZ0kSu0PFJ6R63D9X3PSMAq8tg5Sh00Vzh05MeU"
        // Remove this method to stop OneSignal Debugging
        //        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        //        let observer = MyPushSubscriptionObserver()
        //        OneSignal.User.pushSubscription.addObserver(observer)
        //
        //        OneSignal.initialize("973c5938-5a1c-410e-8389-02b74b38f6c6", withLaunchOptions: launchOptions)
        //
        //        OneSignal.Notifications.requestPermission({ accepted in
        //            Log.s("User accepted notifications: \(accepted)")
        //            Log.s("User ID: \(OneSignal.User)")
        //            UserDefaultsManager.shared.setValue(OneSignal.User.onesignalId ?? "", forKey: .deviceToken)
        //            DispatchQueue.main.async {
        //                UIApplication.shared.registerForRemoteNotifications()
        //            }
        //        }, fallbackToSettings: true)
        //
        //        FirebaseApp.configure()
        ////        Messaging.messaging().delegate = self
        //
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistance = 10

        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            //            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings: UIUserNotificationSettings =
                .init(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        NSSetUncaughtExceptionHandler { exception in
            Log.e("Error Handling: \(exception)")
            Log.e("Error Handling callStackSymbols: \(exception.callStackSymbols)")
        }
        
        //        UserDefaultsManager.shared.setValue(true, forKey: .showMatchingSheet)
        
        UITextField.appearance().tintColor = .text
        
        UIScrollView.appearance().bounces = true
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
        return true
    }
    
    func languageSelection(){
        if LanguageManager.shared.selectedLanguage == "ar" {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
    }
    
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    //        // Handle the redirect URL here
    //        // For example:
    //        if url.scheme == "your_redirect_scheme" {
    //            // This URL is the redirect URL from your authorization flow
    //            // You can handle it further, for example, by extracting parameters
    //            // and updating your app's state or UI accordingly.
    //            // Example:
    //        }
    //        return true
    //    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "myapp" && url.host == "google-calendar" && url.path == "/callback-process" {
            // Handle the redirection here
            // Extract and process the authorization code from the URL
            return true
        }
        return false
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    //    func onPushSubscriptionDidChange(state: OneSignalUser.OSPushSubscriptionChangedState) {
    //        Log.s(state)
    //        if let token = state.current.token {
    //            Log.s("FCM token: \(token)")
    //            UserDefaultsManager.shared.setValue(token, forKey: .deviceToken)
    //        }
    //    }
}

//@available(iOS 10, *)
//extension AppDelegate: UNUserNotificationCenterDelegate {
//        // Receive displayed notifications for iOS 10 devices.
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//
//        if let messageID = userInfo[gcmMessageIDKey] as? String {
//            Log.s("Message ID Extension willPresent: \(messageID)")
//        }
//
//        // Check if the notification was already modified
//        if userInfo["modified"] as? Bool == true {
//            // If already modified, just display it normally
//            completionHandler([.banner, .badge, .sound])
//            return
//        }
//
//        var plainTextBody: String? = nil
//
//        if let aps = userInfo["aps"] as? [String: Any],
//           let alert = aps["alert"] as? [String: Any],
//           let bodyHTML = alert["body"] as? String {
//
//            plainTextBody = decodeHTML(bodyHTML) // Convert HTML to plain text
//            Log.s("Decoded Notification Body: \(plainTextBody ?? "")")
//        }
//
//        if let plainTextBody = plainTextBody {
//            let newContent = UNMutableNotificationContent()
//            newContent.title = notification.request.content.title
//            newContent.body = plainTextBody
//            newContent.sound = .default
//            newContent.userInfo = userInfo.merging(["modified": true]) { _, new in new } // Mark as modified
//
//            // Create a new notification request with the modified content
//            let request = UNNotificationRequest(identifier: notification.request.identifier, content: newContent, trigger: nil)
//
//            // Add the modified notification to the system
//            center.add(request) { error in
//                if let error = error {
//                    Log.e("Failed to post modified notification: \(error)")
//                } else {
//                    Log.s("Modified notification posted successfully")
//                }
//            }
//
//            // Call completion handler but prevent infinite loop
//            completionHandler([])
//        } else {
//            // Fallback: Show the original notification if there's no modifiable body
//            completionHandler([.banner, .badge, .sound])
//        }
//    }
//
//
//
//    // ✅ Improved HTML Decoder
//    func decodeHTML(_ htmlString: String) -> String {
//        guard let data = htmlString.data(using: .utf8) else { return htmlString }
//
//        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
//            .documentType: NSAttributedString.DocumentType.html,
//            .characterEncoding: String.Encoding.utf8.rawValue
//        ]
//
//        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
//            return attributedString.string
//                .replacingOccurrences(of: "\u{00A0}", with: " ") // Unicode non-breaking space
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//        }
//
//        return htmlString
//            .replacingOccurrences(of: "&nbsp;", with: " ") // Manual fallback
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//
//
//
//
//    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
////        if let token: String = Messaging.messaging().fcmToken {
////            Log.s("Device FCM Token - - - - - - - - - - - - - - - >>")
////            Log.s(token)
////            Log.s("- - - - - - - - - - - - - >>>")
////            UserDefaultsManager.shared.setValue(token, forKey: .deviceToken)
////        }
////        Messaging.messaging().apnsToken = deviceToken
//    }
//
//    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {
////        Log.s("Fail to register for Notification >>> \(error)")
//    }
//
////    func userNotificationCenter(_: UNUserNotificationCenter,
////                                didReceive response: UNNotificationResponse,
////                                withCompletionHandler completionHandler: @escaping () -> Void) {
////        let userInfo = response.notification.request.content.userInfo
////        print(userInfo)
////        Log.s("Received Notification >>> \(response)")
////        if let messageID = userInfo[gcmMessageIDKey] {
////            Log.s("Message ID from userNotificationCenter didReceive: \(messageID)")
////        }
////        guard let _: String = userInfo["page"] as? String else { return }
////        completionHandler()
////    }
//
//    func userNotificationCenter(_: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        Log.s("Received Notification >>> \(response)")
//
//        if let messageID = userInfo[gcmMessageIDKey] as? String {
//            Log.s("Message ID from userNotificationCenter didReceive: \(messageID)")
//        }
//
//        if let aps = userInfo["aps"] as? [String: Any],
//           let alert = aps["alert"] as? [String: Any],
//           let bodyHTML = alert["body"] as? String {
//
//            let plainTextBody = decodeHTML(bodyHTML) // Convert HTML to plain text
//            Log.s("Decoded Notification Body: \(plainTextBody)")
//        }
//
//        completionHandler()
//    }
//
//
//
//}

//extension AppDelegate: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        UserDefaultsManager.shared.setValue(fcmToken, forKey: .deviceToken)
//    }
//}

//class MyPushSubscriptionObserver: NSObject, OSPushSubscriptionObserver {
//    func onPushSubscriptionDidChange(state: OneSignalUser.OSPushSubscriptionChangedState) {
//        Log.s("Push subscription state changed: \(state.current.jsonRepresentation())")
//        if state.current.optedIn {
//            if let id = state.current.id {
//                Log.s("FCM token: \(id)")
//                //                UserDefaultsManager.shared.setValue(id, forKey: .deviceToken)
//            }
//            // User is opted in for push notifications
//            // Update your UI or perform other actions here
//        } else {
//            // User is opted out of push notifications
//            // Update your UI or perform other actions here
//        }
//    }
//
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
//            return false
//        }
//
//        // Handle the URL that your app is opened with.
//        // For example, extract the authorization code from the URL and continue the OAuth flow.
//        if let code = url.queryParameters?["code"] {
//            print("Authorization code: \(code)")
//            // Continue the OAuth flow by exchanging the code for an access token.
//        }
//        return true
//    }
//}
