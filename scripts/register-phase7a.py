#!/usr/bin/env python3
"""Register Phase 7a AnalyticsService.swift in the Xcode project."""
from pbxproj import XcodeProject

PROJECT = '/Users/bluemini/.openclaw/workspace/bidcast-ios/BidCast.xcodeproj/project.pbxproj'
FILES = [
    'BidCast/Services/Analytics/AnalyticsService.swift',
]

p = XcodeProject.load(PROJECT)
for f in FILES:
    results = p.add_file(f, target_name='BidCast', force=False)
    print(f"Added {f}: {results}")
p.save()
print("Saved pbxproj.")
