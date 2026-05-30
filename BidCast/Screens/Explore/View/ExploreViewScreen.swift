//
//  ExploreViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD

struct ExploreViewScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var tabBarRouter: TabBarRouter
    
    // CRASH FIX: was a plain `var` — re-created on every SwiftUI re-render,
    // so in-flight async responses could land on a discarded instance.
    // `@StateObject` ensures one stable instance for the view's lifetime.
    @StateObject var viewModel = SelectCategoryViewModel()
    
    @State var selectedCategoryIndex = 0
    var categoryTitles = ["Recommended", "Popular", "All"]
    @State var category: String = ""
    @State var subCategory: String = ""
    @State var navigateToCategoryDetailScreen = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var searchText: String = ""
    @State private var navigateToSearchResults = false

    // MC cmpfokdvh000zoohgznjjw726 (Trey 2026-05-21): Search results row taps.
    // ProfileScreen wants a @Binding String id, ProductDetailView wants @Binding Int.
    @State private var navigateToSearchProfile: Bool = false
    @State private var navigateToSearchProduct: Bool = false
    @State private var searchSelectedUserId: String = ""
    @State private var searchSelectedUserName: String = ""
    @State private var searchSelectedUserImage: String = ""
    @State private var searchSelectedProductId: Int = 0
    @State private var searchSelectedSellerInfo: SellerInfoResponse? = nil

    @State var categoryList = [CategoryDataModel]()
    @State var navigateToNoti: Bool = false
    @State var isLoadingAPI: Bool = true
    
    @State private var expandedCategoryIndex: Int? = nil
    @State private var subCategoryCache: [String: [SelectedSubCategoryDataModel]] = [:]
    @State var loadingSubCategoryId: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                SearchBarView(placeholder: "What are you looking for?") { debouncedText in
                    self.searchText = debouncedText
                    if !debouncedText.isEmpty {
                        self.navigateToSearchResults = true
                    } else {
                        // Optionally, refresh the category list when search is cleared
                        let selectedCategory = categoryTitles[selectedCategoryIndex]
                        Task { await fetchCategory(for: selectedCategory) }
                    }
                }
                HeaderMenuIconView(didTapMenuButton: {
                    print("Menu Button Tapped")
                    navigateToNoti = true
                }, count: .constant(0))
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(.white)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    
                    PillsSelectorView(titles: categoryTitles,
                                      selectedIndex: $selectedCategoryIndex,
                                      backgroundStyle: .pill,
                                      underlineEnabled: false,
                                      onSelectionChanged: { index, data in
                        let selectedCategory = categoryTitles[index]
                        Task {
                            await fetchCategory(for: selectedCategory)
                        }
                    })

                    // Basecamp #9933973683 (2026-05-29 RETURN): Flash Sales
                    // section. PWA shows a ⚡ Flash Sales row on explore;
                    // iOS was missing it entirely. Fetches from the confirmed
                    // GET /api/product/flash-sales endpoint (authed, returns
                    // cross-seller time-windowed items).
                    FlashSalesSectionView(
                        products: viewModel.flashSaleProducts,
                        isLoading: viewModel.isLoadingFlashSales
                    )

                    if isLoadingAPI {
                        // FULL CARD SHIMMER
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(0..<12, id: \.self) { _ in
                                CategoryCardFullShimmerView()
                            }
                        }
                        
                    } else if !isLoadingAPI && categoryList.isEmpty {
                        // NO DATA VIEW
                        NoDataView(message: searchText.isEmpty ? "No categories found" : "No searched categories found")
                            .padding(.top, 40)
                    } else {
                        // GRID LIST WITH SUBCATEGORIES
                        LazyVStack(spacing: 16) {
                            ForEach(Array(categoryRows().enumerated()), id: \.offset) { rowIndex, row in
                                
                                // CATEGORY ROW (3 items)
                                HStack(spacing: 12) {
                                    ForEach(row, id: \.id) { category in
                                        let isSelected = expandedCategoryIndex == categoryList.firstIndex(where: { $0.id == category.id })
                                        CategoryCardView(
                                            title: category.name ?? "",
                                            imageURL: category.image ?? "",
                                            liveCount: category.liveCount ?? 0,
                                            isSelected: isSelected
                                        )
                                        .onTapGesture {
                                            if let index = categoryList.firstIndex(where: { $0.id == category.id }) {
                                                handleCategoryTap(index)
                                            }
                                        }
                                    }
                                    if row.count < 3 {
                                           Spacer() // keeps items leading
                                       }
                                }
                                
                                // INLINE SUBCATEGORY VIEW
                                // CRASH FIX: guard expandedIndex is still
                                // within bounds (it may lag behind a search
                                // that just cleared categoryList).
                                if let expandedIndex = expandedCategoryIndex,
                                   expandedIndex < categoryList.count,
                                   expandedIndex / 3 == rowIndex {
                                    
                                    let categoryId = categoryList[expandedIndex].id ?? 0
                                    let key = "\(categoryId)"
                                    let categoryName = categoryList[expandedIndex].name ?? ""
                                    if let subCache = subCategoryCache[key], !subCache.isEmpty {
                                        // FIX cmp424ztk00sm4axyuk9psh8q: horizontal chip row
                                        SubCategoryListView(
                                            isLoading: loadingSubCategoryId == key,
                                            subCategories: subCategoryCache[key] ?? [],
                                            parentCategory: categoryName,
                                            viewersCount: 0,
                                            onSubCategoryTap: { subCat in
                                                // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14):
                                                // Don't push HomeViewScreen inside the Explore
                                                // tab's NavigationView — that triggers iOS's
                                                // default hidesBottomBarWhenPushed and the
                                                // tab bar disappears. Instead, hand the filter
                                                // off to TabBarRouter and switch to the Home
                                                // tab. The Home tab keeps its own NavigationView
                                                // stack and the bottom tab bar stays visible.
                                                category = categoryName
                                                if subCat.id == -1 {
                                                    subCategory = ""   // 🔥 All selected
                                                } else {
                                                    subCategory = subCat.name ?? ""
                                                }
                                                tabBarRouter.pendingHomeCategory = category
                                                tabBarRouter.pendingHomeSubCategory = subCategory
                                                tabBarRouter.pendingHomeFilterFromExplore = true
                                                // Collapse the inline subcategory drawer so we
                                                // don't reopen it on return.
                                                expandedCategoryIndex = nil
                                                tabBarRouter.selectedTab = 0
                                            }
                                        )
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .top)),
                                            removal: .opacity
                                        ))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
            .background(.backGround)
            
            // Navigation Links
            //
            // MC sub-task cmp49377u00mb3mx117bl0r4x (Trey 2026-05-13):
            // when the user drilled into an Explore category, SwiftUI's
            // default push behaviour was hiding the bottom tab bar because
            // the destination didn't explicitly opt-in to keep the tab bar
            // visible. .toolbar(.visible, for: .tabBar) on the destination
            // restores the tab bar during category drill-in without
            // affecting other CusNavLink sites elsewhere in the app.
            CusNavLink(doNavigate: $navigateToCategoryDetailScreen,
                       destination: HomeViewScreen(showCategory: $category,
                                                   showSubCategory: $subCategory,
                                                   comeFromExploreScreen: $navigateToCategoryDetailScreen)
                        .toolbar(.visible, for: .tabBar))
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
            
            // Link to Search Results
            // MC cmpfokdvh000zoohgznjjw726 (Trey 2026-05-21): wire Users and
            // Products row taps to existing ProfileScreen / ProductDetailView
            // destinations. Show row taps still rely on deepLinkShowId
            // plumbing that Explore doesn't yet have — left as a follow-up.
            NavigationLink(
                destination: SearchResultsView(
                    initialQuery: searchText,
                    onUserTap: { userId in
                        searchSelectedUserId = String(userId)
                        searchSelectedUserName = ""
                        searchSelectedUserImage = ""
                        navigateToSearchProfile = true
                    },
                    onProductTap: { productId in
                        searchSelectedProductId = productId
                        searchSelectedSellerInfo = nil
                        navigateToSearchProduct = true
                    }
                ),
                isActive: $navigateToSearchResults
            ) {
                EmptyView()
            }

            // Search-result destinations.
            CusNavLink(
                doNavigate: $navigateToSearchProfile,
                destination: ProfileScreen(
                    id: $searchSelectedUserId,
                    isComeFrom: .constant("Search"),
                    userName: $searchSelectedUserName,
                    userImage: $searchSelectedUserImage
                )
            )
            CusNavLink(
                doNavigate: $navigateToSearchProduct,
                destination: ProductDetailView(
                    productID: $searchSelectedProductId,
                    sellerInfo: $searchSelectedSellerInfo
                )
            )
        }
        .background(.backGround)
        .padding(.bottom, -27)
        .onFirstAppear {
            let initialTab = tabBarRouter.exploreInitialTab
            if initialTab != 0 {
                selectedCategoryIndex = initialTab
                tabBarRouter.exploreInitialTab = 0
            }
            let selectedCategory = categoryTitles[selectedCategoryIndex]
            Task { await fetchCategory(for: selectedCategory) }
            // Basecamp #9933973683 (2026-05-29 RETURN): load flash sales once
            // on first appear so the section is populated immediately.
            Task { await viewModel.fetchFlashSaleProducts() }
        }
        // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14): also consume a
        // pending exploreInitialTab on every .onAppear (not just
        // .onFirstAppear). The Explore view stays alive across tab
        // switches, so .onFirstAppear only fires once — the second time
        // the user taps 'See All Categories' on Home we need to re-apply
        // the requested segment (All = index 2) here too.
        .onAppear {
            let initialTab = tabBarRouter.exploreInitialTab
            guard initialTab != 0 else { return }
            selectedCategoryIndex = initialTab
            tabBarRouter.exploreInitialTab = 0
            let selectedCategory = categoryTitles[selectedCategoryIndex]
            Task { await fetchCategory(for: selectedCategory) }
        }
        .onChange(of: tabBarRouter.exploreInitialTab) { _, newVal in
            guard newVal != 0 else { return }
            selectedCategoryIndex = newVal
            tabBarRouter.exploreInitialTab = 0
            let selectedCategory = categoryTitles[selectedCategoryIndex]
            Task { await fetchCategory(for: selectedCategory) }
        }
        // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14): When the user
        // drills into a category from the Explore tab the destination
        // HomeViewScreen is pushed via NavigationLink(isActive:) inside the
        // Explore tab's NavigationView. If the user then switches to the
        // Home tab while that push is active, iOS leaks the pushed view's
        // toolbar state (which includes the .toolbar(.visible, for: .tabBar)
        // modifier we added in an earlier fix) into sibling tabs, causing
        // the bottom tab bar to stop rendering on the Home tab. Dismiss the
        // Explore drill-in push the moment the user leaves the Explore tab
        // so the NavigationView state is clean when they return.
        .onChange(of: tabBarRouter.selectedTab) { _, newTab in
            if newTab != 1 {
                // User navigated away from Explore — collapse the drill-in
                // push so the Explore NavigationView stack is clean and its
                // toolbar state does not bleed into the new tab.
                navigateToCategoryDetailScreen = false
                expandedCategoryIndex = nil
            }
        }
    }
    
    // MARK: - API Calls
    
    func fetchCategory(for tab: String) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        isLoadingAPI = true
        // CRASH FIX (cmp3q3ilb00814axyrxdg91de): reset expandedCategoryIndex
        // before clearing categoryList. The inline subcategory view accesses
        // categoryList[expandedCategoryIndex!] during re-render; if the index
        // is not cleared before removeAll(), SwiftUI renders with the stale
        // index into an empty array → fatal index-out-of-bounds crash on search.
        expandedCategoryIndex = nil
        subCategoryCache.removeAll()
        categoryList.removeAll()
        
        await viewModel.getCategoryList(param: CategoryRequest(category_id: "", type: tab.lowercased(), search: searchText))
        success()
    }
    
    func success() {
        let response = viewModel.categoryResponse
        if response.status == "success" {
            self.categoryList = response.data ?? []
            isLoadingAPI = false
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
    
    func categoryRows() -> [[CategoryDataModel]] {
        stride(from: 0, to: categoryList.count, by: 3).map {
            Array(categoryList[$0..<min($0 + 3, categoryList.count)])
        }
    }
    
    func handleCategoryTap(_ index: Int) {
        let categoryId = categoryList[index].id ?? 0
        let categoryName = categoryList[index].name ?? ""
        
        // Collapse if same category tapped again
        if let expInd = expandedCategoryIndex, expInd == index {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                expandedCategoryIndex = nil
            }
            return
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            expandedCategoryIndex = index
        }
        
        // USE CACHE IF AVAILABLE
        if let cachedSubCategories = subCategoryCache["\(categoryId)"], !cachedSubCategories.isEmpty {
            print("Using cached subcategories for \(categoryId)")
            return
        }
        
        loadingSubCategoryId = "\(categoryId)"
        
        Task {
           
            await fetchSubCategories(categoryId: "\(categoryId)", categoryName: categoryName)
            
        }
    }
//    func fetchSubCategories(categoryId: String, categoryName: String) async {
//
//        let param: [String: Any] = [
//            "category_ids": [categoryId]
//        ]
//
//        loadingSubCategoryId = categoryId
//        SVProgressHUD.show()
//
//        await viewModel.getSubCategoryList1(param: param)
//
//        await SVProgressHUD.dismiss()
//        loadingSubCategoryId = nil
//
//        guard viewModel.subCategoryResponse?.status == "success" else {
//            return
//        }
//
//        let subCats = viewModel.subCategoryResponse?.data ?? []
//
//        guard let apiSubCategories = subCats.first?.subcategories else {
//            return
//        }
//
//        // 🔥 Create "All" subcategory
//        let allSubCategory = SelectedSubCategoryDataModel(
//            id: -1,
//            name: "All",
//            image: categoryList.first { "\($0.id ?? 0)" == categoryId }?.image
//        )
//
//        // 🔥 Insert "All" at first index
//        let finalSubCategories = [allSubCategory] + apiSubCategories
//
//        subCategoryCache[categoryId] = finalSubCategories
//    }
    func fetchSubCategories(categoryId: String, categoryName: String) async {

        let param = [
            "category_ids": [categoryId]
        ]

        SVProgressHUD.show()
        await viewModel.getSubCategoryList1(param: param)
        await SVProgressHUD.dismiss()

        guard viewModel.subCategoryResponse?.status == "success" else {
            loadingSubCategoryId = nil
            return
        }

        let subCats = viewModel.subCategoryResponse?.data ?? []

        if let apiSubCategories = subCats.first?.subcategories {

            if !apiSubCategories.isEmpty {

                // 🔹 Create "All" subcategory
                let allSubCategory = SelectedSubCategoryDataModel(
                    id: -1,
                    name: "All",
                    image: categoryList.first { "\($0.id ?? 0)" == categoryId }?.image
                )

                // 🔹 Insert "All" at first index
                let finalList = [allSubCategory] + apiSubCategories

                // 🔹 Save to cache
                subCategoryCache[categoryId] = finalList

            } else {
                // No subcategories → hand off to Home tab via TabBarRouter.
                // (MC cmp5czpw900jo56kdn739kkjp — see onSubCategoryTap closure
                // for the rationale on tab-switch vs push.)
                subCategoryCache[categoryId] = []
                expandedCategoryIndex = nil
                category = categoryName
                subCategory = ""
                tabBarRouter.pendingHomeCategory = category
                tabBarRouter.pendingHomeSubCategory = subCategory
                tabBarRouter.pendingHomeFilterFromExplore = true
                tabBarRouter.selectedTab = 0
            }

        } else {
            // No subcategory key → hand off to Home tab via TabBarRouter.
            // (MC cmp5czpw900jo56kdn739kkjp)
            subCategoryCache[categoryId] = []
            expandedCategoryIndex = nil
            category = categoryName
            subCategory = ""
            tabBarRouter.pendingHomeCategory = category
            tabBarRouter.pendingHomeSubCategory = subCategory
            tabBarRouter.pendingHomeFilterFromExplore = true
            tabBarRouter.selectedTab = 0
        }

        loadingSubCategoryId = nil
    }

}

// MARK: - SubCategory List View
// FIX cmp424ztk00sm4axyuk9psh8q: vertical list where each row is
// [image] [name] side-by-side — compact rows, no extra height.
struct SubCategoryListView: View {
    let isLoading: Bool
    let subCategories: [SelectedSubCategoryDataModel]
    let parentCategory: String
    let viewersCount: Int
    let onSubCategoryTap: ((SelectedSubCategoryDataModel) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ForEach(0..<3) { _ in
                    SubCategoryShimmerRow()
                    Divider().padding(.leading, 56)
                }
            } else {
                ForEach(Array(subCategories.enumerated()), id: \.element.id) { index, subCategory in
                    SubCategoryRow(
                        viewersCount: viewersCount,
                        subCategory: subCategory,
                        onSubCategoryTap: { onSubCategoryTap?(subCategory) }
                    )
                    if index < subCategories.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, 4)
    }
}

// MARK: - SubCategory Row
struct SubCategoryRow: View {
    let viewersCount: Int
    let subCategory: SelectedSubCategoryDataModel
    let onSubCategoryTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            onSubCategoryTap()
        } label: {
            rowContent
        }
        .buttonStyle(PlainButtonStyle()) // ✅ prevents default blue tint
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .shadow(
            color: isPressed ? Color.defaultTheme.opacity(0.15) : Color.black.opacity(0.06),
            radius: isPressed ? 8 : 4,
            x: 0,
            y: isPressed ? 4 : 2
        )
    }

    // FIX cmp424ztk00sm4axyuk9psh8q: compact row — [image] [name] side by side.
    // Vertical list, each row is one line: small image left, name right.
    private var rowContent: some View {
        HStack(spacing: 10) {
            CustomProfileImage(
                url: subCategory.image ?? "",
                isCircular: false,
                cornerRadius: 6,
                size: 36,
                defaultImage: "photo"
            )
            .frame(width: 36, height: 36)

            Text(subCategory.name ?? "Unknown")
                .font(.custom(poppinsSemiBold, size: 15))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private var viewersBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .foregroundColor(.red)
                .font(.system(size: 11, weight: .bold))

            Text("\(viewersCount) Viewers")
                .font(.custom(poppinsMedium, size: 12))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
            Image(systemName: "photo")
                .foregroundColor(.gray.opacity(0.5))
        }
        .frame(width: 50, height: 50)
    }
}


// MARK: - SubCategory Shimmer Row
struct SubCategoryShimmerRow: View {
    var body: some View {
        // Shimmer row: [image placeholder] [text placeholder]
        HStack(spacing: 10) {
            ShimmerView()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            ShimmerView()
                .frame(width: 120, height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}


// MARK: - Flash Sales Section (Basecamp #9933973683, 2026-05-29 RETURN)
// Displays a horizontal scroll row of active flash-sale products on the
// Explore page, matching the PWA ⚡ Flash Sales section. Data source:
// GET /api/product/flash-sales (listFlashSales controller).
struct FlashSalesSectionView: View {
    let products: [FlashSaleProduct]
    let isLoading: Bool

    var body: some View {
        // Don't render the section if there's nothing (and not loading)
        if isLoading || !products.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("⚡ Flash Sales")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 4)

                if isLoading {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { _ in
                                ShimmerView()
                                    .frame(width: 140, height: 190)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(products) { product in
                                FlashSaleProductCard(product: product)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct FlashSaleProductCard: View {
    let product: FlashSaleProduct

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Product image
            CustomProfileImage(
                url: product.thumbUrl ?? "",
                isCircular: false,
                cornerRadius: 10,
                size: 140
            )
            .frame(width: 140, height: 120)
            .clipped()

            // Title
            Text(product.title ?? "")
                .font(.custom(poppinsSemiBold, size: 12))
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(width: 130, alignment: .leading)

            // Pricing row
            // waveD FIX-1 (2026-05-30): pricing / flash_sale_price are now String?
            // (backend returns them as JSON strings). Parse to Double before compare/format.
            HStack(spacing: 4) {
                let saleVal = Double(product.flash_sale_price ?? "")
                let origVal = Double(product.pricing ?? "")
                if let salePrice = saleVal, salePrice > 0 {
                    Text(String(format: "$%.2f", salePrice))
                        .font(.custom(poppinsBold, size: 13))
                        .foregroundColor(.red)
                    if let original = origVal, original > 0 {
                        Text(String(format: "$%.2f", original))
                            .font(.custom(poppinsRegular, size: 11))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                } else if let price = origVal {
                    Text(String(format: "$%.2f", price))
                        .font(.custom(poppinsBold, size: 13))
                        .foregroundColor(.primary)
                }
            }

            // Countdown badge
            if let endsStr = product.flash_sale_ends_at {
                FlashCountdownBadge(endsAtISO: endsStr)
            }
        }
        .frame(width: 140)
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// Small countdown badge that shows remaining time on a flash sale card.
struct FlashCountdownBadge: View {
    let endsAtISO: String
    @State private var remaining: String = ""
    @State private var timer: Timer? = nil

    var body: some View {
        Text(remaining.isEmpty ? "⚡ Sale" : "⏱ \(remaining)")
            .font(.custom(poppinsRegular, size: 10))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.orange)
            .cornerRadius(6)
            .onAppear { startCountdown() }
            .onDisappear { timer?.invalidate(); timer = nil }
    }

    private func startCountdown() {
        updateRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            updateRemaining()
        }
    }

    private func updateRemaining() {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = fmt.date(from: endsAtISO)
            ?? ISO8601DateFormatter().date(from: endsAtISO)
        guard let end = date else { remaining = "⚡ Sale"; return }
        let diff = end.timeIntervalSinceNow
        if diff <= 0 { remaining = "Ended"; return }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if hours >= 24 {
            remaining = "\(hours / 24)d \(hours % 24)h"
        } else if hours > 0 {
            remaining = "\(hours)h \(minutes)m"
        } else {
            remaining = "\(minutes)m"
        }
    }
}
