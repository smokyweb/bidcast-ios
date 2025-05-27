//
//  OrderCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUICore

// MARK: - Order Card View
struct OrderCardView: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.orderNumber)
                    .fontWeight(.semibold)
                Spacer()
                Text(order.status)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(order.statusColor.opacity(0.2))
                    .foregroundColor(order.statusColor)
                    .cornerRadius(10)
            }

            Text(order.date)
                .font(.caption)
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                order.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(order.name)
                        .fontWeight(.semibold)
                    Text(order.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Text("Order Amount")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(order.amount)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}


