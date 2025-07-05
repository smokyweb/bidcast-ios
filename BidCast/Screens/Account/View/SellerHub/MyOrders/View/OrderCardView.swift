//
//  OrderCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUICore
import SwiftUI

// MARK: - Order Card View
struct OrderCardView: View {
    let order: MyOrderModel?
    var statusColor: Color {
            switch order?.status {
            case "Processing": return .darkGreen
            case "NewOrder": return .darkBlue
            case "Completed": return .darkYellow
            default: return .gray
            }
        }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order?.orderID ?? "")
                    .fontWeight(.semibold)
                Spacer()
                Text(order?.status ?? "")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(10)
            }

            Text(formatDateTime(order?.product?.createdAt))
                .font(.custom(poppinsSemiBold, size: 13.0))
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                AsyncImage(url: URL(string: order?.product?.images?.first ?? "")) { image in
                    image.resizable()
                }placeholder: {
                    Color.gray.opacity(0.3)
                }
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(order?.product?.title?.capitalizingFirstLetter() ?? "")
                        .font(.custom(poppinsSemiBold, size: 14.0))
                    Text(order?.product?.description ?? "")
                        .font(.custom(poppinsRegular, size: 13.0))
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Text("Order Amount")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(order?.product?.pricing ?? 0)")
                    .font(.custom(poppinsSemiBold, size: 13.0))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}


