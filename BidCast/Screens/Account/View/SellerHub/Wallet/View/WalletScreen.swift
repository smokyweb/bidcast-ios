//
//  WalletScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//


//import SwiftUI

//
//struct WalletScreen: View {
//    
//    @State private var segment: WalletScreenSegment = .wallet
//    @Environment(\.presentationMode) private var presentationMode
//    @State var showError: Bool = false
//    @State var isLoading: Bool = false
//    @State var showhud: Bool = false
//    @State var currentPage = 1
//    @State var hudMsg: String = ""
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    @State var data: WalletData?
//    @State var dataTransaction = [TransactionModel]()
//    @State var dataPayOutHistory: [PayOutHistoryModel] = []
//    @State var dataWallet = WalletInfoModel()
//    
//    @State var viewModel = WalletViewModel()
//    @State var selectedButton: WalletSegment = .all
//    var body: some View {
//        VStack(spacing: 0) {
//            VStack{
//                // MARK: Top-Header (fixed)
//                PrimaryHeader(
//                    title: AppString.Account,
//                    isForBoth: true,
//                    leadingImgArr: [.icBack,.appName],
//                    trailingImgArr: [.icSetting],
//                    onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
//                    count: .constant(0)
//                )
//            }
//            
//            CustomSegmentedControl(preselectedIndex: $segment,
//                                   options: WalletScreenSegment.allCases)
//            .padding(.horizontal)
//            ScrollView  {
//                VStack(spacing: 20) {
//                    
//                    switch segment {
//                    case .wallet:
//                        WalletTabView(summary: dataWallet,
//                                      payouts: dataPayOutHistory)
//                        
//                    case .transactions:
//                        if dataTransaction.count == 0{
//                            NoDataView(message: AppString.NoTransactionHistoryFound)
//                        }else{
//                            VStack(spacing: 10) {
//                                SegmentedControlView(segments: WalletSegment.allCases, selectedSegment: $selectedButton, isWithBorder: true){ selection in
//                                        print("SegmentedControlView: \(selectedButton)")
//                                        self.fetchTransaction()
//                                    }
//                                
//                            }
//                            ForEach(dataTransaction.indices, id: \.self) { index in
//                                let data = dataTransaction[index]
//                                TransactionsTabView(
//                                    title: data.source_type ?? "",
//                                    subLabel: data.card_number ?? "",
//                                    price: "\(data.total ?? "0")"
//                                )
//                                .onAppear{
//                                    handlePaginationForTransaction(index: index)
//                                }
//                            }
//                            
//                        }
//                    }
//                    
//                    Spacer(minLength: 90)
//                }
//                .padding(.horizontal)
//                .padding(.top, 10)
//            }
//            
//        }
//        .onAppear{
//            Task{
//               guard Reachability.isConnectedToNetwork() else {
//                    hudMsg = "No Internet Connection"
//                    showhud = true
//                    return
//                }
//                SVProgressHUD.show()
//                await self.viewModel.getWalletInfo()
//                walletInfosuccess()
//                await self.viewModel.getPayOutHistory()
//                payOutHistroysuccess()
//                await SVProgressHUD.dismiss()
//            }
//        }
//        .onChange(of: segment) { newValue in
//            if newValue == .transactions {
//                fetchTransaction()
//            }
//        }
//        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
//    }
//}
//
//
//// Square tile (icon + title + big value)
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
                Text("$\(value)")
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
//
//
////MARK: API LOGIC For Transaction.
extension FinancesView{
    
    // MARK: - Fetch Inventory List
    func fetchTransaction() {
        Task{
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            if selectedButton == .all {
                await viewModel.getTransaction(param: TransactionRequest(page: currentPage))
            }
            else  {
                await viewModel.getTransaction(param: TransactionRequest(page: currentPage, status: selectedButton.rawValue))
            }
            await SVProgressHUD.dismiss()
            transactionSuccess()
        }
    }
    
    //MARK: fetchMoreNotificartion.
    func fetchMoreTransaction() {
        Task {
            currentPage += 1
            if selectedButton == .all {
                await viewModel.getTransaction(param: TransactionRequest(page: currentPage))
            }
            else  {
                await viewModel.getTransaction(param: TransactionRequest(page: currentPage, status: selectedButton.rawValue))
            }
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
            dataPayOutHistory = response.data ?? []
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
    
    var description: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}


import SwiftUI
import SVProgressHUD

struct FinancesView: View {
    @State private var selectedTab = 0
    @State private var selectedFilter = 0
    
    @State private var segment: WalletScreenSegment = .wallet
    @Environment(\.presentationMode) private var presentationMode
    
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var currentPage = 1
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var data: WalletData?
    @State var dataTransaction = [TransactionModel]()
    @State var dataPayOutHistory: [PayOutHistoryModel] = []
    @State var dataWallet = WalletInfoModel()

    @State var viewModel = WalletViewModel()
    @State var selectedButton: WalletSegment = .all
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Wallet")
                        .font(.system(size: 22, weight: .bold))
                    
                    Spacer()
                    Button(action:{
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .opacity(0)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                
                CustomSegmentedControl(preselectedIndex: $segment,
                                       options: WalletScreenSegment.allCases)
                .padding(.horizontal)
                
                ScrollView  {
                    VStack(spacing: 12) {
                        
                        switch segment {
                        case .wallet:
                            WalletTabView(summary: dataWallet,
                                          payouts: dataPayOutHistory)
                            
                        case .transactions:
//                            if dataTransaction.count == 0{
//                                NoDataView(message: AppString.NoTransactionHistoryFound)
//                            }else{
                            TransactionsView(selectedButton: .all) { segment in
                                selectedButton = segment
                            }
                                
//                            }
                        }
                        
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .background(Color(UIColor.systemGroupedBackground))
                
                Divider()
                    .padding(.top, 8)
               
            }
            .navigationBarHidden(true)
            .onAppear{
                Task{
                    guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
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
                    fetchTransaction()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))

        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .black : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.black : Color.clear)
                    .frame(height: 3)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PayoutsView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Account Balance
            VStack(alignment: .leading, spacing: 8) {
                Text("Account Balance")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                
                Text("$115.20")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Balance Details Card
            VStack(spacing: 20) {
                // Available for payout
                VStack(alignment: .leading, spacing: 8) {
                    Text("$98.59 available for payout")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("These funds are available to initiate payout to your bank account.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                }
                
                Divider()
                
                // Processing
                VStack(alignment: .leading, spacing: 8) {
                    Text("$16.61 processing")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack(alignment: .top, spacing: 4) {
                        Text("These funds will be available for payout up to 4 hours after delivery of the order has been confirmed.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(2)
                        
                        Button(action: {}) {
                            Text("View processing transactions")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                }
                
                Divider()
                
                // Not eligible
                HStack(spacing: 8) {
                    Text("Not eligible for early payout")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .background(Color(red: 0.96, green: 0.96, blue: 0.97))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
            .padding(.horizontal, 20)
            
            // Help Center Link
            VStack(alignment: .leading, spacing: 4) {
                Text("Need more information about receiving payouts?")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Button(action: {}) {
                    Text("Visit the Help Center")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            // Payout History
            HStack {
                HStack(spacing: 6) {
                    Text("Payout History")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // Start Payout Button
            VStack(spacing: 12) {
                Button(action: {}) {
                    Text("Start Payout")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.yellow)
                                .shadow(color: Color.yellow.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                
                Text("Funds typically arrive within 1-2 business days.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

struct TransactionsView: View {
    @State var selectedButton: WalletSegment
    var segmentChangeClosure: ((WalletSegment) -> Void)
    let transactions = [
        Transaction1(
            title: "Earnings for selling a Two-Tone Pavé Stainless Steel Ring – Gold Accent Sides + Rectangular Stone Face",
            date: "11/28/25",
            status: "Completed",
            amount: "$3.56"
        ),
        Transaction1(
            title: "Earnings for selling a GRA-Certified Moissanite Ring – 1ct Center Stone + Side Accents (With Card)",
            date: "11/28/25",
            status: "Completed",
            amount: "$7.44"
        ),
        Transaction1(
            title: "Earnings for selling a GRA-Certified Moissanite Ring – 1ct Center Stone + Side Accents (With Card)",
            date: "11/28/25",
            status: "Completed",
            amount: "$6.47"
        ),
        Transaction1(
            title: "Earnings for selling a Men's Square-Face Solitaire Ring – Engraved Setting + High-Fire Stone #3",
            date: "11/28/25",
            status: "Completed",
            amount: "$3.56"
        ),
        Transaction1(
            title: "Earnings for selling a GRA-Certified Moissanite Band – Large Center Stone + Full Side Stones (With Card)",
            date: "11/28/25",
            status: "Completed",
            amount: "$5.48"
        ),
        Transaction1(
            title: "Earnings for selling a Men's Square-Face Solitaire Ring – Engraved Setting + High-Fire Stone #2",
            date: "11/28/25",
            status: "Completed",
            amount: "$5.42"
        )
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // Filter Chips
            SegmentedControlView(segments: WalletSegment.allCases, selectedSegment: $selectedButton, isWithBorder: true){ selection in
                segmentChangeClosure(selectedButton)
            }
            
            // Transactions List
            VStack(spacing: 0) {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                    
                    if transaction.id != transactions.last?.id {
                        Divider()
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
}

struct Transaction1: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let status: String
    let amount: String
}

struct TransactionRow: View {
    let transaction: Transaction1
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
//                    Text(transaction.title)
                    Text("Earnings for selling a Men's Square-Face Solitaire Ring – Engraved Setting + High-Fire Stone #3")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                    
//                    Text("\(transaction.date) • \(transaction.status)")
                    Text("11/18/25 • Completed")
                    
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
//                Text(transaction.amount)
                Text("$5.42")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(red: 0.0, green: 0.7, blue: 0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
//            .background(Color.white)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FinancesView_Previews: PreviewProvider {
    static var previews: some View {
        FinancesView()
    }
}
