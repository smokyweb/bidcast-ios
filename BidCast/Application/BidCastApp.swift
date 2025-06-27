//
//  BidCastApp.swift
//  BidCast
//
//  Created by Abdul-JAM-E-157 on 02/05/25.
//

import SwiftUI

@main
struct BidCastApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appRootManager = AppRootManager()
//    @State var ZIMChatManager = ZIMChatManager()
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor = UIColor.gray
        
        // Set the appearance globally
        UITabBar.appearance().standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        UITabBar.appearance().unselectedItemTintColor = UIColor.mediumDarkGray
        
        
        print("🚀 App starting")
        ZegoManager.shared.createEngine()
        ZIMChatManager.shared.initialize(appID: 1005763407, appSign: "73678be720c3ea2d871376882d27d21d5c2bc891363547424458f9febc8bf423")
        
    }
    var body: some Scene {
        WindowGroup {
            Group{
                switch appRootManager.currentRoot {
                    
                case .splash:
                    NavigationContainer {
                        SplashScreen()
                    }
                    
                case .authentication:
                    NavigationContainer {
                        AuthenticationStack()
                    }
                    
                case .tabBar:
                    NavigationContainer{
                        TabbarScreen()
                    }
                }
                
            }
            .environmentObject(appRootManager)
            .environmentObject(LanguageManager.shared)
            //            .environmentObject(manager)
        }
    }
}
