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

    // MC task cmp5w1v7i019qm61hhld1uiul: state for search result navigation
    @State private var navigateToProfile = false
    @State private var navigateToProductDetail = false
    @State private var selectedUserId: String = ""
    @State private var selectedProductId: Int = 0
    @State private var selectedSellerInfo: SellerInfoResponse? = nil
    @State private var selectedUsername: String = ""
    @State private var selectedUserImage: String = ""


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
//                    if debouncedText == "" { return }
                    self.searchText = debouncedText
                    let selectedCategory = categoryTitles[selectedCategoryIndex]
                    // MC task cmp5w1v7i019qm61hhld1uiul: when the search box
                    // has text, hit the unified explore-search endpoint;
                    // when empty, fall back to category list refresh.
                    if debouncedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.exploreSearchResponse = nil
                        Task { await fetchCategory(for: selectedCategory) }
                    } else {
                        Task { await viewModel.exploreSearch(query: debouncedText) }
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

            // MC task cmp5w1v7i019qm61hhld1uiul: when the search bar has
            // text, swap the category browser for the unified explore-search
            // results.
            if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ExploreSearchResultsView(
                    shows: viewModel.exploreSearchResponse?.data?.shows ?? [],
                    products: viewModel.exploreSearchResponse?.data?.products ?? [],
                    users: viewModel.exploreSearchResponse?.data?.users ?? [],
                    onShowTap: { show in
                        // MC task cmp5w1v7i019qm61hhld1uiul: a tap on a show
                        // result card navigates to the show owner's profile.
                        if let user = show.user {
                            self.selectedUserId = "\(user.id ?? 0)"
                            self.selectedUsername = user.username ?? ""
                            self.selectedUserImage = user.profile_image ?? ""
                            self.navigateToProfile = true
                        }
                    },
                    onProductTap: { product in
                        self.selectedProductId = product.id ?? 0
                        self.selectedSellerInfo = nil // Not available in this API response
                        self.navigateToProductDetail = true
                    },
                    onUserTap: { user in
                        self.selectedUserId = "\(user.id ?? 0)"
                        self.selectedUsername = user.username ?? ""
                        self.selectedUserImage = user.profile_image ?? ""
                        self.navigateToProfile = true
                    }
                )
            } else {
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
                                        SubCategoryListView(
                                            isLoading: loadingSubCategoryId == key,
                                            subCategories: subCategoryCache[key] ?? [],
                                            parentCategory: categoryName,
                                            viewersCount: 0,
                                            onSubCategoryTap: { subCat in
//                                                category = categoryName
//                                                subCategory = subCat.name ?? ""
//                                                navigateToCategoryDetailScreen = true
                                                category = categoryName

                                                    if subCat.id == -1 {
                                                        subCategory = ""   // 🔥 All selected
                                                    } else {
                                                        subCategory = subCat.name ?? ""
                                                    }

                                                    navigateToCategoryDetailScreen = true
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
            } // end else (MC cmp5w1v7i019qm61hhld1uiul)
            
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

            // MC task cmp5w1v7i019qm61hhld1uiul: navigation for search results
            CusNavLink(doNavigate: $navigateToProfile,
                       destination: ProfileScreen(id: $selectedUserId,
                                                  isComeFrom: .constant("Home"),
                                                  userName: $selectedUsername,
                                                  userImage: $selectedUserImage))
            CusNavLink(doNavigate: $navigateToProductDetail,
                       destination: ProductDetailView(productID: $selectedProductId,
                                                      sellerInfo: $selectedSellerInfo))
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
        }
        .onChange(of: tabBarRouter.exploreInitialTab) { _, newVal in
            guard newVal != 0 else { return }
            selectedCategoryIndex = newVal
            tabBarRouter.exploreInitialTab = 0
            let selectedCategory = categoryTitles[selectedCategoryIndex]
            Task { await fetchCategory(for: selectedCategory) }
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
                // No subcategories → direct navigation
                subCategoryCache[categoryId] = []
                expandedCategoryIndex = nil
                category = categoryName
                subCategory = ""
                navigateToCategoryDetailScreen = true
            }

        } else {
            // No subcategory key → direct navigation
            subCategoryCache[categoryId] = []
            expandedCategoryIndex = nil
            category = categoryName
            subCategory = ""
            navigateToCategoryDetailScreen = true
        }

        loadingSubCategoryId = nil
    }

}

// MARK: - SubCategory List View
struct SubCategoryListView: View {
    let isLoading: Bool
    let subCategories: [SelectedSubCategoryDataModel]
    let parentCategory: String
    let viewersCount : Int
    let onSubCategoryTap: ((SelectedSubCategoryDataModel) -> Void)?
    
    var body: some View {
        VStack(spacing: 8) {
            if isLoading {
                loadingView
            } else if !subCategories.isEmpty {
                subCategoryList

            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 8) {
            ForEach(0..<2) { _ in
                SubCategoryShimmerRow()
            }
        }
    }
    
    // MARK: - SubCategory List
    private var subCategoryList: some View {
        VStack(spacing: 8) {
            ForEach(subCategories, id: \.id) { subCategory in
                SubCategoryRow(viewersCount:viewersCount,subCategory: subCategory,onSubCategoryTap: {
                   print("SubCategory clicked")
                    onSubCategoryTap?(subCategory)
                })
                
                    
            }
        }
       
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

    private var rowContent: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image
            CustomProfileImage(url: subCategory.image ?? "",isCircular: false,cornerRadius: 12,size: 50,defaultImage: "photo")
//            AsyncImage(url: URL(string: subCategory.image ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    ShimmerView()
//                        .frame(width: 50, height: 50)
//                case .success(let image):
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 50, height: 50)
//                        .clipped()
//                default:
//                    placeholder
//                }
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Name
            Text(subCategory.name ?? "Unknown")
                .font(.custom(poppinsSemiBold, size: 15))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .topLeading)
                .layoutPriority(1)

            Spacer()

            // Viewer Badge
            viewersBadge
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 74, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
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
        HStack(spacing: 12) {
            // Icon Shimmer
            
            ShimmerView()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Name Shimmer
            VStack(alignment: .leading, spacing: 4) {
                ShimmerView()
                    .frame(width: 120, height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Spacer()
            
            // Badge Shimmer
            ShimmerView()
                .frame(width: 80, height: 28)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

