//
//  HostShowProductsSheet.swift
//  BidCast — iOS parity Phase 8 / P1.12 (2026-04-23)
//
//  Port of Android `ProductsForLiveShowFragment` — a half-sheet shown
//  over `HostPublisherViewController` that lets the host browse their
//  inventory mid-show and pin a different product without leaving the
//  live stream.
//
//  Behavior:
//    - Loads the seller's products via POST api/get-user-product
//      (paginated).
//    - Tap a row → emits pin_product for that product id (same socket
//      event the `pinFirstButton` uses).
//    - Listens to product_pinned / product_unpinned to keep the
//      selected-row checkmark in sync — the host publisher already
//      owns those listeners so we just flip a local flag on callback
//      via the completion that caller passes in.
//
//  Android's "add product" sub-sheet (surprise-set vs. standalone) is
//  folded into the main list here; the surprise-set branch lives in
//  P2 alongside the ManageSurpriseSetSheet port.
//

import UIKit
import SVProgressHUD

final class HostShowProductsSheet: UIViewController {

    // MARK: - Inputs

    /// Current room id — the pin socket emit needs this.
    let roomId: String
    /// Current pinned product id; used to show a checkmark on the row.
    var currentPinnedProductId: String?
    /// Callback invoked when the host selects a product to pin. Parent
    /// VC emits the socket event + updates its UI.
    let onPin: (String, WireProduct) -> Void

    // MARK: - UI

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Products in this show"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Tap a product to pin it for the current auction."
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let refreshButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.register(HostInventoryCell.self, forCellReuseIdentifier: HostInventoryCell.reuseID)
        t.dataSource = self
        t.delegate = self
        t.rowHeight = 72
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    private let emptyState = P3EmptyStateView(
        icon: UIImage(systemName: "shippingbox"),
        title: "No products in inventory",
        message: "Add a product to your inventory first."
    )

    // MARK: - State

    private var items: [WireProduct] = []
    private var paging = P3Paging()

    // MARK: - Init

    init(roomId: String,
         currentPinnedProductId: String?,
         onPin: @escaping (String, WireProduct) -> Void) {
        self.roomId = roomId
        self.currentPinnedProductId = currentPinnedProductId
        self.onPin = onPin
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        refreshButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)

        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(titleLabel)
        header.addSubview(subtitleLabel)
        header.addSubview(refreshButton)

        emptyState.translatesAutoresizingMaskIntoConstraints = false
        emptyState.isHidden = true

        view.addSubview(header)
        view.addSubview(tableView)
        view.addSubview(emptyState)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: header.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            refreshButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            refreshButton.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: refreshButton.leadingAnchor, constant: -8),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyState.topAnchor.constraint(equalTo: tableView.topAnchor),
            emptyState.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            emptyState.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])

        load(reset: true)
    }

    @objc private func refresh() { load(reset: true) }

    private func load(reset: Bool) {
        if reset { paging.reset(); items = [] }
        guard !paging.isLoading, paging.hasMore else { return }
        paging.isLoading = true
        if reset { SVProgressHUD.show() }
        Task { @MainActor in
            defer {
                self.paging.isLoading = false
                SVProgressHUD.dismiss()
            }
            do {
                let fields = ["page": "\(self.paging.page)"]
                let resp: GetMyInventoryResponse = try await APIManager.shared.postMultipartForm(
                    type: .getUserProducts(param: [:]),
                    fields: fields, header: true)
                let newItems = resp.data ?? []
                if reset { self.items = newItems } else { self.items.append(contentsOf: newItems) }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage, totalPages: resp.totalPage))
                self.tableView.reloadData()
                self.emptyState.isHidden = !self.items.isEmpty
            } catch {
                self.presentError(error: error)
            }
        }
    }

    private func presentError(error: Error) {
        let alert = UIAlertController(
            title: "Unable to load inventory",
            message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Called from HostPublisherViewController when a product_pinned
    /// socket event arrives so the sheet can update its checkmark
    /// live while still open.
    func didReceivePinUpdate(productId: String?) {
        self.currentPinnedProductId = productId
        self.tableView.reloadData()
    }
}

// MARK: - Table data source

extension HostShowProductsSheet: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HostInventoryCell.reuseID, for: indexPath) as! HostInventoryCell
        let p = items[indexPath.row]
        let isPinned = p.id.map { "\($0)" == currentPinnedProductId } ?? false
        cell.configure(with: p, isPinned: isPinned)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let p = items[indexPath.row]
        guard let id = p.id else { return }
        let idStr = "\(id)"
        // Emit pin + let caller handle the rest (UI updates, banner).
        onPin(idStr, p)
        // Optimistically reflect in-place so the user sees immediate feedback.
        currentPinnedProductId = idStr
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= items.count - 3 { load(reset: false) }
    }
}

// MARK: - Cell

final class HostInventoryCell: UITableViewCell {
    static let reuseID = "HostInventoryCell"

    private let thumb: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 6
        v.backgroundColor = .secondarySystemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let titleLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.numberOfLines = 2; return l
    }()
    private let priceLabel: UILabel = {
        let l = UILabel(); l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = .systemBlue; return l
    }()
    private let pinBadge: UILabel = {
        let l = UILabel()
        l.text = " Pinned "
        l.font = .systemFont(ofSize: 10, weight: .bold)
        l.textColor = .white
        l.backgroundColor = .systemGreen
        l.layer.cornerRadius = 8
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        let textStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumb)
        contentView.addSubview(textStack)
        contentView.addSubview(pinBadge)
        NSLayoutConstraint.activate([
            thumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumb.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumb.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            thumb.widthAnchor.constraint(equalToConstant: 56),
            thumb.heightAnchor.constraint(equalToConstant: 56),
            textStack.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: pinBadge.leadingAnchor, constant: -8),
            pinBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pinBadge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pinBadge.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with p: WireProduct, isPinned: Bool) {
        titleLabel.text = p.title ?? "Product #\(p.id ?? 0)"
        priceLabel.text = P3Format.currency(p.pricing)
        pinBadge.isHidden = !isPinned
        let first: String? = p.images?.compactMap { $0 }.first
        thumb.p3Load(first, placeholder: UIImage(systemName: "photo"))
        accessoryType = isPinned ? .checkmark : .none
    }
}
