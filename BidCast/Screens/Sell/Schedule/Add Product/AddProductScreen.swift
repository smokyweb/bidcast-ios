//
//  AddProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct AddProductsScreen: View {
 
    @EnvironmentObject  var appRootManager: AppRootManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var productCount = 1
    @State var currentPage = 1
    @Environment(\.presentationMode) var presentationMode
    @Binding var request : StoreScheduleShowRequest
    @State var productDetails: StoreProductParam =  StoreProductParam(category_id: "",
                                                                      title: "",
                                                                      description: "",
                                                                      quantity: "1",
                                                                      pricing: "",
                                                                      flash_sale: "0",
                                                                      accept_offers: "0",
                                                                      reserve_for_live: "0",
                                                                      shipping_profile_id: "4",
                                                                      status: "",
                                                                      sub_category_id: "",
                                                                      width: "",
                                                                      length: "",
                                                                      weight: "",
                                                                      height:"",
                                                                      mail_class:"",
                                                                      processing_category:"", product_condition: "")
    @Binding var thumbNail : String
    
    // ⭐ CHANGED: Static product list that persists across navigation
    
    @EnvironmentObject var productManager: ProductManager
    
    @State var viewModel = ScheduleViewModel()
    @State var productViewModel = ProductViewModel()
    
    @State var deletedIndex: Int?
    @State var deletedProductId: String?
    
    @State private var isTapped = false
    @State var selectedProductIDs: Set<String> = []
    
    @State var navigateToInventry: Bool = false
    @State private var navigateToListProduct: Bool = false
    @State private var navigateToEditListProduct: Bool = false
    @State private var editingProduct: ProductDataModel1? = nil
    @State private var showRandomizerPicker = false
    @State private var showPostCreateRandomizerMapper = false
    @State private var postCreateRandomizerShowId: Int? = nil
    @State private var postCreateRandomizerTemplateId: Int? = nil
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var showCancelSheet: Bool = false
    @State var showDeleteProduct: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var navigateToTab = false
    
    @Binding var fromPrepare : Bool
//    @Binding var backToPrepare : Bool
    @Binding var NavFromProductLibrary : Bool
    @State var navigateToAddProduct  = false
    @State var navigateToEditProduct  = false
    @Binding var backToCreateProduct : Bool
//    var didTapBack : ((Bool,ProductManager) -> Void)?
//    var didTapEdit : ((ProductDataModel1) -> Void)?
    var didTapBack : ((Bool, ProductManager, LetsPrepareCoordinator) -> Void)?
    var didTapEdit : ((ProductDataModel1, LetsPrepareCoordinator) -> Void)?
    @EnvironmentObject var coordinator: LetsPrepareCoordinator

    private var filteredProducts: [ProductDataModel1] {
        let all = productManager.products
        switch request.auction_type_id {
        case "5":  // Buy Now show -> only buy-it-now products
            return all.filter { $0.isBuyNowProduct }
        case "8":  // Live Auction show -> only auction products
            return all.filter { $0.isLiveAuctionProduct }
        default:   // 9 / Surprise Sets / other -> no restriction
            return all
        }
    }

    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
//    init(
//            request: Binding<StoreScheduleShowRequest>,
//            thumbNail: Binding<String>,
//            productManager: ProductManager = ProductManager(), // ⭐ Default value
//            fromPrepare: Binding<Bool> = .constant(false),
//            backToPrepare: Binding<Bool> = .constant(false),
//            NavFromProductLibrary: Binding<Bool> = .constant(false),
//            backToCreateProduct: Binding<Bool> = .constant(false),
//            didTapBack: ((Bool,ProductManager) -> Void)? = nil,
//            didTapEdit: ((ProductDataModel1) -> Void)? = nil,
//            delegate: ShowStepDelegate? = nil
//        ) {
//            // ⭐ Use underscore for @Binding properties
//            self._request = request
//            self._thumbNail = thumbNail
//            self.productManager = productManager
//            self._fromPrepare = fromPrepare
//            self._backToPrepare = backToPrepare
//            self._NavFromProductLibrary = NavFromProductLibrary
//            self._backToCreateProduct = backToCreateProduct
//            self.didTapBack = didTapBack
//            self.didTapEdit = didTapEdit
//            self.delegate = delegate
//        }
    
  
    
    func clearProducts() {
//        productData.removeAll()
//        productDataList.removeAll()
        selectedProductIDs.removeAll()
        productManager.selectedProductIDs.removeAll()
        productManager.streamQuantities.removeAll()
        request.product_ids.removeAll()
        print("🗑️ Cleared all products")
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                PrimaryHeader(
                    title: "Add Products".localized,
                    isForLogo : false ,
                    leadingImgArr:["chevron.left"],
                    onClickLeading: { _ in
                        if backToCreateProduct{
//                            didTapBack?(false,productManager)
                            didTapBack?(true, productManager, coordinator)
                            backToCreateProduct = false
                        }else{
//                            didTapBack?(false,productManager)
                            didTapBack?(false, productManager, coordinator)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    },
                    count: .constant(0)
                )
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Add More Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Add More Products")
                                    .font(.custom(poppinsSemiBold, size: 16))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(productManager.products.count)/100")
                                    .font(.custom(poppinsMedium, size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                addProductOption(text: "Add another product") {
                                    navigateToListProduct = true
                                }
                                
                                addProductOption(text: "Select from product Inventory"){
                                    navigateToInventry = true
                                }
                            }

                            randomizerProductOption {
                                showRandomizerPicker = true
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Added Product Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Added Products")
                                .font(.custom(poppinsSemiBold, size: 16))
                                .foregroundColor(.primary)
                            
                            if filteredProducts.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "cube.box")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray.opacity(0.4))
                                    
                                    Text("No product found")
                                        .font(.custom(poppinsMedium, size: 15))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Add products to your show")
                                        .font(.custom(poppinsRegular, size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                                
                            } else {
                                ForEach(filteredProducts.indices, id: \.self) { index in
                                    let data = filteredProducts[index]
                                    let idStr = "\(data.id ?? -1)"
                                    let isSelected = productManager.selectedProductIDs.contains(idStr)
                                    let availQty = max(1, data.availableQuantity)

                                    // Basecamp #9991372302: bind stream qty from
                                    // productManager so changes persist immediately.
                                    let streamQtyBinding = Binding<Int>(
                                        get: {
                                            productManager.streamQuantities[idStr] ?? availQty
                                        },
                                        set: { newVal in
                                            productManager.setStreamQuantity(newVal, forProductId: idStr, max: availQty)
                                        }
                                    )

                                    ProductItemCard(
                                        product: data,
                                        isSelected: isSelected,
                                        streamQuantity: streamQtyBinding,
                                        onTapCard: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                productManager.toggleSelection(for: idStr)
                                                request.product_ids = Array(productManager.selectedProductIDs)
                                            }
                                        },
                                        onTapEdit: {
                                            editingProduct = data
                                            navigateToEditListProduct = true
                                        },
                                        onTapDelete: {
                                            deletedIndex = index
                                            deletedProductId = idStr
                                            config = BottomSheetConfig(
                                                icon: "trash.circle.fill",
                                                title: "Delete Product?",
                                                message: "Are you sure you want to remove this product?",
                                                primaryButtonTitle: "Delete",
                                                secondaryButtonTitle: "Cancel"
                                            )
                                            showDeleteProduct = true
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Bottom spacing for button
                        Spacer()
                            .frame(height: 100)
                    }
                }
                
                // Fixed Bottom Button
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.gray.opacity(0.2))
                    
                    Button(action: handleFinishTapped) {
                        Text("Finish")
                            .font(.custom(poppinsSemiBold, size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.defaultTheme)
                            .cornerRadius(32)
                            .shadow(color: Color.defaultTheme.opacity(0.03), radius: 2, x: 0, y: 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
                .background(Color.backGround)
                .padding(.bottom, -56)
            }
            .zIndex(0)
        }
        .navigationBarHidden(true)
        .background(.backGround)
        .onAppear {
            // ⭐ REMOVED: API call on appear
//            if backToPrepare{
//                fromPrepare = true
//            }
            showError = false
            showDeleteProduct = false
            request.product_ids = Array(productManager.selectedProductIDs)
            
            print("📱 AddProductsScreen appeared")
            print("   Current products in list: \(productManager.products.count)")
            print("   Selected IDs: \(Array(productManager.selectedProductIDs).joined(separator: ", "))")
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .sheet(isPresented: $showRandomizerPicker) {
            RandomizerTemplatePickerSheet(
                selectedTemplateId: Binding(
                    get: { coordinator.randomizerTemplateId },
                    set: { newId in
                        coordinator.randomizerTemplateId = newId
                        request.randomizer_template_id = newId
                    }
                ),
                allowsProductMapping: false
            )
        }
        .sheet(isPresented: $showPostCreateRandomizerMapper, onDismiss: {
            postCreateRandomizerShowId = nil
            postCreateRandomizerTemplateId = nil
            navigateToTab = true
        }) {
            if let showId = postCreateRandomizerShowId {
                ShowRandomizersManagementSheet(showId: showId, autoOpenTemplateId: postCreateRandomizerTemplateId)
            }
        }
        .overlay(
            CustomBottomSheetView(
                isPresented: $showError,
                config: config,
                primaryAction: {
                    withAnimation {
                        showError = false
                        if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                // ⭐ CHANGED: Clear products after successful submit
                                productManager.clearAll()
                                if postCreateRandomizerShowId != nil && postCreateRandomizerTemplateId != nil {
                                    showPostCreateRandomizerMapper = true
                                } else {
                                    navigateToTab = true
                                }
                            }
                        }
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showError = false
                    }
                }
            )
        )
        .overlay(
            CustomBottomSheetView(
                isPresented: $showDeleteProduct,
                config: config,
                primaryAction: {
                    withAnimation {
                        showDeleteProduct = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        if let index = deletedIndex {
//                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                                // ⭐ CHANGED: Only remove from local list
//                                productData.remove(at: index)
//                                if let productId = deletedProductId {
//                                    selectedProductIDs.remove(productId)
//                                    request.product_ids = selectedProductIDs.joined(separator: ",")
//                                }
//                                deletedIndex = nil
//                                deletedProductId = nil
//                                
//                                print("🗑️ Removed product from list")
//                                print("   Remaining products: \(productData.count)")
//                            }
//                        }
                        // Basecamp #5: list may be filtered by show format, so the
                        // ForEach index no longer maps to productManager.products.
                        // Remove by product id instead to delete the right item.
                        if let pid = deletedProductId {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                productManager.removeProduct(withId: pid)
                                request.product_ids = Array(productManager.selectedProductIDs)

                                deletedIndex = nil
                                deletedProductId = nil
                            }
                        }
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showDeleteProduct = false
                    }
                }
            )
        )
        
        CusNavLink(doNavigate: $navigateToTab, destination:
            TabbarScreen()
                .environmentObject(TabBarRouter())
        )
//        CusNavLink(doNavigate: $navigateToAddProduct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail, backToPrepare: $backToPrepare, fromPrepare: .constant(false)))
//        CusNavLink(doNavigate: $navigateToEditProduct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail, backToPrepare: $backToPrepare, fromPrepare: .constant(false))
//            .environmentObject(productManager))
        
        // ⭐ CHANGED: Pass callback to receive products from inventory
        CusNavLink(doNavigate: $navigateToInventry,
                   destination: InventoryScreen(
                    preSelectedProducts:productManager.products,
                    selectedCategoryId: [Int(request.category_id) ?? 0],
                    // Basecamp #9959447268 (2026-06-03): pass the show's chosen
                    // format so the picker only offers products whose pricing
                    // format matches (Live Auction=8 -> auction products,
                    // Buy Now=5 -> buy-now products). Without this the picker
                    // listed the seller's whole inventory regardless of format.
                    showAuctionTypeId: request.auction_type_id,
                    navigatedFrom: .addProduct,
                    onProductsSelected: { products in
                        productManager.clearAll()
                        productManager.addProducts(products)
                        request.product_ids = Array(productManager.selectedProductIDs)
                    }
                   ).environmentObject(productManager))
        
        CusNavLink(
            doNavigate: $navigateToListProduct,
            destination: ListProductScreen(
                preSelectedCategoryId: request.category_id,
                preSelectedCategoryName: nil,
                isCategoryLocked: true,
                onProductCreated: { newProduct in
                    productManager.addProduct(newProduct)
                    request.product_ids = Array(productManager.selectedProductIDs)
                },
                hideDraftButton: true
            )
        )
        
        CusNavLink(
            doNavigate: $navigateToEditListProduct,
            destination: ListProductScreen(
                preSelectedCategoryId: request.category_id,
                preSelectedCategoryName: nil,
                isCategoryLocked: true,
                onProductCreated: nil,
                onProductUpdated: { updated in
                    productManager.updateProduct(updated)
                    request.product_ids = Array(productManager.selectedProductIDs)
                },
                editingProduct: editingProduct,
                hideDraftButton: true
            )
        )
    }
    
    // MARK: - Add Product Tile
    private func addProductOption(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.defaultTheme)
                
                Text(text)
                    .font(.custom(poppinsMedium, size: 13))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .foregroundColor(.defaultTheme.opacity(0.3))
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func randomizerProductOption(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: coordinator.randomizerTemplateId == nil ? "dice" : "dice.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.defaultTheme)
                    .frame(width: 54, height: 54)
                    .background(Color.defaultThemeLight)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(coordinator.randomizerTemplateId == nil ? "Add Randomizer Template" : "Randomizer Template #\(coordinator.randomizerTemplateId!)")
                        .font(.custom(poppinsSemiBold, size: 15))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    Text("Choose a saved template or create a new wheel")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.defaultTheme.opacity(0.25), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }
}

//MARK: API LOGIC
extension AddProductsScreen {
    
    // ⭐ REMOVED: All fetch functions since we're not calling API on load
    
    func handleFinishTapped() {
        print("🚀 Submitting with products: \(productManager.products.count)")
        print("   Selected IDs: \(Array(productManager.selectedProductIDs).joined(separator: ", "))")

        if let error = validateRequest() {
            hudMsg = error
            showhud = true
            return
        }
        
//        if fromPrepare {
//            backToPrepare = false
//            delegate?.didUpdateRequest(request, thumbNail: thumbNail)
//            return
//        }
        if fromPrepare {
            print("request: \(request)")

            Task { @MainActor in
                coordinator.request = request
                coordinator.thumbNAil = thumbNail

                // Basecamp #9991372302: persist stream quantities to coordinator so
                // LetsPrepare.storeScheduleSHow() can include them in the API call.
                let (orderedIds, orderedQtys) = productManager.orderedProductIdsAndQuantities()
                var qtysDict: [String: Int] = [:]
                for (id, qty) in zip(orderedIds, orderedQtys) {
                    qtysDict[id] = qty
                }
                coordinator.streamQuantities = qtysDict

                coordinator.markCurrentStepCompleted()
                coordinator.shouldNavigateBackToPrepare = true

                // Pop this screen (it was pushed via `CusNavLink`).
                backToCreateProduct = false
                productManager.clearAll()

                print("✅ Delegate call completed")
            }
               return
           }
        
        Task {
            if request.show_id != "" && request.show_id != nil {
                await performUpdateRequest()
            } else {
                await performSaveRequest()
            }
        }
    }

    func validateRequest() -> String? {
        if request.title.isEmpty { return "Please enter title" }
        if request.category_id.isEmpty { return "Please enter category type" }
        if request.auction_type_id.isEmpty { return "Please enter auction type" }
        if thumbNail.isEmpty { return "Please select thumbnail image" }
        if request.date.isEmpty { return "Please enter date" }
        if request.time.isEmpty { return "Please select time" }
        if productManager.selectedProductIDs.isEmpty { return "Please select product" }

        return nil
    }
    
    func performUpdateRequest() async {
        await performAPICalls(
            isConcurrent: false,
            showLoader: true,
            onError: { error in
                config = BottomSheetConfig(
                    icon: "exclamationmark.circle",
                    title: "Error",
                    message: errorDesc(error: error, message: viewModel.errorMessage),
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil
                )
                showError = true
            },
            onSuccess: {
                let response = viewModel.storeShowResponse
                if let templateId = request.randomizer_template_id,
                   let showId = response?.data.id {
                    postCreateRandomizerShowId = showId
                    postCreateRandomizerTemplateId = templateId
                } else {
                    postCreateRandomizerShowId = nil
                    postCreateRandomizerTemplateId = nil
                }
                productManager.clearAll()
                config = BottomSheetConfig(
                    icon: "checkmark.circle.fill",
                    title: "Success",
                    message: response?.message?.capitalized ?? "",
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil,
                    bottomPadding: -80,
                    backgroundDismissal: true
                )
                showError = true
            }
        ) {
            var params: [String: Any] = [
                "show_id": request.show_id ?? "",
                "title": request.title,
                "date": request.date,
                "time": request.time,
                "category_id": request.category_id,
                "auction_type_id": request.auction_type_id,
                "show_discoverability": request.show_discoverability,
                "repeat_value": request.repeat_value,
                "language": request.language,
                "sub_category_id":request.sub_category_id ?? ""
            ]
            if request.is_explicit {
                params["is_explicit"] = 1
            } else {
                params["is_explicit"] = 0
            }
            
            if request.is_repeat {
                params["is_repeat"] = 1
            } else {
                params["is_repeat"] = 0
            }

            // Browse-filter bundle (Basecamp #9928367737): attach tags as `tags[i]` keys
            // so the multipart body posts a real array to /api/v1/store-schedule-show.
            if let tags = request.tags, !tags.isEmpty {
                for (i, tag) in tags.enumerated() {
                    params["tags[\(i)]"] = tag
                }
            }

            // Basecamp #9991372302: send product_ids[] and product_stream_quantities[]
            // as positionally aligned indexed multipart fields (mirrors PWA wire format).
            let (orderedIds, orderedQtys) = productManager.orderedProductIdsAndQuantities()
            for (i, pid) in orderedIds.enumerated() {
                params["product_ids[\(i)]"] = pid
                params["product_stream_quantities[\(i)]"] = orderedQtys[i]
            }

            if let templateId = request.randomizer_template_id {
                params["randomizer_template_id"] = templateId
            }

            viewModel.errorMessage = ""

            try await viewModel.updateScheduleShow(
                param: params,
                images: [thumbNail],
                key: "thumbnail[]"
            )
        }
    }
    
    func performSaveRequest() async {
        await performAPICalls(
            isConcurrent: false,
            showLoader: true,
            onError: { error in
                config = BottomSheetConfig(
                    icon: "exclamationmark.circle",
                    title: "Error",
                    message: errorDesc(error: error, message: viewModel.errorMessage),
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil
                )
                showError = true
            },
            onSuccess: {
                let response = viewModel.storeShowResponse
                if let templateId = request.randomizer_template_id,
                   let showId = response?.data.id {
                    postCreateRandomizerShowId = showId
                    postCreateRandomizerTemplateId = templateId
                } else {
                    postCreateRandomizerShowId = nil
                    postCreateRandomizerTemplateId = nil
                }
                productManager.clearAll()
                config = BottomSheetConfig(
                    icon: "checkmark.circle.fill",
                    title: "Success",
                    message: response?.message?.capitalized ?? "",
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil,
                    bottomPadding: -80,
                    backgroundDismissal: true
                )
                showError = true
            }
        ) {
            var params: [String: Any] = [
                "title": request.title,
                "date": request.date,
                "time": request.time,
                "category_id": request.category_id,
                "auction_type_id": request.auction_type_id,
                "show_discoverability": request.show_discoverability,
                "repeat_value": request.repeat_value,
                "language": request.language,
                "sub_category_id":request.sub_category_id ?? ""
            ]
            if request.is_explicit {
                params["is_explicit"] = 1
            } else {
                params["is_explicit"] = 0
            }
            
            if request.is_repeat {
                params["is_repeat"] = 1
            } else {
                params["is_repeat"] = 0
            }
            // Browse-filter bundle (Basecamp #9928367737): attach tags as `tags[i]` keys
            // so the multipart body posts a real array to /api/v1/store-schedule-show.
            if let tags = request.tags, !tags.isEmpty {
                for (i, tag) in tags.enumerated() {
                    params["tags[\(i)]"] = tag
                }
            }
            // Basecamp #9991372302: send product_ids[] and product_stream_quantities[]
            // as positionally aligned indexed multipart fields (mirrors PWA wire format).
            let (orderedIds, orderedQtys) = productManager.orderedProductIdsAndQuantities()
            for (i, pid) in orderedIds.enumerated() {
                params["product_ids[\(i)]"] = pid
                params["product_stream_quantities[\(i)]"] = orderedQtys[i]
            }

            if let templateId = request.randomizer_template_id {
                params["randomizer_template_id"] = templateId
            }

            viewModel.errorMessage = ""

            try await viewModel.storeScheduleShow(
                param: params,
                images: [thumbNail],
                key: "thumbnail[]"
            )
        }
    }
    
    
    private func errorDesc(error: Error?, message: String?) -> String {
        guard let msg = message else {
            return error?.localizedDescription ?? "Something went wrong"
        }
        return msg
    }
}

import SwiftUI

struct CustomBottomSheetView: View {
    
    @Binding var isPresented: Bool
    var config: BottomSheetConfig
    
    /// Actions moved here (this is what you wanted)
    var primaryAction: (() -> Void)? = nil
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            
            // Dim background
            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isPresented = config.backgroundDismissal }
                    }
            }
            
            VStack {
                Spacer() // PUSH TO BOTTOM
                
                if isPresented {
                    VStack(spacing: 16) {
                        
                        if let icon = config.icon {
                            Image(systemName: icon)
                                .font(.system(size: 40))
                                .foregroundColor(.defaultTheme)
                                .padding(.top, 20)
                        }
                        
                        Text(config.title)
                            .font(.custom(poppinsBold, size: 20.0))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        
                        Text(config.message)
                            .font(.custom(poppinsRegular, size: 15.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        
                        if config.showButtons {
                            VStack(spacing: 8) {
                                
                                if let title = config.primaryButtonTitle {
                                    Button {
                                        primaryAction?()
                                        withAnimation { isPresented = false }
                                    } label: {
                                        Text(title)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.defaultTheme)
                                            .cornerRadius(32)
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: screenWidth - 80, height: 44)
                                    .padding(.bottom, 8)
                                    .padding(.top, 8)
                                }
                                
                                if let title = config.secondaryButtonTitle {
                                    Button {
                                        secondaryAction?()
                                        withAnimation { isPresented = false }
                                    } label: {
                                        Text(title)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(32)
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: screenWidth - 80, height: 44)
                                    .padding(.bottom, 20)
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer().frame(height: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(25, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.bottom, config.bottomPadding)
//                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.25), value: isPresented)

                }
            }
        }
    }
}



struct BottomSheetConfig {
    var icon: String? = nil
    var title: String
    var message: String

    var primaryButtonTitle: String? = nil
    var secondaryButtonTitle: String? = nil

    var showButtons: Bool = true
    var bottomPadding : CGFloat = -90
    var backgroundDismissal : Bool = false
}

// MARK: - Product Item Card
struct ProductItemCard: View {
    let product: ProductDataModel1
    let isSelected: Bool
    // Basecamp #9991372302: stream quantity stepper (how many units offered
    // during the show). Only shown when product is selected and availableQty > 1.
    @Binding var streamQuantity: Int
    let onTapCard: () -> Void
    let onTapEdit: () -> Void
    let onTapDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                // Product Image
                CustomProfileImage(
                    url: product.images?.first ?? "",
                    isCircular: false,
                    cornerRadius: 12,
                    size: 70,
                    height: 70,
                    defaultImage: "fashion"
                ) {}
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

                // Product Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.title ?? "Untitled")
                        .font(.custom(poppinsSemiBold, size: 15))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Text(product.category?.name ?? "Unknown Category")
                        .font(.custom(poppinsMedium, size: 13))
                        .foregroundColor(.secondary)

                    // Basecamp #9963271582 (2026-06-04): show AVAILABLE quantity
                    // (listed - purchased), not the raw listed quantity, so the card
                    // agrees with the server's sold-out rule at schedule time. When a
                    // product is sold out, surface a clear "Sold out" badge instead of a
                    // misleading positive number.
                    if product.isSoldOut {
                        HStack(spacing: 4) {
                            Text("Qty:")
                                .font(.custom(poppinsRegular, size: 12))
                                .foregroundColor(.secondary)

                            Text("Sold out")
                                .font(.custom(poppinsSemiBold, size: 12))
                                .foregroundColor(.red)
                        }
                    } else {
                        HStack(spacing: 4) {
                            Text("Qty:")
                                .font(.custom(poppinsRegular, size: 12))
                                .foregroundColor(.secondary)

                            Text("\(product.availableQuantity)")
                                .font(.custom(poppinsSemiBold, size: 12))
                                .foregroundColor(.primary)
                        }
                    }
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: onTapEdit) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.defaultTheme)
                            .frame(width: 36, height: 36)
                            .background(Color.defaultThemeLight)
                            .cornerRadius(10)
                    }

                    Button(action: onTapDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.red)
                            .frame(width: 36, height: 36)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }

            // Basecamp #9991372302: stream qty stepper — shown only when
            // product is selected and available qty > 1 (nothing to choose
            // when there is only one unit).
            if isSelected && product.availableQuantity > 1 {
                Divider()
                    .padding(.top, 10)

                HStack(spacing: 8) {
                    Text("Show qty:")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: {
                        if streamQuantity > 1 { streamQuantity -= 1 }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(streamQuantity > 1 ? .defaultTheme : .gray.opacity(0.4))
                    }
                    .buttonStyle(.plain)

                    Text("\(streamQuantity)")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.primary)
                        .frame(minWidth: 28)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        if streamQuantity < product.availableQuantity { streamQuantity += 1 }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(streamQuantity < product.availableQuantity ? .defaultTheme : .gray.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected ? Color.defaultTheme : Color.black.opacity(0.08),
                    lineWidth: isSelected ? 2.5 : 1
                )
        )
        .shadow(color: .black.opacity(isSelected ? 0.12 : 0.06), radius: isSelected ? 12 : 6, x: 0, y: isSelected ? 4 : 2)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .onTapGesture(perform: onTapCard)
    }
}
