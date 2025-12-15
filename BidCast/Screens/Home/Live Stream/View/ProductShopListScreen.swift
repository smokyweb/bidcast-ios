//
//  ProductShopListScreen.swift
//  BidCast
//
//  Created by JamTech on 24/11/25.
//
import SwiftUI
import SVProgressHUD

// MARK: - Image Loader
final class LocalImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    func load(fromFilePath path: String?, defaultName: String = "default_product") {
        guard let path = path else {
            image = UIImage(named: defaultName)
            return
        }
        let url = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: url), let ui = UIImage(data: data) {
            image = ui
        } else {
            image = UIImage(named: defaultName)
        }
    }
}

// MARK: - Shimmer Modifier
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    var isActive: Bool
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { proxy in
                        let gradient = LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.25)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Rectangle()
                            .fill(gradient)
                            .rotationEffect(.degrees(0))
                            .offset(x: -proxy.size.width * 1.5 + phase * proxy.size.width * 3)
                    }
                    .clipped()
                )
                .mask(content)
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func shimmer(if active: Bool) -> some View {
        modifier(Shimmer(isActive: active))
    }
}

// MARK: - Product List Item
struct ProductListItem: View {
    @Binding var product: ProductDataModel
    @State private var showBadge = true
    
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
                
                // Bell badge
                if showBadge {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black.opacity(0.85))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 0.6))
                        .padding(.trailing, 6)
                        .padding(.top, 6)
                }
            }
            
            // MARK: - Right Content
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title ?? "Product")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text("Quantity: \(product.quantity ?? "0")")
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

                    Text("• Ships from United States")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.gray)
                }

//                // Buy Now button
//                Button(action: {}) {
//                    Text("Buy Now")
//                        .font(.custom("Poppins-SemiBold", size: 15))
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 10)
//                        .background(Color(.sRGB, red: 0.98, green: 0.96, blue: 0.95))
//                        .clipShape(RoundedRectangle(cornerRadius: 22))
//                }
//                .foregroundColor(.black.opacity(0.85))
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

// MARK: - Product List Heading
struct ProductListHeading: View {
    let count: Int
    
    var body: some View {
        Text("Products (\(count))")
            .font(.custom("Poppins-Bold", size: 20))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
    }
}

// MARK: - Main Screen
struct ProductShopListScreen: View {
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
    
    @State var productData: [ProductDataModel] = []
//    @State var categoryId: String = "-1"
    @State var sellerId: String = "-1"
    @State var currentPage: Int = 1
    
    var options:[String] = ["Sort", "Auction", "Buy Now"]
    
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
            
            // MARK: - Pills Selector
            PillsSelectorView(
                titles: options,
                selectedIndex: $selectedIndex,
                backgroundStyle: .roundedRect,
                underlineEnabled: false,
                showFilterButton: false,
                showSortDropdown: true,
                onSelectionChanged: { index, title in
                    // Show sort sheet when "Sort" is tapped
                    if index == 0 {
                        showSortSheet = true
                        selectedOptions = "newest"
                    }
                    else if index == 1 {
                        resetData()
                        selectedOptions = "auction"
                        fetchProduct()
                    }
                    else if index == 2 {
                        resetData()
                        selectedOptions = "accept_offers"
                        fetchProduct()
                    }
                }
            )
            
            // MARK: - Heading
            ProductListHeading(count: productData.count)
            
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
                            ProductListItem(product: $productData[index])
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

extension ProductShopListScreen {
    
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
                                             search: searchText, page: currentPage,
                                             //                               type: "live",
                                             sale_type: selectedOptions,
                                             sort_by: selectedSort
                )
                try await productViewModel.getProductsData(parameters: request)
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
        let response = productViewModel.productsResponse
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
