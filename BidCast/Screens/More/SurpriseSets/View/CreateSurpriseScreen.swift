//
//  CreateSurpriseScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/02/26.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct CreateSurpriseScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var segment: lisProductScreenSegment = .Buyit
    @State private var selectedFormat: SalesFormat = .buyItNow
    
    @State private var selectedCategory = ""
    @State private var selectedCateporyId = -1
    @State private var categoryNames: [String] = []
    @State private var categoryList: [CategoryDataModel] = []
    
    @State private var selectedSubCategory = ""
    @State private var subCategoryList: [CategoryDataModel] = []
    @State private var subCategoryName : [String] = [""]
    
    @State var showSubCategorySheet = false
    @State var selectedOption: Set<String> = []
    
    @State private var profiles: [StoreShippingModel] = []
    @State var shippingProfileNames: [String] = []
    @State var selectedShippingProfileName: String = ""
    @State var selectedShippingProfileId: Int = 0
    @StateObject private var viewModel = SurpriseViewModel()
    
    @State private var openShippingSheet = false
    
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var isCategoryLocked: Bool = false
    
    @State private var navigateToAddProduct = false
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    @State private var showHud = false
    @State private var hudMsg = ""
    
    @State private var surpriseName        = ""
    @State private var surpriseDescription = ""
    @State private var buyInPrice          = ""
    @State private var productRows:        [ProductRow] = []
    @State private var isAutoRandomizeOn = false
    @State private var isQuickSpinOn = true
    
    var body: some View {
        VStack{
            VStack{
                PrimaryHeader(
                    title: "Create Surprise Set".localized,
                    isForLogo : false, leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            .frame(height:  50)
            .background(Color.white)
            
            ScrollView(showsIndicators:false){
                VStack(alignment:.leading,spacing:12){
                    
                    Text("Surprise set Setup")
                        .font(.custom(robotoMedium, size: 18.0))
                        .foregroundStyle(.text)
                        .padding(.horizontal,12)
                    
                    CustomSegmentedControl(preselectedIndex: $segment, options: lisProductScreenSegment.allCases)
                        .onChange(of: segment) { newSegment in
                            if segment == .Buyit{
                                selectedFormat = .buyItNow
                            }else{
                                selectedFormat = .auction
                            }
                            
                        }
                        .padding(.horizontal,12)
                    
                    AuthTextField(
                        floatingLabel: "",
                        placeholder: "Enter surprise set name".localized,
                        icon: .menuProfile,
                        text: $surpriseName,
                        isIconDisplay : false,
                        custFontName : robotoMedium,
                        custFontSize : 14.0,
                        enteredText:  { title in
                            surpriseName = title
                        })
                    .keyboardType(.alphabet)
                    .padding([.top,.bottom],4)
                    .padding(.horizontal,0)
                    
                    DescriptionFieldView(
                        description: $surpriseDescription,
                        custFontName : robotoMedium,
                        custFontSize : 14.0
                    )
                    { message in
                        surpriseDescription = message
                    }
                    .padding(.horizontal,0)
                    
                    PrimaryButton(
                        title: productRows.isEmpty
                        ? "Manage product"
                        : "Manage product (\(productRows.count))",
                        isOutLine: false,
                        onButtonClick: {
                            print("hell")
                            //                            guard selectedCateporyId != -1 else { return }
                            navigateToAddProduct = true
                        },
                        btnTextColor:.defaultTheme,
                        btnColor: .defaultThemeLight)
                    .padding(.horizontal,0)
                    
                    DropDownSelection(
                        options: $shippingProfileNames, floatingLabel:"Shipping Profile",
                        hint: "Select",
                        selected: $selectedShippingProfileName,
                        anchor: .bottom,
                        custFontName: robotoMedium,
                        custFontSize:  14.0,
                        custCategory : robotoRegular,
                        custCategorySize : 13.0,
                        onOptionSelected: { value in
                            //string value not id -> get Id from name
                            if let profile = profiles.first(where: { $0.name == value }) {
                                selectedShippingProfileId = profile.id != nil ? profile.id ?? 0 : -1
                            }
                            
                        }
                    )
                    .padding(.horizontal,12)
                    if segment == .Auction{
                        ToggleInfoCard(
                            items: [
                                .init(
                                    title: "Auto-Randomize",
                                    description: "After each product sells, the buyer will be randomly assigned. Turn off if you want to randomize manually.",
                                    tint: .defaultTheme,
                                    isOn: $isAutoRandomizeOn
                                ),
                                .init(
                                    title: "Quick Spin",
                                    description: "Turn off if you want a slower spin animation. This does not affect randomization.",
                                    tint: .defaultTheme,
                                    isOn: $isQuickSpinOn
                                )
                            ]
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    }

                    
                }
            }
            .padding(.horizontal)
            .background(.backGround)
            .zIndex(1000)
            VStack{
                PrimaryButton(title:"Submit",onButtonClick: {
                    validateAndSubmit()
                })
            }
            .padding(.bottom,12)
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.backGround)
        .onTapGesture {
            hideKeyboard()
        }
        .overlay(
            CustomBottomSheetView(
                isPresented: $openShippingSheet,
                config: config,
                primaryAction: {
                    withAnimation {
                        openShippingSheet = false
                        if viewModel.errorMessage == nil || viewModel.errorMessage == ""{
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                },
                secondaryAction: {
                    withAnimation {
                        openShippingSheet = false
                    }
                }
            )
            .ignoresSafeArea(.keyboard)
        )
        .sheet(isPresented: $navigateToAddProduct){
            ManageProductScreen(
                isBuyItNow: segment == .Buyit,
                onCancel:{
                    navigateToAddProduct = false
                },onAdded: { price , product in
                    navigateToAddProduct = false
                    productRows = product
                    buyInPrice = price
                })
            .presentationDetents([.fraction(0.60)])   // ✅ Bottom-sheet height
            .presentationCornerRadius(25)              // ✅ Rounded top corners
            .presentationDragIndicator(.hidden)
        }
        .toast(isPresenting: $showHud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight * 0.35, topBarCornerRadius: 25, showTopIndicator: false,
                     onDismiss: {
            if let errorMessage = viewModel.errorMessage {
                showError = false
                viewModel.errorMessage = nil
            }else{
                showError = true
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if let errorMessage = viewModel.errorMessage {
                        showError = false
                        viewModel.errorMessage = nil
                    }else{
                        self.presentationMode.wrappedValue.dismiss()
                        withAnimation {
                            showError = false
                            viewModel.errorMessage = nil
                        }
                    }
                }, onSecondaryClick: {
                    withAnimation {
                        showError = false
                        viewModel.errorMessage = nil
                    }
                })
            .ignoresSafeArea(.keyboard)
        })
        .onFirstAppear {
            Task{
                
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        var errorMessage = viewModel.errorMessage ?? viewModel.errorMessage
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        
                        successShippingProfiles()
                        
                    }
                    
                ) {
                    // 👇 These run in parallel
                    
                    async let shippingTask: () = viewModel.getShippingProfiles()
                    
                    // Wait for all
                    _ = try await (shippingTask)
                }
            }
        }
    }
    
    private func validateAndSubmit() {
        let trimmedName  = surpriseName.trimmingCharacters(in: .whitespaces)
        let trimmedDesc  = surpriseDescription.trimmingCharacters(in: .whitespaces)
        var trimmedPrice = buyInPrice.trimmingCharacters(in: .whitespaces)
      
        // Name
        if trimmedName.isEmpty {
            showValidationError("Surprise set name is required.")
            return
        }
        if trimmedName.count < 2 {
            showValidationError("Name must be at least 2 characters.")
            return
        }
        if trimmedName.count > 100 {
            showValidationError("Name must be under 100 characters.")
            return
        }
        
        // Description (optional)
        if !trimmedDesc.isEmpty && trimmedDesc.count > 500 {
            showValidationError("Description must be under 500 characters.")
            return
        }
        if productRows.count == 0{
            showValidationError("Please add the product")
            return
        }
        
        // Buy-in Price
    
        // Shipping
        if selectedShippingProfileName.isEmpty {
            showValidationError("Please select a shipping profile.")
            return
        }
        
        let autoRandomizer = isAutoRandomizeOn ? 1 : 0
        let quickSpin = isQuickSpinOn ? 1 : 0
        let type = segment == .Buyit ? "buy_it_now" : "auction"
        
        let productItems = productRows.map {
            ProductItem(
                name: $0.name,
                quantity: $0.quantity,
                description: $0.description
            )
        }
        if segment != .Buyit {
            trimmedPrice = "0"
        }
        let param = SurpriseRequest(name: surpriseName,
                                    type: type,
                                    description: surpriseDescription,
                                    price: trimmedPrice,
                                    shippingProfileId: selectedShippingProfileId, quickSpin: quickSpin, autoRandomizer: autoRandomizer, items: productItems)
        print(param)
            Task{
                
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        let errorMessage = viewModel.errorMessage ?? viewModel.errorMessage
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        
                        storeSuccess()
                        
                    }
                    
                ) {
                    
                    async let shippingTask: () = viewModel.storeSurpriseSet(param: param)
                    
                    _ = try await (shippingTask)
                }
            }
    }
    func storeSuccess(){
        let response = viewModel.surpriseResponse
        
        if response?.status == "success"{
            config = BottomSheetConfig(
                icon: "checkmark.circle.fill",
                title: response?.status ?? "",
                message: response?.message ?? "",
                primaryButtonTitle: "Okay",
                secondaryButtonTitle: nil,
                bottomPadding: -50
            )
            openShippingSheet = true
        }else{
          
        }
    }
    private func showValidationError(_ message: String) {
        hudMsg = message
        showHud = true
    }

    
    private func successShippingProfiles() {
        let response = viewModel.getShippingProfilesResponse
        self.profiles = response?.data ?? []
        if profiles.count != 0{
            openShippingSheet = false
            self.shippingProfileNames = profiles.map { $0.name ?? "" }
        }else{
            config = BottomSheetConfig(
                icon: "exclamationmark.circle",
                title: "Missing",
                message: "Please add Shipping profile first for the successful product creation.",
                primaryButtonTitle: "Add Shipping Profile",
                secondaryButtonTitle: nil,
                bottomPadding: -50
            )
            openShippingSheet = true
        }
    }
   
}

//#Preview {
//    CreateSurpriseScreen()
//}
import SwiftUI

struct ToggleInfoCard: View {

    struct Item: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let tint: Color
        @Binding var isOn: Bool
    }

    let items: [Item]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(items.indices, id: \.self) { index in
                let item = items[index]

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.custom(robotoMedium, size: 15))
                            .foregroundColor(.black)

                        Text(item.description)
                            .font(.custom(robotoRegular, size: 13))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Toggle("", isOn: item.$isOn)
                        .labelsHidden()
                        .tint(item.tint)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
            }
        }
    }
}
