//
//  PaymentMethodsListViewController.swift
//  BidCast — iOS parity Phase 4c (2026-04-22)
//
//  Lists saved cards from `GET api/get-card`.
//  Swipe actions:
//    - Set default -> POST api/set-default-card
//    - Delete      -> POST api/delete-card
//
//  Matches Android's AddPaymentCardActivity card list.
//

import UIKit

final class PaymentMethodsListViewController: UIViewController {

    /// When non-nil, tapping a row invokes this and pops the VC. Used by
    /// Checkout to pick a card.
    var onPick: ((PaymentCard) -> Void)?

    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private let refresh = UIRefreshControl()
    private var cards: [PaymentCard] = []
    private var page = 1
    private var hasMore = true
    private var isLoading = false
    private let empty = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment methods"
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            primaryAction: UIAction { [weak self] _ in self?.presentAddCard() }
        )

        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "card")
        refresh.addTarget(self, action: #selector(load), for: .valueChanged)
        table.refreshControl = refresh
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        empty.text = "No payment methods yet.\nTap + to add one."
        empty.textAlignment = .center
        empty.textColor = .secondaryLabel
        empty.numberOfLines = 0
        empty.font = .systemFont(ofSize: 14)
        empty.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(empty)
        NSLayoutConstraint.activate([
            empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            empty.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            empty.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        Task { await reload() }
    }

    @objc private func load() {
        Task { await reload() }
    }

    private func reload() async {
        page = 1
        hasMore = true
        cards.removeAll()
        await loadPage()
    }

    private func loadPage() async {
        guard hasMore, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let resp: GetPaymentCardsResponse = try await APIManager.shared.request(
                type: APIEndPoint.getPaymentCard, header: true
            )
            let items = (resp.data ?? []).compactMap { $0 }
            cards.append(contentsOf: items)
            if items.isEmpty || (resp.currentPage ?? page) >= (resp.totalPages ?? page) {
                hasMore = false
            } else {
                page += 1
            }
            await MainActor.run {
                self.empty.isHidden = !self.cards.isEmpty
                self.refresh.endRefreshing()
                self.table.reloadData()
            }
        } catch {
            debugLog("[Payments] getPaymentCard error: \(error.localizedDescription)")
            await MainActor.run {
                self.empty.isHidden = !self.cards.isEmpty
                self.refresh.endRefreshing()
            }
        }
    }

    private func presentAddCard() {
        let vc = AddCardViewController()
        vc.onAdded = { [weak self] in
            Task { await self?.reload() }
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension PaymentMethodsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection: Int) -> Int { cards.count }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tv.dequeueReusableCell(withIdentifier: "card", for: indexPath)
        let card = cards[indexPath.row]
        var cfg = c.defaultContentConfiguration()
        cfg.text = "•••• \(card.last4 ?? "----")"
        cfg.secondaryText = String(format: "Exp %02d/%d%@",
                                   card.expMonth ?? 0,
                                   card.expYear ?? 0,
                                   card.isDefault == true ? " · Default" : "")
        cfg.image = UIImage(systemName: "creditcard")
        c.contentConfiguration = cfg
        c.accessoryType = (card.isDefault == true) ? .checkmark : .none
        return c
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        let card = cards[indexPath.row]
        if let pick = onPick {
            pick(card)
            navigationController?.popViewController(animated: true)
            return
        }
        // No pick callback — show action sheet
        let sheet = UIAlertController(title: "•••• \(card.last4 ?? "")", message: nil, preferredStyle: .actionSheet)
        if card.isDefault != true {
            sheet.addAction(UIAlertAction(title: "Set default", style: .default) { _ in
                Task { await self.setDefault(cardId: card.cardId ?? "") }
            })
        }
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            Task { await self.delete(cardId: card.cardId ?? "") }
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    func tableView(_ tv: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let card = cards[indexPath.row]
        var actions: [UIContextualAction] = []
        let del = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            Task { await self?.delete(cardId: card.cardId ?? ""); done(true) }
        }
        actions.append(del)
        if card.isDefault != true {
            let mark = UIContextualAction(style: .normal, title: "Default") { [weak self] _, _, done in
                Task { await self?.setDefault(cardId: card.cardId ?? ""); done(true) }
            }
            mark.backgroundColor = .systemBlue
            actions.append(mark)
        }
        return UISwipeActionsConfiguration(actions: actions)
    }

    private func setDefault(cardId: String) async {
        do {
            let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                type: .setDefaultCard(param: ["card_id": cardId]),
                fields: ["card_id": cardId],
                header: true
            )
            await reload()
        } catch {
            debugLog("[Payments] set-default-card error: \(error.localizedDescription)")
        }
    }

    private func delete(cardId: String) async {
        do {
            let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                type: .deleteCard(param: ["card_id": cardId]),
                fields: ["card_id": cardId],
                header: true
            )
            await reload()
        } catch {
            debugLog("[Payments] delete-card error: \(error.localizedDescription)")
        }
    }
}
