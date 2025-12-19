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
    @State private var isLoading: Bool = true
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
            TipSummaryItem(title: "Today Tips", value: "$ \(summary.todayTips ?? 0)")
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            VStack{
                PrimaryHeader(
                    title: AppString.Tips,
                    isForLogo: false,
                    leadingImgArr: [.icBack],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(Color.white)
                .frame(height: 50)
            }
           
            // MARK: - Scrollable Show List
            ScrollView {
                VStack(spacing: 10) {
                    
                    TwoVerticalLabelCell(
                        dataModel: summaryItems,
                        topLabel: { $0.title },
                        bottomLabel: { $0.value }
                    )
                    TipsListView(tips: tipsList?.tips, isLoading: $isLoading)
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
        isLoading = true
        await tipsViewModel.getTipsData()
        await SVProgressHUD.dismiss()
        
        if tipsViewModel.getTipsResponse?.status != "success" {
            isLoading  = false
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
            isLoading  = false
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



struct TipsListView: View {

    let tips: [Tip]?
    @Binding var isLoading: Bool
    var isComeFrom: String = ""

    var body: some View {
        VStack(spacing: 12) {

            if isLoading {
                ForEach(0..<10, id: \.self) { _ in
                    TipCardShimmerView()
                        .padding(.horizontal, 12)
                }

            } else if let tips = tips, !tips.isEmpty {

                ForEach(tips, id: \.id) { tip in
                    TipCardView(
                        transaction: tip,
                        isComeFrom: isComeFrom
                    )
                    .padding(.horizontal, 12)
                }

            } else {
                NoDataView(message: "No Tips Found")
            }
        }
    }
}

// MARK: - Tip Card
struct TipCardView: View {

    let transaction: Tip
    var isComeFrom: String = ""

    @State private var animateBorder = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Profile Image
            if isComeFrom != "Wallet" {
                profileImage
            }

            // Text Content
            VStack(alignment: .leading, spacing: 6) {

                Text("\(transaction.user?.name ?? "") tipped \(formattedAmount) during show")
//                Text("\(transaction.user?.name ?? "") tipped \(formattedAmount) during \(transaction.showTitle ?? "")")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(formatISODateString(transaction.createdAt ?? ""))
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Message Icon
            Image(systemName: "bubble.right")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.defaultTheme)
        }
        .padding(14)
        .background(.white
        )
        .onAppear {
            animateBorder = true
        }
    }

    private var formattedAmount: String {
        let value = transaction.total?.toDouble ?? 0.0
        return value.formatted(.currency(code: "USD"))
    }

    private var profileImage: some View {
        Group {
            if let urlString = transaction.user?.profileImage,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
            } else {
                Image("user_dummy")
                    .resizable()
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: 44, height: 44)
        .clipShape(Circle())
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

// MARK: - Shimmer Card
struct TipCardShimmerView: View {

    var body: some View {
        HStack(spacing: 12) {

            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .shimmer()

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 14)
                    .shimmer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 12)
                    .shimmer()
            }

            Spacer()

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 22, height: 18)
                .shimmer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        )
    }
}
