//
//  TransactionsTabView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUICore

struct TransactionsTabView: View {
   @State var title = ""
    @State var subLabel = ""
    @State var price = ""
    
    
    var body: some View {
      
            VStack(spacing: 15) {
                
                
                    ListCell(
                        isComeFrom: "Wallet",
                        image: "",
                        title: title,
                        vectorImg: .icArrowUp,
                        subLabel: "xxxx-xxxx-xxxx-\(subLabel)",
                        tintColot: "",
                        isVectorImgHidden: true,
                        isDisplayPrice: true,
                        price: "$\(price)"
                    )
                
            }
            .padding(.horizontal, 0) 
        
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

