//
//  ShowProductsPickerViewController.swift
//  BidCast — iOS parity Phase 8 / P1.10 (2026-04-23)
//
//  Multi-select picker mirroring Android `AddProductFragment` in the
//  Schedule-Show wizard. Loads the seller's inventory (POST
//  api/get-user-product) and returns the user-selected product ids to
//  the ScheduleShowEditorViewController via `onDone`.
//

import UIKit
import SVProgressHUD

final class ShowProductsPickerViewController: P3ListViewController {

    private var inventory: [WireProduct] = []
    private var paging = P3Paging()
    private var selected: Set<Int> = []
    private let onDone: (Set<Int>, [WireProduct]) -> Void

    init(initiallySelected: Set<Int>,
         onDone: @escaping (Set<Int>, [WireProduct]) -> Void) {
        self.selected = initiallySelected
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
        self.title = "Attach products"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "p")
        tableView.allowsMultipleSelection = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done", style: .done, target: self, action: #selector(finish))
        emptyState.update(title: "No products yet",
                          message: "Add a product to your inventory first.")
        load(reset: true)
    }

    override func reloadData() { load(reset: true) }

    private func load(reset: Bool) {
        if reset { paging.reset(); inventory = [] }
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
                let fields = ["page": "\(self.paging.page)"]
                let resp: GetMyInventoryResponse = try await APIManager.shared.postMultipartForm(
                    type: .getUserProducts(param: [:]),
                    fields: fields, header: true)
                let newItems = resp.data ?? []
                if reset { self.inventory = newItems } else { self.inventory.append(contentsOf: newItems) }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage, totalPages: resp.totalPage))
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.inventory.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    @objc private func finish() {
        let selectedProducts = inventory.filter { ($0.id).map { selected.contains($0) } ?? false }
        onDone(selected, selectedProducts)
        if let nav = navigationController, nav.viewControllers.first !== self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        inventory.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "p", for: indexPath)
        let p = inventory[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = p.title ?? "Untitled"
        cfg.secondaryText = P3Format.currency(p.pricing) + "  •  qty \(p.quantity ?? "0")"
        cfg.image = UIImage(systemName: "shippingbox")
        cell.contentConfiguration = cfg
        if let id = p.id, selected.contains(id) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let p = inventory[indexPath.row]
        guard let id = p.id else { return }
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= inventory.count - 3 { load(reset: false) }
    }
}
