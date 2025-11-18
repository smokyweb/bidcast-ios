//
//  HeaderMenuIconView.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI

struct HeaderMenuIconView: View {
    var didTapMenuButton : (() -> (Void)) = { }
    @Binding var count: Int
    var body: some View {
        Button(action: {
            print("button tapped")
            didTapMenuButton()
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.custom(poppinsBold, size: 18.0))
                    .foregroundColor(.black)
                    .frame(width: 32, height: 32)  // Square frame
//                    .background(Color.black)
                    .clipShape(Circle())           // Makes it circular
                
                if count > 0 {
                    Circle()
                        .fill(Color.defaultTheme)
                        .frame(width: 8, height: 8)
                        .offset(x: -2, y: -2)
                }
            }
            
        }
    }
}
