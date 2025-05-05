//
//  UserFlowStack.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI

struct UserFlowStack: View {
    var body: some View {
        NavigationContainer {
            UserHomeScreen(isWelcomePage: true)
        }
    }
}

#Preview {
    UserFlowStack()
}
