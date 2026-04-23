//
//  BidsListViewController.swift
//  BidCast — iOS parity Phase 8 / P1.7 (2026-04-23)
//
//  Mirrors Android `BidsFragment` (dashboard/BidsFragment.kt).
//  Backed by GET api/bid/fetch?page=N (APIEndPoint.fetchBids).
//  Tap row → opens ProductDetailsViewController with the bid's product_id
//  (matching Android which pushes ProductDetailsActivity with the productId).
//

import UIKit
import SVProgressHUD

final class BidsListViewController: P3ListViewController {

    private var items: [FetchedBid] = []
    private var paging = P3Paging()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My bids"
        tableView.register(BidsListCell.self, forCellReuseIdentifier: BidsListCell.reuseID)
        emptyState.update(title: "No bids yet",
                          message: "Bids you place on live auctions or buy-now products will show up here.")
        load(reset: true)
    }

    override func reloadData() { load(reset: true) }

    private func load(reset: Bool) {
        if reset { paging.reset(); items = [] }
        guard !paging.isLoading, paging.hasMore else { return }
        paging.isLoading = true
        if reset { SVProgressHUD.show() }

        Task { @MainActor in
            defer {
                self.paging.isLoading = false
                SVProgressHUD.dismiss()
                self.stopRefresh()
            }
            do {
                let resp: FetchBidsResponse = try await APIManager.shared.request(
                    type: .fetchBids(page: "\(self.paging.page)"), header: true
                )
                let newItems = resp.data?.compactMap { $0 } ?? []
                if reset { self.items = newItems } else { self.items.append(contentsOf: newItems) }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage, totalPages: resp.totalPage))
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.items.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BidsListCell.reuseID, for: indexPath) as! BidsListCell
        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bid = items[indexPath.row]
        guard let pid = bid.productId else { return }
        p3Push(ProductDetailsViewController(productId: pid))
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= items.count - 3 { load(reset: false) }
    }
}

// MARK: - Cell

final class BidsListCell: UITableViewCell {
    static let reuseID = "BidsListCell"

    private let thumb: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 8
        v.backgroundColor = .secondarySystemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let titleLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.numberOfLines = 2; return l
    }()
    private let bidLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = .systemBlue; return l
    }()
    private let priceLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel; return l
    }()
    private let dateLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 11)
        l.textColor = .tertiaryLabel; return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        let textStack = UIStackView(arrangedSubviews: [titleLabel, bidLabel, priceLabel, dateLabel])
        textStack.axis = .vertical; textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumb)
        contentView.addSubview(textStack)
        NSLayoutConstraint.activate([
            thumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumb.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            thumb.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            thumb.widthAnchor.constraint(equalToConstant: 64),
            thumb.heightAnchor.constraint(equalToConstant: 64),
            textStack.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: thumb.topAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with bid: FetchedBid) {
        titleLabel.text = bid.product?.title ?? "Product #\(bid.productId ?? 0)"
        bidLabel.text = "Your bid: " + P3Format.currency(bid.bidPrice)
        priceLabel.text = "List: " + P3Format.currency(bid.product?.pricing)
        dateLabel.text = P3Format.date(bid.createdAt)
        let first: String? = bid.product?.images?.compactMap({ $0 }).first
        thumb.p3Load(first, placeholder: UIImage(systemName: "photo"))
    }
}
