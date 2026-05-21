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
                // MC task cmpfposve (Larry 2026-05-21):
                // Move "Item Title" above "Order ID" so the buyer sees what the
                // order is before the order number. Item Title was originally
                // added below Category by cmpfga4ni; Larry now wants it as the
                // first row.
                InfoRow(label: "Item Title", value: order?.product?.title?.capitalizingFirstLetter() ?? "")
                InfoRow(label: "Order ID", value: "\(order?.orderID ?? "")")
                InfoRow(label: "Order Date", value: order?.createdAt?.formattedDate() ?? "N/A")
                InfoRow(label: "Buyer", value: "\(order?.user?.name ?? "")")
                InfoRow(label: "Quantity", value: "\(order?.product?.purchasedQuantity ?? "0")")
                InfoRow(label: "Category", value: "\(order?.product?.category?.name ?? "")")
                // Itemized pricing block (MC task cmpfga4ni) — stays grouped
                // below the order metadata so the totals appear together.
                InfoRow(label: "Cost", value: itemCostDisplay())
                InfoRow(label: "Taxes", value: formatCurrency(order?.transaction?.first?.taxAmount ?? 0))
                InfoRow(label: "Shipping", value: formatCurrency(Double(order?.transaction?.first?.shippingCharges ?? 0)))
                InfoRow(label: "Total", value: totalCostDisplay())
            }
//            .font(.subheadline)
            .foregroundColor(.gray)
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

    // MC task cmpfga4ni helper: "Cost" = item cost the buyer paid for the
    // product itself (pre-tax/pre-shipping). Backend transaction.sub_total is
    // the canonical value; fall back to transaction.product_price, then to the
    // product's own pricing string so legacy/incomplete payloads still render.
    private func itemCostDisplay() -> String {
        if let sub = order?.transaction?.first?.subTotal, sub > 0 {
            return formatCurrency(sub)
        }
        if let price = order?.transaction?.first?.productPrice, price > 0 {
            return formatCurrency(Double(price))
        }
        if let pricing = order?.product?.pricing, let val = Double(pricing) {
            return formatCurrency(val)
        }
        return formatCurrency(0)
    }

    // MC task cmpfga4ni helper: prefer the server-computed total string (it
    // already includes tax + shipping - discount), otherwise sum locally.
    private func totalCostDisplay() -> String {
        if let s = order?.transaction?.first?.total, let v = Double(s), v > 0 {
            return formatCurrency(v)
        }
        let sub = order?.transaction?.first?.subTotal ?? 0
        let tax = order?.transaction?.first?.taxAmount ?? 0
        let ship = Double(order?.transaction?.first?.shippingCharges ?? 0)
        let disc = Double(order?.transaction?.first?.discount ?? 0)
        return formatCurrency(max(0, sub + tax + ship - disc))
    }

    private func formatCurrency(_ amount: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = .current
        return f.string(from: NSNumber(value: amount)) ?? String(format: "$%.2f", amount)
    }
}
