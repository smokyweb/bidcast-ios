//
//  LiveConstants.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 2, milestone 1:
//  iOS-side mirror of Android `Const.kt` SOCKET_URL.
//  Android reference:
//    bidcast-android/app/src/main/java/io/bidswipe/app/utils/Const.kt
//    `val SOCKET_URL = "https://node.bidcast.betaplanets.com/"`
//
//  This file intentionally lives in BidCast/Live/Common/ so the iOS
//  live subsystem is isolated from the existing app surface until the
//  rest of the parity milestones land.
//

import Foundation

public enum LiveConstants {

    /// Base URL for the shared Node Socket.IO live server.
    /// Must match Android `Const.SOCKET_URL` exactly so both clients
    /// connect to the same rooms / namespaces.
    public static let socketURL = URL(string: "https://node.bidcast.betaplanets.com/")!

    /// Backend REST API base (same as ProjectEndPoint.baseURL but exposed here
    /// for live subsystem helpers that need it without pulling the whole
    /// APIEndPoint enum).
    public static let backendBaseURL = URL(string: "https://backend.bidcast.betaplanets.com/")!
}
