//
//  AddressesList.swift
//  BidCast
//
//  Created by JAM_E_329 on 21/05/25.
//
import SwiftUI
import StripeUICore

struct AddressListCell: View {
    var address: Address

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(address.type)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)

                Spacer()

                Menu {
                    Button("Make Default", action: { print("Make Default for \(address.name)") })
                    Button("Delete", role: .destructive, action: { print("Delete \(address.name)") })
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }

            Text(address.name)
                .font(.headline)

            Text(address.house)
                .font(.subheadline)

            Text(address.country)
                .font(.subheadline)

            Text(address.mobile)
                .font(.subheadline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
