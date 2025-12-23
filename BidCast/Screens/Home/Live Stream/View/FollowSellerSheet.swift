//
//  FollowSellerSheet.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//

import SwiftUI

struct FollowSellerSheet: View {
    
    // 🔵 CHANGED — replacing name + image string with full dynamic model
    var seller: SellerInfoResponse?
    
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
                        .font(.custom(poppinsBold, size: 18))
                        .foregroundColor(.gray)
                        .padding(10)
                }
            }
            .padding(.horizontal)
            
            // MARK: - Seller Image (dynamic)
            ZStack {
                if let thumb = seller?.seller_details?.thumbnail,
                   let url = URL(string: thumb) {

                    AsyncImage(url: url) { phase in
                        if let img = phase.image {
                            img.resizable()
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)   // ⭐ Blue border
                    )
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)  // ⭐ Soft shadow

                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.custom(poppinsBold, size: 28))
                                .foregroundColor(.gray)
                        )
                        .overlay(
                            Circle().stroke(Color.defaultTheme, lineWidth: 3)  // ⭐ Border for default image
                        )
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.top, -40)
            // MARK: - Title
            Text("Follow This Seller!")
                .font(.custom(poppinsSemiBold, size: 20))
                .foregroundColor(.black)
            
            (
                Text("Like what you see? Follow ")
                +
                Text(seller?.seller_details?.name ?? "this seller")
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                +
                Text(" to get notifications when they go live!")
            )
            .font(.custom(poppinsRegular, size: 15))
            .multilineTextAlignment(.center)
            .foregroundColor(.gray)
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)   // ⭐ Light text shadow

            
            // MARK: - Buttons
            HStack(spacing: 16) {
                
                // Not Now
                Button(action: onNotNow) {
                    Text("Not Now")
                        .font(.custom(poppinsMedium, size: 16))
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
                        .font(.custom(poppinsMedium, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.defaultTheme)
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

