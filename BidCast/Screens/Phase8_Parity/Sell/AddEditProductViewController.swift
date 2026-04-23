//
//  AddEditProductViewController.swift
//  BidCast — iOS parity Phase 8 / P1.9a (2026-04-23)
//
//  Real Add/Edit Product form matching Android `ListAProductFragment`
//  (1501 lines). The Android version is a single scrollable fragment
//  (not a stepped wizard), so we mirror that layout — a single
//  scroll view with all fields.
//
//  Covered in P1.9a (this commit):
//    - title, description
//    - category picker (api/get-category)
//    - sub-category picker (api/get-subcategories)
//    - sales-format picker: Buy Now / Auction / Surprise Set
//    - quantity, pricing
//    - weight + shipping dimensions (width / height / length)
//    - condition picker (new / used)
//    - toggles: accept_offers, flash_sale, reserve_for_live
//
//  Deferred to P1.9b:
//    - image multi-picker + thumbnail selector (calls store-product-meta
//      with product_images[], videos[], thumbnail[]).
//
//  Backend:
//    - POST api/store-product (multipart form) creates or updates the
//      product. For edit, fields include `product_id`.
//    - POST api/store-product-meta (multipart with file parts) uploads
//      image + video files separately in P1.9b.
//

import UIKit
import SVProgressHUD

final class AddEditProductViewController: UIViewController {

    enum Mode {
        case create
        case edit(WireProduct)
    }

    private let mode: Mode

    // MARK: - Fields

    private let titleField = UITextField()
    private let descView = UITextView()
    private let priceField = UITextField()
    private let quantityField = UITextField()
    private let weightField = UITextField()
    private let widthField = UITextField()
    private let heightField = UITextField()
    private let lengthField = UITextField()
    private let skuField = UITextField()

    private let categoryField = UITextField()
    private let subCategoryField = UITextField()
    private let salesFormatField = UITextField()
    private let conditionField = UITextField()
    private let mailClassField = UITextField()

    private let acceptOffersSwitch = UISwitch()
    private let flashSaleSwitch = UISwitch()
    private let reserveForLiveSwitch = UISwitch()

    // MARK: - Selection state

    private var selectedCategoryId: Int?
    private var selectedSubCategoryId: Int?
    private var selectedSalesFormat: SalesFormat = .buyNow
    private var selectedCondition: ProductCondition = .new
    private var selectedMailClass: String?

    private var availableCategories: [Category] = []
    private var availableSubCategories: [SubCategory] = []
    private var availableMailClasses: [MailClass] = []

    // MARK: - Sales format enum

    enum SalesFormat: String, CaseIterable {
        case buyNow = "buy_now"
        case auction = "auction"
        case surpriseSet = "surprise_set"

        var label: String {
            switch self {
            case .buyNow: return "Buy Now"
            case .auction: return "Auction"
            case .surpriseSet: return "Surprise Set"
            }
        }
    }

    enum ProductCondition: String, CaseIterable {
        case new = "new"
        case likeNew = "like_new"
        case used = "used"
        case refurbished = "refurbished"

        var label: String {
            switch self {
            case .new: return "New"
            case .likeNew: return "Like new"
            case .used: return "Used"
            case .refurbished: return "Refurbished"
            }
        }
    }

    // MARK: - Init

    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        switch mode {
        case .create: self.title = "Add product"
        case .edit(let p): self.title = p.title ?? "Edit product"
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(save))

        buildForm()
        loadCategories()
        loadMailClasses()
        if case .edit(let p) = mode { populate(from: p) }
    }

    // MARK: - Form build

    private func buildForm() {
        [titleField, priceField, quantityField, weightField, widthField,
         heightField, lengthField, skuField, categoryField, subCategoryField,
         salesFormatField, conditionField, mailClassField].forEach {
            $0.borderStyle = .roundedRect
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleField.placeholder = "Title"
        priceField.placeholder = "Price (USD)"
        priceField.keyboardType = .decimalPad
        quantityField.placeholder = "Quantity"
        quantityField.keyboardType = .numberPad
        weightField.placeholder = "Weight (lbs)"
        weightField.keyboardType = .decimalPad
        widthField.placeholder = "Width (in)"
        widthField.keyboardType = .decimalPad
        heightField.placeholder = "Height (in)"
        heightField.keyboardType = .decimalPad
        lengthField.placeholder = "Length (in)"
        lengthField.keyboardType = .decimalPad
        skuField.placeholder = "SKU (optional)"

        categoryField.placeholder = "Category"
        subCategoryField.placeholder = "Sub-category"
        salesFormatField.placeholder = "Sales format"
        conditionField.placeholder = "Condition"
        mailClassField.placeholder = "Mail class (optional)"

        // Default selections
        salesFormatField.text = selectedSalesFormat.label
        conditionField.text = selectedCondition.label

        [categoryField, subCategoryField, salesFormatField,
         conditionField, mailClassField].forEach {
            $0.isUserInteractionEnabled = true
            $0.tintColor = .clear  // don't show a blinking caret — this is a picker
        }
        categoryField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickCategory)))
        subCategoryField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickSubCategory)))
        salesFormatField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickSalesFormat)))
        conditionField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickCondition)))
        mailClassField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickMailClass)))

        descView.font = .systemFont(ofSize: 15)
        descView.layer.borderColor = UIColor.separator.cgColor
        descView.layer.borderWidth = 1
        descView.layer.cornerRadius = 8
        descView.translatesAutoresizingMaskIntoConstraints = false
        descView.heightAnchor.constraint(equalToConstant: 140).isActive = true

        // Switches need labels → group as mini rows.
        let acceptOffersRow = makeToggleRow("Accept offers", acceptOffersSwitch)
        let flashSaleRow = makeToggleRow("Flash sale", flashSaleSwitch)
        let reserveForLiveRow = makeToggleRow("Reserve for live show", reserveForLiveSwitch)

        // Dimensions row (width / height / length as a 3-column horizontal stack).
        let dimsStack = UIStackView(arrangedSubviews: [widthField, heightField, lengthField])
        dimsStack.axis = .horizontal
        dimsStack.spacing = 8
        dimsStack.distribution = .fillEqually

        // Image upload placeholder (P1.9b will wire this)
        let imagesPlaceholder = makeImagesPlaceholder()

        let stack = UIStackView(arrangedSubviews: [
            sectionLabel("Basics"),
            labeled("Title", titleField),
            labeled("Description", descView),
            sectionLabel("Pricing & inventory"),
            labeled("Price", priceField),
            labeled("Quantity", quantityField),
            labeled("Sales format", salesFormatField),
            labeled("Condition", conditionField),
            labeled("SKU", skuField),
            sectionLabel("Category"),
            labeled("Category", categoryField),
            labeled("Sub-category", subCategoryField),
            sectionLabel("Shipping"),
            labeled("Weight (lbs)", weightField),
            labeled("Dimensions (in)", dimsStack),
            labeled("Mail class", mailClassField),
            sectionLabel("Options"),
            acceptOffersRow, flashSaleRow, reserveForLiveRow,
            sectionLabel("Photos"),
            imagesPlaceholder,
            UIView()
        ])
        stack.axis = .vertical
        stack.spacing = 10
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
        sw.translatesAutoresizingMaskIntoConstraints = false
        let row = UIStackView(arrangedSubviews: [lbl, sw])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        return row
    }

    private func makeImagesPlaceholder() -> UIView {
        let lbl = UILabel()
        lbl.text = "Image upload lands in the next build (P1.9b)."
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .tertiaryLabel
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        let wrap = UIView()
        wrap.backgroundColor = .secondarySystemBackground
        wrap.layer.cornerRadius = 8
        wrap.translatesAutoresizingMaskIntoConstraints = false
        lbl.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(lbl)
        NSLayoutConstraint.activate([
            wrap.heightAnchor.constraint(equalToConstant: 80),
            lbl.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            lbl.leadingAnchor.constraint(greaterThanOrEqualTo: wrap.leadingAnchor, constant: 12),
            lbl.trailingAnchor.constraint(lessThanOrEqualTo: wrap.trailingAnchor, constant: -12)
        ])
        return wrap
    }

    // MARK: - Populate (edit)

    private func populate(from p: WireProduct) {
        titleField.text = p.title
        descView.text = p.description
        priceField.text = p.pricing
        quantityField.text = p.quantity
        if let id = p.categoryId {
            selectedCategoryId = id
            categoryField.text = p.category?.name ?? "Category #\(id)"
        }
        if let sid = p.subCategoryId?.value as? Int {
            selectedSubCategoryId = sid
            subCategoryField.text = p.subCategory?.name ?? "Sub #\(sid)"
        }
        if p.auction == true {
            selectedSalesFormat = .auction
        } else if p.reserveForLive == true {
            selectedSalesFormat = .auction       // reserved-for-live is an auction-style variant
        } else {
            selectedSalesFormat = .buyNow
        }
        salesFormatField.text = selectedSalesFormat.label
        if let cond = p.productCondition,
           let parsed = ProductCondition(rawValue: cond) {
            selectedCondition = parsed
            conditionField.text = parsed.label
        }
        if let w = p.weight { weightField.text = "\(w)" }
        if let w = p.width { widthField.text = "\(w)" }
        if let h = p.height { heightField.text = "\(h)" }
        if let l = p.length { lengthField.text = "\(l)" }
        skuField.text = p.sku
        mailClassField.text = p.mailClass
        selectedMailClass = p.mailClass
        acceptOffersSwitch.isOn = p.acceptOffers ?? false
        flashSaleSwitch.isOn = p.flashSale ?? false
        reserveForLiveSwitch.isOn = p.reserveForLive ?? false
    }

    // MARK: - Category loading

    private func loadCategories() {
        Task { @MainActor in
            do {
                let resp: GetCategoryResponse = try await APIManager.shared.request(
                    type: .getCategory, header: true)
                self.availableCategories = resp.data ?? []
            } catch {
                self.availableCategories = []
            }
        }
    }

    private func loadSubCategories(for categoryId: Int) {
        Task { @MainActor in
            do {
                let req = GetSubCategoriesRequest(categoryIds: [categoryId], subcategoryIds: nil)
                let fields = [
                    "category_ids": "[\(categoryId)]"
                ]
                _ = req
                let resp: GetSubCategoriesResponse = try await APIManager.shared.postMultipartForm(
                    type: .getSubCategories(param: req),
                    fields: fields, header: true)
                let groups = resp.data ?? []
                let matching = groups.first { $0.id == categoryId }
                self.availableSubCategories = matching?.subcategories ?? []
            } catch {
                self.availableSubCategories = []
            }
        }
    }

    private func loadMailClasses() {
        Task { @MainActor in
            do {
                let resp: GetMailClassesResponse = try await APIManager.shared.request(
                    type: .getMailClasses, header: true)
                self.availableMailClasses = resp.data?.mailClasses?.compactMap { $0 } ?? []
            } catch {
                self.availableMailClasses = []
            }
        }
    }

    // MARK: - Pickers

    @objc private func pickCategory() {
        guard !availableCategories.isEmpty else {
            p3Alert(message: "Categories still loading. Try again in a moment.")
            return
        }
        let sheet = UIAlertController(title: "Choose category", message: nil, preferredStyle: .actionSheet)
        for c in availableCategories.prefix(30) {
            sheet.addAction(UIAlertAction(title: c.name ?? "—", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.selectedCategoryId = c.id
                self.categoryField.text = c.name
                // Clear sub-category choice; a new list will load.
                self.selectedSubCategoryId = nil
                self.subCategoryField.text = nil
                if let id = c.id { self.loadSubCategories(for: id) }
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func pickSubCategory() {
        guard selectedCategoryId != nil else {
            p3Alert(message: "Pick a category first."); return
        }
        guard !availableSubCategories.isEmpty else {
            p3Alert(message: "No sub-categories for this category.")
            return
        }
        let sheet = UIAlertController(title: "Choose sub-category", message: nil, preferredStyle: .actionSheet)
        for sc in availableSubCategories.prefix(30) {
            sheet.addAction(UIAlertAction(title: sc.name ?? "—", style: .default) { [weak self] _ in
                self?.selectedSubCategoryId = sc.id
                self?.subCategoryField.text = sc.name
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func pickSalesFormat() {
        let sheet = UIAlertController(title: "Sales format", message: nil, preferredStyle: .actionSheet)
        for f in SalesFormat.allCases {
            sheet.addAction(UIAlertAction(title: f.label, style: .default) { [weak self] _ in
                self?.selectedSalesFormat = f
                self?.salesFormatField.text = f.label
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func pickCondition() {
        let sheet = UIAlertController(title: "Condition", message: nil, preferredStyle: .actionSheet)
        for c in ProductCondition.allCases {
            sheet.addAction(UIAlertAction(title: c.label, style: .default) { [weak self] _ in
                self?.selectedCondition = c
                self?.conditionField.text = c.label
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func pickMailClass() {
        guard !availableMailClasses.isEmpty else {
            p3Alert(message: "Mail classes still loading. Try again in a moment.")
            return
        }
        let sheet = UIAlertController(title: "Mail class", message: nil, preferredStyle: .actionSheet)
        for mc in availableMailClasses {
            guard let label = mc.label else { continue }
            sheet.addAction(UIAlertAction(title: label, style: .default) { [weak self] _ in
                self?.selectedMailClass = label
                self?.mailClassField.text = label
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    // MARK: - Save

    @objc private func save() {
        guard let t = titleField.text, !t.isEmpty,
              let price = priceField.text, !price.isEmpty,
              let qty = quantityField.text, !qty.isEmpty else {
            p3Alert(title: "Missing info",
                    message: "Title, price, and quantity are required.")
            return
        }

        var fields: [String: String] = [
            "title": t,
            "description": descView.text ?? "",
            "pricing": price,
            "quantity": qty,
            "status": "active",
            "accept_offers": acceptOffersSwitch.isOn ? "1" : "0",
            "flash_sale": flashSaleSwitch.isOn ? "1" : "0",
            "reserve_for_live": reserveForLiveSwitch.isOn ? "1" : "0",
            "product_condition": selectedCondition.rawValue,
        ]

        if selectedSalesFormat == .auction {
            fields["auction"] = "1"
        } else if selectedSalesFormat == .surpriseSet {
            fields["type"] = "surprise_set"
        }
        if let cid = selectedCategoryId { fields["category_id"] = "\(cid)" }
        if let sid = selectedSubCategoryId { fields["sub_category_id"] = "\(sid)" }
        if let sku = skuField.text, !sku.isEmpty { fields["sku"] = sku }
        if let mc = selectedMailClass { fields["mail_class"] = mc }
        if let w = weightField.text, !w.isEmpty { fields["weight"] = w }
        if let x = widthField.text, !x.isEmpty { fields["width"] = x }
        if let y = heightField.text, !y.isEmpty { fields["height"] = y }
        if let z = lengthField.text, !z.isEmpty { fields["length"] = z }

        if case .edit(let p) = mode, let id = p.id {
            fields["product_id"] = "\(id)"
        }

        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let _: CreateProductResponse = try await APIManager.shared.postMultipartForm(
                    type: .storeProduct(param: StoreProductRequest.empty),
                    fields: fields, header: true)
                self.p3Alert(title: "Saved",
                             message: "Product saved. (Image upload lands in the next build.)") {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }
}
