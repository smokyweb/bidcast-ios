//
//  InventoryViewController.swift
//  BidCast — iOS parity Phase 3d (2026-04-22)
//
//  Seller's product inventory. POST /api/get-user-product (paginated),
//  supports delete + status-toggle. Reuses WireProduct Codable.
//

import UIKit
import SVProgressHUD

final class P3InventoryViewController: P3ListViewController {

    private var items: [WireProduct] = []
    private var paging = P3Paging()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inventory"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self,
            action: #selector(addProduct))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "inv")
        emptyState.update(title: "No inventory",
                          message: "Add a product to start selling.")
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
                let fields = ["page": "\(paging.page)"]
                let resp: GetMyInventoryResponse = try await APIManager.shared.postMultipartForm(
                    type: .getUserProducts(param: [:]),
                    fields: fields, header: true
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

    @objc private func addProduct() {
        p3Push(EditProductPlaceholderViewController(mode: .create))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inv", for: indexPath)
        let p = items[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = p.title ?? "Untitled"
        cfg.secondaryText = "\(P3Format.currency(p.pricing))  •  qty \(p.quantity ?? "0")  •  \(p.status?.capitalized ?? "—")"
        cfg.image = UIImage(systemName: "shippingbox")
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        p3Push(EditProductPlaceholderViewController(mode: .edit(items[indexPath.row])))
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let row = indexPath.row
        let product = items[row]
        guard let pid = product.id else { return nil }

        let del = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.p3Confirm(title: "Delete product",
                            message: "This cannot be undone.",
                            destructive: true) {
                self?.deleteProduct(id: pid, at: row); done(true)
            }
        }

        let statusTitle = (product.status?.lowercased() == "active") ? "Pause" : "Activate"
        let toggle = UIContextualAction(style: .normal, title: statusTitle) { [weak self] _, _, done in
            self?.toggleStatus(product: product, at: row); done(true)
        }
        toggle.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [del, toggle])
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= items.count - 3 { load(reset: false) }
    }

    private func deleteProduct(id: Int, at row: Int) {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let fields = ["product_id": "\(id)"]
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .deleteProduct(param: [:]),
                    fields: fields, header: true
                )
                self.items.remove(at: row)
                self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
                self.emptyStateIsVisible = self.items.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    private func toggleStatus(product: WireProduct, at row: Int) {
        guard let id = product.id else { return }
        let newStatus = (product.status?.lowercased() == "active") ? "inactive" : "active"
        Task { @MainActor in
            do {
                let fields = ["product_id": "\(id)", "status": newStatus]
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .updateProductStatus(param: [:]),
                    fields: fields, header: true
                )
                // Refresh list cheaply.
                self.load(reset: true)
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }
}

// MARK: - Add / edit product scaffolding

/// Simplified form that captures title, description, price, quantity, then
/// calls store-product. A full create/edit form (images, variants, shipping
/// profile, category tree, etc.) is a Phase 4 deliverable. This is the
/// minimum viable flow so sellers can list a product today.
final class EditProductPlaceholderViewController: UIViewController {

    enum Mode {
        case create
        case edit(WireProduct)
    }

    private let mode: Mode
    private let titleField = UITextField()
    private let descField = UITextView()
    private let priceField = UITextField()
    private let qtyField = UITextField()

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        switch mode {
        case .create: self.title = "Add product"
        case .edit(let p): self.title = p.title ?? "Edit product"
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupForm()
    }

    private func setupForm() {
        titleField.borderStyle = .roundedRect
        titleField.placeholder = "Title"
        priceField.borderStyle = .roundedRect
        priceField.placeholder = "Price (USD)"
        priceField.keyboardType = .decimalPad
        qtyField.borderStyle = .roundedRect
        qtyField.placeholder = "Quantity"
        qtyField.keyboardType = .numberPad
        descField.font = .systemFont(ofSize: 15)
        descField.layer.borderColor = UIColor.separator.cgColor
        descField.layer.borderWidth = 1
        descField.layer.cornerRadius = 8
        descField.heightAnchor.constraint(equalToConstant: 140).isActive = true

        if case .edit(let p) = mode {
            titleField.text = p.title
            descField.text = p.description
            priceField.text = p.pricing
            qtyField.text = p.quantity
        }

        let saveBtn = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Save"
        saveBtn.configuration = cfg
        saveBtn.addTarget(self, action: #selector(save), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleField, priceField, qtyField, descField, saveBtn, UIView()])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func save() {
        guard let t = titleField.text, !t.isEmpty,
              let p = priceField.text, !p.isEmpty else {
            p3Alert(title: "Missing info", message: "Title and price are required."); return
        }
        let qty = qtyField.text ?? "1"
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                var fields: [String: String] = [
                    "title": t,
                    "description": descField.text ?? "",
                    "pricing": p,
                    "quantity": qty,
                    "status": "active"
                ]
                if case .edit(let prod) = mode, let id = prod.id {
                    fields["product_id"] = "\(id)"
                }
                let _: CreateProductResponse = try await APIManager.shared.postMultipartForm(
                    type: .storeProduct(param: StoreProductRequest.empty),
                    fields: fields, header: true
                )
                self.p3Alert(title: "Saved",
                             message: "Product saved. You can add images and shipping details later.") {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }
}

// Empty StoreProductRequest helper used when we send the multipart form directly.
extension StoreProductRequest {
    static var empty: StoreProductRequest {
        StoreProductRequest(
            categoryId: nil, title: nil, description: nil, quantity: nil,
            pricing: nil, flashSale: nil, acceptOffers: nil, reserveForLive: nil,
            shippingProfileId: nil, status: nil, images: nil, videos: nil,
            subCategoryId: nil, variant: nil, width: nil, height: nil,
            length: nil, weight: nil, mailClass: nil,
            processingCategory: nil, productCondition: nil,
            hazardousMaterial: nil, sku: nil, costPerItem: nil
        )
    }
}
