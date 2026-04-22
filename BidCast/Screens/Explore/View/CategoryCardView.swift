//
//  CateegoryCardView.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI

let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
]

struct CategoryCardView: View {
    let title: String
    let imageURL: String
    let liveCount: Int
    let isSelected: Bool
    let isScrolling: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: TITLE (Top)
            Text(title)
                .font(.custom(poppinsSemiBold, size: 12))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 34, alignment: .top)
                .padding(.horizontal, 8)
                .padding(.top, 8)

            Spacer(minLength: 0)  // <-- pushes content to center

            // MARK: IMAGE (Centered)
            URLImageView(url: imageURL)
                .frame(width: 90, height: 90)
                .clipped()
                .shadow(color: Color.black.opacity(0.28),
                        radius: 8, x: 0, y: 4)

            Spacer(minLength: 0)  // <-- pushes content to center

            // MARK: LIVE COUNT (Bottom)
            HStack(spacing: 6) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .foregroundColor(.red)
                    .font(.system(size: 12, weight: .bold))

                Text("\(liveCount) Live")
                    .font(.custom(poppinsSemiBold, size: 11))
                    .foregroundColor(.black.opacity(0.8))

                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 110, height: 170, alignment: .top)
//        .background(Color.white)
//        .cornerRadius(14)
//        .shadow(color: Color.black.opacity(0.32),
//                radius: 10, x: 0, y: 3)
        
        .background(
            LinearGradient(
                colors: [
                    isSelected ? Color.yellow.opacity(0.4) : Color.white,
                    isSelected ? Color.darkYellow.opacity(1.0): Color.white,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(14)
//        .padding(2)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .scaleEffect(isSelected ? 1.05 : 1.0) // Add scale animation
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isScrolling)
    }
}
