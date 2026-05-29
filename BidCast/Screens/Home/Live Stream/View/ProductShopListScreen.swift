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
        if let data = try? Data(contentsOf: url),
           let ui = UIImage(data: data) {
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
                .overlay {
                    GeometryReader { proxy in
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.25)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .offset(x: -proxy.size.width * 1.5 + phase * proxy.size.width * 3)
                    }
                }
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
    @Binding var product: ProductDataModel1
    var didSelectproduct: () -> Void = {}

    var body: some View {
        HStack(alignment: .center, spacing: 12) {

            // Image
            ZStack(alignment: .topTrailing) {
                CustomProfileImage(
                    url: product.images?.first ?? "",
                    isCircular: false,
                    cornerRadius: 12,
                    size: 100,
                    height: 100,
                    defaultImage: "photo"
                ) {}

                Image(systemName: "bell.fill")
                    .renderingMode(.template)
                    .foregroundColor(.defaultTheme)
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.defaultThemeLight)
                    .clipShape(Circle())
                    .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 0.6))
                    .padding(6)
            }

            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title?.capitalizingFirstLetter() ?? "Product")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .lineLimit(2)

                Text("Quantity: \(product.quantity ?? "0")")
                    .font(.custom(poppinsSemiBold, size: 13))
                    .foregroundColor(.gray)

                Text(Double(product.pricing ?? "0")?.compactCurrency() ?? "")
                    .font(.custom(poppinsSemiBold, size: 14))
            }

            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .onTapGesture { didSelectproduct() }
    }
}

// MARK: - Heading
struct ProductListHeading: View {
    let count: Int

    var body: some View {
        Text("Products (\(count))")
            .font(.custom("Poppins-Bold", size: 20))
            .padding(.leading, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Main Screen
struct ProductShopListScreen: View {

    // MARK: - State
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""
    @State private var selectedIndex = 0
    @State private var selectedSort = "newest"
    @State private var selectedOptions = ""

    @State private var isLoading = false
    @State private var isFetchingMore = false
    @State private var canLoadMore = true

    @State private var currentPage = 1
    @State private var totalCount = 0

    @State private var showSortSheet = false

    @State private var productData: [ProductDataModel1] = []

    @State private var viewModel = ScheduleViewModel()
    @State private var productViewModel = ProductViewModel()

    @Binding var sellerId: String
    @Binding var categoryIds: Int
    // Basecamp #9943369910 (2026-05-29): numeric show ID (schedule_shows.id)
    // used to scope the product query to only items added to THIS show.
    // Default empty string so callers that don't have a show context (e.g.
    // ProfileScreen → seller shop view) still compile and load the full
    // catalog as before.
    var scheduleShowId: String = ""

    private let options = ["Sort", "Auction", "Buy Now"]

    // MARK: - Body
    var body: some View {
        VStack(spacing: 12) {

            searchBarSection

            pillsSection

            ProductListHeading(count: productData.count)

            productListSection

            Spacer(minLength: 0)
        }
        .background(Color(.systemBackground))
        .onAppear { fetchProduct() }
        .onDisappear { resetData() }
        .onChange(of: selectedSort) { _ in
            resetData()
            fetchProduct()
        }
        .bottomSheet(
            isPresented: $showSortSheet,
            height: screenHeight * 0.6,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            showTopIndicator: false
        ) {
            SortByBottomSheet(
                isPresented: $showSortSheet,
                selectedSort: $selectedSort
            )
        }
    }
}

// MARK: - Subviews
extension ProductShopListScreen {

    private var searchBarSection: some View {
        HStack {
            SearchBarView(placeholder: "Search shop...") { text in
                resetData()
                searchText = text
                fetchProduct()
            }

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .padding(.horizontal, 12)
    }

    private var pillsSection: some View {
        PillsSelectorView(
            titles: options,
            selectedIndex: $selectedIndex,
            backgroundStyle: .roundedRect,
            underlineEnabled: false,
            showFilterButton: false,
            showSortDropdown: true
        ) { index, _ in
            switch index {
            case 0:
                // MC cmp5g5h0k00qs56kd2etclc2a (Ankit 2026-05-14): the Sort
                // pill was assigning `selectedOptions = "newest"`. That
                // variable is the `sale_type` filter (valid values:
                // buy_now / auction / accept_offers) — putting "newest"
                // there made every subsequent fetchProduct() send
                // sale_type=newest, which the server rejects as an invalid
                // filter and returns zero rows. The Sort pill should ONLY
                // open the sort sheet; the actual sort value is handled by
                // selectedSort + .onChange below.
                showSortSheet = true
            case 1:
                resetData()
                selectedOptions = "auction"
                fetchProduct()
            case 2:
                resetData()
                selectedOptions = "accept_offers"
                fetchProduct()
            default:
                break
            }
        }
    }

    private var productListSection: some View {
        ScrollView {
            LazyVStack {
                if isLoading {
                    shimmerList
                } else if productData.isEmpty {
                    NoDataView(message: "No Product Found")
                } else {
                    productItems
                }

                if isFetchingMore {
                    ProgressView().padding()
                }
            }
        }
    }

    private var shimmerList: some View {
        ForEach(0..<8, id: \.self) { _ in
            PurchasesViewShimmerView()
                .padding(.horizontal)
        }
    }

    private var productItems: some View {
        ForEach(productData.indices, id: \.self) { index in
            ProductListItem(product: $productData[index])
                .onAppear { handlePagination(index: index) }
        }
    }
}

// MARK: - API & Pagination
extension ProductShopListScreen {

    private func resetData() {
        productData.removeAll()
        currentPage = 1
        canLoadMore = true
        isFetchingMore = false
    }

    private func fetchProduct(isLoaderShown: Bool = true) {
        guard sellerId != "-1" else { return }

        // MC cmp5g5h0k00qs56kd2etclc2a (Ankit 2026-05-14): viewers joining a
        // live show were seeing an empty product list. Root cause was the
        // `categoryIds` binding flowing in here as `0` (the default for
        // `LiveStream.categoryId` when the room's first product had no
        // category or no products were loaded yet) — the server returns
        // zero rows when filtered by category_ids = "0". When we don't
        // have a real category (<= 0), send an empty string so the seller's
        // full inventory comes back instead of a filtered-empty list.
        let categoryFilter: String = categoryIds > 0 ? "\(categoryIds)" : ""

        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: isLoaderShown,
                onError: { _ in
                    canLoadMore = false
                    isFetchingMore = false
                },
                onSuccess: {
                    productSuccess()
                }
            ) {
                let request = ProductRequest(
                    user_id: sellerId,
                    search: searchText,
                    category_ids: categoryFilter,
                    page: currentPage,
                    sale_type: selectedOptions,
                    sort_by: selectedSort,
                    // Basecamp #9943369910: pass show scope when available.
                    show_id: scheduleShowId.isEmpty ? nil : scheduleShowId
                )
                try await productViewModel.getProductsData1(parameters: request)
            }
        }
    }

    private func handlePagination(index: Int) {
        guard canLoadMore, !isFetchingMore else { return }
        guard index == productData.count - 1 else { return }

        isFetchingMore = true
        currentPage += 1
        fetchProduct(isLoaderShown: false)
    }

    private func productSuccess() {
        let response = productViewModel.productsResponse1
        let newItems = response?.data ?? []

        totalCount = response?.total ?? 0

        if newItems.isEmpty {
            canLoadMore = false
        } else {
            productData.append(contentsOf: newItems)
        }

        isFetchingMore = false
    }
}
