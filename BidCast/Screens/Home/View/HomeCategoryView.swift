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
    let isSelected: Bool
    let isScrolling: Bool
    
    // Updated initializer
    init(title: String, imageURL: String, backgroundColor: String, isSelected: Bool = false, isScrolling: Bool = false) {
        self.title = title
        self.imageURL = imageURL
        self.backgroundColor = backgroundColor
        self.isSelected = isSelected
        self.isScrolling = isScrolling
    }
    
    
    // Check if it's "For You" category
    private var isForYou: Bool {
        title.lowercased() == "for you"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            if isScrolling {
                // MARK: TITLE ONLY (When scrolling)
                Text(title)
                    .font(.custom(poppinsSemiBold, size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.horizontal, 8)
                
            } else {
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
                            .fill(Color.black.opacity(0.4))
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
        }
        .frame(width: 90, height: 120, alignment: .top)
        .background( isForYou ? Color.yellow.opacity(0.9) : Color.gray.opacity(0.3)
//            LinearGradient(
//                colors: [
//                    isForYou ? Color.gray.opacity(0.1) : Color.gray.opacity(0.1),
//                    isForYou ? Color.pink.opacity(0.3): Color(hex: backgroundColor) ?? .clear
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
        )
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isSelected ? Color.black : Color.clear, lineWidth: isSelected ? 2 : 0)
        )
        .padding(2) 
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 2)
        .scaleEffect(isSelected ? 1.05 : 1.0) // Add scale animation
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isScrolling)
    }
}

//struct HomeCategoryCardView: View {
//    let title: String
//    let imageURL: String
//    let backgroundColor: String
//    let isSelected: Bool
//    let isScrolling: Bool
//    
//    // Updated initializer
//    init(title: String, imageURL: String, backgroundColor: String, isSelected: Bool = false, isScrolling: Bool = false) {
//        self.title = title
//        self.imageURL = imageURL
//        self.backgroundColor = backgroundColor
//        self.isSelected = isSelected
//        self.isScrolling = isScrolling
//    }
//    
//    // Check if it's "For You" category
//    private var isForYou: Bool {
//        title.lowercased() == "for you"
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            
//            if isScrolling {
//                // MARK: TITLE ONLY (When scrolling LiveAuctionView) - Reduced size
//                Text(title)
//                    .font(.custom(poppinsSemiBold, size: 10))
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.center)
//                    .lineLimit(1)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                    .padding(.horizontal, 6)
//                
//            } else {
//                // MARK: TITLE (Top)
//                Text(title)
//                    .font(.custom(poppinsSemiBold, size: 12))
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.center)
//                    .lineLimit(2)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding(.horizontal, 8)
//                    .padding(.top, 8)
//
//                Spacer(minLength: 0)
//
//                // MARK: IMAGE (Bottom - Fixed position)
//                if isForYou {
//                    // Show profile icon for "For You"
//                    ZStack {
//                        Circle()
//                            .fill(Color.pink.opacity(0.4))
//                            .frame(width: 65, height: 65)
//                        
//                        Image(systemName: "person.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 35, height: 35)
//                            .foregroundColor(.black)
//                    }
//                    .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 4)
//                    .padding(.bottom, 12)
//                } else {
//                    // Show image from URL for other categories
//                    URLImageView(url: imageURL)
//                        .frame(width: 60, height: 60, alignment: .center)
//                        .clipped()
//                        .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 4)
//                        .padding(.bottom, 12)
//                        .padding(.horizontal, 12)
//                }
//            }
//        }
//        .frame(
//            width: isScrolling ? 70 : 90,      // Reduced width when scrolling
//            height: isScrolling ? 40 : 120,    // Reduced height when scrolling
//            alignment: .center
//        )
//        .background(
//            LinearGradient(
//                colors: [
//                    isForYou ? Color.gray.opacity(0.1) : Color.gray.opacity(0.1),
//                    isForYou ? Color.pink.opacity(0.3): Color(hex: backgroundColor) ?? .clear
//                ],
//                startPoint: .top,
//                endPoint: .bottom
//            )
//        )
//        .cornerRadius(isScrolling ? 8 : 14)    // Smaller corner radius when scrolling
//        .overlay(
//            RoundedRectangle(cornerRadius: isScrolling ? 8 : 14)
//                .strokeBorder(isSelected ? Color.black : Color.clear, lineWidth: isSelected ? 2 : 0)
//        )
//        .padding(1)
////        .shadow(color: Color.black.opacity(isScrolling ? 0.15 : 0.32), radius: isScrolling ? 5 : 10, x: 0, y: isScrolling ? 2 : 3)
//        shadow(color: Color.black.opacity(0.15) , radius: isScrolling ? 5 : 10, x: 0, y: 2)
//        .scaleEffect(isSelected ? 1.05 : 1.0)
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
//        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isScrolling)
//    }
//}
