#!/usr/bin/env python3
"""Register Phase 7b Localization files in the Xcode project.

For Localizable.strings across 13 locales, Xcode uses a variant group with
one PBXVariantGroup and a PBXFileReference per locale. The pbxproj library
supports this via `add_file` with the main strings file + then adding each
locale variant via `add_file`/`add_group`. Simpler: we use a Python helper
that adds Localizable.strings as a single .strings file for the project to
compile. For Codemagic / Xcode 16, putting the files under Resources/Localization
with a base .lproj lets Xcode pick them up automatically when added via
add_file. We'll add only en/Localizable.strings; the Bundle lookup at runtime
will see all *.lproj directories at the same level.

In practice, `add_file` won't create a variant group but will register the
en.lproj/Localizable.strings as a Resources build phase entry. The sibling
lproj directories are picked up automatically by NSLocalizedString at runtime
because they're inside the app bundle Resources/Localization tree.
"""
from pbxproj import XcodeProject

PROJECT = '/Users/bluemini/.openclaw/workspace/bidcast-ios/BidCast.xcodeproj/project.pbxproj'

SWIFT_FILES = [
    'BidCast/Resources/Localization/L10n.swift',
]

# Add the English Localizable.strings into the project so it lands in the
# Resources build phase. (The 12 sibling *.lproj dirs are deployed via the
# same mechanism since they all live under Resources/Localization/*.lproj;
# Xcode copies sibling lprojs once one is registered in a standard structure.)
STRINGS_FILES = [
    'BidCast/Resources/Localization/en.lproj/Localizable.strings',
    'BidCast/Resources/Localization/ar.lproj/Localizable.strings',
    'BidCast/Resources/Localization/de.lproj/Localizable.strings',
    'BidCast/Resources/Localization/es.lproj/Localizable.strings',
    'BidCast/Resources/Localization/fr.lproj/Localizable.strings',
    'BidCast/Resources/Localization/hi.lproj/Localizable.strings',
    'BidCast/Resources/Localization/it.lproj/Localizable.strings',
    'BidCast/Resources/Localization/ja.lproj/Localizable.strings',
    'BidCast/Resources/Localization/ko.lproj/Localizable.strings',
    'BidCast/Resources/Localization/pt.lproj/Localizable.strings',
    'BidCast/Resources/Localization/ru.lproj/Localizable.strings',
    'BidCast/Resources/Localization/vi.lproj/Localizable.strings',
    'BidCast/Resources/Localization/zh.lproj/Localizable.strings',
]

p = XcodeProject.load(PROJECT)
for f in SWIFT_FILES:
    r = p.add_file(f, target_name='BidCast', force=False)
    print(f"Swift {f}: {r}")
for f in STRINGS_FILES:
    r = p.add_file(f, target_name='BidCast', force=False)
    print(f"Strings {f}: {r}")
p.save()
print("Saved pbxproj.")
