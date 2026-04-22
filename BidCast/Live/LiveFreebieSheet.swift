//
//  LiveFreebieSheet.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 6:
//  Viewer-side freebie / randomizer entry. Presented on `get-freebie`,
//  lets the viewer tap "Enter" to emit `enter-in-freebie`, and updates
//  with the winner from `get-freebie-winner`.
//

import UIKit

public final class LiveFreebieSheet: UIViewController {

    public var roomId: String
    public var currentUserId: String
    public var productTitle: String
    public var durationSeconds: Int
    public var onEntered: (() -> Void)?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "🎁 Randomizer"
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 22)
        l.textAlignment = .center
        return l
    }()

    private let subtitle: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textColor = .white.withAlphaComponent(0.85)
        l.font = .systemFont(ofSize: 14)
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()

    private let enterButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Enter", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 17)
        b.backgroundColor = UIColor.systemPink.withAlphaComponent(0.9)
        b.layer.cornerRadius = 10
        return b
    }()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Close", for: .normal)
        b.setTitleColor(.white, for: .normal)
        return b
    }()

    public init(roomId: String, currentUserId: String, productTitle: String, durationSeconds: Int) {
        self.roomId = roomId
        self.currentUserId = currentUserId
        self.productTitle = productTitle
        self.durationSeconds = durationSeconds
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
        card.layer.cornerRadius = 14
        view.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(subtitle)
        card.addSubview(enterButton)
        card.addSubview(closeButton)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            subtitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            subtitle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            enterButton.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 16),
            enterButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            enterButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            enterButton.heightAnchor.constraint(equalToConstant: 46),
            closeButton.topAnchor.constraint(equalTo: enterButton.bottomAnchor, constant: 10),
            closeButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        let s = durationSeconds > 0 ? " (\(durationSeconds)s)" : ""
        subtitle.text = productTitle.isEmpty
            ? "Tap Enter to join the randomizer\(s)."
            : "\(productTitle) — tap Enter to join\(s)."
        enterButton.addTarget(self, action: #selector(enterTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    public func announceWinner(_ name: String) {
        titleLabel.text = "🎉 Winner"
        subtitle.text = "\(name) won!"
        enterButton.setTitle("Close", for: .normal)
        enterButton.removeTarget(nil, action: nil, for: .allEvents)
        enterButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    @objc private func enterTapped() {
        BidcastSocketManager.shared.emitEnterInFreebie(roomId: roomId, userId: currentUserId)
        enterButton.setTitle("Entered ✓", for: .normal)
        enterButton.isEnabled = false
        onEntered?()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
