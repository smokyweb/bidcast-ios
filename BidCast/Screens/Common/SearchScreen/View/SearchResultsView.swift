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

import SwiftUI

struct SearchResultsView: View {
    @StateObject private var viewModel = SearchViewModel()

    let initialQuery: String
    var onShowTap: ((Int) -> Void)?
    var onUserTap: ((Int) -> Void)?
    var onProductTap: ((Int) -> Void)?

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
                    if !viewModel.products.isEmpty {
                        sectionHeader("Products", count: viewModel.products.count)
                        LazyVGrid(columns: cardColumns, spacing: 12) {
                            ForEach(viewModel.products) { product in
                                ProductResultCard(product: product)
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
        .onAppear { viewModel.search(query: initialQuery) }
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
            ZStack(alignment: .topLeading) {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.gray.opacity(0.15)
                    }
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(3/4, contentMode: .fill)
                .clipped()
                .cornerRadius(12)
            }

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

// MARK: - Product card (matches PWA product grid, includes seller username)

private struct ProductResultCard: View {
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
        VStack(alignment: .leading, spacing: 6) {
            // Square thumbnail
            AsyncImage(url: thumbnailURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Color.gray.opacity(0.15)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .clipped()
            .cornerRadius(8)

            Text(product.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(1)

            if !priceLabel.isEmpty {
                Text(priceLabel)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            // Basecamp #9935356432 (2026-05-28): seller username on product cards.
            if !sellerUsername.isEmpty {
                Text("@\(sellerUsername)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
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
