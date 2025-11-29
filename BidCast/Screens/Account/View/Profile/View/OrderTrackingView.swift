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
    @State private var showProductDetails = false

    
    var orderId: String?
    var productId: Int?
 
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel =  ListProductViewModel()
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    @State private var showError: Bool = false
    @State private var orderResponse: OrderDetailsModel?
    
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
                        Text(orderResponse?.order?.product?.title?.capitalizingFirstLetter() ?? "🎀Single🎀 #212")
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
            
            //API Call
            Task {
                await getOrderDetails()
            }
        }
    }
    
    
    private func getOrderDetails() async {
        guard let ordId = orderId, let prodId = productId else { return }
        
        await performAPICalls(
            isConcurrent: false,
            showLoader: true,
            onError: { error in
                config = BottomSheetConfig(
                    icon: "exclamationmark.triangle.fill",
                    title: "Error",
                    message: errorDesc(error: error, message: viewModel.errorMessage),
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil
                )
                showError = true
            },
            onSuccess: {
                let response = viewModel.OrderDetailsResponse
                orderResponse = response?.data
            }
        ) {
            let orderRequest = OrderDetailsParam(product_id: "\(prodId)", order_id: "\(ordId)")
            try await viewModel.getOrderDetails(request: orderRequest)
        }
    }
    
    func encodedOrderID(_ orderId: String) -> String {
        return orderId.replacingOccurrences(of: "#", with: "%23")
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
            
            Text("Order placed \(formattedDate(orderResponse?.order?.createdAt))") // dynamic update
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.secondary)
            
            // Action Buttons
            VStack(spacing: 12) {
                ActionButtonView(
                    icon: "mappin",
                    title: "Shipping to",
                    subtitle: formattedShippingAddress(orderResponse?.shippingAddress) // dynamic update
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
    
    // MARK: - Date Formatter
    private func formattedDate(_ isoDate: String?) -> String {
        guard let isoDate = isoDate else { return "" }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: isoDate) {
            let output = DateFormatter()
            output.dateFormat = "MMM dd, yyyy 'at' hh:mm a"
            return output.string(from: date)  // dynamic update
        }

        return isoDate
    }
    
    // MARK: - Shipping Address Formatter
    private func formattedShippingAddress(_ address: ShippingAddressModel?) -> String {
        guard let address else { return "" }

        return """
        \(address.name ?? "")
        \(address.streetAddress ?? "")
        \(address.city ?? "") \(address.state ?? "") \(address.pincode ?? "")
        """ // dynamic update
    }
    
    func formatOrderDate(_ isoDate: String?) -> String {
        guard let isoDate else { return "" }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = formatter.date(from: isoDate) else { return isoDate }

        let output = DateFormatter()
        output.dateFormat = "MMM dd yyyy"   // May 25 2025

        return output.string(from: date)
    }


    
    // MARK: - Product Image Card
    var productImageCard: some View {
        HStack(alignment: .top) {
            
            CustomProfileImage(
                url: orderResponse?.order?.product?.images?.first,
                isCircular: false,
                cornerRadius: 20,
                size: 200,
                height: 200,
                defaultImage: "photo"
            ) {
                print("profile icon tapped")
            }

            Spacer()
        }
//        .padding(.leading, 16)
    }
    
    // MARK: - Order Details Card
    var orderDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(orderResponse?.order?.product?.title?.capitalizingFirstLetter() ?? "🎀Single🎀 #212")
                .font(.custom("Poppins-Bold", size: 20))
            
            Text(orderResponse?.order?.product?.description ?? "Near Mint")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.secondary)
            
            Button {
                withAnimation(.spring()) { showProductDetails.toggle() }
            } label: {
                HStack {
                    Text("View Product Details")
                        .font(.custom("Poppins-SemiBold", size: 14))
                    
                    Image(systemName: showProductDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.blue)
            }

            
            // MARK: - Expanded / Collapsed Product Details
            if showProductDetails {
                Text("Order Details")
                    .font(.custom("Poppins-Bold", size: 18))
                    .padding(.top, 8)
                
                VStack(spacing: 0) {
                    DetailRowView(label: "Order ID", value: orderResponse?.order?.orderID ?? "#ORD-123-345", isCopyable: true, showCopied: $showCopied)
                    DetailRowView(label: "Order Date", value: formatOrderDate(orderResponse?.order?.createdAt) ?? "Nov 25, 2025")
                    DetailRowView(label: "Sold By", value: orderResponse?.sellerDetails?.name ?? "wyynaut", isLink: true)
                    DetailRowView(label: "Qty", value: orderResponse?.order?.product?.purchasedQuantity ?? "1")
                    DetailRowView(label: "Category", value: orderResponse?.order?.product?.category?.name ?? "Near Mint", isLink: true)
                }
                
                VStack(spacing: 12) {
                    CompactActionButton(icon: "doc.text", title: "Receipt & shipping details")
                    CompactActionButton(icon: "play.fill", title: "Video Receipt", subtitle: "Video receipt available for 60 more days")
                }
                .padding(.top, 8)

            } else {
                VStack(spacing: 12) {
                    CompactActionButton(icon: "doc.text", title: "Receipt & shipping details")
                    CompactActionButton(icon: "play.fill", title: "Video Receipt", subtitle: "Video receipt available for 60 more days")
                }
                .padding(.top, 8)
            }
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
                // Seller Banner / Cover
                LinearGradient(
                    colors: [Color.yellow, Color.orange, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)
                .cornerRadius(20)
//                .overlay(
//                    Text("😎")
//                        .font(.system(size: 60))
//                )
                
                // MARK: - UPDATED: Seller Profile Image (Replaced 🎀)
                CustomProfileImage(
                    url: orderResponse?.sellerDetails?.profile_image,   // dynamic seller image
                    isCircular: true,
                    cornerRadius: 40,
                    size: 100,
                    height: 100,
                    defaultImage: "user_dummy"                  // fallback image
                ) { print("Seller tapped") }                            // optional tap
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
                .offset(y: 40)
            }
            
            VStack(spacing: 16) {
                
                // Seller Name
                Text(orderResponse?.sellerDetails?.name ?? "Unknown Seller")
                    .font(.custom("Poppins-Bold", size: 20))
                    .padding(.top, 40)
                
                // -----------------------
                // MARK: Stats Row
                // -----------------------
                HStack(spacing: 0) {
                    StatScreen(
                        icon: "star.fill",
                        value: String(format: "%.1f", Double(orderResponse?.ratingAvg ?? 0)),
                        label: "Rating"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: nil,
                        value: "\(orderResponse?.soldCount ?? 0)",
                        label: "Sold"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: "clock",
                        value: orderResponse?.avgShip ?? "0d",
                        label: "Avg Ship"
                    )
                }
                .padding(16)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
                
                // Seller Bio
                VStack(alignment: .leading, spacing: 4) {
                    Text(orderResponse?.sellerDetails?.username ?? "-")
                    Text(orderResponse?.sellerDetails?.email ?? "-")
                }
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // View Profile Button
                Button(action: { print("View Profile tapped") }) {
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
    var btnAction: (() -> Void) = { }
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
        .onTapGesture {
            btnAction()
        }
    }
}

// MARK: - Preview
struct OrderTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        OrderTrackingView()
    }
}

extension OrderTrackingView {
    private func errorDesc(error: Error?, message: String?) -> String {
        guard let msg = message else {
            return error?.localizedDescription ?? "Something went wrong"
        }
        return msg
    }
}

