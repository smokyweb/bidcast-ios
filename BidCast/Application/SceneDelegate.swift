//
//  SceneDelegate.swift


import Foundation
import SwiftUI
import ZegoExpressEngine


class SceneDelegate: NSObject, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var currentUserActivity: NSUserActivity?

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "myapp" && url.host == "google-calendar" && url.path == "/callback-process" {
            // Handle the redirection here
            // Extract and process the authorization code from the URL
            return true
        }
        return false
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            print("Hello")
        }
        

        

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let userActivity = connectionOptions.userActivities.first {
            debugPrint("got user activity")
            currentUserActivity = userActivity
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        ZegoExpressEngine.destroy(nil)
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    
    func sceneWillResignActive(_ scene: UIScene) {
//        Log.w("Scene Will Resign Active")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {

    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
//        Log.w("Scene Did Enter Background")
    }
    

    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
            return false
        }
        
        return true
    }
}

