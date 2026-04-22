//
//  WalletViewController.swift
//  BidCast — iOS parity Phase 4b (2026-04-22)
//
//  Replaces the Phase-3 `PhaseLockedViewController` "Wallet" placeholder.
//  Renders available balance + processing + available-for-payout (from
//  `GET api/wallet-info`) and a paginated transactions list (from
//  `POST api/transaction-history/listing`).
//
//  Android parity:
//    - Android `WalletFragment` / `WalletViewFragment` -> `api/wallet-info`
//    - Android `TransactionsFragment` -> `api/transaction-history/listing`
//    - Android `PayoutFragment` -> `api/stripe/payout-history` (shown as "Recent payouts")
//
//  All three Android codables are already imported from Phase 2's
//  PaymentModels.swift — we just wire them.
//

import UIKit

final class WalletViewController: UIViewController {

    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let refresh = UIRefreshControl()

    // Summary cards
    private let balanceLabel = UILabel()
    private let availableForPayoutLabel = UILabel()
    private let processingLabel = UILabel()

    // Segmented history
    private let segment = UISegmentedControl(items: ["Transactions", "Payouts"])
    private let listContainer = UIView()
    private let listTable = UITableView(frame: .zero, style: .plain)

    // Data
    private var transactions: [TransactionEntry] = []
    private var payouts: [PayoutEntry] = []
    private var txPage = 1
    private var payoutPage = 1
    private var txHasMore = true
    private var payoutHasMore = true
    private var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallet"
        view.backgroundColor = .systemGroupedBackground

        let requestPayout = UIBarButtonItem(
            title: "Payout",
            style: .plain,
            target: self,
            action: #selector(requestPayoutTapped)
        )
        navigationItem.rightBarButtonItem = requestPayout

        setupLayout()
        refresh.addTarget(self, action: #selector(pulledToRefresh), for: .valueChanged)
        scroll.refreshControl = refresh

        listTable.dataSource = self
        listTable.delegate = self
        listTable.register(P4TxCell.self, forCellReuseIdentifier: "tx")
        listTable.separatorInset = .zero
        listTable.rowHeight = UITableView.automaticDimension
        listTable.estimatedRowHeight = 64

        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        Task { await reloadAll() }
    }

    // MARK: - Layout

    private func setupLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        stack.addArrangedSubview(makeBalanceCard())
        stack.addArrangedSubview(segment)
        stack.addArrangedSubview(listContainer)

        listContainer.translatesAutoresizingMaskIntoConstraints = false
        listContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 260).isActive = true
        listTable.translatesAutoresizingMaskIntoConstraints = false
        listContainer.addSubview(listTable)
        NSLayoutConstraint.activate([
            listTable.topAnchor.constraint(equalTo: listContainer.topAnchor),
            listTable.leadingAnchor.constraint(equalTo: listContainer.leadingAnchor),
            listTable.trailingAnchor.constraint(equalTo: listContainer.trailingAnchor),
            listTable.bottomAnchor.constraint(equalTo: listContainer.bottomAnchor)
        ])
    }

    private func makeBalanceCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 14
        card.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Balance"
        title.font = .systemFont(ofSize: 13, weight: .medium)
        title.textColor = .secondaryLabel

        balanceLabel.text = "—"
        balanceLabel.font = .systemFont(ofSize: 34, weight: .heavy)

        let line = UIStackView()
        line.axis = .horizontal
        line.distribution = .fillEqually
        line.spacing = 12

        availableForPayoutLabel.numberOfLines = 2
        availableForPayoutLabel.font = .systemFont(ofSize: 13)
        availableForPayoutLabel.textColor = .secondaryLabel

        processingLabel.numberOfLines = 2
        processingLabel.font = .systemFont(ofSize: 13)
        processingLabel.textColor = .secondaryLabel

        line.addArrangedSubview(availableForPayoutLabel)
        line.addArrangedSubview(processingLabel)

        let s = UIStackView(arrangedSubviews: [title, balanceLabel, line])
        s.axis = .vertical
        s.spacing = 4
        s.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(s)
        NSLayoutConstraint.activate([
            s.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            s.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            s.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            s.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    // MARK: - Actions

    @objc private func pulledToRefresh() {
        Task { await reloadAll() }
    }

    @objc private func segmentChanged() {
        listTable.reloadData()
    }

    @objc private func requestPayoutTapped() {
        let vc = PayoutRequestViewController()
        vc.onSubmitted = { [weak self] in
            guard let self = self else { return }
            Task { await self.reloadAll() }
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    // MARK: - Networking

    private func reloadAll() async {
        txPage = 1; payoutPage = 1
        txHasMore = true; payoutHasMore = true
        transactions.removeAll()
        payouts.removeAll()
        await loadWallet()
        await loadTransactions()
        await loadPayouts()
        await MainActor.run {
            self.refresh.endRefreshing()
            self.listTable.reloadData()
        }
    }

    private func loadWallet() async {
        do {
            let resp: WalletInfoResponse = try await APIManager.shared.request(type: APIEndPoint.walletInfo, header: true)
            let d = resp.data
            await MainActor.run {
                balanceLabel.text = Self.money(d?.availableBalance)
                availableForPayoutLabel.text = "Available for payout\n\(Self.money(d?.availableForPayout))"
                processingLabel.text = "Processing\n\(Self.money(d?.processing))"
            }
        } catch {
            debugLog("[Wallet] wallet-info error: \(error.localizedDescription)")
        }
    }

    private func loadTransactions() async {
        guard txHasMore, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let resp: GetTransactionsHistoryResponse = try await APIManager.shared.postMultipartForm(
                type: .getTransactionsHistory(param: ["page": "\(txPage)", "status": ""]),
                fields: ["page": "\(txPage)", "status": ""],
                header: true
            )
            let items = resp.data ?? []
            transactions.append(contentsOf: items)
            if items.isEmpty || (resp.currentPage ?? txPage) >= (resp.totalPage ?? txPage) {
                txHasMore = false
            } else {
                txPage += 1
            }
        } catch {
            debugLog("[Wallet] transactions error: \(error.localizedDescription)")
            txHasMore = false
        }
    }

    private func loadPayouts() async {
        guard payoutHasMore else { return }
        do {
            let resp: PayoutHistoryResponse = try await APIManager.shared.postMultipartForm(
                type: .getPayoutHistory(param: ["page": "\(payoutPage)"]),
                fields: ["page": "\(payoutPage)"],
                header: true
            )
            let items = resp.data ?? []
            payouts.append(contentsOf: items)
            if items.isEmpty || (resp.currentPage ?? payoutPage) >= (resp.totalPage ?? payoutPage) {
                payoutHasMore = false
            } else {
                payoutPage += 1
            }
        } catch {
            debugLog("[Wallet] payout history error: \(error.localizedDescription)")
            payoutHasMore = false
        }
    }

    // MARK: - Utilities

    fileprivate static func money(_ v: Double?) -> String {
        guard let v = v else { return "$0.00" }
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        return f.string(from: NSNumber(value: v)) ?? "$\(v)"
    }

    fileprivate static func moneyStr(_ s: String?) -> String {
        if let s = s, let d = Double(s) { return money(d) }
        return s ?? "—"
    }
}

extension WalletViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        segment.selectedSegmentIndex == 0 ? transactions.count : payouts.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "tx", for: indexPath) as! P4TxCell
        if segment.selectedSegmentIndex == 0 {
            let tx = transactions[indexPath.row]
            cell.configure(
                title: tx.counterpartyName ?? tx.buyerName ?? tx.type ?? "Transaction",
                subtitle: tx.date ?? "",
                amount: WalletViewController.moneyStr(tx.total),
                status: tx.status
            )
        } else {
            let p = payouts[indexPath.row]
            cell.configure(
                title: "Payout",
                subtitle: p.date ?? "",
                amount: p.total.map { "$\($0)" } ?? "—",
                status: p.status
            )
        }
        return cell
    }

    func tableView(_ tv: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = segment.selectedSegmentIndex == 0 ? transactions.count : payouts.count
        if indexPath.row == count - 1 {
            Task {
                if segment.selectedSegmentIndex == 0 { await loadTransactions() }
                else { await loadPayouts() }
                await MainActor.run { self.listTable.reloadData() }
            }
        }
    }
}

// MARK: - Cell

final class P4TxCell: UITableViewCell {
    private let titleLbl = UILabel()
    private let subLbl = UILabel()
    private let amountLbl = UILabel()
    private let statusLbl = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLbl.font = .systemFont(ofSize: 15, weight: .semibold)
        subLbl.font = .systemFont(ofSize: 12)
        subLbl.textColor = .secondaryLabel
        amountLbl.font = .systemFont(ofSize: 15, weight: .semibold)
        amountLbl.textAlignment = .right
        statusLbl.font = .systemFont(ofSize: 11, weight: .medium)
        statusLbl.textAlignment = .right
        statusLbl.textColor = .secondaryLabel

        let left = UIStackView(arrangedSubviews: [titleLbl, subLbl])
        left.axis = .vertical
        left.spacing = 2

        let right = UIStackView(arrangedSubviews: [amountLbl, statusLbl])
        right.axis = .vertical
        right.spacing = 2
        right.alignment = .trailing

        let row = UIStackView(arrangedSubviews: [left, right])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        left.setContentHuggingPriority(.defaultLow, for: .horizontal)
        right.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, subtitle: String, amount: String, status: String?) {
        titleLbl.text = title
        subLbl.text = subtitle
        amountLbl.text = amount
        statusLbl.text = status?.capitalized
    }
}
