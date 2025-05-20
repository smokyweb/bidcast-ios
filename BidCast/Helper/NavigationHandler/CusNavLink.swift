//
//  CusNavLink.swift
// BidSwipe
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI

struct CusNavLink<Content: View>: View {
    
    @Binding var doNavigate: Bool
    @State var destination: Content
    @State var navTitle: String = ""
    
    var body: some View {
        NavigationLink(
            navTitle,
            destination:
                destination
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true),
            isActive: $doNavigate)
        .opacity(0)
    }
}


