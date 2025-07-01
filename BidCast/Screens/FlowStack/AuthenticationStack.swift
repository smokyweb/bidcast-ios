//
//  AuthenticationStack.swift
// BidSwipe
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI

struct AuthenticationStack: View {
    @State private var accountNavigationPath = NavigationPath()
    var body: some View {
        NavigationContainer(navigationPath: $accountNavigationPath) {
            LoginScreen()
        }
    }
}

#Preview {
    AuthenticationStack()
}
