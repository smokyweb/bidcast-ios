//
//  ShippingStatusView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

struct ShippingStatusView: View {
    var order: MyOrderModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "truck.box.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.defaultTheme)
                Text("Shipping Updates")
                    .font(.custom(poppinsSemiBold, size: 16.0))
                    .foregroundColor(.black)
                
            }

            VStack(alignment: .leading, spacing: 24) {
                if let shippingTracking = order?.shippingTracking {
                    ForEach(shippingTracking, id: \.id) { track in
                        ShippingStepView(
                            icon: "checkmark.circle.fill",
                            title: track.title?.capitalizingFirstLetter() ?? "",
                            subtitle: track.createdAt?.formattedDate(toFormat: "MMM dd, yyyy") ?? "N/A",
                            iconColor: .defaultTheme
                        )
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
    }
}
