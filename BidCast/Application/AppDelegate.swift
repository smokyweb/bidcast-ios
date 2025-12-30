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
import ZegoExpressEngine
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
        self.redirectNotification(with: userInfo) // ✅ Pass directly
        completionHandler()
    }
}

//MARK: AppDelegate.
extension AppDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        print("Did Receive User Info: \(userInfo)")

        guard let type = userInfo["type"] as? String else { return }

        switch type {
        case "message":
            let senderID = userInfo["sender_id"] as? String ?? ""
            let senderName = userInfo["sender_name"] as? String ?? ""
            let senderImage = userInfo["sender_image"] as? String ?? ""
            let body = userInfo["body"] as? String ?? ""

            if type == "message" {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("NavToActivityScreen"), object: nil)
                }
            }

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

