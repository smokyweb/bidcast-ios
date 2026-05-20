//
//  InventoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

enum InventoryNavigation {
    case account
    case addProduct
    
    var btnTitle: String  {
        switch self {
        case .account:
            return AppString.newProduct.localized
        case .addProduct:
            return AppString.selectedProduct.localized
        }
    }
}

// MARK: - InventoryScreen
struct InventoryScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedTabIndex: Int = InventorySegment.active.index
    @State var segment: InventorySegment = .active
    
    @State var inventoryList: [ProductDataModel1] = []
    @State var request: ProductRequest = ProductRequest(status: "active", marketplace: "false", page: 1)
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var viewModel = InventoryViewModel()
    @StateObject private var productViewModel = ProductViewModel()
    
    @State private var showAuctionSheet = false
    
    @State var productId : Int = 0
    @State var showError: Bool = false
    @State var showDeleteProduct: Bool = false
    @State var showErrorPopup: Bool = false
    
    @State var isLoading: Bool = true
    
    @State private var isFetchingMore = false
    @State private var canLoadMore = true
    
    @State var showSuccesshud: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var status = "active"
    @State var currentPage = 1
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showSellSheet = false
    @State var navigateToCreateProduct = false
    @State var navigateToEditProduct = false
    @State var searchText: String = ""
    @EnvironmentObject var productManager: ProductManager
    @State var sellerInfo : SellerInfoResponse? = nil
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    var preSelectedProducts: [ProductDataModel1]?
    @State var productToEdit: ProductDataModel1 = ProductDataModel1()
    @StateObject var categoryViewModel = ListProductViewModel()
    @State var categoryList: [CategoryDataModel] = []
    @State var selectedCategoryId: [Int] = []
    @State var selectedCondition: [String] = []
    @State var minPrice: Double = 0.0
    @State var maxPrice: Double = 0.0
    @State var format: String = ""
    
    var navigatedFrom: InventoryNavigation = .account
    @State private var navigateToCreateNewProduct = false

    // Match Tabbar "create product" gating
    @State private var showSellerSheet = false
    @State private var navigateToSeller = false
    @State private var showPaymentShipping = false
    @State private var navigateToShipping = false
    @State private var titleText = ""
    
    @State private var selectedIndex: Int = -1
    @State private var showFilterSheet: Bool = false
    
    @State private var marketPlaceSelected: Bool = false
    @State var selectedProductIDs: Set<Int> = []
    @State var selectedProducts: [ProductDataModel1] = []
    var onProductsSelected: (([ProductDataModel1]) -> Void)?
    @State var navigateToDetail = false
    // QA #10 — Inventory Orders tab → push to MyOrdersScreen
    @State private var navigateToMyOrders = false
    
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack{
                InventoryTopHeaderView {
                    presentationMode.wrappedValue.dismiss()
                } manageBtnTapped: {
                    print("Manage Tapped")
                }
            }
            
            
            HStack{
                //            // MARK: - Search
                SearchBarView(placeholder: "What are you looking for?") { debouncedText in
                    print("User stopped typing. Search: \(debouncedText)")
                    searchText = debouncedText
                    currentPage = 1
                    self.inventoryList.removeAll()
                    Task {
                        await performAPICalls(
                            isConcurrent: true,
                            showLoader: false,
                            onError: { error in
                                alertType = .sheetType(
                                    icon: .alert,
                                    title: "Error",
                                    message: errorDesc(error: error, message: productViewModel.errorMessage),
                                    primaryBtnText: "",
                                    secondaryBtnText: AppString.ok.localized
                                )
                                showError = true
                                canLoadMore = false
                                isFetchingMore = false
                            }, onSuccess: {
                                // On success
                                handleDataLoad()
                            }
                            
                        ) {
                            try await fetchInventory(for: segment, page: 1)
                        }
                    }
                }
                //                .padding(.horizontal, 12)
                PillsSelectorView(
                    titles: [],
                    selectedIndex: $selectedIndex,
                    backgroundStyle: .roundedRect,
                    underlineEnabled: false,
                    showFilterButton: true,
                    showSortDropdown: false,
                    onSelectionChanged: { index, title in },
                    onFilterTapped: { showFilterSheet = true }
                )
                .fixedSize(horizontal: true, vertical: false)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 12)
            // MARK: - Segmented Control
            CustomSegmentedControl(preselectedIndex: $segment, options: InventorySegment.allCases)
                .onChange(of: segment) { newSegment in
                    // MC cmpdqpgof000nc9kp6f0xtti6 — Orders tab hidden per PM (2026-05-20).
                    // Original QA #10 navigation logic preserved below; restore by
                    // un-commenting the `case orders` line in InventorySegment.
//                    if newSegment == .orders {
//                        navigateToMyOrders = true
//                        DispatchQueue.main.async { segment = .active }
//                        return
//                    }
                    clearFilter()
                    Task {
                        await performAPICalls(
                            isConcurrent: true,
                            showLoader: false,
                            onError: { error in
                                alertType = .sheetType(
                                    icon: .alert,
                                    title: "Error",
                                    message: errorDesc(error: error, message: productViewModel.errorMessage),
                                    primaryBtnText: "",
                                    secondaryBtnText: AppString.ok.localized
                                )
                                showError = true
                                canLoadMore = false
                                isFetchingMore = false
                            }, onSuccess: {
                                // On success
                                handleDataLoad()
                            }
                            
                        ) {
                            try await fetchInventory(for: segment, page: 1)
                        }
                    }
                }
                .padding(.horizontal)
     
            // MARK: - Inventory List
            ScrollView {
                LazyVStack(spacing: 12) {
                    if isLoading {
                        // Show 5 skeleton items
                        ForEach(0..<5) { _ in
                            SkeletonProductCardView()
                                .padding(.horizontal, 12)
                        }
                    }
                    else if inventoryList.isEmpty {
                        NoDataView(message: AppString.NoInventoryFound.localized)
                    }
                    else {
                        ForEach(Array(inventoryList.enumerated()), id: \.element.id) { index, inventory in
                            let inventory = inventoryList[index]
                            
                            ProductCardView(product: inventory,
                                            segmant: $segment,
                                            isSelectionMode: navigatedFrom == .addProduct,
                                            isSelected: selectedProductIDs.contains(inventory.id ?? 0),
                                            onSelect: { product in
                                switch navigatedFrom {
                                case .account:
                                    productId = product.id ?? 0
                                    navigateToDetail = true
                                case .addProduct:
                                    toggleProductSelection(product)
                                }
                              
                            },
                                            onEdit: { product in
                                productToEdit = product
                                navigateToEditProduct = true
                                
                            },onDuplicate: {
                                
                            }, onToggleActivation: { id in
                                self.productId = id
                                let status = "active"
                                
                                changeProductStatus(status: status)
                            },
                                            onToggleDeActivation: { id in
                                self.productId = id
                                let status = "inactive"
                                
                                changeProductStatus(status: status)
                            },
                                            
                                            onDelete: { id in
                                self.productId = id
                                config = BottomSheetConfig(
                                    icon: "trash.circle.fill",
                                    title: "Delete Product?",
                                    message:  "Are you sure you want to remove this product?",
                                    primaryButtonTitle: "Delete",
                                    secondaryButtonTitle: "Cancel",
                                    bottomPadding: -80
                                )
                                showDeleteProduct = true
                            })
                            .onAppear {
                                checkAndLoadMore(currentIndex: index)
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 12)
            .background(.backGround)
            
            // Loader at bottom
            if isFetchingMore {
                ProgressView()
                    .padding(.vertical, 16)
            }
            
            // Bottom Button
            VStack(spacing: 0) {
                Divider()
                Button(action: {
                    switch navigatedFrom {
                    case .account:
                        print("create new Prooduct")
                        if UserDefaults.sellerVerafied == "verified" {
                            if UserDefaults.sellerAddress {
                                navigateToCreateProduct = true
                            } else {
                                titleText = "Add Address"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    showPaymentShipping = true
                                }
                            }
                        } else {
                            handleSellerVerification()
                        }
                    case .addProduct:
                        print("Select Existing Product")
                        onProductsSelected?(selectedProducts)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    HStack {
                        Text(navigatedFrom.btnTitle)
                            .font(.custom(poppinsSemiBold, size: 16))
                        
                        if navigatedFrom == .addProduct && !selectedProducts.isEmpty {
                            Text("(\(selectedProducts.count))")
                                .font(.custom(poppinsSemiBold, size: 16))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        navigatedFrom == .addProduct && selectedProducts.isEmpty
                        ? Color.gray.opacity(0.5)
                        : Color.defaultTheme
                    )
                    .cornerRadius(32)
                }
                .disabled(navigatedFrom == .addProduct && selectedProducts.isEmpty)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            CusNavLink(doNavigate: $navigateToDetail, destination: ProductDetailView(productID: $productId, sellerInfo: $sellerInfo))
            // QA #10 — Inventory Orders tab → MyOrdersScreen
            CusNavLink(doNavigate: $navigateToMyOrders, destination: MyOrdersScreen())
            CusNavLink(doNavigate: $navigateToEditProduct, destination: EditProductScreen(productData: $productToEdit)) // for edit
            CusNavLink(doNavigate: $navigateToCreateProduct, destination: ListProductScreen())
            CusNavLink(doNavigate: $navigateToSeller, destination: SellerVerificationScreen())
            CusNavLink(doNavigate: $navigateToShipping, destination: CreateAddress())
            CusNavLink(doNavigate: $navigateToCreateNewProduct,
                       destination: CreateProductScreen(requests: .constant(StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: [], is_explicit: false, show_discoverability: "", repeat_value: "", is_repeat: false, language: "english")),
                                                        thumbNail: .constant(""),
                                                        fromPrepare: .constant(false),
                                                         isComeFrom: .inventry))
            CusNavLink(doNavigate: $showFilterSheet,
                       destination: FilterPageView(selectedCategoryArr: $selectedCategoryId,
                                                   selectedConditionArr: $selectedCondition,
                                                   minPriceVal: $minPrice,
                                                   maxPriceVal: $maxPrice,
                                                   selectedFormat: $format,
                                                   apiCallClosure: {
                //api Call
                Task {
                    await performAPICalls(
                        isConcurrent: true,
                        showLoader: false,
                        onError: { error in
                            alertType = .sheetType(
                                icon: .alert,
                                title: "Error",
                                message: errorDesc(error: error, message: productViewModel.errorMessage),
                                primaryBtnText: "",
                                secondaryBtnText: AppString.ok.localized
                            )
                            showError = true
                            canLoadMore = false
                            isFetchingMore = false
                        }, onSuccess: {
                            // On success
                            handleDataLoad()
                        }
                    ) {
                        searchText = ""
                        currentPage = 1
                        
                        _ = try await fetchInventory(for: segment, page: currentPage)
                    }
                }
            }, categories: $categoryList) )
        }
        .background(.backGround)
        .padding(.bottom, -70)
        .toolbar(.hidden,for: .tabBar)
        .onFirstAppear {
            //            showAuctionSheet = false
            initializeSelectedProducts()
            Task {
                await performAPICalls(
                    isConcurrent: true,
                    showLoader: false,
                    onError: { error in
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: productViewModel.errorMessage ?? categoryViewModel.errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                        canLoadMore = false
                        isFetchingMore = false
                    }, onSuccess: {
                        // On success
                        handleDataLoad()
                        categorySuccess()
                    }
                    
                ) {
                    clearFilter()
                    request.search = searchText
                    selectedCategoryId = navigatedFrom == .account ? [] : []
                    async let inventoryTask: () = fetchInventory(for: segment, page: currentPage)
                    // 👇 These run in parallel
                    async let categoryTask: () = categoryViewModel.getSubCategoryList(param: CategoryRequest(category_id: ""))
                    
                    // Wait for all
                    _ = try await (categoryTask, inventoryTask)
                }
            }
            
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .toast(isPresenting: $showSuccesshud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlyeSuccess)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
        .bottomSheet(isPresented: $showPaymentShipping, height: screenHeight / 2.2) {
            PaymentAndShippingInfoSheet(
                isPresented: $showPaymentShipping,
                onAddInfo: {
                    if UserDefaults.sellerAddress != true {
                        showPaymentShipping = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToShipping = true
                        }
                    }
                },
                buttonText: $titleText
            )
        }
        .bottomSheet(isPresented: $showSellerSheet, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
            showSellerSheet = false
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation {
                        showSellerSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToSeller = true
                        }
                    }
                },
                onSecondaryClick: {
                    withAnimation {
                        showSellerSheet = false
                    }
                }
            )
        }
        
        
        .overlay(
            CustomBottomSheetView(
                isPresented: $showDeleteProduct,
                config: config,
                primaryAction: {
                    withAnimation {
                        showDeleteProduct = false
                        deleteProduct(with: productId)
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showDeleteProduct = false
                    }
                }
            )
        )
        
        .overlay(
            CustomBottomSheetView(
                isPresented: $showErrorPopup,
                config: config,
                primaryAction: {
                    withAnimation {
                        showErrorPopup = false
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showErrorPopup = false
                    }
                }
            )
        )
        
        
    }

    private func handleSellerVerification() {
        alertType = .sheetType(
            icon: .info,
            title: "Become a Verified Seller!",
            message: "Before you interact with live shows.you need to become a verified seller.",
            primaryBtnText: "OK",
            secondaryBtnText: "",
            buttonWidth: screenWidth - 60
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.snappy) {
                showSellerSheet = true
            }
        }
    }
    func toggleProductSelection(_ product: ProductDataModel1) {
        guard let productId = product.id else { return }
        
        if selectedProductIDs.contains(productId) {
            // Deselect
            selectedProductIDs.remove(productId)
            selectedProducts.removeAll { $0.id == productId }
        } else {
            // Select
            selectedProductIDs.insert(productId)
            selectedProducts.append(product)
        }
    }
    private func maintainSelections() {
            // Ensure selectedProducts contains the actual product objects from the loaded list
            var updatedSelectedProducts: [ProductDataModel1] = []
            
            for selectedId in selectedProductIDs {
                if let product = inventoryList.first(where: { $0.id == selectedId }) {
                    updatedSelectedProducts.append(product)
                }
            }
            
            selectedProducts = updatedSelectedProducts
            print("🟢 Maintained \(selectedProducts.count) selections after data load")
        }
    private func initializeSelectedProducts() {
            // Set selected product IDs from pre-selected products
        selectedProductIDs = Set(productManager.products.compactMap { $0.id })
        selectedProducts = productManager.products
            
            print("🔵 Initialized with \(selectedProducts.count) pre-selected products")
            print("🔵 Selected IDs: \(selectedProductIDs)")
        }
    
    private func deleteProduct(with productId: Int) {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
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
                    deleteProductSuccess()
                }
                
            ) {
                let param = DeleteProduct(product_id: productId)
                await viewModel.deleteProductRequest(parameters: param)
                
            }
        }
    }
    
    // MARK: - deleteProductSuccess
    func deleteProductSuccess() {
        //        SVProgressHUD.dismiss()
        let response = viewModel.deleteProductResponse
        if response.status == "success" {
            self.showSellSheet = false
            
            hudMsg = "Product deleted successfully"
            showSuccesshud = true
            
            currentPage = 1
            self.inventoryList.removeAll()
            
            Task {
                await performAPICalls(
                    isConcurrent: true,
                    showLoader: false,
                    onError: { error in
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: productViewModel.errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                        canLoadMore = false
                        isFetchingMore = false
                    }, onSuccess: {
                        // On success
                        handleDataLoad()
                    }
                    
                ) {
                    try await fetchInventory(for: segment, page: 1)
                }
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
    
    private func changeProductStatus(status: String) {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.circle",
                        title: "Error",
                        message: productViewModel.errorMessage ?? "",
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showErrorPopup = true
                }, onSuccess: {
                    // On success
                    hudMsg = "Product Status changed Successfully!"
                    showSuccesshud = true
                    Task {
                        await performAPICalls(
                            isConcurrent: true,
                            showLoader: false,
                            onError: { error in
                                alertType = .sheetType(
                                    icon: .alert,
                                    title: "Error",
                                    message: errorDesc(error: error, message: productViewModel.errorMessage),
                                    primaryBtnText: "",
                                    secondaryBtnText: AppString.ok.localized
                                )
                                showError = true
                            }, onSuccess: {
                                // On success
                                handleDataLoad()
                            }
                            
                        ) {
                            try await fetchInventory(for: segment, page: 1)
                        }
                    }
                }
            ) {
                let param = UpdateProductStatusRequest(status: status, product_id: "\(productId)")
                try await viewModel.updateProductStatus(param: param)
            }
        }
        
    }
    
    func categorySuccess() {
        let response = categoryViewModel.categoryResponse
        if response?.status == "success" {
            self.categoryList = response?.data ?? [CategoryDataModel]()
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: categoryViewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
    }
    
    //    // MARK: - Fetch Inventory List
    //    func fetchInventory(for segment: InventorySegment,page: Int) async throws{
    //        request.status = segment.rawValue.lowercased()
    //        request.page = page
    //        request.search = searchText
    //        if !selectedCategoryId.isEmpty {
    //            request.category_ids = selectedCategoryId.toCommaSeparatedString()
    //        }
    //
    //        request.marketplace = "\(marketPlaceSelected)"
    //        if format != "" {
    //            request.format = format
    //        }
    //        if minPrice != 0.0 {
    //            request.min_price = minPrice.toString()
    //        }
    //        if maxPrice != 0.0 {
    //            request.max_price = maxPrice.toString()
    //        }
    //        if !selectedCondition.isEmpty {
    //            request.conditions = selectedCondition.toCommaSeparatedString()
    //        }
    //        isLoading = true
    //        canLoadMore = false
    //        isFetchingMore = false
    //        try await productViewModel.getProductsData1(parameters: request)
    //    }
    //
    //    func handlePagination(index: Int) {
    //        let isLastItem = index == inventoryList.count - 1
    //        let canFetchMore = (productViewModel.productsResponse1?.total ?? 0) > inventoryList.count
    //        guard canLoadMore, !isFetchingMore else { return }
    //        if isLastItem && canFetchMore {
    //            isFetchingMore = true
    //            fetchMoreInventory()
    //        }
    //    }
    //
    //    private func clearFilter() {
    //        inventoryList = []
    //        currentPage = 1
    //        searchText = ""
    //        selectedCategoryId = []
    //        format = ""
    //        minPrice = 0.0
    //        maxPrice = 0.0
    //        selectedCondition = []
    //    }
    //
    //    // MARK: - Handle ViewModel Data
    //    func handleDataLoad() {
    //
    //        let response = productViewModel.productsResponse1
    //        isLoading = false
    //        if response?.status == "success" {
    //            // append new data
    //            if currentPage == 1  {
    //                self.inventoryList = response?.data ?? []
    //            }
    //            else  {
    //                self.inventoryList += response?.data ?? []
    //            }
    //        } else {
    //            alertType = .sheetType(
    //                icon: .alert,
    //                title: "Error",
    //                message: productViewModel.errorMessage ?? "",
    //                primaryBtnText: AppString.ok.localized,
    //                secondaryBtnText:""
    //            )
    //            showError = true
    //        }
    //        isFetchingMore = false
    //        canLoadMore = false
    //    }
    //
    //    func fetchMoreInventory() {
    //        Task {
    //            currentPage += 1
    ////            request.status = status
    ////            request.page = currentPage
    ////            if !selectedCategoryId.isEmpty {
    ////                request.categoryIds = selectedCategoryId.toCommaSeparatedString()
    ////            }
    //            request.status = segment.rawValue.lowercased()
    //            request.page = currentPage
    //            request.search = searchText
    //            if !selectedCategoryId.isEmpty {
    //                request.category_ids = selectedCategoryId.toCommaSeparatedString()
    //            }
    //
    //            request.marketplace = "\(marketPlaceSelected)"
    //            if format != "" {
    //                request.format = format
    //            }
    //            if minPrice != 0.0 {
    //                request.min_price = minPrice.toString()
    //            }
    //            if maxPrice != 0.0 {
    //                request.max_price = maxPrice.toString()
    //            }
    //            if !selectedCondition.isEmpty {
    //                request.conditions = selectedCondition.toCommaSeparatedString()
    //            }
    ////            isLoading = true
    //
    //            try await productViewModel.getProductsData1(parameters: request)
    //            handleDataLoad()
    //        }
    //    }
    
    
    /// Checks if we should load more data when a specific item appears
    private func checkAndLoadMore(currentIndex: Int) {
        // Don't load if:
        // 1. Already fetching
        // 2. Can't load more (reached end)
        // 3. Still loading initial data
        guard !isFetchingMore, canLoadMore, !isLoading else { return }
        
        // Calculate threshold (load more when user is 3 items from the end)
        let thresholdIndex = inventoryList.count - 3
        
        // Trigger load more when user scrolls near the end
        if currentIndex >= thresholdIndex {
            loadMoreData()
        }
    }
    
    /// Loads the next page of data
    private func loadMoreData() {
        // Prevent multiple simultaneous calls
        guard !isFetchingMore else { return }
        
        // Check if there's more data to load
        let totalItems = productViewModel.productsResponse1?.total ?? 0
        let currentItemCount = inventoryList.count
        
        guard currentItemCount < totalItems else {
            // We've loaded all items
            canLoadMore = false
            return
        }
        
        // Set fetching flag
        isFetchingMore = true
        
        // Increment page and fetch
        currentPage += 1
        
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: false,
                onError: { error in
                    // ✅ Reset pagination state on error
                    isFetchingMore = false
                    currentPage -= 1 // Rollback page increment
                    
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: productViewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                },
                onSuccess: {
                    // ✅ Handle successful data load
                    
                    handlePaginationSuccess()
                    
                }
            ) {
                try await fetchInventory(for: segment, page: currentPage)
            }
        }
    }
    
    /// Handles successful pagination response
    private func handlePaginationSuccess() {
        let response = productViewModel.productsResponse1
        
        guard response?.status == "success" else {
            // Handle error case
            isFetchingMore = false
            currentPage -= 1 // Rollback
            return
        }
        
        // Append new data
        let newData = response?.data ?? []
        inventoryList.append(contentsOf: newData)
        
        // Update pagination state
        let totalItems = response?.total ?? 0
        let currentItemCount = inventoryList.count
        
        // Check if we can load more
        canLoadMore = currentItemCount < totalItems
        isFetchingMore = false
        
        print("📄 Loaded page \(currentPage): \(newData.count) items | Total: \(currentItemCount)/\(totalItems)")
    }
    
    // MARK: - ✅ CORRECTED Fetch Inventory
    func fetchInventory(for segment: InventorySegment, page: Int) async throws {
        // MC cmpdqpgof000nc9kp6f0xtti6 — Orders tab hidden per PM (2026-05-20).
        // Original QA #10 short-circuit preserved below; restore alongside the
        // `case orders` line in InventorySegment.
//        if segment == .orders { return }
        // Build request
        request.status = segment.rawValue.lowercased()
        request.page = page
        request.search = searchText
        request.marketplace = "\(marketPlaceSelected)"
        
        // Apply filters
        if !selectedCategoryId.isEmpty {
            request.category_ids = selectedCategoryId.toCommaSeparatedString()
        }
        else {
            request.category_ids?.removeAll()
        }
        //           if format != "" {
        request.format = format
        //           }
        if minPrice != 0.0 {
            request.min_price = minPrice.toString()
        }
        if maxPrice != 0.0 {
            request.max_price = maxPrice.toString()
        }
        //           if !selectedCondition.isEmpty {
        request.conditions = selectedCondition.toCommaSeparatedString()
        //           }
        
        // ✅ Only show loading for first page
        if page == 1 {
            isLoading = true
        }
        
        // Make API call
        try await productViewModel.getProductsData1(parameters: request)
    }
    
    // MARK: - ✅ CORRECTED Handle Data Load
    func handleDataLoad() {
        let response = productViewModel.productsResponse1
        isLoading = false
        
        if response?.status == "success" {
            // ✅ For page 1, replace data. For other pages, append (handled in handlePaginationSuccess)
            if currentPage == 1 {
                self.inventoryList = response?.data ?? []
                maintainSelections()
                // ✅ Reset pagination state for fresh data
                let totalItems = response?.total ?? 0
                canLoadMore = inventoryList.count < totalItems
                isFetchingMore = false
                
                print("📄 Initial load: \(inventoryList.count) items | Total: \(totalItems)")
            }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: productViewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
            showError = true
            
            // ✅ Reset pagination state
            canLoadMore = false
            isFetchingMore = false
        }
    }
    
    // MARK: - ✅ UPDATED Clear Filter
    private func clearFilter() {
        inventoryList = []
        currentPage = 1
        searchText = ""
        if navigatedFrom != .addProduct{
            selectedCategoryId = []
        }
        format = ""
        minPrice = 0.0
        maxPrice = 0.0
        selectedCondition = []
        
        // ✅ Reset pagination state
        canLoadMore = true
        isFetchingMore = false
    }
}

// MARK: - Inventory Segment Enum
// MC cmpdqpgof000nc9kp6f0xtti6 (PM Pritika Gupta, 2026-05-20):
//   Per PM request, BOTH the Sold and Orders tabs are commented out
//   on iOS for now. Sold was redundant (per-product sold state is
//   already visible via quantity badges). Orders is hidden until the
//   PM decides the final placement for the orders entry point.
//   Restore by un-commenting the two `case` lines below and the two
//   `.orders` references in this file (search for "MC cmpdqpgof").
enum InventorySegment: String, CaseIterable, CustomStringConvertible {
    case active = "Active"
    case draft = "Draft"
    case inactive = "Inactive"
//    case sold = "Sold"      // MC cmpdqpgof000nc9kp6f0xtti6 — hidden per PM (2026-05-20)
//    case orders = "Orders"  // MC cmpdqpgof000nc9kp6f0xtti6 — hidden per PM (2026-05-20)
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    static var inventorytArray: [String] {
        return InventorySegment.allCases.map { $0.rawValue }
    }
    
    // Get segment by index
    static func segment(at index: Int) -> InventorySegment? {
        let allSegments = InventorySegment.allCases
        guard allSegments.indices.contains(index) else {
            return nil
        }
        return Array(allSegments)[index]
    }
    
    // Get index of current segment
    var index: Int {
        return Array(InventorySegment.allCases).firstIndex(of: self) ?? 0
    }
}

struct InventoryTopHeaderView: View {
    var backBtnTapped: (() -> Void) = {}
    var manageBtnTapped: (() -> Void) = {}
    
    var body: some View {
        // MARK: - Navigation Header
        HStack {
            Button(action: {
                backBtnTapped()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.custom(poppinsBold, size: 16))
                    
                    //                    Text("Back")
                    //                        .font(.custom(poppinsSemiBold, size: 16))
                }
                .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Inventory")
                .font(.custom(poppinsBold, size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            //            Button(action: {
            //                // Manage action
            //                manageBtnTapped()
            //            }) {
            //                Text("Manage")
            //                    .font(.custom(poppinsSemiBold, size: 16))
            //                    .foregroundColor(.defaultTheme)
            //            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}


import SwiftUI

struct InventoryTabView: View {
    
    @Binding var selectedTab: InventorySegment
    
    var tabChangeClosure: (() -> Void)? = nil
    var body: some View {
        
        VStack(spacing: 0) {
            
            // MARK: - Tab Selector
            HStack(spacing: 0) {
                ForEach(InventorySegment.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                            tabChangeClosure?()
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text(tab.rawValue)
                                .font(.custom(selectedTab == tab ? poppinsBold : poppinsSemiBold, size: 14))
                                .foregroundColor(selectedTab == tab ? .black : .gray)
                            
                            // Selection Indicator
                            Rectangle()
                                .fill(selectedTab == tab ? Color.primary : Color.clear)
                                .frame(height: 3)
                                .cornerRadius(1.5)
                        }
                        .frame(width: 80)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .background(Color(.systemBackground))
            
            Divider()
                .padding(.top, 0)
        }
        .background(Color(.systemBackground))
    }
}

struct ProductCardView: View {
    let product: ProductDataModel1
    @State private var isPressed: Bool = false
    @State private var showActions: Bool = false
    @State private var isLongPressing: Bool = false
    @Binding var segmant: InventorySegment
    
    var isSelectionMode: Bool = false
    var isSelected: Bool = false
    var onSelect: ((ProductDataModel1) -> Void)?
    
    var onEdit: ((ProductDataModel1) -> Void)?
    var onDuplicate: (() -> Void)?
    var onToggleActivation: ((Int) -> Void)?
    var onToggleDeActivation: ((Int) -> Void)?
    var onDelete: ((Int) -> Void)?
    
    var body: some View {
        mainContent
            .background(backgroundDimmer)
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ZStack(alignment: .topTrailing) {
            cardContainer
        }
    }
    
    // MARK: - Card Container
    private var cardContainer: some View {
        HStack {
            cardContent
            Spacer()
            if !isSelectionMode {
                menuButton
            }
        }
        .background(cardBackground)
        .overlay(cardBorder)
        .onTapGesture {
//            if isSelectionMode {
                onSelect?(product)
//            }
        }
    }
    
    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemBackground))
            .shadow(
                color: Color.black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 4
            )
    }
    
    // MARK: - Card Border
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(
                borderColor,
                lineWidth: borderWidth
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var borderColor: Color {
        isSelectionMode && isSelected ? Color.defaultTheme : Color.gray.opacity(0.1)
    }
    
    private var borderWidth: CGFloat {
        isSelectionMode && isSelected ? 3 : 1
    }
    
    // MARK: - Menu Button
    private var menuButton: some View {
        Menu {
            menuContent
        } label: {
            menuButtonLabel
        }
    }
    
    // MARK: - Menu Content
    @ViewBuilder
    private var menuContent: some View {
        Group {
            editOption
            activationOption
            deleteOption
        }
    }
    
    private var menuBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(
                color: Color.black.opacity(0.15),
                radius: 20,
                x: 0,
                y: 8
            )
    }
    
    private var menuBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
    }
    
    // MARK: - Menu Options
    private var editOption: some View {
        MenuOptionButton(
            icon: "pencil",
            title: "Edit",
            iconColor: .blue
        ) {
            handleEdit()
        }
    }
    
    @ViewBuilder
    private var activationOption: some View {
        if segmant == .active {
            MenuOptionButton(
                icon: product.status == "active" ? "eye.slash" : "eye",
                title: product.status == "active" ? "Deactivate" : "Activate",
                iconColor: product.status == "active" ? .orange : .green
            ) {
                if product.status == "active" {
                    handleToggleDeActivation()
                } else {
                    handleToggleActivation()
                }
            }
        } else {
            MenuOptionButton(
                icon: "eye",
                title: "Activate",
                iconColor: .green
            ) {
                handleToggleActivation()
            }
        }
    }
    
    private var deleteOption: some View {
        MenuOptionButton(
            icon: "trash",
            title: "Delete",
            iconColor: .red
        ) {
            handleDelete()
        }
    }
    
    // MARK: - Menu Button Label
    private var menuButtonLabel: some View {
        Image(systemName: "ellipsis")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.gray)
            .padding(.top, 12)
            .frame(width: 32, height: 32)
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .rotationEffect(.degrees(90))
    }
    
    // MARK: - Background Dimmer
    private var backgroundDimmer: some View {
        Color.black.opacity(0.001)
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showActions = false
                }
            }
            .allowsHitTesting(showActions)
    }
    
    // MARK: - Action Handlers
    private func handleEdit() {
        closeActionsMenu {
            onEdit?(product)
        }
    }
    
    private func handleDuplicate() {
        closeActionsMenu {
            onDuplicate?()
        }
    }
    
    private func handleToggleActivation() {
        closeActionsMenu {
            onToggleActivation?(product.id ?? 0)
        }
    }
    
    private func handleToggleDeActivation() {
        closeActionsMenu {
            onToggleDeActivation?(product.id ?? 0)
        }
    }
    
    private func handleDelete() {
        closeActionsMenu {
            onDelete?(product.id ?? 0)
        }
    }
    
    private func closeActionsMenu(completion: @escaping () -> Void) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showActions = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
}

// MARK: - Card Content Extension
extension ProductCardView {
    var cardContent: some View {
        HStack(spacing: 8) {
            productImageView
            productDetailsView
        }
        .padding(.leading,12)
        .padding(.trailing, 6)
        .padding(.vertical, 16)
        .scaleEffect(scaleAmount)
        .opacity(opacityAmount)
    }
    
    private var scaleAmount: CGFloat {
        isPressed ? 0.98 : (isLongPressing ? 1.02 : 1.0)
    }
    
    private var opacityAmount: Double {
        product.status == "inactive" ? 0.7 : 1.0
    }
}

// MARK: - Product Image Extension
extension ProductCardView {
    var productImageView: some View {
          let imageURL =
              product.thumbnail?.first ??
              product.images?.first

          return CustomProfileImage(
              url: imageURL,
              isCircular: false,
              size: 120
          )
          .frame(width: 120, height: 120)
      }
}

// MARK: - Product Details Extension
extension ProductCardView {
    var productDetailsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            productTitle
            productMetadata
            productQuantity
            priceSectionView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var productTitle: some View {
        Text(product.title?.capitalizingFirstLetter() ?? "")
            .font(.custom(poppinsSemiBold, size: 16))
            .foregroundColor(.black)
            .lineLimit(2)
    }
    
    private var productMetadata: some View {
        HStack(spacing: 6) {
            Text(product.productCondition ?? "New")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.darkGray)
                .lineLimit(1)
            
            Circle()
                .fill(Color.secondary)
                .frame(width: 3, height: 3)
            
            Text(product.category?.name ?? "Category")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.darkGray)
        }
    }
    
    private var productQuantity: some View {
        // QA #11 — show remaining stock (quantity - purchased_quantity) so the badge updates after a sale.
        // Falls back to quantity when purchased_quantity is missing; clamps at 0 so we never show negatives.
        Text("Quantity: \(availableStockString)")
            .font(.custom(poppinsRegular, size: 13))
            .foregroundColor(.darkGray)
    }

    private var availableStockString: String {
        let totalString = product.quantity ?? "0"
        let purchasedString = product.purchasedQuantity ?? "0"
        guard let total = Int(totalString) else { return totalString }
        let purchased = Int(purchasedString) ?? 0
        return "\(max(total - purchased, 0))"
    }
}

// MARK: - Badge View Extension
extension ProductCardView {
    func badgeView(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(color.opacity(0.1)))
        .overlay(
            Capsule()
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Price Section Extension
extension ProductCardView {
    var priceSectionView: some View {
        VStack(spacing: 8) {
            Text("\(formatCurrencyCompact(Double(product.pricing ?? "0.0") ?? 0.0))")
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.primary)
            
            Text("\(product.bidCount ?? 0) Bids")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
        }
    }
    private func formatCurrencyCompact(_ value: Double) -> String {
            let absValue = abs(value)
            let sign = value < 0 ? "-" : ""
            
            switch absValue {
            case 1_000_000_000...:
                // Billions
                return String(format: "%@$%.2fB", sign, absValue / 1_000_000_000)
            case 1_000_000...:
                // Millions
                return String(format: "%@$%.2fM", sign, absValue / 1_000_000)
            case 1_000...:
                // Thousands
                return String(format: "%@$%.1fK", sign, absValue / 1_000)
            default:
                // Less than 1000 - show full amount
                return String(format: "%@$%.2f", sign, absValue)
            }
        }
}

// MARK: - Animation Extension
extension ProductCardView {
    func animatePress() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isPressed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Menu Option Button (Keep as is)
struct MenuOptionButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            menuContent
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(pressGesture)
    }
    
    private var menuContent: some View {
        HStack(spacing: 12) {
            iconView
            titleView
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(isPressed ? Color.gray.opacity(0.1) : Color.clear)
    }
    
    private var iconView: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(iconColor)
            .frame(width: 24, height: 24)
    }
    
    private var titleView: some View {
        Text(title)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.primary)
    }
    
    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                isPressed = true
            }
            .onEnded { _ in
                isPressed = false
            }
    }
}

// MARK: - Menu Option Button
//struct MenuOptionButton: View {
//    let icon: String
//    let title: String
//    let iconColor: Color
//    let action: () -> Void
//    
//    @State private var isPressed = false
//    
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 12) {
//                Image(systemName: icon)
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(iconColor)
//                    .frame(width: 24, height: 24)
//                
//                Text(title)
//                    .font(.system(size: 15, weight: .medium))
//                    .foregroundColor(.primary)
//                
//                Spacer()
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 14)
//            .background(isPressed ? Color.gray.opacity(0.1) : Color.clear)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .simultaneousGesture(
//            DragGesture(minimumDistance: 0)
//                .onChanged { _ in
//                    isPressed = true
//                }
//                .onEnded { _ in
//                    isPressed = false
//                }
//        )
//    }
//}

//extension ProductCardView {
//    var cardContent: some View {
//        HStack(spacing: 16) {
//            productImageView
//            productDetailsView
//        }
//        .padding(.horizontal,8)
//        .padding(.vertical,16)
//        //        .background(
//        //            RoundedRectangle(cornerRadius: 20)
//        //                .fill(Color(.systemBackground))
//        //                .shadow(
//        //                    color: isLongPressing ? Color.defaultTheme.opacity(0.2) : Color.black.opacity(0.08),
//        //                    radius: isLongPressing ? 16 : 12,
//        //                    x: 0,
//        //                    y: isLongPressing ? 6 : 4
//        //                )
//        //        )
//        //        .overlay(
//        //            RoundedRectangle(cornerRadius: 20)
//        //                .stroke(
//        //                    isLongPressing ? Color.defaultTheme.opacity(0.3) : Color.gray.opacity(0.1),
//        //                    lineWidth: isLongPressing ? 2 : 1
//        //                )
//        //        )
//        .scaleEffect(isPressed ? 0.98 : (isLongPressing ? 1.02 : 1.0))
//        .opacity(product.status == "inactive" ? 0.7 : 1.0)
//    }
//}
//extension ProductCardView {
//    var productImageView: some View {
//        VStack {
//            CustomProfileImage(url: product.images?.first ?? "", isCircular: false, size: 120)
//        }
//        .frame(width: 120, height: 120)
//    }
//}
//extension ProductCardView {
//    var productDetailsView: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            //            if product.status == "inactive" {
//            //                badgeView(title: "Inactive", color: .orange)
//            //            } else if (product.quantity ?? 0) == 0 {
//            //                badgeView(title: "Out of Stock", color: .red)
//            //            }
//            
//            Text(product.title?.capitalizingFirstLetter() ?? "")
//                .font(.custom(poppinsSemiBold, size: 16))
//                .foregroundColor(.primary)
//                .lineLimit(2)
//            
//            HStack(spacing: 8) {
//                //                Text(product.condition ?? "New")
//                Text(product.productCondition ?? "New")
//                    .font(.custom(poppinsRegular, size: 13))
//                    .foregroundColor(.secondary)
//                
//                Circle()
//                    .fill(Color.secondary)
//                    .frame(width: 3, height: 3)
//                
//                Text(product.category?.name ?? "Category")
//                    .font(.custom(poppinsRegular, size: 13))
//                    .foregroundColor(.secondary)
//            }
//            
//            Text("Quantity: \(product.quantity ?? "0")")
//                .font(.custom(poppinsRegular, size: 13))
//                .foregroundColor(.secondary)
//            
//            priceSectionView
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//extension ProductCardView {
//    func badgeView(title: String, color: Color) -> some View {
//        HStack(spacing: 6) {
//            Circle()
//                .fill(color)
//                .frame(width: 6, height: 6)
//            
//            Text(title)
//                .font(.system(size: 12, weight: .semibold))
//                .foregroundColor(color)
//        }
//        .padding(.horizontal, 10)
//        .padding(.vertical, 6)
//        .background(Capsule().fill(color.opacity(0.1)))
//        .overlay(
//            Capsule()
//                .stroke(color.opacity(0.2), lineWidth: 1)
//        )
//    }
//}
//extension ProductCardView {
//    var priceSectionView: some View {
//        VStack(spacing: 8) {
//            Text("$\(product.pricing ?? "$0.00")")
//                .font(.custom(poppinsSemiBold, size: 16))
//                .foregroundColor(.primary)
//            
//            Text("\(product.bidCount ?? 0) Bids")
//                .font(.custom(poppinsRegular, size: 13))
//                .foregroundColor(.secondary)
//        }
//    }
//}
//extension ProductCardView {
//    func animatePress() {
//        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//            isPressed = true
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                isPressed = false
//            }
//        }
//    }
//}

// MARK: - Product Actions Bottom Sheet
struct ProductActionsSheet: View {
    @Binding var isPresented: Bool
    let isActive: Bool
    var onEdit: () -> Void
    var onDuplicate: () -> Void
    var onToggleActivation: () -> Void
    var onToggleDeActivation: () -> Void
    var segmant: InventorySegment
    var onDelete: () -> Void
    
    @State private var selectedAction: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                // MARK: - Header
                HStack {
                    Text("Actions")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // MARK: - Action Options
                VStack(spacing: 12) {
                    ProductActionButton(
                        icon: "square.and.pencil",
                        title: "Edit",
                        subtitle: "Modify product details",
                        color: .blue,
                        isSelected: selectedAction == "Edit"
                    ) {
                        selectedAction = "Edit"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onEdit()
                            isPresented = false
                        }
                    }
                    
                    //                    ProductActionButton(
                    //                        icon: "doc.on.doc",
                    //                        title: "Duplicate",
                    //                        subtitle: "Create a copy of this product",
                    //                        color: .purple,
                    //                        isSelected: selectedAction == "Duplicate"
                    //                    ) {
                    //                        selectedAction = "Duplicate"
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    //                            onDuplicate()
                    //                            isPresented = false
                    //                        }
                    //                    }
                    if segmant == .active || segmant == .draft {
                        ProductActionButton(
                            icon: "pause.circle",
                            title: "Deactivate" ,
                            subtitle:"Hide from active listings",
                            color: .orange,
                            isSelected: selectedAction == "Deactivate"
                        ) {
                            selectedAction = "Deactivate"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onToggleDeActivation()
                                isPresented = false
                            }
                        }
                    }
                    if segmant == .inactive || segmant == .draft {
                        ProductActionButton(
                            icon: "play.circle",
                            title: "Activate",
                            subtitle: "Show in active listings",
                            color: .green,
                            isSelected: selectedAction == "Activate"
                        ) {
                            selectedAction = "Activate"
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onToggleActivation()
                                isPresented = false
                            }
                        }
                    }
                    
                    ProductActionButton(
                        icon: "trash.fill",
                        title: "Delete",
                        subtitle: "Remove product permanently",
                        color: .red,
                        isSelected: selectedAction == "Delete"
                    ) {
                        selectedAction = "Delete"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onDelete()
                            isPresented = false
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGroupedBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
        )
    }
}

// MARK: - Action Button Component
struct ProductActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 16) {
                // Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
                
                // Text Container
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Arrow Indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .opacity(0.5)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? color.opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Skeleton Loading View
struct SkeletonProductCardView: View {
    var body: some View {
        HStack(spacing: 16) {
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)
                .shimmer()
            
            VStack(alignment: .leading, spacing: 8) {
                
                // Title
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 16)
                    .shimmer()
                
                // Condition + Category
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 14)
                    .shimmer()
                
                // Quantity
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 14)
                    .shimmer()
                
                // Price Row
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 16)
                    .shimmer()
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}


extension Array where Element == Int {
    func toCommaSeparatedString() -> String {
        self.map { String($0) }.joined(separator: ",")
    }
}

extension Array where Element == String {
    func toCommaSeparatedString() -> String {
        self
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: ",")
    }
}

extension Double {
    func toString(_ decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f", self)
    }
}
