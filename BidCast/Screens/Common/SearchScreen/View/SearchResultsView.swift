//
//  SearchResultsView.swift
//  BidCast
//
//  Created by Larry Difficult Task Agent on 2026-05-18.
//

import SwiftUI

struct SearchResultsView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    // State for navigation
    @State private var navigateToProduct: SearchResultProduct?
    @State private var navigateToUser: SearchResultUser?
    @State private var navigateToShow: SearchResultShow?
    
    // The initial query passed from Home or Explore
    let initialQuery: String
    
    var body: some View {
        ScrollView {
            // Navigation Links
            if let product = navigateToProduct {
                NavigationLink(destination: ProductDetailsView(productId: String(product.id)), tag: product, selection: $navigateToProduct) { EmptyView() }
            }
            if let user = navigateToUser {
                NavigationLink(destination: ProfileScreen(id: .constant(String(user.id)), isComeFrom: .constant("Search")), tag: user, selection: $navigateToUser) { EmptyView() }
            }
            if let show = navigateToShow {
                // Placeholder: This will require fetching full show details first
                // For now, it will just be a link that gets triggered.
                // We'll need a new view or a loader that fetches details then presents LiveStream.
                NavigationLink(destination: Text("Fetching Show Details..."), tag: show, selection: $navigateToShow) { EmptyView() }
            }

            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    if !viewModel.shows.isEmpty {
                        Section(header: headerView(title: "Shows", count: viewModel.shows.count)) {
                            ForEach(viewModel.shows) { show in
                                ShowCard(show: show)
                                    .onTapGesture {
                                        // TODO: Implement full fetch & navigation logic
                                        print("Tapped show \(show.id)")
                                        self.navigateToShow = show
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if !viewModel.products.isEmpty {
                        Section(header: headerView(title: "Products", count: viewModel.products.count)) {
                            ForEach(viewModel.products) { product in
                                ProductCard(product: product)
                                    .onTapGesture {
                                        guard product.id != 0 else { return } // Assuming 0 is not a valid ID
                                        self.navigateToProduct = product
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if !viewModel.users.isEmpty {
                        Section(header: headerView(title: "Users", count: viewModel.users.count)) {
                            ForEach(viewModel.users) { user in
                                UserCard(user: user)
                                    .onTapGesture {
                                        self.navigateToUser = user
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Search Results")
        .onAppear {
            viewModel.search(query: initialQuery)
        }
    }
    
    private func headerView(title: String, count: Int) -> some View {
        Text("\(title) (\(count))")
            .font(.headline)
            .padding(.vertical, 8)
    }
}

// MARK: - Simple Card Views
private struct ShowCard: View {
    let show: SearchResultShow
    var body: some View {
        HStack {
            // Using a placeholder icon as image URLs can be complex
            Image(systemName: "video.fill")
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            VStack(alignment: .leading) {
                Text(show.title).fontWeight(.bold)
                Text(show.user?.name ?? "Unknown creator").font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

private struct ProductCard: View {
    let product: SearchResultProduct
    var body: some View {
        HStack {
            Image(systemName: "tag.fill")
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            VStack(alignment: .leading) {
                Text(product.title).fontWeight(.bold)
                Text("$\(product.pricing)").font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

private struct UserCard: View {
    let user: SearchResultUser
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .frame(width: 50, height: 50)
                .background(Color.green.opacity(0.2))
                .cornerRadius(8)
            VStack(alignment: .leading) {
                Text(user.name ?? "Unknown").fontWeight(.bold)
                Text(user.username ?? "").font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}


extension Product: Hashable {
    static func == (lhs: SearchResultProduct, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension User: Hashable {
    static func == (lhs: SearchResultUser, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Show: Hashable {
    static func == (lhs: SearchResultShow, rhs: Show) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
