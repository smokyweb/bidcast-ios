//
//  PayoutRowView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUI

struct PayoutRowView: View {
    var payout: Payout?
    var currencySymbol: String? = ""
    
    var dateString: String? = ""
    var amountString: String {
        "\(currencySymbol ?? "")" + String(format: "%,.2f", payout?.amount ?? 0.0)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(amountString)
                    .fontWeight(.semibold)
                Text(dateString ?? "")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(payout?.status ?? "")
                .font(.footnote)
                .foregroundColor(.green)   // adjust per-status if needed
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
