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
        if !UserDefaults.accessToken.isEmpty {
                withAnimation(.snappy) {
                        DispatchQueue.main.async {
                            appRootManager.currentRoot = .tabBar
                        }
                }
           
        } else {
            DispatchQueue.main.async {
                appRootManager.currentRoot = .authentication
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                handleUserLogin()
            })
        })

    }
}

#Preview {
    SplashScreen()
}

