//
//  ExploreViewModel.swift
//  BidCast
//
//  Created by Trey Difficult Task Agent on 2026-04-21.
//  Fixed 2026-05-13: crash on auction search (iOS_V2).
//
//  Drives the Explore tab. Two loaders: categories (`api/get-category`) and
//  products (`api/v1/get-product`). Both endpoints and payload shapes mirror
//  what the Android app already consumes.
//
//  CRASH FIX (cmp3q3ilb00814axyrxdg91de):
//  ----------------------------------------
//  Root cause: `fetchProducts(reset:)` set `self.products = []` synchronously
//  then dispatched a Task. If the user typed quickly in the search bar,
//  a second `setSearch` call arrived while `isFetchingProducts == true` and
//  was silently dropped — leaving the UI stuck on an empty/stale product list.
//  Worse, when the in-flight Task completed it would call
//  `exploreDidUpdateProducts()` with results from the *previous* query,
//  overwriting the pending search state and causing an
//  index-out-of-bounds crash in UICollectionView (`cellForItemAt` received
//  an indexPath whose item no longer existed in the freshly-reset array).
//
//  Fix: introduce a per-fetch `requestGeneration` counter. Each Task
//  captures the generation at launch; it discards its results if a newer
//  fetch has superseded it. `isFetchingProducts` is replaced by a nullable
//  `currentTask` so in-flight requests are cancelled before a reset fetch
//  starts — eliminating the stale-callback race entirely.
//

import Foundation

protocol ExploreViewModelDelegate: AnyObject {
    func exploreDidUpdateCategories()
    func exploreDidUpdateProducts()
    func exploreDidFail(error: String)
    func exploreDidStartLoading()
    func exploreDidStopLoading()
}

@MainActor
final class ExploreViewModel {

    weak var delegate: ExploreViewModelDelegate?

    private(set) var categories: [CategoryModel] = []
    private(set) var products: [ProductModel] = []

    /// Current filter. Mutated by the filter sheet, then `applyFilter(_:)` is
    /// called to trigger a fresh product fetch.
    private(set) var filter: ProductFilter = .empty

    /// Pagination book-keeping
    private(set) var currentPage: Int = 1
    private(set) var totalPages: Int = 1
    var canLoadMore: Bool { currentPage < totalPages }

    // MARK: - Fetch-generation tracking (crash fix)
    //
    // Each call to fetchProducts increments `fetchGeneration`. The spawned
    // Task captures the generation at launch and checks it before mutating
    // `products` or calling delegate methods. Stale Tasks (superseded by a
    // newer search/filter) are silently discarded, preventing the
    // index-out-of-bounds crash caused by a stale callback overwriting a
    // freshly-reset product array mid-UICollectionView-layout.
    private var fetchGeneration: Int = 0
    private var currentFetchTask: Task<Void, Never>? = nil
    // Keep for external canLoadMore guard compat.
    private var isFetchingProducts: Bool { currentFetchTask != nil }

    // MARK: - Public API

    func loadInitial() {
        fetchCategories()
        fetchProducts(reset: true)
    }

    func applyFilter(_ newFilter: ProductFilter) {
        var f = newFilter
        f.page = 1
        self.filter = f
        fetchProducts(reset: true)
    }

    func resetFilter() {
        self.filter = .empty
        fetchProducts(reset: true)
    }

    func setSelectedCategory(_ categoryID: Int?) {
        self.filter.categoryID = categoryID
        // Tapping a different top-level category clears the sub-category.
        self.filter.subCategoryID = nil
        self.filter.page = 1
        fetchProducts(reset: true)
    }

    /// P2.15 — drill into a sub-category under the currently-selected
    /// category. Pass `nil` to clear the sub-filter (back to "All
    /// <category>").
    func setSelectedSubcategory(_ subcategoryID: Int?) {
        self.filter.subCategoryID = subcategoryID
        self.filter.page = 1
        fetchProducts(reset: true)
    }

    /// P2.15 — switch the explore type tab (All / Recommended / Popular).
    /// Mirrors Android's ExploreTypeFragment behaviour of reloading the
    /// product grid without changing the currently-selected category.
    func setExploreType(_ type: ExploreType) {
        guard self.filter.exploreType != type else { return }
        self.filter.exploreType = type
        self.filter.page = 1
        fetchProducts(reset: true)
    }

    /// P2.15 — async fetch of sub-categories for the category picker sheet.
    /// Returns an empty list on any transport/decoding error so the sheet
    /// can show "no sub-categories".
    func fetchSubcategories(categoryID: Int) async -> [SubCategory] {
        do {
            let req = GetSubCategoriesRequest(categoryIds: [categoryID], subcategoryIds: nil)
            let resp: GetSubCategoriesResponse = try await APIManager.shared.postMultipartForm(
                type: .getSubCategories(param: req),
                fields: ["category_ids": "\(categoryID)"],
                header: true
            )
            return resp.data?.flatMap { $0.subcategories ?? [] } ?? []
        } catch {
            debugLog("Explore: getSubCategories failed -> \(error.localizedDescription)")
            return []
        }
    }

    func setSearch(_ query: String) {
        self.filter.search = query
        self.filter.page = 1
        fetchProducts(reset: true)
    }

    func loadNextPageIfPossible() {
        guard canLoadMore, !isFetchingProducts else { return }
        self.filter.page = currentPage + 1
        fetchProducts(reset: false)
    }

    // MARK: - Categories

    private func fetchCategories() {
        Task {
            do {
                let resp: ExploreGetCategoryResponse = try await APIManager.shared.request(
                    type: APIEndPoint.getCategory,
                    header: true
                )
                self.categories = resp.data ?? []
                self.delegate?.exploreDidUpdateCategories()
            } catch {
                // Categories are a soft failure — show empty rail and keep going.
                debugLog("Explore: getCategory failed -> \(error.localizedDescription)")
                self.categories = []
                self.delegate?.exploreDidUpdateCategories()
            }
        }
    }

    // MARK: - Products

    private func fetchProducts(reset: Bool) {
        if reset {
            // Cancel any in-flight fetch — its results are now stale.
            currentFetchTask?.cancel()
            currentFetchTask = nil
            self.products = []
            self.currentPage = 1
            self.filter.page = 1
        } else {
            // Pagination append: don't start if already fetching.
            guard currentFetchTask == nil else { return }
        }

        fetchGeneration &+= 1
        let myGeneration = fetchGeneration
        let fieldsSnapshot = filter.formFields()
        let isReset = reset

        self.delegate?.exploreDidStartLoading()

        let task = Task { [weak self] in
            guard let self = self else { return }
            defer {
                // Only clear the task handle if we're still the current fetch.
                if self.fetchGeneration == myGeneration {
                    self.currentFetchTask = nil
                    self.delegate?.exploreDidStopLoading()
                }
            }
            do {
                let resp: ExploreGetProductsResponse = try await APIManager.shared.postMultipartForm(
                    type: APIEndPoint.getProducts,
                    fields: fieldsSnapshot,
                    header: true
                )
                // Discard results if a newer fetch has already started.
                guard self.fetchGeneration == myGeneration else { return }
                let newItems = resp.data ?? []
                if isReset {
                    self.products = newItems
                } else {
                    self.products.append(contentsOf: newItems)
                }
                self.currentPage = resp.currentPage ?? self.filter.page
                self.totalPages = resp.totalPage ?? self.currentPage
                self.delegate?.exploreDidUpdateProducts()
            } catch {
                guard self.fetchGeneration == myGeneration else { return }
                if Task.isCancelled { return }
                let message: String
                if let dataError = error as? DataError {
                    message = dataError.getErrorMessage()
                } else {
                    message = error.localizedDescription
                }
                self.delegate?.exploreDidFail(error: message)
            }
        }
        currentFetchTask = task
    }
}
