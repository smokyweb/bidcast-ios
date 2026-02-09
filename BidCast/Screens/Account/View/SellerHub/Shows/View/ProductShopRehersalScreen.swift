//
//  ProductShopRehersalScreen.swift
//  BidCast
//
//  Created by JamTech on 16/12/25.
//

import SwiftUI

// MARK: - Inventory Segment Enum
enum RehearsalProductSegment: String, CaseIterable, CustomStringConvertible {
    case buynow = "Buy Now"
    case auction = "Auction"
    case offers = "Offers"
    case sold = "Sold"
    case Surprise = "Surprise Sets"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    static var RehearsalProductArray: [String] {
        return RehearsalProductSegment.allCases.map { $0.rawValue }
    }
    
    static func segment(at index: Int) -> RehearsalProductSegment? {
        let allSegments = RehearsalProductSegment.allCases
        guard allSegments.indices.contains(index) else {
            return nil
        }
        return Array(allSegments)[index]
    }
    
    var index: Int {
        return Array(RehearsalProductSegment.allCases).firstIndex(of: self) ?? 0
    }
}

enum RehearsalSelectionMode {
    case auction
    case freebie

    var buttonTitle: String {
        switch self {
        case .auction: return "Start Auction"
        case .freebie: return "Select Freebie"
        }
    }
}

// MARK: - Main Screen
struct ProductShopRehersalScreen: View {
    var mode: RehearsalSelectionMode = .auction
    @State var searchText: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedIndex: Int = 0
    @State private var isLoading: Bool = false
    var roomId: String
    @State private var isFetchingMore = false
    @State private var canLoadMore = true
    @State private var saleType = "auction"
    @State private var type = ""
    @State private var status = ""
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @StateObject var socketManager = SocketManagerService.shared
    
    @State private var showSortSheet = false
    @State private var selectedSort: String = "newest"
    @State private var selectedOptions: String = ""
    
    @State private var viewModel = ScheduleViewModel()
    @State var productViewModel = ProductViewModel()
    
    @State private var totalCount = 0
    @Binding var auctionTypeId : Int
    @Binding var productDataFromEvent: [ProductDataModel1]
    @State private var productDataFromAPI: [ProductDataModel1] = []
    @State private var sortedProductData: [ProductDataModel1] = []
    @State private var pinnedProductIds: Set<Int> = []
    
    @State private var apiProducts: [ProductDataModel1] = []
    @State private var displayedProducts: [ProductDataModel1] = []
    @State private var surpriseSetData: [ProductSurpriseData] = []
    
    var categoryId: String = "-1"
    @State var currentPage: Int = 1
    @State var segment: RehearsalProductSegment = .buynow
    
    var onTapCancel: (() -> Void)?
    var onProductSelected: ((ProductDataModel1) -> Void)?
    var onSurpriseSetSelected: ((ProductSurpriseData) -> Void)?
    var onSurpriseSetUnitSelected: ((ProductSurpriseData, String, Int, Int, Bool) -> Void)?
    @State private var socketListenersConfigured = false
    
    // NEW: State for Create Product Sheet
    @State private var showCreateProductSheet = false
    var onProductCreated: (() -> Void)?
    
    // State for Manage Product Sheet
    @State private var showManageProductSheet = false
    @State private var selectedSurpriseSet: ProductSurpriseData?
    
    // State for Add Action Sheet
    @State private var showAddActionSheet = false
    @State private var showCreateSurpriseSheet = false
    
    private var eventProductIds: Set<Int> {
        Set(productDataFromEvent.compactMap { $0.id })
    }
    
    init(
        mode: RehearsalSelectionMode = .auction,
        roomId: String,
        auctionTypeId: Binding<Int>,
        productDataFromEvent: Binding<[ProductDataModel1]>,
        categoryId: String = "-1",
        onTapCancel: (() -> Void)? = nil,
        onProductSelected: ((ProductDataModel1) -> Void)? = nil,
        onSurpriseSetSelected: ((ProductSurpriseData) -> Void)? = nil,
        onSurpriseSetUnitSelected: ((ProductSurpriseData, String, Int, Int, Bool) -> Void)?,
        onProductCreated: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.roomId = roomId
        self._auctionTypeId = auctionTypeId
        self._productDataFromEvent = productDataFromEvent
        self.categoryId = categoryId
        self.onTapCancel = onTapCancel
        self.onProductSelected = onProductSelected
        self.onSurpriseSetSelected = onSurpriseSetSelected
        self.onSurpriseSetUnitSelected = onSurpriseSetUnitSelected
        self.onProductCreated = onProductCreated
        
        // Set initial segment based on auctionTypeId
        self._segment = State(initialValue: auctionTypeId.wrappedValue == 9 ? .Surprise : .buynow)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Header with Search & Close
            HStack(spacing: 12) {
                SearchBarView(placeholder: "Search shop...") { text in
                    resetData()
                    self.searchText = text
                    fetchProduct()
                }
                
                Button(action: {
                    onTapCancel?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.custom(poppinsSemiBold, size: 20.0))
                        .foregroundColor(.black)
                }
            }
           
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.backGround)
           
            
            // MARK: - Tab View
            GenericTabView(selectedTab: $segment) {
                if segment == .auction {
                    resetData()
                    guard auctionTypeId != 9 else { return }
                    self.saleType = "auction"
                    self.type = ""
                    self.status = ""
                    fetchProduct()
                } else if segment == .offers {
                    resetData()
                    guard auctionTypeId != 9 else { return }
                    self.saleType = "accept_offers"
                    self.type = ""
                    self.status = ""
                    fetchProduct()
                } else if segment == .buynow {
                    resetData()
                    guard auctionTypeId != 9 else { return }
                    self.saleType = ""
                    self.status = ""
                    self.type = "buy_now"
                    fetchProduct()
                } else if segment == .sold {
                    resetData()
                    guard auctionTypeId != 9 else { return }
                    self.saleType = ""
                    self.status = "inactive"
                    self.type = "buy_now"
                    fetchProduct()
                    
                } else if segment == .Surprise {
                    resetData()
                    guard auctionTypeId == 9 else { return }
                    fetchSurpriseSet()
                }
            }
            
            // MARK: - Heading
            ProductHeading(count: segment == .Surprise ? surpriseSetData.count : displayedProducts.count)
                .padding(.vertical,6)
                .padding(.horizontal, 16)
            
            if segment == .Surprise {
                // MARK: - Surprise Sets Content
                if surpriseSetData.isEmpty && !isLoading {
                    GeometryReader { geo in
                        VStack {
                            NoDataView(message: "No Surprise Sets found")
                                .padding(.top, -100)
                            Spacer()
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            if isLoading {
                                ForEach(0..<4, id: \.self) { _ in
                                    PurchasesViewShimmerView()
                                        .padding(.horizontal, 16)
                                }
                            } else {
                            ForEach(surpriseSetData, id: \.id) { surpriseSet in
                                    ProductSurpriseCard(
                                        data: surpriseSet,
                                        onManageProducts: {
                                            selectedSurpriseSet = surpriseSet
                                            showManageProductSheet = true
                                        },
                                        onPin: {
                                            // Handle pin action
                                        },
                                        onTap: {
                                            // Check if type is buy_now or auction
                                            if surpriseSet.type == "auction" {
                                                // For auction type, show auction settings sheet
                                                onSurpriseSetSelected?(surpriseSet)
                                            } else {
                                                // For buy_now type, start directly without auction sheet
                                                onSurpriseSetUnitSelected?(surpriseSet, "\(surpriseSet.price ?? 0)", 0, 0, false)
                                            }
                                        }
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .background(Color.backGround)
                }
            } else if displayedProducts.isEmpty {
                GeometryReader { geo in
                    VStack {
                        NoDataView(message: "No Product found")
                            .padding(.top, -100)
                        Spacer()
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        if isLoading && displayedProducts.isEmpty {
                            ForEach(0..<8) { _ in
                                PurchasesViewShimmerView()
                                    .padding(.horizontal, 16)
                            }
                        } else {
                            ForEach(displayedProducts, id: \.id) { product in
                                let productId = product.id ?? 0
                                
                                ProductRehearsalListItem(
                                    product: product,
                                    roomId: roomId,
                                    isPinned: pinnedProductIds.contains(productId),
                                    actionTitle: mode.buttonTitle,
                                    onPinTapped: {
                                        togglePin(productId)
                                    },
                                    onActionTapped: {
                                        onProductSelected?(product)
                                    }
                                )
                                .onAppear {
                                    guard let lastApiProduct = apiProducts.last,
                                          lastApiProduct.id == product.id else { return }
                                    loadNextPageIfNeeded()
                                }
                            }
                        }
                        
                        // Bottom Loader
                        if isFetchingMore {
                            ProgressView()
                                .padding(.vertical, 16)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                .background(Color.backGround)
            }
            PrimaryButton(title: "Add New", onButtonClick: {
                showAddActionSheet = true
            })
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.backGround)
        .onAppear {
            setupSocketListeners()
            if auctionTypeId == 9 {
                self.resetData()
                segment = .Surprise
                fetchSurpriseSet()
            } else if displayedProducts.isEmpty {
                resetData()
                fetchProduct()
            }
        }
        .onDisappear {
            resetData()
        }
        .onChange(of: selectedSort) { _ in
            resetData()
            fetchProduct()
        }
        .sheet(isPresented: $showCreateProductSheet) {
            ListProductScreen(forSheet:true,
                              onCancel:{
                showCreateProductSheet = false
            },
                              preSelectedCategoryId: "\(displayedProducts.first?.category?.id ?? 0)",
                              preSelectedCategoryName: displayedProducts.first?.category?.name ?? "",
                              isCategoryLocked: true)
            .onDisappear {
                // Refresh product list after creating
                resetData()
                fetchProduct()
                onProductCreated?()
            }
        }
        .bottomSheet(
            isPresented: $showSortSheet,
            height: screenHeight * 0.6,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.backGround),
            topBarBackgroundColor: Color(.backGround),
            showTopIndicator: false,
            onDismiss: {
                showSortSheet = false
            },
            content: {
                SortByBottomSheet(
                    isPresented: $showSortSheet,
                    selectedSort: $selectedSort
                )
            }
        )
        .sheet(isPresented: $showManageProductSheet) {
            if let surpriseSet = selectedSurpriseSet {
                ManageProductSheet(
                    surpriseData: surpriseSet,
                    onStartAuction: { product, bidAmount, requiredTime, counterBidTime, isSuddenDeath in
                        // Get the first available unit ID from the product
                        onSurpriseSetUnitSelected?(surpriseSet, bidAmount, requiredTime, counterBidTime, isSuddenDeath)
                        showManageProductSheet = false
                    }
                )
            }
        }
        .sheet(isPresented: $showCreateSurpriseSheet) {
            CreateSurpriseScreen()
                .onDisappear {
                    // Refresh surprise set list after creating
                    if segment == .Surprise {
                        resetData()
                        fetchSurpriseSet()
                    }
                }
        }
        .confirmationDialog("What would you like to create?", isPresented: $showAddActionSheet, titleVisibility: .visible) {
            Button("Create Product") {
                showCreateProductSheet = true
            }
            Button("Create Surprise Set") {
                showCreateSurpriseSheet = true
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Setup Socket Listeners
    private func setupSocketListeners() {
        guard !socketListenersConfigured else { return }
        socketListenersConfigured = true
        
        socketManager.listenForPinnedProductStatus { roomID, productId, message, productIDs in
            guard roomId == roomID else { return }
            let id = Int(productId) ?? 0
            pinnedProductIds.insert(id)
            updateSortedProducts()
        }
        
        socketManager.listenForProductUnpinned { roomID, productID, msg in
            guard roomId == roomID else { return }
            let id = Int(productID) ?? 0
            pinnedProductIds.remove(id)
            updateSortedProducts()
        }
    }
    
    // MARK: - Toggle Pin
    private func togglePin(_ productId: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if pinnedProductIds.contains(productId) {
                pinnedProductIds.remove(productId)
            } else {
                pinnedProductIds.insert(productId)
            }
            updateSortedProducts()
        }
        
        SocketManagerService.shared.sendPinProduct(
            roomId: roomId,
            productId: "\(productId)"
        )
    }
    
    // MARK: - Update Sorted Products
    private func updateSortedProducts() {
        displayedProducts = reorderProducts(
            pinnedIds: pinnedProductIds,
            eventIds: eventProductIds,
            apiProducts: apiProducts
        )
    }
}

// MARK: - Extensions
extension ProductShopRehersalScreen {
    
    private func resetData() {
        productDataFromAPI = []
        apiProducts = []
        displayedProducts = []
        sortedProductData = []
        currentPage = 1
        canLoadMore = true
        isFetchingMore = false
        isLoading = false
        self.status = ""
        self.type = "buy_now"
        self.saleType = ""
    }
    
    func fetchProduct(isLoaderShown: Bool = true) {
        guard !isFetchingMore else { return }
        
        if isLoaderShown && displayedProducts.isEmpty {
            isLoading = true
        }
        isFetchingMore = true
        guard auctionTypeId != 9 else { return }
        
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: false,
                onError: { error in
                    canLoadMore = false
                    isFetchingMore = false
                    isLoading = false
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText: ""
                    )
                    showError = true
                },
                onSuccess: {
                    isLoading = false
                    productSuccess()
                }
            ) {
                let request = ProductRequest(
                    search: searchText,
                    category_ids: categoryId,
                    status:status, page: currentPage,
                    type: type,
                    sale_type: saleType
                )
                try await productViewModel.getProductsData1(parameters: request)
            }
        }
    }
    
    private func loadNextPageIfNeeded() {
        guard canLoadMore,
              !isFetchingMore,
              productDataFromAPI.count < totalCount else { return }
        
        currentPage += 1
        fetchProduct(isLoaderShown: false)
    }
    
    func reorderProducts(
        pinnedIds: Set<Int>,
        eventIds: Set<Int>,
        apiProducts: [ProductDataModel1]
    ) -> [ProductDataModel1] {
        var pinned: [ProductDataModel1] = []
        var event: [ProductDataModel1] = []
        var normal: [ProductDataModel1] = []
        
        for product in apiProducts {
            let id = product.id ?? 0
            
            if pinnedIds.contains(id) {
                pinned.append(product)
            } else if eventIds.contains(id) {
                event.append(product)
            } else {
                normal.append(product)
            }
        }
        
        return pinned + event + normal
    }
  
    func productSuccess() {
        let response = productViewModel.productsResponse1
        guard response?.status == "success" else {
            canLoadMore = false
            isFetchingMore = false
            return
        }

        let newItems = response?.data ?? []
        totalCount = response?.total ?? 0

        let uniqueItems = newItems.filter { newItem in
            !apiProducts.contains(where: { $0.id == newItem.id })
        }

        guard !uniqueItems.isEmpty else {
            canLoadMore = false
            isFetchingMore = false
            return
        }

        apiProducts.append(contentsOf: uniqueItems)
        displayedProducts.append(contentsOf: uniqueItems)

        if apiProducts.count >= totalCount {
            canLoadMore = false
        }

        isFetchingMore = false
        updateSortedProducts()
    }
    
    // MARK: - Fetch Surprise Set
    func fetchSurpriseSet() {
        isLoading = true
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: false,
                onError: { error in
                    isLoading = false
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: productViewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText: ""
                    )
                    showError = true
                },
                onSuccess: {
                    isLoading = false
                    surpriseSetData = productViewModel.getSurpriseResponse?.data ?? []
                }
            ) {
                try await productViewModel.getSurpiseSet()
            }
        }
    }
}

// MARK: - Product List Heading
struct ProductHeading: View {
    let count: Int
    
    var body: some View {
        Text("\(count) Items")
            .font(.custom("Poppins-Bold", size: 14))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
    }
}

// MARK: - Product List Item
struct ProductRehearsalListItem: View {
    let product: ProductDataModel1
    var roomId: String
    var isPinned: Bool
    var actionTitle: String
    var onPinTapped: (() -> Void)?
    var onActionTapped: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // Product Image
            CustomProfileImage(
                url: product.thumbnail?.first ?? "",
                isCircular: false,
                cornerRadius: 12,
                size: 100,
                height: 100,
                defaultImage: "photo"
            ) {}
            .frame(width: 100, height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
            
            // Right Content
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title?.capitalizingFirstLetter() ?? "Product")
                    .font(.custom("Poppins-SemiBold", size: 13))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Text(product.category?.name ?? "N/A")
                        .font(.custom("Poppins-Regular", size: 11))
                        .foregroundColor(.gray)

                    Text(product.productCondition ?? "New")
                        .font(.custom("Poppins-SemiBold", size: 11))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .foregroundColor(.gray)
                }

                Text("$\(product.pricing ?? "0.0")")
                    .font(.custom("Poppins-Bold", size: 15))
                    .foregroundColor(.black)

                // Action Button
                HStack(spacing: 8) {
                    Button(action: {
                        onActionTapped?()
                    }) {
                        Text(actionTitle)
                            .font(.custom("Poppins-SemiBold", size: 12))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(.sRGB, red: 0.98, green: 0.96, blue: 0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .foregroundColor(.black.opacity(0.85))
                    
                    if actionTitle == "Start Auction" {
                        Button(action: {
                            onPinTapped?()
                        }) {
                            Image(systemName: "pin.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(isPinned ? .defaultTheme : .gray.opacity(0.6))
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
