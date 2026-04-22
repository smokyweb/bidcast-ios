//
//  BlockedUsersViewController.swift
//  BidCast — iOS parity Phase 3c (2026-04-22)
//
//  Mirrors Android `BlockedUsersFragment`. GET /api/blocked-users, unblock
//  via POST /api/block-unblock.
//

import UIKit
import SVProgressHUD

final class BlockedUsersViewController: P3ListViewController {

    private var users: [BlockedUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Blocked Users"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "blocked")
        emptyState.update(title: "No blocked users",
                          message: "Anyone you block will show up here.")
        load()
    }

    override func reloadData() { load() }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss(); self.stopRefresh() }
            do {
                let resp: GetBlockedUsersResponse = try await APIManager.shared.request(
                    type: .getBlockedUsers, header: true
                )
                let list = (resp.data?.blockedByMe ?? []).compactMap { $0 }
                self.users = list
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.users.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blocked", for: indexPath)
        var cfg = cell.defaultContentConfiguration()
        let u = users[indexPath.row]
        cfg.text = u.name ?? "User"
        cell.contentConfiguration = cfg
        cell.accessoryType = .none
        return cell
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let row = indexPath.row
        let unblock = UIContextualAction(style: .normal, title: "Unblock") { [weak self] _, _, done in
            guard let self = self else { done(false); return }
            let u = self.users[row]
            guard let uid = u.id else { done(false); return }
            ChatStoreRegistry.active.unblockUser(userId: uid) { res in
                DispatchQueue.main.async {
                    switch res {
                    case .success:
                        self.users.remove(at: row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        done(true)
                    case .failure(let err):
                        self.p3Alert(message: err.localizedDescription); done(false)
                    }
                }
            }
        }
        unblock.backgroundColor = .systemGreen
        return UISwipeActionsConfiguration(actions: [unblock])
    }
}
