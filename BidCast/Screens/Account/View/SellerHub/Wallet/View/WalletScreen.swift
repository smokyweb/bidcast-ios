//
//  WalletScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//




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


struct TransactionsView: View {
    @State var selectedButton: WalletSegment
    
    @Binding var transactions: [TransactionModel]
    
    var segmentChangeClosure: ((WalletSegment) -> Void)
    
    var body: some View {
        VStack(spacing: 12) {
            // Filter Chips
            SegmentedControlView(segments: WalletSegment.allCases, selectedSegment: $selectedButton, isWithBorder: true){ selection in
                segmentChangeClosure(selectedButton)
            }
            
            // Transactions List
            if transactions.count != 0 {
                VStack(spacing: 0) {
                    ForEach(transactions, id: \.id) { transaction in
                        TransactionRow(transaction: transaction)
                        
                        if transaction.id != transactions.last?.id {
                            Divider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            
            else {
                NoDataView(message: "No Transactions Avalable")
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
    let transaction: TransactionModel
    @State private var isPressed = false
    
    // QA #13 — derive a human-readable title from the live transaction data.
    private func transactionTitle(for txn: TransactionModel) -> String {
        let counterparty = txn.counterpartyName?.trimmingCharacters(in: .whitespaces)
            ?? txn.buyer?.name?.trimmingCharacters(in: .whitespaces)
            ?? txn.sender?.name?.trimmingCharacters(in: .whitespaces)
            ?? txn.receiver?.name?.trimmingCharacters(in: .whitespaces)
        let typeRaw = (txn.type ?? "").trimmingCharacters(in: .whitespaces).lowercased()
        // Map snake_case backend values to human copy.
        let typeCopy: String = {
            switch typeRaw {
            case "payout", "withdrawal":     return "Payout"
            case "refund":                   return "Refund"
            case "tip":                      return "Tip"
            case "earning", "earnings", "sale", "order": return "Earnings from sale"
            case "":                          return "Transaction"
            default:                          return typeRaw.capitalized
            }
        }()
        if let cp = counterparty, !cp.isEmpty {
            switch typeRaw {
            case "payout", "withdrawal": return "Payout to \(cp)"
            case "refund":               return "Refund to \(cp)"
            case "tip":                  return "Tip from \(cp)"
            default:                     return "\(typeCopy) — \(cp)"
            }
        }
        return typeCopy
    }
    
    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    // QA #13 — Transactions section was rendering a hardcoded ring title for every row.
                    // Build a real label from the transaction model (counterparty + type) so users see
                    // their actual transactions instead of filler data.
                    Text(transactionTitle(for: transaction))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)
                    Text("\(formatISODateString(transaction.date ?? "")) • \(transaction.status ?? "")")
                    //                    Text("11/18/25 • Completed")
                    
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("$ \(transaction.total ?? "0.00")")
                //                Text("$5.42")
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
    
    
    func formatISODateString(
        _ dateString: String,
        outputFormat: String = "MMM dd, yyyy"
    ) -> String {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = iso.date(from: dateString) else { return dateString }
        
        let formatter = DateFormatter()
        formatter.dateFormat = outputFormat
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        
        return formatter.string(from: date)
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

struct WalletPayoutView: View {
    
    // MARK: - State
    @State private var segment: WalletScreenSegment = .wallet
    @State private var navigateToAllPayouts = false
    @State private var isTipAmountButtoClicked = false
    
    @State private var isLoading = true
    
    @State private var walletInfo = WalletInfoModel()
    @State private var payoutHistory: [PayOutHistoryModel] = []
    
    @StateObject private var viewModel = WalletViewModel()
    
    @State var dataTransaction = [TransactionModel]()
    
    @State var currentPage = 1
    @State var selectedButton: WalletSegment = .all
    
    @State private var sellerId: String = ""
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var walletAmount : Int = 0
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                VStack {
                    PrimaryHeader(title: "Wallet",leadingImgArr: ["chevron.left"], onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },count: .constant(0))
                }
                // MARK: Segment (UNCHANGED)
                CustomSegmentedControl(
                    preselectedIndex: $segment,
                    options: WalletScreenSegment.allCases
                )
                .onChange(of: segment, { oldValue, newValue in
                    if segment == .wallet {
                        loadData()
                    }
                    else {
                        fetchTransaction()
                    }
                })
                .padding(.horizontal)
                .padding(.vertical,12)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if segment == .wallet {
                            walletContent
                        } else {
                            TransactionsView(selectedButton: .all, transactions: $dataTransaction) { _ in
                                
                            }
                        }
                        
                        //                        Spacer(minLength: 100)
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                .background(.backGround)
                //                .padding(.bottom,-40)
                if segment == .wallet {
                    if walletInfo.avaiableForPayout ?? 0 != 0{
                        VStack(spacing: 8) {
                            PrimaryButton(title: "Start Payout",onButtonClick: {
                                sellerId = "\(UserDefaults.userId)"
                                walletAmount  = walletInfo.avaiableForPayout ?? 0
                                isTipAmountButtoClicked = true
                                
                            })
                            Text("Funds typically arrive within 1–2 business days.")
                                .font(.custom(poppinsRegular, size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            //            .padding(.bottom,-40)
            .background(.backGround)
            .navigationBarHidden(true)
            .onAppear {
                loadData()
            }
            .bottomSheet(isPresented: $showError,
                         height: screenHeight * 0.35,
                         topBarCornerRadius: 25,
                         contentBackgroundColor: Color(.systemBackground),
                         topBarBackgroundColor: Color(.systemBackground),
                         showTopIndicator: false,
                         onDismiss: {
                if self.viewModel.errorMessage != "" || self.viewModel.errorMessage != nil{
                    //errorMessage not nil
                    showError = true
                }else{
                    showError = false
                }
            }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        self.presentationMode.wrappedValue.dismiss()
                        withAnimation { showError = false }
                    }, onSecondaryClick: {
                        withAnimation { showError = false }
                    })
                .background(Color(.backGround))
                .cornerRadius(25, corners: [.topLeft, .topRight])
            })
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding(.bottom,-32)
        .background(.backGround)
        CusNavLink(
            doNavigate: $navigateToAllPayouts,
            destination: FullPayoutHistoryView()
        )
        CusNavLink(
            doNavigate: $isTipAmountButtoClicked,
            destination: PayoutView(walletAmount: $walletAmount, sellerID: sellerId)
        )
    }
    
    // MARK: - Wallet Content
    private var walletContent: some View {
        VStack(spacing: 20) {
            
            // cmpcqb3fa (2026-05-20): renamed labels per Trey's option A — Total Balance = In Escrow + Available.
            // Matches Android (MR !24) + PWA (deployed 2026-05-20 09:34 EDT).
            VStack(alignment: .leading, spacing: 6) {
                Text("Total Balance")
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.gray)
                
                Text("\(String(format: "$%.2f", walletInfo.avaiableBalance ?? 0.00))")
                    .font(.custom(poppinsBold, size: 42))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Payout Info Card (REPLACED MIDDLE)
            VStack(spacing: 18) {
                payoutRow(
                    title: "$\(walletInfo.avaiableForPayout ?? 0) Available",
                    desc: "Available — these funds are ready to initiate payout to your bank account."
                )
                
                Divider()
                
                payoutRow(
                    title: "$\(walletInfo.processing ?? 0.00) In Escrow",
                    desc: "In Escrow — these funds will become Available up to 4 hours after the order has been delivered."
                )
                if walletInfo.avaiableForPayout ?? 0 == 0{
                    Divider()
                    
                    HStack(spacing: 6) {
                        Text("Not eligible for early payout")
                            .font(.custom(poppinsMedium, size: 14))
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(18)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.15))
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            
            // Help Center
            VStack(alignment: .leading, spacing: 4) {
                Text("Need more information about receiving payouts?")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.gray)
                
                Text("Visit the Help Center")
                    .font(.custom(poppinsMedium, size: 13))
                    .foregroundColor(.defaultTheme)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Payout History Header
            HStack {
                Text("Payout History")
                    .font(.custom(poppinsSemiBold, size: 18))
                
                Spacer()
                
                Button("See All") {
                    //                    navigateToAllPayouts = true
                }
                .font(.custom(poppinsMedium, size: 15))
                .foregroundColor(.defaultTheme)
            }
            
            // Payout History List (TOP 5)
            if isLoading {
                PayoutHistoryShimmerView()
            } else {
                VStack(spacing: 0) {
                    ForEach(payoutHistory.prefix(5)) { payout in
                        PayoutRowView(payout: payout)
                        Divider().padding(.leading, 20)
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            }
            
        }
    }
    
    // MARK: - Helpers
    private func payoutRow(title: String, desc: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom(poppinsSemiBold, size: 15))
            Text(desc)
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.gray)
        }
    }
    
    private func loadData() {
        Task {
            await performAPICalls(
                isConcurrent: true,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                    isLoading = false
                }, onSuccess: {
                    // On success
                    isLoading = false
                    walletInfosuccess()
                    payOutHistroysuccess()
                }
                
            ) {
                isLoading = true
                async let walletInfo: () =  viewModel.getWalletInfo()
                async let payoutHistory: () = viewModel.getPayOutHistory()
                _ = try await (walletInfo, payoutHistory)
            }
        }
    }
}

// MARK: - Full Payout History Page
struct FullPayoutHistoryView: View {
    
    @State private var page = 1
    @State private var payouts: [PayOutHistoryModel] = []
    @State private var isLoading = true
    @StateObject private var viewModel = WalletViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if isLoading {
                    PayoutHistoryShimmerView()
                } else {
                    Text("hello")
                    ForEach(payouts) { payout in
                        PayoutRowView(payout: payout)
                            .onAppear {
                                if payout.id == payouts.last?.id {
                                    loadMore()
                                }
                            }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Payout History")
        .onAppear {
            fetch()
        }
    }
    
    private func fetch() {
        Task {
            isLoading = true
            await viewModel.getPayOutHistory()
            payouts = viewModel.payOutHistoryDict.data ?? []
            isLoading = false
        }
    }
    
    private func loadMore() {
        page += 1
        fetch()
    }
}

// MARK: - Shimmer
struct PayoutHistoryShimmerView: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 56)
                    .shimmer()
            }
        }
    }
}


////MARK: API LOGIC For Transaction.
extension WalletPayoutView{
    
    // MARK: - Fetch Inventory List
    func fetchTransaction() {
        
        Task{
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                },
                onSuccess: {
                    transactionSuccess()
                }
            ) {
                if selectedButton == .all {
                    try await viewModel.getTransaction(param: TransactionRequest(page: currentPage))
                }
                else  {
                    try await viewModel.getTransaction(param: TransactionRequest(page: currentPage, status: selectedButton.rawValue))
                }
            }
        }
        
        //        Task{
        //           guard Reachability.isConnectedToNetwork() else {
        //                hudMsg = "No Internet Connection"
        //                showhud = true
        //                return
        //            }
        //            SVProgressHUD.show()
        //
        //            await SVProgressHUD.dismiss()
        //            if viewModel.errorMessage == nil || viewModel.errorMessage == ""{
        //
        //            }else{
        //                alertType = .sheetType(
        //                    icon: .alert,
        //                    title: "Error",
        //                    message: viewModel.errorMessage ?? "".capitalizingFirstLetter(),
        //                    primaryBtnText: "",
        //                    secondaryBtnText: AppString.ok.localized
        //                )
        //            }
        //        }
    }
    
    //MARK: fetchMoreNotificartion.
    func fetchMoreTransaction() {
        Task{
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                },
                onSuccess: {
                    transactionSuccess()
                }
            ) {
                currentPage += 1
                if selectedButton == .all {
                    try await viewModel.getTransaction(param: TransactionRequest(page: currentPage))
                }
                else  {
                    try await viewModel.getTransaction(param: TransactionRequest(page: currentPage, status: selectedButton.rawValue))
                }
            }
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
            
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
    
    
    //MARK: payOutHistroysuccess.
    
    func payOutHistroysuccess(){
        let response  = viewModel.payOutHistoryDict
        if response.status == "success"{
            payoutHistory = response.data ?? []
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
            walletInfo = response.data ?? WalletInfoModel()
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



//import SwiftUI

//
//
//import SwiftUI
//import SVProgressHUD
//
//struct FinancesView: View {
//    @State private var selectedTab = 0
//    @State private var selectedFilter = 0
//
//    @State private var segment: WalletScreenSegment = .wallet
//    @Environment(\.presentationMode) private var presentationMode
//
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
//    @State var currentPage = 1
//    @State var selectedButton: WalletSegment = .all
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Header
//                HStack {
//                    Button(action: {}) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 20, weight: .semibold))
//                            .foregroundColor(.black)
//                    }
//
//                    Spacer()
//
//                    Text("Wallet")
//                        .font(.system(size: 22, weight: .bold))
//
//                    Spacer()
//                    Button(action:{
//                        self.presentationMode.wrappedValue.dismiss()
//                    }){
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 20))
//                            .opacity(0)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.vertical, 16)
//                .background(Color.white)
//
//                CustomSegmentedControl(preselectedIndex: $segment,
//                                       options: WalletScreenSegment.allCases)
//                .padding(.horizontal)
//
//                ScrollView  {
//                    VStack(spacing: 12) {
//
//                        switch segment {
//                        case .wallet:
//                            WalletTabView(summary: dataWallet,
//                                          payouts: dataPayOutHistory)
//
//                        case .transactions:
////                            if dataTransaction.count == 0{
////                                NoDataView(message: AppString.NoTransactionHistoryFound)
////                            }else{
//                            TransactionsView(selectedButton: .all) { segment in
//                                selectedButton = segment
//                            }
//
////                            }
//                        }
//
//                        Spacer(minLength: 90)
//                    }
//                    .padding(.horizontal)
//                    .padding(.top, 10)
//                }
//                .background(Color(UIColor.systemGroupedBackground))
//
//                Divider()
//                    .padding(.top, 8)
//
//            }
//            .navigationBarHidden(true)
//            .onAppear{
//                Task{
//                    guard Reachability.isConnectedToNetwork() else {
//                        hudMsg = "No Internet Connection"
//                        showhud = true
//                        return
//                    }
//                    SVProgressHUD.show()
//                    await self.viewModel.getWalletInfo()
//                    walletInfosuccess()
//                    await self.viewModel.getPayOutHistory()
//                    payOutHistroysuccess()
//                    await SVProgressHUD.dismiss()
//                }
//            }
//            .onChange(of: segment) { newValue in
//                if newValue == .transactions {
//                    fetchTransaction()
//                }
//            }
//            .background(Color(UIColor.systemGroupedBackground))
//
//        }
//    }
//}
//
//struct TabButton: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 8) {
//                Text(title)
//                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
//                    .foregroundColor(isSelected ? .black : .gray)
//
//                Rectangle()
//                    .fill(isSelected ? Color.black : Color.clear)
//                    .frame(height: 3)
//                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
//            }
//        }
//        .frame(maxWidth: .infinity)
//    }
//}
//
//struct PayoutsView: View {
//    var body: some View {
//        VStack(spacing: 20) {
//            // Account Balance
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Account Balance")
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.gray)
//
//                Text("$115.20")
//                    .font(.system(size: 48, weight: .bold))
//                    .foregroundColor(.black)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//
//            // Balance Details Card
//            VStack(spacing: 20) {
//                // Available for payout
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("$98.59 available for payout")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.black)
//
//                    Text("These funds are available to initiate payout to your bank account.")
//                        .font(.system(size: 14))
//                        .foregroundColor(.gray)
//                        .fixedSize(horizontal: false, vertical: true)
//                        .lineSpacing(2)
//                }
//
//                Divider()
//
//                // Processing
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("$16.61 processing")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.black)
//
//                    HStack(alignment: .top, spacing: 4) {
//                        Text("These funds will be available for payout up to 4 hours after delivery of the order has been confirmed.")
//                            .font(.system(size: 14))
//                            .foregroundColor(.gray)
//                            .fixedSize(horizontal: false, vertical: true)
//                            .lineSpacing(2)
//
//                        Button(action: {}) {
//                            Text("View processing transactions")
//                                .font(.system(size: 14))
//                                .foregroundColor(.blue)
//                                .underline()
//                        }
//                    }
//                }
//
//                Divider()
//
//                // Not eligible
//                HStack(spacing: 8) {
//                    Text("Not eligible for early payout")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.black)
//
//                    Image(systemName: "info.circle")
//                        .font(.system(size: 14))
//                        .foregroundColor(.gray)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(20)
//            .background(Color(red: 0.96, green: 0.96, blue: 0.97))
//            .cornerRadius(16)
//            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
//            .padding(.horizontal, 20)
//
//            // Help Center Link
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Need more information about receiving payouts?")
//                    .font(.system(size: 14))
//                    .foregroundColor(.gray)
//
//                Button(action: {}) {
//                    Text("Visit the Help Center")
//                        .font(.system(size: 14))
//                        .foregroundColor(.blue)
//                        .underline()
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 20)
//
//            // Payout History
//            HStack {
//                HStack(spacing: 6) {
//                    Text("Payout History")
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundColor(.black)
//
//                    Image(systemName: "info.circle")
//                        .font(.system(size: 16))
//                        .foregroundColor(.gray)
//                }
//
//                Spacer()
//
//                Button(action: {}) {
//                    Text("See All")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(.blue)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//
//            Spacer()
//
//            // Start Payout Button
//            VStack(spacing: 12) {
//                Button(action: {}) {
//                    Text("Start Payout")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(.black)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(
//                            RoundedRectangle(cornerRadius: 28)
//                                .fill(Color.yellow)
//                                .shadow(color: Color.yellow.opacity(0.3), radius: 8, x: 0, y: 4)
//                        )
//                }
//
//                Text("Funds typically arrive within 1-2 business days.")
//                    .font(.system(size: 13))
//                    .foregroundColor(.gray)
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 20)
//        }
//    }
//}

//
//struct FinancesView_Previews: PreviewProvider {
//    static var previews: some View {
//        FinancesView()
//    }
//}

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
//@State var currentPage = 1
//    @State var selectedButton: WalletSegment = .all
//    var body: some View {
//        VStack(spacing: 0) {
//            VStack{
//                // MARK: Top-Header (fixed)
//                PrimaryHeader(
//                    title: AppString.Account,
//                    isForBoth: false,
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
