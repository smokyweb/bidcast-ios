//
//  PayoutRowView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUI

struct PayoutRowView: View {
    var payout: PayOutHistoryModel?
    var currencySymbol: String? = "$"
    
    var dateString: String {
        "\(payout?.createdAt?.formattedDate() ?? "N/A")"
    }
    var amountString: String {
        if let amount = Double(payout?.total ?? "0.0") {
            let formatted = String(format: "%.2f", amount)
            return "\(currencySymbol ?? "")" + formatted
        }
        return "\(currencySymbol ?? "")" + "0.0"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(amountString)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                Text(dateString)
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
