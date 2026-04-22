//
//  P3SellHomeViewController.swift
//  BidCast — iOS parity Phase 3i (2026-04-22)
//
//  Landing screen for the Sell tab. The old Sell tab was a 29-line
//  Xcode-generated stub. This VC replaces it with a real hub that
//  routes to:
//    - Seller Hub (stats + all sub-sections)
//    - Scheduled Shows (create / edit)
//    - Inventory (add / edit products)
//    - Preferences
//
//  The existing TabBarViewController loads "Sell" from the `Sell`
//  storyboard via the SellViewController class; we leave that storyboard
//  in place and have AppDelegate / SceneDelegate inject this VC on first
//  tab selection via navigationController.setViewControllers.
//
//  Alternative wiring:
//    - Let TabBarViewController keep loading SellViewController, but
//      SellViewController's viewDidLoad pushes this hub programmatically.
//  We implement the alternative inside `SellViewController+Phase3.swift`
//  so this VC stays independently testable.
//

import UIKit

final class P3SellHomeViewController: UIViewController {

    private let scroll = UIScrollView()
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 14
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 20, left: 16, bottom: 20, right: 16)
        return s
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sell"
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

        render()
    }

    private func render() {
        stack.addArrangedSubview(head("Sell on Bidcast"))
        stack.addArrangedSubview(body("Host live shows, list products, track orders."))

        stack.addArrangedSubview(tile(
            icon: "storefront",
            title: "Seller Hub",
            subtitle: "KPIs, orders, offers, analytics, seller status"
        ) { [weak self] in
            self?.p3Push(SellerHubContainerViewController())
        })

        stack.addArrangedSubview(tile(
            icon: "video.badge.plus",
            title: "Schedule a show",
            subtitle: "Set a date, time, category, and share"
        ) { [weak self] in
            self?.p3Push(ScheduleShowEditorViewController(mode: .create))
        })

        stack.addArrangedSubview(tile(
            icon: "shippingbox",
            title: "Manage inventory",
            subtitle: "Add, edit, and delete products"
        ) { [weak self] in
            self?.p3Push(P3InventoryViewController())
        })

        stack.addArrangedSubview(tile(
            icon: "rectangle.stack.badge.plus",
            title: "All my scheduled shows",
            subtitle: "Upcoming, past, and share links"
        ) { [weak self] in
            self?.p3Push(ScheduledShowsViewController())
        })

        stack.addArrangedSubview(tile(
            icon: "megaphone",
            title: "Promote a show",
            subtitle: "Boost reach with paid promotions (Phase 4 buy)"
        ) { [weak self] in
            self?.p3Push(PromoteToolsViewController())
        })

        stack.addArrangedSubview(tile(
            icon: "star.circle",
            title: "Premier Shop",
            subtitle: "Apply for Premier seller status"
        ) { [weak self] in
            self?.p3Push(PremierShopViewController())
        })

        // iOS parity Job A: Coupons entry from Sell tab (previously orphan).
        stack.addArrangedSubview(tile(
            icon: "ticket",
            title: "Coupons",
            subtitle: "Browse available discount codes"
        ) { [weak self] in
            self?.p3Push(CouponsViewController())
        })

        stack.addArrangedSubview(UIView())
    }

    private func head(_ s: String) -> UILabel {
        let l = UILabel(); l.text = s
        l.font = .systemFont(ofSize: 26, weight: .bold); l.numberOfLines = 0; return l
    }
    private func body(_ s: String) -> UILabel {
        let l = UILabel(); l.text = s
        l.font = .systemFont(ofSize: 14); l.textColor = .secondaryLabel; l.numberOfLines = 0; return l
    }

    private func tile(icon: String, title: String, subtitle: String,
                      action: @escaping () -> Void) -> UIView {
        let btn = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.baseBackgroundColor = .secondarySystemGroupedBackground
        cfg.baseForegroundColor = .label
        cfg.cornerStyle = .medium
        cfg.image = UIImage(systemName: icon)?.withRenderingMode(.alwaysTemplate)
        cfg.imagePadding = 12
        cfg.imagePlacement = .leading
        cfg.title = title
        cfg.subtitle = subtitle
        cfg.titleAlignment = .leading
        btn.configuration = cfg
        btn.contentHorizontalAlignment = .leading
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true
        btn.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return btn
    }
}
