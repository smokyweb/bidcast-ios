//
//  SearchResultsView.swift
//  BidCast
//

import SwiftUI

struct SearchResultsView: View {
    @StateObject private var viewModel = SearchViewModel()

    let initialQuery: String
    /// Called when a show row is tapped. Parent handles deepLinkShowId nav.
    var onShowTap: ((Int) -> Void)?

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
                    // Shows section
                    if !viewModel.shows.isEmpty {
                        sectionHeader("Shows", count: viewModel.shows.count)
                        ForEach(viewModel.shows) { show in
                            ShowResultRow(show: show)
                                .onTapGesture { onShowTap?(show.id) }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                        }
                    }

                    // Products section
                    if !viewModel.products.isEmpty {
                        sectionHeader("Products", count: viewModel.products.count)
                        ForEach(viewModel.products) { product in
                            ProductResultRow(product: product)
                                // TODO(post-v1): tap → standalone product detail screen
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                        }
                    }

                    // Users section
                    if !viewModel.users.isEmpty {
                        sectionHeader("Users", count: viewModel.users.count)
                        ForEach(viewModel.users) { user in
                            UserResultRow(user: user)
                                // TODO(post-v1): tap → standalone seller profile screen
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                        }
                    }

                    if !viewModel.isLoading && viewModel.shows.isEmpty && viewModel.products.isEmpty && viewModel.users.isEmpty {
                        Text("No results for \"\(initialQuery)\"")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Search Results")
        .onAppear { viewModel.search(query: initialQuery) }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        Text("\(title) (\(count))")
            .font(.headline)
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }
}

// MARK: - Row views

private struct ShowResultRow: View {
    let show: SearchResultShow
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "video.fill")
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.red.opacity(0.8))
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 2) {
                Text(show.title).fontWeight(.semibold).lineLimit(1)
                if let creator = show.user?.name {
                    Text(creator).font(.caption).foregroundColor(.secondary)
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

private struct ProductResultRow: View {
    let product: SearchResultProduct
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tag.fill")
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.8))
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 2) {
                Text(product.title).fontWeight(.semibold).lineLimit(1)
                if let pricing = product.pricing {
                    Text(pricing).font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

private struct UserResultRow: View {
    let user: SearchResultUser
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill")
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.8))
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 2) {
                Text(user.name ?? "Unknown").fontWeight(.semibold)
                if let username = user.username, !username.isEmpty {
                    Text("@\(username)").font(.caption).foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
