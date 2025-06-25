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
        
//      ZegoManager.shared.createEngine()
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setForegroundColor(.primary)
        SVProgressHUD.setBackgroundColor(.black)
        SVProgressHUD.setBackgroundLayerColor(.black.withAlphaComponent(0.8))
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistance = 10
        IQKeyboardManager.shared.enableAutoToolbar = true
        STPAPIClient.shared.publishableKey = "pk_test_51RQLxjQEbmPLLc7GaDeFTplB9lwTK5t9ZvpHVd1CtK4XtWsmktQvN3hoZW0ZZ0kSu0PFJ6R63D9X3PSMAq8tg5Sh00Vzh05MeU"
        FirebaseApp.configure()
        
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
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}
