//
//  ExploreSubcategoryPickerSheet.swift
//  BidCast — iOS Parity Phase 8 / P2.15 (2026-04-23)
//
//  Bottom sheet that lets the user drill into a sub-category under the
//  currently-selected top-level Explore category. Android reference:
//  `ExploreFragment.onCategoryClick` -> `ExploreTypeFragment` which
//  hydrates a sub-category list via `get-subcategories` and re-queries
//  products. On iOS we stay inside the same tab to avoid a full push.
//
//  Flow:
//    1. Shown when a user re-taps an already-selected category chip.
//    2. Immediately fires `GET api/get-subcategories` through
//       `ExploreViewModel.fetchSubcategories`. Shows a spinner while
//       loading.
//    3. First row is always "All <category>" which clears the
//       sub-category filter. Tapping any sub-category row applies the
//       filter and dismisses.
//    4. Parent `ExploreViewController` refreshes the product grid via
//       `ExploreViewModel.setSelectedSubcategory`.
//

import UIKit

final class ExploreSubcategoryPickerSheet: UIViewController,
                                            UITableViewDataSource,
                                            UITableViewDelegate {

    // MARK: - Input

    /// Category id used to fetch sub-categories.
    private let categoryID: Int
    /// The currently-applied sub-category filter so we can show a checkmark.
    private let currentSubcategoryID: Int?
    /// Shared view-model that owns the `fetchSubcategories` network call.
    private weak var viewModel: ExploreViewModel?

    var onPicked: ((Int?) -> Void)?

    // MARK: - State

    private var items: [SubCategory] = []
    private var isLoading = false

    // MARK: - UI

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Filter by sub-category"
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.rowHeight = 48
        return t
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Init

    init(categoryID: Int,
         currentSubcategoryID: Int?,
         viewModel: ExploreViewModel) {
        self.categoryID = categoryID
        self.currentSubcategoryID = currentSubcategoryID
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(spinner)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        loadSubcategories()
    }

    // MARK: - Networking

    private func loadSubcategories() {
        isLoading = true
        spinner.startAnimating()
        tableView.reloadData()

        Task { [weak self] in
            guard let self = self, let vm = self.viewModel else { return }
            let list = await vm.fetchSubcategories(categoryID: self.categoryID)
            self.items = list
            self.isLoading = false
            self.spinner.stopAnimating()
            self.tableView.reloadData()
        }
    }

    // MARK: - Table

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // First row is always "All <category>"; skip it while loading so
        // the user doesn't accidentally tap through with no sub-cats yet.
        return isLoading ? 0 : items.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "All"
            cell.accessoryType = (currentSubcategoryID == nil) ? .checkmark : .none
            cell.imageView?.image = UIImage(systemName: "square.grid.2x2")
        } else {
            let sub = items[indexPath.row - 1]
            cell.textLabel?.text = sub.name ?? "Untitled"
            cell.accessoryType = (sub.id == currentSubcategoryID) ? .checkmark : .none
            cell.imageView?.image = UIImage(systemName: "tag")
        }
        cell.imageView?.tintColor = .secondaryLabel
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let picked: Int?
        if indexPath.row == 0 {
            picked = nil
        } else {
            picked = items[indexPath.row - 1].id
        }
        onPicked?(picked)
        dismiss(animated: true)
    }
}
