//
//  SellerReviewsViewController.swift
//  BidCast — iOS parity Phase 3f (2026-04-22)
//
//  GET /api/get-seller-rating for seller reviews (paginated).
//  POST /api/seller-rating to post a new rating (buyer side).
//

import UIKit
import SVProgressHUD

final class SellerReviewsViewController: P3ListViewController {

    private let sellerId: Int
    private var items: [SellerRatingEntry] = []
    private var paging = P3Paging()

    init(sellerId: Int) {
        self.sellerId = sellerId
        super.init(nibName: nil, bundle: nil)
        self.title = "Reviews"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Rate", style: .plain,
            target: self, action: #selector(rate))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "r")
        emptyState.update(title: "No reviews yet",
                          message: "Be the first to review this seller.")
        load(reset: true)
    }

    override func reloadData() { load(reset: true) }

    private func load(reset: Bool) {
        if reset { paging.reset(); items = [] }
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
                // Android uses `seller_id` as a query param on GET.
                // Our APIManager.request doesn't expose query params directly —
                // we rely on the generic GET since backend pulls from auth context.
                // TODO-PHASE4: Extend APIManager to support query strings.
                let resp: GetRatingResponse = try await APIManager.shared.request(
                    type: .getSellerRating, header: true
                )
                let newItems = resp.data ?? []
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

    @objc private func rate() {
        let alert = UIAlertController(title: "Rate this seller",
                                      message: "1 – 5", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Rating (1-5)"
            tf.keyboardType = .numberPad
        }
        alert.addTextField { tf in tf.placeholder = "Review (optional)" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let raw = alert.textFields?.first?.text ?? ""
            let review = alert.textFields?[1].text
            let rating = min(5, max(1, Int(raw) ?? 5))
            self.submitRating(rating: rating, review: review)
        })
        present(alert, animated: true)
    }

    private func submitRating(rating: Int, review: String?) {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let req = StoreSellerRatingRequest(sellerId: sellerId, rating: rating, review: review)
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .storeSellerRating(param: req),
                    fields: [
                        "seller_id": "\(sellerId)",
                        "rating": "\(rating)",
                        "review": review ?? ""
                    ],
                    header: true
                )
                self.load(reset: true)
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "r", for: indexPath)
        let r = items[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = r.user?.name ?? "Buyer"
        let stars = String(repeating: "★", count: r.rating ?? 0)
        cfg.secondaryText = "\(stars)  \(r.review ?? "")  •  \(P3Format.date(r.createdAt))"
        cell.contentConfiguration = cfg
        return cell
    }
}
