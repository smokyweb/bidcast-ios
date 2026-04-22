//
//  PayoutRequestViewController.swift
//  BidCast — iOS parity Phase 4b (2026-04-22)
//
//  Hits `POST api/stripe/fund-transfer` with `amount` in dollars.
//  Android equivalent: `PayoutFragment`.
//

import UIKit

final class PayoutRequestViewController: UIViewController {

    var onSubmitted: (() -> Void)?

    private let amountField = UITextField()
    private let submitBtn = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Request payout"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close, primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            })

        let hint = UILabel()
        hint.text = "Amount (USD)"
        hint.font = .systemFont(ofSize: 13, weight: .medium)
        hint.textColor = .secondaryLabel

        amountField.placeholder = "0.00"
        amountField.keyboardType = .decimalPad
        amountField.borderStyle = .roundedRect
        amountField.font = .systemFont(ofSize: 24)

        var cfg = UIButton.Configuration.filled()
        cfg.title = "Request Payout"
        cfg.baseBackgroundColor = .systemBlue
        submitBtn.configuration = cfg
        submitBtn.addTarget(self, action: #selector(submit), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [hint, amountField, submitBtn, spinner])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func submit() {
        let raw = (amountField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard let _ = Double(raw), !raw.isEmpty else {
            let alert = UIAlertController(title: "Invalid amount", message: "Enter a dollar amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        submitBtn.isHidden = true
        spinner.startAnimating()
        Task { [raw] in
            do {
                let _: FundTransferResponse = try await APIManager.shared.postMultipartForm(
                    type: .payout(param: FundTransferRequest(amount: raw)),
                    fields: ["amount": raw],
                    header: true
                )
                await MainActor.run {
                    self.onSubmitted?()
                    self.dismiss(animated: true)
                }
            } catch {
                await MainActor.run {
                    self.submitBtn.isHidden = false
                    self.spinner.stopAnimating()
                    let a = UIAlertController(title: "Payout failed", message: error.localizedDescription, preferredStyle: .alert)
                    a.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(a, animated: true)
                }
            }
        }
    }
}
