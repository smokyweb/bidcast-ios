//
//  HomeCategoryViw.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI

let rows = [
    GridItem(.fixed(140))   // row height
]

struct HomeCategoryCardView: View {
    let title: String
    let imageURL: String
    let backgroundColor: String
    
    // Default initializer
    init(title: String, imageURL: String, backgroundColor: String) {
        self.title = title
        self.imageURL = imageURL
        self.backgroundColor = backgroundColor
    }
    
    // Check if it's "For You" category
    private var isForYou: Bool {
        title.lowercased() == "for you"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: TITLE (Top)
            Text(title)
                .font(.custom(poppinsSemiBold, size: 12))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 8)
                .padding(.top, 8)

            Spacer(minLength: 0)

            // MARK: IMAGE (Bottom - Fixed position)
            if isForYou {
                // Show profile icon for "For You"
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 65, height: 65)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 35, height: 35)
                        .foregroundColor(.black)
                }
                .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 4)
                .padding(.bottom, 12)
            } else {
                // Show image from URL for other categories
                URLImageView(url: imageURL)
                    .frame(width: 60, height: 60, alignment: .center)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 4)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 12)
            }
        }
        .frame(width: 90, height: 120, alignment: .top)
        .background(
            LinearGradient(
                colors: [
                    Color.gray.opacity(0.15),
//                    backgroundColor.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isForYou ? Color.black : Color.clear, lineWidth: isForYou ? 3 : 0)
        )
        .shadow(color: Color.black.opacity(0.32), radius: 10, x: 0, y: 3)
    }
}
