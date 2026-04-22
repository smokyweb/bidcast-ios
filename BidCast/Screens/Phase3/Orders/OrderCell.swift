//
//  OrderCell.swift
//  BidCast — iOS parity Phase 3a (2026-04-22)
//

import UIKit

final class OrderCell: UITableViewCell {

    static let reuseID = "OrderCell"

    private let thumb: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 8
        v.backgroundColor = .secondarySystemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let titleLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.numberOfLines = 2; return l
    }()
    private let orderIdLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel; return l
    }()
    private let statusBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.backgroundColor = .systemGray
        l.textAlignment = .center
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let priceLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 14, weight: .bold); return l
    }()
    private let dateLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 11)
        l.textColor = .secondaryLabel; return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator

        let textStack = UIStackView(arrangedSubviews: [titleLabel, orderIdLabel, priceLabel, dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(thumb)
        contentView.addSubview(textStack)
        contentView.addSubview(statusBadge)

        NSLayoutConstraint.activate([
            thumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumb.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            thumb.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            thumb.widthAnchor.constraint(equalToConstant: 64),
            thumb.heightAnchor.constraint(equalToConstant: 64),

            textStack.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: thumb.topAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -8),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            statusBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 72),
            statusBadge.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    func configure(with order: Order) {
        titleLabel.text = order.product?.title ?? order.productSet?.name ?? "Order #\(order.orderId ?? "?")"
        orderIdLabel.text = "Order: \(order.orderId ?? "—")"
        dateLabel.text = P3Format.date(order.createdAt)
        if let total = order.transaction?.first?.total {
            priceLabel.text = P3Format.currency(total)
        } else {
            priceLabel.text = ""
        }
        let status = (order.status ?? "pending").capitalized
        statusBadge.text = "  \(status)  "
        statusBadge.backgroundColor = Self.color(for: order.status)

        let firstImage: String? = {
            if let imgs = order.product?.images, let first = imgs.first { return first }
            return nil
        }()
        thumb.p3Load(firstImage, placeholder: UIImage(systemName: "photo"))
    }

    private static func color(for status: String?) -> UIColor {
        switch (status ?? "").lowercased() {
        case "new", "pending":           return .systemOrange
        case "processing", "paid":       return .systemBlue
        case "shipped", "in_transit":    return .systemIndigo
        case "delivered", "completed":   return .systemGreen
        case "cancelled", "refunded":    return .systemGray
        default:                         return .systemGray2
        }
    }
}
