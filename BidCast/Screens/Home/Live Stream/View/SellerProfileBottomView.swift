//
//  SellerProfileBottomView.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//

import SwiftUI

struct SellerProfileBottomSheet: View {
    @Binding var isPresented: Bool
    
    var sellerName: String
    var sellerImage: String
    var rating: Double
    var reviewCount: String
    var soldCount: String
    var avgShipTime: String
    var isFollowing: Bool
    
    var onTipOrBoost: () -> Void
    var onViewProfile: () -> Void
    var onMessage: () -> Void
    var onMentionInChat: () -> Void
    var onBlock: () -> Void
    var onReport: () -> Void
    var onFollow: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Handle Bar
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                // MARK: - Header
                HStack(spacing: 16) {
                    // Profile Image
                    CustomProfileImage(url: sellerImage, isCircular: true, size: 55)
                    
                    // Seller Name
                    Text(sellerName)
                        .font(.custom(poppinsBold, size: 14))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Follow Button
                    Button(action: onFollow) {
                        Text(isFollowing ? "Following" : "Follow")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(isFollowing ? Color.gray.opacity(0.2) : Color.yellow)
                            .cornerRadius(22)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // MARK: - Stats Row
                HStack(spacing: 0) {
                    StatScreen(icon: "star.fill", value: String(format: "%.1f", rating), label: "Rating")
                    
                    Divider()
                        .frame(height: 40)
                        .padding(.horizontal, 8)
                    
                    StatScreen(icon: nil, value: reviewCount, label: "Reviews")
                    
                    Divider()
                        .frame(height: 40)
                        .padding(.horizontal, 8)
                    
                    StatScreen(icon: nil, value: soldCount, label: "Sold")
                    
                    Divider()
                        .frame(height: 40)
                        .padding(.horizontal, 8)
                    
                    StatScreen(icon: "shippingbox", value: avgShipTime, label: "Avg Ship")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                // MARK: - Action Buttons
                VStack(spacing: 0) {
                    ActionButton(
                        icon: "giftcard.fill",
                        title: "Tip or Boost",
                        action: onTipOrBoost
                    )
                    
                    ActionButton(
                        icon: "person.circle",
                        title: "View Profile",
                        action: onViewProfile
                    )
                    
                    ActionButton(
                        icon: "message",
                        title: "Message",
                        action: onMessage
                    )
                    
                    ActionButton(
                        icon: "text.bubble",
                        title: "Mention in Chat",
                        action: onMentionInChat
                    )
                    
                    ActionButton(
                        icon: "nosign",
                        title: "Block",
                        titleColor: .red,
                        action: onBlock
                    )
                    
                    ActionButton(
                        icon: "exclamationmark.triangle",
                        title: "Report",
                        titleColor: .red,
                        action: onReport,
                        showDivider: false
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Stat View Component

struct StatScreen: View {
    var icon: String?
    var value: String
    var label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
//                        .foregroundColor(icon == "star.fill" ? .yellow : .primary)
                    .foregroundColor(.primary)                }
                Text(value)
                    .font(.custom(poppinsBold, size: 18))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Action Button Component

struct ActionButton: View {
    var icon: String
    var title: String
    var titleColor: Color = .primary
    var action: () -> Void
    var showDivider: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Button(action: action) {
                HStack(spacing: 16) {
                    
                    // Icon Circle
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(titleColor)
                    }
                    
                    // Title
                    Text(title)
                        .font(.custom(poppinsMedium, size: 16))
                        .foregroundColor(titleColor)

                }
                .frame(maxWidth: .infinity, alignment: .leading) // ⬅ FIX
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}


// MARK: - Preview

struct SellerProfileBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        SellerProfileBottomSheet(
            isPresented: .constant(true),
            sellerName: "badbunnygolfshop",
            sellerImage: "https://via.placeholder.com/150",
            rating: 5.0,
            reviewCount: "1.8K",
            soldCount: "5.5K",
            avgShipTime: "2d",
            isFollowing: false,
            onTipOrBoost: { print("Tip or Boost") },
            onViewProfile: { print("View Profile") },
            onMessage: { print("Message") },
            onMentionInChat: { print("Mention in Chat") },
            onBlock: { print("Block") },
            onReport: { print("Report") },
            onFollow: { print("Follow") }
        )
    }
}
