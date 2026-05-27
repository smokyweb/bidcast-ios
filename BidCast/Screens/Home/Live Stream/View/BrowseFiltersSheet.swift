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
    }

    static let empty = BrowseFilters()
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

    var body: some View {
        VStack(spacing: 0) {
            // Header — mirrors SortByBottomSheet's PrimarySheetHeader so the
            // sheet feels native to the rest of the app's bottom sheets.
            PrimarySheetHeader(title: "Filters", onClose: {
                isPresented = false
            })

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

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
                    filterSection(title: "Tag") {
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Type a tag", text: $draft.tag)
                                .font(.custom(poppinsRegular, size: 14))
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                .onChange(of: draft.tag) { _, newValue in
                                    scheduleTagFetch(prefix: newValue)
                                }

                            if !tagSuggestions.isEmpty {
                                // Compact suggestion list — tap to fill.
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
