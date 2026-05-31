//
//  SearchResultsView.swift
//  BidCast
//
//  Trey QA 2026-05-31 (build 360 feedback): rebuilt with TABBED results matching
//  Android SearchShowFragment:
//    • Shows / Products / Users tabs (each showing section total in header)
//    • PER-TAB independent numbered pager (Prev/1…N/Next) — switching tabs
//      preserves each tab's own current-page and last-page state
//    • Tapping a page loads ONLY that tab's data (replaces, does not append)
//    • Multiselect tags wired through BrowseFiltersSheet → SearchViewModel
//
//  Basecamp #9935356432 (2026-05-28): rich card layout (Shows=2-col grid, Products=list rows)
//  Basecamp #9933801536 (2026-05-28): save-search bell button
//  Basecamp #9933301500 (2026-05-29): filter sheet on search results
//

import SwiftUI
import AlertToast

struct SearchResultsView: View {
    @StateObject private var viewModel = SearchViewModel()

    let initialQuery: String
    var onShowTap: ((Int) -> Void)?
    var onUserTap: ((Int) -> Void)?
    var onProductTap: ((Int) -> Void)?

    // Basecamp #9933801536: save-search bell state
    @State private var savedAcknowledged: Bool = false
    @State private var showSavedToast: Bool = false

    // Basecamp #9933301500 round 5: filter sheet
    @State private var showFiltersSheet: Bool = false
    @State private var appliedFilters: BrowseFilters = .empty

    private let cardColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Tab bar — Shows / Products / Users with totals
            // Matches Android TabLayout with section total counts.
            tabBar

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if viewModel.isLoading {
                        ProgressView("Searching...")
                            .padding(32)
                            .frame(maxWidth: .infinity)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        // MARK: Active tab content
                        activeTabContent

                        // MARK: Per-tab numbered pager
                        // Hidden when only 1 page for the active tab.
                        tabPager
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Search Results")
        .toolbar {
            // Basecamp #9933301500 round 5: filter button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFiltersSheet = true }) {
                    Image(systemName: appliedFilters.isActive
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(appliedFilters.isActive ? .orange : .primary)
                }
                .accessibilityLabel("Filter search results")
            }
            // Basecamp #9933801536: save-search bell
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveCurrentSearch) {
                    Image(systemName: savedAcknowledged ? "bell.fill" : "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(savedAcknowledged ? .orange : .primary)
                }
                .accessibilityLabel("Save this search")
            }
        }
        .sheet(isPresented: $showFiltersSheet) {
            BrowseFiltersSheet(
                isPresented: $showFiltersSheet,
                draft: appliedFilters,
                onApply: { newFilters in
                    appliedFilters = newFilters
                    rerunSearch()
                }
            )
        }
        .toast(isPresenting: $showSavedToast) {
            AlertToast(
                displayMode: .hud,
                type: .regular,
                title: "Search saved — you'll get notified when something matches",
                style: alertStlyeSuccess
            )
        }
        .onAppear { rerunSearch() }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(tab: .shows,    label: "Shows",    total: viewModel.showsTotal)
            tabButton(tab: .products, label: "Products", total: viewModel.productsTotal)
            tabButton(tab: .users,    label: "Users",    total: viewModel.usersTotal)
        }
        .background(Color(.systemGray6))
    }

    private func tabButton(tab: SearchTab, label: String, total: Int) -> some View {
        let isSelected = viewModel.activeTab == tab
        let displayLabel = total > 0 ? "\(label) (\(total))" : label
        return Button(action: { viewModel.activeTab = tab }) {
            VStack(spacing: 0) {
                Text(displayLabel)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .defaultTheme : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.vertical, 11)
                    .padding(.horizontal, 4)
                // Active indicator line
                Rectangle()
                    .fill(isSelected ? Color.defaultTheme : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Active Tab Content

    @ViewBuilder
    private var activeTabContent: some View {
        switch viewModel.activeTab {
        case .shows:
            showsContent
        case .products:
            productsContent
        case .users:
            usersContent
        }
    }

    @ViewBuilder
    private var showsContent: some View {
        if viewModel.shows.isEmpty {
            Text("No shows found for \"\(initialQuery)\"")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
        } else {
            LazyVGrid(columns: cardColumns, spacing: 16) {
                ForEach(viewModel.shows) { show in
                    ShowResultCard(show: show)
                        .onTapGesture { onShowTap?(show.id) }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }

    @ViewBuilder
    private var productsContent: some View {
        if viewModel.products.isEmpty {
            Text("No products found for \"\(initialQuery)\"")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 8) {
                ForEach(viewModel.products) { product in
                    ProductResultRow(product: product)
                        .onTapGesture { onProductTap?(product.id) }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }

    @ViewBuilder
    private var usersContent: some View {
        if viewModel.users.isEmpty {
            Text("No users found for \"\(initialQuery)\"")
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 8) {
                ForEach(viewModel.users) { user in
                    UserResultRow(user: user)
                        .onTapGesture { onUserTap?(user.id) }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }

    // MARK: - Per-Tab Pager
    //
    // Each tab has its own currentPage + lastPage. Tapping a page number calls
    // viewModel.loadPage(tab:page:) which updates ONLY that tab's array/page
    // state, leaving the other two tabs untouched — matches Android's independent
    // per-tab page counters (showsCurrentPage / productsCurrentPage / usersCurrentPage).

    @ViewBuilder
    private var tabPager: some View {
        let (currentPage, lastPage) = pagerState(for: viewModel.activeTab)
        if lastPage > 1 {
            SearchNumberedPager(
                currentPage: currentPage,
                totalPages: lastPage
            ) { page in
                viewModel.loadPage(tab: viewModel.activeTab, page: page)
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    private func pagerState(for tab: SearchTab) -> (Int, Int) {
        switch tab {
        case .shows:    return (viewModel.showsPage,    viewModel.showsLastPage)
        case .products: return (viewModel.productsPage, viewModel.productsLastPage)
        case .users:    return (viewModel.usersPage,    viewModel.usersLastPage)
        }
    }

    // MARK: - Search helpers

    private func rerunSearch() {
        runPagedSearch(page: 1)
    }

    private func runPagedSearch(page: Int) {
        let catIds = appliedFilters.categoryIds.isEmpty ? nil : appliedFilters.categoryIds
        let subIds = appliedFilters.subCategoryIds.isEmpty ? nil : appliedFilters.subCategoryIds
        viewModel.search(query: initialQuery, page: page,
                         categoryIds: catIds,
                         subCategoryIds: subIds,
                         filters: appliedFilters)
    }

    // Basecamp #9933801536: save current query as a saved search
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
}

// MARK: - Show card (2-col grid, 3:4 aspect thumbnail)

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

            // Thumbnail (3:4 aspect) — anchored on Color to set cell height correctly
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

// MARK: - Product row (single-column horizontal list)

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
            AsyncImage(url: thumbnailURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Color.gray.opacity(0.15)
                }
            }
            .frame(width: 72, height: 72)
            .clipped()
            .cornerRadius(8)

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

// MARK: - Numbered Pager (Trey QA 2026-05-31)
// Renders:  ‹ Prev   1  2  3  …  N   Next ›
// • Current page highlighted in orange
// • Ellipsis ("…") collapses long runs: always show first/last + ±2 around current
// • Prev disabled on page 1, Next disabled on last page

struct SearchNumberedPager: View {
    let currentPage: Int
    let totalPages: Int
    let onPageTap: (Int) -> Void

    private var visiblePages: [Int?] {
        guard totalPages > 1 else { return [1] }
        var pages = [Int?]()
        let window = 2
        var included = Set<Int>()
        included.insert(1)
        included.insert(totalPages)
        for p in max(1, currentPage - window)...min(totalPages, currentPage + window) {
            included.insert(p)
        }
        let sorted = included.sorted()
        var prev: Int? = nil
        for p in sorted {
            if let last = prev, p - last > 1 { pages.append(nil) }
            pages.append(p)
            prev = p
        }
        return pages
    }

    var body: some View {
        HStack(spacing: 4) {
            Button(action: { if currentPage > 1 { onPageTap(currentPage - 1) } }) {
                Text("‹ Prev")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(currentPage > 1 ? .defaultTheme : Color.gray.opacity(0.4))
            }
            .disabled(currentPage <= 1)

            ForEach(Array(visiblePages.enumerated()), id: \.offset) { _, item in
                if let page = item {
                    Button(action: { onPageTap(page) }) {
                        Text("\(page)")
                            .font(.system(size: 13, weight: page == currentPage ? .bold : .regular))
                            .frame(minWidth: 28, minHeight: 28)
                            .background(page == currentPage ? Color.defaultTheme : Color.clear)
                            .foregroundColor(page == currentPage ? .white : .primary)
                            .clipShape(Circle())
                    }
                } else {
                    Text("…")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .frame(minWidth: 16)
                }
            }

            Button(action: { if currentPage < totalPages { onPageTap(currentPage + 1) } }) {
                Text("Next ›")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(currentPage < totalPages ? .defaultTheme : Color.gray.opacity(0.4))
            }
            .disabled(currentPage >= totalPages)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
