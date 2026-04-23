//
//  SellerHubOverviewViewController.swift
//  BidCast — iOS Parity Phase 8 / P2.20 (2026-04-23)
//
//  Android port: `ui/sellerHub/OverviewFragment.kt`. On Android this is the
//  landing pane of SellerHubActivity's pager and shows KPI metrics plus a
//  promote-tools grid. On iOS we take the same role: `SellerHubContainer`
//  now embeds this VC as its landing pane, and the existing nav-tile set
//  moves to a "Sections" pane selected via the segmented control that
//  P2.20 installs on the container.
//
//  For the first iOS version we surface:
//    - KPI row (Items / Orders / Revenue) — same three tiles the container
//      used to render at the top of itself.
//    - Account Health card — defect-free / on-time / policy standing.
//    - A lightweight "Suggested next step" row that promotes the highest
//      leverage action (drawn from the same SellerHub data). This is
//      deliberately minimal; Android's richer metric/promote grid is
//      tracked as a follow-up.
//
//  The VC is self-contained (no tab bar / nav bar chrome of its own)
//  because it is meant to be embedded.
//

import UIKit

final class SellerHubOverviewViewController: UIViewController {

    // MARK: - Public API

    /// Drive the UI from this. Container loads it from `getSellerHubInfo`
    /// and passes the decoded `SellerHubData`.
    var hubData: SellerHubData? {
        didSet { renderIfLoaded() }
    }

    // MARK: - UI

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
    private var didLayout = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])
        didLayout = true
        renderIfLoaded()
    }

    // MARK: - Render

    private func renderIfLoaded() {
        guard didLayout else { return }
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(kpiRow())
        stack.addArrangedSubview(accountHealthCard())
        stack.addArrangedSubview(suggestedActionCard())
    }

    // MARK: - KPI tiles

    private func kpiRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        row.addArrangedSubview(kpiTile(title: "Items", value: hubData?.items.map(String.init) ?? "—"))
        row.addArrangedSubview(kpiTile(title: "Orders", value: hubData?.totalOrders.map(String.init) ?? "—"))
        row.addArrangedSubview(kpiTile(title: "Revenue", value: P3Format.currency(hubData?.revenue)))
        return row
    }

    private func kpiTile(title: String, value: String) -> UIView {
        let c = UIStackView()
        c.axis = .vertical
        c.alignment = .leading
        c.backgroundColor = .secondarySystemGroupedBackground
        c.layer.cornerRadius = 10
        c.isLayoutMarginsRelativeArrangement = true
        c.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        let v = UILabel()
        v.text = value
        v.font = .systemFont(ofSize: 22, weight: .bold)
        v.textColor = .label
        let t = UILabel()
        t.text = title
        t.font = .systemFont(ofSize: 12)
        t.textColor = .secondaryLabel
        c.addArrangedSubview(v)
        c.addArrangedSubview(t)
        return c
    }

    // MARK: - Account health

    private func accountHealthCard() -> UIView {
        let c = UIStackView()
        c.axis = .vertical
        c.spacing = 6
        c.backgroundColor = .secondarySystemGroupedBackground
        c.layer.cornerRadius = 10
        c.isLayoutMarginsRelativeArrangement = true
        c.layoutMargins = .init(top: 14, left: 14, bottom: 14, right: 14)

        let t = UILabel()
        t.text = "Account Health"
        t.font = .systemFont(ofSize: 14, weight: .semibold)
        c.addArrangedSubview(t)

        let h = hubData?.accountHealth
        c.addArrangedSubview(kv("Defect-free orders", h?.defectFreeOrderRate ?? "—"))
        c.addArrangedSubview(kv("On-time scan rate", h?.onTimeScanRate ?? "—"))
        c.addArrangedSubview(kv("Policy standing", h?.policyStanding ?? "—"))
        return c
    }

    // MARK: - Suggested action

    private func suggestedActionCard() -> UIView {
        let c = UIStackView()
        c.axis = .vertical
        c.spacing = 8
        c.backgroundColor = .secondarySystemGroupedBackground
        c.layer.cornerRadius = 10
        c.isLayoutMarginsRelativeArrangement = true
        c.layoutMargins = .init(top: 14, left: 14, bottom: 14, right: 14)

        let title = UILabel()
        title.text = "Next step"
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        c.addArrangedSubview(title)

        let msg = UILabel()
        msg.numberOfLines = 0
        msg.textColor = .secondaryLabel
        msg.font = .systemFont(ofSize: 13)
        msg.text = suggestedNextStepMessage()
        c.addArrangedSubview(msg)

        return c
    }

    private func suggestedNextStepMessage() -> String {
        // Lightweight triage based on available KPIs; mirrors the tone of
        // Android's prompts that push sellers toward the highest-leverage
        // action (list more / schedule a show / fulfil orders).
        if (hubData?.items ?? 0) == 0 {
            return "List your first item to unlock Shows and Promote tools."
        }
        if (hubData?.totalOrders ?? 0) == 0 {
            return "You've got listings live — schedule a Live Show to get bids flowing."
        }
        return "Keep shipping on time to hold your account health in the green."
    }

    private func kv(_ key: String, _ value: String) -> UIView {
        let r = UIStackView()
        r.axis = .horizontal
        let k = UILabel(); k.text = key; k.font = .systemFont(ofSize: 13); k.textColor = .secondaryLabel
        let v = UILabel(); v.text = value; v.font = .systemFont(ofSize: 13, weight: .semibold); v.textAlignment = .right
        r.addArrangedSubview(k); r.addArrangedSubview(v)
        return r
    }
}
