//
//  WalletTabView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUI
 
struct WalletTabView: View {
    
    var summary: WalletSummary
    var payouts: [Payout]
    
    // Currency formatting helper
    private func money(_ value: Double) -> String {
        "\(summary.currencySymbol)" + String(format: "%,.2f", value)
    }
    let transactions = [
        Transaction(title: "Purchase from John", date: Date(timeIntervalSince1970: 1742841600), amount: 1250.00, isOutgoing: true)
    ]
    
    @State var categoryList: [CategoryDataModel] = [
        CategoryDataModel(id: 1, name: "Electronics", image: "electronics_icon", color: "#FF5733")
    ]
    
    var body: some View {
        ScrollView {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(spacing: 4) {
                        Text("Available Balance")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text(money(summary.availableBalance))
                            .font(.system(size: 34, weight: .bold))
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)

                    HStack(spacing: 12) {
                        WalletStatTile(
                            title: "Available for\nPayout",
                            value: money(summary.availableForPayout),
                            iconName: "arrow.up.arrow.down"
                        )
                        WalletStatTile(
                            title: "Processing",
                            value: money(summary.processing),
                            iconName: "lock.rotation"
                        )
                    }
                    VStack(spacing: 16) {
                            ForEach(0 ..< categoryList.count, id: \.self) { ind in
                                ListCell( isComeFrom: "Wallet",image: categoryList[ind].image ?? "", title: categoryList[ind].name ?? "", vectorImg: .icArrowUp,subLabel : "BidSwipe",tintColot: categoryList[ind].color ?? "")
                                    .padding([.leading ,.trailing] ,0)
                                
                            }
                        }

                    if !payouts.isEmpty {
                        Text("Payout History")
                            .fontWeight(.semibold)

                        VStack(spacing: 0) {
                            ForEach(payouts) { payout in
                                PayoutRowView(payout: payout, currencySymbol: summary.currencySymbol)
                                if payout.id != payouts.last?.id {
                                    Divider()
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .ignoresSafeArea(edges: .horizontal)
    }
}

