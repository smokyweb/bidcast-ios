//
//  StackedImageView.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//
import SwiftUI

import SwiftUI

struct StackedImageView: View {
    var imageURL: String
    var stackCount: Int = 2
    var spacing: CGFloat = 8
    var totalCount: Int
    
    var productStackTapped: (() -> Void)?

    var defaultImage: Image = Image("defaultUser")

    private let mainSize: CGFloat = 50
    private let sizeReduction: CGFloat = 5  // Each layer is 8pt smaller

    var body: some View {
        ZStack(alignment: .center) {
            
            // MARK: - BACK LAYERS (smallest to largest)
            // Start from back (smallest) to front (largest)
            ForEach((0..<stackCount).reversed(), id: \.self) { index in
                
                // Calculate size: each layer is progressively smaller
                let layerSize = mainSize - (CGFloat(stackCount - index) * sizeReduction)
                
                // Calculate offset: negative to show top corner of previous layer
                let offsetY = -CGFloat(stackCount - index) * spacing
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(index % 2 == 0 ? Color.white : Color.black)
                    .frame(width: layerSize, height: layerSize)
                    .offset(y: offsetY)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(.black.opacity(0.2)), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    .zIndex(Double(index))
            }

            // MARK: - MAIN IMAGE (front layer)
            ZStack(alignment: .topTrailing) {
                
                Group {
                    if imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        defaultImage
                            .resizable()
                            .scaledToFill()
                    } else {
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            default:
                                defaultImage
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                }
                .frame(width: mainSize, height: mainSize)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.black.opacity(0.2)), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.20), radius: 6, x: 0, y: 4)
                
                // BADGE (floating outside top-right)
                Text("\(totalCount)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.defaultTheme)
                    .clipShape(Capsule())
                    .offset(x: 10, y: -10)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
            }
            .zIndex(Double(stackCount + 1))
        }
        .frame(
            width: mainSize + 20,  // Extra space for badge
            height: mainSize + (CGFloat(stackCount) * spacing)
        )
        .onTapGesture {
            productStackTapped?()
        }
    }
}
