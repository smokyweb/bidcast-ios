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
    var showsCancellationActions: Bool = true
    private var isProductSetOrder: Bool {
        order.productSet != nil
    }
    
    @State private var isPressed: Bool = false
    @State private var imageLoaded: Bool = false
    @State private var showApproveConfirm: Bool = false
    @State private var showDeclineConfirm: Bool = false
    @State private var decisionLoading: Bool = false
    @State private var decisionError: String? = nil

    var onTapCardView: (() -> Void)?
    var onTapBuyerView: (() -> Void)?
    /// Called on successful approve or decline so the list can refresh.
    var onCancellationDecided: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            if !isProductSetOrder {
                orderImageSection
            }
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
        .alert("Approve cancellation?", isPresented: $showApproveConfirm) {
            Button("Keep Order", role: .cancel) { }
            Button("Approve & Cancel", role: .destructive) { approveCancellation() }
        } message: {
            Text("This will cancel the order and notify the buyer.")
        }
        .alert("Decline cancellation?", isPresented: $showDeclineConfirm) {
            Button("Back", role: .cancel) { }
            Button("Decline", role: .destructive) { declineCancellation() }
        } message: {
            Text("The buyer will be notified that their cancellation request was declined.")
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
                url: order.product?.thumbnail?.first ?? order.product?.images?.first ?? "",
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
            cancellationRequestBlock
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var displayTitle: String {
        if isProductSetOrder {
            return order.productSetItemUnit?.name?.capitalizingFirstLetter()
                ?? order.productSetItem?.name?.capitalizingFirstLetter()
                ?? order.productSet?.name?.capitalizingFirstLetter()
                ?? "Auction Item"
        } else {
            return order.product?.title?.capitalizingFirstLetter() ?? "Order Title"
        }
    }


    private var displayPrice: String {
        if let transactionTotal = order.transaction?.first?.total,
           let amount = Double(transactionTotal) {
            return amount.compactCurrency()
        }

        if isProductSetOrder {
            return order.transaction?.first?.total?.toDouble?.compactCurrency() ?? "0.0"
        } else {
            return Double(order.product?.pricing ?? "0")?.compactCurrency() ?? "0.0"
        }
    }

    
    // MARK: - Status Badges
    private var statusBadges: some View {
        HStack(spacing: 8) {
            StatusBadge(
                // M2 (2026-05-28): render the API-provided human status_label
                // ("Needs Processing", "Ready to Ship", "Shipped", "Out for
                // Delivery", "Completed", ...). Falls back to the legacy
                // "<status> Review" string for old/cached responses that don't
                // carry status_label.
                title: displayStatusLabel,
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
        Text(displayTitle)
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
            
            Text(displayPrice)
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
                .foregroundColor(.defaultTheme)
            
            Text("Buyer:")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
            
            Text(order.user?.name?.capitalizingFirstLetter() ?? "Unknown")
                .font(.custom(poppinsMedium, size: 13))
                .foregroundColor(.defaultTheme)
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
        isPressed ? Color.defaultTheme.opacity(0.2) : Color.black.opacity(0.06)
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
    
    // MARK: - Status label (M2)
    /// Prefer the backend's human status_label (e.g. "Needs Processing",
    /// "Shipping Label Created", "In Transit", "Delivered/Completed",
    /// "Pending Shipping", "Cancelled"). Fall back to a cleaned-up raw
    /// status string when the field is absent (old/cached data).
    /// Basecamp #9986437322 (round 2): removed the " Review" suffix that was
    /// being appended to the raw status in the fallback path — Android
    /// (OrdersAdapter) never appends "Review"; it shows the status_label
    /// directly, or formats the raw status via replace("_"," ").asCapital().
    private var displayStatusLabel: String {
        if let label = order.statusLabel?.trimmingCharacters(in: .whitespacesAndNewlines),
           !label.isEmpty {
            return label
        }
        // Fallback: clean up the raw machine status (e.g. "needs_processing" → "Needs Processing")
        let raw = order.status ?? "Pending"
        return raw
            .replacingOccurrences(of: "_", with: " ")
            .capitalizingFirstLetter()
    }

    // MARK: - Status Colors
    private var statusColor: Color {
        // M2 (2026-05-28): prefer the machine status_bucket for coloring when
        // present; fall back to the legacy raw status mapping otherwise.
        switch (order.statusBucket ?? order.status)?.lowercased() {
        case "completed", "delivered":
            return .green
        case "processing", "shipped", "needs_processing", "ready_to_ship", "out_for_delivery":
            return .orange
        case "cancelled", "refunded":
            return .red
        case "pending", "new_order":
            return .defaultTheme
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
    // MARK: - Cancellation request block (seller)
    @ViewBuilder
    private var cancellationRequestBlock: some View {
        if showsCancellationActions, order.cancellationStatus?.lowercased() == "requested" {
            VStack(alignment: .leading, spacing: 8) {
                // Amber header with optional reason
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 14))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cancellation requested by buyer")
                            .font(.custom(poppinsSemiBold, size: 12))
                            .foregroundColor(.orange)
                        if let reason = order.cancellationReason, !reason.isEmpty {
                            Text(reason)
                                .font(.custom(poppinsRegular, size: 11))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                // Approve / Decline buttons
                if decisionLoading {
                    ProgressView()
                        .padding(.vertical, 4)
                } else {
                    HStack(spacing: 8) {
                        Button(action: { showApproveConfirm = true }) {
                            Text("Approve & Cancel")
                                .font(.custom(poppinsSemiBold, size: 11))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .clipShape(Capsule())
                        }
                        Button(action: { showDeclineConfirm = true }) {
                            Text("Decline")
                                .font(.custom(poppinsSemiBold, size: 11))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }

                if let err = decisionError {
                    Text(err)
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 6)
        }
    }

    // MARK: - Approve cancellation (seller)
    private func approveCancellation() {
        guard let orderId = order.id, orderId > 0 else { return }
        decisionLoading = true
        decisionError = nil
        Task {
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/decide-cancellation") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            let body: [String: Any] = ["order_id": orderId, "decision": "approve"]
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
            do {
                let (data, resp) = try await URLSession.shared.data(for: req)
                let http = resp as? HTTPURLResponse
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                let statusStr = (json?["status"] as? String) ?? ""
                let msg = (json?["message"] as? String) ?? ""
                await MainActor.run {
                    decisionLoading = false
                    if http?.statusCode == 200 && statusStr == "success" {
                        onCancellationDecided?()
                    } else {
                        decisionError = msg.isEmpty ? "Could not approve cancellation." : msg
                    }
                }
            } catch {
                await MainActor.run {
                    decisionLoading = false
                    decisionError = "Network error."
                }
            }
        }
    }

    // MARK: - Decline cancellation (seller)
    private func declineCancellation() {
        guard let orderId = order.id, orderId > 0 else { return }
        decisionLoading = true
        decisionError = nil
        Task {
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/decide-cancellation") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            let body: [String: Any] = ["order_id": orderId, "decision": "reject"]
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
            do {
                let (data, resp) = try await URLSession.shared.data(for: req)
                let http = resp as? HTTPURLResponse
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                let statusStr = (json?["status"] as? String) ?? ""
                let msg = (json?["message"] as? String) ?? ""
                await MainActor.run {
                    decisionLoading = false
                    if http?.statusCode == 200 && statusStr == "success" {
                        onCancellationDecided?()
                    } else {
                        decisionError = msg.isEmpty ? "Could not decline cancellation." : msg
                    }
                }
            } catch {
                await MainActor.run {
                    decisionLoading = false
                    decisionError = "Network error."
                }
            }
        }
    }

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
