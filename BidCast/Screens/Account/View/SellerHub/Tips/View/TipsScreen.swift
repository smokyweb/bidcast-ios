//
//  TipsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

// MARK: - TipsScreen View
struct TipsScreen: View {
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    let transactions = [
        Transaction(title: "Sarah JohnSon", date: Date(timeIntervalSince1970: 1742841600), amount: 10.00, isOutgoing: true)
    ]
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager

    @StateObject private var tipsViewModel = TipsViewModel()
    @State private var tipsList: TipsModel?
    
    var summaryItems: [TipSummaryItem] {
        guard let summary = tipsList?.summary else { return [] }
        
        return [
            TipSummaryItem(title: "Total Tips", value: "$ \(summary.totalTips ?? "0")"),
            TipSummaryItem(title: "Today Tips", value: "$ \(summary.todayTips ?? "0")")
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            VStack{
                PrimaryHeader(
                    title: AppString.Tips,
                    isForBoth : true,
                    leadingImgArr: [.icBack,.appName],
                    trailingImgArr: [.notification],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
           
            // MARK: - Scrollable Show List
            ScrollView {
                VStack(spacing: 10) {
                    TwoVerticalLabelCell(
                        dataModel: summaryItems,
                        topLabel: { $0.title },
                        bottomLabel: { $0.value }
                    )
                    if let tips = tipsList?.tips, !tips.isEmpty {
                        ForEach(tips, id: \.id) { txn in
                            TransactionRowView(transaction: txn)
                                .padding(.horizontal,8)
                                .background(.white)
                                .cornerRadius(12)
                                .padding(.horizontal,12)
                        }
                    }
                    else  {
                        NoDataView(message: "No Tips Found")
                    }
                }
                .padding(.top)
            }.safeAreaInset(edge: .bottom) {
                // MARK: - Fixed Bottom Button
//                PrimaryButton(title: AppString.submit.localized, isOutLine: false, onButtonClick: {
//                    // Action
//                },btnTextColor: .white)
//                .padding(.horizontal)
//                .padding(.vertical, 0)
//                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
        .onAppear() {
            Task {
                await loadTipsData()
            }
        }
    }
    
    func loadTipsData() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await tipsViewModel.getTipsData()
        await SVProgressHUD.dismiss()
        
        if tipsViewModel.getTipsResponse?.status != "success" {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: tipsViewModel.getTipsResponse?.message ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK",
                sheetThemeColor: .pinkBtn
            )
            withAnimation(.snappy) { showError = true }
        } else {
            tipsList = tipsViewModel.getTipsResponse?.data
        }
    }
}



enum TipsValue : String, CaseIterable, CustomStringConvertible{
    
    case tipsToday = "Tips today"
    case totalTips = "Total tips"
    //    case totalTi = "Testing"
    
    var description: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    
    var labelOlt : String{
        switch self {
            
        case .tipsToday:
            return "284"
        case .totalTips:
            return "$5.2K"
//        case .totalTi :
//            return "$5.2K"

        }
    }
}

// MARK: - Preview
#Preview {
    TipsScreen()
}

