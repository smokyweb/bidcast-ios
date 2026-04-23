//
//  SavedItemsViewController.swift
//  BidCast — iOS parity Phase 8 / P1.7 stub (2026-04-23)
//
//  Placeholder VC so the Activity tab's nav-bar "saved items" entry
//  compiles before P1.11 lands the real implementation backed by
//  GET api/user/favorite.
//

import UIKit

final class SavedItemsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved items"
        view.backgroundColor = .systemBackground
        let empty = P3EmptyStateView(
            icon: UIImage(systemName: "heart"),
            title: "Coming soon",
            message: "Your saved items will show up here."
        )
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
