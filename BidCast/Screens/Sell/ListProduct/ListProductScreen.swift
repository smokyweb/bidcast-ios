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
    // Basecamp #9933973683 (2026-05-29 RETURN): flash sale setup fields.
    // ListProductScreen had the toggle UI but no price/date inputs and no
    // setFlashSale API call, so enabling flash sale had no effect.
    @State private var flashSalePriceText: String = ""
    @State private var flashSaleStartsAt: Date = Date()
    @State private var flashSaleEndsAt: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

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
//    @State var isImageSizeExceeding: Bool = false
    @State var request : StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "1", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"", product_condition: "")

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
    var forSheet : Bool = false

    var onCancel : () -> () = { }
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

    var preSelectedCategoryId: String? = nil
       var preSelectedCategoryName: String? = nil
       var isCategoryLocked: Bool = false

    var onProductCreated: ((ProductDataModel1) -> Void)? = nil
    var onProductUpdated: ((ProductDataModel1) -> Void)? = nil
    var editingProduct: ProductDataModel1? = nil
    var hideDraftButton: Bool = false

    private var isEditing: Bool { (editingProduct?.id ?? 0) != 0 }
    @EnvironmentObject var coordinator: LetsPrepareCoordinator

    private var isUsingShippingProfile: Bool {
        !(request.shipping_profile_id.trimmingCharacters(in: .whitespacesAndNewlines)).isEmpty
    }

    private var selectedMailClass: MailClass? {
        let selected = request.mail_class.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !selected.isEmpty else { return nil }
        return mailClasses.first(where: { $0.label == selected })
    }

    private var selectedFormatIsAuction: Bool {
        selectedFormat == .auction
    }

    private var selectedProductType: String {
        selectedFormatIsAuction ? "live" : "buy_it_now"
    }

    private func productIsAuction(_ product: ProductDataModel1) -> Bool {
        if product.auction == true || product.reserveForLive == true || product.isAuction == true { return true }
        let values = [product.type, product.saleFormat]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        return values.contains { ["live", "auction", "live_auction", "reserve_for_live", "reserveforlive"].contains($0) }
    }

    var body: some View {

//        ZStack {
            VStack{
                VStack{
                    if forSheet{
                        PrimarySheetHeader(title: "Add New Product", onClose: {
                            onCancel()
                        })
                        .padding(.vertical,12)
                    }else{
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
                }
                .frame(height: forSheet ? 60 : 50)
                .background(Color.white)

                ScrollView(showsIndicators:false){

                    MediaPickerView(uploadedImageUrls: $imageUrls, uploadedVideoUrls: $uploadedVideoUrls)

                    VStack(alignment:.leading,spacing: 8){
                        Text("Product Details".localized)
                            .font(.custom(robotoMedium, size: 16.0))
                            .padding(.top,8)
                            .padding([.leading,.trailing],16.0)
                        if isCategoryLocked {
                            // Show locked category field
                            LockedCategoryField(categoryName: selectedCategory)
                                .padding([.leading, .trailing], 16)
                        } else{
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
                            }
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
//                        AuthTextField(floatingLabel: "Quantity".localized, placeholder: "Enter Quantity".localized, icon: .menuProfile, text: $request.quantity ,isIconDisplay : false,
//                                      custFontName : robotoMedium,
//                                      custFontSize : 14.0,
//                                      enteredText:  { quantity in
//                            request.quantity = quantity
//                        })
//                        .keyboardType(.numberPad)
//                        .padding([.bottom],4)
                        Text("Quantity")
                            .font(.custom(robotoMedium, fixedSize: 14.0))
                            .foregroundStyle(.text)
                            .padding(.horizontal,16)
                        HStack(spacing: 6) {
                            Button(action: {
                                var quantity = Int(request.quantity) ?? 0
                                if quantity > 1 {
                                    quantity -= 1
                                    request.quantity = "\(quantity)" // keep request in sync
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.custom(poppinsBold, size: 16.0))
                                    .foregroundColor(.defaultTheme)
                                    .frame(width: 40, height: 40) // fixed size
                                    .background(.defaultThemeLight)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)

                            Text("\(request.quantity)")
                                .font(.custom(poppinsSemiBold, fixedSize: 13.0))
                                .frame(width: 50, alignment: .center)

                            Button(action: {
                                var quantity = Int(request.quantity) ?? 0
                                quantity += 1
                                request.quantity = "\(quantity)"
                            }) {
                                Image(systemName: "plus")
                                    .font(.custom(poppinsBold, size: 16.0))
                                    .foregroundColor(.defaultTheme)
                                    .frame(width: 40, height: 40) // fixed size
                                    .background(.defaultThemeLight)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal,16)
                        .padding([.top,.bottom],4)
//

                        // Shipping Profile (optional). If selected, Mail Class + Dimensions become optional.
                        DropDownSelection(
                            options: $shippingProfileNames,
                            floatingLabel: "Shipping Profile",
                            hint: "Select",
                            selected: $selectedShippingProfileName,
                            anchor: .bottom,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                selectedShippingProfileName = value
                                if let profile = profiles.first(where: { $0.name == value }) {
                                    request.shipping_profile_id = profile.id != nil ? "\(profile.id!)" : ""
                                } else {
                                    request.shipping_profile_id = ""
                                }

                                if isUsingShippingProfile {
                                    // When using shipping profile, Mail Class + Dimensions are not required.
                                    request.mail_class = ""
                                }
                            }
                        )
                        .padding([.leading,.trailing],16)
                        .zIndex(1202.0)

                        if isUsingShippingProfile {
                            Button(action: {
                                selectedShippingProfileName = ""
                                request.shipping_profile_id = ""
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.primary)
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
                                options: $mailClassList, floatingLabel:"Mail Class",
                                hint: "Select",
                                selected: $request.mail_class,
                                anchor: .bottom,
                                custFontName: robotoMedium,
                                custFontSize:  14.0,
                                custCategory : robotoRegular,
                                custCategorySize : 13.0,
                                onOptionSelected: { value in
                                    request.mail_class = value
                                }
                            )
                            .padding([.leading,.trailing],16)

                            // Dimensions Section (required when no shipping profile selected)
                            DimensionsSection(request: $request, limits: selectedMailClass)
                        }

                        DropDownSelection(
                            options: $processingListArr, floatingLabel:"Processing Category",
                            hint: "Select",
                            selected: $request.processing_category,
                            anchor: .bottom,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                request.processing_category = value
                            }
                        )
                        .padding([.leading,.trailing],16)

                        DropDownSelection(
                            options: $conditionListArr, floatingLabel:"Condition",
                            hint: "Select",
                            selected: $request.product_condition,
                            anchor: .bottom,
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

                        AuthTextField(floatingLabel: "Buy It Now Price".localized,
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

                                // Basecamp #9933973683 (2026-05-29 RETURN): flash sale
                                // setup fields. Previously the toggle existed but there
                                // were no inputs for price/dates, so enabling flash sale
                                // only set flash_sale=1 in the payload with no price/window.
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
                                        HStack {
                                            Text("Starts at")
                                                .font(.custom(poppinsBold, size: 11))
                                                .foregroundColor(.orange)
                                            Spacer(minLength: 8)
                                            DatePicker("", selection: $flashSaleStartsAt)
                                                .labelsHidden()
                                                .datePickerStyle(.compact)
                                                .fixedSize()
                                        }
                                        HStack {
                                            Text("Ends at")
                                                .font(.custom(poppinsBold, size: 11))
                                                .foregroundColor(.orange)
                                            Spacer(minLength: 8)
                                            DatePicker("", selection: $flashSaleEndsAt, in: Date()...)
                                                .labelsHidden()
                                                .datePickerStyle(.compact)
                                                .fixedSize()
                                        }
                                        Text("Buyers see a flash-sale badge + countdown on this product during the window.")
                                            .font(.custom(poppinsRegular, size: 11))
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
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


                    VStack(alignment:.leading,spacing: 8){

                        // Sales Options - Enhanced Toggle Cards
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
                    if hideDraftButton {
                        PrimaryButton(
                            title: isEditing ? "Update" : "Continue",
                            isOutLine: false,
                            onButtonClick: {
                                hideKeyboardPopup()
                                saveProductDetails(as: "active")
                            },
                            cornerRadius: 32,
                            btnTextColor: .white
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    } else {
                        TwoButton(
                            titleOne: isEditing ? "Update" : "Publish",
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
                    }
                }
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

                        setupPreSelectedCategory()
                        setupEditingProductIfNeeded()
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

    private func setupPreSelectedCategory() {
            guard let categoryId = preSelectedCategoryId, !categoryId.isEmpty else { return }

            request.category_id = categoryId

            if let categoryName = preSelectedCategoryName, !categoryName.isEmpty {
                selectedCategory = categoryName
            } else if let id = Int(categoryId),
                      let derivedName = categoryList.first(where: { $0.id == id })?.name,
                      !derivedName.isEmpty {
                selectedCategory = derivedName
            }

            // If category is locked, fetch subcategories automatically
            if isCategoryLocked {
                Task {
                    await fetchSubCategoriesForPreSelectedCategory(categoryId: categoryId)
                }
            }
        }

    private func setupEditingProductIfNeeded() {
        guard let product = editingProduct else { return }

        // Basic info
        if let categoryId = product.category?.id, categoryId != 0 {
            request.category_id = "\(categoryId)"
        }
        request.title = product.title ?? ""
        request.description = product.description ?? ""
        request.quantity = product.quantity ?? "1"

        // Dimensions
        request.width = "\(product.width ?? 0.0)"
        request.height = "\(product.height ?? 0.0)"
        request.length = "\(product.length ?? 0.0)"
        request.weight = "\(product.weight ?? 0.0)"

        // Mail / processing / condition
        request.mail_class = product.mailClass ?? ""
        request.processing_category = product.processingCategory ?? ""
        request.product_condition = product.productCondition ?? ""

        // Pricing flags
        request.pricing = product.pricing ?? ""
        let isAuctionProduct = productIsAuction(product)
        isTappedFlash = product.flashSale ?? false
        isTappedAccept = product.acceptOffers ?? false
        isTappedReserve = product.reserveForLive ?? isAuctionProduct
        request.flash_sale = isTappedFlash ? "1" : "0"
        request.accept_offers = isTappedAccept ? "1" : "0"
        request.reserve_for_live = isTappedReserve ? "1" : "0"
        // Basecamp #9933973683 (2026-05-29 RETURN): pre-fill flash sale
        // price + window when editing a product that already has a flash sale.
        if let flashPrice = product.flashSalePrice, flashPrice > 0 {
            flashSalePriceText = String(format: "%.2f", flashPrice)
        }
        if let startsStr = product.flashSaleStartsAt,
           let startsDate = ISO8601DateFormatter().date(from: startsStr) {
            flashSaleStartsAt = startsDate
        }
        if let endsStr = product.flashSaleEndsAt,
           let endsDate = ISO8601DateFormatter().date(from: endsStr) {
            flashSaleEndsAt = endsDate
        }

        // Segment guess: persisted auction/type flags imply auction.
        if isAuctionProduct {
            segment = .Auction
            selectedFormat = .auction
        } else {
            segment = .Buyit
            selectedFormat = .buyItNow
        }

        // Media
        imageUrls = product.images ?? []
        if imageUrls.isEmpty {
            imageUrls = product.thumbnail ?? []
        }
        uploadedVideoUrls = product.videos ?? []

        // Shipping profile
        if let shippingProfileId = product.shippingProfileId, shippingProfileId != 0 {
            request.shipping_profile_id = "\(shippingProfileId)"
            if let name = profiles.first(where: { $0.id == shippingProfileId })?.name {
                selectedShippingProfileName = name
            }
        }

        // Category UI label
        if isCategoryLocked {
            if let name = product.category?.name, !name.isEmpty {
                selectedCategory = name
            } else if let idStr = product.category?.id, idStr != 0,
                      let derived = categoryList.first(where: { $0.id == idStr })?.name {
                selectedCategory = derived
            }
        }
    }

        // NEW: Fetch subcategories for pre-selected category
        private func fetchSubCategoriesForPreSelectedCategory(categoryId: String) async {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
                onError: { error in
                    print("Error fetching subcategories: \(error)")
                },
                onSuccess: {
                    self.subCategoryList.removeAll()
                    if let response = self.viewModel.categoryResponse {
                        self.subCategoryList = response.data
                        self.subCategoryName = self.subCategoryList.map { $0.name ?? "" }
                    }
                }
            ) {
                let request = CategoryRequest(category_id: categoryId)
                try await self.viewModel.getSubCategoryList(param: request)
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
            self.mailClassList = data.map {$0.label }
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
                        "auction": selectedFormatIsAuction,
                        "type": selectedProductType,
                        "shipping_profile_id": request.shipping_profile_id,
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
                        "status": request.status,
                        "hazardous_material": isHazardousMaterial
                    ]
                    if isEditing, let productId = editingProduct?.id {
                        productRequest["product_id"] = productId
                    }

                    if !variantArray.isEmpty {
                        productRequest["variant"] = variantArray
                    }

                    // 🔹 Call product store API
                    self.viewModel.errorMessage = nil
                    try await viewModel.storeProduct(productId: isEditing ? (editingProduct?.id ?? 0) : nil, param: productRequest)

                    // Basecamp #9933973683 (2026-05-29 RETURN): follow up with
                    // flash-sale endpoint. The main storeProduct call only sends
                    // flash_sale=1|0; the price + window go to a dedicated route.
                    if let productId = viewModel.storeProductResponse?.data.id ?? (isEditing ? editingProduct?.id : nil) {
                        if isTappedFlash, let price = Double(flashSalePriceText), price > 0 {
                            await setFlashSaleForProduct(productId: productId, price: price,
                                                         startsAt: flashSaleStartsAt, endsAt: flashSaleEndsAt)
                        } else if !isTappedFlash && isEditing {
                            await clearFlashSaleForProduct(productId: productId)
                        }
                    }
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

        if request.shipping_profile_id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // No shipping profile: Mail Class + Dimensions are required.
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

    // Basecamp #9933973683 (2026-05-29 RETURN): flash-sale API helpers,
    // mirrored from EditProductScreen. POST /api/product/flash-sale sets the
    // price + window; DELETE /api/product/flash-sale/<id> clears it.
    private func setFlashSaleForProduct(productId: Int, price: Double, startsAt: Date, endsAt: Date) async {
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/flash-sale") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let token = UserDefaults.accessToken
        req.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let isoFmt = ISO8601DateFormatter()
        let body: [String: Any] = [
            "product_id": productId,
            "flash_sale_price": price,
            "starts_at": isoFmt.string(from: startsAt),
            "ends_at": isoFmt.string(from: endsAt)
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do { _ = try await URLSession.shared.data(for: req) } catch { print("setFlashSale failed: \(error)") }
    }

    private func clearFlashSaleForProduct(productId: Int) async {
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/flash-sale/\(productId)") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let token = UserDefaults.accessToken
        req.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        do { _ = try await URLSession.shared.data(for: req) } catch { print("clearFlashSale failed: \(error)") }
    }

    func storeSuccess(){
        if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: errorMessage,
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
            return
        }

        let response = viewModel.storeProductResponse
        if response?.status?.lowercased() == "success" {
            if let product = response?.data {
                if isEditing {
                    onProductUpdated?(product)
                } else {
                    onProductCreated?(product)
                }
            }
            alertType = .sheetType(
                icon: .success,
                title: "Success",
                message: response?.message ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
            showError = true
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: response?.message ?? "Product could not be saved.",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
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

extension MailClass {
    var hasAnyLimitsOrNotes: Bool {
        (max_weight_lbs ?? 0) > 0 ||
        (max_length_in ?? 0) > 0 ||
        (max_width_in ?? 0) > 0 ||
        (max_height_in ?? 0) > 0 ||
        (max_length_plus_girth_in ?? 0) > 0 ||
        !(notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
}

struct MailClassLimitsView: View {
    let mailClass: MailClass

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let notes = mailClass.notes, !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(notes)
                    .font(.custom(robotoRegular, size: 12))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            let items: [(String, String?)] = [
                ("Max weight", mailClass.max_weight_lbs.map { "\($0) lbs" }),
                ("Max length", mailClass.max_length_in.map { "\($0) in" }),
                ("Max width", mailClass.max_width_in.map { "\($0) in" }),
                ("Max height", mailClass.max_height_in.map { "\($0) in" }),
                ("Max length + girth", mailClass.max_length_plus_girth_in.map { "\($0) in" })
            ]

            let filteredItems: [(String, String)] = items.compactMap { pair in
                let (title, value) = pair
                guard let value, !value.isEmpty else { return nil }
                return (title, value)
            }

            ForEach(filteredItems, id: \.0) { item in
                HStack(spacing: 6) {
                    Text(item.0 + ":")
                        .font(.custom(robotoMedium, size: 12))
                        .foregroundColor(.gray)
                    Text(item.1)
                        .font(.custom(robotoRegular, size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct HazardousLabel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hazardous Materials")
                .font(.custom(poppinsMedium, size: 16))
                .foregroundColor(.primary)

            Text("Carriers restrict shipping of items that may pose a safety risk, like lithium batteries.")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

enum lisProductScreenSegment : String, CaseIterable, CustomStringConvertible {
    case Buyit = "Buy It Now"
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
    var limits: MailClass? = nil

    // Basecamp #9988324984 — USPS package-size presets.
    // Default is .custom; selecting a preset fills width/height/length.
    // Dimensions are always treated as inches in this section (no unit field).
    @State private var selectedPackagePreset: USPSPackagePreset = .custom

    private func maxLabel(_ value: Double?, unit: String) -> String? {
        guard let value, value > 0 else { return nil }
        return "max \(value) \(unit)"
    }

    private func applyPreset(_ preset: USPSPackagePreset) {
        guard preset != .custom else { return }
        request.length = formatDimension(preset.length)
        request.width  = formatDimension(preset.width)
        request.height = formatDimension(preset.height)
    }

    private func formatDimension(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%g", value)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Image(systemName: "cube.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.defaultTheme)

                Text("Package Dimensions")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)

                Spacer()
            }
            .padding(.horizontal, 16)

            // USPS Package Preset Picker (Basecamp #9988324984)
            USPSPackagePresetPicker(selectedPreset: $selectedPackagePreset)
                .padding(.horizontal, 16)
                .onChange(of: selectedPackagePreset) { newPreset in
                    applyPreset(newPreset)
                }

            // Dimensions Grid
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Width Field
                    DimensionField(
                        label: "Width",
                        maxText: maxLabel(limits?.max_width_in, unit: "in"),
                        unit: "in",
                        value: $request.width,
                        icon: "arrow.left.and.right"
                    )

                    // Height Field
                    DimensionField(
                        label: "Height",
                        maxText: maxLabel(limits?.max_height_in, unit: "in"),
                        unit: "in",
                        value: $request.height,
                        icon: "arrow.up.and.down"
                    )
                }

                HStack(spacing: 12) {
                    // Length Field
                    DimensionField(
                        label: "Length",
                        maxText: maxLabel(limits?.max_length_in, unit: "in"),
                        unit: "in",
                        value: $request.length,
                        icon: "arrow.forward"
                    )

                    // Weight Field
                    DimensionField(
                        label: "Weight",
                        maxText: maxLabel(limits?.max_weight_lbs, unit: "lbs"),
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
                .fill(Color.defaultThemeLight)
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
    var maxText: String? = nil
    let unit: String
    @Binding var value: String
    let icon: String

    @State private var isFocused: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label with Icon
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.custom(poppinsSemiBold,size: 13.0))
                    .foregroundColor(.defaultTheme)

                Text(maxText == nil ? label : "\(label) (\(maxText!))")
                    .font(.custom(poppinsSemiBold,size: 13.0))
                    .foregroundColor(.darkGray)
            }

            // Input Field with Unit
            HStack(spacing: 8) {
                TextField("0", text: $value, onEditingChanged: { focused in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = focused
                    }
                })

                .keyboardType(.decimalPad)
                .font(.custom(poppinsSemiBold,size: 13.0))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)

                Text(unit)
                    .font(.custom(poppinsSemiBold,size: 13.0))
                    .foregroundColor(.darkGray)
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
struct LockedCategoryField: View {
    let categoryName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.custom(robotoMedium, size: 14.0))
                .foregroundColor(.text)

            HStack {
                Text(categoryName)
                    .font(.custom(robotoRegular, size: 13.0))
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - USPS Package Presets (Basecamp #9988324984)
// Defined here (a compiled file) because new standalone files are not
// registered in project.pbxproj and would not be built. Shared module-wide by
// CreateProductScreen, EditProductScreen (via DimensionsSection) and
// CreateShippingProfileScreen.
import Foundation
import SwiftUI

// MARK: - USPS Package Preset

/// A single USPS flat-rate size preset.
/// All dimension values are in inches.
struct USPSPackagePreset: Identifiable, Equatable {
    let id: String          // unique stable identifier (the label)
    let label: String       // display name shown in the picker
    let length: Double
    let width: Double
    let height: Double

    // Convenience: the unit string expected by the shipping-profile screen.
    static let unitLabel = "Inch"
}

// MARK: - Preset Catalogue

extension USPSPackagePreset {

    /// "Custom" sentinel — selecting this leaves fields untouched.
    static let custom = USPSPackagePreset(
        id: "custom",
        label: "Custom",
        length: 0, width: 0, height: 0
    )

    static let all: [USPSPackagePreset] = [
        custom,
        USPSPackagePreset(id: "flat_rate_envelope",
                          label: "USPS Flat Rate Envelope",
                          length: 12.5, width: 9.5, height: 0.5),
        USPSPackagePreset(id: "window_flat_rate_envelope",
                          label: "USPS Window Flat Rate Envelope",
                          length: 12.5, width: 9.5, height: 0.5),
        USPSPackagePreset(id: "small_flat_rate_envelope",
                          label: "USPS Small Flat Rate Envelope",
                          length: 10, width: 6, height: 0.5),
        USPSPackagePreset(id: "padded_flat_rate_envelope",
                          label: "USPS Padded Flat Rate Envelope",
                          length: 12.5, width: 9.5, height: 0.5),
        USPSPackagePreset(id: "legal_flat_rate_envelope",
                          label: "USPS Legal Flat Rate Envelope",
                          length: 15, width: 9.5, height: 0.5),
        USPSPackagePreset(id: "small_flat_rate_box",
                          label: "USPS Small Flat Rate Box",
                          length: 8.69, width: 5.44, height: 1.75),
        USPSPackagePreset(id: "medium_flat_rate_box_1",
                          label: "USPS Medium Flat Rate Box 1 (Top Loading)",
                          length: 11.25, width: 8.75, height: 6),
        USPSPackagePreset(id: "medium_flat_rate_box_2",
                          label: "USPS Medium Flat Rate Box 2 (Side Loading)",
                          length: 14, width: 12, height: 3.5),
        USPSPackagePreset(id: "large_flat_rate_box",
                          label: "USPS Large Flat Rate Box",
                          length: 12.25, width: 12.25, height: 6),
    ]
}

// MARK: - Formatted dimension string (for display in menu label)

extension USPSPackagePreset {
    /// "12.5 × 9.5 × 0.5 in" — appended to non-custom menu items.
    var dimensionSummary: String {
        func fmt(_ v: Double) -> String {
            v.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", v)
                : String(format: "%g", v)
        }
        return "\(fmt(length)) × \(fmt(width)) × \(fmt(height)) in"
    }

    /// Full menu label: "USPS Flat Rate Envelope  12.5 × 9.5 × 0.5 in"
    var menuLabel: String {
        self == .custom ? label : "\(label)  \(dimensionSummary)"
    }
}

// MARK: - Picker View (reusable)

/// A compact Menu-style picker that sits above dimension fields.
/// Selecting a non-Custom preset calls `onSelect` with the chosen preset.
/// Selecting Custom calls `onSelect(.custom)` — callers must ignore it to
/// leave existing values untouched.
struct USPSPackagePresetPicker: View {
    @Binding var selectedPreset: USPSPackagePreset

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "shippingbox")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.defaultTheme)

            Text("USPS Package Preset")
                .font(.custom(poppinsMedium, size: 13))
                .foregroundColor(.darkGray)

            Spacer()

            Menu {
                ForEach(USPSPackagePreset.all) { preset in
                    Button(preset.menuLabel) {
                        selectedPreset = preset
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedPreset.label)
                        .font(.custom(poppinsMedium, size: 13))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.defaultTheme.opacity(0.04))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.defaultTheme.opacity(0.15), lineWidth: 1)
        )
    }
}
