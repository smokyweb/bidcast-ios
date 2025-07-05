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
                    .font(.custom(poppinsSemiBold, size: 13.0))
                Text(dateString ?? "")
                    .font(.custom(poppinsRegular, size: 13.0))
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(payout?.status ?? "")
                .font(.custom(poppinsRegular, size: 13.0))
                .foregroundColor(.green)   // adjust per-status if needed
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
