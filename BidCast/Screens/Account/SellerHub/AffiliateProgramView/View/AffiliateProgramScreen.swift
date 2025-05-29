//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//
import SwiftUI

// MARK: - ReferralStats
struct ReferralStats {
    var totalReferrals: Int
    var earnings: Double
}

// MARK: - AffiliateProgramScreen
struct AffiliateProgramScreen: View {
    @Environment(\.presentationMode) var presentationMode
    var referralCode: String
    var stats: ReferralStats
    var onShare: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            PrimaryHeader(
                title: "Affiliate Program",
                leadingImgArr: [.icBack],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 50)
            .background(Color.white)
            .zIndex(1) // ensures it stays on top

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Earn $100 Per Referral")
                            .font(.title2)
                            .bold()
                        Text("Invite sellers and earn rewards when they succeed")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    ReferralCodeCardView(code: referralCode, onShare: onShare)

                    RewardInfoCardView()

                    ReferralStatsView(stats: stats)
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Preview
struct AffiliateProgramView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AffiliateProgramScreen(
                referralCode: "SELLER2025",
                stats: ReferralStats(totalReferrals: 0, earnings: 0.0),
                onShare: {
                    print("Share link tapped")
                }
            )
        }
    }
}
