//
//  ExploreSearchResultsView.swift
//  BidCast
//
//  Created for MC task cmp5w1v7i019qm61hhld1uiul on 2026-05-15.
//
//  Renders the unified explore-search result list (Shows / Products / People)
//  shown on the Explore tab when the search bar has text.
//

import SwiftUI

struct ExploreSearchResultsView: View {
    let shows: [ExploreSearchShow]
    let products: [ExploreSearchProduct]
    let users: [ExploreSearchUser]
    let onShowTap: (ExploreSearchShow) -> Void
    let onProductTap: (ExploreSearchProduct) -> Void
    let onUserTap: (ExploreSearchUser) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if shows.isEmpty && products.isEmpty && users.isEmpty {
                    NoDataView(message: "No results found")
                        .padding(.top, 40)
                } else {
                    if !shows.isEmpty {
                        sectionHeader("Shows")
                        ForEach(shows) { show in
                            HStack(spacing: 12) {
                                thumbnail(urlString: show.thumbnail?.first, size: 60, isCircle: false)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(show.title ?? "Untitled show")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(show.user?.name ?? show.user?.username ?? "")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                            .onTapGesture { onShowTap(show) }
                        }
                    }

                    if !products.isEmpty {
                        sectionHeader("Products")
                        ForEach(products) { product in
                            HStack(spacing: 12) {
                                thumbnail(urlString: product.image, size: 60, isCircle: false)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(product.name ?? "Untitled product")
                                        .font(.system(size: 16, weight: .semibold))
                                    if let price = product.price {
                                        Text(String(format: "$%.2f", price))
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                            .onTapGesture { onProductTap(product) }
                        }
                    }

                    if !users.isEmpty {
                        sectionHeader("People")
                        ForEach(users) { user in
                            HStack(spacing: 12) {
                                thumbnail(urlString: user.profile_image, size: 48, isCircle: true)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name ?? "")
                                        .font(.system(size: 16, weight: .semibold))
                                    if let username = user.username, !username.isEmpty {
                                        Text("@\(username)")
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
                            .onTapGesture { onUserTap(user) }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
        }
        .background(Color.backGround)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .padding(.top, 4)
    }

    @ViewBuilder
    private func thumbnail(urlString: String?, size: CGFloat, isCircle: Bool) -> some View {
        Group {
            if let s = urlString, let url = URL(string: s), !s.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.15)
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.15)
                    @unknown default:
                        Color.gray.opacity(0.15)
                    }
                }
            } else {
                Color.gray.opacity(0.15)
            }
        }
        .frame(width: size, height: size)
        .clipShape(isCircle ? AnyShape(Circle()) : AnyShape(RoundedRectangle(cornerRadius: 8)))
    }
}

// SwiftUI's AnyShape is iOS 16+. The project's min iOS is 15.6 per the
// bidcast skill, so define a compat wrapper if needed. Swift type-checks
// the conditional clip shape via this generic adapter.
private struct AnyShape: Shape {
    private let pathFn: (CGRect) -> Path
    init<S: Shape>(_ shape: S) {
        self.pathFn = { rect in shape.path(in: rect) }
    }
    func path(in rect: CGRect) -> Path {
        pathFn(rect)
    }
}
