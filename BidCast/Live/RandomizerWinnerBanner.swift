//
//  RandomizerWinnerBanner.swift
//  BidCast
//
//  iOS Parity Phase 6d (2026-04-22) — viewer-visible 6-second overlay
//  announcing a randomizer / freebie winner.
//
//  The existing `LiveFreebieSheet` already handles the entry flow and
//  in-sheet winner announcement when the viewer opted in. This banner
//  is for the broadcast-to-all-viewers case — on `get-freebie-winner`
//  every viewer (entered or not) briefly sees a celebration overlay.
//

import UIKit

public final class RandomizerWinnerBanner: UIView {

    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.82)
        layer.cornerRadius = 14
        layer.masksToBounds = true
        isHidden = true
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.text = "🎉"
        l.font = .systemFont(ofSize: 28)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Winner"
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = ""
        l.textColor = .white
        l.font = .boldSystemFont(ofSize: 17)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var hideTimer: Timer?

    private func setupLayout() {
        addSubview(emojiLabel)
        let stack = UIStackView(arrangedSubviews: [titleLabel, nameLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
        ])
    }

    public func show(winnerName: String, duration: TimeInterval = 6.0) {
        nameLabel.text = winnerName
        isHidden = false
        alpha = 0
        UIView.animate(withDuration: 0.25) { self.alpha = 1 }
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.hide()
        }
    }

    public func hide() {
        hideTimer?.invalidate()
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
    }
}
