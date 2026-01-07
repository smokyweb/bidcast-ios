//
//  CardSelectionSheet.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 07/01/26.
//

import Foundation
import SwiftUI

struct CardSelectionSheet: View {
    
    var cardArr: [CardDataModel]
    var initialIndex: Int
    var onSelect: (Int) -> Void

    @Environment(\.presentationMode) private var presentationMode
    @State private var selectedIndex: Int?

    var body: some View{
        VStack(spacing: 16) {
            
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 8)
            
            Text("Select Payment Method")
                .font(.custom(poppinsSemiBold, size: 16))
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(cardArr.indices, id: \.self) { index in
                        CardSelectionRow(
                            card: cardArr[index],
                            isSelected: selectedIndex == index
                        ) {
                            selectedIndex = index
                        }
                    }
                }
                .padding()
            }
            
            selectButton
        }
        .presentationDetents([.medium])
        .onAppear {
            selectedIndex = initialIndex
        }
    }
    private var selectButton: some View {
            Button {
                if let selectedIndex {
                    onSelect(selectedIndex)
                }
            } label: {
                Text("Continue")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        selectedIndex == nil
                        ? Color.gray.opacity(0.4)
                        : Color.defaultTheme
                    )
                    .cornerRadius(30)
            }
            .disabled(selectedIndex == nil)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
}

struct CardSelectionRow: View {

    let card: CardDataModel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("**** **** **** \(card.last4 ?? "")")
                        .font(.custom(poppinsSemiBold, size: 14))

                    Text("\(card.expYear ?? 0)/\(card.expMonth ?? 0)")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.defaultTheme)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.backGround)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.defaultTheme : Color.gray.opacity(0.3),
                        lineWidth: 1.5
                    )
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
