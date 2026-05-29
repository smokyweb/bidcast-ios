//
//  PurchasesView.swift
//  BidCast
//
//  Created by JamTech on 18/11/25.
//

import SwiftUI

struct PurchasesViewScreen: View {
    var purchaseList: PurchasedOrderModel?
    @State private var userId: String = ""
    @State private var userImage: String = ""
    @State private var userName: String = ""
    // Basecamp #9934033253 (2026-05-27 → 2026-05-29): buyer cancel-request state
    @State private var showCancelConfirm: Bool = false
    @State private var cancelLoading: Bool = false
    @State private var cancelError: String? = nil
    @State private var localStatusOverride: String? = nil
    @State private var localCancellationStatus: String? = nil

    var onTapOrderTracking: ((PurchasedOrderModel?) -> Void)?
    var onTapUserProfile: ((String, String, String) -> Void)?
    var onOrderCancelled: ((Int) -> Void)? = nil

    // Effective cancellation status: local override wins (set after a successful API call)
    private var effectiveCancellationStatus: String? {
        localCancellationStatus ?? purchaseList?.cancellationStatus
    }

    // Basecamp #9934033253 (2026-05-27 → 2026-05-29): show request button when order
    // is cancellable and no cancellation is already pending/approved.
    private var canCancel: Bool {
        let s = (localStatusOverride ?? purchaseList?.status ?? "").lowercased()
        guard s == "pending" || s == "processing" else { return false }
        return effectiveCancellationStatus?.lowercased() != "requested"
    }

    private var cancelRejectedNote: String {
        if let reason = purchaseList?.cancellationRejectReason, !reason.isEmpty {
            return "Your order could not be cancelled. \(reason)"
        }
        return "Your order could not be cancelled."
    }

    private var isProductSet: Bool {
        purchaseList?.productSet != nil
    }
    private var displayTitle: String {
        if let setTitle = purchaseList?.productSet?.name, !setTitle.isEmpty {
            return setTitle.capitalizingFirstLetter()
        }
        return purchaseList?.product?.title?.capitalizingFirstLetter() ?? ""
    }

    private var displayPrice: String {
        if let price = purchaseList?.productSet?.price?.compactCurrency() {
            return price
        }
        if let price = purchaseList?.product?.pricing?.toDouble?.compactCurrency() {
            return price
        }
        return ""
    }

    private var displaySellerName: String {
        if let sellerName = purchaseList?.productSet?.seller?.name {
            return sellerName.capitalizingFirstLetter()
        }
        return purchaseList?.product?.user?.name?.capitalizingFirstLetter() ?? ""
    }

    private var displaySellerId: String {
        if let id = purchaseList?.productSet?.seller?.id {
            return "\(id)"
        }
        return "\(purchaseList?.product?.user?.id ?? 0)"
    }

    private var displaySellerImage: String {
        if let image = purchaseList?.productSet?.seller?.profileImage {
            return image
        }
        return purchaseList?.product?.user?.profileImage ?? ""
    }


    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // MARK: - Product Image
            if let imageURL = purchaseList?.product?.images?.first, !imageURL.isEmpty {
                URLImageView(url: imageURL, cornerRadius: 10, height: 80,)
                    .frame(width: 80, height: 80, alignment: .center)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                    )
//                    .padding(.horizontal, 6)
                    .padding(.leading, 12)
                    .padding(.trailing,4)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            }

            // MARK: - Order Details
            VStack(alignment: .leading, spacing: 2) {
                // Status Badge
                Text(purchaseList?.status?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsSemiBold, size: 12.0))
                    .foregroundColor(.green)
//                    .padding(.bottom, 2)
                    .padding(.horizontal, 10)
                    .background(.green.opacity(0.2))
//                    .padding(.vertical, 2)
                    .clipShape(Capsule())

                // Product Name
                Text(displayTitle)
                    .font(.custom(poppinsBold, size: 14.0))
                    .foregroundColor(.black)
                    .lineLimit(2)

                // Price
                HStack(spacing: 4) {
                    Text("Price:")
                        .font(.custom(poppinsBold, size: 12.0))
                        .foregroundColor(.gray)
//                    if let price = purchaseList?.product?.pricing?.toDouble?.compactCurrency() {
                        Text(displayPrice)
                            .font(.custom(poppinsBold, size: 12.0))
                            .foregroundColor(.black)
//                    }
                }

                // Purchase Date
                HStack(spacing: 4) {
                    Text("Purchased:")
                        .font(.custom(poppinsMedium, size: 12.0))
                        .foregroundColor(.gray)

                    Text(purchaseList?.createdAt?.formattedDateAndTimeString(input:"yyyy-MM-dd HH:mm:ss",output: " dd MMM yyyy") ?? "N/A")
                        .font(.custom(poppinsMedium, size: 12.0))
                        .foregroundColor(.black)
                }

                // Seller
                HStack(spacing: 4) {
                    Text("From:")
                        .font(.custom(poppinsMedium, size: 12.0))
                        .foregroundColor(.gray)
                    Button {
//                        userId = "\(purchaseList?.product?.user?.id ?? 0)"
//                        userImage = purchaseList?.product?.user?.profileImage ?? ""
//                        userName = purchaseList?.product?.user?.name ?? ""
                        userId = displaySellerId
                        userImage = displaySellerImage
                        userName = displaySellerName
                        onTapUserProfile?(userId, userImage, userName)
                    } label: {
                        Text(displaySellerName)
                            .font(.custom(poppinsMedium, size: 12.0))
                            .foregroundColor(.blue)
                    }


                }

                // Basecamp #9934033253 (2026-05-27 → 2026-05-29): request-cancellation tri-state block.
                cancellationStateBlock
                if let err = cancelError {
                    Text(err)
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.red)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal,isProductSet ? 12 : 0)

            Spacer()
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.28)) {
                onTapOrderTracking?(purchaseList)
            }
        }

        .padding(4)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .alert("Request to cancel this order?", isPresented: $showCancelConfirm) {
            Button("Keep Order", role: .cancel) { }
            Button("Request Cancellation", role: .destructive) {
                requestCancellation()
            }
        } message: {
            Text("Request to cancel this order? The seller will need to approve it.")
        }
    }

    // Basecamp #9934033253 (2026-05-29): POST /api/product/request-cancellation.
    private func requestCancellation() {
        guard let orderId = purchaseList?.id, orderId > 0 else { return }
        cancelLoading = true
        cancelError = nil
        Task {
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/request-cancellation") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            let body: [String: Any] = ["order_id": orderId]
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
            do {
                let (data, resp) = try await URLSession.shared.data(for: req)
                let http = resp as? HTTPURLResponse
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                let statusStr = (json?["status"] as? String) ?? ""
                let msg = (json?["message"] as? String) ?? ""
                await MainActor.run {
                    cancelLoading = false
                    if http?.statusCode == 200 && statusStr == "success" {
                        localCancellationStatus = "requested"
                    } else {
                        cancelError = msg.isEmpty ? "Could not request cancellation." : msg
                    }
                }
            } catch {
                await MainActor.run {
                    cancelLoading = false
                    cancelError = "Network error."
                }
            }
        }
    }

    // MARK: - Cancellation state UI (buyer)
    @ViewBuilder
    private var cancellationStateBlock: some View {
        if effectiveCancellationStatus?.lowercased() == "requested" {
            Text("⏳ Cancellation requested — waiting for seller approval")
                .font(.custom(poppinsRegular, size: 11))
                .foregroundColor(.orange)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.orange.opacity(0.12))
                .clipShape(Capsule())
                .padding(.top, 4)
        } else if effectiveCancellationStatus?.lowercased() == "rejected" && canCancel {
            VStack(alignment: .leading, spacing: 4) {
                Text(cancelRejectedNote)
                    .font(.custom(poppinsRegular, size: 11))
                    .foregroundColor(.red)
                requestCancelButton
            }
            .padding(.top, 4)
        } else if canCancel {
            requestCancelButton
                .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var requestCancelButton: some View {
        Button(action: { showCancelConfirm = true }) {
            HStack(spacing: 4) {
                if cancelLoading { ProgressView().scaleEffect(0.7) }
                Text(cancelLoading ? "Requesting…" : "Request Cancellation")
                    .font(.custom(poppinsSemiBold, size: 11))
                    .foregroundColor(.red)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.red.opacity(0.08))
            .clipShape(Capsule())
        }
        .disabled(cancelLoading)
    }

    func formattedDate(_ isoDate: String?) -> String {
        guard let isoDate = isoDate,
              let date = ISO8601DateFormatter().date(from: isoDate) else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

//// MARK: - Preview
//struct OrderItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            PurchasesViewScreen(
//                status: "Completed",
//                productName: "ACER charger #34",
//                price: "$15.97",
//                purchaseDate: "12/22/24",
//                seller: "blowout_tech_sales",
//                imageURL: nil
//            )
//            .padding()
//        }
//        .background(Color.gray.opacity(0.1))
//    }
//}

struct PurchasesViewShimmerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // Image shimmer
            PulseShimmerView()
                .frame(width: 80, height: 80)
                .cornerRadius(14)
                .padding(.horizontal, 6)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 8) {

                // Status shimmer
                PulseShimmerView()
                    .frame(width: 60, height: 14)
                    .cornerRadius(6)

                // Product Name shimmer
                PulseShimmerView()
                    .frame(width: 140, height: 14)
                    .cornerRadius(6)

                // Price shimmer
                PulseShimmerView()
                    .frame(width: 100, height: 12)
                    .cornerRadius(6)

                // Date shimmer
                PulseShimmerView()
                    .frame(width: 120, height: 12)
                    .cornerRadius(6)

                // Seller shimmer
                PulseShimmerView()
                    .frame(width: 90, height: 12)
                    .cornerRadius(6)
            }

            Spacer()
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
//
extension String {
    func formattedPrice() -> String {
        // Remove unwanted characters
        let clean = self.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)

        // Convert to Double
        guard let value = Double(clean) else { return "$0.00" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}


struct SavedViewScreen: View {
    var purchaseList: PurchasedOrderModel?
    @State private var userId: String = ""
    @State private var userImage: String = ""
    @State private var userName: String = ""

    var onTapOrderTracking: ((PurchasedOrderModel?) -> Void)?
    var onTapUserProfile: ((String, String, String) -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // MARK: - Product Image
            if let imageURL = purchaseList?.product?.images?.first, !imageURL.isEmpty {
                URLImageView(url: imageURL, cornerRadius: 10, height: 80,)
                    .frame(width: 80, height: 80, alignment: .center)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                    )
//                    .padding(.horizontal, 6)
                    .padding(.leading, 12)
                    .padding(.trailing,4)
                    .padding(.vertical,8)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            }

            // MARK: - Order Details
            VStack(alignment: .leading, spacing: 2) {
                // Status Badge
//                Text(purchaseList?.status?.capitalizingFirstLetter() ?? "")
//                    .font(.custom(poppinsSemiBold, size: 12.0))
//                    .foregroundColor(.green)
////                    .padding(.bottom, 2)
//                    .padding(.horizontal, 10)
//                    .background(.green.opacity(0.2))
////                    .padding(.vertical, 2)
//                    .clipShape(Capsule())
//
                // Product Name
                Text(purchaseList?.product?.title?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsBold, size: 14.0))
                    .foregroundColor(.black)
                    .lineLimit(2)
                Text(purchaseList?.product?.category?.name?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsRegular, size: 11.0))
                    .foregroundColor(.darkGray)
                    .lineLimit(2)

                // Price
                HStack(spacing: 4) {
                    Text("Price:")
                        .font(.custom(poppinsBold, size: 12.0))
                        .foregroundColor(.gray)
                    if let price = purchaseList?.product?.pricing?.toDouble?.compactCurrency() {
                        Text(price)
                            .font(.custom(poppinsBold, size: 12.0))
                            .foregroundColor(.black)
                    }
                }

                // Purchase Date
//                HStack(spacing: 4) {
//                    Text("Purchased:")
//                        .font(.custom(poppinsMedium, size: 12.0))
//                        .foregroundColor(.gray)
//
//                    Text(purchaseList?.createdAt?.formattedDateAndTimeString(input:"yyyy-MM-dd HH:mm:ss",output: " dd MMM yyyy") ?? "N/A")
//                        .font(.custom(poppinsMedium, size: 12.0))
//                        .foregroundColor(.black)
//                }

                // Seller
//                HStack(spacing: 4) {
//                    Text("From:")
//                        .font(.custom(poppinsMedium, size: 12.0))
//                        .foregroundColor(.gray)
//                    Button {
//                        userId = "\(purchaseList?.product?.user?.id ?? 0)"
//                        userImage = purchaseList?.product?.user?.profileImage ?? ""
//                        userName = purchaseList?.product?.user?.name ?? ""
//                        onTapUserProfile?(userId, userImage, userName)
//                    } label: {
//                        Text(purchaseList?.product?.user?.name?.capitalizingFirstLetter() ?? "")
//                            .font(.custom(poppinsMedium, size: 12.0))
//                            .foregroundColor(.blue)
//                    }
//
//
//                }
            }

            Spacer()
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.28)) {
                onTapOrderTracking?(purchaseList)
            }
        }

        .padding(4)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }


}



struct SavedShimmerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // Image shimmer
            PulseShimmerView()
                .frame(width: 80, height: 80)
                .cornerRadius(14)
                .padding(.horizontal, 6)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 8) {



                // Product Name shimmer
                PulseShimmerView()
                    .frame(width: 140, height: 14)
                    .cornerRadius(6)
                PulseShimmerView()
                    .frame(width: 140, height: 14)
                    .cornerRadius(6)

                // Price shimmer
                PulseShimmerView()
                    .frame(width: 100, height: 12)
                    .cornerRadius(6)


            }

            Spacer()
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
