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

    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: TITLE (Top)
            Text(title)
                .font(.custom(poppinsSemiBold, size: 12))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.top, 8)

            Spacer(minLength: 0)  // <-- pushes content to center

            // MARK: IMAGE (Centered)
            URLImageView(url: imageURL)
                .frame(width: 90, height: 70)
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
        .frame(width: 110, height: 160, alignment: .top)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.32),
                radius: 10, x: 0, y: 3)
    }
}
