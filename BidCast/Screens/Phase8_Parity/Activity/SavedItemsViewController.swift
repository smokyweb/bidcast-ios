//
//  SavedItemsViewController.swift
//  BidCast — iOS parity Phase 8 / P1.11 (2026-04-23)
//
//  Mirrors Android `SavedItemsFragment`. Products the user has saved
//  via the heart icon on `api/user/favorite`. Android uses
//  `api/v1/get-my-purchases-orders` with `status="saved"` so we hit
//  the same endpoint with the same shape.
//
//  Tap row → ProductDetailsViewController.
//  Swipe left → "Unsave" (api/user/favorite with product_id) to toggle
//    the row off.
//
//  Entry points:
//    - ActivityViewController+JobA — nav-bar heart icon
//    - AccountViewController+JobA — ellipsis menu (future) / grid (future)
//

import UIKit
import SVProgressHUD

final class SavedItemsViewController: P3ListViewController {

    private var items: [ProductsByStatusItem] = []
    private var paging = P3Paging()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved items"
        tableView.register(SavedItemCell.self, forCellReuseIdentifier: SavedItemCell.reuseID)
        emptyState.update(title: "No saved items yet",
                          message: "Tap the heart on a product to save it for later.")
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
                    "status": "saved",
                    "page": "\(self.paging.page)"
                ]
                let resp: GetProductsByStatusResponse = try await APIManager.shared.postMultipartForm(
                    type: .getProductsByStatus(param: [:]),
                    fields: fields, header: true)
                let newItems = resp.data ?? []
                if reset {
                    self.items = newItems
                } else {
                    let existingIds = Set(self.items.compactMap { $0.id })
                    self.items.append(contentsOf: newItems.filter {
                        guard let id = $0.id else { return true }
                        return !existingIds.contains(id)
                    })
                }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage, totalPages: resp.totalPage))
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.items.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    private func unsave(_ item: ProductsByStatusItem, at indexPath: IndexPath) {
        guard let pid = item.productId else { return }
        Task { @MainActor in
            do {
                let fields = ["product_id": "\(pid)"]
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .userFavorite(param: [:]),
                    fields: fields, header: true)
                if let row = self.items.firstIndex(where: { $0.id == item.id }) {
                    self.items.remove(at: row)
                    self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)],
                                              with: .automatic)
                }
                self.emptyStateIsVisible = self.items.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    // MARK: - Table

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SavedItemCell.reuseID, for: indexPath) as! SavedItemCell
        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        guard let pid = item.productId ?? item.product?.id else { return }
        p3Push(ProductDetailsViewController(productId: pid))
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= items.count - 3 { load(reset: false) }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = items[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Unsave") { [weak self] _, _, done in
            self?.unsave(item, at: indexPath); done(true)
        }
        action.image = UIImage(systemName: "heart.slash")
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - Cell

final class SavedItemCell: UITableViewCell {
    static let reuseID = "SavedItemCell"

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
    private let priceLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = .systemBlue; return l
    }()
    private let sellerLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 11)
        l.textColor = .secondaryLabel; return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        let textStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel, sellerLabel])
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

    func configure(with item: ProductsByStatusItem) {
        let p = item.product
        titleLabel.text = p?.title ?? "Product #\(item.productId ?? 0)"
        priceLabel.text = P3Format.currency(p?.pricing)
        sellerLabel.text = (item.user?.name).map { "Sold by \($0)" } ?? ""
        let first: String? = p?.images?.compactMap { $0 }.first
        thumb.p3Load(first, placeholder: UIImage(systemName: "photo"))
    }
}
