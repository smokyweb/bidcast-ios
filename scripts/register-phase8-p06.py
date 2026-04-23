#!/usr/bin/env python3
"""Register iOS Parity Phase 8 / P0.6 Account stubs."""
from pbxproj import XcodeProject

PROJECT = '/Users/bluemini/.openclaw/workspace/bidcast-ios/BidCast.xcodeproj/project.pbxproj'
FILES = [
    'BidCast/Screens/Phase8_Parity/Account/TrustedBuyerViewController.swift',
    'BidCast/Screens/Phase8_Parity/Account/InterestsViewController.swift',
    'BidCast/Screens/Phase8_Parity/Account/ClipsPlaceholderViewController.swift',
]

p = XcodeProject.load(PROJECT)
for f in FILES:
    r = p.add_file(f, target_name='BidCast', force=False)
    print(f"Added {f}: {r}")
p.save()
print("Saved.")
