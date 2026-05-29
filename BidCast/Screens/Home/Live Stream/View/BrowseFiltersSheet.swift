//
//  BrowseFiltersSheet.swift
//  BidCast
//
//  Created for Basecamp #9933301500 (2026-05-27): port the 5 PWA browse
//  filters (Show Format, Tags, Premier Shops, Shipped From, Reduced
//  Shipping) to iOS. Backend already accepts all of these fields on
//  POST /api/get-live-show — see ApiController::getLiveShow for the
//  validator (show_format, tag, ship_country, ship_state, premier_shop,
//  shipping). No backend changes needed; this sheet just collects the
//  values and hands them back to the caller, who passes them into the
//  next GetLiveShowsRequest.
//

import SwiftUI

// MARK: - Public value type the caller round-trips

/// Snapshot of the 5 browse filters. All optional — when a field is nil/empty
/// the request omits it (sent as JSON null, which Laravel `nullable` treats
/// as absent). The shape mirrors the request fields 1:1 on purpose so the
/// caller can just splat these into `GetLiveShowsRequest`.
struct BrowseFilters: Equatable {
    var showFormat: String? = nil    // surprise_sets | live_auction | buy_it_now | nil(All)
    var tag: String = ""             // single tag, no leading "#"
    var premierShop: Bool = false
    var shipCountry: String? = nil   // 2-letter ISO; nil = Any country
    var shipState: String = ""       // optional state/region free text
    var shipping: String? = nil      // free | reduced | nil(All)
    // Basecamp #9938023997 (2026-05-28): multi-select category + subcategory filters.
    var categoryIds: [Int] = []
    var subCategoryIds: [Int] = []

    /// Returns true when at least one filter is set; used to render the
    /// little badge on the Filter button so the user can tell at a glance
    /// that there's something applied.
    var isActive: Bool {
        showFormat != nil
        || !tag.trimmingCharacters(in: .whitespaces).isEmpty
        || premierShop
        || shipCountry != nil
        || !shipState.trimmingCharacters(in: .whitespaces).isEmpty
        || shipping != nil
        || !categoryIds.isEmpty
        || !subCategoryIds.isEmpty
    }

    static let empty = BrowseFilters()
}

// MARK: - Category / Subcategory filter value types
//
// Thin wrappers so BrowseFiltersSheet doesn't import or depend on
// SelectCategoryViewModel or any ObservableObject — the sheet is
// deliberately self-contained (same pattern as tag autocomplete above).
struct BrowseFilterCategory: Identifiable, Hashable {
    let id: Int
    let name: String
}

struct BrowseFilterSubcategory: Identifiable, Hashable {
    let id: Int
    let name: String
    let categoryId: Int
}

// MARK: - FlowLayout helper (chip wrapping)
//
// Basecamp #9938023997 / #9940038345 (2026-05-28, round 2): the previous
// implementation wrapped a `GeometryReader` in `.fixedSize(vertical: true)`
// and laid chips out with absolute `.offset(...)` inside a ZStack. A
// `GeometryReader` has NO intrinsic content height — it greedily takes the
// width its parent proposes and reports an ideal height of ~0 (and
// `.fixedSize(vertical:)` can't fix a dimension the view has no intrinsic
// value for). So the whole chip container reported height ≈ 0 to the
// surrounding `VStack(spacing: 24)`, every section below Categories was
// drawn starting at the chips' y-origin, and the offset chips painted on
// top of Show Format / Tag / Premier Shops / Shipped from / Shipping.
//
// The app's deployment target is iOS 17.6, so we can use the native
// SwiftUI `Layout` protocol. `sizeThatFits` returns the TRUE total wrapped
// height, which is what propagates to the parent stack, so sibling
// sections now flow below the chips with no overlap. Same fix covers both
// the Categories and Subcategories chip areas (both use `FlowLayout`).
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // Width to wrap within: the proposed width, falling back to a sane
        // value if the proposal is nil/unbounded (shouldn't happen inside a
        // VStack, but guard anyway).
        let maxWidth = proposal.width ?? .infinity
        let arrangement = arrange(subviews: subviews, maxWidth: maxWidth)
        return CGSize(width: arrangement.width, height: arrangement.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let arrangement = arrange(subviews: subviews, maxWidth: bounds.width)
        for (index, point) in arrangement.points.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                anchor: .topLeading,
                proposal: ProposedViewSize(arrangement.sizes[index])
            )
        }
    }

    // Single pass that computes per-chip sizes, wrapped positions, and the
    // total bounding size. Used by both sizeThatFits and placeSubviews so
    // the measured height and the placed layout always agree.
    private func arrange(subviews: Subviews, maxWidth: CGFloat) -> (points: [CGPoint], sizes: [CGSize], width: CGFloat, height: CGFloat) {
        var points: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            // Wrap to the next row when this chip would overflow the row and
            // it isn't the first chip on the row.
            if x > 0 && x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            points.append(CGPoint(x: x, y: y))
            sizes.append(size)
            x += size.width + spacing
            maxRowWidth = max(maxRowWidth, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }

        let totalHeight = y + rowHeight
        let totalWidth = maxWidth.isFinite ? maxWidth : maxRowWidth
        return (points, sizes, totalWidth, totalHeight)
    }
}

// MARK: - Hardcoded country list
//
// Matches the Android port (US, CA, UK, AU, FR, DE, IT, JP, MX, IN) so the
// two platforms behave identically. Keep this list in lockstep with
// `ExploreBrowseFiltersSheet.kt` on the Android side.
struct BrowseFilterCountry: Identifiable, Hashable {
    let code: String          // ISO-3166-1 alpha-2, what the API expects
    let label: String         // user-facing
    var id: String { code }
}

enum BrowseFilterCountries {
    static let all: [BrowseFilterCountry] = [
        .init(code: "US", label: "United States"),
        .init(code: "CA", label: "Canada"),
        .init(code: "GB", label: "United Kingdom"),   // ISO code for UK
        .init(code: "AU", label: "Australia"),
        .init(code: "FR", label: "France"),
        .init(code: "DE", label: "Germany"),
        .init(code: "IT", label: "Italy"),
        .init(code: "JP", label: "Japan"),
        .init(code: "MX", label: "Mexico"),
        .init(code: "IN", label: "India"),
    ]
}

// MARK: - The sheet view

struct BrowseFiltersSheet: View {
    @Binding var isPresented: Bool

    /// Live working copy the user mutates inside the sheet. Caller passes
    /// the current state in; Apply hands it back via `onApply` and we
    /// dismiss. Cancel dismisses without calling back.
    @State var draft: BrowseFilters
    let onApply: (BrowseFilters) -> Void

    // MARK: Tag autocomplete plumbing
    //
    // GET /api/tags/suggest?q=<prefix> is a tiny endpoint that returns a
    // list of tag names. We call it directly with URLSession (no need to
    // add a typed APIEndPoint case for one ad-hoc autocomplete). Debounced
    // by 250 ms via a tiny timer so we don't hammer the server on every
    // keystroke.
    @State private var tagSuggestions: [String] = []
    @State private var tagDebounceTimer: Timer? = nil
    // Basecamp #9933301500 (2026-05-27 round 3): all available tags for the
    // dropdown picker — loaded once when the filter sheet opens.
    @State private var allTags: [String] = []
    @State private var isLoadingTags: Bool = false
    // Basecamp #9933301500 (2026-05-29 round 7): category-scoped tag names for
    // the currently selected (single) category. Reloaded whenever the category
    // selection changes. tagCache avoids re-fetching the same category's tags.
    @State private var categoryTags: [String] = []
    @State private var tagCache: [Int: [String]] = [:]

    // Basecamp #9938023997 (2026-05-28): category + subcategory filter state.
    @State private var allCategories: [BrowseFilterCategory] = []
    @State private var isLoadingCategories: Bool = false
    // subcatCache: category_id → flat list of its subcategories (populated lazily
    // as the user selects categories; avoids redundant network calls).
    @State private var subcatCache: [Int: [BrowseFilterSubcategory]] = [:]
    @State private var isFetchingSubcats: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header — mirrors SortByBottomSheet's PrimarySheetHeader so the
            // sheet feels native to the rest of the app's bottom sheets.
            PrimarySheetHeader(title: "Filters", onClose: {
                isPresented = false
            })

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: 0a) Categories ---------------------------
                    filterSection(title: "Categories") {
                        if isLoadingCategories {
                            ProgressView().frame(maxWidth: .infinity, alignment: .center)
                        } else if allCategories.isEmpty {
                            Text("No categories available")
                                .font(.custom(poppinsRegular, size: 13))
                                .foregroundColor(.gray)
                        } else {
                            FlowLayout(spacing: 8) {
                                ForEach(allCategories) { cat in
                                    let selected = draft.categoryIds.contains(cat.id)
                                    Button(action: {
                                        toggleCategory(cat.id)
                                    }) {
                                        Text(cat.name)
                                            .font(.custom(poppinsRegular, size: 13))
                                            .foregroundColor(selected ? .white : .black)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(selected ? Color.defaultTheme : Color.white)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(selected ? Color.defaultTheme : Color.gray.opacity(0.35), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }

                    // MARK: 0b) Subcategories (only when ≥1 cat selected)
                    if !draft.categoryIds.isEmpty {
                        filterSection(title: "Subcategories") {
                            if isFetchingSubcats {
                                ProgressView().frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                let subs = availableSubcategories
                                if subs.isEmpty {
                                    Text("No subcategories for selected categories")
                                        .font(.custom(poppinsRegular, size: 13))
                                        .foregroundColor(.gray)
                                } else {
                                    FlowLayout(spacing: 8) {
                                        ForEach(subs) { sub in
                                            let selected = draft.subCategoryIds.contains(sub.id)
                                            Button(action: {
                                                toggleSubcategory(sub.id)
                                            }) {
                                                Text(sub.name)
                                                    .font(.custom(poppinsRegular, size: 13))
                                                    .foregroundColor(selected ? .white : .black)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 7)
                                                    .background(selected ? Color.defaultTheme : Color.white)
                                                    .cornerRadius(20)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(selected ? Color.defaultTheme : Color.gray.opacity(0.35), lineWidth: 1)
                                                    )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // MARK: 1) Show Format ----------------------------
                    filterSection(title: "Show Format") {
                        VStack(alignment: .leading, spacing: 10) {
                            radioRow(title: "All Formats",  isOn: draft.showFormat == nil) {
                                draft.showFormat = nil
                            }
                            radioRow(title: "Surprise Sets", isOn: draft.showFormat == "surprise_sets") {
                                draft.showFormat = "surprise_sets"
                            }
                            radioRow(title: "Live Auction",  isOn: draft.showFormat == "live_auction") {
                                draft.showFormat = "live_auction"
                            }
                            radioRow(title: "Buy It Now",    isOn: draft.showFormat == "buy_it_now") {
                                draft.showFormat = "buy_it_now"
                            }
                        }
                    }

                    // MARK: 2) Tags -----------------------------------
                    // Basecamp #9933301500 (2026-05-29 round 7): the tag dropdown
                    // must be SCOPED TO THE CURRENTLY SELECTED CATEGORY, matching
                    // the PWA. Tags live in the show_tags pivot per-category, so a
                    // global tag list (old /api/tags/suggest behavior) returned
                    // tags that don't apply to the chosen category and matched
                    // nothing. Now: enabled only when exactly ONE category is
                    // selected; options come from GET /api/categories/{id}/tags
                    // (BrowseFilterController::categoryTags). draft.tag holds the
                    // tag NAME (backend matches name OR slug).
                    filterSection(title: "Tag") {
                        VStack(alignment: .leading, spacing: 8) {
                            if draft.categoryIds.count != 1 {
                                // No single category context → tag is ambiguous.
                                Text(draft.categoryIds.count > 1
                                     ? "Tags are per-category — select just one category."
                                     : "Pick one category to see its seller tags.")
                                    .font(.custom(poppinsRegular, size: 13))
                                    .foregroundColor(.gray)
                            } else if categoryTags.isEmpty && isLoadingTags {
                                ProgressView().frame(maxWidth: .infinity, alignment: .center)
                            } else if categoryTags.isEmpty {
                                Text("No tags in this category yet")
                                    .font(.custom(poppinsRegular, size: 13))
                                    .foregroundColor(.gray)
                            } else {
                                // Picker-style menu of tags scoped to the category.
                                Menu {
                                    Button("Any tag") { draft.tag = "" }
                                    Divider()
                                    ForEach(categoryTags, id: \.self) { tag in
                                        Button(tag) { draft.tag = tag }
                                    }
                                } label: {
                                    HStack {
                                        Text(draft.tag.isEmpty ? "Any tag" : draft.tag)
                                            .font(.custom(poppinsRegular, size: 14))
                                            .foregroundColor(draft.tag.isEmpty ? .gray : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(10)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                }
                            }

                            if !tagSuggestions.isEmpty {
                                // legacy suggestion list kept for fallback
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(tagSuggestions, id: \.self) { suggestion in
                                        Button(action: {
                                            draft.tag = suggestion
                                            tagSuggestions = []
                                        }) {
                                            HStack {
                                                Text(suggestion)
                                                    .font(.custom(poppinsRegular, size: 13))
                                                    .foregroundColor(.black)
                                                Spacer()
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 10)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        Divider()
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            }
                        }
                    }

                    // MARK: 3) Premier Shops only ---------------------
                    filterSection(title: "Premier Shops only") {
                        Toggle(isOn: $draft.premierShop) {
                            Text("Only show Premier Shops")
                                .font(.custom(poppinsRegular, size: 13))
                                .foregroundColor(.black)
                        }
                        .tint(Color.defaultTheme)
                    }

                    // MARK: 4) Shipped from ---------------------------
                    filterSection(title: "Shipped from") {
                        VStack(alignment: .leading, spacing: 10) {
                            // Country picker — Menu wraps the chosen value
                            // in a tappable label, exactly like a native
                            // dropdown. nil = "Any country" sentinel.
                            Menu {
                                Button("Any country") { draft.shipCountry = nil }
                                ForEach(BrowseFilterCountries.all) { country in
                                    Button(country.label) { draft.shipCountry = country.code }
                                }
                            } label: {
                                HStack {
                                    Text(countryLabel(for: draft.shipCountry))
                                        .font(.custom(poppinsRegular, size: 14))
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            }

                            // Free-text state/region. We don't ship a state
                            // picker on mobile — the PWA also accepts any
                            // string up to 100 chars (server validator).
                            TextField("State / region (optional)", text: $draft.shipState)
                                .font(.custom(poppinsRegular, size: 14))
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .disabled(draft.shipCountry == nil)
                                .opacity(draft.shipCountry == nil ? 0.5 : 1)
                        }
                    }

                    // MARK: 5) Reduced shipping -----------------------
                    filterSection(title: "Shipping") {
                        VStack(alignment: .leading, spacing: 10) {
                            radioRow(title: "All",     isOn: draft.shipping == nil) {
                                draft.shipping = nil
                            }
                            radioRow(title: "Free",    isOn: draft.shipping == "free") {
                                draft.shipping = "free"
                            }
                            radioRow(title: "Reduced", isOn: draft.shipping == "reduced") {
                                draft.shipping = "reduced"
                            }
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            // MARK: Footer buttons
            HStack(spacing: 12) {
                Button(action: {
                    // Reset the draft right here so the user sees the wipe
                    // and can still Apply (= "clear all"). They'd otherwise
                    // have to clear each field by hand.
                    draft = .empty
                    tagSuggestions = []
                }) {
                    Text("Clear")
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                        .cornerRadius(24)
                }
                // Note: Clear button action already resets draft = .empty which
                // includes the new categoryIds / subCategoryIds (both default []).

                Button(action: {
                    onApply(normalized(draft))
                    isPresented = false
                }) {
                    Text("Apply")
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.defaultTheme)
                        .cornerRadius(24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.backGround)
        // Basecamp #9938023997 / #9940038345 (2026-05-28): the category +
        // tag fetches used to be triggered from an `EmptyView().onAppear`
        // buried inside the ScrollView's VStack. SwiftUI treats EmptyView
        // as a zero-size elided primitive and does NOT reliably deliver its
        // .onAppear, so neither fetchAllCategories() nor fetchAllTags() ever
        // ran on TestFlight (build 341) — leaving "No categories available"
        // and "No tags available yet" even though the backend returns both.
        // Move the trigger to the root view's .onAppear, which always fires.
        .onAppear {
            fetchAllCategories()
            // Basecamp #9933301500 (2026-05-29 round 7): tags are category-scoped
            // now; load them for whatever single category is pre-selected (if any).
            refreshCategoryTags()
        }
    }

    // MARK: - Section helper -----------------------------------------

    @ViewBuilder
    private func filterSection<Content: View>(title: String,
                                              @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom(poppinsSemiBold, size: 14))
                .foregroundColor(.black)
            content()
        }
    }

    @ViewBuilder
    private func radioRow(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isOn ? Color.defaultTheme : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isOn {
                        Circle().fill(Color.defaultTheme).frame(width: 10, height: 10)
                    }
                }
                Text(title)
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.black)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Helpers -------------------------------------------------

    private func countryLabel(for code: String?) -> String {
        guard let c = code else { return "Any country" }
        return BrowseFilterCountries.all.first(where: { $0.code == c })?.label ?? c
    }

    /// Drops empty strings so they don't show up as `""` filters when sent
    /// to the API. The server's validator treats empty as present-but-blank
    /// (and `tag` blank still triggers a join), so we'd rather omit.
    private func normalized(_ f: BrowseFilters) -> BrowseFilters {
        var out = f
        out.tag = out.tag.trimmingCharacters(in: .whitespaces)
        out.shipState = out.shipState.trimmingCharacters(in: .whitespaces)
        // Don't ship a state without a country.
        if out.shipCountry == nil { out.shipState = "" }
        return out
    }

    // MARK: - Tag autocomplete ----------------------------------------

    // Basecamp #9933301500 (2026-05-29 round 7): tags are CATEGORY-SCOPED.
    // Load the tag names for the single selected category from
    // GET /api/categories/{id}/tags (BrowseFilterController::categoryTags,
    // response shape { data: { category, tags: [{id,name,slug,category_count}] } }).
    // Disabled / cleared when 0 or >1 categories are selected. If the current
    // draft.tag is no longer valid under the new category, it is cleared.
    private func refreshCategoryTags() {
        // Only meaningful with exactly one category selected.
        guard draft.categoryIds.count == 1, let catId = draft.categoryIds.first else {
            categoryTags = []
            if !draft.tag.isEmpty { draft.tag = "" }
            return
        }
        // Serve from cache when available.
        if let cached = tagCache[catId] {
            categoryTags = cached
            if !draft.tag.isEmpty && !cached.contains(draft.tag) { draft.tag = "" }
            return
        }
        isLoadingTags = true
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/categories/\(catId)/tags") else {
            isLoadingTags = false; return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        let token = UserDefaults.accessToken
        if !token.isEmpty { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: req) { data, _, _ in
            DispatchQueue.main.async { self.isLoadingTags = false }
            guard let data else { return }
            struct TagItem: Decodable { let name: String? }
            struct Payload: Decodable { let tags: [TagItem]? }
            struct Envelope: Decodable { let data: Payload? }
            var parsed: [String] = []
            if let env = try? JSONDecoder().decode(Envelope.self, from: data) {
                parsed = (env.data?.tags ?? []).compactMap { $0.name }
            }
            DispatchQueue.main.async {
                self.tagCache[catId] = parsed
                // Guard against a stale response if the user changed selection
                // while this request was in flight.
                if self.draft.categoryIds.count == 1 && self.draft.categoryIds.first == catId {
                    self.categoryTags = parsed
                    if !self.draft.tag.isEmpty && !parsed.contains(self.draft.tag) { self.draft.tag = "" }
                }
            }
        }.resume()
    }

    // MARK: - Category / Subcategory helpers -------------------------

    /// Flat list of subcategories across all currently selected categories,
    /// built by unioning the per-category cache entries.
    private var availableSubcategories: [BrowseFilterSubcategory] {
        var seen = Set<Int>()
        var result: [BrowseFilterSubcategory] = []
        for catId in draft.categoryIds {
            for sub in (subcatCache[catId] ?? []) {
                if seen.insert(sub.id).inserted {
                    result.append(sub)
                }
            }
        }
        return result
    }

    private func toggleCategory(_ id: Int) {
        if let idx = draft.categoryIds.firstIndex(of: id) {
            draft.categoryIds.remove(at: idx)
            // Drop any selected subcats that belong to the deselected category
            let removedSubs = Set((subcatCache[id] ?? []).map { $0.id })
            draft.subCategoryIds.removeAll { removedSubs.contains($0) }
        } else {
            draft.categoryIds.append(id)
            // Fetch subcats for this newly-selected category (if not cached)
            if subcatCache[id] == nil {
                fetchSubcategories(for: draft.categoryIds)
            }
        }
        // Basecamp #9933301500 (2026-05-29 round 7): tags are scoped to the
        // single selected category — reload (or clear) the tag dropdown whenever
        // the category selection changes.
        refreshCategoryTags()
    }

    private func toggleSubcategory(_ id: Int) {
        if let idx = draft.subCategoryIds.firstIndex(of: id) {
            draft.subCategoryIds.remove(at: idx)
        } else {
            draft.subCategoryIds.append(id)
        }
    }

    private func fetchAllCategories() {
        guard allCategories.isEmpty else { return }
        isLoadingCategories = true
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/get-category?get_count=false") else {
            isLoadingCategories = false; return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        // Basecamp #9940038345 round 1 (2026-05-28): Trey: "on ios category
        // filter says No categories available." Root cause was the token
        // read using a raw UserDefaults key path that doesn't always have
        // the latest value depending on when the sheet was instantiated.
        // Switch to UserDefaults.accessToken (the canonical extension that
        // login + delete-account write to) so we always read the freshest
        // logged-in token. Add an Accept header too — some Laravel
        // middleware variants gate JSON output on it.
        let token = UserDefaults.accessToken
        if !token.isEmpty { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: req) { data, response, error in
            DispatchQueue.main.async { self.isLoadingCategories = false }
            guard let data else { return }
            struct Item: Decodable { let id: Int?; let name: String? }
            struct Envelope: Decodable { let data: [Item]? }
            let parsed: [BrowseFilterCategory]
            if let env = try? JSONDecoder().decode(Envelope.self, from: data) {
                parsed = (env.data ?? []).compactMap { item in
                    guard let id = item.id, let name = item.name else { return nil }
                    return BrowseFilterCategory(id: id, name: name)
                }
            } else { parsed = [] }
            DispatchQueue.main.async { self.allCategories = parsed }
        }.resume()
    }

    /// POST /api/get-subcategories with `category_ids` and union-merge results
    /// into the per-category cache so we can quickly rebuild the available list.
    private func fetchSubcategories(for categoryIds: [Int]) {
        let uncached = categoryIds.filter { subcatCache[$0] == nil }
        guard !uncached.isEmpty else { return }
        isFetchingSubcats = true
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/get-subcategories") else {
            isFetchingSubcats = false; return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Basecamp #9940038345 round 1: same UserDefaults.accessToken fix as
        // fetchAllCategories above so subcategory fetch isn't broken either.
        let token = UserDefaults.accessToken
        if !token.isEmpty { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try? JSONSerialization.data(withJSONObject: ["category_ids": categoryIds])
        URLSession.shared.dataTask(with: req) { data, _, _ in
            DispatchQueue.main.async { self.isFetchingSubcats = false }
            guard let data else { return }
            // Response: { data: [{ id, name, subcategories: [{ id, name, category_id }] }] }
            struct SubItem: Decodable { let id: Int?; let name: String?; let category_id: Int? }
            struct CatItem: Decodable { let id: Int?; let subcategories: [SubItem]? }
            struct Envelope: Decodable { let data: [CatItem]? }
            guard let env = try? JSONDecoder().decode(Envelope.self, from: data) else { return }
            var newCache = self.subcatCache
            for cat in (env.data ?? []) {
                guard let catId = cat.id else { continue }
                let subs: [BrowseFilterSubcategory] = (cat.subcategories ?? []).compactMap { s in
                    guard let sid = s.id, let sname = s.name else { return nil }
                    return BrowseFilterSubcategory(id: sid, name: sname, categoryId: s.category_id ?? catId)
                }
                newCache[catId] = subs
            }
            DispatchQueue.main.async { self.subcatCache = newCache }
        }.resume()
    }

    private func scheduleTagFetch(prefix: String) {
        // Debounce 250ms — long enough that a fast typist isn't fanning out
        // 8 requests per word, short enough that suggestions feel live.
        tagDebounceTimer?.invalidate()
        let trimmed = prefix.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            tagSuggestions = []
            return
        }
        tagDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false) { _ in
            fetchTagSuggestions(prefix: trimmed)
        }
    }

    private func fetchTagSuggestions(prefix: String) {
        // Direct URLSession GET — no auth header needed for the public
        // autocomplete endpoint. If a token IS available we don't bother
        // sending it; the endpoint is in the un-authed group on backend.
        var components = URLComponents(string: "https://backend.bidcast.betaplanets.com/api/tags/suggest")
        components?.queryItems = [URLQueryItem(name: "q", value: prefix)]
        guard let url = components?.url else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            // Server shape (per BrowseFilterController::suggestTags) is
            // either { status, data: [string] } or a bare [string]. Try
            // both shapes so we degrade gracefully.
            struct Envelope: Decodable { let data: [String]? }
            var parsed: [String] = []
            if let env = try? JSONDecoder().decode(Envelope.self, from: data),
               let arr = env.data {
                parsed = arr
            } else if let arr = try? JSONDecoder().decode([String].self, from: data) {
                parsed = arr
            }
            // Hard cap at 8 so the dropdown doesn't blow past the sheet.
            let capped = Array(parsed.prefix(8))
            DispatchQueue.main.async {
                tagSuggestions = capped
            }
        }.resume()
    }
}
