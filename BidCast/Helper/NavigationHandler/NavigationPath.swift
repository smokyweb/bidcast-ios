//
//  NavigationPath.swift
// BidSwipe
//
//  Created by JAM-E-282 on 19/01/24.
//

import Foundation

class AppRootManager: ObservableObject {
    
    static var shared: AppRootManager?
    @Published var currentRoot: eAppRoots

        init() {
            if !UserDefaults.accessToken.isEmpty {
                currentRoot = .tabBar
            } else {
                currentRoot = .authentication
            }
        }
    
    enum eAppRoots {
        case splash
        case authentication
        case tabBar
    }
}


