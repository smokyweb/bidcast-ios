//
//  DeliveryAddressView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

struct DeliveryAddressView: View {
    var order : MyOrderModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Delivery Address", systemImage: "mappin.and.ellipse")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text(order?.shippingAddress ?? "")
            }
            .font(.subheadline)

            HStack {
                Spacer()
//                Image(systemName: "viewfinder")
//                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}
