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
}
