//
//  NavigationPath.swift
//  imperium
//
//  Created by JAM-E-282 on 19/01/24.
//

import Foundation

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: eAppRoots = .splash
    
    enum eAppRoots {
        case splash
        case authentication
        case subscription
        case user
        case employer
        case welcome
    }
}
