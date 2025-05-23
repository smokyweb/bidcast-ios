//
//  AddressesList.swift
//  BidCast
//
//  Created by JAM_E_329 on 21/05/25.
//
import SwiftUI
import StripeUICore

struct AddressListCell: View {
    var address: AddressModel
    var onTapDefault : () -> () = { }
    var onTapDelete : () -> () = { }
    var isDefault = false
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(address.type ?? "")
                    .font(.custom(poppinsBold, size: 13.0))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                if isDefault{
                    Text("Default")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .background(.lightBlue)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                Spacer()

                Menu {
                    Button("Make Default", action: {
                        print("Make Default for \(address.name ?? "")")
                        onTapDefault()
                    })
                    Button("Delete", role: .destructive, action: {
                        print("Delete \(address.name ?? "")")
                        onTapDelete()
                    })
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }

            Text(address.name ?? "")
                .font(.headline)

            Text(address.street_address ?? "")
                .font(.subheadline)

            Text(address.pincode ?? "")
                .font(.subheadline)

            Text(address.phone_number ?? "")
                .font(.subheadline)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
