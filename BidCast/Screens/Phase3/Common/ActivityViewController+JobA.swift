//
//  ActivityViewController+JobA.swift
//  BidCast — iOS parity Job A (App-flow wiring, 2026-04-22)
//
//  The stock Activity tab (BidCast/Screens/Main/Activity/ActivityViewController.swift)
//  renders entirely-static mock cells. For Job A we replace its visible
//  content with a real "Activity hub" that surfaces the live Phase 3
//  features a buyer / viewer needs:
//
//      segment 0 — Orders        -> OrderListViewController   (Phase 3a)
//      segment 1 — Messages      -> ConversationListViewController (Phase 3c)
//      segment 2 — Notifications -> NotificationListViewController  (Phase 3b)
//
//  Same strategy as P3SellSwizzle: we swizzle viewWillAppear(_:) so the
//  existing storyboard stub keeps working, but the first time it appears
//  we wipe its placeholder subviews and embed a UIPageViewController-like
//  container that hosts the three Phase 3 list VCs behind a segmented
//  control. This avoids a storyboard rewrite and keeps the existing
//  TabBarViewController routing untouched.
//

import UIKit

// MARK: - Activity hub container

final class JobAActivityHubViewController: UIViewController {

    private let segmented: UISegmentedControl = {
        let s = UISegmentedControl(items: ["Orders", "Messages", "Notifications"])
        s.selectedSegmentIndex = 0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let container = UIView()
    private var current: UIViewController?

    private lazy var orders = OrderListViewController()
    private lazy var messages = ConversationListViewController()
    private lazy var notifs = NotificationListViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Activity"
        view.backgroundColor = .systemBackground

        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmented)
        view.addSubview(container)
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        // Nav-bar: Preferences in the top-right so users can reach the
        // Phase 3 Preferences hub from Activity in one tap (it also
        // lives on Account; Activity gives a second entry).
        let prefs = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            style: .plain, target: self, action: #selector(openPreferences)
        )
        navigationItem.rightBarButtonItem = prefs

        show(orders)
    }

    @objc private func segmentChanged() {
        switch segmented.selectedSegmentIndex {
        case 0: show(orders)
        case 1: show(messages)
        case 2: show(notifs)
        default: break
        }
    }

    @objc private func openPreferences() {
        p3Push(PreferencesViewController())
    }

    private func show(_ vc: UIViewController) {
        if let c = current {
            c.willMove(toParent: nil)
            c.view.removeFromSuperview()
            c.removeFromParent()
        }
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: container.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        vc.didMove(toParent: self)
        current = vc
    }

    /// Entry point for DeepLinkRouter — pick a segment programmatically.
    func selectTab(_ index: Int) {
        guard (0...2).contains(index) else { return }
        segmented.selectedSegmentIndex = index
        segmentChanged()
    }
}

// MARK: - Swizzle on ActivityViewController

extension ActivityViewController {

    private static var jobAEmbedKey: UInt8 = 0

    private var jobAHasEmbedded: Bool {
        get { (objc_getAssociatedObject(self, &Self.jobAEmbedKey) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &Self.jobAEmbedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    @objc public func jobAEmbedActivityHubIfNeeded() {
        guard !jobAHasEmbedded else { return }
        jobAHasEmbedded = true

        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .systemGroupedBackground

        let hub = JobAActivityHubViewController()
        let nav = UINavigationController(rootViewController: hub)
        addChild(nav)
        nav.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nav.view)
        NSLayoutConstraint.activate([
            nav.view.topAnchor.constraint(equalTo: view.topAnchor),
            nav.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nav.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        nav.didMove(toParent: self)
    }
}

enum JobAActivitySwizzle {
    private static var installed = false
    static func installIfNeeded() {
        guard !installed else { return }
        installed = true
        let cls: AnyClass = ActivityViewController.self
        let originalSel = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSel = #selector(ActivityViewController.jobA_viewWillAppear(_:))
        guard
            let original = class_getInstanceMethod(cls, originalSel),
            let swizzled = class_getInstanceMethod(cls, swizzledSel)
        else { return }
        method_exchangeImplementations(original, swizzled)
    }
}

extension ActivityViewController {
    @objc func jobA_viewWillAppear(_ animated: Bool) {
        // After IMP swap this calls the real viewWillAppear implementation.
        self.jobA_viewWillAppear(animated)
        self.jobAEmbedActivityHubIfNeeded()
    }
}
