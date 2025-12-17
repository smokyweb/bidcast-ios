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
    
    // Get segment by index
    static func segment(at index: Int) -> RehearsalProductSegment? {
        let allSegments = RehearsalProductSegment.allCases
        guard allSegments.indices.contains(index) else {
            return nil
        }
        return Array(allSegments)[index]
    }
    
    // Get index of current segment
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
    
    @State private var pinnedStatus: [[Int: Bool]] = [[:]]
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
    
    
    //    // Get IDs from event products
    private var eventProductIds: Set<Int> {
        Set(productDataFromEvent.compactMap { $0.id })
    }
    
    
    @Binding var productDataFromEvent: [ProductDataModel1]
    @State private var productDataFromAPI: [ProductDataModel1] = []

    @State private var sortedProductData: [ProductDataModel1] = []
    @State private var pinnedProductId: [Int] = []
    //    @State var categoryId: String = "-1"
    var categoryId: String = "-1"
    @State var currentPage: Int = 1
    
    @State var segment: RehearsalProductSegment = .auction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Search Bar + Close Button
            HStack {
                SearchBarView(placeholder: "Search shop...") { text in
                    if text == "" { return }
                    resetData()
                    self.searchText = text
                    fetchProduct()
                }
                .padding(.leading, 12)
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(12)
            }
            GenericTabView(selectedTab: $segment) {
            }
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
                        ForEach(sortedProductData.indices, id: \.self) { index in
                            ProductRehearsalListItem(product: $sortedProductData[index],
                                                     roomId: roomId,
                                                     isPinned: pinnedProductId.contains(sortedProductData[index].id ?? 0))
                                .padding(.vertical, 4)
                                .onAppear {
                                    handlePagination(index: index)
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
        .background(.clear)
        .onAppear {
            DispatchQueue.main.async {
                fetchProduct()
            }
            
            socketManager.listenForPinnedProductStatus { productId, isPinned in
                print("\(productId) is \(isPinned)")
                pinnedProductId.insert(productId, at: 0)
                sortedProductData = updatedProductsByPinnedEvent(pinnedProductId: productId, apiProducts: sortedProductData)
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
}


extension ProductShopRehersalScreen {
    
    private func resetData() {
        productDataFromAPI = []
        sortedProductData = []
        currentPage = 1
        canLoadMore = true
        isFetchingMore = false
    }

    
    func fetchProduct(isLoaderShown: Bool = true) {
        Task{
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
                        secondaryBtnText:""
                    )
                    showError = true
                },
                onSuccess: {
                    productSuccess()
                }
            ) {
                let request = ProductRequest(search: searchText,
                                             category_ids: categoryId,
                                             page:currentPage,
                )
                try await productViewModel.getProductsData1(parameters: request)
            }
        }
    }
    
    func handlePagination(index: Int) {
        guard canLoadMore, !isFetchingMore else { return }
        guard totalCount > (index + 1) else { return }
        let thresholdIndex = productDataFromAPI.count - 1
        if index == thresholdIndex {
            isFetchingMore = true
            currentPage += 1
            fetchProduct(isLoaderShown: false)
        }
    }
    
    func reorderProductsByEvent(
        priorityIds: Set<Int>,
        apiProducts: [ProductDataModel1]
    ) -> [ProductDataModel1] {
        
        var priority: [ProductDataModel1] = []
        var remaining: [ProductDataModel1] = []
        
        for product in apiProducts {
            if priorityIds.contains(product.id ?? 0) {
                priority.append(product)
            } else {
                remaining.append(product)
            }
        }
        
        return priority + remaining
    }
    
    func updatedProductsByPinnedEvent(pinnedProductId: Int,
        apiProducts: [ProductDataModel1]
    ) -> [ProductDataModel1] {

        let eventIds =  Set([pinnedProductId])
        return reorderProductsByEvent( priorityIds: eventIds, apiProducts: apiProducts)
    }

    //MARK: productSuccess.
    func productSuccess(){
        let response = productViewModel.productsResponse1
        if response?.status == "success"{
            let newItems = response?.data ?? []
            totalCount = response?.total ?? 0
            if newItems.isEmpty {
                canLoadMore = false
            } else {
                productDataFromAPI.append(contentsOf: newItems)
            }
            sortedProductData = reorderProductsByEvent(priorityIds: eventProductIds, apiProducts: productDataFromAPI)
        }else{
            canLoadMore = false
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
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
    @Binding var product: ProductDataModel1
    var roomId: String
    var isPinned: Bool
//    var pinnedProduct: ((Int) -> Void) = {_ in}
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
                    Text("\(product.category?.name ?? "N/A")") //toDo: static data
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
                            SocketManagerService.shared.sendPinProduct(roomId: roomId, productId: "\(product.id ?? 0)")
                            
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
//
//import SwiftUI
//
//// MARK: - Main Screen
//struct ProductShopRehersalScreen: View {
//    @State var searchText: String = ""
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedIndex: Int = 0
//    @State private var isLoading: Bool = false
//    
//    @State private var isFetchingMore = false
//    @State private var canLoadMore = true
//    
//    @State private var pinnedProductIds: Set<Int> = [] // Track manually pinned product IDs
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
//    @Binding var productDataFromEvent: [ProductDataModel1]
//    @State private var productDataFromAPI: [ProductDataModel1] = []
//    var categoryId: String = "-1"
//    @State var currentPage: Int = 1
//    
//    @State var segment: RehearsalProductSegment = .auction
//    @State private var roomId: String = "" // Add your room ID here
//    
//    // Get IDs from event products
//    private var eventProductIds: Set<Int> {
//        Set(productDataFromEvent.compactMap { $0.id })
//    }
//    
//    // Computed property for sorted products
//    private var sortedProducts: [ProductDataModel1] {
//        let eventIds = eventProductIds
//        let pinnedIds = pinnedProductIds
//        
//        return productDataFromAPI.sorted { product1, product2 in
//            let id1 = product1.id ?? 0
//            let id2 = product2.id ?? 0
//            
//            // Check if products are manually pinned
//            let isPinned1 = pinnedIds.contains(id1)
//            let isPinned2 = pinnedIds.contains(id2)
//            
//            // Check if products are in event
//            let isInEvent1 = eventIds.contains(id1)
//            let isInEvent2 = eventIds.contains(id2)
//            
//            // Priority 1: Manually pinned products (highest priority) - at TOP
//            if isPinned1 && !isPinned2 { return true }
//            if !isPinned1 && isPinned2 { return false }
//            
//            // Priority 2: Products in event (but not manually pinned) - in MIDDLE
//            if !isPinned1 && !isPinned2 {
//                if isInEvent1 && !isInEvent2 { return true }
//                if !isInEvent1 && isInEvent2 { return false }
//            }
//            
//            // Priority 3: Regular products - at BOTTOM
//            // Within same priority, sort by product ID
//            return id1 < id2
//        }
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            
//            // MARK: - Search Bar + Close Button
//            HStack {
//                SearchBarView(placeholder: "Search shop...") { text in
//                    if text == "" { return }
//                    resetData()
//                    self.searchText = text
//                    fetchProduct()
//                }
//                .padding(.leading, 12)
//                
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Image(systemName: "xmark")
//                        .font(.custom("Poppins-SemiBold", size: 14))
//                        .foregroundColor(.gray)
//                }
//                .padding(12)
//            }
//            
//            GenericTabView(selectedTab: $segment) {}
//            
//            // MARK: - Heading
//            ProductHeading(count: sortedProducts.count)
//            
//            ScrollView(showsIndicators: false) {
//                LazyVStack(spacing: 0) {
//                    if isLoading {
//                        ForEach(0..<8) { _ in
//                            PurchasesViewShimmerView()
//                                .padding(.horizontal, 8)
//                                .padding(.vertical, 4)
//                        }
//                    } else if sortedProducts.isEmpty {
//                        NoDataView(message: "No Product Found")
//                    } else {
//                        ForEach(sortedProducts.indices, id: \.self) { index in
//                            let product = sortedProducts[index]
//                            let productId = product.id ?? 0
//                            let isPinned = pinnedProductIds.contains(productId)
//                            let isInEvent = eventProductIds.contains(productId)
//                            
//                            ProductRehearsalListItem(
//                                product: product,
//                                isPinned: isPinned,
//                                isInEvent: isInEvent,
//                                onPinToggle: {
//                                    togglePin(productId: productId)
//                                }
//                            )
//                            .padding(.vertical, 4)
//                            .onAppear {
//                                handlePagination(index: index)
//                            }
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
//            Spacer(minLength: 0)
//        }
//        .frame(maxHeight: .infinity, alignment: .top)
//        .background(.clear)
//        .onAppear {
//            DispatchQueue.main.async {
//                fetchProduct()
//            }
//            
//            // Listen for socket updates
//            socketManager.listenForPinnedProductStatus { productId, isPinned in
//                handleSocketPinUpdate(productId: productId, isPinned: isPinned)
//            }
//        }
//        .onDisappear {
//            resetData()
//        }
//        .onChange(of: selectedSort) { _ in
//            resetData()
//            fetchProduct()
//        }
//        .bottomSheet(
//            isPresented: $showSortSheet,
//            height: screenHeight * 0.6,
//            topBarCornerRadius: 20,
//            contentBackgroundColor: Color(.systemBackground),
//            topBarBackgroundColor: Color(.systemBackground),
//            showTopIndicator: false,
//            onDismiss: {
//                showSortSheet = false
//            },
//            content: {
//                SortByBottomSheet(
//                    isPresented: $showSortSheet,
//                    selectedSort: $selectedSort
//                )
//            }
//        )
//    }
//}
//
//extension ProductShopRehersalScreen {
//    
//    // MARK: - Toggle Pin
//    private func togglePin(productId: Int) {
//        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
//            if pinnedProductIds.contains(productId) {
//                // Unpin
//                pinnedProductIds.remove(productId)
//                socketManager.sendUnpinProduct(roomId: roomId, productId: String(productId))
//            } else {
//                // Pin
//                pinnedProductIds.insert(productId)
//                socketManager.sendPinProduct(roomId: roomId, productId: String(productId))
//            }
//        }
//    }
//    
//    // MARK: - Handle Socket Pin Update
//    private func handleSocketPinUpdate(productId: String, isPinned: Bool) {
//        guard let id = Int(productId) else { return }
//        
//        if isPinned {
//            pinnedProductIds.insert(id)
//        } else {
//            pinnedProductIds.remove(id)
//        }
//    }
//    
//    private func resetData() {
//        productDataFromAPI = []
//        currentPage = 1
//        canLoadMore = true
//        isFetchingMore = false
//        pinnedProductIds.removeAll() // Clear pinned products on reset
//    }
//    
//    func fetchProduct(isLoaderShown: Bool = true) {
//        Task {
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
//                        secondaryBtnText: ""
//                    )
//                    showError = true
//                },
//                onSuccess: {
//                    productSuccess()
//                }
//            ) {
//                let request = ProductRequest(
//                    search: searchText,
//                    category_ids: categoryId,
//                    page: currentPage
//                )
//                try await productViewModel.getProductsData1(parameters: request)
//            }
//        }
//    }
//    
//    func handlePagination(index: Int) {
//        guard canLoadMore, !isFetchingMore else { return }
//        guard totalCount > (index + 1) else { return }
//        let thresholdIndex = sortedProducts.count - 1
//        if index == thresholdIndex {
//            isFetchingMore = true
//            currentPage += 1
//            fetchProduct(isLoaderShown: false)
//        }
//    }
//    
//    // MARK: - Product Success
//    func productSuccess() {
//        let response = productViewModel.productsResponse1
//        if response?.status == "success" {
//            let newItems = response?.data ?? []
//            totalCount = response?.total ?? 0
//            if newItems.isEmpty {
//                canLoadMore = false
//            } else {
//                productDataFromAPI.append(contentsOf: newItems)
//            }
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
//        isFetchingMore = false
//    }
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
//// MARK: - Product List Item
//struct ProductRehearsalListItem: View {
//    let product: ProductDataModel1
//    let isPinned: Bool
//    let isInEvent: Bool
//    let onPinToggle: () -> Void
//    
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
//                    Text("\(product.category?.name ?? "N/A")")
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
//                // Buy Now button with Pin Icon
//                HStack(spacing: 8) {
//                    Button(action: {}) {
//                        Text("Start Auction")
//                            .font(.custom("Poppins-SemiBold", size: 15))
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 10)
//                            .background(Color(.sRGB, red: 0.98, green: 0.96, blue: 0.95))
//                            .clipShape(RoundedRectangle(cornerRadius: 22))
//                    }
//                    .foregroundColor(.black.opacity(0.85))
//                    
//                    // Pin Button - Always visible, changes state based on pinning
//                    Button(action: onPinToggle) {
//                        Image(systemName: isPinned ? "pin.circle.fill" : "pin.circle")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 28, height: 28)
//                            .foregroundColor(isPinned ? .defaultTheme : .gray.opacity(0.4))
//                    }
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
//
//// MARK: - Socket Manager Extension
//extension SocketManagerService {
//    // MARK: - Emit Event: Pin Product
//    func sendPinProduct(roomId: String, productId: String) {
//        let payload: [String: Any] = [
//            "room_id": roomId,
//            "product_id": productId
//        ]
//        
//        performIfConnected {
//            socket.emit("pin_product", payload)
//            logger.info("📤 Sent pin_product: \(payload)")
//        }
//    }
//    
//    // MARK: - Emit Event: Unpin Product
//    func sendUnpinProduct(roomId: String, productId: String) {
//        let payload: [String: Any] = [
//            "room_id": roomId,
//            "product_id": productId
//        ]
//        
//        performIfConnected {
//            socket.emit("unpin_product", payload)
//            logger.info("📤 Sent unpin_product: \(payload)")
//        }
//    }
//    
//    // MARK: - Listen: Product Pinned Status
//    func listenForPinnedProductStatus(completion: @escaping (_ productId: String, _ isPinned: Bool) -> Void) {
//        socket.on("product_pinned") { data, _ in
//            guard let json = data.first as? [String: Any] else {
//                self.logger.warning("⚠️ Invalid product_pinned payload: \(data)")
//                return
//            }
//            
//            let productId = json["product_id"] as? String ?? ""
//            let pinned = json["pinned"] as? Bool ?? false
//            
//            DispatchQueue.main.async {
//                completion(productId, pinned)
//            }
//            
//            self.logger.info("✅ product_pinned received → productId=\(productId), pinned=\(pinned)")
//        }
//    }
//}
//
//// MARK: - Color Extension
//extension Color {
//    static let defaultTheme = Color(red: 40/255, green: 100/255, blue: 200/255)
//}
