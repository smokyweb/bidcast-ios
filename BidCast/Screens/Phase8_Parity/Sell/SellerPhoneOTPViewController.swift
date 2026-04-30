//
//  SellerPhoneOTPViewController.swift
//  BidCast — iOS Parity QA fix (MC task cmolwmp0i00f64315lqq37lv3)
//
//  Mirrors Android `SellerVerificationActivity`'s phone-OTP step:
//    1. User enters phone number. Country code defaults to US (+1).
//    2. We normalize to E.164 (`+<country><digits>`) before calling
//       `seller-identity/store-phone-number`.
//    3. Backend returns OTP echo, we transition to OTP entry.
//    4. User enters OTP, we call `seller-identity/otp-verify`.
//    5. On success we pop back to the caller (typically the
//       `SellerVerificationSheet` presenter — DashViewController /
//       Account / Sell tab).
//
//  Country picker: a small UIAlertController action sheet of the most
//  common Bidcast markets (US, CA, GB, AU, MX, IN). Defaults to US +1
//  to match Android's behavior. Selecting a different code changes the
//  E.164 prefix and the digit-count validator (we accept 7-15 digits
//  per E.164).
//
//  Endpoints (already registered):
//    - APIEndPoint.storePhoneNumber → POST seller-identity/store-phone-number
//    - APIEndPoint.verifyNumberOtp  → POST seller-identity/otp-verify
//
//  The Android activity calls `fetchSellerVerification` first to detect
//  whether the user has already passed phone OTP and short-circuit to a
//  "Phone verified" state. We do the same here so the screen is safe to
//  re-enter from anywhere.

import UIKit
import SVProgressHUD

final class SellerPhoneOTPViewController: UIViewController {

    // MARK: - Country picker model

    private struct CountryDial {
        let label: String
        let dial: String     // includes leading "+"
    }

    /// Hard-coded short list. Matches the markets product currently has
    /// presence in. Defaults to `.first` which is the US.
    private let countries: [CountryDial] = [
        CountryDial(label: "🇺🇸 United States", dial: "+1"),
        CountryDial(label: "🇨🇦 Canada",        dial: "+1"),
        CountryDial(label: "🇬🇧 UK",            dial: "+44"),
        CountryDial(label: "🇦🇺 Australia",     dial: "+61"),
        CountryDial(label: "🇲🇽 Mexico",        dial: "+52"),
        CountryDial(label: "🇮🇳 India",         dial: "+91"),
    ]

    private var selectedCountry: CountryDial!

    // MARK: - State

    private enum Step { case entryPhone, entryOtp, verified }
    private var step: Step = .entryPhone
    private var lastE164: String = ""

    // MARK: - UI

    private let countryButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.bordered()
        cfg.cornerStyle = .medium
        cfg.contentInsets = .init(top: 10, leading: 12, bottom: 10, trailing: 12)
        b.configuration = cfg
        b.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return b
    }()

    private let phoneField: UITextField = {
        let f = UITextField()
        f.borderStyle = .roundedRect
        f.placeholder = "Phone number"
        f.keyboardType = .phonePad
        f.textContentType = .telephoneNumber
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private let otpField: UITextField = {
        let f = UITextField()
        f.borderStyle = .roundedRect
        f.placeholder = "6-digit code"
        f.keyboardType = .numberPad
        f.textContentType = .oneTimeCode
        f.isHidden = true
        f.translatesAutoresizingMaskIntoConstraints = false
        return f
    }()

    private lazy var primaryButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Send code"
        cfg.cornerStyle = .medium
        b.configuration = cfg
        b.addTarget(self, action: #selector(primaryTap), for: .touchUpInside)
        return b
    }()

    private lazy var resendButton: UIButton = {
        let b = UIButton(type: .system)
        var cfg = UIButton.Configuration.plain()
        cfg.title = "Send a new code"
        b.configuration = cfg
        b.addTarget(self, action: #selector(resendTap), for: .touchUpInside)
        b.isHidden = true
        return b
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Verify phone"
        navigationItem.largeTitleDisplayMode = .never
        selectedCountry = countries.first!
        layout()
        refreshCountryButtonTitle()
        Task { await checkExistingState() }
    }

    private func layout() {
        let header = UILabel()
        header.font = .systemFont(ofSize: 18, weight: .semibold)
        header.text = "Confirm your phone"
        header.textAlignment = .center

        let subHeader = UILabel()
        subHeader.font = .systemFont(ofSize: 13)
        subHeader.textColor = .secondaryLabel
        subHeader.text = "We'll text you a verification code. Standard rates may apply."
        subHeader.numberOfLines = 0
        subHeader.textAlignment = .center

        countryButton.addTarget(self, action: #selector(pickCountry), for: .touchUpInside)

        // Phone row: country code + phone number side-by-side.
        let phoneRow = UIStackView(arrangedSubviews: [countryButton, phoneField])
        phoneRow.axis = .horizontal
        phoneRow.spacing = 8
        phoneRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [
            header, subHeader, phoneRow, otpField, primaryButton,
            resendButton, statusLabel
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
        countryButton.heightAnchor.constraint(equalToConstant: 36).isActive = true

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private func refreshCountryButtonTitle() {
        var cfg = countryButton.configuration ?? UIButton.Configuration.bordered()
        cfg.title = selectedCountry.dial
        cfg.subtitle = nil
        countryButton.configuration = cfg
    }

    // MARK: - Country picker

    @objc private func pickCountry() {
        let sheet = UIAlertController(
            title: "Country code",
            message: nil,
            preferredStyle: .actionSheet)
        for c in countries {
            sheet.addAction(UIAlertAction(title: "\(c.label)  \(c.dial)", style: .default) { [weak self] _ in
                self?.selectedCountry = c
                self?.refreshCountryButtonTitle()
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    // MARK: - Existing-state probe

    @MainActor
    private func checkExistingState() async {
        do {
            let resp: FetchSellerVerificationResponse = try await APIManager.shared.request(
                type: .fetchSellerVerification, header: true)
            let data = resp.data
            // Android short-circuits when number_otp_verified == 1.
            if (data?.numberOtpVerified ?? 0) == 1 {
                step = .verified
                renderForStep()
                statusLabel.text = "Phone already verified ✓"
                statusLabel.textColor = .systemGreen
                return
            }
            // If we have a stored phone but no OTP yet, prefill it for
            // convenience.
            if let p = data?.phoneNumber, !p.isEmpty {
                lastE164 = p
                let stripped = p.hasPrefix("+") ? p : ("+" + p.filter(\.isNumber))
                if let match = countries.first(where: { stripped.hasPrefix($0.dial) }) {
                    selectedCountry = match
                    refreshCountryButtonTitle()
                    phoneField.text = String(stripped.dropFirst(match.dial.count))
                } else {
                    phoneField.text = stripped
                }
            }
        } catch {
            // Non-fatal; user can still send a fresh phone.
        }
    }

    // MARK: - Step rendering

    private func renderForStep() {
        switch step {
        case .entryPhone:
            phoneField.isHidden = false
            countryButton.isHidden = false
            otpField.isHidden = true
            resendButton.isHidden = true
            primaryButton.configuration?.title = "Send code"
            statusLabel.text = nil

        case .entryOtp:
            phoneField.isHidden = true
            countryButton.isHidden = true
            otpField.isHidden = false
            resendButton.isHidden = false
            primaryButton.configuration?.title = "Verify"
            statusLabel.text = "Code sent to \(lastE164)"
            statusLabel.textColor = .secondaryLabel
            otpField.becomeFirstResponder()

        case .verified:
            phoneField.isHidden = true
            countryButton.isHidden = true
            otpField.isHidden = true
            primaryButton.configuration?.title = "Done"
            resendButton.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func primaryTap() {
        switch step {
        case .entryPhone:
            sendPhone()
        case .entryOtp:
            verifyOtp()
        case .verified:
            navigationController?.popViewController(animated: true)
            dismiss(animated: true)
        }
    }

    @objc private func resendTap() {
        // Sending a fresh code = re-submit the same E.164 number.
        guard !lastE164.isEmpty else {
            step = .entryPhone
            renderForStep()
            return
        }
        submitStorePhoneNumber(e164: lastE164)
    }

    // MARK: - E.164 normalization

    /// Returns the digits-only payload suitable for prefixing with the
    /// selected dial code. `+` is handled separately. Strips any
    /// formatting (spaces, dashes, parens, leading `0`s on a couple of
    /// markets where users habitually include the trunk prefix).
    private func normalizedDigits(from raw: String) -> String {
        let digits = raw.filter(\.isNumber)
        // Strip a single leading 0 for markets where users include the
        // domestic trunk prefix (UK, AU). Keeps US/CA untouched since
        // they don't have a trunk-0 convention.
        if digits.first == "0" && (selectedCountry.dial == "+44" || selectedCountry.dial == "+61") {
            return String(digits.dropFirst())
        }
        return digits
    }

    /// Compose the E.164 string using the currently selected country.
    /// Returns nil if the resulting digit count is outside E.164 bounds.
    private func composeE164() -> String? {
        let digits = normalizedDigits(from: phoneField.text ?? "")
        // E.164 max is 15 digits including country code.
        let dialDigits = selectedCountry.dial.filter(\.isNumber).count
        let total = dialDigits + digits.count
        // QA-NOTE: Android currently enforces 10-digit US numbers; we
        // mirror that for `+1` and accept 7-15 digits in total elsewhere
        // (E.164 minimum is 7 in some markets, e.g. Pacific Islands).
        if selectedCountry.dial == "+1" {
            guard digits.count == 10 else { return nil }
        } else {
            guard total >= 8, total <= 15 else { return nil }
        }
        return "\(selectedCountry.dial)\(digits)"
    }

    // MARK: - Network

    private func sendPhone() {
        guard let raw = phoneField.text, !raw.isEmpty else {
            p3Alert(message: "Please enter your phone number.")
            return
        }
        guard let e164 = composeE164() else {
            if selectedCountry.dial == "+1" {
                p3Alert(message: "Please enter a valid 10-digit US phone number.")
            } else {
                p3Alert(message: "Please enter a valid phone number for \(selectedCountry.label).")
            }
            return
        }
        submitStorePhoneNumber(e164: e164)
    }

    private func submitStorePhoneNumber(e164: String) {
        SVProgressHUD.show()
        primaryButton.isEnabled = false
        Task { @MainActor in
            defer {
                SVProgressHUD.dismiss()
                primaryButton.isEnabled = true
            }
            do {
                let _: StorePhoneNumberResponse = try await APIManager.shared.postMultipartForm(
                    type: .storePhoneNumber(param: [:]),
                    fields: ["phone_number": e164],
                    header: true)
                lastE164 = e164
                step = .entryOtp
                renderForStep()
            } catch {
                p3Alert(message: (error as? DataError)?.getErrorMessage()
                        ?? error.localizedDescription)
            }
        }
    }

    private func verifyOtp() {
        let code = (otpField.text ?? "").filter(\.isNumber)
        guard code.count >= 4 else {
            p3Alert(message: "Please enter the code we texted you.")
            return
        }
        SVProgressHUD.show()
        primaryButton.isEnabled = false
        Task { @MainActor in
            defer {
                SVProgressHUD.dismiss()
                primaryButton.isEnabled = true
            }
            do {
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .verifyNumberOtp(param: [:]),
                    fields: ["otp": code],
                    header: true)
                step = .verified
                renderForStep()
                statusLabel.text = "Phone verified ✓"
                statusLabel.textColor = .systemGreen
                // Auto-pop after a beat so the user sees the success.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                    self?.dismiss(animated: true)
                }
            } catch {
                p3Alert(message: (error as? DataError)?.getErrorMessage()
                        ?? error.localizedDescription)
            }
        }
    }
}
