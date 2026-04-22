//
//  LiveShowContext.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 2:
//  Shared context model passed between the iOS viewer (WatchStreamViewController)
//  and the iOS host (HostPublisherViewController). Mirrors the fields Android
//  pulls off `liveShowData` in `App.kt` / `WatchStreamFragment.kt` /
//  `AgoraPublisherActivity.kt`.
//

import Foundation

public struct LiveShowContext {
    public let showId: String
    public let roomId: String
    public let rtcToken: String
    public let agoraAppId: String
    public let sellerId: String
    public let sellerName: String
    public let sellerImage: String?
    public let categoryId: String?
    public let auctionTypeId: Int?
    public let productIds: [String]
    public let isHost: Bool

    public init(
        showId: String,
        roomId: String,
        rtcToken: String,
        agoraAppId: String,
        sellerId: String,
        sellerName: String,
        sellerImage: String?,
        categoryId: String?,
        auctionTypeId: Int?,
        productIds: [String],
        isHost: Bool
    ) {
        self.showId = showId
        self.roomId = roomId
        self.rtcToken = rtcToken
        self.agoraAppId = agoraAppId
        self.sellerId = sellerId
        self.sellerName = sellerName
        self.sellerImage = sellerImage
        self.categoryId = categoryId
        self.auctionTypeId = auctionTypeId
        self.productIds = productIds
        self.isHost = isHost
    }
}
