//
//  InterestsViewController.swift
//  BidCast — iOS Parity QA fix (MC task cmolwmp0i00f64315lqq37lv3)
//
//  Replacement for the P0.6 stub. Mirrors Android's two-step interest
//  flow:
//
//    Android `CategoryFragment` → user picks parent categories
//    Android `SubCategoryFragment` → user picks sub-categories under the
//        chosen parents, with the Apr-2026 QA fixes applied:
//          (a) parents that have NO sub-categories are filtered out of
//              the list (commit `cmo7iad45...` on Android).
//          (b) if NONE of the selected parents have sub-categories,
//              the screen is skipped entirely and the empty selection
//              is auto-submitted to `api/user/favorite` (commit
//              `cmo7iad9e...` on Android).
//          (c) sub-category title font is reduced to wrap nicely
//              (Android sets it to ~15sp).
//
//  This screen is reachable from:
//    - Account tab grid (existing).
//    - Post-signup auto-route in SignUpViewController.swift.
//    - Anywhere else that pushes `InterestsViewController()`.
//
//  Save endpoint: `api/user/favorite` (existing iOS endpoint; Android
//  posts `category_ids` + `sub_category_ids` as JSON body via
//  `GetSubCategoriesRequest`). The iOS endpoint is registered as multipart
//  in ProjectEndPoint.swift, so we send the same fields as multipart for
//  parity with the rest of the iOS app.
//
//  Constraints:
//    - No new endpoints required (`getCategory` + `getSubCategories` +
//      `userFavorite` already exist).
//    - Programmatic UIKit; no XIB/storyboard.

import UIKit

final class InterestsViewController: UIViewController {

    // MARK: - State

    /// Loaded parent categories (from `getCategory`).
    private var parents: [CategoryModel] = []

    /// Set of parent category ids the user has currently selected.
    private var selectedParentIds: Set<Int> = []

    /// Sub-category groups loaded from `getSubCategories` for the
    /// currently selected parents. After fix-(a), groups with empty
    /// `subcategories` arrays are filtered out before we render.
    private var subGroups: [SubCategoryGroup] = []

    /// Set of sub-category ids the user has selected.
    private var selectedSubIds: Set<Int> = []

    /// Two-phase flow:
    ///   .pickParents → tapping continue loads subcategories.
    ///   .pickSubs    → tapping save submits to `userFavorite`.
    private enum Phase { case pickParents, pickSubs }
    private var phase: Phase = .pickParents

    // MARK: - UI

    private let scroll = UIScrollView()
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 12
        s.alignment = .fill
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): Android
    // `fragment_category.xml` shows a top "Header" with the screen title,
    // a centered body subheader, then a 3-column grid of category cards,
    // then a brand-blue `appBtn` Continue button at the bottom. iOS now
    // mirrors that visual hierarchy.
    private let header: UILabel = {
        let l = UILabel()
        // Android Header uses a 18sp bold semantic title. We mirror that.
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.textColor = AppColor.darkGray
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()

    private let subHeader: UILabel = {
        let l = UILabel()
        // Matches Android `BodyLarge` underneath the Header (16sp, ~70%
        // gray).
        l.font = .systemFont(ofSize: 14)
        l.textColor = AppColor.mediumDarkGray
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()

    private lazy var primaryButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Continue"
        // Android `appBtn` style is solid `@color/primary` (#0058BD) with
        // white text and ~14dp corner radius. AppColor.primary is pinned
        // to that hex in commit f640595.
        cfg.baseBackgroundColor = AppColor.primary
        cfg.baseForegroundColor = .white
        cfg.cornerStyle = .medium
        var titleAttr = AttributedString("Continue")
        titleAttr.font = .systemFont(ofSize: 16, weight: .semibold)
        cfg.attributedTitle = titleAttr
        cfg.contentInsets = .init(top: 14, leading: 16, bottom: 14, trailing: 16)
        b.configuration = cfg
        b.addTarget(self, action: #selector(primaryTap), for: .touchUpInside)
        return b
    }()

    private lazy var loader: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Android `headerTitle` is "Select Your Favourite Category".
        title = "Select Your Favourite Category"
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        buildLayout()
        renderForPhase()
        Task { await loadCategories() }
    }

    private func buildLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)
        view.addSubview(loader)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor),
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Network

    @MainActor
    private func loadCategories() async {
        loader.startAnimating()
        defer { loader.stopAnimating() }
        do {
            let resp: ExploreGetCategoryResponse = try await APIManager.shared.request(
                type: APIEndPoint.getCategory, header: true)
            self.parents = resp.data ?? []
            renderForPhase()
        } catch {
            self.parents = []
            renderForPhase()
            p3Alert(message: "Couldn't load categories. " +
                    ((error as? DataError)?.getErrorMessage() ?? error.localizedDescription))
        }
    }

    @MainActor
    private func loadSubCategories() async {
        let parentIds = Array(selectedParentIds)
        guard !parentIds.isEmpty else { return }
        loader.startAnimating()
        defer { loader.stopAnimating() }
        do {
            let req = GetSubCategoriesRequest(categoryIds: parentIds, subcategoryIds: nil)
            // Backend reads `category_ids` as a multipart text field, same as
            // AddEditProductViewController.loadSubCategories.
            let fields: [String: String] = [
                "category_ids": "[\(parentIds.map { String($0) }.joined(separator: ","))]"
            ]
            _ = req
            let resp: GetSubCategoriesResponse = try await APIManager.shared.postMultipartForm(
                type: .getSubCategories(param: req),
                fields: fields, header: true)
            let allGroups = resp.data ?? []
            // QA-fix (a): drop parents with no subcategories.
            let nonEmpty = allGroups.filter { !($0.subcategories ?? []).isEmpty }
            self.subGroups = nonEmpty

            // QA-fix (b): if NONE of the selected parents have any subs,
            // skip the screen and auto-submit with empty sub list.
            if nonEmpty.isEmpty {
                await submitInterests()
                return
            }
            self.phase = .pickSubs
            renderForPhase()
        } catch {
            p3Alert(message: "Couldn't load sub-categories. " +
                    ((error as? DataError)?.getErrorMessage() ?? error.localizedDescription))
        }
    }

    @MainActor
    private func submitInterests() async {
        loader.startAnimating()
        primaryButton.isEnabled = false
        defer {
            loader.stopAnimating()
            primaryButton.isEnabled = true
        }
        let parentIds = Array(selectedParentIds)
        let subIds = Array(selectedSubIds)
        do {
            // Mirror Android's `userFavorite(categoryIds, subcategoriesIds)`.
            // Backend accepts these as multipart-form parts (same content
            // shape we use for `getSubCategories` and `storeProduct`).
            let fields: [String: String] = [
                "category_ids": "[\(parentIds.map { String($0) }.joined(separator: ","))]",
                "sub_category_ids": "[\(subIds.map { String($0) }.joined(separator: ","))]"
            ]
            let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                type: .userFavorite(param: [:]),
                fields: fields, header: true)
            p3Alert(title: "Saved",
                    message: "Your interests have been saved.") { [weak self] in
                self?.handleSaveSuccess()
            }
        } catch {
            p3Alert(message: "Couldn't save interests. " +
                    ((error as? DataError)?.getErrorMessage() ?? error.localizedDescription))
        }
    }

    private func handleSaveSuccess() {
        // If we're embedded in the post-signup nav stack, send the user
        // to the main app. Otherwise just pop.
        if let nav = self.navigationController, nav.viewControllers.count > 1 {
            // Likely we were pushed onto the signup nav. Drop back to root
            // and let SceneDelegate.navigateToLandingScreen take over.
            sceneDel.navigateToLandingScreen()
        } else {
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true)
        }
    }

    // MARK: - Rendering

    private func renderForPhase() {
        // Reset stack.
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(subHeader)
        stack.setCustomSpacing(20, after: subHeader)

        // VISUAL PARITY 2026-05-01: copy now mirrors Android
        // `@string/select_your_favourite_category` /
        // `@string/choose_the_categories_you_re_interested_in_to_watch_related_shows`
        // and the sub-step equivalents.
        switch phase {
        case .pickParents:
            header.text = "Select Your Favourite Category"
            subHeader.text = "Choose the categories you're interested in to watch related shows."
            self.title = "Select Your Favourite Category"
            var titleAttr = AttributedString("Continue")
            titleAttr.font = .systemFont(ofSize: 16, weight: .semibold)
            primaryButton.configuration?.attributedTitle = titleAttr
            renderParentChips()

        case .pickSubs:
            header.text = "Select Your Favourite Sub-Category"
            subHeader.text = "Pick sub-categories under your selected categories so we can fine-tune your recommendations."
            self.title = "Select Your Favourite Sub-Category"
            var titleAttr = AttributedString("Save")
            titleAttr.font = .systemFont(ofSize: 16, weight: .semibold)
            primaryButton.configuration?.attributedTitle = titleAttr
            renderSubcategoryGroups()
        }

        // Primary button row
        let buttonRow = UIStackView(arrangedSubviews: [primaryButton])
        buttonRow.axis = .horizontal
        buttonRow.distribution = .fillEqually
        primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        stack.addArrangedSubview(buttonRow)

        if phase == .pickSubs {
            let backBtn = UIButton(type: .system)
            var cfg = UIButton.Configuration.plain()
            cfg.title = "Back to categories"
            backBtn.configuration = cfg
            backBtn.addTarget(self, action: #selector(backToParents), for: .touchUpInside)
            stack.addArrangedSubview(backBtn)
        }
    }

    private func renderParentChips() {
        guard !parents.isEmpty else {
            let lbl = UILabel()
            lbl.text = "No categories available."
            lbl.textColor = .secondaryLabel
            lbl.textAlignment = .center
            stack.addArrangedSubview(lbl)
            return
        }
        // VISUAL PARITY 2026-05-01: Android uses a 3-column grid
        // (`spanCount="3"` in fragment_category.xml). Match that.
        let columns = 3
        var row: UIStackView?
        var rowCount = 0
        for cat in parents {
            if rowCount == 0 {
                row = UIStackView()
                row?.axis = .horizontal
                row?.spacing = 10
                row?.distribution = .fillEqually
                row?.alignment = .fill
                stack.addArrangedSubview(row!)
            }
            let card = makeCategoryCard(
                id: cat.id ?? -1,
                title: cat.name ?? "Category",
                isSelected: selectedParentIds.contains(cat.id ?? -1),
                onTap: { [weak self] in self?.toggleParent(cat) }
            )
            row?.addArrangedSubview(card)
            rowCount = (rowCount + 1) % columns
        }
        // Pad short final row so .fillEqually keeps consistent widths.
        if let r = row {
            while r.arrangedSubviews.count < columns {
                r.addArrangedSubview(UIView())
            }
        }
    }

    private func renderSubcategoryGroups() {
        guard !subGroups.isEmpty else {
            let lbl = UILabel()
            lbl.text = "No sub-categories available."
            lbl.textColor = .secondaryLabel
            lbl.textAlignment = .center
            stack.addArrangedSubview(lbl)
            return
        }
        for group in subGroups {
            let title = UILabel()
            title.text = group.name ?? "Category"
            // QA-fix (c): smaller, wrap-friendly font (Android: ~15sp).
            title.font = .systemFont(ofSize: 15, weight: .semibold)
            title.numberOfLines = 0
            stack.addArrangedSubview(title)

            let subs = group.subcategories ?? []
            // 2-column chip grid for each parent.
            var row: UIStackView?
            var rowCount = 0
            for sub in subs {
                if rowCount == 0 {
                    row = UIStackView()
                    row?.axis = .horizontal
                    row?.spacing = 10
                    row?.distribution = .fillEqually
                    stack.addArrangedSubview(row!)
                }
                let chip = makeChip(
                    id: sub.id ?? -1,
                    title: sub.name ?? "Sub-category",
                    isSelected: selectedSubIds.contains(sub.id ?? -1),
                    fontSize: 13,
                    onTap: { [weak self] in self?.toggleSub(sub) }
                )
                row?.addArrangedSubview(chip)
                rowCount = (rowCount + 1) % 2
            }
            if let r = row, r.arrangedSubviews.count == 1 {
                r.addArrangedSubview(UIView())
            }
            stack.setCustomSpacing(12, after: row ?? title)
        }
    }

    /// VISUAL PARITY 2026-05-01: Android `category_item.xml` is a
    /// MaterialCardView wrapping a vertical LinearLayout (image-on-top,
    /// title-below) with `cardCornerRadius=8dp`. The selected state lifts
    /// the card to brand-blue with white text. iOS reproduces that with a
    /// UIView container so we keep the chip's tap target.
    private func makeCategoryCard(id: Int,
                                  title: String,
                                  isSelected: Bool,
                                  onTap: @escaping () -> Void) -> UIView {
        let card = UIControl()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 8
        card.layer.masksToBounds = true
        card.backgroundColor = isSelected
            ? AppColor.primary
            : AppColor.lightBlue
        card.layer.borderWidth = isSelected ? 0 : 1
        card.layer.borderColor = AppColor.bgColor?.cgColor

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = isSelected ? .white : AppColor.darkGray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        card.addSubview(label)
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 96),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])

        card.addAction(UIAction { _ in onTap() }, for: .touchUpInside)
        return card
    }

    /// Sub-category chip — kept compact and pill-shaped per Android Chip
    /// styling (`chip_bg_state` toggles between primary blue and
    /// inverseOnSurface). Returns a UIControl so it remains tappable
    /// inside a stack view.
    private func makeChip(id: Int,
                          title: String,
                          isSelected: Bool,
                          fontSize: CGFloat,
                          onTap: @escaping () -> Void) -> UIView {
        let btn = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        var titleAttr = AttributedString(title)
        titleAttr.font = .systemFont(ofSize: fontSize, weight: .medium)
        cfg.attributedTitle = titleAttr
        // VISUAL PARITY 2026-05-01: selected chip uses brand blue +
        // white text (`@color/primary` / `@color/onPrimary`). Unselected
        // uses the surface gray with dark text (`@color/inverseOnSurface`
        // ≈ #F1F0F7 + `@color/scrim` text).
        cfg.baseBackgroundColor = isSelected
            ? AppColor.primary
            : AppColor.lightGray
        cfg.baseForegroundColor = isSelected
            ? .white
            : AppColor.darkGray
        cfg.cornerStyle = .capsule
        cfg.contentInsets = .init(top: 10, leading: 14, bottom: 10, trailing: 14)
        btn.configuration = cfg
        btn.titleLabel?.numberOfLines = 0
        btn.titleLabel?.textAlignment = .center
        btn.addAction(UIAction { _ in onTap() }, for: .touchUpInside)
        return btn
    }

    // MARK: - Actions

    private func toggleParent(_ cat: CategoryModel) {
        guard let id = cat.id else { return }
        if selectedParentIds.contains(id) {
            selectedParentIds.remove(id)
        } else {
            selectedParentIds.insert(id)
        }
        renderForPhase()
    }

    private func toggleSub(_ sub: SubCategory) {
        guard let id = sub.id else { return }
        if selectedSubIds.contains(id) {
            selectedSubIds.remove(id)
        } else {
            selectedSubIds.insert(id)
        }
        renderForPhase()
    }

    @objc private func primaryTap() {
        switch phase {
        case .pickParents:
            guard !selectedParentIds.isEmpty else {
                p3Alert(title: "Pick at least one",
                        message: "Choose one or more categories to continue.")
                return
            }
            Task { await loadSubCategories() }

        case .pickSubs:
            // It's OK to save with no subs selected — Android allows this
            // (the multi-select grid does not enforce a min count).
            Task { await submitInterests() }
        }
    }

    @objc private func backToParents() {
        // Going back wipes the sub selections so the user re-confirms
        // them when they re-land on the sub screen.
        selectedSubIds.removeAll()
        subGroups.removeAll()
        phase = .pickParents
        renderForPhase()
    }
}
