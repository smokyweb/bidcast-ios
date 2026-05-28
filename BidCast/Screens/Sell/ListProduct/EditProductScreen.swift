//
//  EditProductScreen.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 11/11/25.
//


import SwiftUI
import SwiftfulLoadingIndicators
import SVProgressHUD
import AlertToast
import SwiftUI
import SwiftfulLoadingIndicators
import SVProgressHUD
import AlertToast

struct EditProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var categorySelect: String = ""
    @State var categoyList = [String]()
    @State var productTitle = ""
    @State var message = ""
    
    @State var isTappedFlash: Bool = false
    // Basecamp #9933973683 (2026-05-27): flash sale price + window state.
    @State private var flashSalePriceText: String = ""
    @State private var flashSaleStartsAt: Date = Date()
    @State private var flashSaleEndsAt: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
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
    @State private var mailClasses: [MailClass] = []
    
    @State var conditionListArr = ["New",
                                   "Like New",
                                   "Gently Loved",
                                   "Well Loved",
                                   "Other",
                                   "Trending"]
    
    @State var request: StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "", sub_category_id: "", width: "", length: "", weight: "", height: "", mail_class: "", processing_category: "", product_condition: "")
    
    @State private var profiles: [StoreShippingModel] = []
    @State var shippingProfileNames: [String] = []
    @State var selectedShippingProfileName: String = ""
    @StateObject private var shippingViewModel = ShippingViewModel()
    
    @StateObject var viewModel = ListProductViewModel()
    
    @State var imageUrls: [String] = []
    @State var videoUrls: [String] = []
    @State var thumbnailUrls: [String] = []
    
    @State private var isHazardousMaterial: Bool = false
    @State private var selectedFormat: SalesFormat = .buyItNow
    
    @State var showSellerSheet = false
    @State var navigateToSeller = false
    @State var showSubCategorySheet = false
    @State var selectedOption: Set<String> = []
    @State var selectedSubCategory = ""
    @State var subCategoryList: [CategoryDataModel] = []
    @State var subCategoryName: [String] = [""]
    @Binding var productData: ProductDataModel1
    @State var extraFields: [ExtraFieldModel] = []
    @State var processingListArr = ["Letters", "Flats", "Machinaable", "Nonstandard", "Non Machinable"]
    @State var extraFieldValues: [String: String] = [:]
    @State var selectedRadio: [String: String] = [:]
    @State var productId: Int = -1
    @State var openShippingSheet = false
    @State var navigateToShippingProfiles = false
    
    private var isUsingShippingProfile: Bool {
        !(request.shipping_profile_id.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty
    }
    
    private var selectedMailClass: MailClass? {
        let selected = request.mail_class.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !selected.isEmpty else { return nil }
        return mailClasses.first(where: { $0.label == selected })
    }
    
    var strokeColor: Color {
        isHazardousMaterial ? Color.defaultTheme.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    var lineWidth: CGFloat {
        isHazardousMaterial ? 2 : 1
    }
    
    @State private var segment: lisProductScreenSegment = .Buyit
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    
    var body: some View {
        VStack {
            VStack {
                PrimaryHeader(
                    title: "Edit Product".localized,
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            .frame(height: 40)
            .background(Color.white)
            
            ScrollView(showsIndicators: false) {
                
                MediaPickerView(uploadedImageUrls: $imageUrls, uploadedVideoUrls: $videoUrls) { index, mediaType in
                    if mediaType == .image {
                        thumbnailUrls.remove(at: index)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Product Details".localized)
                        .font(.custom(robotoMedium, size: 16.0))
                        .padding(.top, 8)
                        .padding([.leading, .trailing], 16.0)
                    
                    DropDownSelection(
                        options: $categoryNames,
                        floatingLabel: "Category",
                        hint: "Select Category",
                        selected: $selectedCategory,
                        anchor: .bottom,
                        custFontName: robotoMedium,
                        custFontSize: 14.0,
                        custCategory: robotoRegular,
                        custCategorySize: 13.0,
                        onOptionSelected: { value in
                            selectedCategory = value
                            if let id = categoryList.first(where: { $0.name == value })?.id {
                                request.category_id = "\(id)"
                            } else {
                                request.category_id = ""
                            }
                            Task {
                                await performAPICalls(
                                    isConcurrent: false,
                                    onError: { error in
                                        showSubCategorySheet = false
                                    },
                                    onSuccess: {
                                        self.subCategoryList.removeAll()
                                        if let response = self.viewModel.categoryResponse {
                                            self.subCategoryList = response.data
                                            self.subCategoryName = self.subCategoryList.map { $0.name ?? "" }
                                        }
                                        if subCategoryList.count != 0 {
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
                    .padding([.leading, .trailing], 16)
                    
                    AuthTextField(
                        floatingLabel: "Title".localized,
                        placeholder: "Enter Product title".localized,
                        icon: .menuProfile,
                        text: $request.title,
                        isIconDisplay: false,
                        custFontName: robotoMedium,
                        custFontSize: 14.0,
                        enteredText: { title in
                            request.title = title
                        })
                    .keyboardType(.alphabet)
                    .padding([.top, .bottom], 4)
                    
                    DescriptionFieldView(
                        description: $request.description,
                        custFontName: robotoMedium,
                        custFontSize: 14.0
                    ) { message in
                        request.description = message
                    }
                    
                    AuthTextField(
                        floatingLabel: "Quantity".localized,
                        placeholder: "Enter Quantity".localized,
                        icon: .menuProfile,
                        text: $request.quantity,
                        isIconDisplay: false,
                        custFontName: robotoMedium,
                        custFontSize: 14.0,
                        enteredText: { quantity in
                            request.quantity = quantity
                        })
                    .keyboardType(.numberPad)
                    .padding([.bottom], 4)
                    
                    // Shipping Profile (optional). If selected, Mail Class + Dimensions become optional.
                    DropDownSelection(
                        options: $shippingProfileNames,
                        floatingLabel: "Shipping Profile",
                        hint: "Select",
                        selected: $selectedShippingProfileName,
                        anchor: .bottom,
                        custFontName: robotoMedium,
                        custFontSize: 14.0,
                        custCategory: robotoRegular,
                        custCategorySize: 13.0,
                        onOptionSelected: { value in
                            selectedShippingProfileName = value
                            if let profile = profiles.first(where: { $0.name == value }) {
                                request.shipping_profile_id = profile.id != nil ? "\(profile.id!)" : ""
                            } else {
                                request.shipping_profile_id = ""
                            }
                            
                            if isUsingShippingProfile {
                                request.mail_class = ""
                            }
                        }
                    )
                    .padding([.leading, .trailing], 16)
                    .zIndex(1202.0)
                    
                    if isUsingShippingProfile {
                        Button(action: {
                            selectedShippingProfileName = ""
                            request.shipping_profile_id = ""
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                Text("Clear Shipping Profile")
                                    .font(.custom(robotoMedium, size: 13))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.top, 2)
                    }
                    
                    if !isUsingShippingProfile {
                        DropDownSelection(
                            options: $mailClassList,
                            floatingLabel: "Mail Class",
                            hint: "Select",
                            selected: $request.mail_class,
                            anchor: .bottom,
                            custFontName: robotoMedium,
                            custFontSize: 14.0,
                            custCategory: robotoRegular,
                            custCategorySize: 13.0,
                            onOptionSelected: { value in
                                request.mail_class = value
                            }
                        )
                        .padding([.leading, .trailing], 16)
                        DimensionsSection(request: $request, limits: selectedMailClass)
                    }
                    
                    DropDownSelection(
                        options: $processingListArr,
                        floatingLabel: "Processing Category",
                        hint: "Select",
                        selected: $request.processing_category,
                        anchor: .bottom,
                        custFontName: robotoMedium,
                        custFontSize: 14.0,
                        custCategory: robotoRegular,
                        custCategorySize: 13.0,
                        onOptionSelected: { value in
                            request.processing_category = value
                        }
                    )
                    .padding([.leading, .trailing], 16)
                    
                    DropDownSelection(
                        options: $conditionListArr,
                        floatingLabel: "Condition",
                        hint: "Select",
                        selected: $request.product_condition,
                        anchor: .bottom,
                        custFontName: robotoMedium,
                        custFontSize: 14.0,
                        custCategory: robotoRegular,
                        custCategorySize: 13.0,
                        onOptionSelected: { value in
                            request.product_condition = value
                        }
                    )
                    .padding([.leading, .trailing], 16)
                    
                    if extraFields.count != 0 {
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
                                            .padding(.horizontal, 1)
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
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
                .background(.white)
                .cornerRadius(12)
                .padding(.top, 2)
                .padding(.horizontal, 12)
                
                VStack(alignment: .leading) {
                    Text("Pricing")
                        .font(.custom(poppinsMedium, size: 13.0))
                        .padding(.horizontal)
                        .padding(.top)
                    
                    CustomSegmentedControl(preselectedIndex: $segment, options: lisProductScreenSegment.allCases)
                        .onChange(of: segment) { newSegment in
                            if segment == .Buyit {
                                selectedFormat = .buyItNow
                            } else {
                                selectedFormat = .auction
                            }
                        }
                        .padding(.horizontal)
                    
                    Text("Price".localized)
                        .font(.custom(robotoMedium, size: 16.0))
                        .padding(.top, 8)
                        .padding([.leading, .trailing], 16.0)
                    
                    AuthTextField(
                        floatingLabel: "Buy It Now Price".localized,
                        placeholder: "$0.0",
                        icon: .menuProfile,
                        text: $request.pricing,
                        isIconDisplay: false,
                        isForPrice: true,
                        custFontName: robotoMedium,
                        custFontSize: 14.0,
                        enteredText: { price in
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
                        .onChange(of: isTappedReserve) { newValue in
                            if newValue {
                                request.reserve_for_live = "1"
                            } else {
                                request.reserve_for_live = "0"
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            EnhancedToggleCard(
                                title: "Flash Sale",
                                subtitle: "Limited time offer",
                                icon: "bolt.fill",
                                iconColor: Color.defaultTheme,
                                isOn: $isTappedFlash
                            )
                            .padding(.horizontal, 12)

                            // Basecamp #9933973683 (2026-05-27): flash sale price + window fields
                            if isTappedFlash {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        Text("$")
                                            .font(.custom(poppinsBold, size: 14))
                                            .foregroundColor(.red)
                                        TextField("Sale price (must be < regular price)", text: $flashSalePriceText)
                                            .keyboardType(.decimalPad)
                                            .font(.custom(poppinsRegular, size: 14))
                                            .padding(8)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange.opacity(0.4), lineWidth: 1))
                                    }
                                    HStack(spacing: 8) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Starts at").font(.custom(poppinsBold, size: 11)).foregroundColor(.orange)
                                            DatePicker("", selection: $flashSaleStartsAt).labelsHidden().datePickerStyle(.compact)
                                        }
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Ends at").font(.custom(poppinsBold, size: 11)).foregroundColor(.orange)
                                            DatePicker("", selection: $flashSaleEndsAt, in: Date()...).labelsHidden().datePickerStyle(.compact)
                                        }
                                    }
                                    Text("Buyers see a flash-sale badge + countdown during the window.")
                                        .font(.custom(poppinsRegular, size: 11))
                                        .foregroundColor(.gray)
                                }
                                .padding(12)
                                .background(Color.orange.opacity(0.06))
                                .cornerRadius(10)
                                .padding(.horizontal, 12)
                            }
                            
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
                
                VStack(alignment: .leading, spacing: 8) {
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
                
                // Bottom Buttons - Updated for Edit
                TwoButton(
                    titleOne: "Update",
                    titleTwo: "Save as Draft",
                    onFirstButtonClick: {
                        hideKeyboardPopup()
                        saveProductDetails(as: "active")
                    },
                    onSecButtonClick: {
                        hideKeyboardPopup()
                        saveProductDetails(as: "draft")
                    }
                )
                .padding(.bottom, 20)
            }
            .padding(.vertical, 16)
            .background(.backGround)
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
                            }
                            showSubCategorySheet = false
                        }
                    )
                }
            )
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
            }
            .bottomSheet(isPresented: $showError, height: screenHeight * 0.35, topBarCornerRadius: 25, showTopIndicator: false,
                onDismiss: {
                if let errorMessage = viewModel.errorMessage {
                    showError = false
                    viewModel.errorMessage = nil
                } else {
                    showError = true
                }
            }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        if let errorMessage = viewModel.errorMessage {
                            showError = false
                            viewModel.errorMessage = nil
                        } else {
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
            .overlay(
                CustomBottomSheetView(
                    isPresented: $openShippingSheet,
                    config: config,
                    primaryAction: {
                        withAnimation {
                            openShippingSheet = false
                            navigateToShippingProfiles = true
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
        .onAppear {
            getProductDetails()
        }
        .onFirstAppear(perform: {
            Task {
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
                        categorySuccess()
                        successShippingProfiles()
                        mailSuccess()
                    }
                ) {
                    async let categoryTask: () = viewModel.getSubCategoryList(param: CategoryRequest(category_id: ""))
                    async let mailTask: () = viewModel.getMailClasses()
                    async let shippingTask: () = shippingViewModel.getShippingProfiles()
                    
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
        openShippingSheet = false
        self.shippingProfileNames = profiles.map { $0.name ?? "" }
    }
    
    func mailSuccess() {
        let response = viewModel.mailClassResponse
        if viewModel.errorMessage == nil {
            let data = response?.data.mail_classes ?? [MailClass]()
            self.mailClassList = data.map { $0.label }
            self.mailClasses = data
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
        guard validateRequest(request, imageUrls: imageUrls, videoUrls: videoUrls, status: status) else {
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
                
                let localImages = imageUrls.filter { url in
                    !(url.hasPrefix("http://") || url.hasPrefix("https://"))
                }
                
                let serverImages = imageUrls.filter { url in
                    (url.hasPrefix("http://") || url.hasPrefix("https://"))
                }
                
                let serverThumbnails = thumbnailUrls.filter { url in
                    (url.hasPrefix("http://") || url.hasPrefix("https://"))
                }
                
                let localVideos = videoUrls.filter { url in
                    !(url.hasPrefix("http://") || url.hasPrefix("https://"))
                }
                
                let serverVideos = videoUrls.filter { url in
                    (url.hasPrefix("http://") || url.hasPrefix("https://"))
                }
                
                var uploadedImagesUrls: [[String: String]] = []
                var uploadedVideoUrls: [[String: String]] = []
                
                // Upload new media if any
                if !localImages.isEmpty || !localVideos.isEmpty {
                    var mimeType: [String] = []
                    var photos = [[String]]()
                    var keysValue: [String] = []
                    
                    if localImages.count > 0 {
                        mimeType.append("image/jpeg")
                        keysValue.append("images[]")
                        let imagesArr = localImages.map { $0.description }
                        photos.append(imagesArr)
                    }
                    
                    if localVideos.count > 0 {
                        for urlString in localVideos {
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
                                mimeType.append("video/*")
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
                        return
                    }
                    
                    guard let response = self.viewModel.storeImageResponse,
                          response.status == "success" else { return }
                    
                    uploadedImagesUrls = response.data.images?.compactMap {
                        return ["image": $0.images ?? "", "thumbnail": $0.thumbnail ?? ""]
                    } ?? []
                    
                    uploadedVideoUrls = response.data.videos?.compactMap {
                        return ["videos": $0.videos ?? ""]
                    } ?? []
                }
                
                // Combine server and newly uploaded media
                for (index, item) in serverImages.enumerated() {
                    uploadedImagesUrls.append(["image": item, "thumbnail": serverThumbnails[index]])
                }
                
                for item in serverVideos {
                    uploadedVideoUrls.append(["videos": item])
                }
                
                
                let finalImageUrls: [[String: String]]
                if !uploadedImagesUrls.isEmpty {
                    // New images were uploaded
                    finalImageUrls = uploadedImagesUrls
                } else if !imageUrls.isEmpty {
                    // No new uploads, use existing image URLs (edit mode)
                    finalImageUrls = imageUrls.map { url in
                        return ["image": url, "thumbnail": url]
                    }
                } else {
                    // No images at all
                    finalImageUrls = []
                }

                let finalVideoUrls: [[String: String]]
                if !uploadedVideoUrls.isEmpty {
                    // New videos were uploaded
                    finalVideoUrls = uploadedVideoUrls
                } else if !videoUrls.isEmpty {
                    // No new uploads, use existing video URLs (edit mode)
                    finalVideoUrls = videoUrls.map { url in
                        return ["videos": url]
                    }
                } else {
                    // No videos at all
                    finalVideoUrls = []
                }
                
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
                    "width": request.width,
                    "length": request.length,
                    "weight": request.weight,
                    "height": request.height,
                    "mail_class": request.mail_class,
                    "processing_category": request.processing_category,
                    "product_condition": request.product_condition,
                    "images": finalImageUrls,
                    "videos": finalVideoUrls,
                    "status": request.status,
                    "hazardous_material": isHazardousMaterial
                ]
                
                if !variantArray.isEmpty {
                    productRequest["variant"] = variantArray
                }
                
                // 🔹 Call product update API
                self.viewModel.errorMessage?.removeAll()
                try await viewModel.storeProduct(productId: productId, param: productRequest)

                // Basecamp #9933973683 (2026-05-27): if flash sale on, follow up
                // with the dedicated flash-sale endpoint to set price + window.
                if isTappedFlash, let price = Double(flashSalePriceText), price > 0 {
                    await setFlashSale(productId: productId, price: price, startsAt: flashSaleStartsAt, endsAt: flashSaleEndsAt)
                } else if !isTappedFlash {
                    // Turned off → clear any existing flash sale terms server-side.
                    await clearFlashSale(productId: productId)
                }
                storeSuccess()
            }
        }
    }
    
    // Basecamp #9933973683 (2026-05-27): flash sale API helpers.
    private func setFlashSale(productId: Int, price: Double, startsAt: Date, endsAt: Date) async {
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/flash-sale") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        let isoFmt = ISO8601DateFormatter()
        let body: [String: Any] = [
            "product_id": productId,
            "flash_sale_price": price,
            "starts_at": isoFmt.string(from: startsAt),
            "ends_at": isoFmt.string(from: endsAt),
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do { _ = try await URLSession.shared.data(for: req) } catch { print("setFlashSale failed: \(error)") }
    }

    private func clearFlashSale(productId: Int) async {
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/flash-sale/\(productId)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        do { _ = try await URLSession.shared.data(for: req) } catch { print("clearFlashSale failed: \(error)") }
    }

    func categorySuccess() {
        let response = viewModel.categoryResponse
        if response?.status == "success" {
            self.categoryList = response?.data ?? [CategoryDataModel]()
            selectedCategory = self.categoryList.filter({ $0.id == Int(request.category_id) }).first?.name ?? ""
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
    
    func getProductDetails() {
        selectedCategory = productData.category?.name ?? ""
        productId = productData.id ?? 0
        request = StoreProductParam(
            category_id: "\(productData.category?.id ?? 0)",
            title: productData.title ?? "",
            description: productData.description ?? "",
            quantity: "\(productData.quantity ?? "0")",
            pricing: "\(productData.pricing ?? "0.0")",
            flash_sale: productData.flashSale ?? false ? "1" : "0",
            accept_offers: productData.acceptOffers ?? false ? "1" : "0",
            reserve_for_live: productData.reserveForLive ?? false ? "1" : "0",
            shipping_profile_id: "\(productData.shippingProfileId ?? 0)",
            status: productData.status ?? "",
            width: "\(productData.width ?? 0.0)",
            length: "\(productData.length ?? 0.0)",
            weight: "\(productData.weight ?? 0.0)",
            height: "\(productData.height ?? 0.0)",
            mail_class: productData.mailClass ?? "",
            processing_category: productData.processingCategory ?? "",
            product_condition: productData.productCondition ?? ""
        )
        
        isTappedFlash = productData.flashSale ?? false
        isTappedAccept = productData.acceptOffers ?? false
        isTappedReserve = productData.reserveForLive ?? false
        
        self.imageUrls = productData.images ?? [String]()
        self.thumbnailUrls = productData.thumbnail ?? [String]()
        self.videoUrls = productData.videos ?? [String]()
        
        if request.category_id == "0" {
            request.category_id.removeAll()
        }
        if request.quantity == "0" {
            request.quantity.removeAll()
        }
        if request.pricing == "0.0" {
            request.pricing.removeAll()
        }
        if imageUrls == [] {
            self.imageUrls.removeAll()
        }
        if thumbnailUrls == [] {
            self.thumbnailUrls.removeAll()
        }
        if videoUrls == [] {
            self.videoUrls.removeAll()
        }
    }
    
    // MARK: - Validation
    private func validateRequest(_ request: StoreProductParam, imageUrls: [String], videoUrls: [String], status: String) -> Bool {
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
        
        if request.shipping_profile_id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if request.mail_class.isEmpty { hudMsg = "Please select mail class"; return false }
            if request.width.isEmpty { hudMsg = "Please enter width"; return false }
            if request.height.isEmpty { hudMsg = "Please enter height"; return false }
            if request.length.isEmpty { hudMsg = "Please enter length"; return false }
            if request.weight.isEmpty { hudMsg = "Please enter weight"; return false }
            
            let mailLabel = request.mail_class.trimmingCharacters(in: .whitespacesAndNewlines)
            if let limits = mailClasses.first(where: { $0.label == mailLabel }) {
                if let msg = validateDimensionsAgainstMailClass(request: request, mailClass: limits) {
                    hudMsg = msg
                    return false
                }
            }
            
        }
        
        if request.processing_category.isEmpty { hudMsg = "Please select processing category"; return false }
        if request.product_condition.isEmpty { hudMsg = "Please select product condition"; return false }
        if request.pricing.isEmpty { hudMsg = "Please enter pricing"; return false }
        guard let price = Double(request.pricing), price >= 1 else {
            hudMsg = "Price should not be less than $1.00"
            return false
        }
        return true
    }
    
    private func validateDimensionsAgainstMailClass(request: StoreProductParam, mailClass: MailClass) -> String? {
        let weight = Double(request.weight) ?? 0
        let width = Double(request.width) ?? 0
        let height = Double(request.height) ?? 0
        let length = Double(request.length) ?? 0
        
        if let maxWeight = mailClass.max_weight_lbs, maxWeight > 0, weight > maxWeight {
            return "Weight must be ≤ \(maxWeight) lbs for \(mailClass.label)"
        }
        if let maxLength = mailClass.max_length_in, maxLength > 0, length > maxLength {
            return "Length must be ≤ \(maxLength) in for \(mailClass.label)"
        }
        if let maxWidth = mailClass.max_width_in, maxWidth > 0, width > maxWidth {
            return "Width must be ≤ \(maxWidth) in for \(mailClass.label)"
        }
        if let maxHeight = mailClass.max_height_in, maxHeight > 0, height > maxHeight {
            return "Height must be ≤ \(maxHeight) in for \(mailClass.label)"
        }
        if let maxLPG = mailClass.max_length_plus_girth_in, maxLPG > 0 {
            let lengthPlusGirth = length + 2 * (width + height)
            if lengthPlusGirth > maxLPG {
                return "Length + girth must be ≤ \(maxLPG) in for \(mailClass.label)"
            }
        }
        
        return nil
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
    
    func storeSuccess() {
        if let errorMessage = viewModel.errorMessage {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: errorMessage,
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        } else {
            let response = viewModel.storeProductResponse
            alertType = .sheetType(
                icon: .success,
                title: "Success",
                message: response?.message ?? "Product updated successfully",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
            showError = true
        }
    }
}
