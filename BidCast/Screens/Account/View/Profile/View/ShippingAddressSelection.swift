//
//  ShippingAddressSelection.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 07/01/26.
//

import Foundation
import SwiftUI

struct ShippingAddressSelectionSheet: View {

    var addressArr: [AddressModel]
    var initialSelectedId: Int?
    var onSelect: (AddressModel) -> Void

    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedAddress: AddressModel?

    var body: some View {
        VStack(spacing: 16) {

            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)

            Text("Select Shipping Address")
                .font(.custom(poppinsSemiBold, size: 16))

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(addressArr, id: \.id) { address in
                        Button {
                            selectedAddress = address
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(address.name ?? "")
                                    .font(.custom(poppinsSemiBold, size: 14))

                                Text("\(address.street_address ?? "")")
                                    .font(.custom(poppinsRegular, size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.backGround)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedAddress?.id == address.id
                                        ? Color.defaultTheme
                                        : Color.gray.opacity(0.3),
                                        lineWidth: 1.5
                                    )
                            )
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }

            Button {
                if let selectedAddress {
                    onSelect(selectedAddress)
//                    dismiss()
//                    self.presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Continue")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        selectedAddress == nil
                        ? Color.gray.opacity(0.4)
                        : Color.defaultTheme
                    )
                    .cornerRadius(30)
            }
            .disabled(selectedAddress == nil)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .presentationDetents([.medium, .large])
        .onAppear {
            selectedAddress = addressArr.first { $0.id == initialSelectedId }
        }
    }
}
