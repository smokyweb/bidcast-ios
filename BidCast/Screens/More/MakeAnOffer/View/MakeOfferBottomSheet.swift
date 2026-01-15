//
//  MakeOfferBottomSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
struct MakeOfferBottomSheet: View {

    @Binding var isPresented: Bool
    let listedPrice: String
    let offerOptions: [Double]
    let onSendOffer: (Double?) -> Void
    var enteredText: (String) -> Void = { _ in }

    @State private var selectedOffer: Double? = nil
    @State private var customOffer: String = ""

    private var listedPriceDouble: Double {
        Double(listedPrice) ?? 0
    }

    var body: some View {
        VStack(spacing: 12) {

            PrimarySheetHeader(title: "Make an Offer") {
                isPresented = false
            }

            listedPriceRow
            offerGrid
            customOfferField
            infoNote
            sendButton
        }
        .padding(.horizontal, 16)
        .background(Color.backGround)
    }
    
    private var offerGrid: some View {
        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 12) {
            ForEach(offerOptions, id: \.self) { offer in
                OfferOptionCard(
                    offer: offer,
                    discountedPrice: listedPriceDouble - offer,
                    isSelected: selectedOffer == offer
                ) {
                    selectOffer(offer)
                }
            }
        }
    }
    private func selectOffer(_ offer: Double) {
        selectedOffer = offer
        customOffer = String(format: "%.0f", listedPriceDouble - offer)
    }

    private var customOfferField: some View {
        AuthTextField(
            floatingLabel: "Custom Offer",
            placeholder: "Enter your own amount",
            icon: .menuProfile,
            text: $customOffer,
            isIconDisplay: false,
            isForPrice:true,
            custFontName: robotoMedium,
            custFontSize: 14
        ) { value in
            enteredText(value)
        }
        .keyboardType(.numberPad)
        .onChange(of: customOffer) { newValue in
            if let selected = selectedOffer,
               newValue != String(format: "%.0f", listedPriceDouble - selected) {
                selectedOffer = nil
            }
        }
        .padding(.horizontal,-12)
    }

    private var infoNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "creditcard")
                .foregroundColor(.darkGray)
            Text("You won't be charged unless the seller accepts your offer")
                .font(.custom(poppinsRegular, size: 11))
                .foregroundColor(.darkGray)
        }
        .padding(.top)
    }
    private var sendButton: some View {
        PrimaryButton(title: "Send Offer") {
            let value = Double(customOffer) ?? selectedOffer
            onSendOffer(value)
            isPresented = false
        }
    }

    private var listedPriceRow: some View {
        HStack {
            Text("Listed Price")
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(.black)

            Spacer()

            Text(listedPriceDouble.compactCurrency())
                .font(.custom(poppinsSemiBold, size: 13))
        }
    }

}

import SwiftUI

struct OfferOptionCard: View {
    let offer: Double
    let discountedPrice: Double
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                Text("$\(Int(offer)) off")
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(isSelected ? .white : .defaultTheme)

                Text("$\(Int(discountedPrice))")
                    .font(.custom(poppinsSemiBold, size: 12))
                    .foregroundColor(isSelected ? .white : .darkGray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.defaultTheme : Color.defaultThemeLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.clear : Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
