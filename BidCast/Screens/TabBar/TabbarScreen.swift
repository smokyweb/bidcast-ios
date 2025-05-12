//
//  TabbarScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI

struct TabbarScreen: View {
    var body: some View {
        TabView {
            HomeViewScreen()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ExploreViewScreen()
                .tabItem {
                    Label("Explore", systemImage: "safari.fill")
                }
            SellScreen()
                .tabItem {
                    Label("Sell", systemImage: "plus.circle.fill")
                }
            ActivityScreen()
                .tabItem {
                    Label("Activity", systemImage: "suit.heart.fill")
                          }
            AccountScreen()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
        }
        
    }
}

#Preview {
    TabbarScreen()
}
