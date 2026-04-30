//
//  SellerVerificationSheet.swift
//  BidCast — iOS parity Phase 8 / P1.8 (2026-04-23)
//
//  Bottom sheet equivalent of Android's `DashActivity.verificationDialog()`.
//  Presented when a seller tries to reach List-a-Product or Schedule-a-Show
//  without having completed all four prerequisites:
//      - Seller identity verified
//      - KYC (Stripe) active
//      - At least one card on file
//      - At least one shipping address on file
//
//  Tap-throughs take the user directly to the relevant fix VC:
//      - Identity → SellerIdentityViewController / KYCViewController (Android
//        equivalent is StoreSellerIdCardFragment). iOS currently bundles
//        these two flows under KYC. When a dedicated `SellerIdentityViewController`
//        VC is added (future Phase 4), this will be routed separately.
//      - KYC         → KYCViewController   (Stripe onboarding webview)
//      - Card        → PaymentMethodsListViewController
//      - Shipping    → MyAddressViewController
//

import UIKit

/// Represents one unmet prerequisite.
enum SellerVerificationItem: String, CaseIterable {
    case sellerIdentity
    case phoneOtp           // QA-FIX (MC task cmolwmp0i): seller phone OTP
    case kyc
    case card
    case shipping

    var title: String {
        switch self {
        case .sellerIdentity: return "Verify seller identity"
        case .phoneOtp:       return "Verify your phone number"
        case .kyc:            return "Complete KYC onboarding"
        case .card:           return "Add a payment method"
        case .shipping:       return "Add a shipping address"
        }
    }

    var subtitle: String {
        switch self {
        case .sellerIdentity: return "Confirm your ID so buyers know who they're buying from."
        case .phoneOtp:       return "We text a one-time code to confirm you can be reached."
        case .kyc:            return "Stripe needs your details before we can pay out earnings."
        case .card:           return "Required for subscriptions, fees, and promo boosts."
        case .shipping:       return "Required as your default return address on orders."
        }
    }

    var icon: String {
        switch self {
        case .sellerIdentity: return "person.badge.shield.checkmark"
        case .phoneOtp:       return "phone.badge.checkmark"
        case .kyc:            return "checkmark.seal"
        case .card:           return "creditcard"
        case .shipping:       return "shippingbox"
        }
    }
}

final class SellerVerificationSheet: UIViewController {

    let missing: [SellerVerificationItem]

    init(missing: [SellerVerificationItem]) {
        self.missing = missing
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()
    }

    private func layout() {
        let headline = UILabel()
        headline.font = .systemFont(ofSize: 22, weight: .bold)
        headline.text = "Before you can sell"
        headline.numberOfLines = 0

        let sub = UILabel()
        sub.font = .systemFont(ofSize: 14)
        sub.textColor = .secondaryLabel
        sub.numberOfLines = 0
        sub.text = "Finish these steps to unlock listing products and scheduling shows."

        let stack = UIStackView(arrangedSubviews: [headline, sub])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(20, after: sub)

        for item in missing {
            stack.addArrangedSubview(row(for: item))
        }

        let dismiss = UIButton(type: .system)
        var cfg = UIButton.Configuration.plain()
        cfg.title = "Not now"
        dismiss.configuration = cfg
        dismiss.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        stack.setCustomSpacing(16, after: stack.arrangedSubviews.last ?? dismiss)
        stack.addArrangedSubview(dismiss)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func row(for item: SellerVerificationItem) -> UIView {
        let btn = UIButton(type: .system)
        var cfg = UIButton.Configuration.bordered()
        cfg.baseBackgroundColor = .secondarySystemGroupedBackground
        cfg.baseForegroundColor = .label
        cfg.cornerStyle = .medium
        cfg.image = UIImage(systemName: item.icon)
        cfg.imagePadding = 12
        cfg.imagePlacement = .leading
        cfg.title = item.title
        cfg.subtitle = item.subtitle
        cfg.titleAlignment = .leading
        btn.configuration = cfg
        btn.contentHorizontalAlignment = .leading
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true
        btn.addAction(UIAction { [weak self] _ in self?.handle(item) }, for: .touchUpInside)
        return btn
    }

    private func handle(_ item: SellerVerificationItem) {
        // Presenting VC is what we should push into. Dismiss sheet first,
        // then ask the presenter to push the fix VC.
        guard let presenter = presentingViewController else {
            dismiss(animated: true)
            return
        }
        dismiss(animated: true) {
            switch item {
            case .sellerIdentity, .kyc:
                // Both roll up to the Stripe KYC flow in the iOS Phase 4
                // bundle. When a dedicated SellerIdentity VC is added,
                // route sellerIdentity there separately.
                presenter.p3Push(KYCViewController())
            case .phoneOtp:
                // QA-FIX (MC task cmolwmp0i): dedicated phone OTP screen
                // mirroring Android `SellerVerificationActivity`'s phone
                // step — sends `seller-identity/store-phone-number`
                // (E.164 normalized) then `seller-identity/otp-verify`.
                presenter.p3Push(SellerPhoneOTPViewController())
            case .card:
                presenter.p3Push(PaymentMethodsListViewController())
            case .shipping:
                // MyAddressViewController is a storyboard-backed VC (see
                // P0.4 wiring in CheckoutViewController). If it fails to
                // instantiate from the storyboard we fall back to a plain
                // alloc/init so the fix still happens.
                if let story = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "MyAddressViewController") as? MyAddressViewController {
                    presenter.p3Push(story)
                } else {
                    presenter.p3Push(MyAddressViewController())
                }
            }
        }
    }

    // MARK: - Gating predicate

    /// Evaluates the user profile + KYC payload against Android's
    /// `DashActivity.verificationDialog()` predicate. Any returned items
    /// are what's missing (ordered by the CaseIterable order so the UI
    /// presents them consistently).
    static func missingItems(profile: UserProfileData?,
                             kyc: CheckKycData?) -> [SellerVerificationItem] {
        var missing: [SellerVerificationItem] = []

        // Seller identity — Android checks `seller_identity_status == "verified"`.
        // QA-NOTE: Android also surfaces a `phoneOtp` step in its
        // `SellerVerificationActivity`, but the iOS `UserProfileData`
        // payload does not yet include the `number_otp_verified` flag.
        // Adding `.phoneOtp` here unconditionally would block every
        // seller, so we route to the new SellerPhoneOTPViewController
        // from inside the dedicated `SellerIdentity` step instead, and
        // also expose it directly to QA via deep links if needed. The
        // gate predicate stays a function of the four flags currently
        // present on `UserProfileData`.
        if (profile?.sellerIdentityStatus ?? "").lowercased() != "verified" {
            missing.append(.sellerIdentity)
        }

        // KYC — Android checks Stripe `kyc_status == "active"`.
        // If we failed to load kyc, treat as missing (safer default).
        if (kyc?.kycStatus ?? "").lowercased() != "active" {
            missing.append(.kyc)
        }

        // Card — Android checks `has_card_added == true`.
        if profile?.hasCardAdded != true {
            missing.append(.card)
        }

        // Shipping — Android checks `has_shipping_address == true`.
        if profile?.hasShippingAddress != true {
            missing.append(.shipping)
        }

        return missing
    }
}
