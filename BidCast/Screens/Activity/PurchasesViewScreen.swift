//
//  PurchasesView.swift
//  BidCast
//
//  Created by JamTech on 18/11/25.
//

import SwiftUI

struct PurchasesView: View {
    
    @State var searchText: String = ""
    
    var filterArray: [String] = ["All", "In Progress", "Completed", "Refunds", "Cancelled"]
    
    @State var navigateToNoti : Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                
                HeaderMenuIconView(
                    didTapMenuButton: {
                        navigateToNoti = true
                    },
                    count: .constant(4)
                )
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
}

#Preview {
    PurchasesView()
}
