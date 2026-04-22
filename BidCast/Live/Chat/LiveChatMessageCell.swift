//
//  LiveChatMessageCell.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  Chat bubble cell for live stream chat overlays. Mirrors Android's
//  MessagesAdapter.kt row style: small circular avatar + sender name in
//  a tinted pill + message body. System messages render without an avatar
//  and with italicized grey text so auction lifecycle events (auction
//  started, you won, raid incoming) are visually distinct from user chat.
//

import UIKit

public final class LiveChatMessageCell: UITableViewCell {

    public static let reuseId = "LiveChatMessageCell"

    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = UIColor.white.withAlphaComponent(0.4)
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .boldSystemFont(ofSize: 12)
        l.textColor = UIColor(red: 0.92, green: 0.85, blue: 0.55, alpha: 1.0)
        return l
    }()

    private let bodyLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = .systemFont(ofSize: 13)
        l.textColor = .white
        l.numberOfLines = 0
        return l
    }()

    private let stack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 1
        return s
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(avatarView)
        contentView.addSubview(stack)
        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(bodyLabel)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            avatarView.widthAnchor.constraint(equalToConstant: 24),
            avatarView.heightAnchor.constraint(equalToConstant: 24),

            stack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    public func configure(with m: LiveChatMessage) {
        switch m.kind {
        case .user:
            avatarView.isHidden = false
            nameLabel.isHidden = false
            nameLabel.text = m.senderName
            bodyLabel.attributedText = NSAttributedString(
                string: m.body,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor.white
                ]
            )
            if let urlString = m.senderImage, let url = URL(string: urlString) {
                // Simple async image load. If the app has an image loader
                // helper we could switch to it, but keeping this dep-free
                // prevents coupling the Live module to picker UI.
                loadAvatar(url: url)
            } else {
                avatarView.image = UIImage(systemName: "person.crop.circle.fill")
                avatarView.tintColor = UIColor.white.withAlphaComponent(0.4)
            }
        case .system:
            avatarView.isHidden = true
            nameLabel.isHidden = true
            bodyLabel.attributedText = NSAttributedString(
                string: m.body,
                attributes: [
                    .font: UIFont.italicSystemFont(ofSize: 12),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.7)
                ]
            )
        }
    }

    // MARK: - Avatar loading (very simple)

    private static var avatarCache = NSCache<NSURL, UIImage>()

    private func loadAvatar(url: URL) {
        if let cached = Self.avatarCache.object(forKey: url as NSURL) {
            self.avatarView.image = cached
            return
        }
        self.avatarView.image = UIImage(systemName: "person.crop.circle.fill")
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            Self.avatarCache.setObject(img, forKey: url as NSURL)
            DispatchQueue.main.async {
                self?.avatarView.image = img
            }
        }.resume()
    }
}
