//
//  OrderListViewController.swift
//  BidCast — iOS parity Phase 3a (2026-04-22)
//

import UIKit
import SVProgressHUD

final class OrderListViewController: P3ListViewController {

    private let vm: OrderListViewModel
    private let segmented: UISegmentedControl

    /// status key in same position as `segmented` segments.
    /// Index 0 = "" (all)
    private let statusFilters: [String?] = [nil, "new", "processing", "shipped", "delivered"]
    private let statusLabels:  [String]  = ["All", "New", "Processing", "Shipped", "Delivered"]

    init(kind: OrderListKind = .myOrders) {
        self.vm = OrderListViewModel(kind: kind)
        self.segmented = UISegmentedControl(items: statusLabels)
        super.init(nibName: nil, bundle: nil)
        self.title = (kind == .myOrders) ? "My Orders" : "My Purchases"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Segmented filter at top
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        let headerWrap = UIView()
        headerWrap.translatesAutoresizingMaskIntoConstraints = false
        headerWrap.addSubview(segmented)
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: headerWrap.topAnchor, constant: 12),
            segmented.leadingAnchor.constraint(equalTo: headerWrap.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: headerWrap.trailingAnchor, constant: -16),
            segmented.bottomAnchor.constraint(equalTo: headerWrap.bottomAnchor, constant: -8)
        ])
        headerWrap.frame.size = CGSize(width: view.bounds.width, height: 52)
        tableView.tableHeaderView = headerWrap

        tableView.register(OrderCell.self, forCellReuseIdentifier: OrderCell.reuseID)

        emptyState.update(title: "No orders yet",
                          message: "When you buy something, it will show up here.")

        vm.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.emptyStateIsVisible = self.vm.orders.isEmpty
            self.stopRefresh()
        }
        vm.onError = { [weak self] msg in
            SVProgressHUD.dismiss()
            self?.stopRefresh()
            self?.p3Alert(message: msg)
        }
        vm.onLoadingChange = { loading in
            if loading { SVProgressHUD.show() } else { SVProgressHUD.dismiss() }
        }

        vm.loadInitial()
    }

    override func reloadData() { vm.loadInitial() }

    @objc private func statusChanged() {
        let idx = segmented.selectedSegmentIndex
        let status = statusFilters[idx]
        vm.setStatusFilter(status)
    }

    // MARK: - Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderCell.reuseID, for: indexPath) as! OrderCell
        cell.configure(with: vm.orders[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = vm.orders[indexPath.row]
        let detail = OrderDetailViewController(order: order)
        p3Push(detail)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= vm.orders.count - 3 {
            vm.loadNext()
        }
    }
}
