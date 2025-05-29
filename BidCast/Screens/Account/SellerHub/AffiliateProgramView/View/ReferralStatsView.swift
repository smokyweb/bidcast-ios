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
            Text("Your Referral Stats")
                .font(.headline)

            HStack {
                VStack {
                    Text("\(stats.totalReferrals)")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.red)
                    Text("Total Referrals")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack {
                    Text("$\(Int(stats.earnings))")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.red)
                    Text("Earnings")
                        .font(.caption)
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

