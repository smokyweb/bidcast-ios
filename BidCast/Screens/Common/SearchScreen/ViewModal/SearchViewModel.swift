//
//  SearchViewModel.swift
//  BidCast
//
//  Created by JAM-E-265 on 02/02/24.
//
//  Trey QA 2026-05-31 (build 360 feedback): full rebuild for tabbed search results.
//  ROOT CAUSE of build 360 bug: a SINGLE shared `currentPage` + a single `search()`
//  that replaced ALL 3 arrays simultaneously → tapping any pager page reloaded all
//  3 sections to the same page (Products-page-2 would also clobber Shows-page-1).
//
//  FIX: per-tab page state (showsPage / productsPage / usersPage) + an `activeTab`
//  publisher. `search()` handles initial / filter-change loads (all tabs reset to
//  page 1). `loadPage(tab:page:)` loads a specific page for ONE tab only, leaving
//  the other two tabs untouched — this is the Android parity behaviour (Android
//  tracks showsCurrentPage / productsCurrentPage / usersCurrentPage independently).
//

import Foundation

// MARK: - SearchTab (active tab selection)

enum SearchTab: String, CaseIterable {
    case shows    = "Shows"
    case products = "Products"
    case users    = "Users"
}

// MARK: - SearchViewModel

@MainActor
final class SearchViewModel: ObservableObject {

    @Published var shows: [SearchResultShow] = []
    @Published var products: [SearchResultProduct] = []
    @Published var users: [SearchResultUser] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Trey QA 2026-05-31: active tab drives which section is visible + which pager
    // is shown. Switching tabs is instant (no network call) — each tab's results
    // are already loaded from the initial search or the last per-tab page load.
    @Published var activeTab: SearchTab = .shows

    // Per-tab current page (1-based). Reset to 1 on full search or filter change.
    @Published var showsPage:    Int = 1
    @Published var productsPage: Int = 1
    @Published var usersPage:    Int = 1

    // Per-tab last page (from pagination.{shows,products,users}.last_page).
    // Drives the numbered pager's total-page count for each tab independently.
    @Published var showsLastPage:    Int = 1
    @Published var productsLastPage: Int = 1
    @Published var usersLastPage:    Int = 1

    // Per-tab totals for tab-header counts ("Shows (28)").
    @Published var showsTotal:    Int = 0
    @Published var productsTotal: Int = 0
    @Published var usersTotal:    Int = 0

    // Full pagination object kept for callers that inspect it directly.
    @Published var pagination: SearchPagination? = nil

    // Convenience: current page for the active tab (used by anything that
    // still reads viewModel.currentPage — e.g. legacy call sites).
    var currentPage: Int {
        switch activeTab {
        case .shows:    return showsPage
        case .products: return productsPage
        case .users:    return usersPage
        }
    }

    // Cached request context so per-tab page loads reuse the same query + filters.
    private var lastQuery:          String       = ""
    private var lastCategoryIds:    [Int]?       = nil
    private var lastSubCategoryIds: [Int]?       = nil
    private var lastFilters:        BrowseFilters? = nil

    // MARK: - Full search (initial load or filter change, all tabs reset to page 1)

    // Basecamp #9933301500 (2026-05-29): accept the full BrowseFilters set.
    // Basecamp #9938023997 (2026-05-28): category + subcategory filter params.
    // Trey QA 2026-05-31: `page` param intentionally reset to 1 here — callers
    // that want per-tab pagination should use `loadPage(tab:page:)` instead.
    func search(query: String, page: Int = 1,
                categoryIds: [Int]? = nil,
                subCategoryIds: [Int]? = nil,
                filters: BrowseFilters? = nil) {
        // Cache for per-tab page loads.
        lastQuery = query
        lastCategoryIds = categoryIds
        lastSubCategoryIds = subCategoryIds
        lastFilters = filters

        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            shows = []; products = []; users = []
            showsTotal = 0; productsTotal = 0; usersTotal = 0
            showsLastPage = 1; productsLastPage = 1; usersLastPage = 1
            showsPage = 1; productsPage = 1; usersPage = 1
            return
        }
        Task {
            await performSearch(query: query, page: 1, tab: nil,
                                categoryIds: categoryIds,
                                subCategoryIds: subCategoryIds,
                                filters: filters)
        }
    }

    // MARK: - Per-tab page load (only updates the requested tab)

    /// Load a specific page for a single tab. The other two tabs are unaffected —
    /// their arrays, page counters, and last-page values remain as-is.
    /// This is the core Android-parity behaviour Trey asked for in QA build 360.
    func loadPage(tab: SearchTab, page: Int) {
        guard !lastQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task {
            await performSearch(query: lastQuery, page: page, tab: tab,
                                categoryIds: lastCategoryIds,
                                subCategoryIds: lastSubCategoryIds,
                                filters: lastFilters)
        }
    }

    // MARK: - Internal

    private func performSearch(query: String, page: Int, tab: SearchTab?,
                               categoryIds: [Int]?,
                               subCategoryIds: [Int]?,
                               filters: BrowseFilters?) async {
        isLoading = true
        errorMessage = nil
        do {
            var searchRequest = UnifiedSearchRequest(search: query, page: String(page))
            searchRequest.category_ids     = categoryIds?.isEmpty == false ? categoryIds : nil
            searchRequest.sub_category_ids = subCategoryIds?.isEmpty == false ? subCategoryIds : nil

            // Basecamp #9933301500 (2026-05-29): wire the full filter set.
            // Trey QA 2026-05-31: prefer multiselect `tags` array; fall back to
            // legacy single `tag` string for backward compat with the old filter path.
            if let f = filters {
                searchRequest.show_format  = f.showFormat
                if !f.tags.isEmpty {
                    // Multiselect path (new, matches Android chip behavior)
                    searchRequest.tags = f.tags
                    searchRequest.tag  = nil
                } else {
                    // Legacy single-tag path
                    let trimmedTag = f.tag.trimmingCharacters(in: .whitespacesAndNewlines)
                    searchRequest.tag  = trimmedTag.isEmpty ? nil : trimmedTag
                    searchRequest.tags = nil
                }
                searchRequest.shipping     = f.shipping
                searchRequest.premier_shop = f.premierShop ? true : nil
                searchRequest.ship_country = f.shipCountry
                let trimmedState = f.shipState.trimmingCharacters(in: .whitespacesAndNewlines)
                searchRequest.ship_state   = trimmedState.isEmpty ? nil : trimmedState
            }

            let response: UnifiedSearchResponse = try await APIManager.shared.request(
                type: APIEndPoint.unifiedSearch(param: searchRequest),
                header: true
            )

            let newPagination = response.data?.pagination
            pagination = newPagination

            if let tab = tab {
                // Per-tab load: ONLY update the requested tab. Other tabs keep
                // their existing arrays, page numbers, and last-page values.
                switch tab {
                case .shows:
                    shows        = response.data?.shows ?? []
                    showsPage    = page
                    showsLastPage = max(1, newPagination?.shows.lastPage ?? showsLastPage)
                    // Total doesn't change between pages — update defensively.
                    if let t = newPagination?.shows.total { showsTotal = t }
                case .products:
                    products        = response.data?.products ?? []
                    productsPage    = page
                    productsLastPage = max(1, newPagination?.products.lastPage ?? productsLastPage)
                    if let t = newPagination?.products.total { productsTotal = t }
                case .users:
                    users        = response.data?.users ?? []
                    usersPage    = page
                    usersLastPage = max(1, newPagination?.users.lastPage ?? usersLastPage)
                    if let t = newPagination?.users.total { usersTotal = t }
                }
            } else {
                // Full search: reset all tabs to page 1 with fresh data.
                shows    = response.data?.shows    ?? []
                products = response.data?.products ?? []
                users    = response.data?.users    ?? []
                showsPage = 1; productsPage = 1; usersPage = 1
                showsLastPage    = max(1, newPagination?.shows.lastPage    ?? 1)
                productsLastPage = max(1, newPagination?.products.lastPage ?? 1)
                usersLastPage    = max(1, newPagination?.users.lastPage    ?? 1)
                showsTotal    = newPagination?.shows.total    ?? 0
                productsTotal = newPagination?.products.total ?? 0
                usersTotal    = newPagination?.users.total    ?? 0
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
