#!/usr/bin/env python3
"""Register iOS Parity Phase 8 / P1.10 Schedule-Show wizard additions."""
from pbxproj import XcodeProject

PROJECT = '/Users/bluemini/.openclaw/workspace/bidcast-ios/BidCast.xcodeproj/project.pbxproj'
FILES = [
    'BidCast/Screens/Phase8_Parity/Shows/ShowProductsPickerViewController.swift',
    'BidCast/Screens/Phase8_Parity/Shows/ShowCouponsPickerViewController.swift',
]

p = XcodeProject.load(PROJECT)
for f in FILES:
    r = p.add_file(f, target_name='BidCast', force=False)
    print(f"Added {f}: {r}")
p.save()
print("Saved.")
