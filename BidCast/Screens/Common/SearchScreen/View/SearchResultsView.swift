//
//  SearchResultsView.swift
//  BidCast
//
//  Basecamp #9935356432 (2026-05-28): rebuild search results to use rich card
//  layout matching the PWA spec. Shows render as 2-column grid with seller
//  avatar + name on top, 3:4 aspect thumbnail with LIVE/viewer-count overlay,
//  title + first product under. Products render as 2-column grid with
//  square thumb, title, price, AND seller username. Users render as full-width
//  rows with real profile images (unchanged behavior, just richer art).
//
//  Basecamp #9933801536 (2026-05-28): add save-search bell button to the
//  navigation bar so users can save the current query from search results.
//  Taps the same SavedSearchAPI.create() already used by CustomSearchBar.
//

import SwiftUI
import AlertToast

struct SearchResultsView: View {
    @StateObject private var viewModel = SearchViewModel()

    let initialQuery: String
    var onShowTap: ((Int) -> Void)?
    var onUserTap: ((Int) -> Void)?
    var onProductTap: ((Int) -> Void)?

    // Basecamp #9933801536: track whether the search was saved so the bell
    // flips to filled + orange after a successful save.
    @State private var savedAcknowledged: Bool = false
    @State private var showSavedToast: Bool = false

    private let cardColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                        .frame(maxWidth: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // MARK: - Shows
                    if !viewModel.shows.isEmpty {
                        sectionHeader("Shows", count: viewModel.shows.count)
                        LazyVGrid(columns: cardColumns, spacing: 16) {
                            ForEach(viewModel.shows) { show in
                                ShowResultCard(show: show)
                                    .onTapGesture { onShowTap?(show.id) }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Products
                    // Basecamp #9935356432 (2026-05-28 corrected): products render
                    // as a single-column list of horizontal rows, NOT a 2-col grid.
                    // Mirrors the seller-profile product list style from Trey's spec.
                    if !viewModel.products.isEmpty {
                        sectionHeader("Products", count: viewModel.products.count)
                        VStack(spacing: 8) {
                            ForEach(viewModel.products) { product in
                                ProductResultRow(product: product)
                                    .onTapGesture { onProductTap?(product.id) }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // MARK: - Users
                    if !viewModel.users.isEmpty {
                        sectionHeader("Users", count: viewModel.users.count)
                        VStack(spacing: 8) {
                            ForEach(viewModel.users) { user in
                                UserResultRow(user: user)
                                    .onTapGesture { onUserTap?(user.id) }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if !viewModel.isLoading && viewModel.shows.isEmpty && viewModel.products.isEmpty && viewModel.users.isEmpty {
                        Text("No results for \"\(initialQuery)\"")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Search Results")
        .toolbar {
            // Basecamp #9933801536: save-search bell in the top-right corner.
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveCurrentSearch) {
                    Image(systemName: savedAcknowledged ? "bell.fill" : "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(savedAcknowledged ? .orange : .primary)
                }
                .accessibilityLabel("Save this search")
            }
        }
        .toast(isPresenting: $showSavedToast) {
            AlertToast(
                displayMode: .hud,
                type: .regular,
                title: "Search saved — you'll get notified when something matches",
                style: alertStlyeSuccess
            )
        }
        .onAppear { viewModel.search(query: initialQuery) }
    }

    // Basecamp #9933801536: POST the current query to /api/saved-searches
    // and flip the bell icon to filled on success.
    private func saveCurrentSearch() {
        let trimmed = initialQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Task {
            await SavedSearchAPI.create(query: trimmed, filters: nil)
            await MainActor.run {
                savedAcknowledged = true
                showSavedToast = true
            }
        }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        Text("\(title) (\(count))")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }
}

// MARK: - Show card (matches home live/upcoming card)

private struct ShowResultCard: View {
    let show: SearchResultShow

    private var thumbnailURL: URL? {
        guard let first = show.thumbnail?.first else { return nil }
        return URL(string: first)
    }

    private var sellerProfileURL: URL? {
        guard let url = show.user?.profile_image, !url.isEmpty else { return nil }
        return URL(string: url)
    }

    private var sellerName: String {
        if let name = show.user?.name, !name.isEmpty { return name }
        if let username = show.user?.username, !username.isEmpty { return username }
        return "Seller"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Seller row
            HStack(spacing: 6) {
                AsyncImage(url: sellerProfileURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.gray.opacity(0.15)
                    }
                }
                .frame(width: 22, height: 22)
                .clipShape(Circle())
                Text(sellerName)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.black)
            }

            // Thumbnail (3:4 aspect)
            // Basecamp #9935356432 (2026-05-28 round 2): the previous
            // .scaledToFill + .aspectRatio(3/4, contentMode: .fill) + .clipped()
            // chain produced thumbnails that overflowed their grid cell
            // boundary, causing the show cards to visibly overlap each other
            // and overlap the section header on iOS. Fix: anchor the aspect
            // ratio on a transparent Color rectangle (which sets the cell
            // height correctly), then overlay the AsyncImage filling that
            // rectangle. .clipped() now actually constrains the image.
            Color.gray.opacity(0.15)
                .aspectRatio(3/4, contentMode: .fit)
                .overlay(
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color.gray.opacity(0.15)
                        }
                    }
                )
                .clipped()
                .cornerRadius(12)

            // Title + date
            VStack(alignment: .leading, spacing: 2) {
                Text(show.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                if let date = show.date, !date.isEmpty {
                    Text(date)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Product row (single-column horizontal list, matches seller-profile product list)

private struct ProductResultRow: View {
    let product: SearchResultProduct

    private var thumbnailURL: URL? {
        if let first = product.thumbnail?.first { return URL(string: first) }
        if let first = product.images?.first { return URL(string: first) }
        return nil
    }

    private var sellerUsername: String {
        if let username = product.user?.username, !username.isEmpty { return username }
        if let name = product.user?.name, !name.isEmpty { return name }
        return ""
    }

    private var priceLabel: String {
        if let p = product.pricing, !p.isEmpty {
            if let d = Double(p) {
                return String(format: "$%.2f", d)
            }
            return p
        }
        return ""
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Small square thumb LEFT
            AsyncImage(url: thumbnailURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Color.gray.opacity(0.15)
                }
            }
            .frame(width: 72, height: 72)
            .clipped()
            .cornerRadius(8)

            // Right-side stack
            VStack(alignment: .leading, spacing: 2) {
                Text(product.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(2)

                if !priceLabel.isEmpty {
                    Text(priceLabel)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 2)
                }

                // Basecamp #9935356432 (2026-05-28): seller username on product rows.
                if !sellerUsername.isEmpty {
                    Text("@\(sellerUsername)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(10)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .cornerRadius(10)
    }
}

// MARK: - User row

private struct UserResultRow: View {
    let user: SearchResultUser

    private var profileURL: URL? {
        guard let url = user.profile_image, !url.isEmpty else { return nil }
        return URL(string: url)
    }

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: profileURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Color.gray.opacity(0.15)
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(user.name ?? user.username ?? "Unknown")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                if let username = user.username, !username.isEmpty {
                    Text("@\(username)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
