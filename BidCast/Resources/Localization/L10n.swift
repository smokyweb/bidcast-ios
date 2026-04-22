//
//  L10n.swift
//  BidCast
//
//  iOS Parity Phase 7b (2026-04-22): thin NSLocalizedString helper.
//
//  Usage:
//      L10n("place_bid")                     // "Place bid"
//      L10n.string("no_more_items_in_queue") // same as above
//      "place_bid".localized                 // String extension sugar
//
//  Keys live in BidCast/Resources/Localization/<locale>.lproj/Localizable.strings.
//  Only en.lproj is fully populated for v1; the other 12 locales exist as
//  scaffolds marked `TODO-TREY: translate`.

import Foundation

enum L10n {
    /// Fetch a localized string by key from Localizable.strings.
    /// Returns the key itself if no translation exists — making missing-key
    /// bugs visible during QA.
    static func string(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, comment: comment)
    }
}

/// Shortcut: `L10n("place_bid")` → `Place bid`
func L10n(_ key: String, comment: String = "") -> String {
    L10n.string(key, comment: comment)
}

extension String {
    /// Convenience for string-literal-first usage.
    var localized: String {
        L10n.string(self)
    }
}
