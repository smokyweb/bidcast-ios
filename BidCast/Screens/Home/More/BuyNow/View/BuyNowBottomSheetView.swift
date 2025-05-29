//
//  NotifyMeBottomSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct BuyNowBottomSheetView: View {
    @Binding var isPresented: Bool
    @State private var isGift = false
    @State private var promoCode = ""
    
    var productImage: Image
    var productTitle: String
    var productColor: String
    var cardLastDigits: String
    var shippingAddress: String
    var subtotal: Double
    var shipping: Double
    var tax: Double
    var onConfirmPurchase: () -> Void

    var total: Double {
        subtotal + shipping + tax
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Buy Now")
                        .font(.title3.bold())
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                    }
                }
                Divider()

                // Product Info
                HStack(spacing: 12) {
                    productImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 56, height: 56)
                        .cornerRadius(8)
                    VStack(alignment: .leading) {
                        Text(productTitle).font(.headline)
                        Text(productColor).font(.subheadline).foregroundColor(.gray)
                    }
                    Spacer()
                }
                Divider()

                // Gift Toggle
                HStack {
                    Label("Send as a gift?", systemImage: "gift")
                    Spacer()
                    Toggle("", isOn: $isGift)
                        .labelsHidden()
                }
                .padding(.vertical, 8)
                Divider()

                // Payment Method
                HStack {
                    VStack(alignment: .leading) {
                        Text("Payment Method").font(.subheadline.bold())
                        HStack {
                            Image("visa") // Replace with actual asset if needed
                                .resizable()
                                .frame(width: 32, height: 20)
                            Text("•••• \(cardLastDigits)")
                        }
                    }
                    Spacer()
                    Button("Change") {}.foregroundColor(.red)
                }
                Divider()

                // Shipping Address
                HStack {
                    VStack(alignment: .leading) {
                        Text("Shipping Address").font(.subheadline.bold())
                        Text(shippingAddress).font(.subheadline)
                    }
                    Spacer()
                    Button("Change") {}.foregroundColor(.red)
                }
                Divider()

                // Promo Code
                TextField("Enter promo code", text: $promoCode)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                Divider()

                // Summary
                VStack(spacing: 4) {
                    SummaryRow(label: "Subtotal", value: subtotal)
                    SummaryRow(label: "Shipping", value: shipping)
                    SummaryRow(label: "Tax", value: tax)
                    Divider()
                    SummaryRow(label: "Total", value: total, isBold: true)
                }

                // Confirm Button
                Button(action: onConfirmPurchase) {
                    Text("Confirm Purchase")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

}

struct SummaryRow: View {
    var label: String
    var value: Double
    var isBold: Bool = false

    var body: some View {
        HStack {
            Text(label).font(isBold ? .headline : .subheadline)
            Spacer()
            Text(String(format: "$%.2f", value))
                .font(isBold ? .headline : .subheadline)
        }
    }
}
