//
//  OrderProductCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

struct OrderProductCardView: View {
    var order:  ProductPurchaseModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AsyncImage(url: URL(string: order?.product?.images?.first ?? "")) { image in
                    image.resizable()
                }placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(order?.product?.title ?? "")
                        .font(.headline)
                    Text(order?.product?.description ?? "")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }

            Divider()

            VStack(spacing: 6) {
                InfoRow(label: "Order ID", value: "\(order?.product?.id ?? 0)")
                InfoRow(label: "Order Date", value: formatDateTime(order?.product?.createdAt))
                InfoRow(label: "Sold By", value: "\(order?.product?.userID ?? 0)")
                InfoRow(label: "Quantity", value: "\(order?.product?.purchasedQuantity ?? 0)")
                InfoRow(label: "Category", value: "\(order?.product?.categoryID ?? 0)")
            }
            .font(.subheadline)
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
                Spacer()
                Text(value).bold()
            }
        }
    }
}
