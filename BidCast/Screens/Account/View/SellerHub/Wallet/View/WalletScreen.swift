//
//  WalletScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//


import SwiftUI
import SVProgressHUD

struct WalletScreen: View {
    
    @State private var segment: WalletScreenSegment = .wallet
    @Environment(\.presentationMode) private var presentationMode
    @State var data: WalletData?
    @State var dataTransaction = [TransactionModel]()
    @State var dataPayOutHistory = PayOutHistoryModel()
    @State var dataWallet = WalletInfoModel()
    
    @State var viewModel = WalletViewModel()
    @State var selectedButton: WalletSegment = .all
    var body: some View {
        VStack(spacing: 0) {
            VStack{
                // MARK: Top-Header (fixed)
                PrimaryHeader(
                    title: "Wallet",
                    isForBoth: true,
                    leadingImgArr: [.icBack,.appName],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                    count: .constant(0)
                )
            }
            
            CustomSegmentedControl(preselectedIndex: $segment,
                                   options: WalletScreenSegment.allCases)
                .padding(.horizontal)
            ScrollView {
                VStack(spacing: 20) {
                    
                    switch segment {
                    case .wallet:
                        WalletTabView(summary: dataWallet,
                                      payouts: data?.payoutHistory ?? [Payout]())
                        
                    case .transactions:
                        VStack(spacing: 10) {
                            SegmentedControlView(segments: WalletSegment.allCases, selectedSegment: $selectedButton, isWithBorder: true)
                        }
                        ForEach(dataTransaction.indices, id: \.self) { index in
                            let data = dataTransaction[index]
                            TransactionsTabView(
                                title: data.source_type ?? "",
                                subLabel: data.card_number ?? "",
                                price: "\(data.total ?? 0)"
                            )
                        }
                    }
                    
                    Spacer(minLength: 90)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            
        }
        .onAppear{
            Task{
                SVProgressHUD.show()
                await self.viewModel.getWalletInfo()
                walletInfosuccess()
                await self.viewModel.getPayOutHistory()
                payOutHistroysuccess()
                await SVProgressHUD.dismiss()
            }
        }
        .onChange(of: segment) { newValue in
            if newValue == .transactions {
                Task {
                    SVProgressHUD.show()
                    await viewModel.getTransaction(param: TransactionRequest())
                    await SVProgressHUD.dismiss()
                    success()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
    
    func success(){
        let response  = viewModel.transactionDict
        if response.status == "success"{
            dataTransaction = response.data ?? [TransactionModel]()
        }
    }
    
    func walletInfosuccess(){
        let response  = viewModel.walletInfoDict
        if response.status == "success"{
            dataWallet = response.data ?? WalletInfoModel()
        }
    }
    
    func payOutHistroysuccess(){
        let response  = viewModel.payOutHistoryDict
        if response.status == "success"{
            dataPayOutHistory = response.data ?? PayOutHistoryModel()
        }
    }
}


/// Square tile (icon + title + big value)
struct WalletStatTile: View {
    var title: String
    var value: String
    var iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: iconName)
                .font(.title2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.title3.bold())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}




// MARK: - WalletData.
struct WalletData {
    var payoutHistory: [Payout]?
    var transactions: [TransactionModel]?
}

// MARK: - Payout.
struct Payout: Identifiable {
    let id = UUID()
    var amount: Double? = 0.0
    var date: String? = ""
    var status: String? = ""
}
//MARK: - WalletScreenSegment
enum WalletScreenSegment: String, CaseIterable, CustomStringConvertible {
    case wallet        = "Wallet"
    case transactions  = "Transactions"
    
    var description: String { rawValue }
}
