//
//  FilterViewController.swift
//  BidCast
//
//  Created by Trey Difficult Task Agent on 2026-04-21.
//
//  Modal filter sheet for the Explore tab. Built programmatically so it can
//  be iterated on without storyboard merge conflicts.
//
//  ⚠️ QA-FIX-cmo93i6gp — MIN-PRICE INPUT BUG
//  -----------------------------------------
//  The old mock UI wiped the text field back to "0" whenever the user partially
//  typed a number (e.g. typing "15" became "0" → "0" → "0" because every
//  keystroke ran `Int(input) ?? 0`).
//
//  Correct contract (preserved here):
//    • Model value is `Int?` — `nil` means "field empty".
//    • `shouldChangeCharactersIn` ONLY permits digit characters.
//    • The model is updated only when the resulting string is EMPTY (→ nil)
//      or PARSEABLE (→ Int). We never write "0" on the user's behalf.
//    • We never reassign `textField.text` inside `shouldChangeCharactersIn` —
//      the system is allowed to perform the edit itself (return true).
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterDidApply(_ filter: ProductFilter)
    func filterDidReset()
}

final class FilterViewController: UIViewController {

    // MARK: - Public

    weak var delegate: FilterViewControllerDelegate?

    /// Filter to pre-populate the sheet with (passed in by the parent).
    var initialFilter: ProductFilter = .empty

    /// Categories loaded by the parent; used to drive the picker row.
    var categories: [CategoryModel] = []

    // MARK: - Private state (model-side)

    private var minPrice: Int? = nil
    private var maxPrice: Int? = nil
    private var selectedCategoryID: Int? = nil
    private var selectedSort: ProductSort = .newest

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Filter Products"
        l.font = .boldSystemFont(ofSize: 20)
        l.textColor = .black
        return l
    }()

    private let minPriceField = UITextField()
    private let maxPriceField = UITextField()
    private let categoryButton = UIButton(type: .system)
    private let sortButton = UIButton(type: .system)

    private let applyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Apply", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .systemBlue
        b.titleLabel?.font = .boldSystemFont(ofSize: 16)
        b.layer.cornerRadius = 8
        return b
    }()

    private let resetButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Reset", for: .normal)
        b.setTitleColor(.systemBlue, for: .normal)
        b.backgroundColor = .systemGray6
        b.titleLabel?.font = .boldSystemFont(ofSize: 16)
        b.layer.cornerRadius = 8
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        hydrateFromInitialFilter()
        buildUI()
    }

    private func hydrateFromInitialFilter() {
        self.minPrice = initialFilter.minPrice
        self.maxPrice = initialFilter.maxPrice
        self.selectedCategoryID = initialFilter.categoryID
        self.selectedSort = initialFilter.sortBy
    }

    // MARK: - UI construction

    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        // Title + close
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.distribution = .fill
        let closeBtn = UIButton(type: .system)
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = .black
        closeBtn.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        titleRow.addArrangedSubview(titleLabel)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleRow.addArrangedSubview(spacer)
        titleRow.addArrangedSubview(closeBtn)
        contentStack.addArrangedSubview(titleRow)

        // Price range
        contentStack.addArrangedSubview(sectionHeader("Price Range"))
        let priceRow = UIStackView()
        priceRow.axis = .horizontal
        priceRow.spacing = 12
        priceRow.distribution = .fillEqually
        styleTextField(minPriceField, placeholder: "Min $")
        styleTextField(maxPriceField, placeholder: "Max $")
        bindPriceTextField(minPriceField, role: .min)
        bindPriceTextField(maxPriceField, role: .max)
        priceRow.addArrangedSubview(minPriceField)
        priceRow.addArrangedSubview(maxPriceField)
        contentStack.addArrangedSubview(priceRow)

        // Seed text from the initial filter (only when set — empty otherwise).
        minPriceField.text = minPrice.map { String($0) } ?? ""
        maxPriceField.text = maxPrice.map { String($0) } ?? ""

        // Category picker
        contentStack.addArrangedSubview(sectionHeader("Category"))
        configurePickerButton(categoryButton, title: currentCategoryTitle())
        categoryButton.addTarget(self, action: #selector(onCategoryTap), for: .touchUpInside)
        contentStack.addArrangedSubview(categoryButton)

        // Sort picker
        contentStack.addArrangedSubview(sectionHeader("Sort By"))
        configurePickerButton(sortButton, title: selectedSort.displayName)
        sortButton.addTarget(self, action: #selector(onSortTap), for: .touchUpInside)
        contentStack.addArrangedSubview(sortButton)

        // Actions
        let actionsRow = UIStackView()
        actionsRow.axis = .horizontal
        actionsRow.spacing = 12
        actionsRow.distribution = .fillEqually
        resetButton.addTarget(self, action: #selector(onReset), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(onApply), for: .touchUpInside)
        [resetButton, applyButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
            actionsRow.addArrangedSubview($0)
        }
        contentStack.addArrangedSubview(UIView()) // flexible spacer
        contentStack.addArrangedSubview(actionsRow)
    }

    private func sectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .boldSystemFont(ofSize: 16)
        l.textColor = .darkGray
        return l
    }

    private func styleTextField(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.keyboardType = .numberPad
        tf.borderStyle = .none
        tf.backgroundColor = .systemGray6
        tf.layer.cornerRadius = 8
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        tf.setLeftPadding(12)
        tf.font = .systemFont(ofSize: 16)
        tf.textColor = .black
        tf.delegate = self
    }

    private func configurePickerButton(_ btn: UIButton, title: String) {
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func currentCategoryTitle() -> String {
        if let id = selectedCategoryID,
           let match = categories.first(where: { $0.id == id }),
           let name = match.name {
            return name
        }
        return "All Categories"
    }

    // MARK: - Price TextField binding (the important bit)

    private enum PriceRole { case min, max }

    /// Tagging scheme used by the delegate methods to know which model slot
    /// to update without extra `@IBOutlet` plumbing.
    private func bindPriceTextField(_ tf: UITextField, role: PriceRole) {
        tf.tag = (role == .min) ? 1001 : 1002
        tf.addTarget(self, action: #selector(priceEditingChanged(_:)), for: .editingChanged)
    }

    @objc private func priceEditingChanged(_ sender: UITextField) {
        // The text the user actually sees RIGHT NOW. We never re-assign it.
        let raw = sender.text ?? ""
        let parsed: Int? = {
            if raw.isEmpty { return nil }
            return Int(raw) // all-digits guaranteed by shouldChangeCharactersIn
        }()

        if sender.tag == 1001 {
            self.minPrice = parsed
        } else if sender.tag == 1002 {
            self.maxPrice = parsed
        }
        // Intentionally: no `sender.text = ...` here. Avoids the classic
        // "typed 15, field shows 0" bug (QA-FIX-cmo93i6gp).
    }

    // MARK: - Actions

    @objc private func onClose() { dismiss(animated: true) }

    @objc private func onReset() {
        minPrice = nil
        maxPrice = nil
        selectedCategoryID = nil
        selectedSort = .newest
        minPriceField.text = ""
        maxPriceField.text = ""
        categoryButton.setTitle(currentCategoryTitle(), for: .normal)
        sortButton.setTitle(selectedSort.displayName, for: .normal)
        delegate?.filterDidReset()
        dismiss(animated: true)
    }

    @objc private func onApply() {
        // Sanity: if both set and min > max, swap so the server never 400s.
        var mn = minPrice
        var mx = maxPrice
        if let a = mn, let b = mx, a > b {
            swap(&mn, &mx)
        }
        var f = initialFilter
        f.minPrice = mn
        f.maxPrice = mx
        f.categoryID = selectedCategoryID
        f.sortBy = selectedSort
        f.page = 1
        delegate?.filterDidApply(f)
        dismiss(animated: true)
    }

    @objc private func onCategoryTap() {
        let alert = UIAlertController(title: "Category", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "All Categories", style: .default) { [weak self] _ in
            self?.selectedCategoryID = nil
            self?.categoryButton.setTitle(self?.currentCategoryTitle(), for: .normal)
        })
        for cat in categories {
            guard let name = cat.name, let id = cat.id else { continue }
            alert.addAction(UIAlertAction(title: name, style: .default) { [weak self] _ in
                self?.selectedCategoryID = id
                self?.categoryButton.setTitle(self?.currentCategoryTitle(), for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func onSortTap() {
        let alert = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        for sort in ProductSort.allCases {
            alert.addAction(UIAlertAction(title: sort.displayName, style: .default) { [weak self] _ in
                self?.selectedSort = sort
                self?.sortButton.setTitle(sort.displayName, for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate (digit-only guard)

extension FilterViewController: UITextFieldDelegate {

    /// Only allow decimal digits. We do NOT mutate the text here — just
    /// permit / deny the edit and let the system apply it. The model is
    /// updated on `.editingChanged`.
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty { return true } // backspace / clear: always allowed
        let allowed = CharacterSet.decimalDigits
        let incoming = CharacterSet(charactersIn: string)
        return allowed.isSuperset(of: incoming)
    }
}

// MARK: - UITextField padding helper (scoped)

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        self.leftView = padding
        self.leftViewMode = .always
    }
}
