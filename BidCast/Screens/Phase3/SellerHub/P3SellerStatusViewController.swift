//
//  SellerStatusViewController.swift
//  BidCast — iOS parity Phase 3d (2026-04-22)
//
//  GET /api/seller-status returns Marketplace + Live-Sell vendor states.
//  User can toggle vacation mode via POST /api/update-vacation-mode-status.
//

import UIKit
import SVProgressHUD

final class P3SellerStatusViewController: UIViewController {

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
    private var data: SellerStatusData?
    private let vacationSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Seller Status"
        view.backgroundColor = .systemGroupedBackground

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

        vacationSwitch.addTarget(self, action: #selector(toggleVacation), for: .valueChanged)
        load()
    }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let status: SellerStatusResponse = try await APIManager.shared.request(
                    type: .getSellerStatus, header: true
                )
                self.data = status.data
                // Vacation mode comes from seller-hub-info, not seller-status, so fetch
                // both and render together.
                let hub: SellerHubResponse = try await APIManager.shared.request(
                    type: .getSellerHubInfo, header: true
                )
                self.vacationSwitch.isOn = hub.data?.vacationMode ?? false
                self.render()
            } catch {
                self.render() // show card with "—" values
            }
        }
    }

    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(vendorCard(
            title: "Marketplace Vendor",
            status: data?.marketplaceVendor?.status,
            since: data?.marketplaceVendor?.vendorSince,
            rating: data?.marketplaceVendor?.sellerRating
        ))
        stack.addArrangedSubview(vendorCard(
            title: "Live-Sell Vendor",
            status: data?.liveSellVendor?.status,
            since: data?.liveSellVendor?.submitted,
            rating: nil
        ))
        stack.addArrangedSubview(vacationCard())
    }

    private func vendorCard(title: String, status: String?, since: String?, rating: Int?) -> UIView {
        let card = UIStackView()
        card.axis = .vertical
        card.spacing = 6
        card.isLayoutMarginsRelativeArrangement = true
        card.layoutMargins = .init(top: 14, left: 14, bottom: 14, right: 14)
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 10

        let t = UILabel(); t.text = title; t.font = .systemFont(ofSize: 14, weight: .semibold)
        card.addArrangedSubview(t)
        card.addArrangedSubview(row("Status", (status ?? "—").capitalized))
        card.addArrangedSubview(row("Since", P3Format.date(since)))
        if let r = rating {
            card.addArrangedSubview(row("Rating", "\(r)"))
        }
        return card
    }

    private func row(_ k: String, _ v: String) -> UIView {
        let r = UIStackView()
        r.axis = .horizontal
        let a = UILabel(); a.text = k; a.font = .systemFont(ofSize: 13); a.textColor = .secondaryLabel
        let b = UILabel(); b.text = v; b.font = .systemFont(ofSize: 13, weight: .medium); b.textAlignment = .right
        r.addArrangedSubview(a); r.addArrangedSubview(b)
        return r
    }

    private func vacationCard() -> UIView {
        let card = UIStackView()
        card.axis = .horizontal
        card.alignment = .center
        card.isLayoutMarginsRelativeArrangement = true
        card.layoutMargins = .init(top: 12, left: 14, bottom: 12, right: 14)
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 10

        let t = UILabel(); t.text = "Vacation mode"; t.font = .systemFont(ofSize: 14, weight: .semibold)
        let sub = UILabel(); sub.text = "Pause listings without delisting"
        sub.font = .systemFont(ofSize: 12); sub.textColor = .secondaryLabel; sub.numberOfLines = 0

        let labels = UIStackView(arrangedSubviews: [t, sub])
        labels.axis = .vertical
        labels.spacing = 2

        card.addArrangedSubview(labels)
        card.addArrangedSubview(vacationSwitch)
        return card
    }

    @objc private func toggleVacation() {
        let value = vacationSwitch.isOn
        Task { @MainActor in
            do {
                let fields = ["status": value ? "1" : "0"]
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .updateVacationModeStatus(param: [:]),
                    fields: fields, header: true
                )
            } catch {
                self.vacationSwitch.isOn = !value
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }
}
