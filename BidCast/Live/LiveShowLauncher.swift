//
//  LiveShowLauncher.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 2, milestone 4→5 integration:
//  Single entry point the rest of the iOS app uses to open the new
//  live-stream screens. Callers don't need to know about Agora, socket,
//  or token fetching — they hand over a `Show` and a role.
//
//  Navigation-wiring contract:
//    ScheduledShowsViewController   (host)    -> launchHost(from:show:)
//    ShopViewController / future    (viewer)  -> launchViewer(from:show:)
//
//  If the Show object is missing rtc_token / room_id / agora app id, the
//  launcher still attempts to open the screen using the app-level Agora
//  app id from Info.plist `AGORA_APP_ID` (matches Android's use of
//  BuildConfig.AGORA_APP_ID). When the token is missing we surface a
//  user-facing alert instead of pretending success.
//

import UIKit

enum LiveShowLauncher {

    static func launchHost(from presenter: UIViewController, show: Show) {
        guard let ctx = makeContext(from: show, isHost: true) else {
            presentMissingInfo(on: presenter, role: "host")
            return
        }
        let vc = HostPublisherViewController()
        vc.context = ctx
        vc.modalPresentationStyle = .fullScreen
        fillIdentity(into: vc)
        presenter.present(vc, animated: true)
    }

    /// BUGFIX 2026-04-29 (MC task cmohlvlro): always fetch a fresh Agora
    /// token via the resolver before presenting the viewer. Previously we
    /// reused the rtc_token cached on the Show object from the home/explore
    /// feed, which is stale once Agora's TTL expires. When the cached token
    /// is past TTL, Agora's joinChannel fails with a server-time-vs-token-time
    /// mismatch error ("start time is different than current time"). Hitting
    /// the resolver guarantees we use a freshly-issued token tied to the
    /// current viewer's uid.
    static func launchViewer(from presenter: UIViewController, show: Show) {
        guard let showId = show.id else {
            presentMissingInfo(on: presenter, role: "viewer")
            return
        }

        let loader = UIAlertController(title: nil, message: "Joining show…", preferredStyle: .alert)
        presenter.present(loader, animated: true)

        let currentUserId: String = {
            if let id = (UserDefaults.standard.value(forKey: "user_id") as? Int) { return String(id) }
            if let s = UserDefaults.standard.string(forKey: "user_id") { return s }
            return ""
        }()

        Task { [weak presenter] in
            do {
                let ctx = try await LiveShowResolver.resolveViewerContext(
                    showId: showId,
                    currentUserId: currentUserId
                )
                await MainActor.run {
                    guard let presenter = presenter else { return }
                    loader.dismiss(animated: false) {
                        let vc = WatchStreamViewController()
                        vc.context = ctx
                        vc.modalPresentationStyle = .fullScreen
                        fillIdentityViewer(into: vc)
                        presenter.present(vc, animated: true)
                    }
                }
            } catch {
                await MainActor.run {
                    guard let presenter = presenter else { return }
                    loader.dismiss(animated: false) {
                        let alert = UIAlertController(
                            title: "Could not join show",
                            message: error.localizedDescription,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        presenter.present(alert, animated: true)
                    }
                }
            }
        }
    }

    // MARK: - Internals

    private static func makeContext(from show: Show, isHost: Bool) -> LiveShowContext? {
        guard
            let rtcToken = show.rtcToken, !rtcToken.isEmpty,
            let roomId = show.roomId, !roomId.isEmpty
        else { return nil }

        let appId = agoraAppId()
        guard !appId.isEmpty else { return nil }

        let showId = show.id.map(String.init) ?? ""
        let sellerId = show.userId.map(String.init) ?? show.user?.id.map(String.init) ?? ""
        let sellerName: String = {
            if let f = show.user?.firstName, !f.isEmpty {
                let l = show.user?.lastName ?? ""
                return "\(f) \(l)".trimmingCharacters(in: .whitespaces)
            }
            if let n = show.user?.name, !n.isEmpty { return n }
            if let u = show.user?.username, !u.isEmpty { return u }
            return show.title ?? "Seller"
        }()
        let sellerImage = show.user?.profileImage
        let categoryId = show.categoryId.map(String.init)
        let productIds = (show.productIds ?? []).compactMap { $0 }

        return LiveShowContext(
            showId: showId,
            roomId: roomId,
            rtcToken: rtcToken,
            agoraAppId: appId,
            sellerId: sellerId,
            sellerName: sellerName,
            sellerImage: sellerImage,
            categoryId: categoryId,
            auctionTypeId: show.auctionTypeId,
            productIds: productIds,
            isHost: isHost
        )
    }

    private static func agoraAppId() -> String {
        if let infoId = Bundle.main.object(forInfoDictionaryKey: "AGORA_APP_ID") as? String, !infoId.isEmpty {
            return infoId
        }
        return ""
    }

    private static func fillIdentity(into vc: HostPublisherViewController) {
        vc.currentUserId = currentUserIdString()
        vc.currentUserName = currentUserName()
        vc.currentUserImage = currentUserImage()
    }

    private static func fillIdentityViewer(into vc: WatchStreamViewController) {
        vc.currentUserId = currentUserIdString()
        vc.currentUserName = currentUserName()
        vc.currentUserImage = currentUserImage()
    }

    private static func currentUserIdString() -> String {
        // Prefer an explicit UserDefaults key; fall back to empty.
        let candidates = ["userId", "user_id", "userID", "CURRENT_USER_ID"]
        for key in candidates {
            if let v = UserDefaults.standard.string(forKey: key), !v.isEmpty { return v }
            let n = UserDefaults.standard.integer(forKey: key)
            if n > 0 { return String(n) }
        }
        return ""
    }

    private static func currentUserName() -> String {
        for key in ["userName", "user_name", "firstName", "first_name"] {
            if let v = UserDefaults.standard.string(forKey: key), !v.isEmpty { return v }
        }
        return "Viewer"
    }

    private static func currentUserImage() -> String {
        for key in ["profilePicture", "user_image", "avatar"] {
            if let v = UserDefaults.standard.string(forKey: key), !v.isEmpty { return v }
        }
        return ""
    }

    private static func presentMissingInfo(on presenter: UIViewController, role: String) {
        let alert = UIAlertController(
            title: "Live stream unavailable",
            message: "This show is missing the \(role) connection info (rtc_token / room_id / Agora app id). Please refresh and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        presenter.present(alert, animated: true)
    }
}
