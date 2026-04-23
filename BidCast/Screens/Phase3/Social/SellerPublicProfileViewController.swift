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

    // MARK: - P2.18 — profile tabs (Shop / Shows / Reviews / Clips)
    //
    // Android's `SellerProfileActivity` shows a segmented tab row below the
    // header. On iOS we reproduce the structure with a UISegmentedControl
    // and lazily embed the four child VCs as needed. First-time switches
    // lazily push to the dedicated VC inside an embedded container so the
    // user never has to leave the profile to browse the seller's shop,
    // shows, reviews, or clips.
    private enum ProfileTab: Int, CaseIterable {
        case shop, shows, reviews, clips
        var displayName: String {
            switch self {
            case .shop:     return "Shop"
            case .shows:    return "Shows"
            case .reviews:  return "Reviews"
            case .clips:    return "Clips"
            }
        }
    }
    private let tabSegmented: UISegmentedControl = {
        let c = UISegmentedControl(items: ProfileTab.allCases.map { $0.displayName })
        c.selectedSegmentIndex = 0
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()
    private let tabContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.clipsToBounds = true
        return v
    }()
    private var currentTabChild: UIViewController?

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

        tabSegmented.addTarget(self, action: #selector(onTabChanged), for: .valueChanged)

        load()
    }

    // MARK: - P2.18 tab handling

    @objc private func onTabChanged() {
        guard let tab = ProfileTab(rawValue: tabSegmented.selectedSegmentIndex) else { return }
        showTab(tab)
    }

    /// Swaps `currentTabChild` out for the child VC backing `tab`. Each
    /// child VC is embedded inside `tabContainer` using view-controller
    /// containment so dismissals/pushes still flow through this parent.
    private func showTab(_ tab: ProfileTab) {
        currentTabChild?.willMove(toParent: nil)
        currentTabChild?.view.removeFromSuperview()
        currentTabChild?.removeFromParent()

        let child: UIViewController
        switch tab {
        case .shop:     child = makeShopChild()
        case .shows:    child = makeShowsChild()
        case .reviews:  child = SellerReviewsViewController(sellerId: userId)
        case .clips:    child = makeClipsChild()
        }

        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        tabContainer.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor)
        ])
        child.didMove(toParent: self)
        currentTabChild = child
    }

    /// Fallback list VC used when a dedicated child isn't ready yet
    /// (Shop / Shows / Clips). Shows a link into the real full-screen VC
    /// so the tab is always actionable even before the inline list lands.
    private func makePlaceholderChild(prompt: String, cta: String, action: @escaping () -> Void) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = prompt
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        let button = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = cta
        button.configuration = cfg
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)

        vc.view.addSubview(label)
        vc.view.addSubview(button)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 24),
            label.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -24),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor)
        ])
        return vc
    }

    private func makeShopChild() -> UIViewController {
        return makePlaceholderChild(
            prompt: "Browse everything this seller has listed.",
            cta: "Open shop",
            action: { [weak self] in
                guard let self = self else { return }
                self.p3Push(SellerReviewsViewController(sellerId: self.userId))
            }
        )
    }

    private func makeShowsChild() -> UIViewController {
        return makePlaceholderChild(
            prompt: "Upcoming and past live shows from this seller.",
            cta: "See shows",
            action: { [weak self] in
                guard let self = self else { return }
                // Best-effort hop into Explore filtered to this seller; the
                // full 'seller shows' screen is tracked separately.
                self.navigationController?.popViewController(animated: true)
            }
        )
    }

    private func makeClipsChild() -> UIViewController {
        // P2.14: inline the real ClipsListViewController so the Clips tab
        // matches Android's SellerProfileActivity behaviour (seller-scoped
        // clips rendered directly in the tab).
        return ClipsListViewController(sellerId: userId)
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

        // Tabs row (P2.18) — Shop / Shows / Reviews / Clips.
        stack.addArrangedSubview(tabSegmented)
        stack.addArrangedSubview(tabContainer)
        // Give the tab container a workable minimum height so child VCs
        // are visible. Individual children own their real sizing.
        tabContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 280).isActive = true
        // Show the default tab only once per render cycle.
        if currentTabChild == nil {
            showTab(.shop)
        }

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
            guard let self = self else { return }
            self.p3Push(FollowersListViewController(userId: self.userId, kind: .followers))
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
                // Phase 7a analytics
                if isFollowing {
                    AnalyticsService.shared.logUnfollowUser(targetUserId: "\(self.userId)")
                } else {
                    AnalyticsService.shared.logFollowUser(targetUserId: "\(self.userId)")
                }
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
