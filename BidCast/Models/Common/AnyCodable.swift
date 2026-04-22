//  AnyCodable.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Android's @SerializedName fields typed as `Any?` (e.g. deleted_at,
//  thumbnail, gift_user, etc.) can hold null, a string, an Int, a
//  nested object, or an empty array. `AnyCodable` accepts any of those
//  so the decoder doesn't fail on field shape drift between environments.

import Foundation

struct AnyCodable: Codable, Hashable {
    let value: Any?

    init(_ value: Any?) { self.value = value }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self.value = nil; return }
        if let b = try? c.decode(Bool.self) { self.value = b; return }
        if let i = try? c.decode(Int.self) { self.value = i; return }
        if let d = try? c.decode(Double.self) { self.value = d; return }
        if let s = try? c.decode(String.self) { self.value = s; return }
        if let arr = try? c.decode([AnyCodable].self) { self.value = arr.map { $0.value }; return }
        if let dict = try? c.decode([String: AnyCodable].self) {
            var out: [String: Any?] = [:]
            for (k, v) in dict { out[k] = v.value }
            self.value = out
            return
        }
        self.value = nil
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        if value == nil { try c.encodeNil(); return }
        if let b = value as? Bool { try c.encode(b); return }
        if let i = value as? Int { try c.encode(i); return }
        if let d = value as? Double { try c.encode(d); return }
        if let s = value as? String { try c.encode(s); return }
        if let arr = value as? [Any?] { try c.encode(arr.map { AnyCodable($0) }); return }
        if let dict = value as? [String: Any?] {
            var out: [String: AnyCodable] = [:]
            for (k, v) in dict { out[k] = AnyCodable(v) }
            try c.encode(out)
            return
        }
        try c.encodeNil()
    }

    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        // Rough equality: string description match. Good enough for models.
        String(describing: lhs.value) == String(describing: rhs.value)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: value))
    }
}

// MARK: - FlexibleID

/// Some Android fields come back as either `Int` or `String` depending on
/// the endpoint (e.g. `role_id` is `Int` in LoginResponse but `String` in
/// some places). Use FlexibleID where the backend contract is fuzzy.
struct FlexibleID: Codable, Hashable {
    let stringValue: String?
    let intValue: Int?

    var value: String? { stringValue ?? intValue.map { String($0) } }

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let i = try? c.decode(Int.self) {
            self.intValue = i; self.stringValue = nil; return
        }
        if let s = try? c.decode(String.self) {
            self.stringValue = s; self.intValue = Int(s); return
        }
        self.intValue = nil; self.stringValue = nil
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        if let i = intValue { try c.encode(i); return }
        if let s = stringValue { try c.encode(s); return }
        try c.encodeNil()
    }
}
