//
//  CouponsViewController.swift
//  BidCast — iOS parity Phase 3e (2026-04-22)
//
//  GET /api/get-coupon -> user's available coupons (UserCoupon[])
//  Active coupon codes are applied on checkout (Phase 4). This screen
//  just lists them + shows expiration. Tapping "Copy" copies the code.
//

import UIKit
import SVProgressHUD

final class CouponsViewController: P3ListViewController {

    private var coupons: [UserCoupon] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Coupons"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "c")
        emptyState.update(title: "No coupons",
                          message: "Promotions and rewards will show up here.")
        load()
    }

    override func reloadData() { load() }

    private func load() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss(); self.stopRefresh() }
            do {
                let resp: GetCouponsResponse = try await APIManager.shared.request(
                    type: .getCoupon, header: true
                )
                self.coupons = resp.data ?? []
                self.tableView.reloadData()
                self.emptyStateIsVisible = self.coupons.isEmpty
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coupons.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "c", for: indexPath)
        let c = coupons[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        let name = c.coupon?.name ?? "Coupon"
        let val = c.coupon?.value.map(String.init) ?? "—"
        let type = c.coupon?.type ?? ""
        cfg.text = name
        let exp = P3Format.date(c.coupon?.expDate)
        cfg.secondaryText = "\(val)\(type == "percent" ? "%" : "")  off  •  exp \(exp)"
        cfg.image = UIImage(systemName: "ticket")
        cell.contentConfiguration = cfg
        cell.accessoryType = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let code = coupons[indexPath.row].coupon?.name ?? ""
        UIPasteboard.general.string = code
        p3Alert(title: "Copied", message: "\"\(code)\" copied. Use at checkout.")
    }
}
