//
//  NotificationSettingsViewController.swift
//  BidCast — iOS parity Phase 3b (2026-04-22)
//
//  Mirrors Android `NotificationSettingFragment`.
//  GET  /api/setting/list   -> load current toggles
//  POST /api/setting/store  -> update a single toggle
//

import UIKit
import SVProgressHUD

final class NotificationSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var data: SettingListData?

    /// Toggles rendered in order. Each entry maps a display label to a
    /// keyPath on `SettingListData` and a server key used by setting/store.
    private struct Toggle {
        let title: String
        let key: String        // server key
        let get: (SettingListData?) -> Bool
    }
    private let toggles: [Toggle] = [
        .init(title: "Direct messages", key: "direct_message", get: { $0?.directMessage ?? true }),
        .init(title: "Receive gifts", key: "receive_gifts", get: { $0?.receiveGifts ?? true }),
        .init(title: "Activity status", key: "activity_status", get: { $0?.activityStatus ?? true }),
        .init(title: "Haptic feedback", key: "haptic_feedback", get: { $0?.hapticFeedback ?? true }),
        .init(title: "Save past shows", key: "save_past_shows", get: { $0?.savePastShows ?? true }),
        .init(title: "Enable clips", key: "enable_clips", get: { $0?.enableClips ?? true }),
        .init(title: "Private entry", key: "enable_private_entry", get: { $0?.enablePrivateEntry ?? false }),
        .init(title: "Show reward status", key: "show_reward_status", get: { $0?.showRewardStatus ?? true }),
        .init(title: "Show seller tools", key: "show_seller_tools", get: { $0?.showSellerTools ?? true }),
        .init(title: "Suggest my account", key: "suggest_my_account", get: { $0?.suggestMyAccount ?? true }),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications & Privacy"
        view.backgroundColor = .systemGroupedBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "toggle")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        load()
    }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let resp: SettingListResponse = try await APIManager.shared.request(
                    type: .settingsList, header: true
                )
                self.data = resp.data
                self.tableView.reloadData()
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    private func save(key: String, value: Bool) {
        Task {
            do {
                let fields = [key: value ? "1" : "0"]
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .settingsStore(param: SettingStoreRequest.empty),
                    fields: fields, header: true
                )
            } catch {
                await MainActor.run {
                    self.p3Alert(title: "Save failed",
                                 message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { toggles.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toggle", for: indexPath)
        let toggle = toggles[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = toggle.title
        cell.contentConfiguration = cfg
        cell.selectionStyle = .none

        let sw = UISwitch()
        sw.isOn = toggle.get(data)
        sw.tag = indexPath.row
        sw.addTarget(self, action: #selector(switched(_:)), for: .valueChanged)
        cell.accessoryView = sw
        return cell
    }

    @objc private func switched(_ sw: UISwitch) {
        let t = toggles[sw.tag]
        save(key: t.key, value: sw.isOn)
    }
}

// Empty init helper so the enum's `settingsStore` case can accept a
// placeholder request when we're sending the real body via multipart form.
extension SettingStoreRequest {
    static var empty: SettingStoreRequest {
        SettingStoreRequest(
            activityStatus: nil, directMessage: nil, enableClips: nil,
            enablePrivateEntry: nil, hapticFeedback: nil, receiveGifts: nil,
            savePastShows: nil, showRewardStatus: nil, showSellerTools: nil,
            suggestMyAccount: nil
        )
    }
}
