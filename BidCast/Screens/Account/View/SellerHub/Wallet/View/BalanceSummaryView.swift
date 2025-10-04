//
//  BalanceSummaryView.swift
//  BidCast
//
//  Created by JamTech on 04/10/25.
//

import SwiftUI

struct BalanceSummaryView: View {
    
    let balance: Double
    let title: String
    
    // Currency formatting helper
    private func formatAmount(_ amount: Double?) -> String {
        guard let amount = amount else { return "0.0" }
        return String(format: "%.2f", amount)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(AppString.AvailableBalance)
                .font(.custom(poppinsRegular, size: 11.0))
                .foregroundColor(.gray)
            Text("$\(formatAmount(balance))")
                .font(.custom(poppinsSemiBold, size: 20.0))
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

#Preview {
    BalanceSummaryView(balance: 10.00, title: AppString.AvailableBalance)
}
