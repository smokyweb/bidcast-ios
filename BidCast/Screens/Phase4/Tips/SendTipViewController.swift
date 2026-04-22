//
//  SendTipViewController.swift
//  BidCast — iOS parity Phase 4f (2026-04-22)
//
//  Sheet-style VC presented from inside a stream. User picks a preset or
//  enters a custom amount and taps Send. Hits
//    POST api/send-tip-amount
//      @Part("seller_id")  sellerId
//      @Part("amount")     amount   (in dollars as string)
//      @Part("card_number") last4   (optional — picks default card if empty)
//
//  Matches Android's `SendGiftFragment`. On success, a `tip_sent` socket
//  event is emitted from the live view (Phase 5 will wire that).
//

import UIKit

final class SendTipViewController: UIViewController {

    var sellerId: Int
    var streamId: Int?
    var onSent: ((Int) -> Void)?

    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let amountField = UITextField()
    private let presetStack = UIStackView()
    private let sendBtn = UIButton(type: .system)
    private let cardButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)

    private var selectedCard: PaymentCard?
    private var selectedAmount: Int = 0

    init(sellerId: Int, streamId: Int? = nil) {
        self.sellerId = sellerId
        self.streamId = streamId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Send a tip"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close, primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            })

        setupLayout()
        Task { await loadDefaultCard() }
    }

    private func setupLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        let hint = UILabel()
        hint.text = "Pick an amount or enter a custom tip. The host gets this directly."
        hint.numberOfLines = 0
        hint.font = .systemFont(ofSize: 13)
        hint.textColor = .secondaryLabel
        stack.addArrangedSubview(hint)

        // Presets
        presetStack.axis = .horizontal
        presetStack.spacing = 8
        presetStack.distribution = .fillEqually
        let presets = (UserDefaults.standard.array(forKey: "bidcast.tip.presets") as? [Int])
            ?? [1, 5, 10, 25, 50]
        for amount in presets {
            let b = UIButton(type: .system)
            var cfg = UIButton.Configuration.tinted()
            cfg.title = "$\(amount)"
            b.configuration = cfg
            b.addAction(UIAction { [weak self] _ in
                self?.selectedAmount = amount
                self?.amountField.text = "\(amount)"
            }, for: .touchUpInside)
            presetStack.addArrangedSubview(b)
        }
        stack.addArrangedSubview(presetStack)

        amountField.placeholder = "Custom amount"
        amountField.keyboardType = .numberPad
        amountField.borderStyle = .roundedRect
        amountField.font = .systemFont(ofSize: 24, weight: .semibold)
        stack.addArrangedSubview(amountField)

        var cardCfg = UIButton.Configuration.bordered()
        cardCfg.title = "Payment: loading…"
        cardCfg.image = UIImage(systemName: "creditcard")
        cardCfg.imagePadding = 8
        cardButton.configuration = cardCfg
        cardButton.contentHorizontalAlignment = .leading
        cardButton.addAction(UIAction { [weak self] _ in
            self?.pickCard()
        }, for: .touchUpInside)
        stack.addArrangedSubview(cardButton)

        var sendCfg = UIButton.Configuration.filled()
        sendCfg.title = "Send Tip"
        sendCfg.baseBackgroundColor = .systemGreen
        sendBtn.configuration = sendCfg
        sendBtn.addTarget(self, action: #selector(send), for: .touchUpInside)
        stack.addArrangedSubview(sendBtn)
        stack.addArrangedSubview(spinner)
    }

    private func pickCard() {
        let list = PaymentMethodsListViewController()
        list.onPick = { [weak self] card in
            self?.selectedCard = card
            self?.updateCardButton()
        }
        navigationController?.pushViewController(list, animated: true)
    }

    private func updateCardButton() {
        if let c = selectedCard {
            cardButton.configuration?.title = "Visa •••• \(c.last4 ?? "")"
        } else {
            cardButton.configuration?.title = "Add a payment method"
        }
    }

    private func loadDefaultCard() async {
        do {
            let resp: GetPaymentCardsResponse = try await APIManager.shared.request(
                type: APIEndPoint.getPaymentCard, header: true
            )
            let cards = (resp.data ?? []).compactMap { $0 }
            let def = cards.first(where: { $0.isDefault == true }) ?? cards.first
            await MainActor.run {
                self.selectedCard = def
                self.updateCardButton()
            }
        } catch {
            debugLog("[SendTip] getCards error: \(error.localizedDescription)")
        }
    }

    @objc private func send() {
        // Determine amount
        let raw = (amountField.text ?? "").trimmingCharacters(in: .whitespaces)
        let amount = Int(raw) ?? selectedAmount
        guard amount > 0 else {
            alert("Enter a tip amount.")
            return
        }
        guard let card = selectedCard else {
            alert("Add a payment method first.")
            return
        }

        sendBtn.isEnabled = false
        spinner.startAnimating()

        let fields: [String: String] = [
            "seller_id": "\(sellerId)",
            "amount": "\(amount)",
            "card_number": card.last4 ?? ""
        ]

        Task {
            do {
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .sendTipAmount(param: fields),
                    fields: fields,
                    header: true
                )
                await MainActor.run {
                    self.onSent?(amount)
                    // Phase 7a analytics
                    let cents = Int((Double(amount) ?? 0) * 100)
                    AnalyticsService.shared.logSendTip(showId: "\(self.sellerId)", amountCents: cents)
                    // TODO-PHASE5: Emit `tip_sent` socket event here so the
                    // host UI sees the tip animation in real time. Match the
                    // Android payload shape:
                    //   { room_id: streamId, user_id: me, amount: amount }
                    let a = UIAlertController(title: "Tip sent",
                                              message: "Your $\(amount) tip is on its way.",
                                              preferredStyle: .alert)
                    a.addAction(UIAlertAction(title: "Nice", style: .default) { _ in
                        self.dismiss(animated: true)
                    })
                    self.present(a, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.sendBtn.isEnabled = true
                    self.spinner.stopAnimating()
                    // Backend may return a client_secret if SCA/3DS is required.
                    // Android doesn't handle this today — iOS is prepared to,
                    // but we'd need the backend to actually return the secret.
                    // TODO-BACKEND: expose client_secret on send-tip-amount
                    // when Stripe requires SCA so we can confirm via
                    // StripeService.confirmPaymentIntent.
                    self.alert("Tip failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func alert(_ msg: String) {
        let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
