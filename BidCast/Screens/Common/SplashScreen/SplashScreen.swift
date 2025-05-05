//
//  SplashScreen.swift
//  imperium
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
            if let userData: UserDetailModal = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                withAnimation(.snappy) {
                    if userData.role_id == "2" {
                        if userData.is_student ?? "" == "" {
                            navigatetoUser = true
                        } else {
                            DispatchQueue.main.async {
                                appRootManager.currentRoot = .user
                            }
                        }
                    } else if userData.role_id == "3" {
                        if userData.emp_company_created ?? false == false {
                            navigateToEmployer = true
                        } else {
                            DispatchQueue.main.async {
                                appRootManager.currentRoot = .employer
                            }
                        }
                    }else if userData.role_id == "4" {
                        
                        DispatchQueue.main.async {
                            appRootManager.currentRoot = .employer
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
            Image(.fullBackground)
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth, height: screenHeight)
                .ignoresSafeArea(.all)
                .overlay(alignment: .center, content: {
                    Image(.appName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                })
            
            
            CusNavLink(doNavigate: $navigatetoUser, destination: UserHomeScreen())
            
            CusNavLink(doNavigate: $navigateToEmployer, destination: EmployerHomeScreen())
            
        }.onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                handleUserLogin()
            })
        })
    }
}

#Preview {
    SplashScreen()
}
