//
//  SellerOrdersViewController.swift
//  BidCast — iOS parity Phase 3d (2026-04-22)
//
//  Seller-side orders list (POST api/v1/get-my-orders with seller-flag
//  backend convention). Reuses the GetOrdersResponse + Order models.
//  Backend treats the endpoint as dual-view based on role. Clicking a row
//  opens the OrderDetail + lets seller change status via
//  POST /api/change-order-status.
//

import UIKit
import SVProgressHUD

final class SellerOrdersViewController: P3ListViewController {

    private var orders: [Order] = []
    private var paging = P3Paging()
    private let segmented = UISegmentedControl(items: ["New", "Processing", "Shipped", "Delivered"])
    private let statuses = ["new", "processing", "shipped", "delivered"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Orders"

        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        let wrap = UIView()
        wrap.addSubview(segmented)
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 10),
            segmented.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -16),
            segmented.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -8)
        ])
        wrap.frame.size = .init(width: view.bounds.width, height: 48)
        tableView.tableHeaderView = wrap

        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseID)
        emptyState.update(title: "No orders",
                          message: "Orders placed against your listings show up here.")
        load(reset: true)
    }

    override func reloadData() { load(reset: true) }
    @objc private func statusChanged() { load(reset: true) }

    private func load(reset: Bool) {
        if reset { paging.reset(); orders = [] }
        guard !paging.isLoading, paging.hasMore else { return }
        paging.isLoading = true
        SVProgressHUD.show()
        Task { @MainActor in
            defer {
                self.paging.isLoading = false
                SVProgressHUD.dismiss()
                self.stopRefresh()
            }
            do {
                let fields = [
                    "page": "\(paging.page)",
                    "status": statuses[segmented.selectedSegmentIndex],
                    "is_seller": "1"
                ]
                let resp: GetOrdersResponse = try await APIManager.shared.postMultipartForm(
                    type: .getOrderListing(param: [:]),
                    fields: fields, header: true
                )
                let newItems = resp.data ?? []
                if reset { self.orders = newItems } else { self.orders.append(contentsOf: newItems) }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage, totalPages: resp.totalPage))
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.orders.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orders.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseID, for: indexPath) as! OrderCell
        cell.configure(with: orders[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = orders[indexPath.row]
        let detail = OrderDetailViewController(order: order)
        // Enrich nav bar with "Update status" action for sellers.
        detail.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Update",
            style: .plain,
            target: self,
            action: nil)
        p3Push(detail)
        // Extra: quick-update sheet while still on list.
        presentStatusSheet(for: order)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= orders.count - 3 { load(reset: false) }
    }

    private func presentStatusSheet(for order: Order) {
        guard let oid = order.id else { return }
        let sheet = UIAlertController(title: "Update order status", message: nil, preferredStyle: .actionSheet)
        for status in ["processing", "shipped", "delivered", "cancelled"] {
            sheet.addAction(UIAlertAction(title: status.capitalized, style: .default) { [weak self] _ in
                self?.changeStatus(orderId: oid, status: status)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // Present over the just-pushed detail VC — presentingViewController is self.
        present(sheet, animated: true)
    }

    private func changeStatus(orderId: Int, status: String) {
        Task { @MainActor in
            do {
                let fields = ["order_id": "\(orderId)", "status": status]
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .changeOrderStatus(param: [:]),
                    fields: fields, header: true
                )
                self.load(reset: true)
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }
}
