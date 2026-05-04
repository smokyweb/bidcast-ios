//
//  StripeService.swift
//  BidCast — iOS parity Phase 4a (2026-04-22)
//
//  Single owner for the Stripe iOS SDK. Everywhere Stripe is needed on iOS,
//  go through StripeService.shared instead of reaching into the SDK directly.
//  This keeps the `#if canImport(Stripe)` guards contained in exactly one file,
//  and guarantees we never accidentally compile a reference to a Stripe type
//  when the pod isn't installed (local dev / first CI run before
//  `pod install` completes).
//
//  Android equivalent: `StripeService` lives inside per-screen VMs — card
//  tokenization happens in AddPaymentCardActivity and send-tip is in the
//  stream UI. We centralise here because iOS's SDK API is more opinionated
//  (PaymentSheet, STPAPIClient singleton, STPPaymentHandler).
//

import Foundation
import UIKit

#if canImport(Stripe)
import Stripe
#endif
#if canImport(StripePaymentSheet)
import StripePaymentSheet
#endif

/// Centralized wrapper around the Stripe iOS SDK.
///
/// Everything Stripe-specific should flow through this class so the rest
/// of the app can stay unaware of whether the pod is installed.
final class StripeService {

    // MARK: - Singleton

    static let shared = StripeService()
    private init() {}

    // MARK: - Configuration

    /// Reads the publishable key from Info.plist.
    ///
    /// 2026-05-04 (MC cmordzx1s00cuf3hgkwnkkplg): the placeholder TODO has been
    /// resolved — `STRIPE_PUBLISHABLE_KEY` in Info.plist is the real Stripe
    /// test publishable key, matching what Android ships in BuildConfig.
    /// Live charges still require flipping to a `pk_live_*` key from the Stripe
    /// dashboard before any production payment flow.
    var publishableKey: String {
        (Bundle.main.infoDictionary?["STRIPE_PUBLISHABLE_KEY"] as? String) ?? ""
    }

    /// `true` only after `configure()` successfully installed a non-placeholder
    /// publishable key. Payment-facing VCs gate their CTAs on this and show a
    /// friendly "payments not configured yet" state otherwise.
    private(set) var isConfigured: Bool = false

    /// Call once at app launch (from `AppDelegate.didFinishLaunchingWithOptions`).
    /// Safe to call multiple times — it's idempotent.
    func configure() {
        let key = publishableKey
        guard !key.isEmpty, !key.contains("TODO_TREY") else {
            debugLog("[StripeService] publishable key not set — payments disabled. Set STRIPE_PUBLISHABLE_KEY in Info.plist.")
            isConfigured = false
            return
        }
        #if canImport(Stripe)
        STPAPIClient.shared.publishableKey = key
        isConfigured = true
        debugLog("[StripeService] configured with publishable key prefix: \(String(key.prefix(7)))…")
        #else
        debugLog("[StripeService] Stripe pod not installed yet; configure() is a no-op.")
        isConfigured = false
        #endif
    }

    // MARK: - Card tokenization (Android add-card parity)
    //
    // Android's AddPaymentCardActivity tokenizes the card using Stripe's
    // Android SDK, then POSTs only the resulting `card_token` string to
    // `/api/add-card`. Laravel then attaches the token to the user's Stripe
    // customer server-side. iOS does the same.
    //
    // Why tokens, not PaymentMethods?
    //   - The backend's `/api/add-card` endpoint accepts a `card_token`
    //     (from `StripeAPI.createToken`), not a `payment_method_id`.
    //   - Switching to PaymentMethods would require a new backend endpoint
    //     — out of scope for Phase 4 autonomy mode.

    struct CardInput {
        let number: String
        let expMonth: Int
        let expYear: Int
        let cvc: String
        let cardHolderName: String
        let postalCode: String?
    }

    enum StripeServiceError: Error, LocalizedError {
        case sdkNotAvailable
        case notConfigured
        case tokenizationFailed(String)
        case paymentFailed(String)

        var errorDescription: String? {
            switch self {
            case .sdkNotAvailable:
                return "Stripe SDK is not available in this build."
            case .notConfigured:
                return "Payments are not configured yet. Please contact support."
            case .tokenizationFailed(let msg):
                return "Card tokenization failed: \(msg)"
            case .paymentFailed(let msg):
                return "Payment failed: \(msg)"
            }
        }
    }

    /// Tokenize a card and return the resulting Stripe token id.
    ///
    /// Android calls `Stripe.createToken(cardParams)` and uses `token.id`.
    /// iOS uses `STPAPIClient.shared.createToken(withCard:)` to get the same.
    func createCardToken(
        _ input: CardInput,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        #if canImport(Stripe)
        guard isConfigured else {
            completion(.failure(StripeServiceError.notConfigured))
            return
        }
        let params = STPCardParams()
        params.number = input.number.replacingOccurrences(of: " ", with: "")
        params.expMonth = UInt(input.expMonth)
        params.expYear = UInt(input.expYear)
        params.cvc = input.cvc
        params.name = input.cardHolderName
        if let zip = input.postalCode, !zip.isEmpty {
            let addr = STPAddress()
            addr.postalCode = zip
            params.address = addr
        }
        STPAPIClient.shared.createToken(withCard: params) { token, error in
            if let err = error {
                completion(.failure(StripeServiceError.tokenizationFailed(err.localizedDescription)))
                return
            }
            guard let tokenId = token?.tokenId else {
                completion(.failure(StripeServiceError.tokenizationFailed("Empty token")))
                return
            }
            completion(.success(tokenId))
        }
        #else
        completion(.failure(StripeServiceError.sdkNotAvailable))
        #endif
    }

    // MARK: - 3DS / PaymentIntent handling (for checkout + tips)
    //
    // Backend may return a PaymentIntent client secret if Stripe asks for
    // SCA (3-D Secure) confirmation. In that case the client has to call
    // STPPaymentHandler.confirmPayment to complete the challenge.
    //
    // The Android backend today does not return client_secret in the
    // place-order response — it just settles server-side. We still wire
    // this so that any future backend upgrade "just works" on iOS.

    /// Confirm a `PaymentIntent.client_secret` on the client, presenting
    /// 3-D Secure challenge UI if needed.
    func confirmPaymentIntent(
        clientSecret: String,
        presentingVC: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        #if canImport(Stripe)
        guard isConfigured else {
            completion(.failure(StripeServiceError.notConfigured))
            return
        }
        let params = STPPaymentIntentParams(clientSecret: clientSecret)
        let auth = STPPaymentHandler.shared()
        auth.confirmPayment(params, with: self.authContext(presentingVC)) { status, _, error in
            switch status {
            case .succeeded:
                completion(.success(()))
            case .failed:
                completion(.failure(StripeServiceError.paymentFailed(error?.localizedDescription ?? "Payment failed")))
            case .canceled:
                completion(.failure(StripeServiceError.paymentFailed("Payment canceled")))
            @unknown default:
                completion(.failure(StripeServiceError.paymentFailed("Unknown payment status")))
            }
        }
        #else
        completion(.failure(StripeServiceError.sdkNotAvailable))
        #endif
    }

    /// Confirm a `SetupIntent.client_secret` (used when attaching a card for
    /// future off-session charges — subscriptions, tips queued mid-stream).
    func confirmSetupIntent(
        clientSecret: String,
        presentingVC: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        #if canImport(Stripe)
        guard isConfigured else {
            completion(.failure(StripeServiceError.notConfigured))
            return
        }
        let params = STPSetupIntentConfirmParams(clientSecret: clientSecret)
        STPPaymentHandler.shared().confirmSetupIntent(params, with: self.authContext(presentingVC)) { status, _, error in
            switch status {
            case .succeeded:
                completion(.success(()))
            case .failed:
                completion(.failure(StripeServiceError.paymentFailed(error?.localizedDescription ?? "Setup failed")))
            case .canceled:
                completion(.failure(StripeServiceError.paymentFailed("Setup canceled")))
            @unknown default:
                completion(.failure(StripeServiceError.paymentFailed("Unknown setup status")))
            }
        }
        #else
        completion(.failure(StripeServiceError.sdkNotAvailable))
        #endif
    }

    // MARK: - Auth context for 3-D Secure presentation

    #if canImport(Stripe)
    private func authContext(_ vc: UIViewController) -> STPAuthenticationContext {
        return StripeAuthContext(presenter: vc)
    }
    #endif
}

#if canImport(Stripe)
/// STPAuthenticationContext bridge — Stripe uses this to know which UIVC to
/// present the 3-D Secure challenge from.
final class StripeAuthContext: NSObject, STPAuthenticationContext {
    weak var presenter: UIViewController?
    init(presenter: UIViewController) { self.presenter = presenter }
    func authenticationPresentingViewController() -> UIViewController {
        presenter ?? UIApplication.shared.topMostViewController() ?? UIViewController()
    }
}
#endif

// MARK: - Top-most view controller helper (used by StripeAuthContext)

extension UIApplication {
    /// Best-effort: returns the currently-visible UIViewController so Stripe
    /// can anchor its 3-D Secure webview.
    func topMostViewController() -> UIViewController? {
        let scene = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        let keyWindow = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        var vc = keyWindow?.rootViewController
        while let presented = vc?.presentedViewController { vc = presented }
        return vc
    }
}
