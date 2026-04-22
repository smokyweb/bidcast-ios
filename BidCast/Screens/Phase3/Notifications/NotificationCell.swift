//
//  NotificationCell.swift
//  BidCast — iOS parity Phase 3b (2026-04-22)
//

import UIKit

final class NotificationCell: UITableViewCell {
    static let reuseID = "NotificationCell"

    private let iconView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.tintColor = .systemPink
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.numberOfLines = 0
        return l
    }()
    private let messageLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = .tertiaryLabel
        return l
    }()
    private let unreadDot: UIView = {
        let v = UIView()
        v.backgroundColor = .systemRed
        v.layer.cornerRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 8).isActive = true
        v.heightAnchor.constraint(equalToConstant: 8).isActive = true
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default

        let txt = UIStackView(arrangedSubviews: [titleLabel, messageLabel, dateLabel])
        txt.axis = .vertical
        txt.spacing = 3
        txt.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconView)
        contentView.addSubview(txt)
        contentView.addSubview(unreadDot)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            txt.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            txt.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            txt.trailingAnchor.constraint(equalTo: unreadDot.leadingAnchor, constant: -8),
            txt.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            unreadDot.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            unreadDot.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with n: NotificationEntry) {
        titleLabel.text = n.title ?? "Notification"
        messageLabel.text = n.message ?? ""
        dateLabel.text = P3Format.date(n.createdAt)
        iconView.image = Self.icon(for: n.type)
        unreadDot.isHidden = (n.isSeen ?? 0) != 0
    }

    private static func icon(for type: String?) -> UIImage? {
        switch (type ?? "").lowercased() {
        case "order":   return UIImage(systemName: "shippingbox.fill")
        case "bid":     return UIImage(systemName: "gavel.fill")
        case "tip":     return UIImage(systemName: "gift.fill")
        case "follow":  return UIImage(systemName: "person.fill.badge.plus")
        case "live":    return UIImage(systemName: "dot.radiowaves.left.and.right")
        case "chat":    return UIImage(systemName: "bubble.left.fill")
        default:        return UIImage(systemName: "bell.fill")
        }
    }
}
