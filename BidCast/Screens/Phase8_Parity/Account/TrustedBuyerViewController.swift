//
//  TrustedBuyerViewController.swift
//  BidCast — iOS Parity Phase 8 / P0.6 (2026-04-23)
//
//  Stub screen reachable from the Account tab grid. The full Trusted
//  Buyer management flow (Android's `TrustedBuyerActivity`) lands in
//  Phase P2; for P0 we just render a clear "coming soon" placeholder
//  with the expected backend dependencies listed so the TestFlight QA
//  can reach this tap-through without hitting a blank screen.\n//

import UIKit

final class TrustedBuyerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trusted Buyer"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        let icon = UIImageView(image: UIImage(systemName: "checkmark.seal"))
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.text = "Trusted Buyer"
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        title.textAlignment = .center

        let body = UILabel()
        body.text = """
        This feature is coming in a follow-up release.

        Once enabled, buyers who pass verification will unlock trusted-buyer \
        perks (instant-bid eligibility, higher caps).
        """
        body.textAlignment = .center
        body.numberOfLines = 0
        body.textColor = .secondaryLabel
        body.font = .systemFont(ofSize: 14)

        let stack = UIStackView(arrangedSubviews: [icon, title, body])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            icon.widthAnchor.constraint(equalToConstant: 64),
            icon.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
}
