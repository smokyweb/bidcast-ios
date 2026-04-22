//
//  ReturnRequestViewController.swift
//  BidCast — iOS parity Phase 3a (2026-04-22)
//
//  Simple reason+description form for a return request.
//
//  TODO-PHASE3/4: Backend endpoint for create-return-request is not in
//  Android's ApiInterface.kt. Leaving UI + validation in place; on submit
//  we currently fall back to raise-ticket with subject "Return request".
//  Swap the endpoint once backend team exposes a dedicated route.
//

import UIKit
import SVProgressHUD

final class ReturnRequestViewController: UIViewController {

    private let orderId: Int
    private let reasonPicker = UITextField()
    private let descriptionView = UITextView()
    private let submitBtn = UIButton(type: .system)

    private let reasons = [
        "Damaged on arrival",
        "Not as described",
        "Wrong item",
        "No longer needed",
        "Other"
    ]
    private var selectedReason: String?

    init(orderId: Int) {
        self.orderId = orderId
        super.init(nibName: nil, bundle: nil)
        self.title = "Return request"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        reasonPicker.placeholder = "Select a reason"
        reasonPicker.borderStyle = .roundedRect
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickReason))
        reasonPicker.isUserInteractionEnabled = true
        reasonPicker.addGestureRecognizer(tap)

        descriptionView.font = .systemFont(ofSize: 15)
        descriptionView.layer.borderColor = UIColor.separator.cgColor
        descriptionView.layer.borderWidth = 1
        descriptionView.layer.cornerRadius = 8
        descriptionView.heightAnchor.constraint(equalToConstant: 140).isActive = true

        let descLabel = UILabel()
        descLabel.text = "Tell us more (optional)"
        descLabel.font = .systemFont(ofSize: 13)
        descLabel.textColor = .secondaryLabel

        var cfg = UIButton.Configuration.filled()
        cfg.title = "Submit return request"
        cfg.cornerStyle = .medium
        submitBtn.configuration = cfg
        submitBtn.addTarget(self, action: #selector(submit), for: .touchUpInside)

        stack.addArrangedSubview(label("Reason"))
        stack.addArrangedSubview(reasonPicker)
        stack.addArrangedSubview(descLabel)
        stack.addArrangedSubview(descriptionView)
        stack.addArrangedSubview(submitBtn)
        stack.addArrangedSubview(UIView())

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func label(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }

    @objc private func pickReason() {
        let sheet = UIAlertController(title: "Reason for return", message: nil, preferredStyle: .actionSheet)
        for r in reasons {
            sheet.addAction(UIAlertAction(title: r, style: .default) { [weak self] _ in
                self?.selectedReason = r
                self?.reasonPicker.text = r
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func submit() {
        guard let reason = selectedReason, !reason.isEmpty else {
            p3Alert(title: "Missing info", message: "Please select a reason."); return
        }
        SVProgressHUD.show()
        // TODO-PHASE4: swap to create-return-request endpoint once available.
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let fields: [String: String] = [
                    "order_id": "\(orderId)",
                    "subject": "Return request: \(reason)",
                    "message": descriptionView.text ?? ""
                ]
                let _: RaiseTicketResponse = try await APIManager.shared.postMultipartForm(
                    type: .raiseTicket(param: [:]),
                    fields: fields,
                    header: true
                )
                self.p3Alert(title: "Submitted",
                             message: "Your return request has been submitted. Our team will follow up shortly.") {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch let err as DataError {
                self.p3Alert(message: err.getErrorMessage())
            } catch {
                self.p3Alert(message: error.localizedDescription)
            }
        }
    }
}

/// Standalone "Raise ticket" screen — reused from order detail + help section.
final class RaiseTicketViewController: UIViewController {

    private let orderId: Int?
    private let productId: Int?
    private let subjectField = UITextField()
    private let bodyView = UITextView()

    init(orderId: Int? = nil, productId: Int? = nil) {
        self.orderId = orderId
        self.productId = productId
        super.init(nibName: nil, bundle: nil)
        self.title = "Support ticket"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        subjectField.placeholder = "Subject"
        subjectField.borderStyle = .roundedRect

        bodyView.font = .systemFont(ofSize: 15)
        bodyView.layer.borderColor = UIColor.separator.cgColor
        bodyView.layer.borderWidth = 1
        bodyView.layer.cornerRadius = 8
        bodyView.heightAnchor.constraint(equalToConstant: 180).isActive = true

        let submit = UIButton(type: .system)
        var cfg = UIButton.Configuration.filled()
        cfg.title = "Send"
        submit.configuration = cfg
        submit.addTarget(self, action: #selector(sendTicket), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [subjectField, bodyView, submit, UIView()])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func sendTicket() {
        guard let subject = subjectField.text, !subject.isEmpty,
              let body = bodyView.text, !body.isEmpty else {
            p3Alert(title: "Missing info",
                    message: "Please enter a subject and describe the issue."); return
        }
        SVProgressHUD.show()
        var fields: [String: String] = ["subject": subject, "message": body]
        if let oid = orderId, oid > 0 { fields["order_id"] = "\(oid)" }
        if let pid = productId, pid > 0 { fields["product_id"] = "\(pid)" }

        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let _: RaiseTicketResponse = try await APIManager.shared.postMultipartForm(
                    type: .raiseTicket(param: [:]),
                    fields: fields,
                    header: true
                )
                self.p3Alert(title: "Sent", message: "Your message was sent. We'll respond soon.") {
                    self.navigationController?.popViewController(animated: true)
                }
            } catch let err as DataError {
                self.p3Alert(message: err.getErrorMessage())
            } catch {
                self.p3Alert(message: error.localizedDescription)
            }
        }
    }
}
