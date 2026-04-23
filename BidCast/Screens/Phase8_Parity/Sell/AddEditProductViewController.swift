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
//  Added in P1.9b (2026-04-23):
//    - image multi-picker + thumbnail selector (calls store-product-meta
//      with product_images[] and thumbnail[]).
//
//  Backend:
//    - POST api/store-product (multipart form) creates or updates the
//      product. For edit, fields include `product_id`.
//    - POST api/store-product-meta (multipart with file parts) uploads
//      image + video files separately in P1.9b.
//

import UIKit
import SVProgressHUD
import PhotosUI

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

    // MARK: - Image state (P1.9b)

    /// In-memory selected images, in display order. Index 0 is the
    /// thumbnail unless `thumbnailIndex` is different.
    private var pickedImages: [UIImage] = []
    private var thumbnailIndex: Int = 0

    private lazy var imagesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 88, height: 88)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .init(top: 0, left: 4, bottom: 0, right: 4)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .secondarySystemBackground
        cv.layer.cornerRadius = 8
        cv.showsHorizontalScrollIndicator = false
        cv.register(PickedImageCell.self, forCellWithReuseIdentifier: PickedImageCell.reuseID)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private lazy var addImagesButton: UIButton = {
        let btn = UIButton(type: .system)
        var cfg = UIButton.Configuration.bordered()
        cfg.title = "Add photos"
        cfg.image = UIImage(systemName: "photo.badge.plus")
        cfg.imagePadding = 6
        btn.configuration = cfg
        btn.addTarget(self, action: #selector(pickImages), for: .touchUpInside)
        return btn
    }()

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

        // Image multi-picker + strip (P1.9b)
        let imagesSection = makeImagesSection()

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
            imagesSection,
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

    private func makeImagesSection() -> UIView {
        let strip = UIView()
        strip.translatesAutoresizingMaskIntoConstraints = false
        imagesCollection.dataSource = self
        imagesCollection.delegate = self
        strip.addSubview(imagesCollection)
        strip.addSubview(addImagesButton)
        addImagesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imagesCollection.topAnchor.constraint(equalTo: strip.topAnchor),
            imagesCollection.leadingAnchor.constraint(equalTo: strip.leadingAnchor),
            imagesCollection.trailingAnchor.constraint(equalTo: strip.trailingAnchor),
            imagesCollection.heightAnchor.constraint(equalToConstant: 96),
            addImagesButton.topAnchor.constraint(equalTo: imagesCollection.bottomAnchor, constant: 8),
            addImagesButton.leadingAnchor.constraint(equalTo: strip.leadingAnchor),
            addImagesButton.bottomAnchor.constraint(equalTo: strip.bottomAnchor)
        ])
        return strip
    }

    @objc private func pickImages() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = max(0, 10 - pickedImages.count)
        if config.selectionLimit == 0 {
            p3Alert(message: "You can attach up to 10 images. Remove one to add another.")
            return
        }
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
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
                let resp: CreateProductResponse = try await APIManager.shared.postMultipartForm(
                    type: .storeProduct(param: StoreProductRequest.empty),
                    fields: fields, header: true)

                // Determine resulting product id so we can upload images.
                let resultingId: Int? = {
                    if case .edit(let p) = mode { return p.id }
                    return resp.data?.id
                }()

                if let pid = resultingId, !self.pickedImages.isEmpty {
                    SVProgressHUD.show(withStatus: "Uploading photos…")
                    let imgDatas = self.pickedImages.compactMap { $0.jpegData(compressionQuality: 0.85) }
                    let thumb = self.pickedImages.indices.contains(self.thumbnailIndex)
                        ? self.pickedImages[self.thumbnailIndex].jpegData(compressionQuality: 0.85)
                        : nil
                    do {
                        _ = try await ProductMetaUploader.upload(pending: .init(
                            productId: pid,
                            images: imgDatas,
                            thumbnail: thumb
                        ))
                    } catch {
                        // Non-fatal: we've created the product, just warn about images.
                        self.p3Alert(title: "Saved without photos",
                                     message: "The product was saved, but uploading photos failed: " +
                                     ((error as? DataError)?.getErrorMessage() ?? error.localizedDescription)) {
                            self.navigationController?.popViewController(animated: true)
                        }
                        return
                    }
                }

                self.p3Alert(title: "Saved", message: "Product saved.") {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                self.p3Alert(message: (error as? DataError)?.getErrorMessage() ?? error.localizedDescription)
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension AddEditProductViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }
        let group = DispatchGroup()
        var gathered: [UIImage] = []
        let lock = NSLock()
        for r in results {
            let provider = r.itemProvider
            guard provider.canLoadObject(ofClass: UIImage.self) else { continue }
            group.enter()
            provider.loadObject(ofClass: UIImage.self) { obj, _ in
                defer { group.leave() }
                if let img = obj as? UIImage {
                    lock.lock(); gathered.append(img); lock.unlock()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.pickedImages.append(contentsOf: gathered)
            self.imagesCollection.reloadData()
        }
    }
}

// MARK: - UICollectionView data source (image strip)

extension AddEditProductViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pickedImages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PickedImageCell.reuseID, for: indexPath) as! PickedImageCell
        cell.imageView.image = pickedImages[indexPath.item]
        cell.isThumbnail = (indexPath.item == thumbnailIndex)
        cell.onRemove = { [weak self] in self?.removeImage(at: indexPath.item) }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Tap to set as thumbnail.
        thumbnailIndex = indexPath.item
        imagesCollection.reloadData()
    }

    private func removeImage(at index: Int) {
        guard pickedImages.indices.contains(index) else { return }
        pickedImages.remove(at: index)
        if thumbnailIndex >= pickedImages.count {
            thumbnailIndex = max(0, pickedImages.count - 1)
        }
        imagesCollection.reloadData()
    }
}

// MARK: - Picked image strip cell

final class PickedImageCell: UICollectionViewCell {
    static let reuseID = "PickedImageCell"

    let imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = 8
        v.backgroundColor = .tertiarySystemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let thumbBadge: UILabel = {
        let l = UILabel()
        l.text = " Thumb "
        l.font = .systemFont(ofSize: 10, weight: .bold)
        l.textColor = .white
        l.backgroundColor = .systemBlue
        l.layer.cornerRadius = 4
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let removeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = .black.withAlphaComponent(0.6)
        b.layer.cornerRadius = 10
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    var onRemove: (() -> Void)?

    var isThumbnail: Bool = false {
        didSet {
            thumbBadge.isHidden = !isThumbnail
            layer.borderWidth = isThumbnail ? 2 : 0
            layer.borderColor = UIColor.systemBlue.cgColor
            layer.cornerRadius = 8
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(thumbBadge)
        contentView.addSubview(removeButton)
        thumbBadge.isHidden = true
        removeButton.addAction(UIAction { [weak self] _ in self?.onRemove?() }, for: .touchUpInside)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            thumbBadge.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            thumbBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            thumbBadge.heightAnchor.constraint(equalToConstant: 16),
            removeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            removeButton.widthAnchor.constraint(equalToConstant: 20),
            removeButton.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
