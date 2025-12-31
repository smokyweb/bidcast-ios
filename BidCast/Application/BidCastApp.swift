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
    @StateObject var networkMonitor = NetworkMonitor.shared
    @State private var accountNavigationPath = NavigationPath()
    @StateObject var deepLink = DeepLinkManager()
//    @EnvironmentObject var deepLink: DeepLinkManager
    @StateObject var productManager = ProductManager()
    
    @StateObject private var tabBarRouter = TabBarRouter()
    
    @StateObject private var scheduleRequestStore = ScheduleRequestStore()
    
    @StateObject var staticAPI = StaticAPIViewModel()
    
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
//        UITabBar.appearance().unselectedItemTintColor = UIColor.black
        
        
        print("🚀 App starting")
        SocketManagerService.shared.setupSocket()
//        ZegoManager.shared.createEngine()
//        ZIMChatManager.shared.initialize(appID: 1005763407, appSign: "73678be720c3ea2d871376882d27d21d5c2bc891363547424458f9febc8bf423")
        
    }
    var body: some Scene {
        WindowGroup {
            Group{
                switch appRootManager.currentRoot {
                    
                case .splash:
                    NavigationContainer(navigationPath: $accountNavigationPath) {
                        SplashScreen()
                    }
                    .id(appRootManager.currentRoot.hashValue)
                    
                case .authentication:
                    NavigationContainer(navigationPath: $accountNavigationPath) {
                        AuthenticationStack()
                    }
                    .id(appRootManager.currentRoot.hashValue)
                case .tabBar:
                    NavigationContainer(navigationPath: $accountNavigationPath){
                        TabbarScreen()
                            .environmentObject(tabBarRouter)
                            .environmentObject(productManager)
                            .environmentObject(deepLink)
                    }
                    .id(appRootManager.currentRoot.hashValue)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .userSessionExpired)) { _ in
                UserDefaults.accessToken = ""
                UserDefaults.accessToken.removeAll()
                UserDefaults.sellerVerafied.removeAll()
                UserDefaults.buyerVerafied.removeAll()
                withAnimation(.snappy) {
                    appRootManager.currentRoot = .authentication
                }
            }
            .environmentObject(appRootManager)
            .environmentObject(LanguageManager.shared)
            .environmentObject(networkMonitor)
            .environmentObject(staticAPI)
            .environmentObject(scheduleRequestStore)
            .environmentObject(deepLink)
            .onOpenURL { url in
                deepLink.handle(url: url)
            }
        }
    }
}
