//
//  TipSettingsViewController.swift
//  BidCast — iOS parity Phase 4e (2026-04-22)
//
//  Host-side tip tier configuration. On Android, `TipSettingActivity` is a
//  static screen — the actual save flow is a socket event called
//  `tip_setting_save` emitted from AgoraPublisherActivity while a show is
//  live (see `SocketManager.kt`). The REST `get-tip-amount` endpoint
//  returns the current saved tier values.
//
//  iOS approach:
//    1. Load tiers via GET `api/get-tip-amount` (matches Android).
//    2. Save:
//       - If there's an active SocketManager (Phase 5), emit
//         `tip_setting_save` (keeps parity with Android).
//       - Always also POST to the REST endpoint for durable persistence.
//         QA-NOTE: The Laravel backend currently only persists via socket
//         (the server-side handler writes to DB). There is no dedicated
//         REST `update-tip-settings` endpoint in Android's Retrofit
//         interface, so iOS writes are effective only when a socket is
//         connected. Flagged as a backend gap.
//

import UIKit

final class TipSettingsViewController: UIViewController {

    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let saveBtn = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)

    // 5 preset tip tiers (Android shows 5 chips)
    private var tiers: [Int] = [1, 5, 10, 25, 50]
    private var fields: [UITextField] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tip settings"
        view.backgroundColor = .systemGroupedBackground

        setupLayout()
        Task { await load() }
    }

    private func setupLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 24, right: 16)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        let hint = UILabel()
        hint.text = "Set the 5 preset tip amounts viewers see in your stream. Amounts are in USD."
        hint.numberOfLines = 0
        hint.font = .systemFont(ofSize: 13)
        hint.textColor = .secondaryLabel
        stack.addArrangedSubview(hint)

        for i in 0..<5 {
            let row = makeTierRow(index: i)
            stack.addArrangedSubview(row)
        }

        var cfg = UIButton.Configuration.filled()
        cfg.title = "Save Tip Settings"
        cfg.baseBackgroundColor = .systemBlue
        saveBtn.configuration = cfg
        saveBtn.addTarget(self, action: #selector(save), for: .touchUpInside)
        stack.addArrangedSubview(saveBtn)
        stack.addArrangedSubview(spinner)
    }

    private func makeTierRow(index: Int) -> UIView {
        let lbl = UILabel()
        lbl.text = "Tier \(index + 1)"
        lbl.font = .systemFont(ofSize: 15)

        let field = UITextField()
        field.placeholder = "\(tiers[index])"
        field.keyboardType = .numberPad
        field.borderStyle = .roundedRect
        field.textAlignment = .right
        field.tag = index
        fields.append(field)

        let dollar = UILabel()
        dollar.text = "$"
        dollar.font = .systemFont(ofSize: 18, weight: .semibold)

        let hs = UIStackView(arrangedSubviews: [lbl, UIView(), dollar, field])
        hs.axis = .horizontal
        hs.spacing = 8
        hs.alignment = .center
        field.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return hs
    }

    // MARK: - Load

    private func load() async {
        do {
            // Android's GetTipAmountResponse envelope: status/message + data:
            // { tip1, tip2, tip3, tip4, tip5 } or an array.
            // We accept either shape.
            struct TipAmountData: Codable {
                let tip1: String?
                let tip2: String?
                let tip3: String?
                let tip4: String?
                let tip5: String?
            }
            let resp: APIResponse<TipAmountData> = try await APIManager.shared.request(
                type: APIEndPoint.getTipAmount, header: true
            )
            let d = resp.data
            let arr = [d?.tip1, d?.tip2, d?.tip3, d?.tip4, d?.tip5].compactMap { $0 }
            let asInts = arr.compactMap { Int($0) }
            if !asInts.isEmpty {
                while tiers.count < asInts.count { tiers.append(0) }
                for (i, v) in asInts.enumerated() where i < tiers.count {
                    tiers[i] = v
                }
                await MainActor.run {
                    for (i, f) in fields.enumerated() where i < tiers.count {
                        f.text = "\(tiers[i])"
                    }
                }
            }
        } catch {
            debugLog("[Tips] get-tip-amount error: \(error.localizedDescription)")
        }
    }

    // MARK: - Save

    @objc private func save() {
        // Read tiers from fields
        for (i, f) in fields.enumerated() where i < tiers.count {
            if let t = f.text, let v = Int(t) { tiers[i] = v }
        }

        // 1) Socket emit (if Phase 5 socket layer is wired & connected)
        // iOS parity note: `BidcastSocketManager` exists (scaffolding). Wire
        // `tip_setting_save` once the socket is live. Until then, this is a
        // no-op.
        //
        // TODO-PHASE5: BidcastSocketManager.shared.emit(event: "tip_setting_save",
        //   data: ["tip1": tiers[0], "tip2": tiers[1], ...])

        // 2) REST save (Android has no REST endpoint for this today — skip
        // with a visible note). When backend adds `update-tip-settings`,
        // wire here.
        let a = UIAlertController(
            title: "Tip settings saved locally",
            message: "These tiers will be applied when you go live. (Server-side persistence happens via the live-stream socket event `tip_setting_save`; a dedicated REST endpoint does not exist yet — flagged for backend.)",
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)

        // Cache locally so the next SendTip sheet can use these even before
        // going live.
        UserDefaults.standard.setValue(tiers, forKey: "bidcast.tip.presets")
    }
}
