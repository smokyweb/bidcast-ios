//
//  KYCViewController.swift
//  BidCast — iOS parity Phase 4d (2026-04-22)
//
//  Shows current KYC status + "Continue onboarding" CTA. Tapping the CTA
//  calls `POST api/stripe/check-Kyc` which returns a Stripe-hosted
//  onboarding URL; we open it in an SFSafariViewController. When the user
//  completes onboarding Stripe redirects to the backend's
//  `api/stripe-kyc-callback`, which in turn deep-links back into the app
//  via `bidcast://kyc-complete` (see `DeepLinkRouter`). The app re-fetches
//  KYC status to reflect the new "verified" state.
//
//  Android equivalent:
//    `KYCFragment` -> `checkKyc()` -> webview loads `data.url` -> intercepts
//    redirect to `api/stripe-kyc-callback` -> finishes.
//

import UIKit
import SafariServices

final class KYCViewController: UIViewController {

    private let statusLabel = UILabel()
    private let detailLabel = UILabel()
    private let continueBtn = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let refreshBtn = UIButton(type: .system)

    private var kycStatus: String?
    private var onboardingUrl: String?
    private var safariVC: SFSafariViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "KYC Verification"
        view.backgroundColor = .systemBackground

        // Status card
        statusLabel.font = .systemFont(ofSize: 24, weight: .bold)
        statusLabel.text = "Loading…"

        detailLabel.font = .systemFont(ofSize: 14)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.text = "Check your verification status and complete Stripe's onboarding flow to receive payouts."

        var cfg = UIButton.Configuration.filled()
        cfg.title = "Start / Continue Onboarding"
        cfg.baseBackgroundColor = .systemBlue
        continueBtn.configuration = cfg
        continueBtn.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        var refreshCfg = UIButton.Configuration.plain()
        refreshCfg.title = "Refresh status"
        refreshBtn.configuration = refreshCfg
        refreshBtn.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [statusLabel, detailLabel, continueBtn, refreshBtn, spinner])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        // Listen for deep-link callback from Stripe return URL
        NotificationCenter.default.addObserver(
            self, selector: #selector(kycCallbackReceived),
            name: .bidcastKYCCompleted, object: nil
        )

        Task { await fetchStatus() }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Networking

    @objc private func refreshTapped() {
        Task { await fetchStatus() }
    }

    private func fetchStatus() async {
        await MainActor.run { spinner.startAnimating() }
        do {
            // Android uses POST api/stripe/check-Kyc which returns the Stripe
            // onboarding URL alongside the current status.
            let resp: CheckKycResponse = try await APIManager.shared.postMultipartForm(
                type: .checkKyc, fields: [:], header: true
            )
            let data = resp.data
            kycStatus = data?.kycStatus
            onboardingUrl = data?.url
            await MainActor.run { self.renderStatus() }
        } catch {
            debugLog("[KYC] check-Kyc error: \(error.localizedDescription)")
            await MainActor.run {
                self.statusLabel.text = "Status unavailable"
                self.detailLabel.text = error.localizedDescription
                self.spinner.stopAnimating()
            }
        }
    }

    private func renderStatus() {
        spinner.stopAnimating()
        let status = (kycStatus ?? "").lowercased()
        switch status {
        case "verified", "active", "complete", "completed":
            statusLabel.text = "✅ Verified"
            statusLabel.textColor = .systemGreen
            detailLabel.text = "Your Stripe account is verified. You can receive payouts."
            continueBtn.isHidden = (onboardingUrl == nil)
            continueBtn.configuration?.title = "Open Stripe dashboard"
        case "pending", "in_review", "under_review", "restricted":
            statusLabel.text = "⏳ Pending"
            statusLabel.textColor = .systemOrange
            detailLabel.text = "Stripe is reviewing your submission. No action needed."
            continueBtn.isHidden = true
        case "rejected", "declined":
            statusLabel.text = "❌ Rejected"
            statusLabel.textColor = .systemRed
            detailLabel.text = "Stripe rejected this submission. Tap below to retry."
            continueBtn.isHidden = (onboardingUrl == nil)
        default:
            statusLabel.text = "Not started"
            statusLabel.textColor = .label
            detailLabel.text = "Complete Stripe onboarding to start selling on BidCast."
            continueBtn.isHidden = (onboardingUrl == nil)
        }

        if onboardingUrl == nil {
            continueBtn.setTitle("Onboarding link unavailable", for: .disabled)
            continueBtn.isEnabled = false
        } else {
            continueBtn.isEnabled = true
        }
    }

    // MARK: - Open Stripe onboarding

    @objc private func continueTapped() {
        guard let urlStr = onboardingUrl, let url = URL(string: urlStr) else {
            let a = UIAlertController(title: "No onboarding URL", message: "Please try again.", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return
        }
        let sf = SFSafariViewController(url: url)
        sf.delegate = self
        safariVC = sf
        present(sf, animated: true)
    }

    @objc private func kycCallbackReceived() {
        // Fired by DeepLinkRouter when Stripe redirects to our URL scheme.
        safariVC?.dismiss(animated: true)
        Task { await fetchStatus() }
    }
}

extension KYCViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // User dismissed Safari — re-check status in case they finished
        // but we missed the redirect.
        Task { await fetchStatus() }
    }
}

extension Notification.Name {
    /// Posted by DeepLinkRouter when `bidcast://kyc-complete` is opened.
    static let bidcastKYCCompleted = Notification.Name("bidcast.kyc.completed")
}
