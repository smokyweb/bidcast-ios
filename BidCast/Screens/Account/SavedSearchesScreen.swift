//
//  SavedSearchesScreen.swift
//  BidCast
//
//  Basecamp #9933801536 (2026-05-27): manage saved searches.
//

import SwiftUI

struct SavedSearchesScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var items: [SavedSearchItem] = []
    @State private var isLoading: Bool = true
    @State private var deletingId: Int? = nil
    var onItemTap: ((String) -> Void)? = nil

    // Basecamp #9933801536 round 3 (2026-05-28): tapping a saved search must
    // re-run the search. Previously this called an unset onItemTap closure +
    // dismissed the page, so the user just saw the screen close with nothing
    // happening. Now we push the SearchResultsView so the saved query is
    // re-run in place.
    @State private var navigateQuery: String? = nil
    @State private var navigateActive: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Saved Searches")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.black)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            Text("You'll get a notification when a new show or product matches.")
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 4)

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if items.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                        .padding(16)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                    Text("No saved searches yet")
                        .font(.custom(poppinsSemiBold, size: 15))
                    Text("Run a search from the top bar, then tap the bell icon to save it.")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Spacer()
            } else {
                List {
                    ForEach(items) { item in
                        SavedSearchRow(item: item, onRunQuery: { q in
                            // Basecamp #9933801536 round 3: route to results.
                            navigateQuery = q
                            navigateActive = true
                        }, onDelete: { id in
                            Task { await deleteRow(id: id) }
                        }, isDeleting: deletingId == item.id)
                    }
                }
                .listStyle(.plain)
            }

            // Hidden NavigationLink that fires when a row is tapped.
            NavigationLink(
                destination: SearchResultsView(initialQuery: navigateQuery ?? ""),
                isActive: $navigateActive,
                label: { EmptyView() }
            )
            .hidden()
        }
        .navigationBarHidden(true)
        .onAppear { Task { await refresh() } }
    }

    private func refresh() async {
        isLoading = true
        let fetched = await SavedSearchAPI.list()
        await MainActor.run {
            self.items = fetched
            self.isLoading = false
        }
    }

    private func deleteRow(id: Int) async {
        await MainActor.run { deletingId = id }
        let ok = await SavedSearchAPI.delete(id: id)
        await MainActor.run {
            if ok { items.removeAll { $0.id == id } }
            deletingId = nil
        }
    }
}

struct SavedSearchRow: View {
    let item: SavedSearchItem
    var onRunQuery: (String) -> Void
    var onDelete: (Int) -> Void
    var isDeleting: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.query?.isEmpty == false ? item.query! : "Filters only")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.black)
                    .lineLimit(1)
                if let f = item.filters, !f.isEmpty {
                    Text(f.map { "\($0.key): \($0.value.stringValue)" }.joined(separator: ", "))
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                if let created = item.created_at {
                    Text("Saved \(created.prefix(10))")
                        .font(.custom(poppinsRegular, size: 10))
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                if let q = item.query, !q.isEmpty { onRunQuery(q) }
            }

            if isDeleting {
                ProgressView()
            } else {
                Button(action: { onDelete(item.id) }) {
                    Text("Remove")
                        .font(.custom(poppinsSemiBold, size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Capsule())
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 6)
    }
}
