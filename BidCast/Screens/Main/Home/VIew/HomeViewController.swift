//
//  HomeViewController.swift
//  BidCast — iOS Parity Phase 8 / P0.3 (2026-04-23)
//
//  Rewritten to replace the hardcoded 8-tile mock with real data backed by
//  the Android feed endpoints:
//    • horizontal category rail   → GET  api/get-category
//    • 2-column show grid         → POST api/get-live-show (paginated)
//
//  Tapping a tile:
//    - live show  → LiveShowLauncher / LiveShowResolver →
//                   WatchStreamViewController (full-screen)
//    - upcoming   → if the show carries a product, push
//                   ProductDetailsViewController; otherwise show an alert
//
//  UI still uses the existing CollectionCardCell + CategoryCollectionCell
//  to keep the visual language unchanged.
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//  Rewritten by Trey Difficult Task Agent on 2026-04-23.
//

import UIKit
import Kingfisher
import SVProgressHUD

enum HomeSection: Int, CaseIterable {
    case category
    case label
    case data
}

class HomeViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var headerViewolt: HeaderWithAppName!
    @IBOutlet weak var collectionViewOlt: UICollectionView!

    // MARK: Data
    private(set) var categories: [CategoryModel] = []
    private(set) var shows: [Show] = []

    private var selectedCategoryId: Int? // nil == "For You" / All
    private var currentPage = 1
    private var totalPages = 1
    private var isLoading = false
    private var hasLoadedOnce = false

    private let refreshControl = UIRefreshControl()

    // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3):
    // Android home replaces the BidCast wordmark header with a full-width
    // pill search field plus a bell on the right (fragment_home.xml).
    // We attach the field as a subview of the existing HeaderWithAppName
    // host so storyboard constraints stay valid.
    private let homeSearchField = UISearchTextField()
    private let homeBellButton = UIButton(type: .system)
    /// Selected filter tab index (0=Live Now, 1=Popular, 2=Coming Soon). Cosmetic
    /// only for now; actual filtering wiring is out of this visual port's scope.
    private var selectedFilterTabIndex: Int = 0

    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHeaderView()
        self.configureCollectionVIew()
        self.refreshFeed()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the JobA-era floating "Shows" button if present, since the
        // feed now shows live shows directly. We just mark any existing
        // button hidden; we don't touch the swizzle itself so the JobA
        // discovery path stays available for QA.
        jobAHideFloatingShowsButtonIfPresent()
    }

    private func configureHeaderView() {
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): hide the
        // wordmark + side icons that the legacy HeaderWithAppName ships and
        // overlay an Android-style search-pill + bell row instead.
        self.headerViewolt.headerViewSetup(
            appButtonHidden: true,
            rightButtonHidden: true,
            leftButtonHidden: true,
            headerName: ""
        )
        self.installAndroidStyleSearchHeader()
    }

    /// Builds the Android home-fragment header (search field + bell) and
    /// drops it on top of HeaderWithAppName's container.
    private func installAndroidStyleSearchHeader() {
        let host = self.headerViewolt!
        host.backgroundColor = .white

        homeSearchField.translatesAutoresizingMaskIntoConstraints = false
        homeSearchField.placeholder = "What are you looking for?"
        homeSearchField.borderStyle = .none
        homeSearchField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        homeSearchField.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
        homeSearchField.layer.cornerRadius = 22
        homeSearchField.layer.borderWidth = 1
        homeSearchField.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
        homeSearchField.clipsToBounds = true
        homeSearchField.leftViewMode = .always
        let mag = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        mag.tintColor = UIColor(white: 0.55, alpha: 1.0)
        mag.contentMode = .center
        mag.frame = CGRect(x: 0, y: 0, width: 36, height: 22)
        homeSearchField.leftView = mag
        homeSearchField.returnKeyType = .search
        homeSearchField.clearButtonMode = .whileEditing

        homeBellButton.translatesAutoresizingMaskIntoConstraints = false
        homeBellButton.setImage(
            UIImage(systemName: "bell")?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        homeBellButton.tintColor = .black

        host.addSubview(homeSearchField)
        host.addSubview(homeBellButton)

        NSLayoutConstraint.activate([
            homeSearchField.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 16),
            homeSearchField.trailingAnchor.constraint(equalTo: homeBellButton.leadingAnchor, constant: -12),
            homeSearchField.heightAnchor.constraint(equalToConstant: 44),
            homeSearchField.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -10),

            homeBellButton.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -16),
            homeBellButton.centerYAnchor.constraint(equalTo: homeSearchField.centerYAnchor),
            homeBellButton.widthAnchor.constraint(equalToConstant: 30),
            homeBellButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func configureCollectionVIew() {
        let cellId = [
            CategoryCollectionCell.identifier,
            LabelCollectionCell.identifier,
            CollectionCardCell.identifier
        ]
        self.collectionViewOlt.registerCells(for: cellId)
        self.collectionViewOlt.delegate = self
        self.collectionViewOlt.dataSource = self

        // Pull-to-refresh
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
        collectionViewOlt.refreshControl = refreshControl
    }

    @objc private func onPullToRefresh() {
        refreshFeed()
    }

    // MARK: - Data loading

    /// Refresh categories + first page of shows. Called on initial load
    /// and on pull-to-refresh. Categories are a soft-failure (empty rail
    /// if the network hiccups).
    private func refreshFeed() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.fetchCategories()
            await self.fetchShows(page: 1, reset: true)
            await MainActor.run {
                self.hasLoadedOnce = true
                self.refreshControl.endRefreshing()
            }
        }
    }

    @MainActor
    private func fetchCategories() async {
        do {
            let resp: ExploreGetCategoryResponse = try await APIManager.shared.request(
                type: APIEndPoint.getCategory, header: true
            )
            self.categories = resp.data ?? []
            self.collectionViewOlt.reloadData()
        } catch {
            // Soft-fail: leave categories empty. Keep the rail collapsed.
            debugLog("[Home] getCategory failed -> \(error.localizedDescription)")
        }
    }

    @MainActor
    private func fetchShows(page: Int, reset: Bool) async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        if reset, !refreshControl.isRefreshing {
            SVProgressHUD.show()
        }

        var fields: [String: String] = [
            "type": "all",
            "page": "\(page)",
            "search": ""
        ]
        if let cid = selectedCategoryId {
            fields["category"] = "\(cid)"
        } else {
            // 2026-05-04 v2 (MC task cmordzx1s00cuf3hgkwnkkplg): re-flipped
            // back to `all` because `for_you` is still surfacing
            // "Couldn't load feed" on builds 236+ even after the
            // pagination-envelope fix in build 234. Real root cause is
            // server-side: the `for_you` response shape diverges from
            // `all` in a way iOS Codable can't read. Need backend to
            // confirm the response is identical to `all`. Until then,
            // hard-code to `all` to keep the home feed loading.
            fields["category"] = "all"
        }

        do {
            let resp: GetMyShowResponse = try await APIManager.shared.postMultipartForm(
                type: .getLiveShow(param: [:]),
                fields: fields,
                header: true
            )
            let newItems = resp.data ?? []
            // QA-FIX (MC task cmolwmp0i00f64315lqq37lv3): when the personalized
            // "For You" feed is empty on first page, Android falls back to
            // the full all-shows list so the user never sees a blank screen.
            // For other categories the empty state is intentional and we
            // respect it. Mirror that here.
            if reset, page == 1, newItems.isEmpty, selectedCategoryId == nil {
                debugLog("[Home] empty For-You feed -> falling back to all shows")
                var fallbackFields = fields
                fallbackFields["category"] = "all"
                do {
                    let resp2: GetMyShowResponse = try await APIManager.shared.postMultipartForm(
                        type: .getLiveShow(param: [:]),
                        fields: fallbackFields,
                        header: true
                    )
                    self.shows = resp2.data ?? []
                    self.currentPage = resp2.currentPage ?? 1
                    self.totalPages = resp2.totalPage ?? self.currentPage
                    self.collectionViewOlt.reloadData()
                } catch {
                    debugLog("[Home] For-You fallback failed -> \(error.localizedDescription)")
                    self.shows = []
                    self.collectionViewOlt.reloadData()
                }
                await MainActor.run { SVProgressHUD.dismiss() }
                return
            }
            if reset {
                self.shows = newItems
            } else {
                self.shows.append(contentsOf: newItems)
            }
            self.currentPage = resp.currentPage ?? page
            self.totalPages = resp.totalPage ?? self.currentPage
            self.collectionViewOlt.reloadData()
        } catch {
            debugLog("[Home] getLiveShow failed -> \(error.localizedDescription)")
            if reset {
                let msg = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
                let alert = UIAlertController(title: "Couldn't load feed", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
        await MainActor.run { SVProgressHUD.dismiss() }
    }

    private func loadNextPageIfPossible() {
        guard !isLoading, currentPage < totalPages else { return }
        Task { await self.fetchShows(page: self.currentPage + 1, reset: false) }
    }

    // MARK: - Tap handling

    private func handleShowTap(_ show: Show) {
        // BUGFIX 2026-04-29 (MC task cmohlxj0h): use the stricter isActuallyLive
        // gate so users tapping a not-yet-started show do not get sent to the
        // live viewer (which would crash / show a black screen).
        if show.isActuallyLive {
            // Full-screen viewer. LiveShowLauncher handles rtc_token/roomId
            // fast path; otherwise its resolver kicks in.
            LiveShowLauncher.launchViewer(from: self, show: show)
            return
        }
        // Upcoming show — if it has a single product attached, push product
        // details. Otherwise show an info alert.
        if let firstProductId = (show.products?.compactMap { $0?.id }.first) {
            let vc = ProductDetailsViewController(productId: firstProductId)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        // First product id from product_ids if available
        if let pidStr = show.productIds?.compactMap({ $0 }).first,
           let pid = Int(pidStr) {
            let vc = ProductDetailsViewController(productId: pid)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        // No deep-link target — show a lightweight info sheet.
        let title = show.title ?? "Upcoming show"
        let alert = UIAlertController(
            title: title,
            message: "This show hasn't started yet.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - JobA button hide

    private func jobAHideFloatingShowsButtonIfPresent() {
        for sub in view.subviews {
            // The JobA install uses a UIButton with image "video.fill" at a
            // known anchor; identify by accessibilityLabel set there.
            if let btn = sub as? UIButton, btn.accessibilityLabel == "Shows" {
                btn.isHidden = true
            }
        }
    }

    // MARK: - Show helpers

    /// Best-effort thumbnail URL for a show tile.
    fileprivate func showThumbnailURL(_ s: Show) -> String? {
        if let t = s.thumbnail?.compactMap({ $0 }).first, !t.isEmpty { return t }
        if let i = s.imgThumbnail?.compactMap({ $0 }).first, !i.isEmpty { return i }
        return nil
    }

    fileprivate func hostDisplayName(_ s: Show) -> String {
        if let f = s.user?.firstName, !f.isEmpty {
            let l = s.user?.lastName ?? ""
            return "\(f) \(l)".trimmingCharacters(in: .whitespaces)
        }
        return s.user?.name ?? s.user?.username ?? "Seller"
    }
}

// MARK: - UICollectionView DataSource / Delegate

extension HomeViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HomeSection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = HomeSection(rawValue: section) else { return 0 }
        switch sectionType {
        case .category: return 1   // single host row containing the rail
        case .label:    return 1
        case .data:     return shows.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let rowType = HomeSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for HomeSection")
        }
        switch rowType {
        case .category:
            let cell = collectionView.dequeueCell(ofType: CategoryCollectionCell.self, for: indexPath)
            // Feed real category names into the existing xib-based rail.
            // Keep "For You" as the first chip (selectedIndex == 0).
            var titles = ["For You"]
            titles.append(contentsOf: categories.compactMap { $0.name })
            cell.title = titles
            cell.selectedIndex = self.currentCategoryIndex
            cell.didTapBtn = { [weak self, weak cell] tappedIndex in
                guard let self = self, let cell = cell else { return }
                cell.selectedIndex = tappedIndex
                cell.collectionViewOlt.reloadData()
                if tappedIndex == 0 {
                    self.selectedCategoryId = nil
                } else {
                    let idx = tappedIndex - 1
                    if idx < self.categories.count {
                        self.selectedCategoryId = self.categories[idx].id
                    } else {
                        self.selectedCategoryId = nil
                    }
                }
                Task { await self.fetchShows(page: 1, reset: true) }
            }
            return cell

        case .label:
            let cell = collectionView.dequeueCell(ofType: LabelCollectionCell.self, for: indexPath)
            // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): cell now
            // renders 3 discrete filter tabs. Persist selection visually so
            // taps stick across reloads.
            cell.selectedIndex = self.selectedFilterTabIndex
            cell.didTapTab = { [weak self, weak cell] tabIdx in
                guard let self = self, let cell = cell else { return }
                self.selectedFilterTabIndex = tabIdx
                cell.selectedIndex = tabIdx
            }
            return cell

        case .data:
            let cell = collectionView.dequeueCell(ofType: CollectionCardCell.self, for: indexPath)
            let s = shows[indexPath.item]
            cell.titleView?.text = s.title ?? "Untitled show"
            // BUGFIX 2026-04-29 (MC task cmohlxj0h): only show the red LIVE
            // badge when the show is actually streaming.
            let live = s.isActuallyLive
            cell.categoyView?.text = live
                ? "LIVE"
                : (s.category?.name ?? "Upcoming")
            cell.categoyView?.textColor = live ? .systemRed : .systemBlue
            cell.profileNameOlt?.text = hostDisplayName(s)
            // Thumbnail image
            if let raw = showThumbnailURL(s), let url = URL(string: raw) {
                cell.imgViewOlt?.kf.setImage(
                    with: url,
                    placeholder: UIImage(systemName: "photo")
                )
            } else {
                cell.imgViewOlt?.image = UIImage(systemName: "photo")
            }
            // Seller avatar
            if let raw = s.user?.profileImage, !raw.isEmpty, let url = URL(string: raw) {
                cell.profileImgOlt?.kf.setImage(
                    with: url,
                    placeholder: UIImage(systemName: "person.crop.circle")
                )
            } else {
                cell.profileImgOlt?.image = UIImage(systemName: "person.crop.circle")
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 8 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 4 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let rowType = HomeSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for HomeSection")
        }
        switch rowType {
        case .category:
            return CGSize(width: self.collectionViewOlt.frame.width - 10, height: 90)
        case .label:
            return CGSize(width: self.collectionViewOlt.frame.width - 10, height: 60)
        case .data:
            let w = self.collectionViewOlt.frame.width / 2 - 6
            return CGSize(width: w, height: 350)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let rowType = HomeSection.allCases[safe: indexPath.section] else { return }
        guard rowType == .data, indexPath.item < shows.count else { return }
        handleShowTap(shows[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        // Infinite scroll: trigger next page when within 4 tiles of the end
        // and we're in the data section.
        guard let rowType = HomeSection.allCases[safe: indexPath.section],
              rowType == .data else { return }
        if indexPath.item >= shows.count - 4 {
            loadNextPageIfPossible()
        }
    }

    // The category chip rail uses the selected index ("For You" == 0) + all
    // category objects in order. Keep the UI index in sync with the model.
    private var currentCategoryIndex: Int {
        guard let sid = selectedCategoryId else { return 0 }
        if let idx = categories.firstIndex(where: { $0.id == sid }) {
            return idx + 1
        }
        return 0
    }
}
