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
import Kingfisher

public final class PinnedProductCard: UIView {

    // MARK: Subviews

    // FIX cmp41hieh00rj4axy15wpcmqz: product thumbnail shown left of title.
    // Android and iOS streamers both send product images via the socket
    // (auction_started / product_pinned payloads). Images from Android
    // arrive as a relative path under product.images[] and need the base
    // URL prepended; iOS sends full URLs in product.thumbnail[]. Both are
    // handled by updateProductImage(_:).
    private let productImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        iv.image = UIImage(systemName: "photo")
        iv.tintColor = UIColor.white.withAlphaComponent(0.5)
        return iv
    }()

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

        addSubview(productImageView)
        addSubview(chip)
        addSubview(titleLabel)
        addSubview(bidLabel)
        addSubview(timerLabel)

        NSLayoutConstraint.activate([
            // Product thumbnail — left edge
            productImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            productImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 48),
            productImageView.heightAnchor.constraint(equalToConstant: 48),

            // PINNED chip — above title, right of thumbnail
            chip.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            chip.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 8),
            chip.widthAnchor.constraint(equalToConstant: 54),
            chip.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.topAnchor.constraint(equalTo: chip.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: timerLabel.leadingAnchor, constant: -8),

            bidLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            bidLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 8),
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

    // FIX cmp41hieh00rj4axy15wpcmqz: load product image from socket payload.
    // Android sends images[] as relative paths (no host); iOS sends thumbnail[]
    // as full URLs. Both cases handled here.
    public func updateProductImage(_ urlString: String?) {
        guard let raw = urlString, !raw.isEmpty else {
            productImageView.image = UIImage(systemName: "photo")
            productImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
            return
        }
        // If the URL is already absolute (starts with http), use it directly.
        // Otherwise treat as relative path under the Bidcast backend base URL.
        let absolute: String
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            absolute = raw
        } else {
            absolute = "https://backend.bidcast.betaplanets.com/" + raw
        }
        guard let url = URL(string: absolute) else {
            productImageView.image = UIImage(systemName: "photo")
            return
        }
        productImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "photo"),
            options: [.transition(.fade(0.2))]
        )
    }
}
