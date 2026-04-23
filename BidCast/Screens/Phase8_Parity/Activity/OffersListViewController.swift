//
//  OffersListViewController.swift
//  BidCast — iOS parity Phase 8 / P1.7 (2026-04-23)
//
//  Mirrors Android `OfferFragment` (dashboard/OfferFragment.kt) — the
//  buyer-side offers list. POST api/offer/lists with `offer_type="user"`
//  returns the offers that the current user has made / are awaiting the
//  seller's response.
//
//  Android differences vs seller side (`SellerOffersViewController`):
//    - Seller fragment sends `offer_type="seller"`, gets offers buyers
//      made on the seller's products.
//    - Buyer fragment sends `offer_type="user"`, gets offers made BY
//      the buyer. Status badge shows pending/accepted/declined.
//

import UIKit
import SVProgressHUD

final class OffersListViewController: P3ListViewController {

    private var items: [OfferEntry] = []
    private var paging = P3Paging()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My offers"
        tableView.register(BuyerOfferCell.self, forCellReuseIdentifier: BuyerOfferCell.reuseID)
        emptyState.update(title: "No offers yet",
                          message: "Offers you send to sellers show up here.")
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
                let fields = [
                    "page": "\(self.paging.page)",
                    "offer_type": "user"
                ]
                let resp: GetOffersResponse = try await APIManager.shared.postMultipartForm(
                    type: .offerList(param: [:]),
                    fields: fields, header: true
                )
                let newItems = (resp.data ?? []).compactMap { $0 }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: BuyerOfferCell.reuseID, for: indexPath) as! BuyerOfferCell
        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let offer = items[indexPath.row]
        guard let pid = offer.productId else { return }
        p3Push(ProductDetailsViewController(productId: pid))
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= items.count - 3 { load(reset: false) }
    }
}

// MARK: - Cell

final class BuyerOfferCell: UITableViewCell {
    static let reuseID = "BuyerOfferCell"

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
    private let amountLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = .systemBlue; return l
    }()
    private let listPriceLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel; return l
    }()
    private let dateLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 11)
        l.textColor = .tertiaryLabel; return l
    }()
    private let statusBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.backgroundColor = .systemGray
        l.textAlignment = .center
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        let textStack = UIStackView(arrangedSubviews: [titleLabel, amountLabel, listPriceLabel, dateLabel])
        textStack.axis = .vertical; textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumb)
        contentView.addSubview(textStack)
        contentView.addSubview(statusBadge)
        NSLayoutConstraint.activate([
            thumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumb.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            thumb.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            thumb.widthAnchor.constraint(equalToConstant: 64),
            thumb.heightAnchor.constraint(equalToConstant: 64),
            textStack.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: thumb.topAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -8),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            statusBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 72),
            statusBadge.heightAnchor.constraint(equalToConstant: 22)
        ])
    }

    func configure(with offer: OfferEntry) {
        titleLabel.text = offer.product?.title ?? "Product #\(offer.productId ?? 0)"
        amountLabel.text = "Your offer: " + P3Format.currency(offer.amount)
        listPriceLabel.text = "List: " + P3Format.currency(offer.product?.pricing)
        dateLabel.text = P3Format.date(offer.createdAt)
        let status = (offer.status ?? "pending").capitalized
        statusBadge.text = "  \(status)  "
        statusBadge.backgroundColor = Self.color(for: offer.status)
        let first: String? = offer.product?.images?.compactMap { $0 }.first
        thumb.p3Load(first, placeholder: UIImage(systemName: "photo"))
    }

    private static func color(for status: String?) -> UIColor {
        switch (status ?? "").lowercased() {
        case "pending":  return .systemOrange
        case "accepted": return .systemGreen
        case "declined", "rejected": return .systemRed
        case "counter":  return .systemBlue
        default:         return .systemGray2
        }
    }
}
