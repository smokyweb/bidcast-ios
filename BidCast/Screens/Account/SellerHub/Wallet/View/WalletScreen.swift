//
//  WalletScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast

// MARK: - WalletScreen View
struct WalletScreen: View {
    @State private var segment: WalletScreenSegment = .walet
    @State private var selectedButton: WalletSegment = .all
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    let transactions = [
        Transaction(title: "Purchase from John", date: Date(timeIntervalSince1970: 1742841600), amount: 1250.00, isOutgoing: true)
    ]
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager



    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            PrimaryHeader(
                title: "",
                isForLogo : true,
                leadingImgArr: [.appName],
                trailingImgArr: [.notification],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .padding(.horizontal)
            .padding(.bottom, 10)
            .frame(height: 50)

            // MARK: - Segmented Control (also fixed)
            CustomSegmentedControl(preselectedIndex: $segment, options: WalletScreenSegment.allCases)
//                .background(Color.white)
                .padding(.horizontal)

            // MARK: - Scrollable Show List
            ScrollView {
                VStack(spacing: 10) {
                    SegmentedControlView(segments: WalletSegment.allCases, selectedSegment: $selectedButton, isWithBorder: true)
                    
                    ForEach(transactions) { txn in
                        TransactionRowView(transaction: txn)
                            .padding(.horizontal)
                            .padding(.top ,20)
                    }
                }
                .padding(.top)
            } .safeAreaInset(edge: .bottom) {
                // MARK: - Fixed Bottom Button
                PrimaryButton(
                    title: AppString.submit.localized,
                    isOutLine: false,
                    onButtonClick: {
                        // Action
                    },
                    btnTextColor: .white
                )
                .padding(.horizontal)
                .padding(.vertical, 0)
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
    }
}


// MARK: - Segment Enum
enum WalletScreenSegment: String, CaseIterable, CustomStringConvertible {
    case walet = "Wallet"
    case transactions = "Transactions"

    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
}


// MARK: - Preview
#Preview {
    WalletScreen()
}


enum WalletSegment: String, CaseIterable, CustomStringConvertible {
    case all = "All"
    case processing = "Processing"
    case complete = "Complete"
    case withdrawal = "Withdrawal"
    
    var description: String {
        return rawValue
    }
}
