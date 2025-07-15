//
//  ReferralStatsView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct ReferralStatsView: View {
    var stats: ReferralStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppString.YourReferralStatus)
                .font(.headline)

            HStack {
                VStack {
                    Text("\(stats.totalReferrals)")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.defaultTheme)
                    Text(AppString.TotalReferrals)
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack {
                    Text("$\(Int(stats.earnings))")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.defaultTheme)
                    Text(AppString.Earnings)
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

