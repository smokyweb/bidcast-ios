//
//  TipsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast

// MARK: - TipsScreen View
struct TipsScreen: View {
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
                title: "Tips",
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
            .frame(height : 10)


            // MARK: - Scrollable Show List
            ScrollView {
                VStack(spacing: 10) {
                    TwoVerticalLabelCell(dataModel: TipsValue.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description.localized})
                    
                    ForEach(transactions) { txn in
                        TransactionRowView(transaction: txn)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }.safeAreaInset(edge: .bottom) {
                // MARK: - Fixed Bottom Button
                PrimaryButton(title: AppString.submit.localized, isOutLine: false, onButtonClick: {
                    // Action
                },btnTextColor: .white)
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



enum TipsValue : String, CaseIterable, CustomStringConvertible{
    
    case tipsToday = "Tips today"
    case totalTips = "Total tips"
    case totalTi = "Testing"
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    
    var labelOlt : String{
        switch self {
            
        case .tipsToday:
            return "284"
        case .totalTips:
            return "$5.2K"
        case .totalTi :
            return "$5.2K"

        }
    }
}

// MARK: - Preview
#Preview {
    TipsScreen()
}

