//
//  AnalyticsViewController.swift
//  BidCast — iOS parity Phase 3d (2026-04-22)
//
//  GET /api/seller-analytic returns headline KPIs + top buyers.
//  This screen renders the KPI tiles and buyer list. Charts (line/bar)
//  are Phase 4 (Swift Charts dependency).
//

import UIKit
import SVProgressHUD

final class P3AnalyticsViewController: UIViewController, UITableViewDataSource {

    private let scroll = UIScrollView()
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return s
    }()
    private let topBuyersTable = UITableView(frame: .zero, style: .grouped)
    private var topBuyers: [AnalyticsTopBuyer] = []
    private var data: SellerAnalyticsData?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
        view.backgroundColor = .systemGroupedBackground

        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        topBuyersTable.dataSource = self
        topBuyersTable.register(UITableViewCell.self, forCellReuseIdentifier: "buyer")
        topBuyersTable.isScrollEnabled = false
        topBuyersTable.backgroundColor = .clear

        load()
    }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let resp: SellerAnalyticsResponse = try await APIManager.shared.request(
                    type: .getSellerAnalytics, header: true
                )
                self.data = resp.data
                let buyers = (resp.data?.topBuyersByOrders ?? resp.data?.topBuyersBySales) ?? []
                self.topBuyers = buyers.compactMap { $0 }
                self.render()
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let stats = data?.stats else {
            stack.addArrangedSubview(P3EmptyStateView(
                icon: UIImage(systemName: "chart.bar"),
                title: "No data yet",
                message: "Sell some items and analytics will appear here."))
            return
        }

        stack.addArrangedSubview(kpiRow([
            ("Total items", "\(stats.totalItems ?? 0)"),
            ("Revenue", P3Format.currency(stats.revenue)),
            ("Total sales", "\(stats.totalSales ?? 0)")
        ]))
        stack.addArrangedSubview(kpiRow([
            ("Followers", "\(stats.followers ?? 0)"),
            ("Live sessions", "\(stats.liveSessions ?? 0)"),
            ("Rating", "\(stats.rating ?? 0)")
        ]))

        stack.addArrangedSubview(sectionLabel("Top buyers"))
        let h: CGFloat = CGFloat(max(topBuyers.count, 0)) * 56 + 40
        topBuyersTable.heightAnchor.constraint(equalToConstant: max(160, h)).isActive = true
        stack.addArrangedSubview(topBuyersTable)
        topBuyersTable.reloadData()

        stack.addArrangedSubview(sectionLabel("Chart (Phase 4)"))
        let chartPlaceholder = UIView()
        chartPlaceholder.backgroundColor = .secondarySystemBackground
        chartPlaceholder.layer.cornerRadius = 10
        chartPlaceholder.heightAnchor.constraint(equalToConstant: 180).isActive = true
        let tip = UILabel()
        tip.text = "Sales + visitor charts land in Phase 4 with Swift Charts."
        tip.textAlignment = .center
        tip.font = .systemFont(ofSize: 13)
        tip.textColor = .secondaryLabel
        tip.numberOfLines = 0
        tip.translatesAutoresizingMaskIntoConstraints = false
        chartPlaceholder.addSubview(tip)
        NSLayoutConstraint.activate([
            tip.centerXAnchor.constraint(equalTo: chartPlaceholder.centerXAnchor),
            tip.centerYAnchor.constraint(equalTo: chartPlaceholder.centerYAnchor),
            tip.leadingAnchor.constraint(greaterThanOrEqualTo: chartPlaceholder.leadingAnchor, constant: 20),
            tip.trailingAnchor.constraint(lessThanOrEqualTo: chartPlaceholder.trailingAnchor, constant: -20)
        ])
        stack.addArrangedSubview(chartPlaceholder)
    }

    private func kpiRow(_ tiles: [(String, String)]) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 10
        for (title, value) in tiles {
            let t = UIStackView()
            t.axis = .vertical
            t.alignment = .leading
            t.backgroundColor = .secondarySystemGroupedBackground
            t.layer.cornerRadius = 10
            t.isLayoutMarginsRelativeArrangement = true
            t.layoutMargins = .init(top: 10, left: 12, bottom: 10, right: 12)
            let v = UILabel(); v.text = value; v.font = .systemFont(ofSize: 18, weight: .bold)
            let k = UILabel(); k.text = title; k.font = .systemFont(ofSize: 11); k.textColor = .secondaryLabel
            t.addArrangedSubview(v); t.addArrangedSubview(k)
            row.addArrangedSubview(t)
        }
        return row
    }

    private func sectionLabel(_ s: String) -> UILabel {
        let l = UILabel(); l.text = s
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }

    // MARK: - Top buyers table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(topBuyers.count, 1)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "buyer", for: indexPath)
        if topBuyers.isEmpty {
            var cfg = cell.defaultContentConfiguration()
            cfg.text = "No buyers yet"
            cfg.textProperties.color = .secondaryLabel
            cell.contentConfiguration = cfg
            return cell
        }
        let b = topBuyers[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = b.user?.name ?? b.user?.username ?? "Buyer"
        cfg.secondaryText = "Orders: \(b.totalOrders ?? 0)  •  \(P3Format.currency(b.totalSales))"
        cfg.image = UIImage(systemName: "person.crop.circle")
        cell.contentConfiguration = cfg
        return cell
    }
}
