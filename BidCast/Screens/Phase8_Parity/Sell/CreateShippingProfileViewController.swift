//
//  CreateShippingProfileViewController.swift
//  BidCast — iOS Parity QA fix (MC task cmolwmp0i00f64315lqq37lv3)
//
//  Mirrors Android `CreateShippingProfileFragment` (~319 lines):
//    - profile name
//    - weight + weight unit (lb / oz / kg / g)
//    - dimensions (W / H / L) + dimension unit (in / cm)
//    - "max items per package" toggle (when on, dims are required)
//    - "additional weight per item" toggle (when on, increment fields)
//    - USPS pre-load on save toggle: defaults to USPS Standard
//      (8.5 × 5.5 × 1.5 in, 5 oz) per the audit's "USPS pre-loaded"
//      requirement.
//
//  POST `api/store-shipping-profile` (multipart) — same shape as Android.
//
//  Reachable from:
//    - "+ Add new profile" entry in `AddEditProductViewController`'s
//      shipping-profile picker.
//    - Any direct push (e.g. SellerHub > Shipping > Profiles in a future
//      phase).

import UIKit
import SVProgressHUD

final class CreateShippingProfileViewController: UIViewController {

    // MARK: - Form fields

    private let nameField: UITextField = {
        let f = UITextField()
        f.placeholder = "Profile name (e.g. \"Small box\")"
        f.borderStyle = .roundedRect
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let weightField: UITextField = {
        let f = UITextField()
        f.placeholder = "Weight"
        f.borderStyle = .roundedRect
        f.keyboardType = .decimalPad
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let weightUnitField = UITextField()
    private let dimUnitField    = UITextField()

    private let widthField: UITextField = {
        let f = UITextField()
        f.placeholder = "Width"
        f.borderStyle = .roundedRect
        f.keyboardType = .decimalPad
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let heightField: UITextField = {
        let f = UITextField()
        f.placeholder = "Height"
        f.borderStyle = .roundedRect
        f.keyboardType = .decimalPad
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let lengthField: UITextField = {
        let f = UITextField()
        f.placeholder = "Length"
        f.borderStyle = .roundedRect
        f.keyboardType = .decimalPad
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let maxItemsField: UITextField = {
        let f = UITextField()
        f.placeholder = "Max items per package"
        f.borderStyle = .roundedRect
        f.keyboardType = .numberPad
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let incrementWeightField: UITextField = {
        let f = UITextField()
        f.placeholder = "Additional weight per item"
        f.borderStyle = .roundedRect
        f.keyboardType = .decimalPad
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let incrementWeightUnitField = UITextField()

    private let maxItemsSwitch    = UISwitch()
    private let extraWeightSwitch = UISwitch()

    // MARK: - State

    private var weightUnit: String = "lb"
    private var dimUnit: String    = "Inch"
    private var incrementWeightUnit: String = "lb"

    private weak var maxItemsExpand: UIView?
    private weak var extraWeightExpand: UIView?

    // USPS pre-load defaults (matches Android `CreateShippingProfileFragment`
    // box-dim dropdown's "Custom" / standard preset behavior). Audit calls
    // these out explicitly: 8.5 × 5.5 × 1.5 in, 5 oz.
    private let uspsDefaults = (
        weight: "5", weightUnit: "oz",
        width:  "8.5", height: "5.5", length: "1.5",
        dimUnit: "Inch"
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New shipping profile"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(save))
        layout()
        applyUSPSDefaults()
    }

    private func layout() {
        // Picker fields use unified styling.
        for f in [weightUnitField, dimUnitField, incrementWeightUnitField] {
            f.borderStyle = .roundedRect
            f.translatesAutoresizingMaskIntoConstraints = false
            f.tintColor = .clear
            f.isUserInteractionEnabled = true
        }
        weightUnitField.placeholder = "Unit"
        dimUnitField.placeholder = "Unit"
        incrementWeightUnitField.placeholder = "Unit"

        weightUnitField.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: #selector(pickWeightUnit)))
        dimUnitField.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: #selector(pickDimUnit)))
        incrementWeightUnitField.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: #selector(pickIncrementWeightUnit)))

        // Weight row: weight + weight-unit
        let weightRow = UIStackView(arrangedSubviews: [weightField, weightUnitField])
        weightRow.axis = .horizontal
        weightRow.spacing = 8
        weightRow.distribution = .fill
        weightUnitField.widthAnchor.constraint(equalToConstant: 80).isActive = true

        // Dimensions row: W / H / L + unit
        let dimsRow = UIStackView(arrangedSubviews: [widthField, heightField, lengthField, dimUnitField])
        dimsRow.axis = .horizontal
        dimsRow.spacing = 8
        dimsRow.distribution = .fillEqually

        // Increment weight row
        let incRow = UIStackView(arrangedSubviews: [incrementWeightField, incrementWeightUnitField])
        incRow.axis = .horizontal
        incRow.spacing = 8
        incrementWeightUnitField.widthAnchor.constraint(equalToConstant: 80).isActive = true

        // "Max items" expand container
        let maxItemsBlock = UIStackView(arrangedSubviews: [maxItemsField])
        maxItemsBlock.axis = .vertical
        maxItemsBlock.spacing = 8
        maxItemsBlock.isHidden = true
        self.maxItemsExpand = maxItemsBlock

        // "Extra weight" expand container
        let extraBlock = UIStackView(arrangedSubviews: [incRow])
        extraBlock.axis = .vertical
        extraBlock.spacing = 8
        extraBlock.isHidden = true
        self.extraWeightExpand = extraBlock

        // Toggles
        maxItemsSwitch.addTarget(self, action: #selector(toggleMaxItems), for: .valueChanged)
        extraWeightSwitch.addTarget(self, action: #selector(toggleExtraWeight), for: .valueChanged)

        let maxItemsToggle = makeToggleRow("Limit items per package", maxItemsSwitch)
        let extraWeightToggle = makeToggleRow("Additional weight per added item", extraWeightSwitch)

        // USPS preset button — explicit hint that defaults can be re-applied.
        let presetBtn = UIButton(type: .system)
        var presetCfg = UIButton.Configuration.plain()
        presetCfg.title = "Reset to USPS standard (8.5 × 5.5 × 1.5 in, 5 oz)"
        presetCfg.image = UIImage(systemName: "shippingbox")
        presetCfg.imagePadding = 6
        presetBtn.configuration = presetCfg
        presetBtn.addTarget(self, action: #selector(applyUSPSDefaults), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel("Profile"),
            labeled("Name", nameField),
            sectionLabel("Weight"),
            labeled("Weight per package", weightRow),
            sectionLabel("Dimensions"),
            labeled("W / H / L", dimsRow),
            presetBtn,
            sectionLabel("Limits (optional)"),
            maxItemsToggle, maxItemsBlock,
            extraWeightToggle, extraBlock,
            UIView()
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.keyboardDismissMode = .onDrag
        view.addSubview(scroll)
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -32)
        ])
    }

    private func sectionLabel(_ s: String) -> UILabel {
        let l = UILabel()
        l.text = s
        l.font = .systemFont(ofSize: 13, weight: .heavy)
        l.textColor = .secondaryLabel
        return l
    }

    private func labeled(_ s: String, _ field: UIView) -> UIView {
        let lbl = UILabel()
        lbl.text = s
        lbl.font = .systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .secondaryLabel
        let stack = UIStackView(arrangedSubviews: [lbl, field])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private func makeToggleRow(_ s: String, _ sw: UISwitch) -> UIView {
        let lbl = UILabel()
        lbl.text = s
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        lbl.numberOfLines = 0
        sw.translatesAutoresizingMaskIntoConstraints = false
        let row = UIStackView(arrangedSubviews: [lbl, sw])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        return row
    }

    // MARK: - USPS preset

    @objc private func applyUSPSDefaults() {
        weightField.text = uspsDefaults.weight
        weightUnit       = uspsDefaults.weightUnit
        weightUnitField.text = weightUnit
        widthField.text  = uspsDefaults.width
        heightField.text = uspsDefaults.height
        lengthField.text = uspsDefaults.length
        dimUnit          = uspsDefaults.dimUnit
        dimUnitField.text = dimUnit
    }

    // MARK: - Toggles

    @objc private func toggleMaxItems() {
        maxItemsExpand?.isHidden = !maxItemsSwitch.isOn
    }

    @objc private func toggleExtraWeight() {
        extraWeightExpand?.isHidden = !extraWeightSwitch.isOn
    }

    // MARK: - Unit pickers

    @objc private func pickWeightUnit() { presentUnits(["lb", "oz", "kg", "g"]) { [weak self] u in
        self?.weightUnit = u; self?.weightUnitField.text = u
    } }

    @objc private func pickIncrementWeightUnit() { presentUnits(["lb", "oz", "kg", "g"]) { [weak self] u in
        self?.incrementWeightUnit = u; self?.incrementWeightUnitField.text = u
    } }

    @objc private func pickDimUnit() { presentUnits(["Inch", "Centimeter"]) { [weak self] u in
        self?.dimUnit = u; self?.dimUnitField.text = u
    } }

    private func presentUnits(_ units: [String], _ pick: @escaping (String) -> Void) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for u in units {
            sheet.addAction(UIAlertAction(title: u, style: .default) { _ in pick(u) })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    // MARK: - Save

    @objc private func save() {
        guard let name = nameField.text, !name.isEmpty else {
            p3Alert(message: "Please enter a profile name."); return
        }
        guard let w = weightField.text, !w.isEmpty else {
            p3Alert(message: "Please enter a weight."); return
        }
        guard !weightUnit.isEmpty else {
            p3Alert(message: "Please pick a weight unit."); return
        }

        // Mirror Android field names (note `additionalWeight`, `maxItems`
        // are camelCase parts on the wire; rest are snake_case).
        var fields: [String: String] = [
            "name": name,
            "size": weightUnit,
            "weight": w,
            "additionalWeight": extraWeightSwitch.isOn ? "1" : "0",
            "maxItems": maxItemsSwitch.isOn ? "1" : "0",
        ]

        if maxItemsSwitch.isOn {
            guard let mi = maxItemsField.text, !mi.isEmpty else {
                p3Alert(message: "Please enter the max items per package."); return
            }
            guard let h = heightField.text, !h.isEmpty,
                  let wd = widthField.text, !wd.isEmpty,
                  let l = lengthField.text, !l.isEmpty else {
                p3Alert(message: "Please enter package height, width, and length."); return
            }
            fields["max_item_unit"] = mi
            fields["height"] = h
            fields["width"] = wd
            fields["length"] = l
            fields["scale"] = dimUnit
        } else {
            // When max-items is off Android still happily stores dims
            // (the box-dim dropdown writes to those fields). Send what we
            // have so the USPS preset survives a save.
            if let h = heightField.text, !h.isEmpty { fields["height"] = h }
            if let wd = widthField.text, !wd.isEmpty { fields["width"] = wd }
            if let l = lengthField.text, !l.isEmpty { fields["length"] = l }
            if !dimUnit.isEmpty { fields["scale"] = dimUnit }
        }

        if extraWeightSwitch.isOn {
            guard let inc = incrementWeightField.text, !inc.isEmpty else {
                p3Alert(message: "Please enter the additional weight per item."); return
            }
            fields["increment_weight"] = inc
            fields["increment_weight_scale"] = incrementWeightUnit
        }

        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .storeShippingProfile(param: [:]),
                    fields: fields,
                    header: true)
                p3Alert(title: "Saved",
                        message: "Shipping profile saved.") { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                    self?.dismiss(animated: true)
                }
            } catch {
                p3Alert(message: (error as? DataError)?.getErrorMessage()
                        ?? error.localizedDescription)
            }
        }
    }
}
