#!/usr/bin/env python3
"""Register Phase 6 Swift files into BidCast.xcodeproj.

Files added:
    BidCast/Live/Host/CreatePollSheet.swift
    BidCast/Live/Host/HostTipSettingsSheet.swift
    BidCast/Live/Host/HostRandomizerSheet.swift
    BidCast/Live/Host/HostRaidSheet.swift
    BidCast/Live/RandomizerWinnerBanner.swift
"""
from pathlib import Path
from pbxproj import XcodeProject

REPO = Path(__file__).resolve().parents[1]
PROJ = REPO / "BidCast.xcodeproj" / "project.pbxproj"
TARGET = "BidCast"

FILES = [
    "BidCast/Live/Host/CreatePollSheet.swift",
    "BidCast/Live/Host/HostTipSettingsSheet.swift",
    "BidCast/Live/Host/HostRandomizerSheet.swift",
    "BidCast/Live/Host/HostRaidSheet.swift",
    "BidCast/Live/RandomizerWinnerBanner.swift",
]


def main() -> None:
    p = XcodeProject.load(str(PROJ))
    added = 0
    for rel in FILES:
        abs_path = REPO / rel
        if not abs_path.exists():
            print(f"[skip] missing: {rel}")
            continue
        # `force=False` skips already-registered files.
        res = p.add_file(rel, target_name=TARGET, force=False)
        if res:
            added += 1
            print(f"[add ] {rel}")
        else:
            print(f"[keep] already in project: {rel}")
    p.save()
    print(f"Done. {added} file(s) added.")


if __name__ == "__main__":
    main()
