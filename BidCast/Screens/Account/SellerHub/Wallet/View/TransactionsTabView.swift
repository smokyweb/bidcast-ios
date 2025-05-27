//
//  TransactionsTabView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUICore

struct TransactionsTabView: View {
    var transactions: [Transaction]
    @State var categoryList: [CategoryDataModel] = [
        CategoryDataModel(id: 1, name: "Electronics", image: "electronics_icon", color: "#FF5733"),
        CategoryDataModel(id: 2, name: "Fashion", image: "fashion_icon", color: "#33C1FF"),
        CategoryDataModel(id: 3, name: "Home", image: "home_icon", color: "#28A745"),
        CategoryDataModel(id: 4, name: "Books", image: "books_icon", color: "#FFC300")
    ]
    @State private var selectedButton: WalletSegment = .all
    
    var body: some View {
        if transactions.isEmpty {
            Text("No transactions yet.")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, minHeight: 200)
        } else {
            VStack(spacing: 15) {
                VStack(spacing: 10) {
                    SegmentedControlView(segments: WalletSegment.allCases, selectedSegment: $selectedButton, isWithBorder: true)
                }
                ForEach(0 ..< categoryList.count, id: \.self) { ind in
                    ListCell(
                        isComeFrom: "Wallet",
                        image: categoryList[ind].image ?? "",
                        title: categoryList[ind].name ?? "",
                        vectorImg: .icArrowUp,
                        subLabel: "BidSwipe",
                        tintColot: categoryList[ind].color ?? ""
                    )
                }
            }
            .padding(.horizontal, 0) 
        }
    }
}

//MARK: WalletSegment.
enum WalletSegment: String, CaseIterable, CustomStringConvertible {
    case all = "All"
    case processing = "Processing"
    case complete = "Complete"
    case withdrawal = "Withdrawal"

    var description: String {
        return rawValue
    }
}

