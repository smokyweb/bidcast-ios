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
        CategoryDataModel(id: 1, name: "Early Payout", image: "electronics_icon", color: "#FF5733")
    ]
    
    var body: some View {
        ScrollView {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    VStack(spacing: 4) {
                        Text("Available Balance")
                            .font(.custom(poppinsRegular, size: 11.0))
                            .foregroundColor(.gray)
                        Text("$\(formatAmount(summary.avaiableBalance))")
                            .font(.custom(poppinsSemiBold, size: 20.0))
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    
                    HStack(spacing: 12) {
                        WalletStatTile(
                            title: "Available for\nPayout",
                            value: formatAmount(Double(summary.avaiableForPayout ?? 0)),
                            iconName: "arrow.up.arrow.down"
                        )
                        WalletStatTile(
                            title: "Processing",
                            value: formatAmount(summary.processing),
                            iconName: "lock.rotation"
                        )
                    }
                    VStack(spacing: 16) {
                        ForEach(0 ..< categoryList.count, id: \.self) { ind in
                            ListCell( isComeFrom: "Wallet",image: categoryList[ind].image ?? "", title: categoryList[ind].name ?? "", vectorImg: .icArrowUp,subLabel : "You're eligible for early payout",tintColot: categoryList[ind].color ?? "")
                                .padding([.leading ,.trailing] ,0)
                                .padding(.vertical,1)
                            
                        }
                    }
                    Text("Payout History")
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
                        HStack{
                            Spacer()
                            VStack(alignment:.center, spacing: 16) {
                                Spacer()
                                
                                Image("noData")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("No Payout history found")
                                    .font(.custom(poppinsSemiBold, size: 13))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
//                .frame(maxWidth: .infinity)
            }
        }
        .ignoresSafeArea(edges: .horizontal)
    }
}

