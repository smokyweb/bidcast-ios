//
//  OrderProductCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

struct OrderProductCardView: View {
    var order: OrderModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image("headphones")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.productName)
                        .font(.headline)
                    Text(order.productColor)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }

            Divider()

            VStack(spacing: 6) {
                InfoRow(label: "Order ID", value: "#\(order.id)")
                InfoRow(label: "Order Date", value: order.date)
                InfoRow(label: "Sold By", value: order.seller)
                InfoRow(label: "Quantity", value: "\(order.quantity)")
                InfoRow(label: "Category", value: order.category)
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
