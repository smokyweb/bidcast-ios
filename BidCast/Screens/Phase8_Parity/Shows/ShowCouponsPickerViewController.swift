//
//  ShowCouponsPickerViewController.swift
//  BidCast — iOS parity Phase 8 / P1.10 (2026-04-23)
//
//  Multi-select picker mirroring Android `AddCouponFragment` in the
//  Schedule-Show wizard. Loads the seller's coupon list (GET
//  api/get-coupon) and returns the user-selected coupon ids back to
//  the caller.
//
//  QA-NOTE: Android's `AddCouponFragment` body is currently an empty
//  stub that doesn't wire the ids anywhere — we provide the UI here
//  and push coupon_ids[] via the store-schedule-show multipart so the
//  backend can start consuming them whenever it's ready, without
//  blocking iOS on Android's gap.
//

import UIKit
import SVProgressHUD

final class ShowCouponsPickerViewController: P3ListViewController {

    private var coupons: [UserCoupon] = []
    private var selected: Set<Int> = []
    private let onDone: (Set<Int>, [UserCoupon]) -> Void

    init(initiallySelected: Set<Int>,
         onDone: @escaping (Set<Int>, [UserCoupon]) -> Void) {
        self.selected = initiallySelected
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
        self.title = "Attach coupons"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "c")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done", style: .done, target: self, action: #selector(finish))
        emptyState.update(title: "No coupons yet",
                          message: "Create a coupon from the Sell tab.")
        load()
    }

    override func reloadData() { load() }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer {
                SVProgressHUD.dismiss()
                self.stopRefresh()
            }
            do {
                let resp: GetCouponsResponse = try await APIManager.shared.request(
                    type: .getCoupon, header: true)
                self.coupons = resp.data ?? []
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.coupons.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    @objc private func finish() {
        let picked = coupons.filter {
            guard let cid = $0.couponId ?? $0.coupon?.id else { return false }
            return selected.contains(cid)
        }
        onDone(selected, picked)
        if let nav = navigationController, nav.viewControllers.first !== self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coupons.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "c", for: indexPath)
        let row = coupons[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = row.coupon?.name ?? "Coupon #\(row.coupon?.id ?? row.couponId ?? 0)"
        let valueText: String = {
            if let v = row.coupon?.value, let t = row.coupon?.type {
                return "\(v) \(t)"
            }
            return ""
        }()
        cfg.secondaryText = [row.coupon?.description, valueText]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " • ")
        cfg.image = UIImage(systemName: "ticket")
        cell.contentConfiguration = cfg
        let cid = row.couponId ?? row.coupon?.id
        cell.accessoryType = (cid.map { selected.contains($0) } ?? false) ? .checkmark : .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = coupons[indexPath.row]
        guard let cid = row.couponId ?? row.coupon?.id else { return }
        if selected.contains(cid) { selected.remove(cid) } else { selected.insert(cid) }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
