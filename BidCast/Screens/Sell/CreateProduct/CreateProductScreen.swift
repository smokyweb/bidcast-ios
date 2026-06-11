//
//  CreateProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SVProgressHUD
import AlertToast

enum CreateProductNavigation {
    case inventry
    case other
}

struct CreateProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var categorySelect : String = ""
    @State var categoyList = [String]()
    //previuos Data
    @Binding var requests : StoreScheduleShowRequest
    @Binding var thumbNail : String
//    @Binding var backToPrepare : Bool
    @State var productTitle = ""
    @State var message = ""
    @State var isTappedFlash : Bool = false
    // Basecamp #9933973683 (2026-05-27): flash sale state.
    @State private var flashSalePriceText: String = ""
    @State private var flashSaleStartsAt: Date = Date()
    @State private var flashSaleEndsAt: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State var isTappedAccept : Bool = false
    @State var isTappedReserve: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var categoryNames: [String] = []
    @State var selectedCategory = ""
    @State var categoryList: [CategoryDataModel] = []
    @State var mailClassList = [String]()
    //category request data
    @State var request : StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "1", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"",  product_condition: "")
    
    @State var viewModel = ListProductViewModel()
    @State private var imageUrls: [String] = []
    @State private var videoUrls: [String] = []
    
    @State var shippingProfileNames: [String] = []
    @State var selectedShippingProfileName: String = ""
    @State private var profiles: [StoreShippingModel] = []
    @StateObject private var shippingViewModel = ShippingViewModel()

    
    @State var showSellerSheet = false
    @State var navigateToSeller = false
    @State var showSubCategorySheet = false
    @State var selectedOption: Set<String> = []
    @State var selectedSubCategory = ""
    @State var subCategoryList: [CategoryDataModel] = []
    @State var subCategoryName : [String] = [""]
    //    @Binding var productData : InventoryDataModel
    @State var extraFields: [ExtraFieldModel] = []
    
    @State var processingListArr = ["Letters","Flats","Machinaable","Nonstandard","Non Machinable"]
    
    @State var conditionListArr = ["New",
                     "Like New",
                     "Gently Loved",
                     "Well Loved",
                     "Other",
                     "Trending"]
    
    @State var navigateToShippingProfiles = false
    @State var extraFieldValues: [String: String] = [:]
    @State var selectedRadio: [String: String] = [:]
    @State var navigateToAddProduct = false
    @State var navigateToSalesFormat = false
    @State var navigateToProuct = false
    @State var comeFromProductLibrary = false
    @Binding var fromPrepare : Bool
    @EnvironmentObject var coordinator: LetsPrepareCoordinator
    
    var isComeFrom: CreateProductNavigation = .other
    @State var editProductData: ProductDataModel1? = nil
    @State var openShippingSheet = false
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    
    @State private var navFromPrepare = false
    @State private var navFromProductLibrary = false

    // Basecamp #9988324984 — USPS package-size preset picker state.
    @State private var selectedPackagePreset: USPSPackagePreset = .custom

    @EnvironmentObject var productManager: ProductManager
    @State var productId = ""
    var body: some View {
        
        ZStack(alignment: .bottom) {
            VStack{
                VStack{
                    PrimaryHeader(
                        title: "Create Product".localized,
                        isForLogo : false, leadingImgArr: ["chevron.left"],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            if comeFromProductLibrary{
                                if fromPrepare{
                                    navigateToProuct = true
                                }else{
                                    navigateToAddProduct = true
                                }
                            }else{
                               
                                self.presentationMode.wrappedValue.dismiss()
                            }
                            productId.removeAll()
                        },
                        count: .constant(0)
                    )
                }
//                .padding(.horizontal, 12)
                
                ScrollView(showsIndicators:false) {
                    
                    MediaPickerView(uploadedImageUrls: $imageUrls, uploadedVideoUrls: $videoUrls)
//                        .padding(.horizontal,12)
                        .background(.clear)
                    
                    VStack(alignment:.leading,spacing: 8){
                        
                        DropDownSelection(
                            options: $categoryNames,
                            floatingLabel:"Category",
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
                                Task {
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
                                        let request = CategoryRequest(category_id: request.category_id)
                                        try await self.viewModel.getSubCategoryList(param: request)
                                    }
                                }
                            }
                        )
                        .disabled(isComeFrom == .inventry ? false : !selectedCategory.isEmpty)
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
                        
                        // Basecamp #9988324984 — USPS package-size preset picker.
                        // Placed above dimension fields; selecting a preset fills
                        // width/height/length with the preset's inch values.
                        // Fields remain editable after selection (no snap-back).
                        USPSPackagePresetPicker(selectedPreset: $selectedPackagePreset)
                            .padding([.bottom], 4)
                            .onChange(of: selectedPackagePreset) { newPreset in
                                guard newPreset != .custom else { return }
                                let fmt: (Double) -> String = { v in
                                    v.truncatingRemainder(dividingBy: 1) == 0
                                        ? String(format: "%.0f", v)
                                        : String(format: "%g", v)
                                }
                                request.length = fmt(newPreset.length)
                                request.width  = fmt(newPreset.width)
                                request.height = fmt(newPreset.height)
                            }

                        AuthTextField(floatingLabel: "Width (in)".localized, placeholder: "Enter width".localized, icon: .menuProfile, text: $request.width ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.width = quantity
                        })
                        .keyboardType(.decimalPad)
                        .padding([.bottom],4)

                        AuthTextField(floatingLabel: "Height (in)".localized, placeholder: "Enter height".localized, icon: .menuProfile, text: $request.height ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.height = quantity
                        })
                        .keyboardType(.decimalPad)
                        .padding([.bottom],4)

                        AuthTextField(floatingLabel: "Length (in)".localized, placeholder: "Enter length".localized, icon: .menuProfile, text: $request.length ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.length = quantity
                        })
                        .keyboardType(.decimalPad)
                        .padding([.bottom],4)
                        
                        AuthTextField(floatingLabel: "Weight (lbs)".localized, placeholder: "Enter Weight".localized, icon: .menuProfile, text: $request.weight ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.weight = quantity
                        })
                        .keyboardType(.decimalPad)
                        .padding([.bottom],4)
                        
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
                            anchor: .bottom,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                //                                if let id = categoryList.first(where: { $0.name == value })?.id {
                                request.processing_category = value
                                //                                } else {
                                //                                    request.processing_category = ""
                                //                                }
                            }
                        )
                        .padding([.leading,.trailing],16)
                        .background(.clear)
                        
                        
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
                        
                        // Quantity Selector
                        HStack(spacing: 6) {
                            Button(action: {
                                var quantity = Int(request.quantity) ?? 0
                                if quantity > 1 {
                                    quantity -= 1
                                    request.quantity = "\(quantity)" // keep request in sync
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 40, height: 40) // fixed size
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(request.quantity)")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 50, alignment: .center)
                            
                            Button(action: {
                                var quantity = Int(request.quantity) ?? 0
                                quantity += 1
                                request.quantity = "\(quantity)"
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 40, height: 40) // fixed size
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal,12)
                        
//                        PrimaryButton(
//                            title: "Add Variants",
//                            isOutLine: false,
//                            custFontName : poppinsSemiBold,
//                            custFontSize : 14.0,
//                            onButtonClick: {
//                                print("hell")
//                            }, imageName: "ic_Plus", btnColor: .white)
                    }
                    //                    .background(.white)
                    .padding(.bottom, 16)
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.top,4)
                    .padding(.horizontal, 12)
                    
                    VStack(alignment:.leading,spacing: 8){

                        // Basecamp #9933973683 (2026-05-27): flash sale toggle + details.
                        Toggle(isOn: $isTappedFlash) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Flash Sale")
                                    .font(.custom(poppinsBold, size: 14))
                                Text("Set a time-limited discount price")
                                    .font(.custom(poppinsRegular, size: 11))
                                    .foregroundColor(.gray)
                            }
                        }
                        .onChange(of: isTappedFlash) { _, on in
                            request.flash_sale = on ? "1" : "0"
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)

                        if isTappedFlash {
                            // Basecamp #9933973683 (2026-05-29): the flash-sale
                            // config used two `.compact` date+time DatePickers
                            // side-by-side in an HStack. Each compact picker has
                            // a wide intrinsic size (date AND time pills), so two
                            // of them plus spacing exceeded the phone width and
                            // the card stretched past the screen edge. Stack the
                            // two pickers vertically as full-width rows so the
                            // card always fits, and put each label + picker on
                            // one line with the picker right-aligned.
                            VStack(alignment: .leading, spacing: 12) {
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

                        // Sales Options - Enhanced Toggle Cards
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
                                    request.shipping_profile_id = profile.id != nil ? "\(profile.id!)" : ""
                                }
                                
                            }
                        )
                        .padding([.leading,.trailing],12)
                        
                    }
                    .padding(.bottom, 16)
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.top,2)
                    .padding(.horizontal, 12)
                    
                    
                    TwoButton(titleOne: "Continue",
                              titleTwo: "Use Product Library",
                              onFirstButtonClick: {
                        print(request)
                        print(imageUrls)
                        guard !(imageUrls.isEmpty && videoUrls.isEmpty) else {
                            hudMsg = "Please add images or videos"
                            showhud = true
                            return
                        }
                        guard !requests.category_id.isEmpty else{
                            hudMsg = "Please select category"
                            showhud = true
                            return
                        }
                        guard !request.title.isEmpty else{
                            hudMsg = "Please enter title"
                            showhud = true
                            return
                        }
                        guard !request.description.isEmpty else{
                            hudMsg = "Please enter description"
                            showhud = true
                            return
                        }
                        guard !request.width.isEmpty else{
                            hudMsg = "Please enter width"
                            showhud = true
                            return
                        }
                        guard !request.height.isEmpty else{
                            hudMsg = "Please enter height"
                            showhud = true
                            return
                        }
                        guard !request.length.isEmpty else{
                            hudMsg = "Please enter length"
                            showhud = true
                            return
                        }
                        guard !request.weight.isEmpty else{
                            hudMsg = "Please enter weight"
                            showhud = true
                            return
                        }
                        guard !request.mail_class.isEmpty else{
                            hudMsg = "Please select mail class"
                            showhud = true
                            return
                        }
                        guard !request.processing_category.isEmpty else{
                            hudMsg = "Please select processing category"
                            showhud = true
                            return
                        }
                        guard !request.product_condition.isEmpty else{
                            hudMsg = "Please select product condition"
                            showhud = true
                            return
                        }
                        guard !request.shipping_profile_id.isEmpty else{
                            hudMsg = "Please select shipping profile"
                            showhud = true
                            return
                        }
                        navigateToSalesFormat = true
                    },
                              onSecButtonClick: {
                        request = StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "", accept_offers: "", reserve_for_live: "", shipping_profile_id: "", status: "", width: "", length: "", weight: "", height: "", mail_class: "", processing_category: "", product_condition: "")
                        imageUrls.removeAll()
                        videoUrls.removeAll()
                        selectedShippingProfileName.removeAll()
                        if self.fromPrepare{
                            navigateToProuct = true
                        }else{
                            navigateToAddProduct = true
                        }
                        
                    },firstBtnTitleColor:.defaultTheme, firstBtnBgColor: .defaultThemeLight,secBtnTitleColor:.white, secBtnBgColor: .defaultTheme)
//                    .padding(.horizontal,12)
                    .padding(.bottom, 16)
                }
//                .padding(.horizontal,12)
            }
            

            
            CusNavLink(doNavigate: $navigateToAddProduct, destination: AddProductsScreen(request:$requests,thumbNail: $thumbNail,fromPrepare: $navFromPrepare, NavFromProductLibrary: $navigateToAddProduct, backToCreateProduct:$navigateToAddProduct,didTapBack:{ value,manager,coordinat in
                comeFromProductLibrary = value
                
//                productManager  = manager
            },didTapEdit:{ product,coordinat in
                comeFromProductLibrary = true
                editProductData = product
                populateProductData(product)
                
            })
                .environmentObject(productManager)
            )
            
            //from prepare
            CusNavLink(doNavigate: $navigateToProuct, destination: AddProductsScreen(request:$requests,thumbNail: $thumbNail,fromPrepare: $fromPrepare, NavFromProductLibrary: .constant(false), backToCreateProduct: $navigateToProuct ,didTapBack:{ value,manager,coordinat in
                comeFromProductLibrary = value
//                productManager  = manager
            },didTapEdit:{ product,coordinat in
                comeFromProductLibrary = true
                editProductData = product
                populateProductData(product)
            })
                .environmentObject(productManager)
            )
            
            CusNavLink(doNavigate: $navigateToSalesFormat,
                       destination: SalesFormatScreen(request: $request,
                                                      storeScheduleRequest: $requests,
                                                      imageUrls : $imageUrls,
                                                      videoUrls: $videoUrls,
                                                      thumbNail: $thumbNail,
                                                      fromPrepare: $fromPrepare,
                                                      backToCreateProduct:$navigateToSalesFormat,
                                                      productId: $productId,
                                                      didTapBack:{ value, manager,coordinat in
                comeFromProductLibrary = value
                imageUrls.removeAll()
                videoUrls.removeAll()
                selectedShippingProfileName.removeAll()
              
                //                productManager = manager
                
            },didTapEdit  : { product,coordinat in
                comeFromProductLibrary = true
                
                editProductData = product
                populateProductData(product)
                
            })
                        .environmentObject(productManager)
            )
            
            CusNavLink(doNavigate: $navigateToShippingProfiles, destination: ShippingSettingsScreen())
        }
        .ignoresSafeArea(edges: .bottom)
        .background(.backGround)
        .bottomSheet(isPresented: $showError,
                     height: screenHeight * 0.35,
                     topBarCornerRadius: 25,
                     contentBackgroundColor: Color(.systemBackground),
                     topBarBackgroundColor: Color(.systemBackground),
                     showTopIndicator: false,
                     onDismiss: {
            if self.viewModel.errorMessage != "" || self.viewModel.errorMessage != nil{
                //errorMessage not nil
                showError = true
            }else{
                showError = false
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    self.presentationMode.wrappedValue.dismiss()
                    withAnimation { showError = false }
                }, onSecondaryClick: {
                    withAnimation { showError = false }
                })
            .background(Color(.systemBackground))
            .cornerRadius(25, corners: [.topLeft, .topRight])
        })
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
            
        }
        .bottomSheet(
            isPresented: $showSubCategorySheet,
            height: selectedOption.count < 4 ? screenHeight * 0.35 : screenHeight/1.7,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                showSubCategorySheet = true
            },
            content: {
                SelectionBottomSheet(
                    title: "Select Sub-Category",
                    message: "Please select Sub-category.",
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
        )
        .onFirstAppear(perform: {
            Task {
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: viewModel.errorMessage),
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
                    async let shippingTask: () = shippingViewModel.getShippingProfiles()
                    async let mailTask: () = viewModel.getMailClasses()
                    
                    // Wait for all
                    _ = try await (categoryTask, shippingTask, mailTask)
                }
            }
        })
        .onAppear {
            //assign categoryId
            request.category_id = "\(requests.category_id)"
//            if comeFromProductLibrary{
//                imageUrls.removeAll()
//                videoUrls.removeAll()
//                selectedShippingProfileName.removeAll()
//            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        
    }
    
    private func errorDesc(error: Error?, message: String?) -> String {
        guard let msg = message else {
            return error?.localizedDescription ?? "Something went wrong"
        }
        return msg
    }
    
    func mailSuccess() {
        let response = viewModel.mailClassResponse
        if response?.status == "success" {
            let data = response?.data.mail_classes ?? [MailClass]()
            self.mailClassList = data.map {$0.label }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
    }
    
    func categorySuccess() {
        
        let response = viewModel.categoryResponse
        if response?.status == "success" {
            self.categoryList = response?.data ?? [CategoryDataModel]()
            self.selectedCategory = self.categoryList.filter({$0.id == Int(requests.category_id)}).first?.name ?? ""
            self.categoryNames = response?.data.map { $0.name ?? "No Category" } ?? [String]()
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
    }
    
    private func successShippingProfiles() {
        let response = shippingViewModel.getShippingProfilesResponse
        self.profiles = response?.data ?? []
        if profiles.count != 0{
            openShippingSheet = false
            self.shippingProfileNames = profiles.map { $0.name ?? "" }
        }else{
            openShippingSheet = true
          
            config = BottomSheetConfig(
                icon: "exclamationmark.circle",
                title: "Missing",
                message: "Please add Shipping profile first for the successful product creation.",
                primaryButtonTitle: "Add Shipping Profile",
                secondaryButtonTitle: nil,bottomPadding: -70
            )
        }
    }
    private func populateProductData(_ product: ProductDataModel1) {
           // Basic Info
           request.title = product.title ?? ""
           request.description = product.description ?? ""
           request.quantity = "\(product.quantity ?? "1")"
        self.productId = "\(product.id ?? 0)"
           // Dimensions
        request.width = "\(product.width ?? 0.0)"
           request.height = "\(product.height ?? 0.0)"
           request.length = "\(product.length ?? 0.0)"
           request.weight = "\(product.weight ?? 0.0)"
           
           // Mail & Processing
//        request.mail_class = product.mailClass ?? ""
//        request.processing_category = product.processingCategory ?? ""
//        request.product_condition = product.productCondition ?? ""
           
           // Category
        if let categoryId = product.category?.id {
               request.category_id = "\(categoryId)"
               selectedCategory = categoryList.first(where: { $0.id == categoryId })?.name ?? ""
           }
           
           // Sub Category
           if let subCategoryId = product.subCategoryId {
               request.sub_category_id = "\(subCategoryId)"
           }
           
           // Shipping Profile
           if let shippingProfileId = product.shippingProfileId {
               request.shipping_profile_id = "\(shippingProfileId)"
               selectedShippingProfileName = profiles.first(where: { $0.id == shippingProfileId })?.name ?? ""
           }
        
        if let mailClass = product.mailClass, !mailClass.isEmpty {
            if self.mailClassList.contains(mailClass) {
                self.request.mail_class = mailClass
            }
        }
        
        // Set Processing Category - match with loaded options
        if let processingCategory = product.processingCategory, !processingCategory.isEmpty {
            if self.processingListArr.contains(processingCategory) {
                self.request.processing_category = processingCategory
            }
        }
        
        // Set Product Condition - match with loaded options
        if let condition = product.productCondition, !condition.isEmpty {
            if self.conditionListArr.contains(condition) {
                self.request.product_condition = condition
            }
        }
        
           // Images and Videos
           if let images = product.images {
               imageUrls = images.compactMap { $0.self }
           }
           
           if let videos = product.videos {
               videoUrls = videos.compactMap { $0.self }
           }
           // Sales Options
           request.pricing = product.pricing ?? ""
           request.flash_sale = product.flashSale == true ? "1" : "0"
           request.accept_offers = product.acceptOffers == true ? "1" : "0"
           request.reserve_for_live = product.reserveForLive == true ? "1" : "0"
           request.status = product.status ?? ""
       }
       
       /// Reset form to initial state
       private func resetForm() {
           request = StoreProductParam(
               category_id: "",
               title: "",
               description: "",
               quantity: "1",
               pricing: "",
               flash_sale: "0",
               accept_offers: "0",
               reserve_for_live: "0",
               shipping_profile_id: "",
               status: "",
               sub_category_id: "",
               width: "",
               length: "",
               weight: "",
               height:"",
               mail_class:"",
               processing_category:"",
               product_condition: ""
           )
           imageUrls.removeAll()
           videoUrls.removeAll()
           selectedShippingProfileName.removeAll()
           selectedCategory = ""
           editProductData = nil
       }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
