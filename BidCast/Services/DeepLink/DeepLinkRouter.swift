//
//  DeepLinkRouter.swift
//  BidCast — iOS parity Phase 4m (2026-04-22)
//
//  Single point of resolution for:
//    - Custom URL scheme:   bidcast://...
//    - Universal Links:     https://bidcast.betaplanets.com/...
//    - Push notification "type"/"id" payloads (forwarded by
//      PushRegistrationService.handleNotificationTap)
//
//  Route patterns (mirrored from Android's DashActivity deep-link handler):
//    bidcast://stream/{id}      -> open live stream viewer
//    bidcast://order/{id}       -> open order detail
//    bidcast://chat/{id}        -> open chat thread where id = chatKey
//    bidcast://profile/{userId} -> open seller public profile
//    bidcast://kyc-complete     -> signal KYC onboarding callback
//    bidcast://product/{id}     -> open product detail
//
//  All routes go through `route(URL:)` which posts the resolved target on
//  the main queue to whichever root navigation is active.
//

import Foundation
import UIKit

enum DeepLinkTarget: Equatable {
    case stream(Int)
    case order(Int)
    case chat(String)        // chatKey "{max}_chats_{min}"
    case profile(Int)
    case product(Int)
    case kycComplete
    case unknown(URL)
}

final class DeepLinkRouter {

    static let shared = DeepLinkRouter()
    private init() {}

    // MARK: - Entry points

    /// URL-scheme entry (AppDelegate `application(_:open:options:)`).
    @discardableResult
    func route(url: URL) -> DeepLinkTarget {
        let target = parse(url: url)
        dispatch(target)
        return target
    }

    /// Universal link entry (AppDelegate `application(_:continue:restorationHandler:)`).
    @discardableResult
    func routeUniversalLink(_ userActivity: NSUserActivity) -> DeepLinkTarget? {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else { return nil }
        let target = parse(url: url)
        dispatch(target)
        return target
    }

    /// Push-notification tap routing.
    @discardableResult
    func routeFromPushPayload(_ userInfo: [AnyHashable: Any]) -> DeepLinkTarget {
        // Two shapes:
        //   1) { "url": "bidcast://..." }  — preferred, backend can send
        //      straight into the router.
        //   2) { "type": "order"|"chat"|"stream"|"profile"|"product", "id": "..." }
        //      — legacy Android payload (see MyFirebaseMessagingService.kt).
        if let raw = userInfo["url"] as? String, let url = URL(string: raw) {
            let target = parse(url: url)
            dispatch(target)
            return target
        }
        let type = (userInfo["type"] as? String)?.lowercased() ?? ""
        let idAny = userInfo["id"] ?? userInfo["show_id"] ?? userInfo["order_id"]
        let idStr = (idAny as? String) ?? (idAny as? Int).map { "\($0)" } ?? ""
        let target: DeepLinkTarget
        switch type {
        case "stream", "live", "show":
            target = .stream(Int(idStr) ?? 0)
        case "order":
            target = .order(Int(idStr) ?? 0)
        case "chat", "message":
            target = .chat(idStr)
        case "profile", "user", "seller":
            target = .profile(Int(idStr) ?? 0)
        case "product", "buy":
            target = .product(Int(idStr) ?? 0)
        default:
            target = .unknown(URL(string: "about:blank")!)
        }
        dispatch(target)
        return target
    }

    // MARK: - Parse

    private func parse(url: URL) -> DeepLinkTarget {
        // Accept both `bidcast://` scheme and Universal Links on the known
        // domain. TODO-TREY: once the `apple-app-site-association` file is
        // live on bidcast.betaplanets.com this will auto-start working.
        let path: String
        let host = (url.host ?? "").lowercased()
        if url.scheme == "bidcast" {
            // Custom scheme — host is effectively the first segment.
            // bidcast://stream/42   → host=stream, pathComponents=["/","42"]
            path = "/\(host)\(url.path)"
        } else {
            path = url.path
        }
        let parts = path.split(separator: "/").map { String($0) }
        guard let first = parts.first?.lowercased() else {
            return .unknown(url)
        }
        switch first {
        case "stream", "show", "live":
            if let idStr = parts.dropFirst().first, let id = Int(idStr) {
                return .stream(id)
            }
        case "order":
            if let idStr = parts.dropFirst().first, let id = Int(idStr) {
                return .order(id)
            }
        case "chat", "message":
            if let key = parts.dropFirst().first { return .chat(key) }
        case "profile", "seller", "user":
            if let idStr = parts.dropFirst().first, let id = Int(idStr) {
                return .profile(id)
            }
        case "product":
            if let idStr = parts.dropFirst().first, let id = Int(idStr) {
                return .product(id)
            }
        case "kyc-complete", "kyccomplete":
            return .kycComplete
        default: break
        }
        return .unknown(url)
    }

    // MARK: - Dispatch

    private func dispatch(_ target: DeepLinkTarget) {
        DispatchQueue.main.async {
            switch target {
            case .kycComplete:
                NotificationCenter.default.post(name: .bidcastKYCCompleted, object: nil)
            case .stream(let id):
                self.push(self.buildViewController(for: "stream", id: "\(id)"))
                debugLog("[DeepLink] stream/\(id)")
            case .order(let id):
                self.push(self.buildViewController(for: "order", id: "\(id)"))
                debugLog("[DeepLink] order/\(id)")
            case .chat(let key):
                self.push(self.buildViewController(for: "chat", id: key))
                debugLog("[DeepLink] chat/\(key)")
            case .profile(let id):
                self.push(self.buildViewController(for: "profile", id: "\(id)"))
                debugLog("[DeepLink] profile/\(id)")
            case .product(let id):
                self.push(self.buildViewController(for: "product", id: "\(id)"))
                debugLog("[DeepLink] product/\(id)")
            case .unknown(let url):
                debugLog("[DeepLink] unknown: \(url.absoluteString)")
            }
        }
    }

    // MARK: - VC resolution

    private func buildViewController(for type: String, id: String) -> UIViewController? {
        switch type {
        case "order":
            // Phase 3 OrderDetailViewController seeds from the list; for a
            // direct deep-link we fall through to the list with a highlight
            // hint (full detail resolution is TODO once OrderDetail's
            // constructor accepts a bare orderId).
            // TODO-PHASE4: expose `OrderDetailViewController(orderId:)` init.
            return OrderListViewController()
        case "chat":
            // Construct a bare Conversation from the chatKey so we can push
            // straight into the existing Phase 3 ChatThreadViewController.
            let parts = id.split(separator: "_").compactMap { Int($0) }
            let meRaw = UserDefaults.standard.value(forKey: "id") as? String ?? ""
            let me = Int(meRaw) ?? 0
            let other: Int
            if parts.count >= 2 {
                other = parts[0] == me ? parts[1] : parts[0]
            } else { other = 0 }
            let convo = Conversation(
                id: id,
                participants: [me, other],
                lastMessage: nil,
                lastMessageAt: nil,
                unreadCount: 0,
                otherUser: UserPublic(
                    id: other, bio: nil, email: nil,
                    firstName: nil, lastName: nil, name: nil,
                    username: nil, profileImage: nil, thumbnail: nil,
                    referralCode: nil, roleId: nil, isActive: nil,
                    rating: nil, isFollowed: nil
                ),
                isMuted: nil
            )
            return ChatThreadViewController(conversation: convo)
        case "profile":
            if let iid = Int(id) {
                return SellerPublicProfileViewController(userId: iid)
            }
            return nil
        case "stream":
            // TODO-PHASE5: Phase 5 will ship WatchStreamViewController that
            // takes a show_id. For now, fall through to the home feed.
            return nil
        case "product":
            // Phase 2 product detail exists; Checkout can be opened inline.
            // TODO-PHASE4/5: expose a standalone ProductDetailVC init.
            if let pid = Int(id) {
                return CheckoutViewController(productId: pid)
            }
            return nil
        default:
            return nil
        }
    }

    private func push(_ vc: UIViewController?) {
        guard let vc = vc,
              let nav = Self.currentNavigationController() else {
            return
        }
        nav.pushViewController(vc, animated: true)
    }

    private static func currentNavigationController() -> UINavigationController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        let keyWindow = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        var root = keyWindow?.rootViewController
        while let presented = root?.presentedViewController { root = presented }

        if let nav = root as? UINavigationController { return nav }
        if let tab = root as? UITabBarController,
           let nav = tab.selectedViewController as? UINavigationController { return nav }
        return nil
    }
}
