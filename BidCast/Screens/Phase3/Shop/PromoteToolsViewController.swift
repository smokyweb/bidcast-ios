//
//  PromoteToolsViewController.swift
//  BidCast — iOS parity Phase 3e (2026-04-22)
//
//  GET /api/get-promote-tools   — marketing product info
//  GET /api/get-promote-show    — list of shows being promoted
//  POST /api/schedule-show/store-promote-show — buy promotion (Phase 4)
//

import UIKit
import SVProgressHUD

final class PromoteToolsViewController: UIViewController {

    private let scroll = UIScrollView()
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return s
    }()
    private var tools: PromoteToolsData?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Promote Tools"
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
                let resp: GetPromoteToolsResponse = try await APIManager.shared.request(
                    type: .getPromoteTools, header: true
                )
                self.tools = resp.data
                self.render()
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let d = tools else { return }

        if let t = d.promoteTitle { stack.addArrangedSubview(headline(t)) }
        if let p = d.promoteDetails { stack.addArrangedSubview(para(p)) }

        if let features = d.features?.compactMap({ $0 }), !features.isEmpty {
            stack.addArrangedSubview(sectionLabel("Features"))
            for f in features {
                stack.addArrangedSubview(featureCard(title: f.title ?? "",
                                                     description: f.description ?? ""))
            }
        }
        stack.addArrangedSubview(sectionLabel("Promote a show"))
        if let opts = d.showOptions {
            stack.addArrangedSubview(para(
                "Reach: \(opts.followers ?? 0) followers · \(opts.shows ?? 0) shows · \(opts.views ?? 0) views"
            ))
        }

        let buy = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Buy promotion (Phase 4)"
        buy.configuration = cfg
        buy.isEnabled = false
        stack.addArrangedSubview(buy)

        stack.addArrangedSubview(para(
            "Purchasing promotions requires Stripe integration — Phase 4."))
    }

    private func headline(_ s: String) -> UILabel {
        let l = UILabel(); l.text = s
        l.font = .systemFont(ofSize: 22, weight: .bold); l.numberOfLines = 0; return l
    }
    private func para(_ s: String) -> UILabel {
        let l = UILabel(); l.text = s
        l.font = .systemFont(ofSize: 14); l.textColor = .secondaryLabel; l.numberOfLines = 0; return l
    }
    private func sectionLabel(_ s: String) -> UILabel {
        let l = UILabel(); l.text = s
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel; return l
    }
    private func featureCard(title: String, description: String) -> UIView {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 2
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 10, left: 12, bottom: 10, right: 12)
        s.backgroundColor = .secondarySystemBackground
        s.layer.cornerRadius = 8
        let t = UILabel(); t.text = title; t.font = .systemFont(ofSize: 15, weight: .semibold)
        let d = UILabel(); d.text = description; d.font = .systemFont(ofSize: 13); d.textColor = .secondaryLabel; d.numberOfLines = 0
        s.addArrangedSubview(t); s.addArrangedSubview(d)
        return s
    }
}
