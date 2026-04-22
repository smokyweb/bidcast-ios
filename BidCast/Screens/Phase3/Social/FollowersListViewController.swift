//
//  FollowersListViewController.swift
//  BidCast — iOS parity Phase 3f (2026-04-22)
//
//  Backend doesn't ship a dedicated GET /api/get-followers /api/get-following
//  endpoint (Android pulls these inline from profile-by-id payloads).
//  This screen is a structural placeholder — sets up the list, documents
//  the gap, and lets us drop real rows in when backend exposes the
//  dedicated endpoint.
//

import UIKit

final class FollowersListViewController: UIViewController {

    enum Kind { case followers, following }
    private let userId: Int
    private let kind: Kind

    init(userId: Int, kind: Kind) {
        self.userId = userId
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
        self.title = (kind == .followers) ? "Followers" : "Following"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let empty = P3EmptyStateView(
            icon: UIImage(systemName: "person.2"),
            title: "Coming soon",
            message: "Dedicated \(kind == .followers ? "followers" : "following") endpoint pending backend support."
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
