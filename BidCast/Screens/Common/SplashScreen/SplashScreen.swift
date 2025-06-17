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
        if let _: Bool = UserDefaultsManager.shared.value(forKey: .isLoggedIn) {
//            if let userData: LoginModel = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                withAnimation(.snappy) {
//                    if userData.role_id == 2 {
                        DispatchQueue.main.async {
                            appRootManager.currentRoot = .tabBar
                        }
//                    }else{
//                        DispatchQueue.main.async {
//                            appRootManager.currentRoot = .authentication
//                        }
//                    }
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
        .onFirstAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                  
                   guard appRootManager.currentRoot == .splash else {
                       print("🚫 Splash exited early")
                       return
                   }
                   handleUserLogin()
               }
        }

    }
}

#Preview {
    SplashScreen()
}

