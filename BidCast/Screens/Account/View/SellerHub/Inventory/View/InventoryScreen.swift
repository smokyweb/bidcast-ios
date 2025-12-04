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
    
    @State var inventoryList: [InventoryDataModel] = []
    @State var request: InventoryRequest = InventoryRequest(status: "active", page: 1)
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var viewModel = InventoryViewModel()
    @State var productId : Int = 0
    @State var showError: Bool = false
    @State var isLoading: Bool = true
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var status = "active"
    @State var currentPage = 1
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showSellSheet = false
    @State var productData : InventoryDataModel
    @State var navigateToCreateProduct = false
    @State var navigateToEditProduct = false
    @State var searchText: String = ""
    
    @Binding var selectedProductIDs: Set<String>
    @Binding var selectedProductData: [ProductDataModel]
    @State var productToEdit: ProductDataModel = ProductDataModel()
    @StateObject var categoryViewModel = ListProductViewModel()
    @State var categoryList: [CategoryDataModel] = []
    @State var selectedCategoryId: String = ""
    
    var navigatedFrom: InventoryNavigation = .account
    @State private var navigateToCreateNewProduct = false
    
    @State private var selectedIndex: Int = 0
    @State private var showFilterSheet: Bool = false
    
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
           
            InventoryTabView(selectedTab: $segment)
            
//            // MARK: - Search
            SearchView { debouncedText in
                print("User stopped typing. Search: \(debouncedText)")
                guard !debouncedText.isEmpty else {
                    return
                }
                // Perform search logic here
                searchText = debouncedText
                currentPage = 1
                self.inventoryList.removeAll()
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
                            handleDataLoad()
                        }
                        
                    ) {
                        try await fetchInventory(for: segment, page: 1)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            // MARK: - Pills Selector
            PillsSelectorView(
                titles: [],
                selectedIndex: $selectedIndex,
                backgroundStyle: .roundedRect,
                underlineEnabled: false,
                showFilterButton: true,
                showSortDropdown: false,
                onSelectionChanged: { index, title in
                    // Show sort sheet when "Sort" is tapped
//                    if index == 0 {
//                        showSortSheet = true
//                        selectedOptions = "newest"
//                    }
//                    else if index == 1 {
//                        resetData()
//                        selectedOptions = "auction"
//                        fetchProduct()
//                    }
//                    else if index == 2 {
//                        resetData()
//                        selectedOptions = "accept_offers"
//                        fetchProduct()
//                    }
                },
                onFilterTapped: {
                    print("Filter Tapped")
                    showFilterSheet = true
                }
            )
            
            // MARK: - Inventory List
            ScrollView {
                LazyVStack(spacing: 4) {
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
                        ForEach(inventoryList.indices, id: \.self) { index in
                            let inventory = inventoryList[index]
                            
                            ProductCardView(product: inventory)
                                .onAppear {
                                    handlePagination(index: index)
                                }
                        }
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 12)

            TwoButton(titleOne: navigatedFrom.btnTitle,
                    onFirstButtonClick: {
                    switch navigatedFrom {
                    case .account:
                        print("create new Prooduct")
                        navigateToCreateProduct = true
                        case .addProduct:
                            print("Select Existing Product")
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    },
                      
                      onSecButtonClick: {  },
                      firstBtnBgColor: .defaultTheme,
                      isHidefirstBtn: false,
                      isHideSecBtn: true
            )
            .padding(.top, 20)
            .padding(.bottom, -15)
            
            
            CusNavLink(doNavigate: $navigateToEditProduct, destination: EditProductScreen(productData: $productToEdit)) // for edit
            CusNavLink(doNavigate: $navigateToCreateProduct, destination: ListProductScreen(productData:.constant(productData)))
            CusNavLink(doNavigate: $navigateToCreateNewProduct,
                       destination: CreateProductScreen(requests: .constant(StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "")),
                                                        thumbNail: .constant(""),
                                                        backToPrepare: .constant(false),
                                                        fromPrepare: .constant(false),
                                                        isComeFrom: .inventry))
            CusNavLink(doNavigate: $showFilterSheet, destination: FilterPageView(categories: $categoryList))
        }
        .background(Color(.systemBackground))
        .onAppear {
            Task {
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: viewModel.errorMessage ?? categoryViewModel.errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        // On success
                        handleDataLoad()
                        categorySuccess()
                    }
                    
                ) {
                    searchText = ""
                    currentPage = 1
                    segment = .active
                    request.search = searchText
                    selectedCategoryId = navigatedFrom == .account ? "" : selectedCategoryId
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
        .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.95) {
            
            ProductDetailSheet(
                onDismiss : {
                    self.showSellSheet = false
                    productId = 0
                },
                productID: $productId,
                onTapEdit: { details  in
                    productToEdit = details.toProductDataModel()
                    navigateToEditProduct = true
                    showSellSheet = false
                },onTapDelete: {
                    SVProgressHUD.show()
                    let param = DeleteProduct(product_id: productId)
                    await viewModel.DeleteProductRequest(parameters: param)
                    await SVProgressHUD.dismiss()
                    deleteProductSuccess()
                }
            )
        }
    }
    
    func handlePagination(index: Int) {
        let isLastItem = index == inventoryList.count - 1
        let canFetchMore = (viewModel.inventoryDict?.total ?? 0) > inventoryList.count

        if isLastItem && canFetchMore {
            fetchMoreInventory()
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
    
    // MARK: - Fetch Inventory List
    func fetchInventory(for segment: InventorySegment,page: Int) async throws{
        request.status = segment.rawValue.lowercased()
        request.page = page
        request.search = searchText
        request.category = selectedCategoryId
        isLoading = true
        try await viewModel.getInventoryList(param: request)
    }
    
    // MARK: - Handle ViewModel Data
    func handleDataLoad() {

        let response = viewModel.inventoryDict
        isLoading = false
        if response?.status == "success" {
            // append new data
            if currentPage == 1  {
                self.inventoryList = response?.data ?? []
            }
            else  {
                self.inventoryList += response?.data ?? []
            }
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
    
    // MARK: - deleteProductSuccess
    func deleteProductSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.inventoryDict
        if response?.status == "success" {
            self.showSellSheet = false
            currentPage = 1
            self.inventoryList.removeAll()
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
                        handleDataLoad()
                    }
                    
                ) {
                    try await fetchInventory(for: segment, page: 1)
                }
            }
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
    func fetchMoreInventory() {
        Task {
            currentPage += 1
            request.status = status
            request.page = currentPage
            request.category = selectedCategoryId
            isLoading = true
            try await viewModel.getInventoryList(param: request)
            handleDataLoad()
        }
    }
}

// MARK: - Inventory Segment Enum
enum InventorySegment: String, CaseIterable, CustomStringConvertible {
    case active = "Active"
    case draft = "Draft"
    case inactive = "Inactive"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    static var inventorytArray: [String] {
        return Segment.allCases.map { $0.rawValue }
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
                    
                    Text("Back")
                        .font(.custom(poppinsSemiBold, size: 16))
                }
                .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Inventory")
                .font(.custom(poppinsBold, size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: {
                // Manage action
                manageBtnTapped()
            }) {
                Text("Manage")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.defaultTheme)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}


import SwiftUI

struct InventoryTabView: View {

    @Binding var selectedTab: InventorySegment
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            // MARK: - Tab Selector
            HStack(spacing: 0) {
                ForEach(InventorySegment.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
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
//
//struct ProductCardView: View {
//    let product: InventoryDataModel
//    @State private var isPressed: Bool = false
//    
//    var body: some View {
//        Button(action: {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                isPressed = true
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                    isPressed = false
//                }
//            }
//        }) {
//            HStack(spacing: 16) {
//                // MARK: - Product Image
//                ZStack(alignment: .topLeading) {
//                    AsyncImage(url: URL(string: product.images?.first ?? "")) { phase in
//                        switch phase {
//                        case .empty:
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(Color(.systemGray6))
//                                    .frame(width: 120, height: 120)
//                                
//                                ProgressView()
//                            }
//                        case .success(let image):
//                            image
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 120, height: 120)
//                                .clipShape(RoundedRectangle(cornerRadius: 16))
//                        case .failure:
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 16)
//                                    .fill(Color(.systemGray5))
//                                    .frame(width: 120, height: 120)
//                                
//                                Image(systemName: "photo")
//                                    .font(.system(size: 30))
//                                    .foregroundColor(.gray)
//                            }
//                        @unknown default:
//                            EmptyView()
//                        }
//                    }
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
//                    )
//                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
//                }
//                .frame(width: 120, height: 120)
//                
//                // MARK: - Product Details
//                VStack(alignment: .leading, spacing: 8) {
//                    // Out of Stock Badge
//                    if true { //toDo
//                        HStack(spacing: 6) {
//                            Circle()
//                                .fill(Color.red)
//                                .frame(width: 6, height: 6)
//                            
//                            Text("Out of Stock")
//                                .font(.system(size: 12, weight: .semibold))
//                                .foregroundColor(.red)
//                        }
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 6)
//                        .background(
//                            Capsule()
//                                .fill(Color.red.opacity(0.1))
//                        )
//                        .overlay(
//                            Capsule()
//                                .stroke(Color.red.opacity(0.2), lineWidth: 1)
//                        )
//                    }
//                    
//                    // Product Title
//                    Text(product.title)
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.primary)
//                        .lineLimit(2)
//                        .multilineTextAlignment(.leading)
//                    
//                    // Product Condition & Category
//                    HStack(spacing: 8) {
//                        Text("Condition")
//                            .font(.system(size: 13, weight: .medium))
//                            .foregroundColor(.secondary)
//                        
//                        Circle()
//                            .fill(Color.secondary)
//                            .frame(width: 3, height: 3)
//                        
//                        Text("Category")
//                            .font(.system(size: 13, weight: .medium))
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Spacer()
//                    
//                    // Price & Bids
//                    HStack(alignment: .bottom) {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Price")
//                                .font(.system(size: 20, weight: .bold))
//                                .foregroundColor(.primary)
//                            
//                            HStack(spacing: 4) {
//                                Image(systemName: "hammer.fill")
//                                    .font(.system(size: 11))
//                                    .foregroundColor(.secondary)
//                                
//                                Text("\("Bid Count") bids")
//                                    .font(.system(size: 13, weight: .regular))
//                                    .foregroundColor(.secondary)
//                            }
//                        }
//                        
//                        Spacer()
//                    }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(16)
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(Color(.systemBackground))
//                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//            )
//            .scaleEffect(isPressed ? 0.98 : 1.0)
//            .opacity(true ? 0.7 : 1.0) //todo
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
//}

struct ProductCardView: View {
    let product: InventoryDataModel
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button {
            animatePress()
        } label: {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private extension ProductCardView {
    var cardContent: some View {
        HStack(spacing: 16) {
            productImageView
            productDetailsView
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .opacity(false ? 0.7 : 1.0) // todo
    }
}

private extension ProductCardView {
    var productImageView: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: product.images?.first ?? "")) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    imageView(image)
                case .failure:
                    failureView
                @unknown default:
                    EmptyView()
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .frame(width: 120, height: 120)
    }
    
    var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
            ProgressView()
        }
    }
    
    func imageView(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    var failureView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray5))
            Image(systemName: "photo")
                .font(.system(size: 30))
                .foregroundColor(.gray)
        }
    }
}

private extension ProductCardView {
    var productDetailsView: some View {
        VStack(alignment: .leading, spacing: 8) {
//            badgeView
            
            Text(product.title ?? "")
                .font(.custom(poppinsBold, size: 16))
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack(spacing: 8) {
                Text("Condition")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
                
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 3, height: 3)
                
                Text("Category")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
            }
            
            Text("Quanity: 4")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
            
            priceSectionView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


private extension ProductCardView {
    var badgeView: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
            
            Text("Out of Stock")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.red)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.red.opacity(0.1)))
        .overlay(
            Capsule()
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
    }
}

private extension ProductCardView {
    var priceSectionView: some View {
        HStack(spacing: 8) {
            Text("$12.00")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
            
            Circle()
                .fill(Color.secondary)
                .frame(width: 3, height: 3)
            
            Text("Auction")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
        }
    }
}

private extension ProductCardView {
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
