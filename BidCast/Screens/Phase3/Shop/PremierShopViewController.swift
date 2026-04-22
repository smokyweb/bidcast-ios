//
//  PremierShopViewController.swift
//  BidCast — iOS parity Phase 3e (2026-04-22)
//
//  Mirrors Android `PremierShopFragment`.
//  GET  /api/get-premier-shop   -> PremierShopData (content + features + requirements)
//  POST /api/apply-premier-shop -> enroll in premier program
//

import UIKit
import SVProgressHUD

final class PremierShopViewController: UIViewController {

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

    private var data: PremierShopData?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Premier Shop"
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
                let resp: GetPremierShopResponse = try await APIManager.shared.request(
                    type: .getPremierShop, header: true
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
        guard let d = data else { return }

        if let pt = d.pageTitle {
            stack.addArrangedSubview(heading(pt, size: 22))
        }
        if let pd = d.pageDetails {
            stack.addArrangedSubview(body(pd))
        }
        if let progress = d.currentProgress {
            stack.addArrangedSubview(body("Progress: \(progress)%"))
        }
        if let features = d.features?.compactMap({ $0 }), !features.isEmpty {
            stack.addArrangedSubview(heading("Features", size: 17))
            for f in features {
                stack.addArrangedSubview(featureRow(title: f.title ?? "",
                                                    description: f.description ?? ""))
            }
        }
        if let reqs = d.requirements?.compactMap({ $0 }), !reqs.isEmpty {
            stack.addArrangedSubview(heading("Requirements", size: 17))
            for r in reqs {
                stack.addArrangedSubview(body("• \(r.platform ?? "Requirement"): \(r.url ?? "")"))
            }
        }

        let apply = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Apply to Premier Shop"
        apply.configuration = cfg
        apply.addTarget(self, action: #selector(applyToPremier), for: .touchUpInside)
        stack.addArrangedSubview(apply)
    }

    private func heading(_ t: String, size: CGFloat) -> UILabel {
        let l = UILabel(); l.text = t
        l.font = .systemFont(ofSize: size, weight: .bold)
        l.numberOfLines = 0
        return l
    }
    private func body(_ t: String) -> UILabel {
        let l = UILabel(); l.text = t
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }
    private func featureRow(title: String, description: String) -> UIView {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 2
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 10, left: 12, bottom: 10, right: 12)
        s.backgroundColor = .secondarySystemBackground
        s.layer.cornerRadius = 8
        s.addArrangedSubview(heading(title, size: 15))
        s.addArrangedSubview(body(description))
        return s
    }

    @objc private func applyToPremier() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .applyPremierShop, fields: [:], header: true
                )
                self.p3Alert(title: "Submitted",
                             message: "Your Premier Shop application is under review.")
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }
}
