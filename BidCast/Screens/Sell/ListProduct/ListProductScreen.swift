//
//  ListProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SVProgressHUD
import AlertToast

struct ListProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var categorySelect : String = ""
    @State var categoyList = [String]()
    @State var productTitle = ""
    @State var message = ""
    
    @State var isTappedFlash: Bool = false
    @State var isTappedAccept: Bool = false
    @State var isTappedReserve: Bool = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var categoryNames: [String] = []
    @State var selectedCategory = ""
    @State var categoryList: [CategoryDataModel] = []
    @State var shippingAddressName: [String] = []
    @State var shippingId = ""
    @State var mailClassList = [String]()
//    @State var isImageSizeExceeding: Bool = false
    @State var request : StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"", product_condition: "")
    
    @State private var profiles: [StoreShippingModel] = []
    @State var shippingProfileNames: [String] = []
    @State var selectedShippingProfileName: String = ""
    @StateObject private var shippingViewModel = ShippingViewModel()
    
    @StateObject var viewModel = ListProductViewModel()
    
    @State var imageUrls: [String] = []
    @State var uploadedVideoUrls: [String] = []
    
    @State private var isHazardousMaterial: Bool = false
    @State private var selectedFormat: SalesFormat = .buyItNow
    
    @State var showSellerSheet = false
    @State var navigateToSeller = false
    @State var showSubCategorySheet = false
    @State var selectedOption: Set<String> = []
    @State var selectedSubCategory = ""
    @State var subCategoryList: [CategoryDataModel] = []
    @State var subCategoryName : [String] = [""]
    @State var extraFields: [ExtraFieldModel] = []
    @State var processingListArr = ["Letters","Flats","Machinaable","Nonstandard","Non Machinable"]
    @State var openShippingSheet = false
    var strokeColor: Color {
        isHazardousMaterial ? Color.defaultTheme.opacity(0.3) : Color.gray.opacity(0.1)
    }

    var lineWidth: CGFloat {
        isHazardousMaterial ? 2 : 1
    }
    
    @State private var segment: lisProductScreenSegment = .Buyit
    
//    @State var conditionListArr = ["New","Used - Like New","Used - Very Good","Used - Good","Used - Acceptable","Collectible - Like New","Collectible - Very Good","Collectible - Good","Collectible - Acceptable"]
    
    @State var conditionListArr = ["New",
                                   "Like New",
                                   "Gently Loved",
                                   "Well Loved",
                                   "Other",
                                   "Trending"]
    
    @State var extraFieldValues: [String: String] = [:]
    @State var selectedRadio: [String: String] = [:]
    @State var navigateToShippingProfiles = false
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )

    var body: some View {
        
//        ZStack {
            VStack{
                VStack{
                    PrimaryHeader(
                        title: "List a Product".localized,
                        isForLogo : false, leadingImgArr: ["chevron.left"],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }
                .frame(height: 40)
                .background(Color.white)
                
                ScrollView(showsIndicators:false){
                    
                    MediaPickerView(uploadedImageUrls: $imageUrls, uploadedVideoUrls: $uploadedVideoUrls)
                    
                    VStack(alignment:.leading,spacing: 8){
                        Text("Product Details".localized)
                            .font(.custom(robotoMedium, size: 16.0))
                            .padding(.top,8)
                            .padding([.leading,.trailing],16.0)
                        
                        DropDownSelection(
                            options: $categoryNames, floatingLabel:"Category",
                            hint: "Select Category",
                            selected: $selectedCategory,
                            anchor: .bottom,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                selectedCategory = value
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
                                            if let response = self.viewModel.categoryResponse{
                                                self.subCategoryList = response.data
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
                        AuthTextField(
                            floatingLabel: "Title".localized,
                            placeholder: "Enter Product title".localized,
                            icon: .menuProfile,
                            text: $request.title ,
                            isIconDisplay : false,
                            custFontName : robotoMedium,
                            custFontSize : 14.0,
                            enteredText:  { title in
                                request.title = title
                            })
                        .keyboardType(.alphabet)
                        .padding([.top,.bottom],4)
                        
                        DescriptionFieldView(
                            description:$request.description,
                            custFontName : robotoMedium,
                            custFontSize : 14.0
                            )
                        { message in
                            request.description = message
                        }
                        AuthTextField(floatingLabel: "Quantity".localized, placeholder: "Enter Quantity".localized, icon: .menuProfile, text: $request.quantity ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.quantity = quantity
                        })
                        .keyboardType(.numberPad)
                        .padding([.bottom],4)
//
                        
                        // Dimensions Section
                        DimensionsSection(request: $request)
                        
                        DropDownSelection(
                            options: $mailClassList, floatingLabel:"Mail Class",
                            hint: "Select",
                            selected: $request.mail_class,
                            anchor: .bottom,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
//                                selectedCategory = value
//                                if let id = categoryList.first(where: { $0.name == value })?.id {
//                                    request.mail_class = "\(id)"
//                                } else {
                                    request.mail_class = value
//                                }
                               
                            }
                        )
                        
                        .padding([.leading,.trailing],16)
                        DropDownSelection(
                            options: $processingListArr, floatingLabel:"Processing Category",
                            hint: "Select",
                            selected: $request.processing_category,
                            anchor: .top,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
//                                selectedCategory = value
//                                if let id = categoryList.first(where: { $0.name == value })?.id {
                                    request.processing_category = value
//                                } else {
//                                    request.processing_category = ""
//                                }
                            }
                        )
                        .padding([.leading,.trailing],16)
                        
                        DropDownSelection(
                            options: $conditionListArr, floatingLabel:"Condition",
                            hint: "Select",
                            selected: $request.product_condition,
                            anchor: .top,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                request.product_condition = value
                            }
                        )
                        .padding([.leading,.trailing],16)
                        
//                        var extraField = self.extraFields
                        if extraFields.count != 0{
                            ForEach(0 ..< extraFields.count) { index in
                                let field = extraFields[index]
                                if let type = field.type {
                                    if type == "text" {
                                        AuthTextField(
                                            floatingLabel: field.label ?? "",
                                            placeholder: "Enter \(field.label ?? "")",
                                            icon: .menuProfile,
                                            text: Binding(
                                                get: { self.extraFieldValues[field.label ?? ""] ?? "" },
                                                set: { self.extraFieldValues[field.label ?? ""] = $0 }
                                            ),
                                            isIconDisplay: false,
                                            custFontName: robotoMedium,
                                            custFontSize: 14.0,
                                            enteredText: { text in
                                                self.extraFieldValues[field.label ?? ""] = text
                                            }
                                        )
                                        .padding(.bottom, 4)
                                        
                                    } else if type == "radio", let options = field.options {
                                        
                                        VStack(alignment: .leading) {
                                            Text(field.label?.capitalizingFirstLetter() ?? "")
                                                .padding(.horizontal,1)
                                                .font(.custom(robotoMedium, size: 14))
                                            
                                            ForEach(options, id: \.self) { option in
                                                HStack {
                                                    Image(systemName: selectedRadio[field.label ?? ""] == option ? "largecircle.fill.circle" : "circle")
                                                        .foregroundColor(Color.defaultTheme)
                                                    Text(option)
                                                        .font(.custom(robotoMedium, size: 14))
                                                }
                                                .onTapGesture {
                                                    selectedRadio[field.label ?? ""] = option
                                                }
                                                .padding(.vertical, 2)
                                            }
                                        }
                                        .padding(.horizontal,16)
                                        .padding(.bottom, 8)
                                    }
                                }
                                
                            }
                        }
//                        PrimaryButton(
//                            title: "Add Variants",
//                            isOutLine: false,
//                            custFontName : poppinsSemiBold,
//                            custFontSize : 14.0,
//                            onButtonClick: {
//                                print("hell")
//                            }, imageName: "ic_Plus", btnColor: .white)
                    }
                    
                    .padding(.bottom, 16)
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.top,2)
                    .padding(.horizontal, 12)
                    
                    
                    VStack(alignment: .leading){
                        // Select Format Label
                        Text("Pricing")
                            .font(.custom(poppinsMedium, size: 13.0))
                            .padding(.horizontal)
                            .padding(.top)
                        
                        
                        CustomSegmentedControl(preselectedIndex: $segment, options: lisProductScreenSegment.allCases)
                            .onChange(of: segment) { newSegment in
                                if segment == .Buyit{
                                    selectedFormat = .buyItNow
                                }else{
                                    selectedFormat = .auction
                                }
                                
                            }
                            .padding(.horizontal)
                        
                        
                        Text("Price".localized)
                            .font(.custom(robotoMedium, size: 16.0))
                            .padding(.top,8)
                            .padding([.leading,.trailing],16.0)
                        
                        AuthTextField(floatingLabel: "Buy it Now Price".localized,
                                      placeholder: "$0.0",
                                      icon: .menuProfile,
                                      text: $request.pricing,
                                      isIconDisplay : false,
                                      isForPrice:true,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { price in
                            request.pricing = price
                        })
                        .keyboardType(.decimalPad)
                        
                        
                        if selectedFormat == .auction {
                            VStack(spacing: 12) {
                                EnhancedToggleCard(
                                    title: "Reserve for Live",
                                    subtitle: "Save for live auction only",
                                    icon: "video.fill",
                                    iconColor: Color.defaultTheme,
                                    isOn: $isTappedReserve
                                )
                                .padding(.horizontal, 12)
                            }
//                            .padding(.horizontal, 16)
                            .onChange(of: isTappedReserve) { newValue in
                                if newValue {
                                    request.reserve_for_live = "1"
                                } else {
                                    request.reserve_for_live = "0"
                                }
                            }
                            
                        }else{
                            VStack(spacing: 12) {
                                EnhancedToggleCard(
                                    title: "Flash Sale",
                                    subtitle: "Limited time offer",
                                    icon: "bolt.fill",
                                    iconColor: Color.defaultTheme,
                                    isOn: $isTappedFlash
                                )
                                .padding(.horizontal, 12)
                                EnhancedToggleCard(
                                    title: "Accept Offers",
                                    subtitle: "Allow buyers to make offers",
                                    icon: "hand.raised.fill",
                                    iconColor: Color.defaultTheme,
                                    isOn: $isTappedAccept
                                )
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .background(.white)
                    .cornerRadius(12)
                    
                    .padding(.horizontal, 16)
                    
                    .onChange(of: isTappedFlash) { newValue in
                        if newValue {
                            request.flash_sale = "1"
                        } else {
                            request.flash_sale = "0"
                        }
                    }
                    .onChange(of: isTappedAccept) { newValue in
                        if newValue {
                            request.accept_offers = "1"
                        } else {
                            request.accept_offers = "0"
                        }
                    }
                    
                    
                    VStack(alignment:.leading,spacing: 8){

                        // Sales Options - Enhanced Toggle Cards
                        DropDownSelection(
                            options: $shippingProfileNames, floatingLabel:"Shipping Profile",
                            hint: "Select",
                            selected: $selectedShippingProfileName,
                            anchor: .top,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                //string value not id -> get Id from name
                                if let profile = profiles.first(where: { $0.name == value }) {
                                    request.shipping_profile_id = profile.id != nil ? "\(profile.id!)" : ""
                                }
                                
                            }
                        )
                        .padding([.leading,.trailing],16)
                        
                        VStack(alignment: .leading, spacing: 16) {

                            Toggle(isOn: $isHazardousMaterial) {
                                HazardousLabel() 
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(
                                        color: Color.black.opacity(0.08),
                                        radius: 12, x: 0, y: 4
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(strokeColor, lineWidth: lineWidth)
                                    .animation(.easeInOut(duration: 0.2), value: isHazardousMaterial)
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .zIndex(1000)
                    
                    // Bottom Buttons
                    TwoButton(
                        titleOne: "Publish",
                        titleTwo: "Save Draft",
                        onFirstButtonClick: {
                            hideKeyboardPopup()
                            saveProductDetails(as: "active")
                        },
                        onSecButtonClick: {
                            hideKeyboardPopup()
                            saveProductDetails(as: "draft")
                        }
                    )
//                    .padding(.horizontal, 12)
//                    .padding(.bottom, 20)
                }
//                .padding(.vertical, 16)
                .background(.backGround)
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color(.systemBackground))
//                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//                )
//                .padding(.horizontal, 12)
                .zIndex(1000)
                
                
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
                .toast(isPresenting: $showhud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
                    
                }
//                .toast(isPresenting: $isImageSizeExceeding) {
//                    AlertToast(displayMode: .hud, type: .regular, title: "Please select image size less than 5 MB", style: alertStlye)
//                }
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
                .overlay(
                    CustomBottomSheetView(
                        isPresented: $openShippingSheet,
                        config: config,
                        primaryAction: {
                            withAnimation {
                                openShippingSheet = false
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    navigateToShippingProfiles = true
//                                }
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
                
                CusNavLink(doNavigate: $navigateToShippingProfiles, destination: ShippingSettingsScreen())
        }
        .edgesIgnoringSafeArea(.bottom)
            .background(.backGround)
        .onFirstAppear(perform: {
            Task{
                
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        var errorMessage = viewModel.errorMessage ?? shippingViewModel.errorMessage
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
                        categorySuccess()
                        successShippingProfiles()
                        mailSuccess()
                    }
                    
                ) {
                    // 👇 These run in parallel
                    async let categoryTask: () = viewModel.getSubCategoryList(param: CategoryRequest(category_id: ""))
                    async let mailTask: () = viewModel.getMailClasses()
                    async let shippingTask: () = shippingViewModel.getShippingProfiles()
                    
                    // Wait for all
                    _ = try await (categoryTask, mailTask, shippingTask)
                }
            }
        })
        .onTapGesture {
           hideKeyboard()
        }
    }
    
    private func successShippingProfiles() {
        let response = shippingViewModel.getShippingProfilesResponse
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
                secondaryButtonTitle: nil
            )
            openShippingSheet = true
        }
    }
    
    func mailSuccess() {
        let response = viewModel.mailClassResponse
        if viewModel.errorMessage == nil {
            let data = response?.data.mail_classes ?? [MailClass]()
            self.mailClassList = data.map {$0.label }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
            
            
        }
    }
    
    func saveProductDetails(as status: String) {
        // 🔹 Step 1: Validation
        guard validateRequest(request, imageUrls: imageUrls, videoUrls: uploadedVideoUrls, status: status) else {
            showhud = true
            return
        }
        
        // 🔹 Step 2: Update status
        request.status = status
        
        // 🔹 Step 3: Perform Sequential API calls
        Task {
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
            ) {
                viewModel.errorMessage?.removeAll()
                var mimeType: [String] = []
                var photos = [[String]]()
                var keysValue: [String] = []
            
                if imageUrls.count > 0 {
                    mimeType.append("image/jpeg")
                    keysValue.append("images[]")
                    let imagesArr = self.imageUrls.map({$0.description})
                    photos.append(imagesArr)
                }
                
                
                if self.uploadedVideoUrls.count > 0 {
                    // Check video URL extension to set the appropriate MIME type
                    for urlString in uploadedVideoUrls {
                        guard let url = URL(string: urlString) else { return }
                        let fileExtension = url.pathExtension.lowercased()
                        
                        switch fileExtension {
                        case "mp4":
                            keysValue.append("videos[]")
                            mimeType.append("video/mp4")
                            photos.append([url.description])
                        case "avi":
                            keysValue.append("videos[]")
                            mimeType.append("video/avi")
                            photos.append([url.description])
                        case "mov":
                            keysValue.append("videos[]")
                            mimeType.append("video/mov")
                            photos.append([url.description])
                        case "mkv":
                            keysValue.append("videos[]")
                            mimeType.append("video/x-matroska")
                            photos.append([url.description])
                        default:
                            keysValue.append("videos[]")
                            mimeType.append("video/*") // Default case for unknown video types
                            photos.append([url.description])
                        }
                    }
                }
                try await viewModel.uploadStoreImage(images: photos, mimeType: mimeType, keysValue: keysValue)
                if let errorMessage = self.viewModel.errorMessage, errorMessage != "" {
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
                else  {
                    guard let response = self.viewModel.storeImageResponse,
                          response.status == "success" else { return }
                    
                    let uploadedImagesUrls: [[String: String]] = response.data.images?.compactMap {
                        return ["image": $0.images ?? "", "thumbnail": $0.thumbnail ?? ""]
                    } ?? []
                    let uploadedVideoUrls: [[String: String]] = response.data.videos?.compactMap {
                        return ["videos": $0.videos ?? ""]
                    } ?? []
                    
                    
                    // 🔹 Build extra fields
                    let variantArray = buildVariantArray(extraFields: extraFields,
                                                         extraFieldValues: extraFieldValues,
                                                         selectedRadio: selectedRadio)
                    
                    // 🔹 Prepare request body
                    var productRequest: [String: Any] = [
                        "category_id": request.category_id,
                        "sub_category_id": request.sub_category_id ?? "",
                        "title": request.title,
                        "description": request.description,
                        "quantity": request.quantity,
                        "pricing": request.pricing,
                        "flash_sale": request.flash_sale,
                        "accept_offers": request.accept_offers,
                        "reserve_for_live": request.reserve_for_live,
                        "shipping_profile_id": request.shipping_profile_id,
//                        "auction": "true",
                        // ✅ Newly added fields
                        "width": request.width,
                        "length": request.length,
                        "weight": request.weight,
                        "height": request.height,
                        "mail_class": request.mail_class,
                        "processing_category": request.processing_category,
                        "product_condition": request.product_condition,
                        // ✅ Images array (already present)
                        "images": uploadedImagesUrls,
                        "videos": uploadedVideoUrls,
//                        "type": "live",
                        "status": request.status,
                        "hazardous_material": isHazardousMaterial
                    ]

                    if !variantArray.isEmpty {
                        productRequest["variant"] = variantArray
                    }
                    
                    // 🔹 Call product store API
                    self.viewModel.errorMessage?.removeAll()
                    try await viewModel.storeProduct(param: productRequest)
                    storeSuccess()
                }
            }
        }
    }
    
    func categorySuccess() {
       
        let response = viewModel.categoryResponse
        if response?.status == "success" {
            self.categoryList = response?.data ?? [CategoryDataModel]()
            self.categoryNames = response?.data.map { $0.name ?? "No Category" } ?? [String]()
            
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
            
            
        }
    }
    
    // MARK: - Validation
    private func validateRequest(_ request: StoreProductParam, imageUrls: [String],videoUrls: [String], status: String) -> Bool {
        if status == "draft" {
            if request.title.isEmpty {
                hudMsg = "Please enter title"
                return false
            }
            if request.category_id.isEmpty {
                hudMsg = "Please select category"
                return false
            }
            return true
        }
        
        if imageUrls.isEmpty && videoUrls.isEmpty {
            hudMsg = "Please add media"
            return false
        }
        if request.category_id.isEmpty {
            hudMsg = "Please select category"
            return false
        }
        if request.title.isEmpty {
            hudMsg = "Please enter title"
            return false
        }
        if request.description.isEmpty {
            hudMsg = "Please enter description"
            return false
        }
        if request.quantity.isEmpty {
            hudMsg = "Please enter quantity"
            return false
        }
        guard let quantity = Double(request.quantity), quantity >= 1 else {
            hudMsg = "Please enter quantity greater than 1"
            return false
        }
        if request.width.isEmpty { hudMsg = "Please enter width"; return false }
        if request.height.isEmpty { hudMsg = "Please enter height"; return false }
        if request.length.isEmpty { hudMsg = "Please enter length"; return false }
        if request.weight.isEmpty { hudMsg = "Please enter weight"; return false }
        if request.mail_class.isEmpty { hudMsg = "Please select mail class"; return false }
        if request.processing_category.isEmpty { hudMsg = "Please select processing category"; return false }
        if request.product_condition.isEmpty { hudMsg = "Please select product condition"; return false }
        if request.pricing.isEmpty { hudMsg = "Please enter pricing"; return false }
        guard let price = Double(request.pricing), price >= 1 else {
            hudMsg = "Price should not be less than $1.00"
            return false
        }
        if request.shipping_profile_id.isEmpty {
            hudMsg = "Please select shipping address"
            return false
        }
        return true
    }

    // MARK: - Variant Builder
    private func buildVariantArray(
        extraFields: [ExtraFieldModel],
        extraFieldValues: [String: String],
        selectedRadio: [String: String]
    ) -> [[String: Any]] {
        var variantArray: [[String: Any]] = []
        
        for field in extraFields {
            guard let title = field.label, let type = field.type else { continue }
            
            if type == "text" {
                let value = extraFieldValues[title] ?? ""
                variantArray.append(["title": title, "value": value])
            } else if type == "radio", let options = field.options {
                let selected = selectedRadio[title] ?? ""
                var valueDict: [String: String] = [:]
                
                for (index, option) in options.enumerated() {
                    let key = "option_\(index + 1)"
                    valueDict[key] = option
                }
                valueDict["selected"] = selected
                
                variantArray.append(["title": title, "value": valueDict])
            }
        }
        return variantArray
    }

    
    func storeSuccess(){
        if let errorMessage = viewModel.errorMessage {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: errorMessage,
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }else{
            let response = viewModel.storeProductResponse
            alertType = .sheetType(
                icon: .success,
                title: "Success",
                message: response?.message ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
            showError = true
        }
    }
    
    // Format Button View
    private func formatButton(title: String, systemImage: String, isSelected: Bool) -> some View {
        VStack {
            Image(systemName: systemImage)
                .font(.custom(poppinsSemiBold, size: 13.0))
                .padding(.bottom, 4)
            Text(title)
                .font(.custom(poppinsSemiBold, size: 13.0))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.defaultThemeLight : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .cornerRadius(12)
    }
   
}

struct HazardousLabel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hazardous Materials")
                .font(.custom(poppinsMedium, size: 16))
                .foregroundColor(.primary)

            Text("Carries restrict shipping items that may pose risk to safety, like lithium batteries.")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

enum lisProductScreenSegment : String, CaseIterable, CustomStringConvertible {
    case Buyit = "Buy it Now"
    case Auction = "Auction"

    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
}


// MARK: - Supporting Components

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.custom(poppinsSemiBold, size: 16.0))
            .foregroundColor(.primary)
          
    }
}

// MARK: - Dimensions Section Component
struct DimensionsSection: View {
    @Binding var request: StoreProductParam
    
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "cube.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text("Package Dimensions")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Dimensions Grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Width Field
                    DimensionField(
                        label: "Width",
                        unit: "cm",
                        value: $request.width,
                        icon: "arrow.left.and.right"
                    )
                    
                    // Height Field
                    DimensionField(
                        label: "Height",
                        unit: "cm",
                        value: $request.height,
                        icon: "arrow.up.and.down"
                    )
                }
                
                HStack(spacing: 12) {
                    // Length Field
                    DimensionField(
                        label: "Length",
                        unit: "cm",
                        value: $request.length,
                        icon: "arrow.forward"
                    )
                    
                    // Weight Field
                    DimensionField(
                        label: "Weight",
                        unit: "lbs",
                        value: $request.weight,
                        icon: "scalemass.fill"
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.defaultTheme.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.defaultThemeLight, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Dimension Field Component
struct DimensionField: View {
    let label: String
    let unit: String
    @Binding var value: String
    let icon: String
    
    @State private var isFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label with Icon
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Input Field with Unit
            HStack(spacing: 8) {
                TextField("0", text: $value, onEditingChanged: { focused in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = focused
                    }
                })
                .keyboardType(.decimalPad)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                
                Text(unit)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isFocused ? Color.defaultTheme.opacity(0.5) : Color.gray.opacity(0.2), lineWidth: isFocused ? 2 : 1)
            )
            .shadow(color: isFocused ? Color.defaultThemeLight : Color.clear, radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Enhanced Toggle Card Component
struct EnhancedToggleCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                    isOn.toggle()
                }
            }
        }) {
            HStack(spacing: 14) {
                // Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(isOn ? 0.15 : 0.08))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                .shadow(color: isOn ? iconColor.opacity(0.1) : Color.clear, radius: 1, x: 0, y: 4)
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Toggle Switch
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: iconColor))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
//                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isOn ? iconColor.opacity(0.4) : Color.gray.opacity(0.1), lineWidth: isOn ? 2 : 1)
                    .animation(.easeInOut(duration: 0.2), value: isOn)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
