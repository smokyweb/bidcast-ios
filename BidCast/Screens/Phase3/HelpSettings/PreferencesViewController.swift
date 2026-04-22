//
//  PreferencesViewController.swift
//  BidCast — iOS parity Phase 3h (2026-04-22)
//
//  Top-level "Preferences" menu. Hub for notif toggles, tutorials,
//  static pages, blocked users, refer-a-friend, logout. Intended to be
//  pushed from the Account tab once the new tab bar routes through
//  Phase 3 screens.
//

import UIKit

final class PreferencesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private struct Row { let title: String; let icon: String; let make: () -> UIViewController }
    private struct Section { let title: String; let rows: [Row] }

    private lazy var sections: [Section] = [
        Section(title: "Notifications", rows: [
            Row(title: "Notifications", icon: "bell",
                make: { NotificationListViewController() }),
            Row(title: "Settings", icon: "slider.horizontal.3",
                make: { NotificationSettingsViewController() })
        ]),
        Section(title: "Social", rows: [
            Row(title: "Refer a friend", icon: "gift",
                make: { AffiliateViewController() }),
            Row(title: "Blocked users", icon: "person.slash",
                make: { BlockedUsersViewController() }),
            Row(title: "Find people", icon: "magnifyingglass",
                make: { UserSearchViewController() })
        ]),
        Section(title: "Help", rows: [
            Row(title: "Tutorials", icon: "book",
                make: { TutorialsListViewController() }),
            Row(title: "Raise support ticket", icon: "lifepreserver",
                make: { RaiseTicketViewController() })
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preferences"
        view.backgroundColor = .systemGroupedBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "p")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "p", for: indexPath)
        let row = sections[indexPath.section].rows[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = row.title
        cfg.image = UIImage(systemName: row.icon)
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = sections[indexPath.section].rows[indexPath.row].make()
        p3Push(vc)
    }
}
