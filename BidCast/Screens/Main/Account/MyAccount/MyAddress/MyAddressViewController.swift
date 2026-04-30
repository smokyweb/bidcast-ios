//
//  MyAddressViewController.swift
//  BidCast — iOS Parity Phase 8 / P0.4 (2026-04-23)
//
//  Real addresses list backed by:
//    GET  api/get-shipping-address      \u2192 list
//    POST api/upsert-shipping-address   \u2192 add / edit
//    POST api/set-default-shipping-address
//    POST api/delete-shipping-address
//
//  Replaces the former 2-row mock list (`sectionData: [.address : 2]`,
//  `fetchApi()` commented out). Swipe-to-delete, "Set default", and tap
//  to edit are all live.
//
//  Also exposes `onPick` so CheckoutViewController can push this screen
//  as an address picker \u2014 tapping a row calls `onPick(address)` and
//  pops back.
//

import UIKit
import SVProgressHUD

class MyAddressViewController: UIViewController {

    @IBOutlet weak var tableViewOlt: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var headerView: HeaderView!

    // MARK: - State

    private(set) var addresses: [ShippingAddress] = []

    /// Optional picker callback \u2014 when set, tapping a row invokes it and
    /// pops back. Used by `CheckoutViewController.pickAddress()`.
    var onPick: ((ShippingAddress) -> Void)?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureHeaderView()
        self.configureAddButton()
        self.reloadAddresses()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setTabBarHidden(true)
        self.setNavigationBarHidden(true)
    }

    // MARK: - Configure

    private func configureTableView() {
        self.tableViewOlt.delegate = self
        self.tableViewOlt.dataSource = self
        let cellIds = [
            LocationNameCell.identifier,
            SubmitCell.identifier,
            AppHeaderCell.identifier,
            AddressCell.identifier
        ]
        tableViewOlt.registerCells(for: cellIds)
        self.tableViewOlt.separatorStyle = .none
        tableViewOlt.configTblView(bgColor: .pearl)
        // Allow pull-to-refresh when the list has content.
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(reloadAddresses), for: .valueChanged)
        tableViewOlt.refreshControl = rc
    }

    private func configureHeaderView() {
        self.headerView.headerViewSetup(
            rightButtonHidden: false,
            leftButtonHidden: false,
            headerName: (onPick == nil) ? "My Addresses" : "Select Address",
            setRightImage: UIImage(systemName: "plus")?
                .withTintColor(.darkBlue, renderingMode: .alwaysOriginal),
            rightButtonAction: onTapAddAddress,
            leftButtonAction: didTabBack
        )
        self.headerView.bottomLbl.isHidden = true
        self.headerView.cenetrVerticalConstraint.constant =
            UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }

    private func configureAddButton() {
        self.submitBtn.setImage(
            UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal),
            for: .normal
        )
        self.submitBtn.setTitle("Add New Address", for: .normal)
        self.submitBtn.setTitleColor(.white, for: .normal)
        self.submitBtn.backgroundColor = .darkBlue
        self.submitBtn.addBorders(of: .darkBlue, width: 1.0)
        self.submitBtn.makeCornerRounded(ofSize: 8)
        self.submitBtn.addTarget(self, action: #selector(onTapAddAddress), for: .touchUpInside)
    }

    // MARK: - API

    @objc private func reloadAddresses() {
        Task { [weak self] in
            guard let self = self else { return }
            await MainActor.run {
                if self.tableViewOlt.refreshControl?.isRefreshing != true {
                    SVProgressHUD.show()
                }
            }
            defer {
                Task { @MainActor in
                    SVProgressHUD.dismiss()
                    self.tableViewOlt.refreshControl?.endRefreshing()
                }
            }
            do {
                let resp: GetShippingAddressResponse = try await APIManager.shared.request(
                    type: .getShippingAddress, header: true
                )
                let list = (resp.data ?? []).compactMap { $0 }
                await MainActor.run {
                    self.addresses = list
                    self.tableViewOlt.reloadData()
                }
            } catch {
                await MainActor.run {
                    let msg = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
                    Utilities.sharedInstance.showToast(source: self, message: msg)
                }
            }
        }
    }

    private func deleteAddress(_ addr: ShippingAddress) {
        guard let id = addr.id else { return }
        SVProgressHUD.show()
        Task { [weak self] in
            guard let self = self else { return }
            defer { Task { @MainActor in SVProgressHUD.dismiss() } }
            do {
                let fields = ["address_id": "\(id)"]
                let _: APIResponse<AnyCodable> = try await APIManager.shared.postMultipartForm(
                    type: .deleteAddress(param: fields),
                    fields: fields,
                    header: true
                )
                await MainActor.run {
                    self.addresses.removeAll { $0.id == id }
                    self.tableViewOlt.reloadData()
                }
            } catch {
                await MainActor.run {
                    let msg = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
                    Utilities.sharedInstance.showToast(source: self, message: msg)
                }
            }
        }
    }

    private func setDefault(_ addr: ShippingAddress) {
        guard let id = addr.id else { return }
        SVProgressHUD.show()
        Task { [weak self] in
            guard let self = self else { return }
            defer { Task { @MainActor in SVProgressHUD.dismiss() } }
            do {
                let fields = ["address_id": "\(id)"]
                let _: APIResponse<AnyCodable> = try await APIManager.shared.postMultipartForm(
                    type: .setDefaultShippingAddress(param: fields),
                    fields: fields,
                    header: true
                )
                // Re-fetch the list so isDefault flags are accurate.
                self.reloadAddresses()
            } catch {
                await MainActor.run {
                    let msg = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
                    Utilities.sharedInstance.showToast(source: self, message: msg)
                }
            }
        }
    }

    // MARK: - Nav

    @objc private func onTapAddAddress() {
        let vc = AddShippingAddressViewController(mode: .create)
        vc.onSaved = { [weak self] in self?.reloadAddresses() }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func didTabBack() {
        self.goToBack()
    }
}

// MARK: - UITableViewDelegate / DataSource

extension MyAddressViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(addresses.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if addresses.isEmpty {
            // Empty-state cell \u2014 reuse a plain UITableViewCell so we don't
            // depend on a dedicated xib.
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "emptyAddr")
            cell.textLabel?.text = "No addresses yet"
            cell.detailTextLabel?.text = "Tap the + button to add your first one."
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = .pearl
            cell.backgroundColor = .pearl
            return cell
        }
        let cell = tableView.dequeueCell(with: AddressCell.self)
        let addr = addresses[indexPath.row]
        cell.contentView.backgroundColor = .pearl
        cell.countryOlt.isHidden = false
        cell.phoneOlt.isHidden = false
        cell.centerConst.constant = -60
        cell.selectionStyle = .default
        // Populate the cell labels best-effort; AddressCell ships with
        // outlet names chosen for Ankit's original xib, so we just write
        // canonical strings into any outlets we can see.
        configureAddressCell(cell, with: addr)
        return cell
    }

    /// Hydrate the existing `AddressCell` xib with real data.
    private func configureAddressCell(_ cell: AddressCell, with addr: ShippingAddress) {
        let line1 = addr.streetAddress ?? ""
        let city = [addr.city, addr.state]
            .compactMap { $0 }.joined(separator: ", ")
        let zip = addr.pincode ?? ""
        let phone = addr.phoneNumber ?? ""

        cell.nameLblOlt?.text = addr.name ?? ""
        cell.addressTypeOlt?.text = addr.type ?? ""
        cell.streetOlt?.text = line1
        cell.stateOlt?.text = [city, zip].filter { !$0.isEmpty }.joined(separator: " ")
        cell.countryOlt?.text = city.isEmpty ? (addr.pincode ?? "") : city
        cell.phoneOlt?.text = phone
        cell.defaiultOlt?.isHidden = (addr.isDefault != true)
        cell.accessibilityLabel = [addr.name, line1, city, zip, phone]
            .compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
        cell.accessibilityHint = (addr.isDefault == true) ? "Default address" : nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Const.Height.AutomaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !addresses.isEmpty, indexPath.row < addresses.count else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let addr = addresses[indexPath.row]
        if let pick = onPick {
            pick(addr)
            self.goToBack()
            return
        }
        // Non-picker mode: push edit screen.
        let vc = AddShippingAddressViewController(mode: .edit(addr))
        vc.onSaved = { [weak self] in self?.reloadAddresses() }
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        guard !addresses.isEmpty, indexPath.row < addresses.count else { return nil }
        let addr = addresses[indexPath.row]

        let del = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            guard let self = self else { done(false); return }
            let alert = UIAlertController(
                title: "Delete address?",
                message: "This cannot be undone.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in done(false) })
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.deleteAddress(addr)
                done(true)
            })
            self.present(alert, animated: true)
        }

        let def = UIContextualAction(style: .normal, title: "Set default") { [weak self] _, _, done in
            self?.setDefault(addr)
            done(true)
        }
        def.backgroundColor = .systemBlue

        if addr.isDefault == true {
            return UISwipeActionsConfiguration(actions: [del])
        }
        return UISwipeActionsConfiguration(actions: [del, def])
    }
}
