//
//  SellerProfileBottomView.swift
//  BidCast
//
//  Created by JamTech on 21/11/25.
//

import SwiftUI

struct SellerProfileBottomSheet: View {
    @Binding var isPresented: Bool
    
    var sellerInfo: SellerInfoResponse?        // ✅ Entire API response
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
                    CustomProfileImage(
                        url: sellerInfo?.seller_details?.thumbnail ?? "",
                        isCircular: true,
                        size: 55
                    )
                    
                    // Seller Name
                    Text(sellerInfo?.seller_details?.name ?? "Seller")
                        .font(.custom(poppinsBold, size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Follow Button
                    Button(action: onFollow) {
                        Text((sellerInfo?.is_following ?? false) ? "Following" : "Follow")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.defaultTheme.opacity(0.6))
                            .cornerRadius(22)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // MARK: - Stats Row
                HStack(spacing: 0) {
                    StatScreen(
                        icon: "star.fill",
                        value: String(format: "%.1f", sellerInfo?.rating_avg ?? 0.0),
                        label: "Rating"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: nil,
                        value: "\(sellerInfo?.review ?? "0")",
                        label: "Reviews"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: nil,
                        value: "\(sellerInfo?.sold_count ?? 0)",
                        label: "Sold"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: "clock",
                        value: sellerInfo?.avg_ship ?? "0",
                        label: "Avg Ship"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                
                // MARK: - Action Buttons
                VStack(spacing: 0) {
                    ActionButton(icon: "giftcard.fill", title: "Tip or Boost", action: onTipOrBoost)
                    ActionButton(icon: "person.circle", title: "View Profile", action: onViewProfile)
                    ActionButton(icon: "message", title: "Message", action: onMessage)
                    ActionButton(icon: "text.bubble", title: "Mention in Chat", action: onMentionInChat)
                    ActionButton(icon: "nosign", title: "Block", titleColor: .red, action: onBlock)
                    ActionButton(icon: "exclamationmark.triangle", title: "Report", titleColor: .red, action: onReport, showDivider: false)
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
