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
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var currentPage = 1
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
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
                        if dataTransaction.count == 0{
                            NoDataView(message: "No Transaction history found")
                        }else{
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
                                .onAppear{
                                    handlePaginationForTransaction(index: index)
                                }
                            }
                            
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
                fetchTransaction(page: currentPage)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}


// Square tile (icon + title + big value)
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
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.custom(poppinsSemiBold, size: 11.0))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}


//MARK: API LOGIC For Transaction.
extension WalletScreen{
    
    // MARK: - Fetch Inventory List
    func fetchTransaction(page: Int) {
        Task{
            SVProgressHUD.show()
            await viewModel.getTransaction(param: TransactionRequest(page: currentPage))
            await SVProgressHUD.dismiss()
            transactionSuccess()
        }
    }
    
    //MARK: fetchMoreNotificartion.
    func fetchMoreTransaction() {
        Task {
            currentPage += 1
            await viewModel.getTransaction(param: TransactionRequest(page: currentPage))
            transactionSuccess()
        }
    }
    
    //MARK: handlePagination.
    func handlePaginationForTransaction(index: Int) {
        let isLastItem = index == dataTransaction.count - 1
        let canFetchMore = (viewModel.transactionDict.total ?? 0) > dataTransaction.count
        
        if isLastItem && canFetchMore {
            fetchMoreTransaction()
        }
    }
    
    //MARK: transactionSuccess.
    func transactionSuccess(){
        let response  = viewModel.transactionDict
        if response.status == "success" {
            let newData = response.data ?? [TransactionModel]()
            
            if currentPage == 1 {
                dataTransaction = newData
            } else {
                dataTransaction.append(contentsOf: newData)
            }
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }

    
    //MARK: payOutHistroysuccess.
    func payOutHistroysuccess(){
        let response  = viewModel.payOutHistoryDict
        if response.status == "success"{
            dataPayOutHistory = response.data ?? PayOutHistoryModel()
        }else{
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            
        }
    }
    
    //MARK: walletInfosuccess.
    func walletInfosuccess(){
        let response  = viewModel.walletInfoDict
        if response.status == "success"{
            dataWallet = response.data ?? WalletInfoModel()
        }else{
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            
        }
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
