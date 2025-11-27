//
//  OrderTrackingView.swift
//  BidCast
//
//  Created by JamTech on 27/11/25.
//

import SwiftUI

struct OrderTrackingView: View {
    @State private var progress: CGFloat = 0
    @State private var showCopied = false
    @State private var bounceAnimation = false
 
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Main Status Card
                        mainStatusCard
                        
                        // Product Image Card
                        productImageCard
                        
                        // Order Details Card
                        orderDetailsCard
                        
                        // Buyer Protections Card
                        buyerProtectionsCard
                        
                        // Seller Info Card
                        sellerInfoCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 12) {
                        // Back Button
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .font(.custom("Poppins-Medium", size: 16))
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                        }
                        
                        Spacer()
                        
                        // Title
                        Text("🎀Single🎀 #212")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }

        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                progress = 0.25
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever()) {
                bounceAnimation.toggle()
            }
        }
    }
    
    // MARK: - Main Status Card
    var mainStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preparing Package")
                .font(.custom("Poppins-Bold", size: 24))
            
            Text("Typically ships in 1 day")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(.primary)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("The seller is preparing your package to ship. They typically ship in 1 day. Once the package is scanned, you'll receive tracking updates to follow its journey to you.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            Button(action: {}) {
                HStack {
                    Text("Bundled with 5 other items")
                        .font(.custom("Poppins-SemiBold", size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.blue)
            }
            
            Text("Order placed Nov 25, 2025 at 10:10PM")
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.secondary)
            
            // Action Buttons
            VStack(spacing: 12) {
                ActionButtonView(
                    icon: "mappin",
                    title: "Shipping to",
                    subtitle: "Jay Yorty\n547 Bridgeside Dr\nAvon Lake OH 44012-2767"
                )
                
                ActionButtonView(
                    icon: "message",
                    title: "Message the seller"
                )
                
                ActionButtonView(
                    icon: "questionmark.circle",
                    title: "Get help with this purchase",
                    subtitle: "Eligible for a refund within 7 days of delivery."
                )
                
                ActionButtonView(
                    icon: "gift",
                    title: "Refer a buyer, earn $5!",
                    subtitle: "Get credit towards your next purchase",
                    isHighlighted: true
                )
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        .transition(.opacity.combined(with: .offset(y: 10)))
    }
    
    // MARK: - Product Image Card
    var productImageCard: some View {
        VStack {
            Text("🎀")
                .font(.system(size: 70))
                .offset(y: bounceAnimation ? -10 : 0)
            
            Text("😊")
                .font(.system(size: 60))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            LinearGradient(
                colors: [Color.pink.opacity(0.3), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Order Details Card
    var orderDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎀Single🎀 #212")
                .font(.custom("Poppins-Bold", size: 20))
            
            Text("Near Mint")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.secondary)
            
            Button(action: {}) {
                HStack {
                    Text("View Product Details")
                        .font(.custom("Poppins-SemiBold", size: 14))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.blue)
            }
            
            Text("Order Details")
                .font(.custom("Poppins-Bold", size: 18))
                .padding(.top, 8)
            
            VStack(spacing: 0) {
                DetailRowView(label: "Order ID", value: "663690536", isCopyable: true, showCopied: $showCopied)
                DetailRowView(label: "Order Date", value: "Nov 25, 2025")
                DetailRowView(label: "Sold By", value: "wyynaut", isLink: true)
                DetailRowView(label: "Qty", value: "1")
                DetailRowView(label: "Category", value: "Pokémon Cards", isLink: true)
            }
            
            VStack(spacing: 12) {
                CompactActionButton(icon: "doc.text", title: "Receipt & shipping details")
                CompactActionButton(icon: "play.fill", title: "Video Receipt", subtitle: "Video receipt available for 60 more days")
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Buyer Protections Card
    var buyerProtectionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buyer Protections")
                .font(.custom("Poppins-Bold", size: 18))
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Whatnot Buyer Guarantee")
                        .font(.custom("Poppins-SemiBold", size: 14))
                    
                    Text("Receive your purchase on time and as described or we'll make it right.")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Seller Info Card
    var sellerInfoCard: some View {
        VStack(spacing: 16) {
            Text("About the Seller")
                .font(.custom("Poppins-Bold", size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack(alignment: .bottom) {
                // Cover Image
                LinearGradient(
                    colors: [Color.yellow, Color.orange, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)
                .cornerRadius(20)
                .overlay(
                    Text("😎")
                        .font(.system(size: 60))
                )
                
                // Profile Avatar
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text("🎀")
                            .font(.system(size: 40))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                    .offset(y: 40)
            }
            
            VStack(spacing: 16) {
                Text("wyynaut")
                    .font(.custom("Poppins-Bold", size: 20))
                    .padding(.top, 40)
                
                // MARK: - Stats Row
                HStack(spacing: 0) {
                    StatScreen(
                        icon: "star.fill",
//                        value: String(format: "%.1f", sellerInfo?.rating_avg ?? 0.0),
                        value: String(format: "%.1f", 0.0),
                        label: "Rating"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: nil,
//                        value: "\(sellerInfo?.review ?? "0")",
                        value: String("3.4K"),
                        label: "Sold"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: "clock",
//                        value: sellerInfo?.avg_ship ?? "0",
                        value: "1d",
                        label: "Avg Ship"
                    )
                }
                .padding(16)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text("I'm just a girl 🎀")
                    Text("Struggles to open packs but we have fun.")
                    Text("Ig: wyynaut.streams")
                    Text("Ig: ThePokeFisher ←— For Consignments")
                }
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: {}) {
                    Text("View Profile")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Action Button Component
struct ActionButtonView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var isHighlighted: Bool = false
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isHighlighted ? Color.yellow : Color.gray.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.primary)
                }
                .scaleEffect(isPressed ? 1.1 : 1.0)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(isHighlighted ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Detail Row Component
struct DetailRowView: View {
    let label: String
    let value: String
    var isLink: Bool = false
    var isCopyable: Bool = false
    @Binding var showCopied: Bool
    
    init(label: String, value: String, isLink: Bool = false, isCopyable: Bool = false, showCopied: Binding<Bool> = .constant(false)) {
        self.label = label
        self.value = value
        self.isLink = isLink
        self.isCopyable = isCopyable
        self._showCopied = showCopied
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text(value)
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(isLink ? .blue : .primary)
                
                if isCopyable {
                    Button(action: {
                        UIPasteboard.general.string = value
                        showCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopied = false
                        }
                    }) {
                        ZStack {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.blue)
                            
                            if showCopied {
                                Text("Copied!")
                                    .font(.custom("Poppins-Medium", size: 10))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.8))
                                    .cornerRadius(6)
                                    .offset(y: -30)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Compact Action Button
struct CompactActionButton: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct OrderTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        OrderTrackingView()
    }
}
