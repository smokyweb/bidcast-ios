//
//  OrderTrackingViewController.swift
//  BidCast — iOS parity Phase 3a (2026-04-22)
//
//  Renders the `ShippingTracking` vertical timeline pulled from Android's
//  `TrackingFragment`.
//

import UIKit

final class OrderTrackingViewController: UIViewController {

    private let tracking: [ShippingTracking]
    private let orderId: String
    private let tableView = UITableView(frame: .zero, style: .plain)

    init(tracking: [ShippingTracking], orderId: String) {
        self.tracking = tracking
        self.orderId = orderId
        super.init(nibName: nil, bundle: nil)
        self.title = "Tracking • \(orderId)"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "track")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        if tracking.isEmpty {
            let empty = P3EmptyStateView(icon: UIImage(systemName: "shippingbox"),
                                         title: "No tracking updates yet",
                                         message: "Once the seller ships, progress will appear here.")
            empty.frame = view.bounds
            empty.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(empty)
        }
    }
}

extension OrderTrackingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracking.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        let t = tracking[indexPath.row]
        cell.textLabel?.text = t.title ?? "—"
        cell.detailTextLabel?.text = P3Format.date(t.createdAt)
        var cfg = cell.defaultContentConfiguration()
        cfg.text = t.title ?? "—"
        cfg.secondaryText = P3Format.date(t.createdAt)
        cfg.image = UIImage(systemName: "checkmark.circle.fill")
        cfg.imageProperties.tintColor = .systemGreen
        cell.contentConfiguration = cfg
        return cell
    }
}
