//
//  CustomSearchBar.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 15/10/25.
//

import SwiftUI
import SwiftUI

struct CustomSearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "Search..."
    // Basecamp #9933801536 (2026-05-27): when non-nil, optional filters dict
    // to send to the saved-search API alongside the text query. Pages that
    // have a filter sheet should pass the current filter snapshot here so
    // saved searches capture the full intent.
    var savedSearchFilters: [String: Any]? = nil
    // Basecamp #9933801536: hide the bell on screens where save-search
    // doesn't make sense (e.g. shop inventory search). Default visible.
    var showSaveBell: Bool = true
    @State private var savedAcknowledged: Bool = false

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding([.leading] , 8)

            TextField(placeholder, text: $searchText)
                .foregroundColor(.primary)
                .frame(height: 45)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.custom(poppinsSemiBold, size: 28.0))
                        .foregroundStyle(.black)
                }
                .padding([.trailing] , 4)
            }

            if showSaveBell {
                Button(action: {
                    saveCurrentSearch()
                }) {
                    Image(systemName: savedAcknowledged ? "bell.fill" : "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(savedAcknowledged ? .orange : .gray)
                }
                .padding([.trailing] , 8)
                .accessibilityLabel("Save this search")
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    // Basecamp #9933801536 (2026-05-27): POST current query to
    // /api/saved-searches and flip the bell to filled on success.
    private func saveCurrentSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filters = savedSearchFilters ?? [:]
        if trimmed.isEmpty && filters.isEmpty { return }
        Task {
            await SavedSearchAPI.create(query: trimmed.isEmpty ? nil : trimmed, filters: filters.isEmpty ? nil : filters)
            await MainActor.run { savedAcknowledged = true }
        }
    }
}

// Basecamp #9933801536 (2026-05-27): simple URLSession-backed client for
// the new /api/saved-searches endpoints. Kept self-contained here to
// avoid wiring through the larger network service for an MVP.
enum SavedSearchAPI {
    static func create(query: String?, filters: [String: Any]?) async {
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/saved-searches") else { return }
        var body: [String: Any] = [:]
        if let q = query { body["query"] = q }
        if let f = filters { body["filters"] = f }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            _ = try await URLSession.shared.data(for: req)
        } catch {
            print("⚠️ saved-search create failed: \(error)")
        }
    }

    static func list() async -> [SavedSearchItem] {
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/saved-searches") else { return [] }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (data, _) = try await URLSession.shared.data(for: req)
            let resp = try JSONDecoder().decode(SavedSearchListResponse.self, from: data)
            return resp.data ?? []
        } catch {
            print("⚠️ saved-search list failed: \(error)")
            return []
        }
    }

    static func delete(id: Int) async -> Bool {
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/saved-searches/\(id)") else { return false }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode == 200 { return true }
        } catch {
            print("⚠️ saved-search delete failed: \(error)")
        }
        return false
    }
}

struct SavedSearchItem: Codable, Identifiable {
    var id: Int
    var query: String?
    var filters: [String: AnyCodable]?
    var created_at: String?
}

struct SavedSearchListResponse: Codable {
    var status: String?
    var message: String?
    var data: [SavedSearchItem]?
}

// Minimal AnyCodable for filter JSON — keeps the response decode forgiving.
struct AnyCodable: Codable {
    let value: Any
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let v = try? c.decode(String.self) { value = v }
        else if let v = try? c.decode(Int.self) { value = v }
        else if let v = try? c.decode(Double.self) { value = v }
        else if let v = try? c.decode(Bool.self) { value = v }
        else if let v = try? c.decode([String].self) { value = v }
        else if let v = try? c.decode([String: AnyCodable].self) { value = v.mapValues { $0.value } }
        else if c.decodeNil() { value = NSNull() }
        else { value = "" }
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        if let v = value as? String { try c.encode(v) }
        else if let v = value as? Int { try c.encode(v) }
        else if let v = value as? Double { try c.encode(v) }
        else if let v = value as? Bool { try c.encode(v) }
        else if let v = value as? [String] { try c.encode(v) }
        else { try c.encodeNil() }
    }
    var stringValue: String {
        if let v = value as? String { return v }
        if let v = value as? [String] { return v.joined(separator: ", ") }
        return String(describing: value)
    }
}


//#Preview {
//    CustomSearchBar()
//}
