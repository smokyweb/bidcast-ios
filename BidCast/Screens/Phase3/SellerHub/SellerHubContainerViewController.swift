//
//  SellerHubContainerViewController.swift
//  BidCast — iOS parity Phase 3d (2026-04-22)
//
//  Top-level Seller Hub. Loads GET /api/seller-hub-info to populate KPI
//  tiles, and exposes nav tiles to each sub-section: Inventory, Orders,
//  Offers, Analytics, Seller Status, Shipping (Phase 4), Wallet/Payout/
//  Tips/KYC (all Phase 4 payments). Mirrors Android's `SellerHubFragment`.
//

import UIKit
import SVProgressHUD

final class SellerHubContainerViewController: UIViewController {

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

    private var hubData: SellerHubData?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Seller Hub"
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
        load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Re-render tiles in case sub-screen changed inventory count etc.
        load()
    }

    private func load() {
        Task { @MainActor in
            do {
                let resp: SellerHubResponse = try await APIManager.shared.request(
                    type: .getSellerHubInfo, header: true
                )
                self.hubData = resp.data
                self.render()
            } catch {
                // Non-fatal — show the placeholder tiles + nav so the user can
                // still explore sub-sections.
                self.hubData = nil
                self.render()
            }
        }
    }

    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(kpiRow())
        stack.addArrangedSubview(accountHealthCard())
        stack.addArrangedSubview(tilesSection(title: "Selling", tiles: sellingTiles()))
        stack.addArrangedSubview(tilesSection(title: "Finance (Phase 4)", tiles: financeTiles()))
        stack.addArrangedSubview(tilesSection(title: "Growth", tiles: growthTiles()))
    }

    // MARK: - KPI row

    private func kpiRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        row.addArrangedSubview(kpiTile(title: "Items", value: hubData?.items.map(String.init) ?? "—"))
        row.addArrangedSubview(kpiTile(title: "Orders", value: hubData?.totalOrders.map(String.init) ?? "—"))
        row.addArrangedSubview(kpiTile(title: "Revenue", value: P3Format.currency(hubData?.revenue)))
        return row
    }

    private func kpiTile(title: String, value: String) -> UIView {
        let c = UIStackView()
        c.axis = .vertical
        c.alignment = .leading
        c.backgroundColor = .secondarySystemGroupedBackground
        c.layer.cornerRadius = 10
        c.isLayoutMarginsRelativeArrangement = true
        c.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        let v = UILabel()
        v.text = value; v.font = .systemFont(ofSize: 22, weight: .bold); v.textColor = .label
        let t = UILabel()
        t.text = title; t.font = .systemFont(ofSize: 12); t.textColor = .secondaryLabel
        c.addArrangedSubview(v)
        c.addArrangedSubview(t)
        return c
    }

    // MARK: - Account health

    private func accountHealthCard() -> UIView {
        let c = UIStackView()
        c.axis = .vertical
        c.spacing = 6
        c.backgroundColor = .secondarySystemGroupedBackground
        c.layer.cornerRadius = 10
        c.isLayoutMarginsRelativeArrangement = true
        c.layoutMargins = .init(top: 14, left: 14, bottom: 14, right: 14)

        let t = UILabel()
        t.text = "Account Health"
        t.font = .systemFont(ofSize: 14, weight: .semibold)
        c.addArrangedSubview(t)

        let h = hubData?.accountHealth
        c.addArrangedSubview(kv("Defect-free orders", h?.defectFreeOrderRate ?? "—"))
        c.addArrangedSubview(kv("On-time scan rate", h?.onTimeScanRate ?? "—"))
        c.addArrangedSubview(kv("Policy standing", h?.policyStanding ?? "—"))
        return c
    }

    private func kv(_ key: String, _ value: String) -> UIView {
        let r = UIStackView()
        r.axis = .horizontal
        let k = UILabel(); k.text = key; k.font = .systemFont(ofSize: 13); k.textColor = .secondaryLabel
        let v = UILabel(); v.text = value; v.font = .systemFont(ofSize: 13, weight: .semibold); v.textAlignment = .right
        r.addArrangedSubview(k); r.addArrangedSubview(v)
        return r
    }

    // MARK: - Tiles

    private struct Tile {
        let title: String
        let icon: String
        let phase4: Bool
        let build: () -> UIViewController
    }

    private func sellingTiles() -> [Tile] {
        [
            Tile(title: "Inventory", icon: "shippingbox", phase4: false,
                 build: { P3InventoryViewController() }),
            Tile(title: "Orders", icon: "bag", phase4: false,
                 build: { SellerOrdersViewController() }),
            Tile(title: "Offers", icon: "tag", phase4: false,
                 build: { SellerOffersViewController() }),
            Tile(title: "Shows", icon: "video", phase4: false,
                 build: { ScheduledShowsViewController() })
        ]
    }

    private func financeTiles() -> [Tile] {
        [
            Tile(title: "Wallet", icon: "wallet.pass", phase4: true,
                 build: { PhaseLockedViewController(title: "Wallet",
                     message: "Wallet & payouts arrive in Phase 4 (Payments).") }),
            Tile(title: "Payouts", icon: "creditcard", phase4: true,
                 build: { PhaseLockedViewController(title: "Payouts",
                     message: "Stripe payouts land in Phase 4.") }),
            Tile(title: "Tips", icon: "dollarsign.circle", phase4: true,
                 build: { PhaseLockedViewController(title: "Tips",
                     message: "In-stream tipping is Phase 4 + live-stream.") }),
            Tile(title: "KYC", icon: "person.badge.shield.checkmark", phase4: true,
                 build: { PhaseLockedViewController(title: "KYC / Seller verification",
                     message: "Stripe Identity onboarding lands in Phase 4.") })
        ]
    }

    private func growthTiles() -> [Tile] {
        [
            Tile(title: "Analytics", icon: "chart.bar", phase4: false,
                 build: { P3AnalyticsViewController() }),
            Tile(title: "Seller Status", icon: "checkmark.seal", phase4: false,
                 build: { P3SellerStatusViewController() })
        ]
    }

    private func tilesSection(title: String, tiles: [Tile]) -> UIView {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10

        let head = UILabel()
        head.text = title
        head.font = .systemFont(ofSize: 14, weight: .semibold)
        head.textColor = .secondaryLabel
        s.addArrangedSubview(head)

        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 10

        let columns = 2
        var row: UIStackView? = nil
        for (i, t) in tiles.enumerated() {
            if i % columns == 0 {
                row = UIStackView()
                row?.axis = .horizontal
                row?.distribution = .fillEqually
                row?.spacing = 10
                grid.addArrangedSubview(row!)
            }
            row?.addArrangedSubview(tileButton(t))
        }
        if let r = row, r.arrangedSubviews.count == 1 {
            r.addArrangedSubview(UIView())
        }
        s.addArrangedSubview(grid)
        return s
    }

    private func tileButton(_ t: Tile) -> UIView {
        let btn = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.baseBackgroundColor = .secondarySystemGroupedBackground
        cfg.baseForegroundColor = .label
        cfg.cornerStyle = .medium
        cfg.image = UIImage(systemName: t.icon)?.withRenderingMode(.alwaysTemplate)
        cfg.imagePlacement = .top
        cfg.imagePadding = 8
        cfg.title = t.title
        cfg.subtitle = t.phase4 ? "Phase 4" : nil
        btn.configuration = cfg
        btn.contentHorizontalAlignment = .center
        btn.heightAnchor.constraint(equalToConstant: 92).isActive = true
        btn.addAction(UIAction { [weak self] _ in
            let vc = t.build()
            self?.p3Push(vc)
        }, for: .touchUpInside)
        return btn
    }
}

// MARK: - Helper for Phase-4 locked tiles (wallet/payouts/tips/KYC)

final class PhaseLockedViewController: UIViewController {
    private let msg: String
    init(title: String, message: String) {
        self.msg = message
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let empty = P3EmptyStateView(icon: UIImage(systemName: "lock.fill"),
                                     title: "Coming in Phase 4",
                                     message: msg)
        empty.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(empty)
        NSLayoutConstraint.activate([
            empty.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            empty.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            empty.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            empty.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
