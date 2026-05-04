//
//  HomeCategoryTileCell.swift
//  BidCast
//
//  VISUAL PARITY 2026-05-04 (MC cmomx4f1k002c3r1hggx47mks):
//  Programmatic mirror of Android's `home_category_tile.xml` +
//  `HomeCategoryAdapter.kt`. Replaces the legacy
//  `CategoryRowCollectionViewCell` (label-only pill) so the iOS home rail
//  can render the three Android tile types Trey called out:
//
//    • FOR_YOU  — gold/orange gradient card with a white person icon and
//                 white label (matches `category_selected_background.xml`,
//                 a 90° `warningAlt → warning` gradient).
//    • CATEGORY — white card with an outline + the category thumbnail
//                 image and a dark label.
//    • SEE_ALL  — white card with the grid icon (`ic_tile_grid` analogue)
//                 and a dark label.
//
//  All sizing comes from `home_category_tile.xml` (90dp × 100dp, 12dp
//  corner, 8dp padding, label on top, icon flex below). UIKit tweaks the
//  proportions slightly so the iOS row reads identically on a 393pt
//  device but stays visually correct on smaller screens.
//

import UIKit
import Kingfisher

enum HomeCategoryTileType {
    case forYou
    case category
    case seeAll
}

struct HomeCategoryTile {
    let type: HomeCategoryTileType
    let title: String
    /// Remote thumbnail URL (only used by `.category`).
    let imageURL: String?
}

final class HomeCategoryTileCell: UICollectionViewCell {

    static let identifier = "HomeCategoryTileCell"

    // MARK: - Subviews

    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    private let gradientLayer = CAGradientLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    private func buildUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 12
        cardView.layer.masksToBounds = true
        cardView.backgroundColor = .white
        contentView.addSubview(cardView)

        // Title sits on top — matches Android `home_category_tile.xml`
        // which puts the TextView above an icon that flex-grows below.
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor(white: 0.10, alpha: 1.0)
        cardView.addSubview(titleLabel)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        cardView.addSubview(iconImageView)

        // Gradient layer is added on demand for the For You tile.
        gradientLayer.colors = [
            UIColor(red: 0xED/255.0, green: 0x84/255.0, blue: 0x30/255.0, alpha: 1.0).cgColor, // warningAlt
            UIColor(red: 0xED/255.0, green: 0xB7/255.0, blue: 0x30/255.0, alpha: 1.0).cgColor  // warning
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0) // 90° in Android = horizontal sweep
        gradientLayer.cornerRadius = 12

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -6),

            iconImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            iconImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8),
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            iconImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = cardView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.kf.cancelDownloadTask()
        iconImageView.image = nil
        iconImageView.tintColor = nil
        iconImageView.layer.cornerRadius = 0
        iconImageView.layer.borderWidth = 0
        gradientLayer.removeFromSuperlayer()
    }

    // MARK: - Configure

    /// `selected` only matters for `.category` tiles — Android paints the
    /// active one with the same orange gradient as the For You tile.
    func configure(with tile: HomeCategoryTile, selected: Bool) {
        titleLabel.text = tile.title

        // Reset to default card style — gets overridden below per type.
        cardView.backgroundColor = .white
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        titleLabel.textColor = UIColor(white: 0.10, alpha: 1.0)
        gradientLayer.removeFromSuperlayer()

        switch tile.type {
        case .forYou:
            applyGradientStyle()
            iconImageView.image = UIImage(systemName: "person.crop.circle.fill")?
                .withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = .white

        case .category:
            if selected {
                applyGradientStyle()
                titleLabel.textColor = .white
            }
            iconImageView.layer.cornerRadius = 6
            iconImageView.layer.masksToBounds = true
            if let raw = tile.imageURL, let url = URL(string: raw) {
                iconImageView.contentMode = .scaleAspectFill
                iconImageView.kf.setImage(
                    with: url,
                    placeholder: UIImage(systemName: "photo")
                )
            } else {
                iconImageView.contentMode = .scaleAspectFit
                iconImageView.image = UIImage(systemName: "photo")
                iconImageView.tintColor = UIColor(white: 0.55, alpha: 1.0)
            }

        case .seeAll:
            iconImageView.image = UIImage(systemName: "square.grid.2x2")?
                .withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = UIColor(white: 0.20, alpha: 1.0)
            iconImageView.contentMode = .scaleAspectFit
        }
    }

    private func applyGradientStyle() {
        cardView.backgroundColor = .clear
        cardView.layer.borderWidth = 0
        titleLabel.textColor = .white
        if gradientLayer.superlayer == nil {
            cardView.layer.insertSublayer(gradientLayer, at: 0)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
}
