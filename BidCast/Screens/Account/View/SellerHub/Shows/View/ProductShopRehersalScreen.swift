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
    
    @State private var isFetchingMore = false
    @State private var canLoadMore = true
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
     @State private var showSortSheet = false
     @State private var selectedSort: String = "newest"
    
    @State private var selectedOptions: String = ""
    
    @State private var viewModel = ScheduleViewModel()
    @State var productViewModel = ProductViewModel()
    
    @State private var totalCount = 0
    
    @Binding var productData: [ProductDataModel1]
//    @State var categoryId: String = "-1"
    var sellerId: String = "-1"
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
            // MARK: - Pills Selector
//            PillsSelectorView(
//                titles: options,
//                selectedIndex: $selectedIndex,
//                backgroundStyle: .none,
//                underlineEnabled: true,
//                showFilterButton: false,
//                showSortDropdown: false,
//                onSelectionChanged: { index, title in
//                    // Show sort sheet when "Sort" is tapped
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
//                }
//            )
            
            // MARK: - Heading
            ProductHeading(count: productData.count)
            
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {

                    if isLoading {
                        ForEach(0..<8) { _ in
                            PurchasesViewShimmerView()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                    } else if productData.isEmpty {
                        NoDataView(message: "No Product Found")
                    } else {
                        ForEach(productData.indices, id: \.self) { index in
                            ProductRehearsalListItem(product: $productData[index])
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
        .background(Color(.systemBackground))
        .onAppear {
            DispatchQueue.main.async {
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
}


extension ProductShopRehersalScreen {
    
    private func resetData() {
        productData = []
        currentPage = 1
        canLoadMore = true
        isFetchingMore = false
    }

    
    func fetchProduct(isLoaderShown: Bool = true) {
        guard sellerId != "-1" else  {
            print("Category id and user id is not present")
            isFetchingMore = false
            return
        }
        
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
                let request = ProductRequest(user_id: sellerId,
                                             search: searchText,
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
        let thresholdIndex = productData.count - 1
        if index == thresholdIndex {
            isFetchingMore = true
            currentPage += 1
            fetchProduct(isLoaderShown: false)
        }
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
                productData.append(contentsOf: newItems)
            }
        
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
                    Text("\("Category")") //toDo: static data
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.gray)

                    Text("New")
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
                    Button(action: {}) {
                        Text("Start Auction")
                            .font(.custom("Poppins-SemiBold", size: 15))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.sRGB, red: 0.98, green: 0.96, blue: 0.95))
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    }
                    .foregroundColor(.black.opacity(0.85))
                    
                    Image(systemName: "pin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.defaultTheme)
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
