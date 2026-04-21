//
//  ExploreViewModel.swift
//  BidCast
//
//  Created by Trey Difficult Task Agent on 2026-04-21.
//
//  Drives the Explore tab. Two loaders: categories (`api/get-category`) and
//  products (`api/v1/get-product`). Both endpoints and payload shapes mirror
//  what the Android app already consumes.
//

import Foundation

protocol ExploreViewModelDelegate: AnyObject {
    func exploreDidUpdateCategories()
    func exploreDidUpdateProducts()
    func exploreDidFail(error: String)
    func exploreDidStartLoading()
    func exploreDidStopLoading()
}

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
    private var isFetchingProducts = false

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
        self.filter.page = 1
        fetchProducts(reset: true)
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

    @MainActor
    private func fetchCategories() {
        Task {
            do {
                let resp: GetCategoryResponse = try await APIManager.shared.request(
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

    @MainActor
    private func fetchProducts(reset: Bool) {
        guard !isFetchingProducts else { return }
        isFetchingProducts = true
        if reset {
            self.products = []
            self.currentPage = 1
            self.filter.page = 1
        }
        self.delegate?.exploreDidStartLoading()

        Task {
            defer {
                isFetchingProducts = false
                self.delegate?.exploreDidStopLoading()
            }
            do {
                let resp: GetProductsResponse = try await APIManager.shared.postMultipartForm(
                    type: APIEndPoint.getProducts,
                    fields: filter.formFields(),
                    header: true
                )
                let newItems = resp.data ?? []
                if reset {
                    self.products = newItems
                } else {
                    self.products.append(contentsOf: newItems)
                }
                self.currentPage = resp.currentPage ?? filter.page
                self.totalPages = resp.totalPage ?? self.currentPage
                self.delegate?.exploreDidUpdateProducts()
            } catch {
                let message: String
                if let dataError = error as? DataError {
                    message = dataError.getErrorMessage()
                } else {
                    message = error.localizedDescription
                }
                self.delegate?.exploreDidFail(error: message)
            }
        }
    }
}
