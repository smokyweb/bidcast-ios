//
//  L10n.swift
//  BidCast
//
//  iOS Parity Phase 7b (2026-04-22): thin NSLocalizedString helper.
//
//  Usage:
//      L10n("place_bid")                     // "Place bid"
//
//  Keys live in BidCast/Resources/Localization/<locale>.lproj/Localizable.strings.
//  Only en.lproj is fully populated for v1; the other 12 locales exist as
//  scaffolds marked `TODO-TREY: translate`.
//
//  NOTE 2026-04-22: An earlier draft of this file defined BOTH an `enum L10n`
//  wrapper AND a free `func L10n(_:comment:)`. Swift treats type and function
//  names as the same identifier, so the two collided ("invalid redeclaration
//  of 'L10n(_:comment:)'"). The draft also declared a `var localized` on
//  String that collided with `String+Extension.swift`'s `func localized()`.
//  Both collisions are resolved by keeping only the free L10n(…) function
//  below and removing the enum / String extension wrappers — the only external
//  callers use `L10n("key")` form.
//

import Foundation

/// Fetch a localized string by key from Localizable.strings.
/// Returns the key itself if no translation exists — making missing-key
/// bugs visible during QA.
func L10n(_ key: String, comment: String = "") -> String {
    NSLocalizedString(key, comment: comment)
}
