//
//  BrowseLiveShowsViewController.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  Viewer-side entry point that lists currently-live shows (Android:
//  `HomeFragment` "Live Now" carousel backed by `POST /api/get-live-show`).
//  Tapping a show resolves its LiveShowContext via LiveShowResolver and
//  opens WatchStreamViewController fullscreen.
//
//  Scope: a simple table list is enough for parity + TestFlight coverage.
//  A richer tile grid matching Android's Home carousel can land later;
//  that is UX polish, not infra.
//

import UIKit
import SVProgressHUD

public final class BrowseLiveShowsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refresh = UIRefreshControl()
    private var shows: [Show] = []
    private var isLoading = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Now"
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "liveShowCell")
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(reload), for: .valueChanged)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        reload()
    }

    // MARK: - Load

    @objc private func reload() {
        guard !isLoading else { return }
        isLoading = true
        if !refresh.isRefreshing { SVProgressHUD.show() }

        Task { @MainActor in
            defer {
                self.isLoading = false
                SVProgressHUD.dismiss()
                self.refresh.endRefreshing()
            }
            do {
                let fields: [String: String] = [
                    "type": "live",
                    "category": "",
                    "sub_category": "",
                    "search": "",
                    "page": "1"
                ]
                let resp: GetMyShowResponse = try await APIManager.shared.postMultipartForm(
                    type: .getLiveShow(param: [:]),
                    fields: fields,
                    header: true
                )
                self.shows = resp.data ?? []
                self.tableView.reloadData()
            } catch {
                let msg = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
                let alert = UIAlertController(title: "Couldn't load live shows", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "liveShowCell", for: indexPath)
        let s = shows[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = s.title ?? "Untitled show"
        let hostName: String = {
            if let f = s.user?.firstName, !f.isEmpty {
                let l = s.user?.lastName ?? ""
                return "\(f) \(l)".trimmingCharacters(in: .whitespaces)
            }
            return s.user?.name ?? s.user?.username ?? "Seller"
        }()
        let count = s.products?.count ?? s.productIds?.count ?? 0
        cfg.secondaryText = "\(hostName)  •  \(count) product\(count == 1 ? "" : "s")"
        cfg.image = UIImage(systemName: "dot.radiowaves.left.and.right")
        cfg.imageProperties.tintColor = .systemRed
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let show = shows[indexPath.row]
        // Prefer the happy path: LiveShowLauncher already handles the case
        // where rtc_token/room_id are present on the model. If they are
        // not, fall back to LiveShowResolver (async).
        if let _ = show.rtcToken, let _ = show.roomId {
            LiveShowLauncher.launchViewer(from: self, show: show)
            return
        }
        guard let showId = show.id else { return }
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let ctx = try await LiveShowResolver.resolveViewerContext(
                    showId: showId,
                    currentUserId: currentUserIdString()
                )
                let vc = WatchStreamViewController()
                vc.context = ctx
                vc.currentUserId = currentUserIdString()
                vc.currentUserName = currentUserName()
                vc.currentUserImage = currentUserImage()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            } catch {
                let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                let alert = UIAlertController(title: "Can't open show", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Local identity helpers (match LiveShowLauncher fallbacks)

    private func currentUserIdString() -> String {
        for key in ["userId", "user_id", "userID", "id", "CURRENT_USER_ID"] {
            if let v = UserDefaults.standard.string(forKey: key), !v.isEmpty { return v }
            let n = UserDefaults.standard.integer(forKey: key)
            if n > 0 { return String(n) }
        }
        return ""
    }
    private func currentUserName() -> String {
        for key in ["userName", "user_name", "firstName", "first_name"] {
            if let v = UserDefaults.standard.string(forKey: key), !v.isEmpty { return v }
        }
        return "Viewer"
    }
    private func currentUserImage() -> String {
        for key in ["profilePicture", "user_image", "avatar"] {
            if let v = UserDefaults.standard.string(forKey: key), !v.isEmpty { return v }
        }
        return ""
    }
}
