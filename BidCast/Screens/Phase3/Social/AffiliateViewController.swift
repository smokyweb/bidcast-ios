//
//  AffiliateViewController.swift
//  BidCast — iOS parity Phase 3f (2026-04-22)
//
//  GET /api/referral-code/fetch — returns name, referralCode, totals.
//  Share sheet lets user promote the code.
//

import UIKit
import SVProgressHUD

final class AffiliateViewController: UIViewController {

    private let scroll = UIScrollView()
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 18
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 20, left: 16, bottom: 16, right: 16)
        return s
    }()
    private var data: ReferralData?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Refer a friend"
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
        load()
    }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let resp: FetchReferralResponse = try await APIManager.shared.request(
                    type: .fetchReferral, header: true
                )
                self.data = resp.data
                self.render()
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let head = UILabel()
        head.text = "Share your referral code"
        head.font = .systemFont(ofSize: 22, weight: .bold)
        head.numberOfLines = 0
        stack.addArrangedSubview(head)

        let codeLabel = UILabel()
        codeLabel.text = data?.referralCode ?? "—"
        codeLabel.font = .monospacedSystemFont(ofSize: 28, weight: .bold)
        codeLabel.textAlignment = .center
        codeLabel.backgroundColor = .secondarySystemBackground
        codeLabel.layer.cornerRadius = 8
        codeLabel.clipsToBounds = true
        codeLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        stack.addArrangedSubview(codeLabel)

        let stats = UIStackView()
        stats.axis = .horizontal
        stats.distribution = .fillEqually
        stats.addArrangedSubview(statTile(title: "Referred", value: "\(data?.totalReferred ?? 0)"))
        stats.addArrangedSubview(statTile(title: "Earned", value: P3Format.currency(Double(data?.totalEarnings ?? 0))))
        stack.addArrangedSubview(stats)

        let share = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Share"
        share.configuration = cfg
        share.addTarget(self, action: #selector(shareCode), for: .touchUpInside)
        stack.addArrangedSubview(share)
    }

    private func statTile(title: String, value: String) -> UIView {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .center
        let v = UILabel(); v.text = value; v.font = .systemFont(ofSize: 20, weight: .bold)
        let t = UILabel(); t.text = title; t.font = .systemFont(ofSize: 12); t.textColor = .secondaryLabel
        s.addArrangedSubview(v); s.addArrangedSubview(t)
        return s
    }

    @objc private func shareCode() {
        let code = data?.referralCode ?? ""
        let text = "Join me on Bidcast! Use my code \(code) when you sign up."
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(av, animated: true)
    }
}
