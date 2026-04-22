//
//  PinnedProductCard.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  Compact product card shown on both the host and viewer live views
//  when a product is pinned for the current auction. Renders the product
//  title, current bid amount, and a ticking countdown — matches the
//  Android `WatchStreamFragment` bottom pinned strip.
//
//  Bind updates via set(pinnedTitle:, highestBid:, timerSeconds:,
//  isAuctionOpen:). Tapping the card calls `onTap` so the viewer's
//  WatchStreamViewController can open the "Place bid" sheet, and the
//  host VC can open the product settings.
//

import UIKit

public final class PinnedProductCard: UIView {

    // MARK: Subviews
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .boldSystemFont(ofSize: 14)
        l.textColor = .white
        l.numberOfLines = 1
        l.text = "No pinned product"
        return l
    }()

    private let bidLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .boldSystemFont(ofSize: 20)
        l.textColor = UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1.0)
        l.text = "$—"
        return l
    }()

    private let timerLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .boldSystemFont(ofSize: 14)
        l.textColor = .systemRed
        l.text = "--"
        l.textAlignment = .right
        return l
    }()

    private let chip: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .boldSystemFont(ofSize: 10)
        l.textColor = .white
        l.text = "PINNED"
        l.textAlignment = .center
        l.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.9)
        l.layer.cornerRadius = 4
        l.layer.masksToBounds = true
        return l
    }()

    // MARK: State / API
    public var onTap: (() -> Void)?

    // MARK: Init
    public init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.black.withAlphaComponent(0.55)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor

        addSubview(chip)
        addSubview(titleLabel)
        addSubview(bidLabel)
        addSubview(timerLabel)

        NSLayoutConstraint.activate([
            chip.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            chip.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            chip.widthAnchor.constraint(equalToConstant: 54),
            chip.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.topAnchor.constraint(equalTo: chip.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timerLabel.leadingAnchor, constant: -8),

            bidLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            bidLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bidLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            timerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            timerLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    @objc private func tapped() { onTap?() }

    // MARK: API

    public func updateTitle(_ title: String?) {
        titleLabel.text = (title?.isEmpty == false) ? title : "No pinned product"
    }

    public func updateHighestBid(_ amount: Double) {
        if amount > 0 {
            bidLabel.text = String(format: "$%.0f", amount)
        } else {
            bidLabel.text = "$—"
        }
    }

    public func updateTimer(seconds: Int) {
        if seconds < 0 {
            timerLabel.text = "--"
            timerLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        } else if seconds == 0 {
            timerLabel.text = "SOLD"
            timerLabel.textColor = .systemOrange
        } else {
            timerLabel.text = "\(seconds)s"
            timerLabel.textColor = seconds <= 5 ? .systemRed : .systemYellow
        }
    }
}
