//
//  AccountViewController+JobA.swift
//  BidCast — iOS parity Job A (App-flow wiring, 2026-04-22)
//
//  The stock Account tab (BidCast/Screens/Main/Account/AccountViewController.swift)
//  has a segmented "Seller Hub / Account" table driven by `AccountSection`
//  enum, `moreSection` strings, and hard-coded index-based `didTap(index:)`
//  routes. Phase 3/4 introduced a lot of new feature VCs that the stock
//  table never linked to:
//
//    - Wallet (Phase 4b)                → WalletViewController
//    - Payment Methods (Phase 4c)       → PaymentMethodsListViewController
//    - KYC / Verification (Phase 4d)    → KYCViewController
//    - Notification settings (Phase 3b) → NotificationSettingsViewController
//    - Preferences hub (Phase 3h)       → PreferencesViewController
//    - Affiliate / Refer (Phase 3f)     → AffiliateViewController
//    - Followers / Following (Phase 3f) → FollowersListViewController
//    - Tutorials / Help (Phase 3h)      → TutorialsListViewController
//    - Raise ticket (Phase 3a)          → RaiseTicketViewController
//    - Coupons (Phase 3e)               → CouponsViewController
//    - Subscriptions (Phase 4i stub)    → SubscriptionPlansViewController
//
//  Approach: keep the existing AccountViewController table layout untouched
//  (so storyboard bindings still work), but attach a persistent "Quick
//  actions" card at the top of its view via a swizzle on viewWillAppear.
//  The card is a UITableView of its own that links every Phase 3/4 VC
//  above; tapping any row pushes onto the existing nav controller (or
//  wraps in a new nav if there's no ambient nav).
//
//  This approach avoids renaming / restructuring the stock cells/outlets.
//

import UIKit

final class JobAAccountMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private struct Row {
        let title: String
        let icon: String
        let make: () -> UIViewController
    }
    private struct Section {
        let title: String
        let rows: [Row]
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private lazy var sections: [Section] = [
        Section(title: "Payments", rows: [
            Row(title: "My Wallet", icon: "wallet.pass",
                make: { WalletViewController() }),
            Row(title: "Payment Methods", icon: "creditcard",
                make: { PaymentMethodsListViewController() }),
            Row(title: "KYC / Verification", icon: "person.badge.shield.checkmark",
                make: { KYCViewController() }),
            Row(title: "Subscriptions", icon: "crown",
                make: { SubscriptionPlansViewController() })
        ]),
        Section(title: "Community", rows: [
            Row(title: "Followers / Following", icon: "person.2",
                make: { FollowersListViewController(userId: UserDefaults.loggedInUserId, kind: .followers) }),
            Row(title: "Affiliate Program", icon: "gift",
                make: { AffiliateViewController() }),
            Row(title: "Find people", icon: "magnifyingglass",
                make: { UserSearchViewController() }),
            Row(title: "Coupons", icon: "ticket",
                make: { CouponsViewController() }),
            Row(title: "Blocked users", icon: "person.slash",
                make: { BlockedUsersViewController() })
        ]),
        Section(title: "Notifications", rows: [
            Row(title: "Notifications", icon: "bell",
                make: { NotificationListViewController() }),
            Row(title: "Notification Settings", icon: "slider.horizontal.3",
                make: { NotificationSettingsViewController() })
        ]),
        Section(title: "Help & Support", rows: [
            Row(title: "Preferences", icon: "gearshape",
                make: { PreferencesViewController() }),
            Row(title: "Tutorials", icon: "book",
                make: { TutorialsListViewController() }),
            Row(title: "Raise a support ticket", icon: "lifepreserver",
                make: { RaiseTicketViewController() })
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Account"
        view.backgroundColor = .systemGroupedBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ja")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // UITableViewDataSource / Delegate

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ja", for: indexPath)
        let row = sections[indexPath.section].rows[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = row.title
        cfg.image = UIImage(systemName: row.icon)
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = sections[indexPath.section].rows[indexPath.row].make()
        p3Push(vc)
    }
}

// MARK: - Swizzle: inject a "Phase 3/4 Quick Actions" navbar button

extension AccountViewController {

    private static var jobAButtonKey: UInt8 = 0
    private var jobAButtonInstalled: Bool {
        get { (objc_getAssociatedObject(self, &Self.jobAButtonKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &Self.jobAButtonKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    @objc public func jobAInstallMenuButtonIfNeeded() {
        guard !jobAButtonInstalled else { return }
        jobAButtonInstalled = true

        // Attach a floating "More options" button to the view so the Phase 3/4
        // menu is always one tap away, no matter which segment of the stock
        // Account table the user is on. We don't touch navigationItem because
        // the stock Account tab already hides the nav bar.
        let btn = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.image = UIImage(systemName: "ellipsis.circle.fill")
        cfg.baseBackgroundColor = .systemBlue
        cfg.baseForegroundColor = .white
        cfg.cornerStyle = .capsule
        cfg.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        btn.configuration = cfg
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(jobAOpenQuickActions), for: .touchUpInside)
        btn.accessibilityLabel = "More options"
        view.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            btn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            btn.widthAnchor.constraint(equalToConstant: 52),
            btn.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func jobAOpenQuickActions() {
        let menu = JobAAccountMenuViewController()
        let nav = UINavigationController(rootViewController: menu)
        menu.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close, primaryAction: UIAction { [weak nav] _ in
                nav?.dismiss(animated: true)
            })
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

enum JobAAccountSwizzle {
    private static var installed = false
    static func installIfNeeded() {
        guard !installed else { return }
        installed = true
        let cls: AnyClass = AccountViewController.self
        let originalSel = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSel = #selector(AccountViewController.jobA_viewDidAppear(_:))
        guard
            let original = class_getInstanceMethod(cls, originalSel),
            let swizzled = class_getInstanceMethod(cls, swizzledSel)
        else { return }

        let didAdd = class_addMethod(
            cls,
            originalSel,
            method_getImplementation(swizzled),
            method_getTypeEncoding(swizzled)
        )
        if didAdd {
            class_replaceMethod(
                cls,
                swizzledSel,
                method_getImplementation(original),
                method_getTypeEncoding(original)
            )
        } else {
            method_exchangeImplementations(original, swizzled)
        }
    }
}

extension AccountViewController {
    @objc func jobA_viewDidAppear(_ animated: Bool) {
        self.jobA_viewDidAppear(animated)   // real viewDidAppear after IMP swap
        self.jobAInstallMenuButtonIfNeeded()
    }
}
