//
//  OrderCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUI

// MARK: - Order Card View
struct OrderCardView: View {
    let order: MyOrderModel?
    var statusColor: Color {
            switch order?.status {
            case "Processing": return .darkBlue.opacity(0.5)
            case "NewOrder": return .darkBlue.opacity(0.5)
            case "Completed", "Delivered": return .green.opacity(0.5)
            default: return .gray.opacity(0.4)
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
                    .background(statusColor.opacity(0.5))
                    .foregroundColor(statusColor)
                    .cornerRadius(10)
            }

            Text(order?.product?.createdAt?.formattedDateAndTimeString() ?? "N/A")                .font(.custom(poppinsSemiBold, size: 13.0))
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                CustomProfileImage(url: order?.product?.images?.first ?? "",isCircular: true,size: 40)
//                AsyncImage(url: URL(string: order?.product?.images?.first ?? "")) { image in
//                    image
//                        .resizable()
//                } placeholder: {
//                    Color.gray
//                        .opacity(0.3)
//                        .shimmer() // ✨ Apply shimmer here
//                }
//                .scaledToFill()
//                .frame(width: 40, height: 40)
//                .clipShape(Circle())
//                .overlay(
//                    Circle()
//                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                )
//                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                
                VStack(alignment: .leading) {
                    Text(order?.product?.title?.capitalizingFirstLetter() ?? "")
                        .font(.custom(poppinsSemiBold, size: 14.0))
                    Text(order?.product?.description ?? "")
                        .font(.custom(poppinsRegular, size: 13.0))
                        .foregroundColor(.gray)
                }
            }
            Divider()
                .padding(.vertical, 4)
            HStack {
                Text("Order Amount")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(Double(order?.product?.pricing ?? 0), specifier: "%.2f")")
                    .font(.custom(poppinsSemiBold, size: 13.0))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
    }
}


