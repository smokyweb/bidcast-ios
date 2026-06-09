//
//  ProductShopRehersalScreen.swift
//  BidCast
//
//  Created by JamTech on 16/12/25.
//

import SwiftUI

// MARK: - Inventory Segment Enum
// Basecamp #7 (PWA refs 49fba598, cdb8fefb, 8096b426): seller live-shop tabs
// are All / Sold / Offers (dropped the redundant Buy Now / Auction tabs).
// Surprise Sets retained only for the surprise-set show context (auctionTypeId 9).
enum RehearsalProductSegment: String, CaseIterable, CustomStringConvertible {
    case all = "All"
    case sold = "Sold"
    case offers = "Offers"
    case Surprise = "Surprise Sets"
    // Legacy cases kept so the existing `switch segment` stays exhaustive and
    // any older references still compile; no longer surfaced as tabs.
    case buynow = "Buy Now"
    case auction = "Auction"
    
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
    // MARK: - Inputs
    var mode: RehearsalSelectionMode = .auction
    @Environment(\.presentationMode) var presentationMode
    var roomId: String

    // MARK: - UI state
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var showSortSheet = false
    @State private var selectedSort: String = "newest"
    @State private var selectedOptions: String = ""
    @State private var showCreateProductSheet = false
    @State private var showManageProductSheet = false
    @State private var showAddActionSheet = false
    @State private var showCreateSurpriseSheet = false
    @State private var showInventoryPickerSheet = false

    // MARK: - Pagination / filtering
    @State private var isFetchingMore = false
    @State private var canLoadMore = true
    // Basecamp #7: default tab is now "All" -> no format/status filter.
    @State private var saleType = ""
    @State private var type = ""
    @State private var status = ""
    @State private var totalCount = 0
    @State private var currentPage: Int = 1
    @State var segment: RehearsalProductSegment = .buynow
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    // MARK: - Dependencies
    @StateObject var socketManager = SocketManagerService.shared
    
    @State private var viewModel = ScheduleViewModel()
    @State var productViewModel = ProductViewModel()
    
    // MARK: - Data
    @Binding var auctionTypeId : Int
    @Binding var productDataFromEvent: [ProductDataModel1]
    @State private var pinnedProductIds: Set<Int> = []
    @State private var apiProducts: [ProductDataModel1] = []
    @State private var displayedProducts: [ProductDataModel1] = []
    @State private var surpriseSetData: [ProductSurpriseData] = []
    
    var categoryId: String = "-1"
    var categoryName: String = ""
    
    var onTapCancel: (() -> Void)?
    var onProductSelected: ((ProductDataModel1) -> Void)?
    var onSurpriseSetSelected: ((ProductSurpriseData) -> Void)?
    var onSurpriseSetUnitSelected: ((Int,Int ,ProductSurpriseData, String, Int, Int, Bool) -> Void)?
    @State private var socketListenersConfigured = false
    
    var onProductCreated: (() -> Void)?
    var onProductsAdded: (([ProductDataModel1]) -> Void)?
    
    @State private var selectedSurpriseSet: ProductSurpriseData?
    
    // MARK: - Derived values
    private var eventProductIds: Set<Int> {
        Set(productDataFromEvent.compactMap { $0.id })
    }
    
    private var availableTabs: [RehearsalProductSegment] {
        if auctionTypeId == 9 {
            // Surprise Sets show: All / Sold / Offers + the Surprise Sets tab.
            return [.all, .sold, .offers, .Surprise]
        } else {
            // Basecamp #7: All / Sold / Offers (dropped Buy Now / Auction).
            return [.all, .sold, .offers]
        }
    }
    
    init(
        mode: RehearsalSelectionMode = .auction,
        roomId: String,
        auctionTypeId: Binding<Int>,
        productDataFromEvent: Binding<[ProductDataModel1]>,
        categoryId: String = "-1",
        categoryName: String = "",
        onTapCancel: (() -> Void)? = nil,
        onProductSelected: ((ProductDataModel1) -> Void)? = nil,
        onSurpriseSetSelected: ((ProductSurpriseData) -> Void)? = nil,
        onSurpriseSetUnitSelected: ((Int,Int,ProductSurpriseData, String, Int, Int, Bool) -> Void)?,
        onProductCreated: (() -> Void)? = nil,
        onProductsAdded: (([ProductDataModel1]) -> Void)? = nil
    ) {
        self.mode = mode
        self.roomId = roomId
        self._auctionTypeId = auctionTypeId
        self._productDataFromEvent = productDataFromEvent
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.onTapCancel = onTapCancel
        self.onProductSelected = onProductSelected
        self.onSurpriseSetSelected = onSurpriseSetSelected
        self.onSurpriseSetUnitSelected = onSurpriseSetUnitSelected
        self.onProductCreated = onProductCreated
        self.onProductsAdded = onProductsAdded
        
        // Set initial segment based on auctionTypeId. Default to the new
        // "All" tab (Basecamp #7); surprise-set shows still open on Surprise.
        self._segment = State(initialValue: auctionTypeId.wrappedValue == 9 ? .Surprise : .all)
    }
    
    private var headingCount: Int {
        if auctionTypeId == 9 { return surpriseSetData.count }
        if segment == .Surprise { return surpriseSetData.count }
        return displayedProducts.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            tabsView
            
            // MARK: - Heading
            ProductHeading(count: headingCount)
                .padding(.vertical,6)
                .padding(.horizontal, 16)
            
            contentView
            addNewButton
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.backGround)
        .onAppear(perform: handleOnAppear)
        .onDisappear(perform: resetData)
        .onChange(of: selectedSort) { _ in
            resetData()
            fetchProduct()
        }
        .sheet(isPresented: $showCreateProductSheet) { createProductSheet }
        .bottomSheet(isPresented: $showSortSheet, height: screenHeight * 0.6, topBarCornerRadius: 20, contentBackgroundColor: Color(.backGround), topBarBackgroundColor: Color(.backGround), showTopIndicator: false, onDismiss: { showSortSheet = false }) {
            SortByBottomSheet(isPresented: $showSortSheet, selectedSort: $selectedSort)
        }
        .sheet(isPresented: $showManageProductSheet) { manageProductSheet }
        .sheet(isPresented: $showCreateSurpriseSheet) { createSurpriseSheet }
        .sheet(isPresented: $showInventoryPickerSheet) { inventoryPickerSheet }
        .confirmationDialog("What would you like to create?", isPresented: $showAddActionSheet, titleVisibility: .visible) {
            Button("Choose From Inventory") { showInventoryPickerSheet = true }
            Button("Create Product") { showCreateProductSheet = true }
            Button("Create Surprise Set") { showCreateSurpriseSheet = true }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Header / Tabs / Content
    private var headerView: some View {
        HStack(spacing: 12) {
            SearchBarView(placeholder: "Search shop...") { text in
                resetData()
                searchText = text
                fetchProduct()
            }
            
            Button(action: { onTapCancel?() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.custom(poppinsSemiBold, size: 20.0))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.backGround)
    }
    
    private var tabsView: some View {
        GenericTabView(selectedTab: $segment, tabs: availableTabs) {
            resetData()
            
            if auctionTypeId == 9 {
                fetchSurpriseSet()
                return
            }
            
            switch segment {
            case .all:
                // Basecamp #7: full show product list, no format/status filter.
                saleType = ""
                type = ""
                status = ""
                fetchProduct()
            case .offers:
                saleType = "accept_offers"
                type = ""
                status = ""
                fetchProduct()
            case .sold:
                // Basecamp #9959083112 (2026-06-03): the Sold tab was sending
                // status="inactive" to get-product. Verified against the LIVE
                // backend + DB that this is wrong: a purchased product keeps
                // status="active" (the purchase flow increments purchased_quantity
                // and never flips status), so status="inactive" returned only the
                // handful of manually-deactivated products and NONE of the actually
                // sold ones — the Sold tab was always empty for sold items.
                //
                // A product is "sold" when purchased_quantity > 0. There is no
                // backend filter for that, so we fetch the show's full product list
                // (status="", like the All tab) and filter to purchased_quantity > 0
                // CLIENT-SIDE in updateSortedProducts() — mirroring the Android
                // in-show shop, which also filters the show list client-side.
                saleType = ""
                status = ""
                type = ""
                fetchProduct()
            case .Surprise:
                fetchSurpriseSet()
            case .buynow, .auction:
                // Legacy cases — no longer reachable from the tab bar; treat as All.
                saleType = ""
                type = ""
                status = ""
                fetchProduct()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if auctionTypeId == 9 {
            surpriseSetsContent
        } else if displayedProducts.isEmpty {
            emptyProductsContent
        } else {
            productsListContent
        }
    }
    
    private var addNewButton: some View {
        PrimaryButton(title: "Add New", onButtonClick: { showAddActionSheet = true })
    }
    
    // MARK: - Surprise Sets Content
    @ViewBuilder
    private var surpriseSetsContent: some View {
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
                                onPin: { },
                                onTap: {
                                    if surpriseSet.type == "auction" {
                                        onSurpriseSetSelected?(surpriseSet)
                                    } else {
                                        onSurpriseSetUnitSelected?(0, 0, surpriseSet, "\(surpriseSet.price ?? 0)", 0, 0, false)
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
    }
    
    // MARK: - Products List Content
    private var emptyProductsContent: some View {
        GeometryReader { geo in
            VStack {
                NoDataView(message: "No Product found")
                    .padding(.top, -100)
                Spacer()
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    private var productsListContent: some View {
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
                            // Basecamp #9959083112 ROUND 2 (2026-06-03): sold items
                            // must NOT show the "Start Auction" button — a product
                            // that's already been purchased can't be auctioned. Hide
                            // the action button on the Sold tab (still shown on All/
                            // Offers). Surprise Sets (9) hides it as before.
                            showsActionButton: auctionTypeId != 9 && segment != .sold,
                            onPinTapped: { togglePin(productId) },
                            onActionTapped: { onProductSelected?(product) }
                        )
                        .onAppear {
                            guard let lastApiProduct = apiProducts.last,
                                  lastApiProduct.id == product.id else { return }
                            loadNextPageIfNeeded()
                        }
                    }
                }
                
                if isFetchingMore {
                    ProgressView()
                        .padding(.vertical, 16)
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color.backGround)
    }
    
    // MARK: - Sheets
    private var createProductSheet: some View {
        ListProductScreen(
            forSheet: true,
            onCancel: { showCreateProductSheet = false },
            preSelectedCategoryId: nil,
            preSelectedCategoryName: nil,
            isCategoryLocked: false,
            onProductCreated: { product in
                addProductsToLiveShow([product])
                showCreateProductSheet = false
            }
        )
        .onDisappear {
            resetData()
            fetchProduct()
            onProductCreated?()
        }
    }

    private var inventoryPickerSheet: some View {
        InventoryScreen(
            preSelectedProducts: productDataFromEvent,
            showAuctionTypeId: "\(auctionTypeId)",
            navigatedFrom: .addProduct,
            onProductsSelected: { products in
                addProductsToLiveShow(products)
                showInventoryPickerSheet = false
            }
        )
    }
    
    @ViewBuilder
    private var manageProductSheet: some View {
        if let index = surpriseSetData.firstIndex(where: { $0.id == selectedSurpriseSet?.id }) {
            ManageProductSheet(
                surpriseData: $surpriseSetData[index],
                onStartAuction: { itemId, productId, product, bidAmount, requiredTime, counterBidTime, isSuddenDeath in
                    onSurpriseSetUnitSelected?(itemId, productId, product, bidAmount, requiredTime, counterBidTime, isSuddenDeath)
                    showManageProductSheet = false
                },
                didUpdate: { fetchSurpriseSet() }
            )
        }
    }
    
    private var createSurpriseSheet: some View {
        CreateSurpriseScreen()
            .onDisappear {
                if segment == .Surprise {
                    resetData()
                    fetchSurpriseSet()
                }
            }
    }
    
    // MARK: - Lifecycle
    private func handleOnAppear() {
        setupSocketListeners()
        if auctionTypeId == 9 {
            resetData()
            segment = .Surprise
            fetchSurpriseSet()
        } else if displayedProducts.isEmpty {
            resetData()
            fetchProduct()
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
        var products = reorderProducts(
            pinnedIds: pinnedProductIds,
            eventIds: eventProductIds,
            apiProducts: apiProducts
        )

        // Basecamp #9959083112 (2026-06-03): the Sold tab shows products that
        // buyers have purchased. "Sold" == purchased_quantity > 0 (verified live:
        // sold products keep status="active", so we cannot rely on a status flag).
        // The fetch for this tab pulls the show's full list (status=""); we filter
        // to the purchased ones here, client-side.
        if segment == .sold {
            // Basecamp #9959083112 ROUND 2 (2026-06-03): two fixes from Trey's QA:
            //  (1) "shows all sold items, not just this show's" — the Sold tab must
            //      stay scoped to THIS show. reorderProducts() already scopes to
            //      eventProductIds when present, but we additionally hard-filter
            //      to the show's product set here so off-show purchased products
            //      can never leak in even if apiProducts contains catalog items.
            //  (2) purchased_quantity > 0 identifies a sold product.
            let scoped = eventProductIds.isEmpty
                ? products
                : products.filter { eventProductIds.contains($0.id ?? -1) }
            products = scoped.filter { (Int($0.purchasedQuantity ?? "0") ?? 0) > 0 }
        }

        displayedProducts = products
    }

    private func addProductsToLiveShow(_ products: [ProductDataModel1]) {
        guard !products.isEmpty else { return }

        let existingIds = Set(productDataFromEvent.compactMap { $0.id })
        let newProducts = products.filter { product in
            guard let id = product.id else { return false }
            return !existingIds.contains(id)
        }

        if !newProducts.isEmpty {
            productDataFromEvent.append(contentsOf: newProducts)
        }

        let apiIds = Set(apiProducts.compactMap { $0.id })
        let missingApiProducts = products.filter { product in
            guard let id = product.id else { return false }
            return !apiIds.contains(id)
        }
        apiProducts.append(contentsOf: missingApiProducts)
        updateSortedProducts()

        onProductsAdded?(products)
    }
}

// MARK: - Extensions
extension ProductShopRehersalScreen {
    
    private func resetData() {
        apiProducts = []
        displayedProducts = []
        currentPage = 1
        canLoadMore = true
        isFetchingMore = false
        isLoading = false
        // Basecamp #7: reset to the unfiltered "All" defaults; the tab switch
        // sets format/status filters when a specific tab is chosen.
        self.status = ""
        self.type = ""
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
              apiProducts.count < totalCount else { return }

        // Basecamp #9943369910: in the show-scoped picker we only display the
        // show's products (eventProductIds). Once every show product has been
        // loaded, stop paging the rest of the category catalog — otherwise the
        // list keeps fetching off-show items we never render (the old 7->13).
        if !eventProductIds.isEmpty {
            let loadedIds = Set(apiProducts.compactMap { $0.id })
            if eventProductIds.isSubset(of: loadedIds) {
                canLoadMore = false
                return
            }
        }

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
        
        // Basecamp #9943369910 (2026-06-02, Larry confirmed "only 7"): the
        // in-show auction/freebie picker must show ONLY the products added to
        // THIS show, not the seller's whole category catalog. The category API
        // returns every product in the show's category (e.g. 13) and we used to
        // append `normal` (the off-show items), so the list flickered 7 -> 13.
        // When a show product set (eventIds) is present, scope strictly to it.
        // eventIds empty => non-show context (browse/add): keep old behavior.
        if !eventIds.isEmpty {
            return pinned + event
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
    var showsActionButton: Bool = true
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
                    if showsActionButton {
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
                    }
                    
                    if showsActionButton, actionTitle == "Start Auction" {
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
