//
//  TabbarScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI

struct TabbarScreen: View {
    
    @ObservedObject var languageManager = LanguageManager.shared

    var body: some View {
        TabView {
            NavigationContainer {
                   HomeViewScreen()
               }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationContainer {
                   ExploreViewScreen()
               }
               .tabItem {
                   Label("Explore", systemImage: "safari.fill")
               }

            NavigationContainer {
                   SellScreen()
               }
               .tabItem {
                   Label("Sell", systemImage: "plus.circle.fill")
               }

            NavigationContainer { 
                   ActivityScreen()
               }
               .tabItem {
                   Label("Activity", systemImage: "suit.heart.fill")
               }

            NavigationContainer {
                   AccountScreen()
               }
               .tabItem {
                   Label("Account", systemImage: "person.fill")
               }
        }
//        .id(languageManager.languageChanged)
        .accentColor(.tabBar)
    }
}

#Preview {
    TabbarScreen()
}
