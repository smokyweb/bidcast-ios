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
        CategoryDataModel(id: 1, name: "Free Pickup", image: "shop", color: "#E5E7EB",subLabel: "Local pickup settings"),
        CategoryDataModel(id: 2, name: "Domestic Shipments", image: "shipping", color: "#E5E7EB",subLabel:"National delivery options"),
        CategoryDataModel(id: 3, name: "Shipping Costs", image: "dollar", color: "#E5E7EB",subLabel:"Manage shipping rates"),
        CategoryDataModel(id: 4, name: "Shipping Profile", image: "ic_setting", color: "#E5E7EB",subLabel:"Custom shipping profiles")
    ]
    
    let transactions = [
        Transaction(title: "Purchase from John", date: Date(timeIntervalSince1970: 1742841600), amount: 1250.00, isOutgoing: true)
    ]



    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            VStack{
                PrimaryHeader(
                    title: AppString.Shipping,
                    isForBoth : true,
                    leadingImgArr: [.icBack,.appName],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
           
            // MARK: - Scrollable Show List
            ScrollView {
                VStack(spacing: 10) {
                    TwoVerticalLabelCell(dataModel: ShippingValue.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description.localized})
                    
                    ForEach(0 ..< categoryList.count, id: \.self) { ind in
//                            print("\(ind)")
//                            print(self.title[ind])
                        ListCell( isComeFrom: "ShippingScreen",image: categoryList[ind].image ?? "", title: categoryList[ind].name ?? "", vectorImg: .icArrowUp,subLabel : categoryList[ind].subLabel ?? "", tintColot: categoryList[ind].color ?? "",imgViewSize : 40.0,imgSize:24.0)
                            .padding(.horizontal,Leading)
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
    case returns = "Returns"
    
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

