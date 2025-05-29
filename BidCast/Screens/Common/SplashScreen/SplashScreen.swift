//
//  SplashScreen.swift
// BidSwipe
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI

struct SplashScreen: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @State var navigateToEmployer: Bool = false
    @State var navigatetoUser: Bool = false

    func handleUserLogin() {
        if let _: Bool = UserDefaultsManager.shared.value(forKey: .isLoggedIn) {
            if let userData: LoginModel = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                withAnimation(.snappy) {
                    if userData.role_id == 2 {
                        DispatchQueue.main.async {
                            appRootManager.currentRoot = .tabBar
                        }
                    }else{
                        DispatchQueue.main.async {
                            appRootManager.currentRoot = .authentication
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    appRootManager.currentRoot = .authentication
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
//                .padding(.top,-screenHeight/3.5)
                .padding(.leading,-20)
                .ignoresSafeArea(.all)
//                .overlay(alignment: .center, content: {
//                    Image(.mainLogo)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 200)
//                })
            
            
//            CusNavLink(doNavigate: $navigatetoUser, destination: UserHomeScreen())
            
//            CusNavLink(doNavigate: $navigateToEmployer, destination: EmployerHomeScreen())
        }.onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                handleUserLogin()
            })
        })
    }
}

#Preview {
    SplashScreen()
}

