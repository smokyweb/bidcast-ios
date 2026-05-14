//
//  OrderProductCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

struct OrderProductCardView: View {
    var order: MyOrderModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
//                AsyncImage(url: URL(string: order?.product?.images?.first ?? "")) { image in
//                    image.resizable()
//                }placeholder: {
//                    Color.gray.opacity(0.3)
//                }
//                .frame(width: 60, height: 60)
//                .cornerRadius(8)
//
//
                CustomProfileImage(url: order?.product?.images?.first ?? "", isCircular: false, size: 70)
                VStack(alignment: .leading, spacing: 4) {
                    Text(order?.product?.title?.capitalizingFirstLetter() ?? "")
                        .font(.custom(poppinsSemiBold, size: 16.0))
                        .foregroundColor(.black)
                    Text(order?.product?.description?.capitalizingFirstLetter() ?? "")
                        .font(.custom(poppinsRegular, size: 13.0))
                        .foregroundColor(.darkGray)
                }
            }

            Divider()

            VStack(spacing: 6) {
                InfoRow(label: "Order ID", value: "\(order?.orderID ?? "")")
                InfoRow(label: "Order Date", value: order?.createdAt?.formattedDate() ?? "N/A")
                InfoRow(label: "Buyer", value: "\(order?.user?.name ?? "")")
                InfoRow(label: "Quantity", value: "\(order?.product?.purchasedQuantity ?? "0")")
                InfoRow(label: "Category", value: "\(order?.product?.category?.name ?? "")")
            }
//            .font(.subheadline)
            .foregroundColor(.gray)

            // MC sub-task cmp4933lh00l93mx16gbj10ye (Trey 2026-05-13):
            // when viewing the receipt/order, show an itemized price breakdown
            // (subtotal, shipping, tax, total) — not just the order metadata.
            // The transaction payload on MyOrderModel carries these values.
            if let txn = order?.transaction?.first, hasAnyAmount(txn) {
                Divider()
                VStack(spacing: 6) {
                    if let sub = txn.subTotal, sub > 0 {
                        InfoRow(label: "Subtotal", value: formatCurrency(sub))
                    }
                    if let ship = txn.shippingCharges, ship > 0 {
                        InfoRow(label: "Shipping", value: formatCurrency(Double(ship)))
                    }
                    if let tax = txn.taxAmount, tax > 0 {
                        InfoRow(label: "Tax", value: formatCurrency(tax))
                    }
                    if let discount = txn.discount, discount > 0 {
                        InfoRow(label: "Discount", value: "-" + formatCurrency(Double(discount)))
                    }
                    Divider()
                    InfoRow(label: "Total", value: txn.total.flatMap { Double($0) }.map(formatCurrency) ?? (txn.total ?? "--"))
                }
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    struct InfoRow: View {
        var label: String
        var value: String

        var body: some View {
            HStack {
                Text(label)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.darkGray)
                Spacer()
                Text(value)
                    .font(.custom(poppinsBold, size: 13.0))
                    .foregroundColor(.black)
            }
        }
    }

    // MC sub-task cmp4933lh00l93mx16gbj10ye helper: skip the breakdown card if
    // the transaction is empty of all amount fields (avoids an awkward empty
    // divider on legacy orders that pre-date the line-item changes).
    private func hasAnyAmount(_ t: TransactionModel) -> Bool {
        if let v = t.subTotal, v > 0 { return true }
        if let v = t.taxAmount, v > 0 { return true }
        if let v = t.shippingCharges, v > 0 { return true }
        if let v = t.discount, v > 0 { return true }
        if let s = t.total, !s.isEmpty, s != "0", s != "0.0", s != "0.00" { return true }
        return false
    }

    private func formatCurrency(_ amount: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = .current
        return f.string(from: NSNumber(value: amount)) ?? String(format: "$%.2f", amount)
    }
}
