//
//  SellerOffersViewController.swift
//  BidCast — iOS parity Phase 3d (2026-04-22)
//
//  Seller's inbound offers — list + accept/decline.
//  POST /api/offer/lists         (per-status filter)
//  POST /api/offer/update-status (accept/decline)
//

import UIKit
import SVProgressHUD

final class SellerOffersViewController: P3ListViewController {

    private var offers: [OfferEntry] = []
    private var paging = P3Paging()
    private let segmented = UISegmentedControl(items: ["Pending", "Accepted", "Declined"])
    private let statuses = ["pending", "accepted", "declined"]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Offers"

        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        let wrap = UIView()
        wrap.addSubview(segmented)
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 10),
            segmented.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -16),
            segmented.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -8)
        ])
        wrap.frame.size = .init(width: view.bounds.width, height: 48)
        tableView.tableHeaderView = wrap

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "offer")
        emptyState.update(title: "No offers",
                          message: "Inbound offers from buyers will show up here.")
        load(reset: true)
    }

    override func reloadData() { load(reset: true) }

    @objc private func statusChanged() { load(reset: true) }

    private func load(reset: Bool) {
        if reset { paging.reset(); offers = [] }
        guard !paging.isLoading, paging.hasMore else { return }
        paging.isLoading = true
        SVProgressHUD.show()

        Task { @MainActor in
            defer {
                self.paging.isLoading = false
                SVProgressHUD.dismiss()
                self.stopRefresh()
            }
            do {
                let fields = [
                    "page": "\(paging.page)",
                    "status": statuses[segmented.selectedSegmentIndex]
                ]
                let resp: GetOffersResponse = try await APIManager.shared.postMultipartForm(
                    type: .offerList(param: [:]),
                    fields: fields, header: true
                )
                let newItems = (resp.data ?? []).compactMap { $0 }
                if reset { self.offers = newItems } else { self.offers.append(contentsOf: newItems) }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage, totalPages: resp.totalPage))
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.offers.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    // MARK: - Accept / decline

    private func updateStatus(offer: OfferEntry, status: String) {
        guard let id = offer.id else { return }
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let req = UpdateOfferStatusRequest(offerId: id, status: status)
                let _: UpdateOfferResponse = try await APIManager.shared.postMultipartForm(
                    type: .offerUpdateStatus(param: req),
                    fields: ["offer_id": "\(id)", "status": status],
                    header: true
                )
                self.load(reset: true)
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    // MARK: - Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        offers.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offer", for: indexPath)
        let o = offers[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = o.product?.title ?? "Product"
        let who = o.user?.name ?? "Buyer"
        cfg.secondaryText = "\(who) offered \(P3Format.currency(o.amount))  •  \(o.status?.capitalized ?? "")"
        cfg.image = UIImage(systemName: "tag")
        cell.contentConfiguration = cfg
        cell.accessoryType = .none
        return cell
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let offer = offers[indexPath.row]
        guard (offer.status ?? "pending") == "pending" else { return nil }
        let accept = UIContextualAction(style: .normal, title: "Accept") { [weak self] _, _, done in
            self?.updateStatus(offer: offer, status: "accepted"); done(true)
        }
        accept.backgroundColor = .systemGreen
        let decline = UIContextualAction(style: .destructive, title: "Decline") { [weak self] _, _, done in
            self?.updateStatus(offer: offer, status: "declined"); done(true)
        }
        return UISwipeActionsConfiguration(actions: [decline, accept])
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= offers.count - 3 { load(reset: false) }
    }
}
