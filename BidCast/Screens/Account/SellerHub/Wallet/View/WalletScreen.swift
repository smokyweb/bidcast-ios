//
//  WalletScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

//import SwiftUI
//import AlertToast
//
//// MARK: - WalletScreen View
//struct WalletScreen: View {
//    @State private var segment: WalletScreenSegment = .walet
//    @State private var selectedButton: WalletSegment = .all
//    @State private var showError: Bool = false
//    @State private var isLoading: Bool = false
//    @State private var showhud: Bool = false
//    @State private var hudMsg: String = ""
//    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    let transactions = [
//        Transaction(title: "Purchase from John", date: Date(timeIntervalSince1970: 1742841600), amount: 1250.00, isOutgoing: true)
//    ]
//    
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject private var appRootManager: AppRootManager
//
//
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // MARK: - Top Header (fixed)
//            PrimaryHeader(
//                title: "",
//                isForLogo : true,
//                leadingImgArr: [.appName],
//                trailingImgArr: [.notification],
//                onClickLeading: { _ in
//                    self.presentationMode.wrappedValue.dismiss()
//                },
//                count: .constant(0)
//            )
//            .padding(.horizontal)
//            .padding(.bottom, 10)
//            .frame(height: 50)
//
//            // MARK: - Segmented Control (also fixed)
//            CustomSegmentedControl(preselectedIndex: $segment, options: WalletScreenSegment.allCases)
////                .background(Color.white)
//                .padding(.horizontal)
//
//            // MARK: - Scrollable Show List
//            ScrollView {
//                VStack(spacing: 10) {
//                    SegmentedControlView(segments: WalletSegment.allCases, selectedSegment: $selectedButton, isWithBorder: true)
//                    
//                    ForEach(transactions) { txn in
//                        TransactionRowView(transaction: txn)
//                            .padding(.horizontal)
//                            .padding(.top ,20)
//                    }
//                }
//                .padding(.top)
//            }
////            .safeAreaInset(edge: .bottom) {
////                // MARK: - Fixed Bottom Button
////                PrimaryButton(
////                    title: AppString.submit.localized,
////                    isOutLine: false,
////                    onButtonClick: {
////                        // Action
////                    },
////                    btnTextColor: .white
////                )
////                .padding(.horizontal)
////                .padding(.vertical, 0)
////                .background(Color(UIColor.systemGroupedBackground))
////            }
//        }
//        .background(Color(UIColor.systemGroupedBackground))
//        .toast(isPresenting: $showhud) {
//            AlertToast(type: .regular, title: hudMsg)
//        }
//    }
//}
//
//
//// MARK: - Segment Enum
//enum WalletScreenSegment: String, CaseIterable, CustomStringConvertible {
//    case walet = "Wallet"
//    case transactions = "Transactions"
//
//    var description: String {
//        NSLocalizedString(rawValue, comment: "")
//    }
//}
//
//
//// MARK: - Preview
//#Preview {
//    WalletScreen()
//}
//
//
//enum WalletSegment: String, CaseIterable, CustomStringConvertible {
//    case all = "All"
//    case processing = "Processing"
//    case complete = "Complete"
//    case withdrawal = "Withdrawal"
//    
//    var description: String {
//        return rawValue
//    }
//}

import SwiftUI

struct WalletScreen: View {
    
    @State private var segment: WalletScreenSegment = .wallet
    @Environment(\.presentationMode) private var presentationMode
    var data: WalletData
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: Top-Header (fixed)
            PrimaryHeader(
                title: "Wallet",
                isForLogo: true,
                leadingImgArr: [.appName],
                trailingImgArr: [.icSetting],
                onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                count: .constant(0)
            )
            .padding(.horizontal)
            .padding(.bottom, 10)
            .frame(height: 50)
            CustomSegmentedControl(preselectedIndex: $segment,
                                   options: WalletScreenSegment.allCases)
                .padding(.horizontal)
            ScrollView {
                VStack(spacing: 20) {
                    
                    switch segment {
                    case .wallet:
                        WalletTabView(summary: data.summary,
                                      payouts: data.payoutHistory)
                        
                    case .transactions:
                        TransactionsTabView(transactions: data.transactions)
                    }
                    
                    Spacer(minLength: 90)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
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

#Preview {
    let sampleData = WalletData(
        summary: WalletSummary(
            availableBalance: 5280.50,
            availableForPayout: 3450.00,
            processing: 1830.50,
            earlyPayoutMessage: "You're eligible for early payout"
        ),
        payoutHistory: [
            Payout(amount: 1250, date: .init(timeIntervalSince1970: 1741977600), status: "Completed"),
            Payout(amount: 980.25, date: .init(timeIntervalSince1970: 1740796800), status: "Completed"),
            Payout(amount: 2150.75, date: .init(timeIntervalSince1970: 1739568000), status: "Completed")
        ],
        transactions: [
            Transaction(title: "Purchase from John", date: .init(timeIntervalSince1970: 1742841600), amount: 1250.00, isOutgoing: true)
        ]
    )
    
    WalletScreen(data: sampleData)
        .environmentObject(AppRootManager())
}


// MARK: - WalletData.
struct WalletData {
    var summary: WalletSummary
    var payoutHistory: [Payout]
    var transactions: [Transaction]
}

// MARK: - WalletSummary.
struct WalletSummary {
    var availableBalance: Double
    var availableForPayout: Double
    var processing: Double
    var earlyPayoutMessage: String
    var currencySymbol: String = "$"
}

// MARK: - Payout.
struct Payout: Identifiable {
    let id = UUID()
    var amount: Double
    var date: Date
    var status: String
}
//MARK: - WalletScreenSegment
enum WalletScreenSegment: String, CaseIterable, CustomStringConvertible {
    case wallet        = "Wallet"
    case transactions  = "Transactions"
    
    var description: String { rawValue }
}
