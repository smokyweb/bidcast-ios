//
//  AddCardViewController.swift
//  BidCast — iOS parity Phase 4c (2026-04-22)
//
//  Collect card details via Stripe's `STPPaymentCardTextField`, tokenize
//  with Stripe, then POST the resulting `card_token` to `/api/add-card`
//  (matching Android's AddPaymentCardActivity + Retrofit contract).
//
//  Android flow:
//    `Stripe.createToken(cardParams)` -> token.id -> @POST api/add-card
//      @Part("card_token") cardToken
//
//  iOS mirrors exactly: `StripeService.shared.createCardToken(...)` then
//  `APIManager.postMultipartForm(.addPaymentCard...)` with `card_token`.
//
//  If the Stripe pod is not installed locally (first CI run pre-pod-install)
//  we render a manual-entry fallback using UITextFields so the VC at least
//  compiles. In production, the `#if canImport(Stripe)` branch is what runs.
//

import UIKit

#if canImport(Stripe)
import Stripe
#endif

final class AddCardViewController: UIViewController {

    /// Called after the card is successfully added to the user's Stripe
    /// customer on the backend. Presenter can then refresh its list.
    var onAdded: (() -> Void)?

    // Stripe-backed card input (present when pod is installed)
    #if canImport(Stripe)
    private let cardField = STPPaymentCardTextField()
    #endif

    // Manual fallback fields (present when Stripe pod is missing)
    private let numberField = UITextField()
    private let expField = UITextField()
    private let cvcField = UITextField()

    private let nameField = UITextField()
    private let zipField = UITextField()
    private let submitBtn = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let hintLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Card"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close, primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            })

        // Name
        nameField.placeholder = "Cardholder name"
        nameField.borderStyle = .roundedRect
        nameField.autocapitalizationType = .words

        // Card fields (Stripe preferred; fall back to plain UITextFields)
        let cardInputView: UIView
        #if canImport(Stripe)
        cardField.borderWidth = 1
        cardField.cornerRadius = 8
        cardField.borderColor = UIColor.separator
        cardInputView = cardField
        #else
        numberField.placeholder = "Card number"
        numberField.keyboardType = .numberPad
        numberField.borderStyle = .roundedRect

        expField.placeholder = "MM/YY"
        expField.keyboardType = .numberPad
        expField.borderStyle = .roundedRect

        cvcField.placeholder = "CVC"
        cvcField.keyboardType = .numberPad
        cvcField.borderStyle = .roundedRect

        let expCvc = UIStackView(arrangedSubviews: [expField, cvcField])
        expCvc.axis = .horizontal
        expCvc.spacing = 8
        expCvc.distribution = .fillEqually

        let manualCard = UIStackView(arrangedSubviews: [numberField, expCvc])
        manualCard.axis = .vertical
        manualCard.spacing = 8
        cardInputView = manualCard
        #endif

        zipField.placeholder = "Billing ZIP (optional)"
        zipField.borderStyle = .roundedRect
        zipField.keyboardType = .numbersAndPunctuation

        var cfg = UIButton.Configuration.filled()
        cfg.title = "Add Card"
        cfg.baseBackgroundColor = .systemBlue
        submitBtn.configuration = cfg
        submitBtn.addTarget(self, action: #selector(submit), for: .touchUpInside)

        hintLabel.font = .systemFont(ofSize: 11)
        hintLabel.textColor = .secondaryLabel
        hintLabel.numberOfLines = 0
        #if canImport(Stripe)
        hintLabel.text = "Secured with Stripe. Your card is never stored on BidCast servers."
        #else
        // TODO-TREY: this path only exists when the Stripe pod isn't installed.
        // Codemagic installs pods on every build, so live builds always use
        // the Stripe `STPPaymentCardTextField` above.
        hintLabel.text = "Stripe SDK not present in this build — manual fallback."
        #endif

        let stack = UIStackView(arrangedSubviews: [nameField, cardInputView, zipField, submitBtn, spinner, hintLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        if !StripeService.shared.isConfigured {
            // Payments aren't configured yet — warn but still allow, so that
            // TODO-TREY testing works with a pk_test_* key when Trey drops it in.
            let warn = UILabel()
            warn.text = "Payments are not configured yet. Set STRIPE_PUBLISHABLE_KEY in Info.plist."
            warn.font = .systemFont(ofSize: 12)
            warn.textColor = .systemOrange
            warn.numberOfLines = 0
            stack.insertArrangedSubview(warn, at: 0)
        }
    }

    // MARK: - Submit

    @objc private func submit() {
        guard validateInput() else { return }

        submitBtn.isEnabled = false
        spinner.startAnimating()

        #if canImport(Stripe)
        let cardParams = cardField.cardParams
        let inputName = (nameField.text ?? "").trimmingCharacters(in: .whitespaces)
        let postal = (zipField.text ?? "").trimmingCharacters(in: .whitespaces)

        let input = StripeService.CardInput(
            number: cardParams.number ?? "",
            expMonth: Int(cardParams.expMonth?.intValue ?? 0),
            expYear: Int(cardParams.expYear?.intValue ?? 0),
            cvc: cardParams.cvc ?? "",
            cardHolderName: inputName,
            postalCode: postal.isEmpty ? nil : postal
        )
        StripeService.shared.createCardToken(input) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.postTokenToBackend(token: token, holderName: inputName)
            case .failure(let err):
                self.showError(err.localizedDescription)
            }
        }
        #else
        // Pre-pod-install fallback: this would need the backend to accept raw
        // card numbers, which it doesn't. Show an error.
        showError("Stripe SDK not installed in this build.")
        #endif
    }

    private func postTokenToBackend(token: String, holderName: String) {
        // Android: @Multipart @POST api/add-card @Part("card_token") cardToken
        Task {
            do {
                // QA-NOTE: our AddPaymentCardRequest is a richer codable
                // (full PAN/exp/cvc) — Android's actual wire contract is just
                // `card_token`. We therefore route via postMultipartForm with
                // only that one field, ignoring the Codable.
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .addPaymentCard(param: AddPaymentCardRequest(
                        cardHolderName: holderName,
                        cardNumber: token,
                        expMonth: "",
                        expYear: "",
                        cvc: ""
                    )),
                    fields: ["card_token": token],
                    header: true
                )
                await MainActor.run {
                    // Phase 7a analytics
                    AnalyticsService.shared.logAddPaymentInfo()
                    self.onAdded?()
                    self.dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                }
            }
        }
    }

    private func validateInput() -> Bool {
        if (nameField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty {
            showError("Please enter the cardholder name.")
            return false
        }
        #if canImport(Stripe)
        if !cardField.isValid {
            showError("Please enter valid card details.")
            return false
        }
        #endif
        return true
    }

    private func showError(_ msg: String) {
        DispatchQueue.main.async {
            self.submitBtn.isEnabled = true
            self.spinner.stopAnimating()
            let a = UIAlertController(title: "Couldn't add card", message: msg, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(a, animated: true)
        }
    }
}
