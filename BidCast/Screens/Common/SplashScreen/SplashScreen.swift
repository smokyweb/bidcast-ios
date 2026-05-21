//
//  SplashScreen.swift
// BidSwipe
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI

struct SplashScreen: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager

    func handleUserLogin() {
        // MC cmpewtofs000msahgns50t4yk (2026-05-21): switched .snappy to a
        // softer easeInOut so the launch->first-screen handoff no longer
        // "snaps" when this view is ever shown (it is currently dead code
        // because AppRootManager.init() bypasses .splash, but keep the
        // animation gentle for safety).
        if !UserDefaults.accessToken.isEmpty {
            withAnimation(.easeInOut(duration: 0.25)) {
                DispatchQueue.main.async {
                    appRootManager.currentRoot = .tabBar
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                DispatchQueue.main.async {
                    appRootManager.currentRoot = .authentication
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Image(.mainLogo)
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth, height: screenHeight)
                .padding(.leading,-20)
                .ignoresSafeArea(.all)
        }
        .onAppear(perform: {
            // MC cmpewtofs000msahgns50t4yk (2026-05-21): the previous 3s
            // delay made the launch transition feel sluggish. Shortened to
            // 0.5s so if/when this view is shown (deep-link warm-start,
            // future flow) it dismisses quickly instead of holding the
            // user on a static logo for 3 full seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                handleUserLogin()
            })
        })

    }
}

#Preview {
    SplashScreen()
}


