//
//  MakeOfferBottomSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct MakeOfferBottomSheet: View {
    @Binding var isPresented: Bool
    var listedPrice: Double
    var offerOptions: [Double]
    var onSendOffer: (Double?) -> Void
    @State var discountedPrice : Double?
    @State private var selectedOffer: Double?
    @State private var customOffer: String = ""
    var enteredText : (String) -> () = { _ in}

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Make an Offer")
                    .font(.headline)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .imageScale(.medium)
                }
            }

            Divider()

            // Listed Price
            HStack {
                Text("Listed Price")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)
                Spacer()
                Text("$\(Int(listedPrice))")
                    .font(.custom(poppinsSemiBold, size: 13.0))
            }

            // Offer Options
            LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
                ForEach(offerOptions, id: \.self) { offer in
                    let discount = Int(100 - (offer / listedPrice * 100))
                    Button {
                        selectedOffer = offer
                        customOffer = "\(discount)"
                        discountedPrice = Double(discount)
                        
                    } label: {
                        VStack {
                            Text("$ \(Int(offer))  off")
                                .font(.custom(poppinsBold, size: 14.0))
                                .foregroundColor(.red)
                            Text("$ \(discount)")
                                .font(.custom(poppinsSemiBold, size: 12.0))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedOffer == offer ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: selectedOffer == offer ? 2 : 1)
                        )
                    }
                }
            }

            // Custom Offer Input
            VStack(spacing: 8) {
                HStack {
                    Text("Custom Offer")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    Spacer()
                }
                TextField("Enter your own amount", text: $customOffer)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onChange(of: customOffer) { newValue in
                                            enteredText(newValue)
                                            selectedOffer = nil // Unselect preset if custom entered
                                        }
            }

            // Info note
            HStack(spacing: 8) {
                Image(systemName: "creditcard")
                    .foregroundColor(.gray)
                Text("You won't be charged unless the seller accepts your offer")
                    .font(.custom(poppinsRegular, size: 11.0))
                    .foregroundColor(.gray)
            }
            .padding(.top)

            // Send Offer Button
            Button {
                let offerValue = Double(customOffer) ?? selectedOffer
                onSendOffer(offerValue)
                isPresented = false
            } label: {
                Text("Send Offer")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.defaultTheme)
                    .cornerRadius(20)
            }

        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        
    }
}
