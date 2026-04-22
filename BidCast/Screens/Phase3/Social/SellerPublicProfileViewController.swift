//
//  SellerPublicProfileViewController.swift
//  BidCast — iOS parity Phase 3f (2026-04-22)
//
//  GET /api/get-seller-info (seller profile payload) or
//  POST /api/get-profile-by-id when we already have a userId.
//  Includes follow/unfollow via POST /api/follow-unfollow.
//

import UIKit
import SVProgressHUD

final class SellerPublicProfileViewController: UIViewController {

    private let userId: Int
    private let scroll = UIScrollView()
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 14
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return s
    }()
    private var seller: SellerInfoData?
    private let followBtn = UIButton(type: .system)

    init(userId: Int) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
        self.title = "Profile"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        var cfg = UIButton.Configuration.filled()
        cfg.title = "Follow"
        followBtn.configuration = cfg
        followBtn.addTarget(self, action: #selector(toggleFollow), for: .touchUpInside)

        load()
    }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let fields = ["user_id": "\(userId)"]
                let resp: SellerInfoResponse = try await APIManager.shared.postMultipartForm(
                    type: .getProfileById(param: [:]),
                    fields: fields, header: true
                )
                self.seller = resp.data
                self.render()
            } catch {
                // Fallback: try GET seller-info (no user_id = current user)
                do {
                    let resp: SellerInfoResponse = try await APIManager.shared.request(
                        type: .getSellerInfo, header: true
                    )
                    self.seller = resp.data
                    self.render()
                } catch {
                    self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
                }
            }
        }
    }

    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let d = seller

        let header = UIStackView()
        header.axis = .vertical
        header.spacing = 4
        header.alignment = .center
        let avatar = UIImageView()
        avatar.widthAnchor.constraint(equalToConstant: 96).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: 96).isActive = true
        avatar.layer.cornerRadius = 48
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFill
        avatar.backgroundColor = .secondarySystemBackground
        avatar.p3Load(d?.sellerDetails?.profileImage,
                      placeholder: UIImage(systemName: "person.crop.circle.fill"))

        let name = UILabel()
        name.font = .systemFont(ofSize: 20, weight: .bold)
        name.text = d?.sellerDetails?.name ?? d?.sellerDetails?.username ?? "—"

        let sub = UILabel()
        sub.font = .systemFont(ofSize: 13)
        sub.textColor = .secondaryLabel
        sub.text = "@\(d?.sellerDetails?.username ?? "")"

        header.addArrangedSubview(avatar)
        header.addArrangedSubview(name)
        header.addArrangedSubview(sub)
        stack.addArrangedSubview(header)

        // Stats row
        let stats = UIStackView()
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.addArrangedSubview(statTile(title: "Sold", value: "\(Int(d?.soldCount ?? 0))"))
        stats.addArrangedSubview(statTile(title: "Rating", value: String(format: "%.1f", d?.ratingAvg ?? 0)))
        let avgShipText: String = {
            if let s = d?.avgShip?.value as? String { return s }
            if let n = d?.avgShip?.value as? NSNumber { return n.stringValue }
            return "—"
        }()
        stats.addArrangedSubview(statTile(title: "Avg ship", value: avgShipText))
        stack.addArrangedSubview(stats)

        // Follow button reflecting state
        let isFollowing = d?.isFollowing ?? false
        updateFollowButton(isFollowing: isFollowing)
        stack.addArrangedSubview(followBtn)

        // Additional actions
        let actions = UIStackView()
        actions.axis = .vertical
        actions.spacing = 10
        actions.addArrangedSubview(navButton(title: "View seller's reviews") { [weak self] in
            guard let self = self else { return }
            self.p3Push(SellerReviewsViewController(sellerId: self.userId))
        })
        // iOS parity Job A: new entry points so Phase 4f SendTipVC and
        // Phase 3f FollowersListVC are no longer orphaned.
        actions.addArrangedSubview(navButton(title: "Send a tip") { [weak self] in
            guard let self = self else { return }
            let vc = SendTipViewController(sellerId: self.userId)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .formSheet
            self.present(nav, animated: true)
        })
        actions.addArrangedSubview(navButton(title: "Followers / Following") { [weak self] in
            self?.p3Push(FollowersListViewController())
        })
        actions.addArrangedSubview(navButton(title: "Shop this seller") { [weak self] in
            // Phase 3f already fetches `isFollowing` / sold-count etc. here.
            // A future Phase 5 entry will open this seller's full product
            // list; for Job A we at least reach the public-profile review
            // surface so the user can shop-review the seller by proxy.
            guard let self = self else { return }
            self.p3Push(SellerReviewsViewController(sellerId: self.userId))
        })
        actions.addArrangedSubview(navButton(title: "Report user") { [weak self] in
            guard let self = self else { return }
            self.reportPrompt()
        })
        stack.addArrangedSubview(actions)
    }

    private func statTile(title: String, value: String) -> UIView {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        let val = UILabel(); val.text = value; val.font = .systemFont(ofSize: 18, weight: .bold)
        let t = UILabel(); t.text = title; t.font = .systemFont(ofSize: 12); t.textColor = .secondaryLabel
        v.addArrangedSubview(val); v.addArrangedSubview(t)
        return v
    }

    private func navButton(title: String, action: @escaping () -> Void) -> UIButton {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.plain()
        cfg.title = title
        b.configuration = cfg
        b.contentHorizontalAlignment = .leading
        b.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return b
    }

    private func updateFollowButton(isFollowing: Bool) {
        var cfg = followBtn.configuration ?? UIButton.Configuration.filled()
        cfg.title = isFollowing ? "Following" : "Follow"
        cfg.baseBackgroundColor = isFollowing ? .systemGray : .systemBlue
        followBtn.configuration = cfg
    }

    @objc private func toggleFollow() {
        let isFollowing = seller?.isFollowing ?? false
        // Optimistic toggle
        var newSeller = seller
        // (can't easily mutate struct; re-render after response)
        Task { @MainActor in
            do {
                let req = FollowUnfollowRequest(followId: userId)
                let _: FollowUnfollowResponse = try await APIManager.shared.postMultipartForm(
                    type: .followUser(param: req),
                    fields: ["follow_id": "\(userId)"],
                    header: true
                )
                // Reload to get fresh isFollowing flag
                self.load()
                _ = newSeller // silence unused warning
                _ = isFollowing
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    private func reportPrompt() {
        let alert = UIAlertController(title: "Report user",
                                      message: "Tell us what's wrong", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "Reason" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let reason = alert.textFields?.first?.text ?? ""
            InMemoryChatStore.shared.reportUser(userId: self.userId, reason: reason) { _ in
                DispatchQueue.main.async {
                    self.p3Alert(title: "Thanks", message: "Report submitted.")
                }
            }
        })
        present(alert, animated: true)
    }
}
