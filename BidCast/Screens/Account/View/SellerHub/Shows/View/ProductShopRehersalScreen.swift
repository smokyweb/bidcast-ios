//
//  ProductShopRehersalScreen.swift
//  BidCast
//
//  Created by JamTech on 16/12/25.
//

import SwiftUI

// MARK: - Inventory Segment Enum
enum RehearsalProductSegment: String, CaseIterable, CustomStringConvertible {
    case auction = "Auction"
    case buynow = "Buy Now"
    case giveway = "Gievway"
    case sold = "Sold"
    case offers = "Offers"
    case tips = "Tips"
    
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

// MARK: - Main Screen
struct ProductShopRehersalScreen: View {
    @State var searchText: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedIndex: Int = 0
    @State private var isLoading: Bool = false
    var roomId: String
    @State private var isFetchingMore = false
    @State private var canLoadMore = true
    
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
    
    @Binding var productDataFromEvent: [ProductDataModel1]
    @State private var productDataFromAPI: [ProductDataModel1] = []
    @State private var sortedProductData: [ProductDataModel1] = []
    @State private var pinnedProductIds: Set<Int> = []
    
    var categoryId: String = "-1"
    @State var currentPage: Int = 1
    @State var segment: RehearsalProductSegment = .auction
    
    var onTapCancel: (() -> Void)?
    var onAuctionTapped: ((ProductDataModel1) -> Void)?
    
    // Track if we've already set up socket listeners
    @State private var socketListenersConfigured = false
    
    private var eventProductIds: Set<Int> {
        Set(productDataFromEvent.compactMap { $0.id })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Search Bar + Close Button
            HStack {
                SearchBarView(placeholder: "Search shop...") { text in
                    resetData()
                    self.searchText = text
                    fetchProduct()
                }
                .padding(.leading, 12)
                
                Button(action: {
                    onTapCancel?()
                }) {
                    Image(systemName: "xmark")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.black)
                }
                .padding(12)
            }
            
            GenericTabView(selectedTab: $segment) {}
            
            // MARK: - Heading
            ProductHeading(count: sortedProductData.count)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    if isLoading {
                        ForEach(0..<8) { _ in
                            PurchasesViewShimmerView()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                    } else if sortedProductData.isEmpty {
                        NoDataView(message: "No Product Found")
                    } else {
                        // FIX: Use product.id for stable identity, not index
                        ForEach(sortedProductData, id: \.id) { product in
                            let productId = product.id ?? 0
                            let productIndex = sortedProductData.firstIndex(where: { $0.id == product.id }) ?? 0
                            
                            ProductRehearsalListItem(
                                product: product, // FIX: Pass value, not binding
                                roomId: roomId,
                                isPinned: pinnedProductIds.contains(productId),
                                onPinTapped: {
                                    togglePin(productId)
                                },
                                onTapAuction: {
                                    onAuctionTapped?(product)
                                }
                            )
                            .padding(.vertical, 4)
                            .onAppear {
                                // FIX: Use original index from productDataFromAPI for pagination
                                handlePagination(currentDisplayIndex: productIndex)
                            }
                        }
                    }

                    // Loader at bottom
                    if isFetchingMore {
                        ProgressView()
                            .padding(.vertical, 16)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.backGround)
        .onAppear {
            setupSocketListeners()
            
            if sortedProductData.isEmpty {
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
        .bottomSheet(
            isPresented: $showSortSheet,
            height: screenHeight * 0.6,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
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
    }
    
    // MARK: - Setup Socket Listeners (Only Once)
    private func setupSocketListeners() {
        guard !socketListenersConfigured else { return }
        socketListenersConfigured = true
        
        socketManager.listenForPinnedProductStatus { roomID, productId, message, productIDs in
            guard roomId == roomID else { return }
            
            let id = Int(productId) ?? 0
            
            // FIX: Update state in one place with animation
            withAnimation(.easeInOut(duration: 0.3)) {
                pinnedProductIds.insert(id)
                updateSortedProducts()
            }
        }
        
        socketManager.listenForProductUnpinned { roomID, productID, msg in
            guard roomId == roomID else { return }
            
            let id = Int(productID) ?? 0
            
            // FIX: Update state in one place with animation
            withAnimation(.easeInOut(duration: 0.3)) {
                pinnedProductIds.remove(id)
                updateSortedProducts()
            }
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
            
            // FIX: Update sorted products immediately
            updateSortedProducts()
        }
        
        // Send socket event (no UI update here)
        SocketManagerService.shared.sendPinProduct(
            roomId: roomId,
            productId: "\(productId)"
        )
    }
    
    // MARK: - Centralized Product Reordering
    private func updateSortedProducts() {
        sortedProductData = reorderProducts(
            pinnedIds: pinnedProductIds,
            eventIds: eventProductIds,
            apiProducts: productDataFromAPI
        )
    }
}

// MARK: - Extensions
extension ProductShopRehersalScreen {
    
    private func resetData() {
        productDataFromAPI = []
        sortedProductData = []
        currentPage = 1
        canLoadMore = true
        isFetchingMore = false
        isLoading = false
    }
    
    func fetchProduct(isLoaderShown: Bool = true) {
        // FIX: Prevent duplicate API calls
        guard !isFetchingMore else { return }
        
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: isLoaderShown,
                onError: { error in
                    canLoadMore = false
                    isFetchingMore = false
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
                    productSuccess()
                }
            ) {
                let request = ProductRequest(
                    search: searchText,
                    category_ids: categoryId,
                    page: currentPage
                )
                try await productViewModel.getProductsData1(parameters: request)
            }
        }
    }
    
    // FIX: Better pagination logic
    func handlePagination(currentDisplayIndex: Int) {
        guard canLoadMore, !isFetchingMore else { return }
        
        // Only load more if we have more data available
        guard productDataFromAPI.count < totalCount else {
            canLoadMore = false
            return
        }
        
        let threshold = sortedProductData.count - 3
        guard currentDisplayIndex >= threshold else { return }
        guard productDataFromAPI.count < totalCount else { return }
        
        isFetchingMore = true
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
    
    // MARK: - Product Success
    func productSuccess() {
        let response = productViewModel.productsResponse1
        
        if response?.status == "success" {
            let newItems = response?.data ?? []
            totalCount = response?.total ?? 0
            
            if newItems.isEmpty {
                canLoadMore = false
            } else {
                // FIX: Check for duplicates before appending
                let newUniqueItems = newItems.filter { newItem in
                    !productDataFromAPI.contains(where: { $0.id == newItem.id })
                }
                
                productDataFromAPI.append(contentsOf: newUniqueItems)
                if productDataFromAPI.count >= totalCount {
                                    canLoadMore = false
                                }
            }
            
            // FIX: Single reorder call
            updateSortedProducts()
            
        } else {
            canLoadMore = false
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
            showError = true
        }
        
        isFetchingMore = false
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
    let product: ProductDataModel1 // FIX: Changed from @Binding to let
    var roomId: String
    var isPinned: Bool
    var onPinTapped: (() -> Void)?
    var onTapAuction: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // MARK: - Product Image
            ZStack(alignment: .topTrailing) {
                CustomProfileImage(
                    url: product.images?.first ?? "",
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
            }
            
            // MARK: - Right Content
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title ?? "Product")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text("\(product.category?.name ?? "N/A")")
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.gray)

                    Text("\(product.productCondition ?? "New")")
                        .font(.custom("Poppins-SemiBold", size: 10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .foregroundColor(.gray)
                        .clipShape(Capsule())
                }

                HStack(spacing: 4) {
                    Text("$\(product.pricing ?? "0.0")")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.black)
                }

                // Buy Now button
                HStack(spacing: 4) {
                    Button(action: {
                        onTapAuction?()
                    }) {
                        Text("Start Auction")
                            .font(.custom("Poppins-SemiBold", size: 15))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.sRGB, red: 0.98, green: 0.96, blue: 0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .foregroundColor(.black.opacity(0.85))
                    
                    Button(action: {
                        onPinTapped?()
                    }) {
                        Image(systemName: "pin.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(isPinned ? .defaultTheme : .gray.opacity(0.6))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}




//enum RehearsalProductSegment: String, CaseIterable, CustomStringConvertible {
//    case auction = "Auction"
//    case buynow = "Buy Now"
//    case giveway = "Gievway"
//    case sold = "Sold"
//    case offers = "Offers"
//    case tips = "Tips"
//    
//    var description: String {
//        NSLocalizedString(rawValue, comment: "")
//    }
//    
//    static var RehearsalProductArray: [String] {
//        return RehearsalProductSegment.allCases.map { $0.rawValue }
//    }
//    
//    // Get segment by index
//    static func segment(at index: Int) -> RehearsalProductSegment? {
//        let allSegments = RehearsalProductSegment.allCases
//        guard allSegments.indices.contains(index) else {
//            return nil
//        }
//        return Array(allSegments)[index]
//    }
//    
//    // Get index of current segment
//    var index: Int {
//        return Array(RehearsalProductSegment.allCases).firstIndex(of: self) ?? 0
//    }
//}
//
//// MARK: - Main Screen
//struct ProductShopRehersalScreen: View {
//    @State var searchText: String = ""
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedIndex: Int = 0
//    @State private var isLoading: Bool = false
//    var roomId: String
//    @State private var isFetchingMore = false
//    @State private var canLoadMore = true
//    
//    @State private var pinnedStatus: [[Int: Bool]] = [[:]]
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    @State var showError: Bool = false
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    @StateObject var socketManager = SocketManagerService.shared
//    
//    @State private var showSortSheet = false
//    @State private var selectedSort: String = "newest"
//    
//    @State private var selectedOptions: String = ""
//    
//    @State private var viewModel = ScheduleViewModel()
//    @State var productViewModel = ProductViewModel()
//    
//    @State private var totalCount = 0
//    
//    
//    //    // Get IDs from event products
//    private var eventProductIds: Set<Int> {
//        Set(productDataFromEvent.compactMap { $0.id })
//    }
//    
//    
//    @Binding var productDataFromEvent: [ProductDataModel1]
//    @State private var productDataFromAPI: [ProductDataModel1] = []
//
//    @State private var sortedProductData: [ProductDataModel1] = []
////    @State private var pinnedProductId: [Int] = []
//    @State private var pinnedProductIds: Set<Int> = []
//    //    @State var categoryId: String = "-1"
//    var categoryId: String = "-1"
//    @State var currentPage: Int = 1
//    
//    @State var segment: RehearsalProductSegment = .auction
//    var onTapCancel: (() -> Void)?
//    var onAuctionTapped: ((ProductDataModel1) -> Void)?
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            
//            // MARK: - Search Bar + Close Button
//            HStack {
//                SearchBarView(placeholder: "Search shop...") { text in
////                    if text == "" { return }
//                    resetData()
//                    self.searchText = text
//                    fetchProduct()
//                }
//                .padding(.leading, 12)
//                
//                Button(action: {
//                    onTapCancel?()
//                }) {
//                    Image(systemName: "xmark")
//                        .font(.custom("Poppins-SemiBold", size: 14))
//                        .foregroundColor(.gray)
//                }
//                .padding(12)
//            }
//            GenericTabView(selectedTab: $segment) {
//            }
//            // MARK: - Heading
//            ProductHeading(count: sortedProductData.count)
//            
//            ScrollView(showsIndicators: false) {
//                LazyVStack(spacing: 0) {
//
//                    if isLoading {
//                        ForEach(0..<8) { _ in
//                            PurchasesViewShimmerView()
//                                .padding(.horizontal, 8)
//                                .padding(.vertical, 4)
//                        }
//                    } else if sortedProductData.isEmpty {
//                        NoDataView(message: "No Product Found")
//                    } else {
//                        ForEach(sortedProductData.indices, id: \.self) { index in
//                            let product = sortedProductData[index]
//                            let productId = product.id ?? 0
//                            ProductRehearsalListItem(product: $sortedProductData[index],
//                                                     roomId: roomId,
//                                                     isPinned: pinnedProductIds.contains(sortedProductData[index].id ?? 0),
//                                                     onPinTapped: {
//                                togglePin(productId)
//                            },
//                            onTapAuction: {
//                                onAuctionTapped?(sortedProductData[index])
//                            })
//                                .padding(.vertical, 4)
//                                .onAppear {
//                                    handlePagination(index: index)
//                                }
//                        }
//                    }
//
//                    // Loader at bottom
//                    if isFetchingMore {
//                        ProgressView()
//                            .padding(.vertical, 16)
//                    }
//                }
//            }
//
//            
//            Spacer(minLength: 0)
//        }
//        .frame(maxHeight: .infinity, alignment: .top)
//        .background(.clear)
//        .onAppear {
//            DispatchQueue.main.async {
//                fetchProduct()
//            }
//            
//            socketManager.listenForPinnedProductStatus {roomID, productId, message,productIDs in
////                print("\(productId) is \(isPinned)")
//                guard roomId == roomID else { return }
//
//                    let id = Int(productId) ?? 0
//
//                    pinnedProductIds.insert(id)
//
//                    sortedProductData = reorderProducts(
//                        pinnedIds: pinnedProductIds,
//                        eventIds: eventProductIds,
//                        apiProducts: productDataFromAPI
//                    )
//            }
//            socketManager.listenForProductUnpinned{ roomID,productID,msg in
//                guard roomId == roomID else { return }
//
//                   let id = Int(productID) ?? 0
//
//                   pinnedProductIds.remove(id)
//
//                   sortedProductData = reorderProducts(
//                       pinnedIds: pinnedProductIds,
//                       eventIds: eventProductIds,
//                       apiProducts: productDataFromAPI
//                   )
//                
//            }
//        }
//        .onDisappear {
//            resetData()
//        }
//        .onChange(of: selectedSort) { _ in
//            resetData()
//            fetchProduct()
//        }
//
//        .bottomSheet(
//                   isPresented: $showSortSheet,
//                   height: screenHeight * 0.6,
//                   topBarCornerRadius: 20,
//                   contentBackgroundColor: Color(.systemBackground),
//                   topBarBackgroundColor: Color(.systemBackground),
//                   showTopIndicator: false,
//                   onDismiss: {
//                       showSortSheet = false
//                   },
//                   content: {
//                       SortByBottomSheet(
//                           isPresented: $showSortSheet,
//                           selectedSort: $selectedSort
//                       )
//                   }
//               )
//    }
//    private func togglePin(_ productId: Int) {
//
//        if pinnedProductIds.contains(productId) {
//            pinnedProductIds.remove(productId)
//        } else {
//            pinnedProductIds.insert(productId)
//        }
//
//        // 🔁 Reorder immediately
//        sortedProductData = reorderProducts(
//            pinnedIds: pinnedProductIds,
//            eventIds: eventProductIds,
//            apiProducts: productDataFromAPI
//        )
//
//        // 🔥 Backend toggle
//        SocketManagerService.shared.sendPinProduct(
//            roomId: roomId,
//            productId: "\(productId)"
//        )
//    }
//}
//
//
//extension ProductShopRehersalScreen {
//    
//    private func resetData() {
//        productDataFromAPI = []
//        sortedProductData = []
//        currentPage = 1
//        canLoadMore = true
//        isFetchingMore = false
//    }
//
//    
//    func fetchProduct(isLoaderShown: Bool = true) {
//        Task{
//            await performAPICalls(
//                isConcurrent: false,
//                showLoader: isLoaderShown,
//                onError: { error in
//                    canLoadMore = false
//                    isFetchingMore = false
//                    alertType = .sheetType(
//                        icon: .alert,
//                        title: "Error",
//                        message: viewModel.errorMessage ?? "",
//                        primaryBtnText: AppString.ok.localized,
//                        secondaryBtnText:""
//                    )
//                    showError = true
//                },
//                onSuccess: {
//                    productSuccess()
//                }
//            ) {
//                let request = ProductRequest(search: searchText,
//                                             category_ids: categoryId,
//                                             page:currentPage,
//                )
//                try await productViewModel.getProductsData1(parameters: request)
//            }
//        }
//    }
//    
//    func handlePagination(index: Int) {
//        guard canLoadMore, !isFetchingMore else { return }
//        guard totalCount > (index + 1) else { return }
//        let thresholdIndex = productDataFromAPI.count - 1
//        if index == thresholdIndex {
//            isFetchingMore = true
//            currentPage += 1
//            fetchProduct(isLoaderShown: false)
//        }
//    }
//    
//    func reorderProducts(
//        pinnedIds: Set<Int>,
//        eventIds: Set<Int>,
//        apiProducts: [ProductDataModel1]
//    ) -> [ProductDataModel1] {
//
//        var pinned: [ProductDataModel1] = []
//        var event: [ProductDataModel1] = []
//        var normal: [ProductDataModel1] = []
//
//        for product in apiProducts {
//            let id = product.id ?? 0
//
//            if pinnedIds.contains(id) {
//                pinned.append(product)
//            } else if eventIds.contains(id) {
//                event.append(product)
//            } else {
//                normal.append(product)
//            }
//        }
//
//        return pinned + event + normal
//    }
//
//    
//
//    //MARK: productSuccess.
//    func productSuccess() {
//        let response = productViewModel.productsResponse1
//
//        if response?.status == "success" {
//            let newItems = response?.data ?? []
//            totalCount = response?.total ?? 0
//
//            if newItems.isEmpty {
//                canLoadMore = false
//            } else {
//                productDataFromAPI.append(contentsOf: newItems)
//            }
//
//            // 🔥 ALWAYS reorder with pinned + event
//            sortedProductData = reorderProducts(
//                pinnedIds: pinnedProductIds,
//                eventIds: eventProductIds,
//                apiProducts: productDataFromAPI
//            )
//
//        } else {
//            canLoadMore = false
//            alertType = .sheetType(
//                icon: .alert,
//                title: "Error",
//                message: viewModel.errorMessage ?? "",
//                primaryBtnText: AppString.ok.localized,
//                secondaryBtnText: ""
//            )
//            showError = true
//        }
//
//        isFetchingMore = false
//    }
//
//}
//
//// MARK: - Product List Heading
//struct ProductHeading: View {
//    let count: Int
//    
//    var body: some View {
//        Text("\(count) Items")
//            .font(.custom("Poppins-Bold", size: 14))
//            .foregroundColor(.black)
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.leading, 12)
//    }
//}
//
//
//// MARK: - Product List Item
//struct ProductRehearsalListItem: View {
//    @Binding var product: ProductDataModel1
//    var roomId: String
//    var isPinned: Bool
////    var pinnedProduct: ((Int) -> Void) = {_ in}
//    var onPinTapped: (() -> Void)?
//    var onTapAuction: (() -> Void)?
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            
//            // MARK: - Product Image
//            ZStack(alignment: .topTrailing) {
//                CustomProfileImage(
//                    url: product.images?.first ?? "",
//                    isCircular: false,
//                    cornerRadius: 12,
//                    size: 100,
//                    height: 100,
//                    defaultImage: "photo"
//                ) {}
//                .frame(width: 100, height: 100)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
//                )
//                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
//            
//            }
//            
//            // MARK: - Right Content
//            VStack(alignment: .leading, spacing: 6) {
//                Text(product.title ?? "Product")
//                    .font(.custom("Poppins-SemiBold", size: 16))
//                    .foregroundColor(.black)
//                    .lineLimit(2)
//
//                HStack(spacing: 6) {
//                    Text("\(product.category?.name ?? "N/A")") //toDo: static data
//                        .font(.custom("Poppins-Regular", size: 13))
//                        .foregroundColor(.gray)
//
//                    Text("\(product.productCondition ?? "New")")
//                        .font(.custom("Poppins-SemiBold", size: 10))
//                        .padding(.horizontal, 6)
//                        .padding(.vertical, 2)
//                        .foregroundColor(.gray)
//                        .clipShape(Capsule())
//                }
//
//                HStack(spacing: 4) {
//                    Text("$\(product.pricing ?? "0.0")")
//                        .font(.custom("Poppins-Bold", size: 18))
//                        .foregroundColor(.black)
//                }
//
//                // Buy Now button
//                HStack(spacing: 4) {
//                    Button(action: {
//                        onTapAuction?()
//                    }) {
//                        Text("Start Auction")
//                            .font(.custom("Poppins-SemiBold", size: 15))
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 10)
//                            .background(Color(.sRGB, red: 0.98, green: 0.96, blue: 0.95))
//                            .clipShape(RoundedRectangle(cornerRadius: 22))
//                    }
//                    .foregroundColor(.black.opacity(0.85))
//                        Button(action: {
//                            onPinTapped?()
//                        }) {
//                            Image(systemName: "pin.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 22, height: 22)
//                                .foregroundColor(isPinned ? .defaultTheme : .gray.opacity(0.6))
//                        }
//                }
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(12)
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.black.opacity(0.08), lineWidth: 1)
//        )
//        .padding(.horizontal, 12)
//        .padding(.vertical, 6)
//    }
//}
