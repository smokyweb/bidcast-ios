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
       }
    var body: some Scene {
        WindowGroup {
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
