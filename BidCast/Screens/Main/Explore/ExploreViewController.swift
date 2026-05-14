//
//  ExploreViewController.swift
//  BidCast
//
//  Replaced mockup implementation with real Products/Explore backed by the
//  `api/get-category` + `api/v1/get-product` endpoints that the Android app
//  already uses. The previous version rendered 5 hard-coded category tiles
//  and made no network calls.
//
//  QA-FIX-cmo93i6gp: the min-price filter field (now on `FilterViewController`)
//  correctly preserves user input instead of resetting to 0.
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//  Rewritten by Trey Difficult Task Agent on 2026-04-21.
//

import UIKit
import Kingfisher

private enum ExploreSearchSection: Int, CaseIterable {
    case shows
    case products
    case users

    var title: String {
        switch self {
        case .shows: return "Shows"
        case .products: return "Products"
        case .users: return "Users"
        }
    }
}

final class ExploreViewController: UIViewController {

    // MARK: - Storyboard outlets

    @IBOutlet weak var tableViewOlt: UITableView!
    @IBOutlet weak var headerViewOlt: HeaderWithAppName!

    // MARK: - View model

    private let viewModel = ExploreViewModel()

    // MARK: - Layout constants

    private let searchBarHeight: CGFloat = 44
    private let categoryRailHeight: CGFloat = 92
    /// P2.15 — segmented control between the category rail and the
    /// filter button row.
    private let exploreTypeBarHeight: CGFloat = 36
    private let filterBarHeight: CGFloat = 48
    private let productCellAspectRatio: CGFloat = 1.25 // height = width * ratio
    private let productGridSpacing: CGFloat = 12
    private let productGridColumns: CGFloat = 2

    // MARK: - UI (built programmatically on top of the storyboard)

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): Android
        // `fragment_explore.xml` search hint is
        // `@string/what_are_you_looking_for`.
        sb.placeholder = "What are you looking for?"
        sb.searchBarStyle = .minimal
        sb.delegate = self
        sb.translatesAutoresizingMaskIntoConstraints = false
        // Android wraps the search inside an `inputBoxStyle` TextInputLayout
        // with a 2dp stroke + light fill. Approximate with a soft tint.
        if let textField = sb.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = AppColor.lightGray
            textField.layer.cornerRadius = 12
            textField.layer.masksToBounds = true
            textField.font = .systemFont(ofSize: 14)
        }
        return sb
    }()

    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ExploreCategoryChipCell.self,
                    forCellWithReuseIdentifier: ExploreCategoryChipCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        cv.tag = 100 // categories
        return cv
    }()

    /// P2.15 — Explore type tabs (All / Recommended / Popular). Mirrors
    /// Android's ExploreFragment segmented control.
    private lazy var exploreTypeControl: UISegmentedControl = {
        let items = ExploreType.allCases.map { $0.displayName }
        let c = UISegmentedControl(items: items)
        c.selectedSegmentIndex = 0
        c.translatesAutoresizingMaskIntoConstraints = false
        c.addTarget(self, action: #selector(onExploreTypeChanged), for: .valueChanged)
        return c
    }()

    private lazy var filterBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    private lazy var filterButton: UIButton = {
        let b = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let icon = UIImage(systemName: "slider.horizontal.3", withConfiguration: config)
        b.setImage(icon, for: .normal)
        b.setTitle("  Filter", for: .normal)
        b.tintColor = .white
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 14)
        // VISUAL PARITY 2026-05-01: Android `appBtn` style is brand blue
        // (#0058BD), white text. Replace the iOS `.systemBlue` placeholder
        // with AppColor.primary so it reads as the same CTA.
        b.backgroundColor = AppColor.primary
        b.layer.cornerRadius = 8
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(onFilterTap), for: .touchUpInside)
        return b
    }()

    private lazy var resultsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .darkGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var searchResultsTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "searchResult")
        tv.isHidden = true
        return tv
    }()

    private lazy var productsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = productGridSpacing
        layout.minimumLineSpacing = productGridSpacing
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ExploreProductCell.self,
                    forCellWithReuseIdentifier: ExploreProductCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        cv.tag = 200 // products
        return cv
    }()

    private lazy var emptyStateLabel: UILabel = {
        let l = UILabel()
        l.text = "No products match the current filter."
        l.textColor = .gray
        l.textAlignment = .center
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 15)
        l.translatesAutoresizingMaskIntoConstraints = false
        l.isHidden = true
        return l
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "bgColor") ?? .systemBackground
        configureHeaderView()

        // Hide the old storyboard tableView and lay out the new UI on top of it.
        tableViewOlt?.isHidden = true
        buildUI()

        viewModel.delegate = self
        viewModel.loadInitial()
    }

    private func configureHeaderView() {
        self.headerViewOlt.headerViewSetup(
            rightButtonHidden: false,
            leftButtonHidden: true,
            headerName: "Explore",
            setRightImage: UIImage(systemName: "bell.fill")?.withTintColor(.black, renderingMode: .alwaysTemplate),
            setLeftImage: nil
        )
    }

    private func buildUI() {
        view.addSubview(searchBar)
        view.addSubview(categoryCollectionView)
        view.addSubview(exploreTypeControl)
        view.addSubview(filterBar)
        filterBar.addSubview(resultsLabel)
        filterBar.addSubview(filterButton)
        view.addSubview(productsCollectionView)
        view.addSubview(searchResultsTableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(spinner)

        let header = headerViewOlt!

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: header.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: searchBarHeight),

            categoryCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: categoryRailHeight),

            exploreTypeControl.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 4),
            exploreTypeControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            exploreTypeControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exploreTypeControl.heightAnchor.constraint(equalToConstant: exploreTypeBarHeight),

            filterBar.topAnchor.constraint(equalTo: exploreTypeControl.bottomAnchor),
            filterBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterBar.heightAnchor.constraint(equalToConstant: filterBarHeight),

            resultsLabel.leadingAnchor.constraint(equalTo: filterBar.leadingAnchor),
            resultsLabel.centerYAnchor.constraint(equalTo: filterBar.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: filterBar.trailingAnchor),
            filterButton.centerYAnchor.constraint(equalTo: filterBar.centerYAnchor),

            productsCollectionView.topAnchor.constraint(equalTo: filterBar.bottomAnchor),
            productsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            productsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            searchResultsTableView.topAnchor.constraint(equalTo: filterBar.bottomAnchor),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: productsCollectionView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: productsCollectionView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            spinner.centerXAnchor.constraint(equalTo: productsCollectionView.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: productsCollectionView.topAnchor, constant: 24)
        ])
    }

    // MARK: - Actions

    @objc private func onExploreTypeChanged() {
        let idx = exploreTypeControl.selectedSegmentIndex
        let types = ExploreType.allCases
        guard idx >= 0, idx < types.count else { return }
        viewModel.setExploreType(types[idx])
    }

    @objc private func onFilterTap() {
        let vc = FilterViewController()
        vc.initialFilter = viewModel.filter
        vc.categories = viewModel.categories
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }

    /// Home "See All Categories" should always land the user on Explore's
    /// unfiltered All state, even if the tab was previously left on
    /// Recommended/Popular or a drilled-in category.
    func showAllCategoriesFromHome() {
        searchBar.text = ""
        exploreTypeControl.selectedSegmentIndex = 0
        viewModel.resetFilter()
        categoryCollectionView.reloadData()
        productsCollectionView.setContentOffset(.zero, animated: false)
    }

    // MARK: - Helpers

    private func updateResultsLabel() {
        if viewModel.isShowingUnifiedSearchResults {
            let total = viewModel.searchShows.count + viewModel.searchProducts.count + viewModel.searchUsers.count
            resultsLabel.text = total == 0 ? "" : "\(total) result\(total == 1 ? "" : "s")"
        } else {
            let count = viewModel.products.count
            resultsLabel.text = count == 0 ? "" : "\(count) product\(count == 1 ? "" : "s")"
        }
    }

    private func updateSearchModeUI() {
        let searching = viewModel.isShowingUnifiedSearchResults
        searchResultsTableView.isHidden = !searching
        productsCollectionView.isHidden = searching
        emptyStateLabel.text = searching ? "No matches for that search." : "No products match the current filter."
    }
}

// MARK: - UICollectionView DataSource / Delegate

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 100 {
            // "All" chip + every category
            return viewModel.categories.count + 1
        }
        return viewModel.products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 100 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreCategoryChipCell.identifier, for: indexPath) as! ExploreCategoryChipCell
            if indexPath.item == 0 {
                cell.configure(name: "All", imageURL: nil,
                               isSelected: viewModel.filter.categoryID == nil)
            } else {
                let cat = viewModel.categories[indexPath.item - 1]
                cell.configure(name: cat.name ?? "",
                               imageURL: cat.thumbnail ?? cat.image,
                               isSelected: viewModel.filter.categoryID == cat.id)
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreProductCell.identifier, for: indexPath) as! ExploreProductCell
        cell.configure(with: viewModel.products[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 100 {
            return CGSize(width: 80, height: categoryRailHeight - 16)
        }
        let columns = productGridColumns
        let hSpacing = productGridSpacing * (columns - 1)
        let hInset: CGFloat = 32 // 16 left + 16 right from sectionInset
        let width = floor((collectionView.bounds.width - hInset - hSpacing) / columns)
        return CGSize(width: width, height: width * productCellAspectRatio)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 100 {
            let newID: Int?
            if indexPath.item == 0 {
                newID = nil
            } else {
                newID = viewModel.categories[indexPath.item - 1].id
            }
            // P2.15 — if the user re-taps the already-selected category,
            // open the sub-category picker sheet (mirrors Android's
            // ExploreFragment behaviour). First tap just selects.
            if let id = newID, id == viewModel.filter.categoryID {
                presentSubcategoryPicker(for: id)
                return
            }
            viewModel.setSelectedCategory(newID)
            collectionView.reloadData()
            return
        }
        // Product tap → push ProductDetailsViewController (iOS Parity P0.1).
        guard let pid = viewModel.products[indexPath.item].id else { return }
        let vc = ProductDetailsViewController(productId: pid)
        navigationController?.pushViewController(vc, animated: true)
    }

    /// P2.15 — present the sub-category sheet for a given top-level
    /// category id.
    ///
    /// BUGFIX 2026-05-13 (MC cmp49377u00mb3mx117bl0r4x): Trey clarified the
    /// disappearing element is the bottom tab bar. The re-tap sub-category UI
    /// was being presented as a native `.pageSheet`, which sits above the tab
    /// bar and makes it look gone during category drill-in. Present the picker
    /// as an in-context overlay card instead so Explore stays visibly inside
    /// the tab shell while the user picks a sub-category.
    fileprivate func presentSubcategoryPicker(for categoryID: Int) {
        let sheet = ExploreSubcategoryPickerSheet(
            categoryID: categoryID,
            currentSubcategoryID: viewModel.filter.subCategoryID,
            viewModel: viewModel
        )
        sheet.onPicked = { [weak self] subcategoryID in
            self?.viewModel.setSelectedSubcategory(subcategoryID)
        }
        definesPresentationContext = true
        present(sheet, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView.tag == 200 else { return }
        // Infinite scroll: trigger next page when within 4 cells of the end.
        if indexPath.item >= viewModel.products.count - 4 {
            viewModel.loadNextPageIfPossible()
        }
    }
}

// MARK: - UISearchBarDelegate

extension ExploreViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.setSearch(searchBar.text ?? "")
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Debounce-lite: if cleared, refetch immediately.
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        if trimmed.count >= 2 {
            viewModel.setSearch(searchText)
        } else if searchText.isEmpty && viewModel.filter.search.isEmpty == false {
            viewModel.setSearch("")
        }
    }
}

// MARK: - ExploreViewModelDelegate

extension ExploreViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        ExploreSearchSection.allCases.filter { section in
            switch section {
            case .shows: return !viewModel.searchShows.isEmpty
            case .products: return !viewModel.searchProducts.isEmpty
            case .users: return !viewModel.searchUsers.isEmpty
            }
        }.count
    }

    private func visibleSearchSections() -> [ExploreSearchSection] {
        ExploreSearchSection.allCases.filter { section in
            switch section {
            case .shows: return !viewModel.searchShows.isEmpty
            case .products: return !viewModel.searchProducts.isEmpty
            case .users: return !viewModel.searchUsers.isEmpty
            }
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        visibleSearchSections()[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch visibleSearchSections()[section] {
        case .shows: return viewModel.searchShows.count
        case .products: return viewModel.searchProducts.count
        case .users: return viewModel.searchUsers.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult", for: indexPath)
        var cfg = cell.defaultContentConfiguration()
        switch visibleSearchSections()[indexPath.section] {
        case .shows:
            let show = viewModel.searchShows[indexPath.row]
            cfg.text = show.title ?? "Show"
            cfg.secondaryText = show.user?.username.map { "@\($0)" } ?? show.user?.name
            cfg.image = UIImage(systemName: "dot.radiowaves.left.and.right")
            cell.accessoryType = .disclosureIndicator
        case .products:
            let product = viewModel.searchProducts[indexPath.row]
            cfg.text = product.name ?? "Product"
            let seller = product.user?.name ?? ""
            let price = product.price ?? ""
            cfg.secondaryText = [price, seller].filter { !$0.isEmpty }.joined(separator: " • ")
            cfg.image = UIImage(systemName: "bag")
            cell.accessoryType = .disclosureIndicator
        case .users:
            let user = viewModel.searchUsers[indexPath.row]
            cfg.text = user.name ?? user.username ?? "User"
            cfg.secondaryText = user.username.map { "@\($0)" }
            cfg.image = UIImage(systemName: "person.crop.circle")
            cell.accessoryType = .disclosureIndicator
        }
        cell.contentConfiguration = cfg
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch visibleSearchSections()[indexPath.section] {
        case .shows:
            let show = viewModel.searchShows[indexPath.row]
            if show.isActuallyLive {
                LiveShowLauncher.launchViewer(from: self, show: show)
            } else if let firstProductId = (show.products?.compactMap { $0?.id }.first) {
                p3Push(ProductDetailsViewController(productId: firstProductId))
            } else if let pidStr = show.productIds?.compactMap({ $0 }).first, let pid = Int(pidStr) {
                p3Push(ProductDetailsViewController(productId: pid))
            }
        case .products:
            guard let pid = viewModel.searchProducts[indexPath.row].id else { return }
            p3Push(ProductDetailsViewController(productId: pid))
        case .users:
            guard let uid = viewModel.searchUsers[indexPath.row].id else { return }
            p3Push(SellerPublicProfileViewController(userId: uid))
        }
    }
}

extension ExploreViewController: ExploreViewModelDelegate {

    func exploreDidUpdateCategories() {
        categoryCollectionView.reloadData()
    }

    func exploreDidUpdateProducts() {
        updateSearchModeUI()
        productsCollectionView.reloadData()
        emptyStateLabel.isHidden = !viewModel.products.isEmpty
        updateResultsLabel()
    }

    func exploreDidUpdateSearchResults() {
        updateSearchModeUI()
        searchResultsTableView.reloadData()
        let hasResults = !(viewModel.searchShows.isEmpty && viewModel.searchProducts.isEmpty && viewModel.searchUsers.isEmpty)
        emptyStateLabel.isHidden = hasResults == true
        updateResultsLabel()
    }

    func exploreDidFail(error: String) {
        emptyStateLabel.text = viewModel.isShowingUnifiedSearchResults ? "Couldn't load search results.\n\(error)" : "Couldn't load products.\n\(error)"
        let hasResults = viewModel.isShowingUnifiedSearchResults
            ? !(viewModel.searchShows.isEmpty && viewModel.searchProducts.isEmpty && viewModel.searchUsers.isEmpty)
            : !viewModel.products.isEmpty
        emptyStateLabel.isHidden = hasResults
    }

    func exploreDidStartLoading() {
        spinner.startAnimating()
    }

    func exploreDidStopLoading() {
        spinner.stopAnimating()
    }
}

// MARK: - FilterViewControllerDelegate

extension ExploreViewController: FilterViewControllerDelegate {
    func filterDidApply(_ filter: ProductFilter) {
        viewModel.applyFilter(filter)
        categoryCollectionView.reloadData()
    }
    func filterDidReset() {
        viewModel.resetFilter()
        categoryCollectionView.reloadData()
    }
}
