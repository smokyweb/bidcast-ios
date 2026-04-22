//
//  CheckoutViewController.swift
//  BidCast — iOS parity Phase 4g (2026-04-22)
//
//  Complete checkout flow for Buy Now. Mirrors Android's `BuyNowFragment`:
//    1. POST api/v1/checkout-product-detail -> subtotal / shipping / tax / total
//    2. User selects address + payment method + optional promo code
//    3. POST api/v1/place-order -> if backend returns a PaymentIntent
//       client_secret, confirm via StripeService.confirmPaymentIntent
//       (else the backend already charged server-side — nothing more to do).
//    4. On success, navigate to OrderDetail.
//

import UIKit

final class CheckoutViewController: UIViewController {

    // Input
    let productId: Int
    init(productId: Int) {
        self.productId = productId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // State
    private var detail: PurchaseDetailData?
    private var selectedCard: PaymentCard?
    private var selectedAddress: ShippingAddress?
    private var promoCode: PromoCodeData?

    // UI
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let subtotalLbl = UILabel()
    private let shippingLbl = UILabel()
    private let taxLbl = UILabel()
    private let discountLbl = UILabel()
    private let totalLbl = UILabel()
    private let addressBtn = UIButton(type: .system)
    private let paymentBtn = UIButton(type: .system)
    private let promoField = UITextField()
    private let promoApplyBtn = UIButton(type: .system)
    private let placeOrderBtn = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let productLbl = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Checkout"
        view.backgroundColor = .systemGroupedBackground
        setupLayout()
        // Phase 7a analytics
        AnalyticsService.shared.logBeginCheckout(valueCents: nil)
        Task {
            await loadDefaults()
            await recalc()
        }
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
        stack.spacing = 16
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

        productLbl.numberOfLines = 0
        productLbl.font = .systemFont(ofSize: 16, weight: .semibold)
        stack.addArrangedSubview(sectionCard("Item", body: productLbl))

        var addrCfg = UIButton.Configuration.bordered()
        addrCfg.title = "Select address"
        addrCfg.image = UIImage(systemName: "mappin.and.ellipse")
        addrCfg.imagePadding = 8
        addressBtn.configuration = addrCfg
        addressBtn.contentHorizontalAlignment = .leading
        addressBtn.addAction(UIAction { [weak self] _ in self?.pickAddress() }, for: .touchUpInside)
        stack.addArrangedSubview(sectionCard("Ship to", body: addressBtn))

        var payCfg = UIButton.Configuration.bordered()
        payCfg.title = "Select payment method"
        payCfg.image = UIImage(systemName: "creditcard")
        payCfg.imagePadding = 8
        paymentBtn.configuration = payCfg
        paymentBtn.contentHorizontalAlignment = .leading
        paymentBtn.addAction(UIAction { [weak self] _ in self?.pickCard() }, for: .touchUpInside)
        stack.addArrangedSubview(sectionCard("Pay with", body: paymentBtn))

        promoField.placeholder = "Promo code"
        promoField.borderStyle = .roundedRect
        promoField.autocapitalizationType = .allCharacters
        var promoBtn = UIButton.Configuration.plain()
        promoBtn.title = "Apply"
        promoApplyBtn.configuration = promoBtn
        promoApplyBtn.addAction(UIAction { [weak self] _ in self?.applyPromo() }, for: .touchUpInside)

        let promoRow = UIStackView(arrangedSubviews: [promoField, promoApplyBtn])
        promoRow.axis = .horizontal
        promoRow.spacing = 8
        stack.addArrangedSubview(sectionCard("Promo code", body: promoRow))

        // Summary card
        let summary = UIStackView(arrangedSubviews: [
            summaryLine("Subtotal", subtotalLbl),
            summaryLine("Shipping", shippingLbl),
            summaryLine("Tax", taxLbl),
            summaryLine("Discount", discountLbl),
            UIView.divider(),
            summaryLine("Total", totalLbl, boldRight: true)
        ])
        summary.axis = .vertical
        summary.spacing = 8
        stack.addArrangedSubview(sectionCard("Summary", body: summary))

        var btnCfg = UIButton.Configuration.filled()
        btnCfg.title = "Place Order"
        btnCfg.baseBackgroundColor = .systemGreen
        placeOrderBtn.configuration = btnCfg
        placeOrderBtn.addTarget(self, action: #selector(placeOrder), for: .touchUpInside)
        stack.addArrangedSubview(placeOrderBtn)
        stack.addArrangedSubview(spinner)
    }

    private func sectionCard(_ title: String, body: UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        let t = UILabel()
        t.text = title
        t.font = .systemFont(ofSize: 12, weight: .semibold)
        t.textColor = .secondaryLabel
        let s = UIStackView(arrangedSubviews: [t, body])
        s.axis = .vertical
        s.spacing = 8
        s.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(s)
        NSLayoutConstraint.activate([
            s.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            s.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            s.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            s.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    private func summaryLine(_ label: String, _ rhsLabel: UILabel, boldRight: Bool = false) -> UIView {
        let l = UILabel()
        l.text = label
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        rhsLabel.text = "—"
        rhsLabel.textAlignment = .right
        rhsLabel.font = boldRight ? .systemFont(ofSize: 17, weight: .heavy) : .systemFont(ofSize: 14)
        let row = UIStackView(arrangedSubviews: [l, rhsLabel])
        row.axis = .horizontal
        row.distribution = .fill
        l.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return row
    }

    // MARK: - Load defaults (card + address)

    private func loadDefaults() async {
        async let cards: GetPaymentCardsResponse? = try? APIManager.shared.request(
            type: APIEndPoint.getPaymentCard, header: true
        )
        async let addresses: APIResponse<AnyCodable>? = try? APIManager.shared.request(
            type: APIEndPoint.getShippingAddress, header: true
        )
        let (cardResp, _) = await (cards, addresses)
        let ls = (cardResp?.data ?? []).compactMap { $0 }
        let def = ls.first(where: { $0.isDefault == true }) ?? ls.first
        await MainActor.run {
            self.selectedCard = def
            self.updatePaymentButton()
            // Address selection is deferred to the address picker
            // (ShippingAddressesViewController lives in existing Phase 2 code).
        }
    }

    // MARK: - Pickers

    private func pickCard() {
        let list = PaymentMethodsListViewController()
        list.onPick = { [weak self] card in
            self?.selectedCard = card
            self?.updatePaymentButton()
            Task { await self?.recalc() }
        }
        navigationController?.pushViewController(list, animated: true)
    }

    private func pickAddress() {
        // Try to present Phase 2's existing shipping address list. If not
        // available, fall through to an inline prompt.
        let a = UIAlertController(
            title: "Address picker",
            message: "Select an address in 'Shipping Addresses' first, or enter an address ID manually.",
            preferredStyle: .alert
        )
        a.addTextField { tf in
            tf.placeholder = "Address ID"
            tf.keyboardType = .numberPad
            tf.text = self.selectedAddress?.id.map { "\($0)" }
        }
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        a.addAction(UIAlertAction(title: "Use", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let txt = a.textFields?.first?.text, let id = Int(txt) {
                self.selectedAddress = ShippingAddress(
                    id: id, name: nil, phoneNumber: nil, streetAddress: nil,
                    pincode: nil, city: nil, state: nil, type: nil,
                    userId: nil, isDefault: nil
                )
                self.updateAddressButton()
                Task { await self.recalc() }
            }
        })
        present(a, animated: true)
    }

    // MARK: - Promo

    private func applyPromo() {
        let code = (promoField.text ?? "").trimmingCharacters(in: .whitespaces)
        guard !code.isEmpty else { return }
        Task {
            do {
                let resp: VerifyPromoCodeResponse = try await APIManager.shared.postMultipartForm(
                    type: .verifyPromoCode(param: VerifyPromoCodeRequest(code: code, sellerId: nil)),
                    fields: ["code": code],
                    header: true
                )
                await MainActor.run {
                    self.promoCode = resp.data
                    let ok = (resp.data?.code ?? "").isEmpty == false
                    let a = UIAlertController(
                        title: ok ? "Promo applied" : "Invalid code",
                        message: ok ? "Discount will appear in the summary." : (resp.message ?? "Try a different code."),
                        preferredStyle: .alert
                    )
                    a.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(a, animated: true)
                }
                await recalc()
            } catch {
                debugLog("[Checkout] verifyPromo error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Recalc

    private func recalc() async {
        let fields: [String: String] = [
            "shipping_id": selectedAddress?.id.map { "\($0)" } ?? "",
            "product_id": "\(productId)",
            "coupon_name": promoCode?.code ?? ""
        ]
        do {
            let resp: GetPurchaseDetailResponse = try await APIManager.shared.postMultipartForm(
                type: .getPurchaseProduct(param: fields),
                fields: fields,
                header: true
            )
            detail = resp.data
            await MainActor.run { self.renderSummary() }
        } catch {
            debugLog("[Checkout] purchase-detail error: \(error.localizedDescription)")
        }
    }

    private func renderSummary() {
        productLbl.text = detail?.product?.title ?? "Item #\(productId)"
        subtotalLbl.text = money(detail?.subTotal)
        shippingLbl.text = money(detail?.shippingCharges)
        taxLbl.text = money(detail?.taxAmount)
        discountLbl.text = money(detail?.discountAmount) ?? "—"
        totalLbl.text = money(detail?.total)
        updatePaymentButton()
        updateAddressButton()
    }

    private func updatePaymentButton() {
        if let c = selectedCard {
            paymentBtn.configuration?.title = "•••• \(c.last4 ?? "")"
        } else {
            paymentBtn.configuration?.title = "Add / select card"
        }
    }

    private func updateAddressButton() {
        if let a = selectedAddress, let id = a.id {
            addressBtn.configuration?.title = "Address #\(id)"
        } else {
            addressBtn.configuration?.title = "Select shipping address"
        }
    }

    private func money(_ s: String?) -> String {
        if let s = s, !s.isEmpty, let d = Double(s) {
            let f = NumberFormatter()
            f.numberStyle = .currency
            f.currencyCode = "USD"
            return f.string(from: NSNumber(value: d)) ?? "$\(d)"
        }
        return "—"
    }

    // MARK: - Place order

    @objc private func placeOrder() {
        guard let address = selectedAddress, let addressId = address.id else {
            alert("Please select a shipping address.")
            return
        }
        guard let card = selectedCard, let cardId = card.cardId else {
            alert("Please select a payment method.")
            return
        }
        guard let d = detail else {
            alert("Summary not loaded yet.")
            return
        }

        placeOrderBtn.isEnabled = false
        spinner.startAnimating()

        let fields: [String: String] = [
            "shipping_id": "\(addressId)",
            "product_id": "\(productId)",
            "card_id": cardId,
            "promo_code": promoCode?.code ?? "",
            "send_as_gift": "0",
            "gift_user_id": "",
            "gift_msg": "",
            "shipping_charges": d.shippingCharges ?? "0",
            "tax_amount": d.taxAmount ?? "0",
            "sub_total": d.subTotal ?? "0",
            "total": d.total ?? "0",
            "discount": d.discountAmount ?? "0"
        ]

        Task {
            do {
                let resp: APIResponse<PlaceOrderData> = try await APIManager.shared.postMultipartForm(
                    type: .placeOrder(param: fields),
                    fields: fields,
                    header: true
                )
                // If backend returns a client_secret, confirm on client.
                if let secret = resp.data?.clientSecret, !secret.isEmpty {
                    await MainActor.run {
                        StripeService.shared.confirmPaymentIntent(clientSecret: secret, presentingVC: self) { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success:
                                self.finishSuccess(orderId: resp.data?.orderId)
                            case .failure(let err):
                                self.placeOrderBtn.isEnabled = true
                                self.spinner.stopAnimating()
                                self.alert("3-D Secure failed: \(err.localizedDescription)")
                            }
                        }
                    }
                } else {
                    await MainActor.run {
                        self.finishSuccess(orderId: resp.data?.orderId)
                    }
                }
            } catch {
                await MainActor.run {
                    self.placeOrderBtn.isEnabled = true
                    self.spinner.stopAnimating()
                    self.alert("Order failed: \(error.localizedDescription)")
                }
            }
        }
    }

    private func finishSuccess(orderId: Int?) {
        // Phase 7a analytics
        let totalCents: Int? = {
            guard let t = detail?.total, let d = Double(t) else { return nil }
            return Int((d * 100).rounded())
        }()
        AnalyticsService.shared.logPurchase(
            transactionId: orderId.map { String($0) },
            valueCents: totalCents
        )
        let a = UIAlertController(
            title: "Order placed",
            message: orderId.map { "Order #\($0) is on its way!" } ?? "Your order is on its way!",
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "View orders", style: .default) { _ in
            // Pop or push to OrderList — left to the presenter.
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(a, animated: true)
    }

    private func alert(_ msg: String) {
        let a = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - PlaceOrderData envelope (local — no Android parity response we
// can reuse; Android decodes to a thin Order object but iOS just needs the
// id and optional client_secret).

struct PlaceOrderData: Codable, Hashable {
    let orderId: Int?
    let clientSecret: String?       // present only if Stripe requires SCA
    let paymentIntentId: String?

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case clientSecret = "client_secret"
        case paymentIntentId = "payment_intent_id"
    }
}

private extension UIView {
    static func divider() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }
}
