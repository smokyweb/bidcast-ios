//
//  SelectCategoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct SelectCategoryScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var categoryNames: [String] = []
    @State private var auctionTypeNames: [String] = []
    @State private var selectedCategory = ""
    @State private var selectedAuctionType = ""
    @State private var categoryList: [CategoryDataModel] = []
    @State private var auctionTypeList: [AuctionDataModel] = []
    @State var navigateToThumbnail : Bool = false
    @Binding var request : StoreScheduleShowRequest
    @Binding var title : String
    @Binding var fromPrepare : Bool
    @Binding var backToPrepare : Bool
    var viewModel = SelectCategoryViewModel()
    var delegate: ShowStepDelegate?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        VStack {
            
            VStack{
                PrimaryHeader(
                    title: "Select Category".localized,
                    isForLogo: false,
                    leadingImgArr: [.icBack],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            
          
            TitleWithLine(title: "Select the category that most accurately describes your show, and how you would like to sell.", lineLength: 0)
//                .padding([.leading,.trailing] ,40)
            
            VStack(spacing: 10) {
                // Drop Down for Category
                DropDownTextField(
                    hint: "Select Category",
                    text: $selectedCategory,
                    options: $categoryNames,
                    leadingIcon: .location,
                    showLeadingIcon: false,
                    showTrailingIcon: false,
                    showDropDownIcon: true,
                    onOptionSelected: { value in
                        if let id = categoryList.first(where: { $0.name == value })?.id {
                            request.category_id = "\(id)"
                            
                        } else {
                            request.category_id = ""
                        }
                    }, anchor: .top
                )
                
                
                // Drop Down for Auction Type
                DropDownTextField(
                    hint: "Select Auction Type",
                    text: $selectedAuctionType,
                    options: $auctionTypeNames,
                    leadingIcon: .location,
                    showLeadingIcon: false,
                    showTrailingIcon: false,
                    showDropDownIcon: true,
                    onOptionSelected: { value in
                        if let id = auctionTypeList.first(where: { $0.name == value })?.id {
                            request.auction_type_id = "\(id)"
                            
                        } else {
                            request.auction_type_id = ""
                        }
                    },
                    anchor: .bottom
                )
                
                Spacer()
                PrimaryButton(title: AppString.continueBtn.localized, isOutLine: false, onButtonClick: {
                    request.title = title
                    print("Store title,category,auction \(request)")
                    guard !request.title.isEmpty else {
                        hudMsg = "Please enter title"
                            showhud = true
                            return
                    }
                    guard !request.category_id.isEmpty else {
                        hudMsg = "Please enter category type"
                            showhud = true
                            return
                    }
                    guard !request.auction_type_id.isEmpty else {
                        hudMsg = "Please enter auction type"
                            showhud = true
                            return
                    }
                    navigateToThumbnail = true
                    
                },cornerRadius : 12.0, btnTextColor: .white)
                .padding(.bottom, 0)
            }
            .zIndex(1400.0)
            .padding(.top , 10)
//            .padding(.horizontal)
            CusNavLink(doNavigate: $navigateToThumbnail, destination: SelectThumbnailScreen(request:$request,fromPrepare: $fromPrepare,backToPrepare: $backToPrepare,delegate: delegate))
        }
        .background(Color.bg.opacity(0.5))
        .onAppear {
            
            Task{
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await self.viewModel.getCategoryList()
                await SVProgressHUD.dismiss()
                categorySuccess()
                
            }
        }
       
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    // Handle response when primary button clicked
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    
   
    
    func categorySuccess() {
        let response = viewModel.categoryResponse
        if response.status == "success" {
            self.categoryList = response.data ?? [CategoryDataModel]()
            self.categoryNames = (response.data ?? []).map { $0.name ?? "No Category" }
            Task{
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await  self.viewModel.getAuctionList()
                await SVProgressHUD.dismiss()
                auctionSuccess()
            }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
        
    }
    func auctionSuccess(){
        let response = viewModel.auctionResponse
        if response.status == "success" {
            self.auctionTypeList = response.data ?? [AuctionDataModel]()
            self.auctionTypeNames = (response.data ?? []).map { $0.name ?? "No Auction" }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
    
}

//
//#Preview {
//    SelectCategoryScreen(, title: <#Binding<String>#>)
//}
