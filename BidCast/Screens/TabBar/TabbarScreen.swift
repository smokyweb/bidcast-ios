//
//  TabbarScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//@ObservedObject var languageManager = LanguageManager.shared

import SwiftUI

struct TabbarScreen: View {
    @State private var selectedTab = 0
    @State private var showSellSheet = false
    @State private var selectedSellTab: SellTabOption? = nil
    @State private var navigateToLesson = false
    @State private var navigateTolist = false
    @State private var navigateToseller = false
    @ObservedObject var languageManager = LanguageManager.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationContainer { HomeViewScreen() }
                    .tabItem { Label("Home", systemImage: "house") }

                NavigationContainer { ExploreViewScreen() }
                    .tabItem { Label("Explore", systemImage: "safari.fill") }

                Color.clear
                    .tabItem {
                        Label("Sell",
                        systemImage: "plus.circle.fill")
                    }
                    .tag(2)
    

                NavigationContainer { ActivityScreen() }
                    .tabItem { Label("Activity", systemImage: "suit.heart.fill") }

                NavigationContainer { AccountScreen() }
                    .tabItem { Label("Account", systemImage: "person.fill") }
            }
            .onChange(of: selectedTab) { newTab in
                if newTab == 2 {
                    
                    showSellSheet = true
                    selectedTab = 0
                }
            }
           
            CusNavLink(doNavigate: $navigateToLesson, destination: CombinedLessonTipsView())
//            CusNavLink(doNavigate: $navigateToLesson, destination: SelectShowScreen())
            CusNavLink(doNavigate: $navigateTolist, destination: ListProductScreen())
            
        }
        .bottomSheet(
                    isPresented: $showSellSheet,
                    height: screenHeight / 2.6,
                    topBarCornerRadius: 12,
                    contentBackgroundColor: .clear,
                    topBarBackgroundColor: .clear,
                    showTopIndicator: false,
                    onDismiss: {
                        showSellSheet = false
                        
                    },
                    content: {
                        SellScreen { tappedTab in
                            if tappedTab == .lesson {
                                navigateToLesson = true
                            } else if tappedTab == .listProduct {
                                navigateTolist = true
                            }
                        } onTapCancel: {
                            showSellSheet = false
                           
                        }
                        .presentationDetents([.fraction(0.35)])
                    }
                )
        
    }
}
