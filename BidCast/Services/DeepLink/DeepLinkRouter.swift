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
    /// iOS Parity P0.5: `/invite/<code>` universal link — pre-fill signup.
    case invite(String)
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
        case "invite":
            // iOS Parity P0.5: /invite/<code> → land on signup with the
            // field pre-filled. Code is URL-safe alphanum, length >= 3.
            if let code = parts.dropFirst().first, code.count >= 2 {
                return .invite(String(code))
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
                // Phase 5: resolve the show on-demand via LiveShowResolver,
                // then present WatchStreamViewController modally. A bare
                // `push` doesn't fit — live viewer is always fullscreen.
                self.openLiveStream(showId: id)
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
            case .invite(let code):
                // iOS Parity P0.5: present SignUp with the referral field
                // pre-filled. If the user is already signed in we just
                // surface a toast via debug log; deep link is a no-op for
                // signed-in users (matches Android).
                self.presentSignUpForInvite(code: code)
                debugLog("[DeepLink] invite/\(code)")
            case .unknown(let url):
                debugLog("[DeepLink] unknown: \(url.absoluteString)")
            }
        }
    }

    /// iOS Parity P0.5: land on SignUp with a referral code pre-filled.
    /// If the user is already authenticated, this is a no-op — they
    /// shouldn't be bounced back to a signup form.
    private func presentSignUpForInvite(code: String) {
        let token = UserDefaults.accessToken
        if !token.isEmpty {
            debugLog("[DeepLink] /invite ignored for signed-in user")
            return
        }
        let storyboard = UIStoryboard(name: "Onboardings", bundle: nil)
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "SignUpViewController") as? SignUpViewController
        else {
            return
        }
        vc.referralCode = code
        DeepLinkRouter.presentOnTopmost(vc)
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
            // Phase 5: see openLiveStream(showId:) — WatchStreamViewController
            // needs an Agora token + room id, which require an async backend
            // call. That path bypasses this sync VC builder and drives the
            // navigation itself once the token lands.
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

    /// Phase 5: resolve a show id to a full LiveShowContext (via
    /// LiveShowResolver) and present WatchStreamViewController fullscreen.
    /// Surfaces backend / auth errors as in-app alerts on the root window
    /// rather than silently swallowing them.
    private func openLiveStream(showId: Int) {
        let userId = DeepLinkRouter.currentUserIdString()
        Task { @MainActor in
            do {
                let ctx = try await LiveShowResolver.resolveViewerContext(
                    showId: showId,
                    currentUserId: userId
                )
                let vc = WatchStreamViewController()
                vc.context = ctx
                vc.currentUserId = userId
                vc.currentUserName = DeepLinkRouter.currentUserName()
                vc.currentUserImage = DeepLinkRouter.currentUserImage()
                vc.modalPresentationStyle = .fullScreen
                DeepLinkRouter.presentOnTopmost(vc)
            } catch {
                let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                if LiveAuthGuard.handleIfAuthFailure(error: error, source: "DeepLink.openLiveStream") {
                    // Auth listener handles the kick; just show a gentle heads-up.
                    DeepLinkRouter.presentAlert(
                        title: "Session expired",
                        message: "Please log in again to watch live shows."
                    )
                    return
                }
                DeepLinkRouter.presentAlert(
                    title: "Live show unavailable",
                    message: msg
                )
            }
        }
    }

    private static func currentUserIdString() -> String {
        for key in ["userId", "user_id", "userID", "id", "CURRENT_USER_ID"] {
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

    private static func presentOnTopmost(_ vc: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }) ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        top.present(vc, animated: true)
    }

    private static func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        presentOnTopmost(alert)
    }

    private func push(_ vc: UIViewController?) {
        guard let vc = vc else { return }
        guard let nav = Self.currentNavigationController(preferredTabForTarget: vc) else {
            // No ambient nav — wrap in one and present modally so the user
            // still lands on the deep-linked screen.
            let wrap = UINavigationController(rootViewController: vc)
            wrap.modalPresentationStyle = .fullScreen
            Self.topViewController()?.present(wrap, animated: true)
            return
        }
        nav.pushViewController(vc, animated: true)
    }

    // MARK: - Tab-aware navigation resolver
    //
    // For each deep-link target we want the user to feel like they're on
    // the right tab before the push. Orders/Activity/Chat land on the
    // Activity tab (index 3); Stream/Product/Profile land on the Home
    // tab (index 0). KYC / Wallet land on the Account tab (index 4).
    //
    // The TabBarViewController defined at
    // BidCast/Screens/TabBar/View/TabBarViewController.swift indexes tabs
    // as: 0 home, 1 explore, 2 sell, 3 activity, 4 account.

    private static let tabHome     = 0
    private static let tabExplore  = 1
    private static let tabSell     = 2
    private static let tabActivity = 3
    private static let tabAccount  = 4

    private static func preferredTabIndex(for vc: UIViewController) -> Int {
        switch vc {
        case is OrderListViewController,
             is ChatThreadViewController,
             is ConversationListViewController,
             is NotificationListViewController:
            return tabActivity
        case is WalletViewController,
             is PaymentMethodsListViewController,
             is KYCViewController,
             is SellerPublicProfileViewController:
            return tabAccount
        case is CheckoutViewController:
            return tabHome
        default:
            return tabHome
        }
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        let keyWindow = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        var root = keyWindow?.rootViewController
        while let presented = root?.presentedViewController { root = presented }
        return root
    }

    private static func currentNavigationController(preferredTabForTarget vc: UIViewController? = nil)
        -> UINavigationController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        let keyWindow = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        var root = keyWindow?.rootViewController
        while let presented = root?.presentedViewController { root = presented }

        // Tab-bar-aware resolution: switch to the right tab first, then find
        // the first UINavigationController embedded in that tab. Our tab VCs
        // (Sell / Activity) embed a child UINavigationController via swizzle;
        // return that nav so pushes land inside the tab context.
        if let tab = (root as? UITabBarController) ?? findTabBar(in: root) {
            if let vc = vc {
                tab.selectedIndex = preferredTabIndex(for: vc)
            }
            let selected = tab.selectedViewController
            if let nav = selected as? UINavigationController { return nav }
            if let nav = selected?.children.compactMap({ $0 as? UINavigationController }).first {
                return nav
            }
            return nil
        }
        if let nav = root as? UINavigationController { return nav }
        return nil
    }

    private static func findTabBar(in vc: UIViewController?) -> UITabBarController? {
        guard let vc = vc else { return nil }
        if let t = vc as? UITabBarController { return t }
        for child in vc.children {
            if let t = findTabBar(in: child) { return t }
        }
        return nil
    }
}
