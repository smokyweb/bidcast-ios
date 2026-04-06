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
//    @Binding var backToPrepare : Bool
    
    @State var showSubCategorySheet = false
    @State var selectedSubCategory = ""
    @State var subCategoryList: [CategoryDataModel] = []
    @State var subCategoryName : [String] = [""]
    @State var extraFields: [ExtraFieldModel] = []
    @State var selectedOption: Set<String> = []
    
    var viewModel = SelectCategoryViewModel()
    @EnvironmentObject var coordinator: LetsPrepareCoordinator
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        VStack {
            
            VStack{
                PrimaryHeader(
                    title: "Select Category".localized,
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"],
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
                            
                            Task{
                                
                                await performAPICalls(
                                    isConcurrent: false,
                                    onError: { error in
                                        showSubCategorySheet = false
                                    },
                                    onSuccess: {
                                        self.subCategoryList.removeAll()
                                        let response = self.viewModel.categoryResponse
                                        if response != nil{
                                            self.subCategoryList = response.data ?? []
                                            self.subCategoryName = self.subCategoryList.map { $0.name ?? ""}
                                        }
                                        if subCategoryList.count != 0{
                                            showSubCategorySheet = true
                                        }
                                    }
                                ) {
                                    extraFields = []
                                    selectedSubCategory = ""
                                    selectedOption = []
                                    request.sub_category_id = ""
                                    let request = CategoryRequest(category_id: request.category_id)
                                    SVProgressHUD.show()
                                    try await self.viewModel.getSubCategoryList(param: request)
                                    await SVProgressHUD.dismiss()
                                }
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
                                request.repeat_value = ""
                                request.is_repeat = false
                            }
                            else  {
                                request.is_repeat = true
                                request.repeat_value = value
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
                        .toggleStyle(SwitchToggleStyle(tint: .defaultTheme))
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isExplicitContent ? Color.defaultTheme.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: isExplicitContent ? 2 : 1)
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
                            request.language = value
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
                                if selectedDiscoverability == .publicMode{
                                    request.show_discoverability = "public"
                                }else{
                                    request.show_discoverability = "private"
                                }
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
                                if selectedDiscoverability == .publicMode{
                                    request.show_discoverability = "public"
                                }else{
                                    request.show_discoverability = "private"
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                  
                    .padding(.vertical, 12)
                    
                    Spacer()
                    PrimaryButton(title: AppString.continueBtn.localized, isOutLine: false, onButtonClick: {
//                        request.title = title
                        print("Store title,category,auction,repeat \(request)")
                        request.is_explicit = isExplicitContent
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
                        
                    },cornerRadius : 32.0, btnTextColor: .white)
                    .padding(.bottom, 0)
                }
                
                .padding(.top , 10)
            }
            CusNavLink(doNavigate: $navigateToThumbnail, destination: SelectThumbnailScreen(request:$request,fromPrepare: $fromPrepare))
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.backGround)
        .onChange(of: coordinator.shouldNavigateBackToPrepare) { shouldNavigate in
            guard shouldNavigate, fromPrepare else { return }
            navigateToThumbnail = false
        }
        
        .onFirstAppear {
//            request.show_discoverability = "public"
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
                
                populateExistingData()
            }
        }
       
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showSubCategorySheet,
            height: selectedOption.count < 4 ? screenHeight * 0.4 : screenHeight/1.7,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                showSubCategorySheet = false
            },
            content: {
                SelectionBottomSheet(
                    title: "Select sub category",
                    message: "Please select subcategory.",
                    options: $subCategoryName,
                    selectedOptions: $selectedOption,
                    onSelectionDone: { selectedIndexes in
                        if let index = selectedIndexes.first {
                            let selectedValue = subCategoryList[index]
                            selectedSubCategory = selectedValue.name ?? ""
                            request.sub_category_id = "\(selectedValue.id ?? 0)"
                            selectedCategory = "\(selectedCategory) (\(selectedValue.name ?? ""))"
                            print("Selected SubCategory: \(selectedValue.name ?? "")")
                            self.extraFields = selectedValue.extra_fields ?? []
//                                    if let extraFields =  self.viewModel.categoryResponse?.data[index].extra_fields{
//
//                                    }
                        }
                        showSubCategorySheet = false
                    }
                )
       
            }
        )
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
    
    func populateExistingData() {
            // 1. Set Category
        if !request.category_id.isEmpty,
              let categoryId = Int(request.category_id),
              let category = categoryList.first(where: { $0.id == categoryId }) {

               selectedCategory = category.name ?? ""

               // 🔹 Fetch subcategories for existing category
               Task {
                   await fetchSubCategoryAndPopulate()
               }
           }
            
            // 2. Set Auction Type
            if !request.auction_type_id.isEmpty,
               let auctionId = Int(request.auction_type_id),
               let auction = auctionTypeList.first(where: { $0.id == auctionId }) {
                selectedAuctionType = auction.name ?? ""
            }
            
            // 3. Set Repeats
            if request.is_repeat {
                selectedRepeatOptions = request.repeat_value.isEmpty ? "Does Not Repeat" : request.repeat_value
            } else {
                selectedRepeatOptions = "Does Not Repeat"
            }
            
            // 4. Set Explicit Content
            isExplicitContent = request.is_explicit
            
            // 5. Set Language
            if !request.language.isEmpty {
                selectedLanguageOptions = request.language.capitalized
            }
            
            // 6. Set Discoverability
            if request.show_discoverability.lowercased() == "public" {
                selectedDiscoverability = .publicMode
            } else if request.show_discoverability.lowercased() == "private" {
                selectedDiscoverability = .privateMode
            }
            
            print("✅ Data populated:")
            print("- Category: \(selectedCategory)")
            print("- Auction: \(selectedAuctionType)")
            print("- Repeats: \(selectedRepeatOptions)")
            print("- Explicit: \(isExplicitContent)")
            print("- Language: \(selectedLanguageOptions)")
            print("- Discoverability: \(selectedDiscoverability?.rawValue ?? "none")")
        }
    func fetchSubCategoryAndPopulate() async {

        guard !request.category_id.isEmpty else { return }

        SVProgressHUD.show()
        defer { SVProgressHUD.dismiss() }

        do {
            let param = CategoryRequest(category_id: request.category_id)
            try await viewModel.getSubCategoryList(param: param)

            let response = viewModel.categoryResponse
            guard response.status == "success",
                  let list = response.data else { return }

            // Populate list
            self.subCategoryList = list
            self.subCategoryName = list.map { $0.name ?? "" }

            // Restore selected subcategory
            if request.sub_category_id != "" && request.sub_category_id != nil{
               let subId = Int(request.sub_category_id ?? "")
                let index = list.firstIndex(where: { $0.id == subId }) ?? 0

                let selected = list[index]
                selectedSubCategory = selected.name ?? ""

                // Append subcategory to category title
                selectedCategory = "\(selectedCategory) (\(selectedSubCategory))"

                // Restore bottom sheet selection
                selectedOption = [selectedSubCategory]

                // Restore extra fields
                extraFields = selected.extra_fields ?? []
            }

        } catch {
            print("❌ SubCategory fetch failed")
        }
    }

    
}

//
//#Preview {
//    SelectCategoryScreen(, title: <#Binding<String>#>)
//}
