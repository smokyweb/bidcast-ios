//
//  SelectCategoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import SwiftUI
import AlertToast

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
    
    @Binding var title : String
    
    var viewModel = SelectCategoryViewModel()


    var body: some View {
        VStack {
            // Top Header
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
            .background(Color.white)
            
            // Label
            TitleWithLine(title: "Select the category that most accurately describes your show, and how you would like to sell.", lineLength: 0)
                .padding([.leading,.trailing] ,40)
            
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
                    anchor: .top
                )
                .onChange(of: selectedCategory) { newValue in
                   print("The catory count \(categoryNames)")
                }
                
                // Drop Down for Auction Type
                DropDownTextField(
                    hint: "Select Auction Type",
                    text: $selectedAuctionType,
                    options: $auctionTypeNames,
                    leadingIcon: .location,
                    showLeadingIcon: false,
                    showTrailingIcon: false,
                    showDropDownIcon: true,
                    anchor: .bottom
                )
                
                Spacer()
                PrimaryButton(title: AppString.continueBtn.localized, isOutLine: false, onButtonClick: {
                    navigateToThumbnail = true
                },cornerRadius : 12.0, btnTextColor: .white)
                .padding(.bottom, 0)
            }
            .zIndex(1400.0)
            .padding(.top , 10)
            .padding(.horizontal)
            CusNavLink(doNavigate: $navigateToThumbnail, destination: SelectThumbnailScreen())
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.bg.opacity(0.5))
        .onAppear {
            observe()
            self.viewModel.getCategoryList()
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

    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                categorySuccess()
            case .error(let error):
                let msg = error?.localizedDescription ?? AppString.error.localized
                alertType = .sheetType(icon: .alert, title: AppString.error.localized, message: msg, primaryBtnText: "", secondaryBtnText: AppString.ok.localized)
                showError = true
            }
        }
    }

    func categorySuccess() {
        if viewModel.request == "Category" {
            if let response = viewModel.categoryDict {
                if response.status == "success" {
                    self.categoryList = response.data
                    self.categoryNames = response.data.map { $0.name ?? "No Category" }
                    self.viewModel.getAuctionList()
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
        } else if viewModel.request == "Auction" {
            if let response = viewModel.AuctionDict {
                if response.status == "success" {
                    self.auctionTypeList = response.data
                    self.auctionTypeNames = response.data.map { $0.name ?? "No Auction" }
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
    }
}
//
//#Preview {
//    SelectCategoryScreen(, title: <#Binding<String>#>)
//}
