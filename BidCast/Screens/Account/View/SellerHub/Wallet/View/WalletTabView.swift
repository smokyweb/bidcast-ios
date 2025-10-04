//
//  WalletTabView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUI

struct WalletTabView: View {
    
    var summary: WalletInfoModel
    var payouts: [Payout]
    
    @State private var showPayoutView = false
    
    // Currency formatting helper
    private func formatAmount(_ amount: Double?) -> String {
        guard let amount = amount else { return "0.0" }
        return String(format: "%.2f", amount)
    }
    
    private func formatDoubleAmount(_ amount: Double?) -> String {
        guard let amount = amount else { return "0.0" }
        return String(format: "%.2f", amount)
    }
    
    @State var categoryList: [CategoryDataModel] = [
        CategoryDataModel(id: 1, name: AppString.EarlyPayout, image: "electronics_icon", color: "#FF5733")
    ]
    
    var body: some View {
        ScrollView {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    BalanceSummaryView(balance: summary.avaiableBalance ?? 0.0,
                                       title: AppString.AvailableBalance)
                    
                    HStack(spacing: 12) {
                        WalletStatTile(
                            title: AppString.avaialbelForPayOut.localized,
                            value: formatAmount(Double(summary.avaiableForPayout ?? 0)),
                            iconName: "arrow.up.arrow.down"
                        )
                        WalletStatTile(
                            title: AppString.Processing.localized,
                            value: formatAmount(summary.processing),
                            iconName: "lock.rotation"
                        )
                    }
                    
                    VStack(spacing: 16) {
                        ForEach(0 ..< categoryList.count, id: \.self) { ind in
                            Button(action: {
                                showPayoutView = true
                            }) {
                                ListCell(
                                    isComeFrom: "Wallet",
                                    image: categoryList[ind].image ?? "",
                                    title: categoryList[ind].name ?? "",
                                    vectorImg: .icArrowUp,
                                    subLabel: AppString.YouAreEligibleForEarlyPayout,
                                    tintColot: categoryList[ind].color ?? "",
                                    onTapMenuCell: {}
                                )
                                .padding([.leading ,.trailing] ,0)
                                .padding(.vertical,1)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Text(AppString.PayoutHistory)
                        .font(.custom(poppinsSemiBold, size: 14.0))
                    if !payouts.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(payouts) { payout in
                                PayoutRowView(payout: payout, currencySymbol: "$")
                                if payout.id != payouts.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }else{
                        NoDataFoundView(image: "noData", title: AppString.NoPayoutHistoryFound)
                    }
                }
//                .frame(maxWidth: .infinity)
            }
        }
        CusNavLink(doNavigate: $showPayoutView, destination: PayoutView())
        .ignoresSafeArea(edges: .horizontal)
    }
}
