//
//  OrderStatusScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

import SwiftUI

struct OrderStatusScreen: View {
    @Environment(\.presentationMode) var presentationMode
    var order: OrderModel?

    var body: some View {
        VStack(spacing: 0) {
            // ✅ Custom Header
            PrimaryHeader(
                title: "Order Status",
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(Color.white)
            .frame(height: 50)

            ScrollView {
                VStack(spacing: 24) {
                    // 📦 Preparing Icon
                    VStack(spacing: 8) {
                        Image(systemName: "shippingbox.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.red)

                        Text("Preparing Your Order")
                            .font(.title3).bold()

                        Text("The seller is preparing your package for shipping")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)

                    // 📦 Product Details
                    if let order = order {
                        OrderProductCardView(order: order)
                        ShippingStatusView(order: order)
                        DeliveryAddressView(order: order)
                    }

                    // 📃 Equal Width Buttons
                    HStack(spacing: 16) {
                        GeometryReader { geometry in
                            HStack(spacing: 16) {
                                OutlinedButtonView(title: "Receipt")
                                    .frame(width: (geometry.size.width - 16) / 2)
                                OutlinedButtonView(title: "Shipping Details")
                                    .frame(width: (geometry.size.width - 16) / 2)
                            }
                        }
                        .frame(height: 44)
                    }
                    .padding(.vertical, 8)

                    // 🛡️ Buyer Protection
                    BuyerProtectionView()

                    Spacer()
                }
                .padding()
            }

            // 🔙 Home Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Home")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
        .background(Color(red: 240/255, green: 247/255, blue: 255/255).ignoresSafeArea())
    }
}

struct OrderModel {
    var id: String
    var date: String
    var productName: String
    var productColor: String
    var seller: String
    var quantity: Int
    var category: String
    var address: String
    var cityStateZip: String
}

struct ShippingStepView: View {
    var icon: String
    var title: String
    var subtitle: String
    var iconColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
        }
    }
}


