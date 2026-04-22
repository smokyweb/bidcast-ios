//
//  SubscriptionPlansViewController.swift
//  BidCast — iOS parity Phase 3e (2026-04-22)
//
//  Placeholder for Bidcast subscription plans (Premier/Pro). The Android
//  backend does not currently ship a `/api/get-subscription-plans`
//  endpoint — subscription upgrades flow through Premier Shop apply on
//  Android. This screen exists so the Shop tab has a complete surface;
//  once backend exposes a dedicated endpoint we wire the list here.
//

import UIKit

final class SubscriptionPlansViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Subscription Plans"
        view.backgroundColor = .systemBackground
        let empty = P3EmptyStateView(
            icon: UIImage(systemName: "star.circle"),
            title: "Premier Shop is the upgrade path",
            message: "Bidcast doesn't ship separate subscription plans right now. See Premier Shop for eligibility.")
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
