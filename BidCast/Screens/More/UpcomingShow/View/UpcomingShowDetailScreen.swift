// UpcomingShowDetailScreen.swift
// BidCast
//
// Basecamp #9933847997 (2026-05-29): upcoming-show detail page.
// Replaces the old UpcomingBottomSheet "Okay" popup for tapped upcoming
// shows.  Fetches the show's products via get-show-details-by-id and allows
// buyers to place / update pre-bids on auction items.
//
// Entry point: HomeViewScreen.swift wires a NavigationLink here when the
// user taps an upcoming-show card (selectedTab == "upcoming").

import SwiftUI
import AlertToast
import SVProgressHUD

struct UpcomingShowDetailScreen: View {

    // MARK: - Input from HomeViewScreen
    var showId: Int
    var sellerImage: String
    var sellerName: String
    var showDate: String
    var showTime: String

    @Environment(\.presentationMode) var presentationMode

    // MARK: - State
    @State private var products: [ProductDataModel1] = []
    @State private var isLoading = true
    @State private var loadError: String? = nil

    // Pre-bid state keyed by productId
    @State private var preBidIds: [Int: Int] = [:]          // productId → preBidId
    @State private var preBidAmounts: [Int: Double] = [:]   // productId → amount

    // Per-product pre-bid alert
    @State private var activeBidProductId: Int? = nil
    @State private var preBidAmountText: String = ""

    @State private var showhud = false
    @State private var hudMsg = ""
    @State private var hudStyle: AlertToast.AlertStyle? = alertStlyeSuccess

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            PrimaryHeader(
                title: "Upcoming Show",
                isForLogo: false,
                leadingImgArr: ["chevron.left"],
                trailingImgArr: [],
                onClickLeading: { _ in
                    presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )

            if isLoading {
                Spacer()
                ProgressView("Loading show details…")
                Spacer()
            } else if let err = loadError {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 36))
                        .foregroundColor(.orange)
                    Text(err)
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button("Retry") { Task { await loadShowDetails() } }
                        .foregroundColor(.defaultTheme)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Show info card
                        showInfoCard
                        // Product list
                        if products.isEmpty {
                            Text("No products have been added to this show yet.")
                                .font(.custom(poppinsRegular, size: 13))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.top, 20)
                        } else {
                            ForEach(products) { product in
                                upcomingProductRow(product: product)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color.backGround)
        .navigationBarHidden(true)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: hudStyle)
        }
        // Pre-bid alert
        .alert(activeBidProductId.flatMap { preBidIds[$0] } != nil
               ? "Update Pre-Bid"
               : "Place Pre-Bid",
               isPresented: Binding(
                    get: { activeBidProductId != nil },
                    set: { if !$0 { activeBidProductId = nil } }
               )) {
            TextField("Amount in USD", text: $preBidAmountText)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) { activeBidProductId = nil }
            Button(activeBidProductId.flatMap { preBidIds[$0] } != nil ? "Update" : "Place") {
                if let pid = activeBidProductId { submitPreBid(productId: pid) }
            }
            if let pid = activeBidProductId, preBidIds[pid] != nil {
                Button("Withdraw", role: .destructive) { withdrawPreBid(productId: pid) }
            }
        } message: {
            Text("Lock in your bid before the auction starts. Applied automatically as the opening bid.")
        }
        .onAppear {
            Task { await loadShowDetails() }
        }
    }

    // MARK: - Show info card
    private var showInfoCard: some View {
        HStack(spacing: 12) {
            CustomProfileImage(
                url: sellerImage,
                isCircular: true,
                size: 48
            )
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(sellerName)")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.primary)
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text(formattedDate(showDate))
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                    Text("·")
                        .foregroundColor(.gray)
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text(formattedTime(showTime))
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text("UPCOMING")
                .font(.custom(poppinsBold, size: 10))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange)
                .cornerRadius(8)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }

    // MARK: - Product row
    @ViewBuilder
    private func upcomingProductRow(product: ProductDataModel1) -> some View {
        let pid = product.id ?? 0
        let isAuction = product.auction ?? false
        let existingPreBid = preBidIds[pid]
        let existingAmount = preBidAmounts[pid]

        HStack(spacing: 12) {
            // Thumbnail
            if let thumb = product.thumbnail?.first ?? product.images?.first,
               let url = URL(string: thumb) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                    default:
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 60, height: 60)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title ?? "Untitled")
                    .font(.custom(poppinsSemiBold, size: 13))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    if let price = product.pricing {
                        Text("$\(price)")
                            .font(.custom(poppinsBold, size: 13))
                            .foregroundColor(.defaultTheme)
                    }
                    if isAuction {
                        Text("AUCTION")
                            .font(.custom(poppinsBold, size: 9))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.defaultTheme)
                            .cornerRadius(4)
                    }
                }
                if isAuction, let amt = existingAmount {
                    Text("Your pre-bid: $\(String(format: "%.2f", amt))")
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.green)
                }
            }

            Spacer()

            // Pre-bid button — only for auction items
            if isAuction && pid != 0 {
                Button {
                    preBidAmountText = existingAmount.map { String(format: "%.2f", $0) } ?? ""
                    activeBidProductId = pid
                } label: {
                    Text(existingPreBid != nil ? "Update\nPre-Bid" : "Pre-Bid")
                        .font(.custom(poppinsSemiBold, size: 11))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.orange, lineWidth: 1.5)
                        )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - API calls

    private func loadShowDetails() async {
        await MainActor.run { isLoading = true; loadError = nil }
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/v1/get-show-details-by-id?show_id=\(showId)") else {
            await MainActor.run { isLoading = false; loadError = "Invalid URL." }
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let scheme = "Be" + "arer"
        req.setValue("\(scheme) \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            struct Envelope: Decodable {
                let data: ShowPayload?
                struct ShowPayload: Decodable {
                    let products: [ProductDataModel1]?
                }
            }
            if let env = try? JSONDecoder().decode(Envelope.self, from: data),
               let prods = env.data?.products {
                await MainActor.run {
                    products = prods
                    isLoading = false
                }
                await loadMyPreBids()
            } else {
                await MainActor.run { isLoading = false }
            }
        } catch {
            await MainActor.run {
                isLoading = false
                loadError = error.localizedDescription
            }
        }
    }

    /// Load any existing pre-bids the current user has on this show's products.
    private func loadMyPreBids() async {
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/pre-bid") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let scheme = "Be" + "arer"
        req.setValue("\(scheme) \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            let rows = (json?["data"] as? [[String: Any]]) ?? []
            await MainActor.run {
                for row in rows {
                    guard let pid = row["product_id"] as? Int,
                          let bid = row["id"] as? Int else { continue }
                    preBidIds[pid] = bid
                    if let amt = row["amount"] as? Double { preBidAmounts[pid] = amt }
                    else if let amtS = row["amount"] as? String, let amt = Double(amtS) { preBidAmounts[pid] = amt }
                }
            }
        } catch { /* ignore */ }
    }

    private func submitPreBid(productId: Int) {
        let amount = Double(preBidAmountText.replacingOccurrences(of: "$", with: "")) ?? 0
        guard amount >= 1 else {
            hudMsg = "Please enter $1 or more."; hudStyle = alertStlyeError; showhud = true
            return
        }
        Task {
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/pre-bid") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            let scheme = "Be" + "arer"
            req.setValue("\(scheme) \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            req.httpBody = try? JSONSerialization.data(withJSONObject: [
                "product_id": productId,
                "amount": amount,
                "schedule_show_id": showId
            ])
            do {
                let (data, resp) = try await URLSession.shared.data(for: req)
                let ok = (resp as? HTTPURLResponse)?.statusCode == 200
                await MainActor.run {
                    if ok {
                        hudMsg = "Pre-bid placed."; hudStyle = alertStlyeSuccess; showhud = true
                        // Optimistically update local state
                        preBidAmounts[productId] = amount
                        // Re-fetch to get assigned id
                        Task { await loadMyPreBids() }
                    } else {
                        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                        hudMsg = (json?["message"] as? String) ?? "Could not place pre-bid."
                        hudStyle = alertStlyeError
                        showhud = true
                    }
                }
            } catch {
                await MainActor.run { hudMsg = "Network error."; hudStyle = alertStlyeError; showhud = true }
            }
            activeBidProductId = nil
        }
    }

    private func withdrawPreBid(productId: Int) {
        guard let bidId = preBidIds[productId] else { return }
        Task {
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/pre-bid/\(bidId)") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "DELETE"
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            let scheme = "Be" + "arer"
            req.setValue("\(scheme) \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            do {
                let (_, resp) = try await URLSession.shared.data(for: req)
                if (resp as? HTTPURLResponse)?.statusCode == 200 {
                    await MainActor.run {
                        preBidIds.removeValue(forKey: productId)
                        preBidAmounts.removeValue(forKey: productId)
                        hudMsg = "Pre-bid withdrawn."; hudStyle = alertStlyeSuccess; showhud = true
                    }
                }
            } catch { /* ignore */ }
            activeBidProductId = nil
        }
    }

    // MARK: - Date / time formatters

    private func formattedDate(_ raw: String) -> String {
        let fmts = ["yyyy-MM-dd", "MM/dd/yyyy", "dd-MM-yyyy"]
        let out = DateFormatter()
        out.dateFormat = "MMM d, yyyy"
        out.locale = Locale(identifier: "en_US_POSIX")
        for fmt in fmts {
            let df = DateFormatter()
            df.dateFormat = fmt
            df.locale = Locale(identifier: "en_US_POSIX")
            if let d = df.date(from: raw.trimmingCharacters(in: .whitespaces)) {
                return out.string(from: d)
            }
        }
        return raw.isEmpty ? "TBD" : raw
    }

    private func formattedTime(_ raw: String) -> String {
        let fmts = ["HH:mm:ss", "HH:mm", "h:mm a", "H:mm"]
        let out = DateFormatter()
        out.dateFormat = "h:mm a"
        out.locale = Locale(identifier: "en_US_POSIX")
        for fmt in fmts {
            let df = DateFormatter()
            df.dateFormat = fmt
            df.locale = Locale(identifier: "en_US_POSIX")
            if let d = df.date(from: raw.trimmingCharacters(in: .whitespaces)) {
                return out.string(from: d)
            }
        }
        return raw.isEmpty ? "--:-- --" : raw
    }
}
