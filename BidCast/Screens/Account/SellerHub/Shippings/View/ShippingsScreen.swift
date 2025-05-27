//
//  ShippingsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast

// MARK: - ShippingsScreen View
struct ShippingsScreen: View {
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    
    @State var categoryList: [CategoryDataModel] = [
        CategoryDataModel(id: 1, name: "Electronics", image: "electronics_icon", color: "#FF5733"),
        CategoryDataModel(id: 2, name: "Fashion", image: "fashion_icon", color: "#33C1FF"),
        CategoryDataModel(id: 3, name: "Home", image: "home_icon", color: "#28A745"),
        CategoryDataModel(id: 4, name: "Books", image: "books_icon", color: "#FFC300")
    ]
    
    let transactions = [
        Transaction(title: "Purchase from John", date: Date(timeIntervalSince1970: 1742841600), amount: 1250.00, isOutgoing: true)
    ]



    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            PrimaryHeader(
                title: "Offers",
                isForLogo : true,
                leadingImgArr: [.appName],
                trailingImgArr: [.icSetting],
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
                    TwoVerticalLabelCell(dataModel: ShippingValue.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description.localized})
                    
                    ForEach(0 ..< categoryList.count, id: \.self) { ind in
//                            print("\(ind)")
//                            print(self.title[ind])
                        ListCell( isComeFrom: "ShippingScreen",image: categoryList[ind].image ?? "", title: categoryList[ind].name ?? "", vectorImg: .icArrowUp,subLabel : "BidSwipe",tintColot: categoryList[ind].color ?? "")
                           
                       
                    }
                }
                .padding(.top)
               
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
    }
}


//MARK: ShippingValue.
enum ShippingValue : String, CaseIterable, CustomStringConvertible{
    
    case pending = "Pending"
    case delivered = "Delivered"
    case returns = "Return"
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    
    var labelOlt : String{
        switch self {
            
        case .pending:
            return "12"
        case .delivered:
            return "45"
        case .returns :
            return "23"

        }
    }
}

// MARK: - Preview
#Preview {
    ShippingsScreen()
}

