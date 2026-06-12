//
//  NotificationName+Extension.swift
//  Alarm-ios-swift
//
//  Created by natsu1211 on 2017/04/18.
//  Copyright © 2017年 LongGames. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let AlarmDisableNotification = NSNotification.Name("AlarmDisableNotification")

    /// Basecamp #9904579913 + #9922137437 (Trey 2026-05-21): posted when an order
    /// is successfully placed (Buy Now or auction win). Product detail screens
    /// listen for this and refetch so the quantity reflects the post-purchase
    /// state immediately instead of showing the stale cached count.
    static let bidcastOrderPlaced = NSNotification.Name("BidcastOrderPlaced")

    /// Basecamp #9986387480 (round 3, 2026-06-12): posted by RehearsalScreen after a
    /// successful raid so the seller is sent to the target show as a viewer.
    /// userInfo key "roomId" carries the target live_room_<hostId>_<showId> string.
    static let bidcastRaidToViewer = NSNotification.Name("BidcastRaidToViewer")
}
