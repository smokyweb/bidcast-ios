//
//  StackedImageView.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//

import SwiftUI

struct StackedImageView: View {
    var image: Image
    var stackCount: Int = 3           // number of “stacked” layers
    var spacing: CGFloat = 6          // vertical offset between layers
    
    var body: some View {
        ZStack {
            // BACK STACKED IMAGES
            ForEach(0..<stackCount, id: \.self) { index in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 180)
                    .clipped()
                    .cornerRadius(20)
                    .opacity(0.3 - Double(index) * 0.05)   // fade effect
                    .offset(y: CGFloat((stackCount - index) * spacing))
                    .scaleEffect(1 - (CGFloat(index) * 0.03))
            }

            // FRONT IMAGE
            image
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 180)
                .clipped()
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
    }
}
