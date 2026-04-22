//
//  UserSearchViewController.swift
//  BidCast — iOS parity Phase 3f (2026-04-22)
//
//  POST /api/user/searching — user search.
//

import UIKit

final class UserSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var results: [SearchUserEntry] = []
    private var task: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find people"
        view.backgroundColor = .systemBackground
        searchBar.delegate = self
        searchBar.placeholder = "Search sellers, buyers, usernames"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.returnKeyType = .search

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "u")

        view.addSubview(searchBar)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        runSearch(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        runSearch(searchBar.text ?? ""); searchBar.resignFirstResponder()
    }

    private func runSearch(_ query: String) {
        task?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else { self.results = []; self.tableView.reloadData(); return }
        task = Task { @MainActor in
            do {
                let req = SearchRequest(search: trimmed, page: 1)
                let resp: UserSearchingResponse = try await APIManager.shared.request(
                    type: .userSearching(param: req), header: true
                )
                self.results = resp.data ?? []
                self.tableView.reloadData()
            } catch {
                debugLog("userSearching error: \(error.localizedDescription)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { results.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "u", for: indexPath)
        let u = results[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = u.name ?? u.username ?? "User"
        cfg.secondaryText = "@\(u.username ?? "—")"
        cfg.image = UIImage(systemName: "person.crop.circle")
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let u = results[indexPath.row]
        guard let uid = u.id else { return }
        p3Push(SellerPublicProfileViewController(userId: uid))
    }
}
