//
//  AddShippingAddressViewController.swift
//  BidCast — iOS Parity Phase 8 / P0.4 (2026-04-23)
//
//  Form for creating or editing a shipping address. Mirrors Android's
//  `AddShippingAddressFragment` (~234 lines) and posts to:
//    POST api/upsert-shipping-address
//      multipart: type, name, phone_number, street_address, pincode, city, state
//
//  Two modes:
//    .create       → empty form, "Add" button
//    .edit(addr)   → pre-filled from ShippingAddress, "Save" button
//
//  A small programmatic scroll + stack layout keeps the view xib-free so
//  we don't have to author a new storyboard.
//

import UIKit
import SVProgressHUD

final class AddShippingAddressViewController: UIViewController {

    enum Mode {
        case create
        case edit(ShippingAddress)

        var addressId: Int? {
            if case .edit(let a) = self { return a.id }
            return nil
        }
    }

    // MARK: - Input

    let mode: Mode
    var onSaved: (() -> Void)?

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let scroll = UIScrollView()
    private let stack = UIStackView()

    private let nameField = Self.makeField(placeholder: "Full name")
    private let phoneField: UITextField = {
        let tf = Self.makeField(placeholder: "Phone number")
        tf.keyboardType = .phonePad
        return tf
    }()
    private let streetField = Self.makeField(placeholder: "Street address")
    private let cityField = Self.makeField(placeholder: "City")
    private let stateField = Self.makeField(placeholder: "State")
    private let pincodeField: UITextField = {
        let tf = Self.makeField(placeholder: "ZIP / postal code")
        tf.keyboardType = .numbersAndPunctuation
        return tf
    }()
    private let typeControl = UISegmentedControl(items: ["Home", "Office", "Other"])

    private let saveBtn = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = (mode.addressId == nil) ? "Add Address" : "Edit Address"
        navigationItem.largeTitleDisplayMode = .never
        setupLayout()
        prefillIfEditing()
    }

    // MARK: - Layout

    private func setupLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        stack.axis = .vertical
        stack.spacing = 14
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 32, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        typeControl.selectedSegmentIndex = 0
        stack.addArrangedSubview(labelled("Type", field: typeControl))
        stack.addArrangedSubview(labelled("Name", field: nameField))
        stack.addArrangedSubview(labelled("Phone", field: phoneField))
        stack.addArrangedSubview(labelled("Street address", field: streetField))
        stack.addArrangedSubview(labelled("City", field: cityField))
        stack.addArrangedSubview(labelled("State", field: stateField))
        stack.addArrangedSubview(labelled("ZIP", field: pincodeField))

        var btnCfg = UIButton.Configuration.filled()
        btnCfg.title = (mode.addressId == nil) ? "Add address" : "Save changes"
        btnCfg.baseBackgroundColor = .systemBlue
        saveBtn.configuration = btnCfg
        saveBtn.addTarget(self, action: #selector(onTapSave), for: .touchUpInside)
        stack.addArrangedSubview(saveBtn)

        spinner.hidesWhenStopped = true
        stack.addArrangedSubview(spinner)
    }

    private func labelled(_ title: String, field: UIView) -> UIView {
        let l = UILabel()
        l.text = title
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        let row = UIStackView(arrangedSubviews: [l, field])
        row.axis = .vertical
        row.spacing = 6
        return row
    }

    private static func makeField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 15)
        tf.autocorrectionType = .no
        tf.heightAnchor.constraint(equalToConstant: 42).isActive = true
        return tf
    }

    // MARK: - Prefill

    private func prefillIfEditing() {
        guard case .edit(let a) = mode else { return }
        nameField.text = a.name
        phoneField.text = a.phoneNumber
        streetField.text = a.streetAddress
        cityField.text = a.city
        stateField.text = a.state
        pincodeField.text = a.pincode
        switch (a.type ?? "").lowercased() {
        case "home":   typeControl.selectedSegmentIndex = 0
        case "office": typeControl.selectedSegmentIndex = 1
        default:       typeControl.selectedSegmentIndex = 2
        }
    }

    // MARK: - Save

    @objc private func onTapSave() {
        guard let name = nonEmpty(nameField, "name") else { return }
        guard let phone = nonEmpty(phoneField, "phone") else { return }
        guard let street = nonEmpty(streetField, "street address") else { return }
        guard let city = nonEmpty(cityField, "city") else { return }
        guard let stateName = nonEmpty(stateField, "state") else { return }
        guard let pincode = nonEmpty(pincodeField, "ZIP") else { return }

        let typeValue: String = {
            switch typeControl.selectedSegmentIndex {
            case 0: return "home"
            case 1: return "office"
            default: return "other"
            }
        }()

        var fields: [String: String] = [
            "type": typeValue,
            "name": name,
            "phone_number": phone,
            "street_address": street,
            "pincode": pincode,
            "city": city,
            "state": stateName
        ]
        if let id = mode.addressId {
            // The backend upserts when address_id is present.
            fields["address_id"] = "\(id)"
        }

        saveBtn.isEnabled = false
        spinner.startAnimating()

        Task { [weak self] in
            guard let self = self else { return }
            defer {
                Task { @MainActor in
                    self.saveBtn.isEnabled = true
                    self.spinner.stopAnimating()
                }
            }
            do {
                let _: APIResponse<AnyCodable> = try await APIManager.shared.postMultipartForm(
                    type: .addShippingAddress(param: fields),
                    fields: fields,
                    header: true
                )
                await MainActor.run {
                    self.onSaved?()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    let msg = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
                    let alert = UIAlertController(title: "Couldn't save address", message: msg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func nonEmpty(_ tf: UITextField, _ label: String) -> String? {
        let txt = (tf.text ?? "").trimmingCharacters(in: .whitespaces)
        if txt.isEmpty {
            Utilities.sharedInstance.showToast(source: self, message: "Please enter your \(label).")
            return nil
        }
        return txt
    }
}
