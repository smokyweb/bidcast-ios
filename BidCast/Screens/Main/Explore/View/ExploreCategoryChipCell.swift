//
//  ExploreCategoryChipCell.swift
//  BidCast
//
//  Created by Trey Difficult Task Agent on 2026-04-21.
//
//  Small horizontal chip representing a product category. Used by the top
//  rail on the Explore tab. Selected state is indicated by a tinted border
//  and a bolder label.
//

import UIKit
import Kingfisher

final class ExploreCategoryChipCell: UICollectionViewCell {

    static let identifier = "ExploreCategoryChipCell"

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 24
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        iconImageView.layer.borderWidth = 2
        iconImageView.layer.borderColor = UIColor.clear.cgColor
        buildLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    private func buildLayout() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48),

            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func configure(name: String, imageURL: String?, isSelected: Bool) {
        nameLabel.text = name
        nameLabel.font = isSelected
            ? .boldSystemFont(ofSize: 12)
            : .systemFont(ofSize: 12, weight: .medium)
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): Android
        // chip-selected state uses `@color/primary` (#0058BD) for the
        // border / tint. Match that here.
        iconImageView.layer.borderColor = isSelected
            ? (AppColor.primary?.cgColor ?? UIColor.systemBlue.cgColor)
            : UIColor.clear.cgColor

        if let urlStr = imageURL, let url = URL(string: urlStr) {
            iconImageView.kf.setImage(with: url,
                                      placeholder: UIImage(systemName: "square.grid.2x2"),
                                      options: [.transition(.fade(0.2))])
        } else {
            iconImageView.image = UIImage(systemName: "square.grid.2x2")
            iconImageView.tintColor = AppColor.primary
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.kf.cancelDownloadTask()
        iconImageView.image = nil
    }
}
