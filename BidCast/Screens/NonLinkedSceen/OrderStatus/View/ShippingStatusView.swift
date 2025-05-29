//
//  ShippingStatusView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

struct ShippingStatusView: View {
    var order: OrderModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "truck")
                    .foregroundColor(.red)
                Text("Shipping Updates")
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(spacing: 24) {
                ShippingStepView(
                    icon: "checkmark.circle.fill",
                    title: "Order Confirmed",
                    subtitle: "\(order.date) - 10:30 AM",
                    iconColor: .red
                )

                ShippingStepView(
                    icon: "circle.dashed",
                    title: "Preparing Package",
                    subtitle: "In Progress",
                    iconColor: .red
                )
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
    }
}
