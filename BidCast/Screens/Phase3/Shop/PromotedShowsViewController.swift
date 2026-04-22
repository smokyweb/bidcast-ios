//
//  PromotedShowsViewController.swift
//  BidCast — iOS parity Phase 3e (2026-04-22)
//
//  Shows the seller's currently-promoted shows.
//  GET /api/get-promote-show
//

import UIKit
import SVProgressHUD

final class PromotedShowsViewController: P3ListViewController {

    // Android's GetPromotePlansResponse / GetPromoteToolsDetailsResponse
    // are heavy; for Phase 3 we render a minimal list using AnyCodable
    // decode of the `data` array. Real wiring waits for backend contract
    // confirmation in Phase 4.
    private var items: [[String: AnyCodable]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Promoted Shows"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ps")
        emptyState.update(title: "No promoted shows",
                          message: "Boost a show to see performance metrics here.")
        load()
    }

    override func reloadData() { load() }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss(); self.stopRefresh() }
            do {
                let resp: APIEmptyResponse = try await APIManager.shared.request(
                    type: .getPromoteShowList, header: true
                )
                // Best-effort: if backend returns `data: [ {...}, {...} ]`,
                // pull the dicts so we can render a light-weight list.
                if let arr = resp.data?.value as? [Any?] {
                    self.items = arr.compactMap { raw -> [String: AnyCodable]? in
                        // AnyCodable stores dicts as [String: Any?]
                        if let d = raw as? [String: Any?] {
                            return Dictionary(uniqueKeysWithValues: d.map { ($0.key, AnyCodable($0.value as Any)) })
                        }
                        if let d = raw as? [String: Any] {
                            return Dictionary(uniqueKeysWithValues: d.map { ($0.key, AnyCodable($0.value)) })
                        }
                        return nil
                    }
                }
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.items.isEmpty
            } catch {
                self.emptyStateIsVisible = true
                debugLog("getPromoteShowList: \(error.localizedDescription)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ps", for: indexPath)
        var cfg = cell.defaultContentConfiguration()
        let item = items[indexPath.row]
        cfg.text = (item["title"]?.value as? String) ?? (item["show_title"]?.value as? String) ?? "Promoted show"
        if let created = item["created_at"]?.value as? String {
            cfg.secondaryText = P3Format.date(created)
        }
        cfg.image = UIImage(systemName: "megaphone")
        cell.contentConfiguration = cfg
        // Hint when the row is tappable-to-watch
        if watchableShow(from: item) != nil {
            cfg.image = UIImage(systemName: "dot.radiowaves.left.and.right")
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        cell.contentConfiguration = cfg
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < items.count else { return }
        guard let show = watchableShow(from: items[indexPath.row]) else { return }
        LiveShowLauncher.launchViewer(from: self, show: show)
    }

    /// Build a minimal Show just well enough for LiveShowLauncher to open
    /// the viewer screen. Returns nil if the promoted item is not currently
    /// live / missing connection info.
    private func watchableShow(from item: [String: AnyCodable]) -> Show? {
        let roomId = (item["room_id"]?.value as? String).flatMap { $0.isEmpty ? nil : $0 }
        let rtc = (item["rtc_token"]?.value as? String).flatMap { $0.isEmpty ? nil : $0 }
        guard let roomId = roomId, let rtc = rtc else { return nil }
        return Show(
            id: item["id"]?.value as? Int,
            userId: item["user_id"]?.value as? Int,
            title: (item["title"]?.value as? String) ?? (item["show_title"]?.value as? String),
            date: item["date"]?.value as? String,
            time: item["time"]?.value as? String,
            categoryId: item["category_id"]?.value as? Int,
            subCategoryId: item["sub_category_id"]?.value as? Int,
            auctionTypeId: item["auction_type_id"]?.value as? Int,
            isLive: item["is_live"]?.value as? Bool,
            isExplicit: nil, isRepeat: nil, isPromote: nil,
            language: nil, repeatValue: nil,
            rtcToken: rtc,
            roomId: roomId,
            showDiscoverability: nil,
            startedAt: nil, promoteShowId: nil, promotedAt: nil,
            recordingResourceId: nil, recordingSid: nil,
            shareCount: nil, viewerCount: nil, latestViewerCount: nil,
            totalOrders: nil, totalSalesAmount: nil,
            productIds: nil, products: nil,
            thumbnail: nil, imgThumbnail: nil,
            category: nil, subCategory: nil, user: nil, auction: nil
        )
    }
}
