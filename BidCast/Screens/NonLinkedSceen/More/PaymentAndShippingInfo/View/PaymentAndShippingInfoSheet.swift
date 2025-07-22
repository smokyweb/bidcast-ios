//
//  PaymentAndShippingInfoSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 22/07/25.
//

import SwiftUI

struct PaymentAndShippingInfoSheet: View {
    @Binding var isPresented: Bool
    var onAddInfo: () -> Void
    @Binding var buttonText: String

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Drag indicator
                Capsule()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                // Title
                Text("To purchase in lives we need your payment and shipping info")
                    .font(.custom(poppinsSemiBold, size: 15))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Description
                Text("Welcome to BidSwipe! In order to bid on auctions you need to add a payment method and shipping address. All bids and purchases are final.")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Note
                Text("You won’t be charged until you purchase an item.")
                    .font(.custom(poppinsSemiBold, size: 13))
                    .foregroundColor(.purple)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Add Info Button
                Button(action: onAddInfo) {
                    HStack {
                        Image(systemName: "creditcard")
                        Text(buttonText)
                            .font(.custom(poppinsSemiBold, size: 15))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(16)
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.bottom, 32)
        }
        .background(Color.white)
    }
}
