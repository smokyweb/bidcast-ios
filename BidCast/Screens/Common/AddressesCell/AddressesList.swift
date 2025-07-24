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
                Text(address.type?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsBold, size: 13.0))
//                    .padding(.horizontal, 2)
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
                    Button(action: {
                       
                        onTapDefault()
                    }){
                        Text("Set as default")
                            .font(.custom(poppinsSemiBold, size: 11))
                    }
                    
                    Button(role: .destructive, action: {
                     
                        onTapDelete()
                    }){
                        Text("Delete")
                            .font(.custom(poppinsSemiBold, size: 11))
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }

            Text(address.name?.capitalizingFirstLetter() ?? "")
                .font(.custom(poppinsSemiBold, size: 13.0))

            Text(address.street_address?.capitalizingFirstLetter() ?? "")
                .font(.custom(poppinsRegular, size: 13.0))

            Text(address.pincode ?? "")
                .font(.custom(poppinsRegular, size: 13.0))

            Text(address.phone_number ?? "")
                .font(.custom(poppinsRegular, size: 13.0))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
//        .padding(.horizontal)
    }
}
