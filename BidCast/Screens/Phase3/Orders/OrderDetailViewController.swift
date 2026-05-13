//
//  OrderDetailViewController.swift
//  BidCast — iOS parity Phase 3a (2026-04-22)
//
//  Shows a full order detail from the seed `Order` plus a freshly-fetched
//  `FetchOrderDetailResponse` (POST api/v1/get-order-details) so buyer sees
//  current status + shipping tracking + seller details.
//

import UIKit
import SVProgressHUD

final class OrderDetailViewController: UIViewController {

    private let initialOrder: Order
    private var detailData: FetchOrderDetailData?

    private let scroll = UIScrollView()
    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return s
    }()

    init(order: Order) {
        self.initialOrder = order
        super.init(nibName: nil, bundle: nil)
        self.title = "Order #\(order.orderId ?? "—")"
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNav()
        setupLayout()
        renderFromInitial()
        fetchDetail()
    }

    private func setupNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain, target: self, action: #selector(showActions))
    }

    private func setupLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])
    }

    private func renderFromInitial() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(headerCard(order: initialOrder))
        stack.addArrangedSubview(statusCard(order: initialOrder))
        if let product = initialOrder.product {
            stack.addArrangedSubview(productCard(product: product, qty: 1))
        }
        stack.addArrangedSubview(transactionCard(order: initialOrder))
    }

    private func fetchDetail() {
        SVProgressHUD.show()
        Task { @MainActor in
            defer { SVProgressHUD.dismiss() }
            do {
                let fields = ["order_id": "\(initialOrder.id ?? 0)"]
                let resp: FetchOrderDetailResponse = try await APIManager.shared.postMultipartForm(
                    type: .fetchOrderDetail(param: [:]),
                    fields: fields,
                    header: true
                )
                self.detailData = resp.data
                self.renderDetailed()
            } catch {
                // Keep the initial render. Silently skip — buyer still sees summary.
                debugLog("fetchOrderDetail error: \(error.localizedDescription)")
            }
        }
    }

    private func renderDetailed() {
        guard let d = detailData else { return }
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let order = d.order ?? initialOrder
        stack.addArrangedSubview(headerCard(order: order))
        stack.addArrangedSubview(statusCard(order: order))
        if let seller = d.sellerDetails {
            stack.addArrangedSubview(sellerCard(seller: seller, rating: d.ratingAvg, isFollowing: d.isFollowing ?? false))
        }
        if let addr = d.shippingAddress {
            stack.addArrangedSubview(addressCard(addr: addr))
        }
        if let product = order.product {
            stack.addArrangedSubview(productCard(product: product, qty: 1))
        }
        if let tracking = order.shippingTracking, !tracking.isEmpty {
            stack.addArrangedSubview(trackingCard(tracking: tracking))
        }
        stack.addArrangedSubview(transactionCard(order: order))
        stack.addArrangedSubview(actionButtons())
    }

    // MARK: - Card builders

    private func card() -> UIStackView {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 8
        s.isLayoutMarginsRelativeArrangement = true
        s.layoutMargins = .init(top: 14, left: 14, bottom: 14, right: 14)
        s.backgroundColor = .secondarySystemBackground
        s.layer.cornerRadius = 10
        return s
    }

    private func label(_ text: String, font: UIFont = .systemFont(ofSize: 14), color: UIColor = .label) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = color
        l.numberOfLines = 0
        return l
    }

    private func headerCard(order: Order) -> UIView {
        let s = card()
        s.addArrangedSubview(label("Order \(order.orderId ?? "—")",
                                   font: .systemFont(ofSize: 17, weight: .semibold)))
        s.addArrangedSubview(label("Placed: \(P3Format.date(order.createdAt))",
                                   font: .systemFont(ofSize: 13), color: .secondaryLabel))
        return s
    }

    private func statusCard(order: Order) -> UIView {
        let s = card()
        s.addArrangedSubview(label("Status",
                                   font: .systemFont(ofSize: 13), color: .secondaryLabel))
        s.addArrangedSubview(label((order.status ?? "—").capitalized,
                                   font: .systemFont(ofSize: 20, weight: .bold)))
        if let pct = order.orderStatusPercentage {
            let bar = UIProgressView(progressViewStyle: .bar)
            bar.progress = Float(pct) / 100.0
            bar.tintColor = .systemGreen
            s.addArrangedSubview(bar)
        }
        return s
    }

    private func productCard(product: WireProduct, qty: Int) -> UIView {
        let s = card()
        s.addArrangedSubview(label("Item", font: .systemFont(ofSize: 13),
                                   color: .secondaryLabel))
        s.addArrangedSubview(label(product.title ?? "Product",
                                   font: .systemFont(ofSize: 16, weight: .semibold)))
        if let price = product.pricing {
            s.addArrangedSubview(label("Price: \(P3Format.currency(price))"))
        }
        s.addArrangedSubview(label("Qty: \(qty)", font: .systemFont(ofSize: 13),
                                   color: .secondaryLabel))
        return s
    }

    private func sellerCard(seller: UserPublic, rating: String?, isFollowing: Bool) -> UIView {
        let s = card()
        s.addArrangedSubview(label("Seller", font: .systemFont(ofSize: 13),
                                   color: .secondaryLabel))
        let display = seller.name ?? [seller.firstName, seller.lastName].compactMap { $0 }.joined(separator: " ")
        s.addArrangedSubview(label(display.isEmpty ? (seller.username ?? "—") : display,
                                   font: .systemFont(ofSize: 16, weight: .semibold)))
        if let r = rating, !r.isEmpty {
            s.addArrangedSubview(label("★ \(r)", color: .systemOrange))
        }
        return s
    }

    private func addressCard(addr: ShippingAddress) -> UIView {
        let s = card()
        s.addArrangedSubview(label("Ship to", font: .systemFont(ofSize: 13),
                                   color: .secondaryLabel))
        var lines: [String] = []
        if let name = addr.name { lines.append(name) }
        if let street = addr.streetAddress { lines.append(street) }
        // MC sub-task cmp4932vk00l13mx1du6mmebo: render optional line 2.
        if let line2 = addr.addressLine2?.trimmingCharacters(in: .whitespaces), !line2.isEmpty {
            lines.append(line2)
        }
        let cityLine = [addr.city, addr.state, addr.pincode].compactMap { $0 }.joined(separator: ", ")
        if !cityLine.isEmpty { lines.append(cityLine) }
        s.addArrangedSubview(label(lines.joined(separator: "\n")))
        return s
    }

    private func trackingCard(tracking: [ShippingTracking]) -> UIView {
        let s = card()
        s.addArrangedSubview(label("Tracking", font: .systemFont(ofSize: 13),
                                   color: .secondaryLabel))
        for t in tracking {
            let row = label("• \(t.title ?? "—")  \(P3Format.date(t.createdAt))",
                            font: .systemFont(ofSize: 14))
            s.addArrangedSubview(row)
        }
        return s
    }

    private func transactionCard(order: Order) -> UIView {
        let s = card()
        s.addArrangedSubview(label("Payment", font: .systemFont(ofSize: 13),
                                   color: .secondaryLabel))
        guard let tx = order.transaction?.first else {
            s.addArrangedSubview(label("—"))
            return s
        }
        if let sub = tx.subTotal { s.addArrangedSubview(label("Subtotal: \(P3Format.currency(sub))")) }
        if let ship = tx.shippingCharges { s.addArrangedSubview(label("Shipping: \(P3Format.currency(ship))")) }
        if let tax = tx.taxAmount { s.addArrangedSubview(label("Tax: \(P3Format.currency(tax))")) }
        if let disc = tx.discount, disc > 0 {
            s.addArrangedSubview(label("Discount: -\(P3Format.currency(disc))", color: .systemGreen))
        }
        s.addArrangedSubview(label("Total: \(P3Format.currency(tx.total))",
                                   font: .systemFont(ofSize: 16, weight: .bold)))
        if let card = tx.cardNumber {
            s.addArrangedSubview(label("Card: •••• \(String(card.suffix(4)))",
                                       font: .systemFont(ofSize: 12), color: .secondaryLabel))
        }
        return s
    }

    private func actionButtons() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        let trackBtn = makeButton(title: "Track shipment")
        trackBtn.addTarget(self, action: #selector(openTracking), for: .touchUpInside)
        stack.addArrangedSubview(trackBtn)

        let returnBtn = makeButton(title: "Request return",
                                   style: .bordered, tint: .systemRed)
        returnBtn.addTarget(self, action: #selector(openReturn), for: .touchUpInside)
        stack.addArrangedSubview(returnBtn)

        let supportBtn = makeButton(title: "Raise support ticket", style: .bordered)
        supportBtn.addTarget(self, action: #selector(openSupport), for: .touchUpInside)
        stack.addArrangedSubview(supportBtn)

        return stack
    }

    enum ButtonStyle { case filled, bordered }
    private func makeButton(title: String,
                            style: ButtonStyle = .filled,
                            tint: UIColor = .systemBlue) -> UIButton {
        var cfg: UIButton.Configuration
        switch style {
        case .bordered:
            cfg = .bordered()
        case .filled:
            cfg = .filled()
        }
        cfg.baseBackgroundColor = tint
        cfg.cornerStyle = .medium
        cfg.title = title
        let btn = UIButton(configuration: cfg)
        return btn
    }

    @objc private func openTracking() {
        let tracking = initialOrder.shippingTracking ?? detailData?.order?.shippingTracking ?? []
        let vc = OrderTrackingViewController(tracking: tracking,
                                             orderId: initialOrder.orderId ?? "")
        p3Push(vc)
    }

    @objc private func openReturn() {
        let vc = ReturnRequestViewController(orderId: initialOrder.id ?? 0)
        p3Push(vc)
    }

    @objc private func openSupport() {
        let vc = RaiseTicketViewController(orderId: initialOrder.id ?? 0,
                                           productId: initialOrder.product?.id)
        p3Push(vc)
    }

    @objc private func showActions() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Track", style: .default, handler: { [weak self] _ in self?.openTracking() }))
        sheet.addAction(UIAlertAction(title: "Return", style: .default, handler: { [weak self] _ in self?.openReturn() }))
        sheet.addAction(UIAlertAction(title: "Contact seller", style: .default, handler: { [weak self] _ in self?.openSupport() }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
}
