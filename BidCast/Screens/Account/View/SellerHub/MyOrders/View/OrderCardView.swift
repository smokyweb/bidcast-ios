//
//  OrderCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUI

// MARK: - Order Card View
//struct OrderCardView: View {
//    let order: MyOrderModel?
//    var statusColor: Color {
//            switch order?.status {
//            case "Processing": return .defaultTheme.opacity(0.5)
//            case "NewOrder", "Pending": return .darkBlue.opacity(0.5)
//            case "Completed", "Delivered": return .green.opacity(0.5)
//            default: return .gray.opacity(0.4)
//            }
//        }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text(order?.orderID ?? "")
//                    .fontWeight(.semibold)
//                    .foregroundColor(.black)
//                Spacer()
//                Text(order?.status ?? "")
//                    .font(.custom(poppinsSemiBold, size: 13.0))
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 4)
//                    .background(statusColor.opacity(0.5))
//                    .foregroundColor(statusColor)
//                    .cornerRadius(10)
//            }
//
//            Text(order?.product?.createdAt?.formattedDateAndTimeString() ?? "N/A")                .font(.custom(poppinsSemiBold, size: 13.0))
//                .foregroundColor(.gray)
//
//            HStack(spacing: 12) {
//                CustomProfileImage(url: order?.product?.images?.first ?? "",isCircular: true,size: 40)
//                
//                VStack(alignment: .leading) {
//                    Text(order?.product?.title?.capitalizingFirstLetter() ?? "")
//                        .font(.custom(poppinsSemiBold, size: 14.0))
//                        .foregroundColor(.black)
//                    Text(order?.product?.description ?? "")
//                        .font(.custom(poppinsRegular, size: 13.0))
//                        .foregroundColor(.gray)
//                }
//            }
//            Divider()
//                .padding(.vertical, 4)
//            HStack {
//                Text("Order Amount")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                Spacer()
//                Text("$\(Double(order?.product?.pricing ?? "0.0") ?? 0.0, specifier: "%.2f")")
//                    .font(.custom(poppinsSemiBold, size: 13.0))
//                    .foregroundColor(.black)
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
//    }
//}


//
//  ModernOrderCardView.swift
//  BidCast
//
//  Modern order card with animations and shimmer
//

import SwiftUI

// MARK: - Modern Order Card View
struct OrderCardView: View {
    let order: MyOrderModel
    
    @State private var isPressed: Bool = false
    @State private var imageLoaded: Bool = false
    
    var onTapCardView: (() -> Void)?
    var onTapBuyerView: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            orderImageSection
            orderDetailsSection
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowY)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
//        .simultaneousGesture(pressGesture)
        .onTapGesture {
            onTapCardView?()
        }
    }
    
    // MARK: - Image Section
    private var orderImageSection: some View {
        ZStack {
            // Placeholder with shimmer while loading
            if !imageLoaded {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .shimmer()
            }
            
            // Actual Image
            CustomProfileImage(
                url: order.product?.images?.first ?? "",
                isCircular: false,
                size: 100
            )
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .onAppear {
                // Simulate image load
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        imageLoaded = true
                    }
                }
            }
        }
    }
    
    // MARK: - Details Section
    private var orderDetailsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            statusBadges
            orderId
            orderTitle
            soldForSection
            orderDateSection
            Button {
                onTapBuyerView?()
            } label: {
                buyerSection
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Status Badges
    private var statusBadges: some View {
        HStack(spacing: 8) {
            StatusBadge(
                title: "\(order.status ?? "Pending") Review",
                backgroundColor: statusColor.opacity(0.15),
                textColor: statusColor
            )
            
//            StatusBadge(
//                title: earningStatus.replacingOccurrences(of: "_", with: " ").capitalized,
//                backgroundColor: .green.opacity(0.15),
//                textColor: .green
//            )
        }
    }
    
    // MARK: - Order Title
    private var orderTitle: some View {
        Text(order.product?.title ?? "Order Title")
            .font(.custom(poppinsSemiBold, size: 15))
            .foregroundColor(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var orderId: some View {
        Text(order.orderID ?? "Order ID")
            .font(.custom(poppinsRegular, size: 13))
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    // MARK: - Sold For Section
    private var soldForSection: some View {
        HStack(spacing: 4) {
            Text("Sold for:")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
            
            Text("$\(order.product?.pricing ?? "0")")
                .font(.custom(poppinsSemiBold, size: 15))
                .foregroundColor(.primary)
        }
    }
    
    // MARK: - Order Date Section
    private var orderDateSection: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("Date:")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
                Text(formatISODateString(order.createdAt ?? ""))
                    .font(.custom(poppinsMedium, size: 13))
                    .foregroundColor(.primary)
        }
    }
    
    // MARK: - Buyer Section
    private var buyerSection: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.blue)
            
            Text("Buyer:")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
            
            Text(order.user?.name ?? "Unknown")
                .font(.custom(poppinsMedium, size: 13))
                .foregroundColor(.blue)
                .lineLimit(1)
        }
    }
    
    // MARK: - Card Styling
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
    
    private var shadowColor: Color {
        isPressed ? Color.blue.opacity(0.2) : Color.black.opacity(0.06)
    }
    
    private var shadowRadius: CGFloat {
        isPressed ? 12 : 8
    }
    
    private var shadowY: CGFloat {
        isPressed ? 4 : 3
    }
    
    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in isPressed = true }
            .onEnded { _ in isPressed = false }
    }
    
    // MARK: - Status Colors
    private var statusColor: Color {
        switch order.status?.lowercased() {
        case "completed", "delivered":
            return .green
        case "processing", "shipped":
            return .orange
        case "cancelled", "refunded":
            return .red
        case "pending", "new_order":
            return .blue
        default:
            return .gray
        }
    }
    
//    private var earningStatusColor: Color {
//        switch order.earning_status?.lowercased() {
//        case "earnings_completed", "completed":
//            return .green
//        case "pending_review", "under_review":
//            return .orange
//        case "on_hold":
//            return .red
//        default:
//            return .blue
//        }
//    }
//    
    func formatISODateString(
        _ dateString: String,
        outputFormat: String = "MMM dd, yyyy"
    ) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = iso.date(from: dateString) else { return dateString }

        let formatter = DateFormatter()
        formatter.dateFormat = outputFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current

        return formatter.string(from: date)
    }

}

// MARK: - Status Badge Component
struct StatusBadge: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        Text(title)
            .font(.custom(poppinsSemiBold, size: 11))
            .foregroundColor(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
            .overlay(
                Capsule()
                    .stroke(textColor.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Order Card Shimmer (Loading State)
struct OrderCardShimmerView: View {
    var body: some View {
        HStack(spacing: 16) {
            imageShimmer
            detailsShimmer
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
    
    private var imageShimmer: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 100, height: 100)
            .shimmer()
    }
    
    private var detailsShimmer: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Status badges
            HStack(spacing: 8) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 90, height: 22)
                    .shimmer()
                
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 110, height: 22)
                    .shimmer()
            }
            
            // Title
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                    .shimmer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 16)
                    .shimmer()
            }
            
            // Sold for
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 14)
                .shimmer()
            
            // Date
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 140, height: 14)
                .shimmer()
            
            // Buyer
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 130, height: 14)
                .shimmer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Shimmer Modifier (if not already defined)
//extension View {
//    func shimmer() -> some View {
//        self.modifier(ShimmerModifier())
//    }
//}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(shimmerOverlay(content: content))
            .onAppear(perform: startAnimation)
    }
    
    private func shimmerOverlay(content: Content) -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .clear,
                Color.white.opacity(0.6),
                .clear
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .rotationEffect(.degrees(30))
        .offset(x: phase)
        .mask(content)
    }
    
    private func startAnimation() {
        withAnimation(
            Animation.linear(duration: 1.5)
                .repeatForever(autoreverses: false)
        ) {
            phase = 400
        }
    }
}
