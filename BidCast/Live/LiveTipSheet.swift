//
//  LiveTipSheet.swift
//  BidCast
//
//  QA-FIX (cmo93i7ga) iOS Live parity phase 5:
//  Tip entry sheet for viewer-side `send_tip`. Mirrors the quick-amount
//  + custom-amount flow from Android `WatchStreamFragment` tip dialog.
//

import UIKit

public final class LiveTipSheet: UIViewController {

    public var roomId: String = ""
    public var showId: String = ""
    public var sellerId: String = ""
    public var currentUserId: String = ""
    public var onSent: ((String) -> Void)?

    private static let quickAmounts: [Double] = [1, 5, 10, 20, 50]

    private let amountField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.keyboardType = .decimalPad
        t.textColor = .white
        t.font = .boldSystemFont(ofSize: 22)
        t.textAlignment = .center
        t.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        t.layer.cornerRadius = 10
        t.attributedPlaceholder = NSAttributedString(
            string: "$0.00",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )
        return t
    }()

    private let sendButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Send Tip", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 17)
        b.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        b.layer.cornerRadius = 10
        return b
    }()

    public init(roomId: String, showId: String, sellerId: String, currentUserId: String) {
        self.roomId = roomId
        self.showId = showId
        self.sellerId = sellerId
        self.currentUserId = currentUserId
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
        card.layer.cornerRadius = 14
        view.addSubview(card)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Send a tip"
        title.textColor = .white
        title.font = .boldSystemFont(ofSize: 18)
        title.textAlignment = .center

        let quickStack = UIStackView()
        quickStack.translatesAutoresizingMaskIntoConstraints = false
        quickStack.axis = .horizontal
        quickStack.distribution = .fillEqually
        quickStack.spacing = 8
        for v in Self.quickAmounts {
            let b = UIButton(type: .system)
            b.setTitle("$\(Int(v))", for: .normal)
            b.setTitleColor(.white, for: .normal)
            b.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            b.layer.cornerRadius = 8
            b.heightAnchor.constraint(equalToConstant: 40).isActive = true
            b.addTarget(self, action: #selector(quickTapped(_:)), for: .touchUpInside)
            b.tag = Int(v)
            quickStack.addArrangedSubview(b)
        }

        card.addSubview(title)
        card.addSubview(amountField)
        card.addSubview(quickStack)
        card.addSubview(sendButton)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            amountField.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            amountField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            amountField.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            amountField.heightAnchor.constraint(equalToConstant: 50),
            quickStack.topAnchor.constraint(equalTo: amountField.bottomAnchor, constant: 14),
            quickStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            quickStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            sendButton.topAnchor.constraint(equalTo: quickStack.bottomAnchor, constant: 16),
            sendButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            sendButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            sendButton.heightAnchor.constraint(equalToConstant: 46),
            sendButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18)
        ])

        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }

    @objc private func quickTapped(_ sender: UIButton) {
        amountField.text = "\(sender.tag)"
    }

    @objc private func sendTapped() {
        let raw = (amountField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard let amount = Double(raw), amount > 0 else { return }
        let amountStr = String(format: amount.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.2f", amount)
        BidcastSocketManager.shared.emitSendTip(
            roomId: roomId,
            showId: showId,
            userId: currentUserId,
            sellerId: sellerId,
            amount: amountStr
        )
        onSent?(amountStr)
        dismiss(animated: true)
    }
}
