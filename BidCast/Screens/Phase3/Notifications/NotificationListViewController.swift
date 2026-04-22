//
//  NotificationListViewController.swift
//  BidCast — iOS parity Phase 3b (2026-04-22)
//

import UIKit
import SVProgressHUD

final class NotificationListViewController: P3ListViewController {

    private let vm = NotificationListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain, target: self, action: #selector(openSettings))

        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.reuseID)
        emptyState.update(title: "No notifications",
                          message: "You're all caught up.")

        vm.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
            self.emptyStateIsVisible = self.vm.items.isEmpty
            self.stopRefresh()
        }
        vm.onError = { [weak self] msg in
            self?.stopRefresh()
            self?.p3Alert(message: msg)
        }
        vm.onLoadingChange = { loading in
            if loading { SVProgressHUD.show() } else { SVProgressHUD.dismiss() }
        }
        vm.loadInitial()
    }

    override func reloadData() { vm.loadInitial() }

    @objc private func openSettings() {
        p3Push(NotificationSettingsViewController())
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.reuseID,
                                                 for: indexPath) as! NotificationCell
        cell.configure(with: vm.items[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let del = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.vm.delete(at: indexPath.row)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [del])
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= vm.items.count - 3 { vm.loadNext() }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO-PHASE3/4: Route by `type` — e.g. `order` -> OrderDetail, `live` -> Live viewer,
        // `chat` -> ChatThread. Once live + chat exist they'll slot in here.
        let n = vm.items[indexPath.row]
        p3Alert(title: n.title ?? "Notification",
                message: n.message ?? "")
    }
}
