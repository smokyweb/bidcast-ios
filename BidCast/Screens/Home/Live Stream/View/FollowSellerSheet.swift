//
//  FollowSellerSheet.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//

import SwiftUI

struct FollowSellerSheet: View {
    
    var sellerName: String
    var sellerImageURL: String?
    
    var onFollow: () -> Void
    var onNotNow: () -> Void
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            
            // MARK: - Close Button
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(10)
                }
            }
            .padding(.horizontal)
            
            // MARK: - Seller Icon
            ZStack {
                if let url = sellerImageURL, let imageURL = URL(string: url) {
                    AsyncImage(url: imageURL) { phase in
                        if let img = phase.image {
                            img.resizable()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                        )
                }
            }
            .padding(.top, -40)
            
            // MARK: - Title
            Text("Follow This Seller!")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
            
            // MARK: - Description
            Text("Like what you see? Follow \(sellerName) to get notifications when they go live!")
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            
            // MARK: - Buttons
            HStack(spacing: 16) {
                
                // Not Now
                Button(action: onNotNow) {
                    Text("Not Now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 1)
                }
                
                // Follow Seller
                Button(action: onFollow) {
                    Text("Follow Seller")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 10)
        }
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
        )
    }
}
