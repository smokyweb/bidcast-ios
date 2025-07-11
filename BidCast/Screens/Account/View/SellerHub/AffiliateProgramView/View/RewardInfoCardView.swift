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
                .fill(Color.darkGreen.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "dollarsign.circle").foregroundColor(.darkGreen))

            VStack(alignment: .leading, spacing: 4) {
                Text("Earn $100 Reward")
                    .font(.custom(poppinsSemiBold, size: 14.0))
                Text("When your referral makes their first sale")
                    .font(.custom(poppinsRegular, size: 11.0))
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
