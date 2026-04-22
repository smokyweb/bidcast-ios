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
                if let raw = resp.data?.value as? [[String: Any]] {
                    self.items = raw.map { dict in
                        Dictionary(uniqueKeysWithValues: dict.map { ($0.key, AnyCodable($0.value)) })
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
        return cell
    }
}
