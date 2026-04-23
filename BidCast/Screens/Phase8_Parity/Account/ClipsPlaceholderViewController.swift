//
//  ClipsPlaceholderViewController.swift
//  BidCast — iOS Parity Phase 8 / P0.6 (2026-04-23)
//
//  Stub reachable from the Account tab grid. Android's Clips feature
//  (ClipsFragment / ClipEditActivity) needs a dedicated port —
//  capturing, editing, and publishing short videos from recorded live
//  shows. The full experience is scheduled for P2. For P0 this screen
//  gives QA a clear landing point so the Account tap-through isn't a
//  broken navigation.\n//

import UIKit

final class ClipsPlaceholderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Clips"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        let icon = UIImageView(image: UIImage(systemName: "scissors"))
        icon.tintColor = .systemPink
        icon.contentMode = .scaleAspectFit

        let title = UILabel()
        title.text = "Clips are coming soon"
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        title.textAlignment = .center

        let body = UILabel()
        body.text = """
        Clip creation and editing from your recorded live shows is being \
        ported to iOS in a follow-up release.

        Stay tuned — you'll be able to trim, caption, and share highlight \
        clips with your followers right from this tab.
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
