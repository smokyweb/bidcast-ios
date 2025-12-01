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
                    Text(order?.product?.title ?? "")
                        .font(.headline)
                    Text(order?.product?.description ?? "")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }

            Divider()

            VStack(spacing: 6) {
                InfoRow(label: "Order ID", value: "\(order?.orderID ?? "")")
                InfoRow(label: "Order Date", value: order?.product?.createdAt?.formattedDateAndTimeString() ?? "N/A")
                InfoRow(label: "Sold By", value: "\(order?.user?.name ?? "")")
                InfoRow(label: "Quantity", value: "\(order?.product?.purchasedQuantity ?? "0")")
                InfoRow(label: "Category", value: "\(order?.product?.category?.name ?? "")")
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
