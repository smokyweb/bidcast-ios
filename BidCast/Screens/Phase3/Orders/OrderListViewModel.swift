//
//  OrderListViewModel.swift
//  BidCast — iOS parity Phase 3a (2026-04-22)
//
//  Mirror of Android `OrderListingFragment` / `PurchasesFragment`.
//  Hits POST api/v1/get-my-orders (buyer) and POST api/v1/get-my-purchases-orders
//  (historical purchases by status).
//

import Foundation

enum OrderListKind {
    case myOrders           // Buyer — active orders
    case myPurchases        // Buyer — historical purchases
}

final class OrderListViewModel {

    // MARK: - Outputs
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    // MARK: - State
    private(set) var orders: [Order] = []
    private(set) var paging = P3Paging()
    let kind: OrderListKind
    private var statusFilter: String? = nil   // "new", "processing", "shipped", "delivered", etc.

    init(kind: OrderListKind = .myOrders) {
        self.kind = kind
    }

    // MARK: - Public API
    func setStatusFilter(_ status: String?) {
        statusFilter = status
        loadInitial()
    }

    func loadInitial() {
        orders = []
        paging.reset()
        paging.totalPages = 1
        onUpdate?()
        loadNext()
    }

    func loadNext() {
        guard !paging.isLoading, paging.hasMore else { return }
        paging.isLoading = true
        onLoadingChange?(true)

        var fields: [String: String] = [
            "page": "\(paging.page)"
        ]
        if let status = statusFilter, !status.isEmpty {
            fields["status"] = status
        }

        let endpoint: APIEndPoint
        switch kind {
        case .myOrders:
            endpoint = .getOrderListing(param: [:])
        case .myPurchases:
            endpoint = .getProductsByStatus(param: [:])
        }

        Task { @MainActor in
            defer {
                self.paging.isLoading = false
                self.onLoadingChange?(false)
            }
            do {
                let resp: GetOrdersResponse = try await APIManager.shared.postMultipartForm(
                    type: endpoint,
                    fields: fields,
                    header: true
                )
                let newItems = resp.data ?? []
                if self.paging.page == 1 {
                    self.orders = newItems
                } else {
                    self.orders.append(contentsOf: newItems)
                }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage,
                    totalPages: resp.totalPage
                ))
                self.onUpdate?()
            } catch let err as DataError {
                self.onError?(err.getErrorMessage())
            } catch {
                self.onError?(error.localizedDescription)
            }
        }
    }
}
