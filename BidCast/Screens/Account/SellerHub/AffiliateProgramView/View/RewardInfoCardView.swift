//
//  RewardInfoCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct RewardInfoCardView: View {
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "dollarsign.circle").foregroundColor(.green))

            VStack(alignment: .leading, spacing: 4) {
                Text("Earn $100 Reward")
                    .font(.headline)
                Text("When your referral makes their first sale")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    RewardInfoCardView()
}
