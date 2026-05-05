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
    private var rawToolsPayload: [String: Any]?

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
                if let resp: APIResponse<AnyCodable> = try? await APIManager.shared.request(
                    type: .getPromoteTools, header: true
                ) {
                    self.rawToolsPayload = resp.data?.value as? [String: Any]
                    self.tools = Self.parsePromoteTools(from: self.rawToolsPayload)
                    self.render()
                    return
                }

                let resp: GetPromoteToolsResponse = try await APIManager.shared.request(
                    type: .getPromoteTools, header: true
                )
                self.tools = resp.data
                self.rawToolsPayload = nil
                self.render()
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    private func render() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let d = tools else { return }

        if let t = displayPromoteTitle(from: d) { stack.addArrangedSubview(headline(t)) }
        if let p = displayPromoteDetails(from: d) { stack.addArrangedSubview(para(p)) }

        if let features = displayFeatures(from: d), !features.isEmpty {
            stack.addArrangedSubview(sectionLabel("Features"))
            for f in features {
                stack.addArrangedSubview(featureCard(title: f.title ?? "",
                                                     description: f.description ?? ""))
            }
        }
        stack.addArrangedSubview(sectionLabel(displayShowTitle(from: d) ?? "Promote a show"))
        if let reach = displayReachSummary(from: d) {
            stack.addArrangedSubview(para(reach))
        }
        if let details = displayShowDetails(from: d) {
            stack.addArrangedSubview(para(details))
        }

        // iOS parity phase 4h (2026-04-22): real Buy flow.
        // Android's `schedule-show/store-promote-show` takes two multipart
        // fields: `schedule_show_id` + `promote_show_id`. Payment happens
        // server-side using the user's default saved card. We surface an
        // "Apply to a show" picker rather than a pure "Buy" CTA since
        // Android never charges until the show is actually linked.
        let buy = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Apply to a show"
        cfg.baseBackgroundColor = .systemBlue
        buy.configuration = cfg
        buy.addAction(UIAction { [weak self] _ in self?.presentApplyFlow() }, for: .touchUpInside)
        stack.addArrangedSubview(buy)

        stack.addArrangedSubview(para(
            "Your default saved card is charged when the promotion is applied to a scheduled show."))
    }


    private func displayPromoteTitle(from data: PromoteToolsData) -> String? {
        data.promoteTitle ?? stringValue(rawToolsPayload?["promote_title"]) ?? stringValue(rawToolsPayload?["promoteTitle"])
    }

    private func displayPromoteDetails(from data: PromoteToolsData) -> String? {
        data.promoteDetails ?? stringValue(rawToolsPayload?["promote_details"]) ?? stringValue(rawToolsPayload?["promoteDetails"])
    }

    private func displayShowTitle(from data: PromoteToolsData) -> String? {
        data.showTitle ?? stringValue(rawToolsPayload?["show_title"]) ?? stringValue(rawToolsPayload?["showTitle"])
    }

    private func displayShowDetails(from data: PromoteToolsData) -> String? {
        data.showDetails ?? stringValue(rawToolsPayload?["show_details"]) ?? stringValue(rawToolsPayload?["showDetails"])
    }

    private func displayFeatures(from data: PromoteToolsData) -> [PremierShopFeature]? {
        if let features = data.features?.compactMap({ $0 }), !features.isEmpty {
            return features
        }
        guard let raw = rawToolsPayload?["features"] as? [Any] else { return nil }
        return raw.compactMap { item in
            guard let dict = item as? [String: Any] else { return nil }
            return PremierShopFeature(
                title: stringValue(dict["title"]),
                description: stringValue(dict["description"]),
                icon: stringValue(dict["icon"])
            )
        }
    }

    private func displayReachSummary(from data: PromoteToolsData) -> String? {
        let followers = data.showOptions?.followers ?? nestedInt(rawToolsPayload, key: "show_options", nestedKeys: ["Followers", "followers"])
        let shows = data.showOptions?.shows ?? nestedInt(rawToolsPayload, key: "show_options", nestedKeys: ["Shows", "shows"])
        let views = data.showOptions?.views ?? nestedInt(rawToolsPayload, key: "show_options", nestedKeys: ["Views", "views"])
        guard followers != nil || shows != nil || views != nil else { return nil }
        return "Reach: \(followers ?? 0) followers · \(shows ?? 0) shows · \(views ?? 0) views"
    }

    private func stringValue(_ any: Any?) -> String? {
        if let s = any as? String, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return s }
        if let n = any as? NSNumber { return n.stringValue }
        return nil
    }

    private func nestedInt(_ dict: [String: Any]?, key: String, nestedKeys: [String]) -> Int? {
        guard let raw = dict?[key] as? [String: Any] else { return nil }
        for nestedKey in nestedKeys {
            if let v = intValue(raw[nestedKey]) { return v }
        }
        return nil
    }

    private func intValue(_ any: Any?) -> Int? {
        if let i = any as? Int { return i }
        if let s = any as? String { return Int(s) }
        if let n = any as? NSNumber { return n.intValue }
        return nil
    }

    private static func parsePromoteTools(from raw: [String: Any]?) -> PromoteToolsData? {
        guard let raw else { return nil }

        let features: [PremierShopFeature?]? = (raw["features"] as? [Any])?.map { item in
            guard let dict = item as? [String: Any] else { return nil }
            return PremierShopFeature(
                title: stringValueStatic(dict["title"]),
                description: stringValueStatic(dict["description"]),
                icon: stringValueStatic(dict["icon"])
            )
        }

        let showOptionsDict = raw["show_options"] as? [String: Any]
        let showOptions = PromoteShowOptions(
            followers: intValueStatic(showOptionsDict?["Followers"] ?? showOptionsDict?["followers"]),
            shows: intValueStatic(showOptionsDict?["Shows"] ?? showOptionsDict?["shows"]),
            views: intValueStatic(showOptionsDict?["Views"] ?? showOptionsDict?["views"])
        )

        return PromoteToolsData(
            id: intValueStatic(raw["id"]),
            promoteTitle: stringValueStatic(raw["promote_title"] ?? raw["promoteTitle"]),
            promoteDetails: stringValueStatic(raw["promote_details"] ?? raw["promoteDetails"]),
            showTitle: stringValueStatic(raw["show_title"] ?? raw["showTitle"]),
            showIcon: stringValueStatic(raw["show_icon"] ?? raw["showIcon"]),
            showDetails: stringValueStatic(raw["show_details"] ?? raw["showDetails"]),
            features: features,
            showOptions: showOptions
        )
    }

    private static func stringValueStatic(_ any: Any?) -> String? {
        if let s = any as? String, !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return s }
        if let n = any as? NSNumber { return n.stringValue }
        return nil
    }

    private static func intValueStatic(_ any: Any?) -> Int? {
        if let i = any as? Int { return i }
        if let s = any as? String { return Int(s) }
        if let n = any as? NSNumber { return n.intValue }
        return nil
    }

    // MARK: - Apply flow (phase 4h)

    private func presentApplyFlow() {
        let a = UIAlertController(
            title: "Apply promotion",
            message: "Enter the Schedule Show ID and Promotion Tool ID. (A dedicated show-picker UI lives in Phase 4a follow-up.)",
            preferredStyle: .alert
        )
        a.addTextField { $0.placeholder = "schedule_show_id"; $0.keyboardType = .numberPad }
        a.addTextField { $0.placeholder = "promote_show_id";  $0.keyboardType = .numberPad }
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        a.addAction(UIAlertAction(title: "Apply", style: .default) { [weak self, weak a] _ in
            guard let self = self,
                  let showId = a?.textFields?.first?.text, !showId.isEmpty,
                  let promoId = a?.textFields?.last?.text, !promoId.isEmpty else { return }
            Task { await self.buyPromotion(showId: showId, promoId: promoId) }
        })
        present(a, animated: true)
    }

    private func buyPromotion(showId: String, promoId: String) async {
        // QA-NOTE: the `PromoteShowRequest` Codable uses `show_id` /
        // `promote_plan_id` — Android's Retrofit actually expects
        // `schedule_show_id` / `promote_show_id`. We route through
        // postMultipartForm's `fields` dict which is authoritative; the
        // Codable is only used for typed callers.
        let req = PromoteShowRequest(
            showId: Int(showId) ?? 0,
            promotePlanId: Int(promoId)
        )
        let fields: [String: String] = [
            "schedule_show_id": showId,
            "promote_show_id": promoId
        ]
        do {
            let resp: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                type: .promoteShow(param: req),
                fields: fields,
                header: true
            )
            await MainActor.run {
                let a = UIAlertController(
                    title: "Promotion applied",
                    message: resp.message ?? "Your show is now being promoted.",
                    preferredStyle: .alert
                )
                a.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(a, animated: true)
            }
        } catch {
            await MainActor.run { self.p3Alert(message: error.localizedDescription) }
        }
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
