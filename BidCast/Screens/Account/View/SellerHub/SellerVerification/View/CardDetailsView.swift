//
//  CardDetailsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 12/06/25.
//

import SwiftUI

struct CardDetailsView: View {
    let card: CardDetails

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black)
                .frame(height: 180)
                .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 16) {
                Text("BANK NAME")
                    .foregroundColor(.gray)
                    .font(.subheadline.bold())

                Text("\(card.last4 ?? "----")")
                    .foregroundColor(.white)
                    .font(.title2)
                    .bold()

                Text("Enter Name") // Optional: Replace with actual name if available
                    .foregroundColor(.gray)
                    .font(.subheadline)

                HStack {
                    Text("CVV")
                        .foregroundColor(.gray)
                        .font(.subheadline)

                    Spacer()

                    Text(expiryText(month: card.expMonth, year: card.expYear))
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
            .padding()
        }
        .padding(.horizontal)
    }

    private func expiryText(month: Int?, year: Int?) -> String {
        let m = String(format: "%02d", month ?? 0)
        let y = String(format: "%02d", (year ?? 2000) % 100)
        return "\(m)/\(y)"
    }
}
