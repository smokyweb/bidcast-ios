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
    
    enum Discoverability: String {
        case publicMode
        case privateMode
    }
    
    @State private var repeatsOptions: [String] = ["Does Not Repeat", "Daily", "Weekly"]
    @State private var selectedRepeatOptions = "Does Not Repeat"
    @State private var isExplicitContent: Bool = false
    
    @State private var selectedDiscoverability: Discoverability? = .publicMode
    
    @State private var languageOptions: [String] = ["Arabic",
                                                    "Brazil",
                                                    "English",
                                                    "Hindi",
                                                    "Japanese",
                                                    "Korean",
                                                    "Russian",
                                                    "Spanish",
                                                    "Vietnamese"
                                                    ]
    @State private var selectedLanguageOptions = "English"
    
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
            
            ScrollView {
                
                TitleWithLine(title: "Select the category that most accurately describes your show, and how you would like to sell.", lineLength: 0)
                
                VStack(spacing: 10) {
                    
                    DropDownSelection(
                        options: $categoryNames, floatingLabel:"Category",
                        hint: "Select Category",
                        selected: $selectedCategory,
                        anchor: .bottom,
                        custFontName: poppinsSemiBold,
                        custFontSize:  14.0,
                        custCategory : poppinsRegular,
                        custCategorySize : 13.0,
                        onOptionSelected: { value in
                            
                            if let id = categoryList.first(where: { $0.name == value })?.id {
                                request.category_id = "\(id)"
                                
                            } else {
                                request.category_id = ""
                            }
                        }
                    )
                    .zIndex(1201.0)
                    .padding([.leading,.trailing],16)
                    
                    DropDownSelection(
                        options: $auctionTypeNames, floatingLabel:"Auction",
                        hint: "Select Auction",
                        selected: $selectedAuctionType,
                        anchor: .bottom,
                        custFontName: poppinsSemiBold,
                        custFontSize:  14.0,
                        custCategory : poppinsRegular,
                        custCategorySize : 13.0,
                        onOptionSelected: { value in
                            
                            if let id = auctionTypeList.first(where: { $0.name == value })?.id {
                                request.auction_type_id = "\(id)"
                                
                            } else {
                                request.auction_type_id = ""
                            }
                        }
                    )
                    .zIndex(1201.0)
                    .padding([.leading,.trailing],16)
                    
                    DropDownSelection(
                        options: $repeatsOptions, floatingLabel:"Repeats",
                        hint: "Select Repeats",
                        selected: $selectedRepeatOptions,
                        anchor: .bottom,
                        custFontName: poppinsSemiBold,
                        custFontSize:  14.0,
                        custCategory : poppinsRegular,
                        custCategorySize : 13.0,
                        onOptionSelected: { value in
                            if value == "Does Not Repeat" {
                                request.repeats = ""
                            }
                            else  {
                                request.repeats = value
                            }
                        }
                    )
                    .zIndex(1201.0)
                    .padding([.leading,.trailing],16)
                    
                    SectionHeaderView(title: "Content Settings")
                        .padding([.leading,.trailing],16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $isExplicitContent) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Explicit Content")
                                    .font(.custom(poppinsBold, size: 18))
                                    .foregroundColor(.primary)
                                
                                Text("Turn this on if your stream contains explicit contents")
                                    .font(.custom(poppinsRegular, size: 14))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isExplicitContent ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: isExplicitContent ? 2 : 1)
                                .animation(.easeInOut(duration: 0.2), value: isExplicitContent)
                        )
                    }
                    .padding([.leading,.trailing],16)
                    
                    SectionHeaderView(title: "Primary Language")
                        .padding([.leading,.trailing],16)

                    DropDownSelection(
                        options: $languageOptions,
                        floatingLabel:"",
                        description: "Set the primary language of your show to help users to find your show.",
                        hint: "Select Language",
                        selected: $selectedLanguageOptions,
                        anchor: .bottom,
                        custFontName: poppinsSemiBold,
                        custFontSize:  14.0,
                        custCategory : poppinsRegular,
                        custCategorySize : 13.0,
                        onOptionSelected: { value in
                            request.primaryLanguage = value
                            //                        if let id = auctionTypeList.first(where: { $0.name == value })?.id {
                            //                            request.auction_type_id = "\(id)"
                            //
                            //                        } else {
                            //                            request.auction_type_id = ""
                            //                        }
                        }
                    )
                    .zIndex(1201.0)
                    .padding([.leading,.trailing],16)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Show Discoverability")
                            .font(.custom(poppinsBold, size: 18))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        Text("Choose how you want your show to be discovered.")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        ShippingMethodCard(
                            icon: "globe.americas.fill",
                            title: "Public",
                            description: "Discoverable by everyone",
                            linkText: nil,
                            isSelected: selectedDiscoverability == .publicMode,
                            selectionType: .radio
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDiscoverability = .publicMode
                                request.primaryLanguage = "public"
                            }
                        }
                        .padding(.vertical, 8)
                        
                        ShippingMethodCard(
                            icon: "lock.shield.fill",
                            title: "Private",
                            description: "Only discoverable through sharing",
                            linkText: nil,
                            isSelected: selectedDiscoverability == .privateMode,
                            selectionType: .radio
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDiscoverability = .privateMode
                                request.primaryLanguage = "private"
                            }
                        }
                        .padding(.vertical, 8)
                    }
                  
                    .padding(.vertical, 12)
                    
                    Spacer()
                    PrimaryButton(title: AppString.continueBtn.localized, isOutLine: false, onButtonClick: {
//                        request.title = title
                        print("Store title,category,auction \(request)")
                        request.isExplicitContent = isExplicitContent
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
                
                .padding(.top , 10)
            }
            CusNavLink(doNavigate: $navigateToThumbnail, destination: SelectThumbnailScreen(request:$request,fromPrepare: $fromPrepare,backToPrepare: $backToPrepare,delegate: delegate))
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.bg.opacity(0.5))
        
        .onFirstAppear {
            request.discoverablitity = "public"
            Task {
                guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }

                SVProgressHUD.show()
                self.viewModel.errorMessage?.removeAll()

                async let categoryResponse: () = self.viewModel.getCategoryList(param: CategoryRequest(category_id: ""))
                async let auctionResponse: () = self.viewModel.getAuctionList()

                let (_, _) = await (categoryResponse, auctionResponse)
                await SVProgressHUD.dismiss()

                categorySuccess()
                auctionSuccess()
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
            self.categoryList = response.data ?? []
            self.categoryNames = self.categoryList.map { $0.name ?? "No Category" }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type ?? "",
                message: response.message ?? "",
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
