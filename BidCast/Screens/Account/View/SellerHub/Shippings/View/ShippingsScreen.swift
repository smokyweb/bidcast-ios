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
    @StateObject private var shippingViewModel = ShippingViewModel()
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var shippingDetail: ShippingSettingsDataModel?
    @State private var hudMsg: String = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    // MC: cmpbefoac00003ghgmjc4msqo — #47 Shipping Profile cell navigation
    @State private var navigateToShippingProfiles = false
    @State private var navigateToFreePickup = false
    @State private var navigateToDomestic = false
    @State private var navigateToShippingCosts = false
    
    
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
                    isForBoth : false,
                    leadingImgArr: ["chevron.left"],
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
                    
                    // #47: Each cell navigates to its section
                    ForEach(0 ..< categoryList.count, id: \.self) { ind in
                        ListCell(
                            isComeFrom: "ShippingScreen",
                            image: categoryList[ind].image ?? "",
                            title: categoryList[ind].name ?? "",
                            vectorImg: .icArrowUp,
                            subLabel: categoryList[ind].subLabel ?? "",
                            tintColot: categoryList[ind].color ?? "",
                            imgViewSize: 40.0,
                            imgSize: 24.0,
                            onTapMenuCell: {
                                switch ind {
                                case 0: navigateToFreePickup = true
                                case 1: navigateToDomestic = true
                                case 2: navigateToShippingCosts = true
                                case 3: navigateToShippingProfiles = true
                                default: break
                                }
                            }
                        )
                        .padding(.horizontal, Leading)
                    }
                }
                .padding(.top)
               
            }
        }
        .background(Color(.backGround))
        // #47: Navigation links for each shipping category cell
        .background(Group {
            NavigationLink(destination: FreePickupScreen(changeFreeToggle: { _ in })
                .navigationBarBackButtonHidden(true), isActive: $navigateToFreePickup) { EmptyView() }
            NavigationLink(destination: DomesticShipmentsScreen(shippingDetail: shippingDetail)
                .navigationBarBackButtonHidden(true), isActive: $navigateToDomestic) { EmptyView() }
            NavigationLink(destination: ShippingCostsScreen(shippingDetail: shippingDetail)
                .navigationBarBackButtonHidden(true), isActive: $navigateToShippingCosts) { EmptyView() }
            NavigationLink(destination: ShippingProfilesListScreen()
                .navigationBarBackButtonHidden(true), isActive: $navigateToShippingProfiles) { EmptyView() }
        })
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
        
        .onFirstAppear(perform: {
            Task{
                
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        var errorMessage = shippingViewModel.errorMessage ?? shippingViewModel.errorMessage
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        // On success
                        successShippingProfiles()
                 
                    }
                    
                ) {
                    // 👇 These run in parallel
                
                    async let shippingTask: () = shippingViewModel.getShippinDetails()
                    
                    // Wait for all
                    _ = try await (shippingTask)
                }
            }
        })
    }
    
    private func successShippingProfiles() {
        let response = shippingViewModel.ShippingSettingsDataModeldic
        self.shippingDetail = response?.data
        print(shippingDetail ?? {})
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
//#Preview {
//    ShippingsScreen()
//}
//
