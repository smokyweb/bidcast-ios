//
//  HomeViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//  Updated with Pagination Integration
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct HomeViewScreen: View {
    var deepLinkShowId: String?
    @State private var selectedButton: String = ""
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @EnvironmentObject var tabBarRouter: TabBarRouter
     
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var navigateToLiveStream = false
    @State var index = 0
    @State var currentRoomId = ""
    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)
    @Binding var showCategory : String
    @Binding var showSubCategory : String
    @State var viewModel = HomeViewModel()
    var categoryViewModel = SelectCategoryViewModel()
    @State var categoryList = [CategoryDataModel]()
    @State var liveShowsData = [HomeModel]()
    
    @State private var isLoadingCategoryAPI: Bool = true
    @State private var isLoadingShowAPI: Bool = true
    
    let categoryFilterTitles = ["Live Now", "Popular", "Coming Soon"]
    @State private var selectedCategoryIndex: Int = 0
    
    @State private var hasVoted: Bool = false
    
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var userId = ""
    @State var userImage = ""
    @State var userName = ""
    @Binding var comeFromExploreScreen : Bool
    @State var navigateToNoti : Bool = false
    @State var selectedTab = "live"
    @State var navigateToProfile = false
    @State private var showSearchView: Bool = false
    @State var category : String = ""
    @State var subCategory : String = ""
    @State private var isActiveOnHomeScreen = false
    @State var navigateToCategoryDetailScreen : Bool = false
    @State var upCommingSheet : Bool = false
    @State var navigateToAllCategoryScreen : Bool = false
    @State var isNavFrom : String = ""
    @State var searchText: String = ""
    @State private var navigateToSearchResults = false
    
    @State var selectedShowUserName : String = ""
    @State var selectedShowUserImage : String = ""
    @State var selectedShowStartAt : String = ""
    @State var selectedShowStartDate : String = ""
    @State var categoryName : String = ""
    
    @State private var isCategoryScrolling: Bool = false
    @State private var scrollTimer: Timer?
    
    @State private var loadedRoomIDs = Set<String>()
    @State var agoraToken: String = ""
    
    // MARK: - Pagination Properties
    @State var currentPage = 1
    @State private var isLoadingMore = false
    @State private var hasMorePages = true
    @State private var totalItems = 0
    
    @StateObject var socketManager = SocketManagerService.shared
    
    var body: some View {
        VStack(spacing:0){
            HStack(spacing: 12) {
                if comeFromExploreScreen {
                    //back button
                    // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14):
                    // Filtered Home was previously reached via a
                    // NavigationView push from the Explore tab, so the
                    // back button just called presentationMode.dismiss().
                    // The new flow is a tab-switch (Explore -> Home tab
                    // with filter applied via TabBarRouter) — there is no
                    // push to pop. Back now switches the tab selection
                    // back to Explore (tag 1) and clears the Explore
                    // filter so re-entering Home shows the plain feed.
                    Button {
                        comeFromExploreScreen = false
                        showCategory = ""
                        showSubCategory = ""
                        tabBarRouter.selectedTab = 1
                    } label: {
                        Image(systemName:"chevron.left")
                            .font(.custom(poppinsBold, size: 16))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                    }
                }
                
                VStack(spacing:8){
                    SearchBarView(placeholder: "What are you looking for?") { debouncedText in
                        self.searchText = debouncedText
                        if !debouncedText.isEmpty {
                            self.navigateToSearchResults = true
                        }
                    }
                    
                    if comeFromExploreScreen {
                        Text(showCategory)
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.black)
                    }
                }
                
                Spacer()
                
                HeaderMenuIconView(
                    didTapMenuButton: {
                        navigateToNoti = true
                    },
                    count: .constant(0)
                )
            }
            .padding(.horizontal,12)
            .padding(.vertical, 4)
            .background(.white)
            
            // MARK: - Category Horizontal Scrolls
            if !comeFromExploreScreen {
                categoryScrollView
            }
            
            // FIX cmp5czpw900jo56kdn739kkjp: removed `&& showSubCategory == ""`
            // guard — the home row (subcategory filter strip) must stay visible
            // after the user taps any category on the Explore page, whether or
            // not a specific subcategory was pre-selected. The old condition hid
            // the row the moment showSubCategory was non-empty, making the
            // filter strip disappear and leaving users stuck on one subcategory
            // with no way to switch. Now it shows whenever data is ready.
            if comeFromExploreScreen && categoryList.count != 0 {
                categoryScrollView
            }
          
            ScrollView(showsIndicators:false){
                VStack(alignment: .leading, spacing: 8){
                    // MARK: - Filter Pills
                    PillsSelectorView(
                        titles: categoryFilterTitles,
                        selectedIndex: $selectedCategoryIndex,
                        backgroundStyle: .none,
                        underlineEnabled: false,
                        onSelectionChanged: { index, data in
                            let selectedCategory = categoryFilterTitles[index]
                            selectedTab = getCategoryName(for: selectedCategory)
                            resetPagination()
                            Task {
                                await fetchLiveShow()
                            }
                        })
                   
                    // MARK: - Live Auction View with Pagination
                    LiveAuctionView(
                        liveShowsData: $liveShowsData,
                        isLoadingAPI: $isLoadingShowAPI,
                        currentPage: $currentPage,
                        onTapProfile: { index in
                            let item = liveShowsData[index]
                            self.liveShowsData.removeAll()
                            userId = "\(item.user?.id ?? 0)"
                            navigateToProfile = true
                        },
                        onTapProfileName: { index in
                            let item = liveShowsData[index]
                            self.liveShowsData.removeAll()
                            userId = "\(item.user?.id ?? 0)"
                            userImage = item.user?.profile_image ?? ""
                            userName = item.user?.username ?? ""
                            navigateToProfile = true
                        },
                        onTapMainImage: { index in
                            let item = liveShowsData[index]
                            print("🎯 Tapped card at index \(index)")
                            self.index = index
                            self.currentRoomId = item.room_id ?? ""
                            self.agoraToken = item.rtc_token ?? ""
                            userId = "\(item.user?.id ?? 0)"
                            userImage = item.user?.profile_image ?? ""
                            userName = item.user?.username ?? ""
                            self.selectedButton = selectedButton == "For You" ? "" : selectedButton
                            
                            if selectedTab == "upcoming" {
                                selectedShowUserName = item.user?.name ?? ""
                                selectedShowUserImage = item.user?.profile_image ?? ""
                                selectedShowStartAt = item.time ?? ""
                                selectedShowStartDate = item.date ?? ""
                                upCommingSheet = true
                            } else if selectedTab == "popular" {
                                if item.is_live == false {
                                    hudMsg = "This show is not live yet"
                                    showhud = true
                                } else {
                                    navigateToLiveStream = true
                                }
                            } else {
                                categoryName = item.category?.name ?? ""
                                navigateToLiveStream = true
                            }
                        },
                        onTapCategory: { index in
                            let item = liveShowsData[index]
                            self.liveShowsData.removeAll()
                            self.category = item.category?.name ?? ""
                            navigateToCategoryDetailScreen = true
                        },
                        totalItems: totalItems,
                        hasMorePages: hasMorePages,
                        isLoadingMore: isLoadingMore,
                        onLoadMore: {
                            fetchMoreShows()
                        }
                    )
                    .padding(.bottom, 20)
                    .cornerRadius(10)
                }
            }
            .refreshable {
                await refreshLiveShows()
            }
            .background(.backGround)
            .padding([.leading,.trailing], 18)
            .padding(.top, 10)
            
            // MARK: - Navigation Links
            CusNavLink(doNavigate: $navigateToLiveStream, destination: LiveStream(
                currentRoomID: $currentRoomId,
                categoryName: $categoryName,
                currentStreamIndex: self.$index,
                userId: $userId,
                agoraToken: $agoraToken,
                comeFromHome: $navigateToLiveStream,
                category: $selectedButton,
                search: self.$searchText,
                currentPage: self.$currentPage
            ))
            
            CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(
                id: $userId,
                isComeFrom: .constant("Home"),
                userName: $userName,
                userImage: $userImage
            ))
            
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
          
            CusNavLink(doNavigate: $navigateToCategoryDetailScreen, destination: HomeViewScreen(
                showCategory: $category,
                showSubCategory: $subCategory,
                comeFromExploreScreen: $navigateToCategoryDetailScreen
            ))
            
            // Link to Search Results
            NavigationLink(destination: SearchResultsView(initialQuery: searchText), isActive: $navigateToSearchResults) {
                EmptyView()
            }
        }
        .background(.backGround)
        .edgesIgnoringSafeArea(.bottom)
        .padding(.bottom, -15)
        .onAppear {
            socketManager.setupSocket {
                addSocketListeners()
            }
            
            isActiveOnHomeScreen = true
            
            if isActiveOnHomeScreen {
                Task {
                    await fetchCategory(for: "for_you")
                    await fetchLiveShow()
                }
            }
            getProfileData()
        }
        .onChange(of: navigateToLiveStream) { oldValue, isNavigating in
            if !isNavigating {
                Task {
                    await refreshLiveShows()
                    if !comeFromExploreScreen {
                        selectedButton = "For You"
                    }
                }
            }
        }
        // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14): refresh categories
        // and the live-shows feed whenever the Explore-derived filter flag
        // toggles. Two cases:
        //   * false -> true: user just landed on Home from an Explore tap.
        //     Re-fetch so the filtered feed for the chosen category loads.
        //   * true -> false: user re-tapped the Home tab from filtered Home
        //     (or pressed Back). Reset to the regular For-You feed and
        //     re-fetch so the home row + live shows are repopulated
        //     instead of leaving the previous filtered state on screen.
        .onChange(of: comeFromExploreScreen) { _, nowFromExplore in
            resetPagination()
            if !nowFromExplore {
                selectedButton = "For You"
            }
            Task {
                await fetchCategory(for: "for_you")
                await fetchLiveShow()
            }
        }
        // Also refresh when the actual category/subCategory binding changes
        // (defensive — covers an Explore -> different category re-tap that
        // keeps comeFromExploreScreen at true but rotates the filter).
        .onChange(of: showCategory) { _, _ in
            resetPagination()
            Task { await fetchLiveShow() }
        }
        .onChange(of: showSubCategory) { _, _ in
            resetPagination()
            Task { await fetchLiveShow() }
        }
        .onDisappear {
            isActiveOnHomeScreen = false
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $upCommingSheet, height: screenHeight * 0.37) {
            UpcomingBottomSheet(
                profileImage: selectedShowUserImage,
                username: selectedShowUserName,
                showStartAt: selectedShowStartAt,
                showStartDate: selectedShowStartDate,
                onDismiss: {
                    upCommingSheet = false
                }
            )
        }
        // MC sub-task cmp4935yr00lz3mx130q4x1ku (Trey 2026-05-13): the home
        // feed previously set showError=true on load failure but never
        // presented the alert anywhere — users saw a silent stuck feed.
        // Wire a CommonBottomSheet here with a retry action on the primary
        // button so the user can try again without backgrounding the app.
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.8,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: { showError = false }
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    showError = false
                    Task { await fetchLiveShow() }
                },
                onSecondaryClick: {
                    showError = false
                }
            )
        }
        .onChange(of: deepLinkShowId) { showId in
            guard let showId else { return }
            tabBarRouter.selectedTab = 0
            if let show = viewModel.liveShowsResponse.data?.first(where: { $0.id == Int(showId) }) {
                categoryName = show.category?.name ?? ""
                navigateToLiveStream = true
                self.currentRoomId = show.room_id ?? ""
                self.agoraToken = show.rtc_token ?? ""
                userId = "\(show.user?.id ?? 0)"
                userImage = show.user?.profile_image ?? ""
                userName = show.user?.username ?? ""
            }
        }
    }
    
    // MARK: - Category Scroll View
    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if isLoadingCategoryAPI {
                LazyHGrid(rows: rows, spacing: 16) {
                    ForEach(0..<5, id: \.self) { _ in
                        CategoryCardFullShimmerView(
                            width: 90,
                            height: 120,
                            cornerRadius: 9
                        )
                    }
                }
            } else {
                LazyHGrid(rows: rows, spacing: 8) {
                    ForEach(categoryList.indices, id: \.self) { ind in
                        HomeCategoryCardView(
                            title: categoryList[ind].name ?? "",
                            imageURL: categoryList[ind].image ?? "",
                            backgroundColor: categoryList[ind].color ?? "#CCCCCC",
                            isSelected: selectedButton == categoryList[ind].name
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedButton = categoryList[ind].name ?? ""
                                resetPagination()
                                Task {
                                    await fetchLiveShow()
                                }
                            }
                        }
                    }
                    
                    if !comeFromExploreScreen {
                        HomeCategoryCardView(
                            title: "See All Categories",
                            imageURL: "",
                            backgroundColor: "#000000",
                            isSelected: false,
                            isScrolling: false,
                            isSeeAll: true
                        )
                        .onTapGesture {
                            goToExplore()
                        }
                    }
                }
                .frame(height: 140)
                .padding(.leading)
            }
        }
        .background(.backGround)
        .padding(.top, 5)
    }
    
    // MARK: - Pagination Helper Functions
    
    /// Resets pagination to initial state
    private func resetPagination() {
        currentPage = 1
        hasMorePages = true
        isLoadingMore = false
        loadedRoomIDs.removeAll()
        liveShowsData.removeAll()
        totalItems = 0
    }
    
    /// Refreshes the live shows list (pull to refresh)
    func refreshLiveShows() async {
        print("🔄 Refreshing live shows...")
        resetPagination()
        isLoadingShowAPI = true
        await fetchLiveShow()
    }

    /// Fetches live shows for socket updates (page 1 only)
    func fetchLiveShowForSocketUpdate() async {
        var apiCategory = String()
        var subCategory = String()
        
        if comeFromExploreScreen {
            apiCategory = showCategory
            if showSubCategory == "" {
                subCategory = selectedButton.isEmpty ? "" : selectedButton
            } else {
                subCategory = showSubCategory
            }
        } else {
            apiCategory = (selectedButton == "For You") ? "" : selectedButton
        }
        
        await viewModel.getLiveShows(param: GetLiveShowsRequest(
            type: selectedTab,
            category: apiCategory,
            sub_category: subCategory,
            search: searchText,
            page: "1"
        ))

        await MainActor.run {
            guard let socketShows = viewModel.liveShowsResponse.data else { return }

            for show in socketShows {
                guard let roomId = show.room_id else { continue }

                if !loadedRoomIDs.contains(roomId) {
                    liveShowsData.insert(show, at: 0)
                    loadedRoomIDs.insert(roomId)
                    totalItems += 1
                }
            }
        }
    }

    func getProfileData() {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            
            if isActiveOnHomeScreen {
                await self.viewModel.getProfile()
            }
            
            if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                let response = self.viewModel.accountInfo.data
                UserDefaults.isFirstShowCreated = response?.is_FirstShowCreated ?? false
                UserDefaults.profileURL = response?.profile_image ?? ""
                UserDefaults.fullName = response?.name ?? ""
                UserDefaults.userName = response?.username ?? UserDefaults.fullName
            
                UserDefaults.buyerVerafied = response?.buyer_identity_status ?? ""
                UserDefaults.sellerVerafied = response?.seller_identity_status ?? ""
                UserDefaults.sellerAddress = response?.has_shipping_address ?? false
                UserDefaults.hasCardAdded = response?.has_card_added ?? false
                UserDefaults.userEmail = response?.email ?? ""
                UserDefaults.default_card = response?.default_card ?? DefaultCardModel()
                UserDefaults.default_shipping_address = response?.default_shipping_address ?? AddressModel()
                UserDefaults.couponCount = "\(response?.coupon_count ?? 0)"
                UserDefaults.vacationMode = response?.vacation_mode == "true" ? true : false
            }
        }
    }
    
    func goToExplore() {
        tabBarRouter.exploreInitialTab = 2
        tabBarRouter.selectedTab = 1
    }
    
    /// Main function to fetch live shows with pagination support
    func fetchLiveShow() async {
        // Prevent duplicate requests
        guard !isLoadingMore else {
            print("⚠️ Already loading, skipping request")
            return
        }
        
        if currentPage == 1 {
            isLoadingShowAPI = true
            print("📥 Loading page 1 (initial load)")
        } else {
            isLoadingMore = true
            print("📥 Loading page \(currentPage) (pagination)")
        }
        
        var apiCategory = String()
        var subCategory = String()
        
        if comeFromExploreScreen {
            apiCategory = showCategory
            if showSubCategory == "" {
                subCategory = selectedButton.isEmpty ? "" : selectedButton
            } else {
                subCategory = showSubCategory
            }
        } else {
            apiCategory = (selectedButton == "For You") ? "" : selectedButton
        }
        
        let params = GetLiveShowsRequest(
            type: selectedTab,
            category: apiCategory,
            sub_category: subCategory,
            search: searchText,
            page: "\(currentPage)"
        )
        await viewModel.getLiveShows(param: params)

        // MC cmp5crrg600j556kdjykbdaza (Ankit 2026-05-14): after sign-in the
        // first feed call sometimes fails with a transient error (network
        // not yet ready, server returning an unexpected shape, or a brief
        // 401 before the auth token fully propagates). When the ViewModel
        // sets errorMessage (meaning the request itself threw) on the first
        // page, retry once after 1.5 s before surfacing the error sheet.
        // If the retry also fails, success() shows the error normally.
        if currentPage == 1,
           let err = viewModel.errorMessage, !err.isEmpty {
            print("⚠️ Initial feed load failed (\(err)) — retrying in 1.5 s")
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            viewModel.errorMessage = nil
            await viewModel.getLiveShows(param: params)
        }

        success()
    }

    /// Fetches the next page of shows
    func fetchMoreShows() {
        guard !isLoadingMore, hasMorePages else {
            print("⚠️ Cannot fetch more - isLoadingMore: \(isLoadingMore), hasMorePages: \(hasMorePages)")
            return
        }
        
        Task {
            currentPage += 1
            print("📄 Fetching page \(currentPage)")
            await fetchLiveShow()
        }
    }
    
    // MARK: - fetchCategory
    func fetchCategory(for tab: String) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        
        SVProgressHUD.show()
        categoryList.removeAll()
        isLoadingCategoryAPI = true
        await categoryViewModel.getCategoryList(param: CategoryRequest(type: selectedTab))
        await SVProgressHUD.dismiss()
        await categorySuccess()
    }
    
    func fetchSubCategories(categoryId: String) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }

        isLoadingCategoryAPI = true
        categoryList.removeAll()

        await categoryViewModel.getCategoryList(
            param: CategoryRequest(category_id: categoryId)
        )

        subCategorySuccess()
    }
    
    func subCategorySuccess() {
        let response = categoryViewModel.categoryResponse

        guard response.status == "success" else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            return
        }

        isLoadingCategoryAPI = false
        let subCategories = response.data ?? []
        categoryList = subCategories
    }
    
    // MARK: - categorySuccess
    func categorySuccess() async {
        let response = categoryViewModel.categoryResponse
        
        if response.status == "success" {
            isLoadingCategoryAPI = false
            var categories = (response.data ?? []).filter { $0.is_selected == true }
            
            let forYouCategory = CategoryDataModel(
                id: -1,
                name: "For You",
                image: "",
                thumbnail: "",
                color: "",
                subLabel: "",
                is_selected: false,
                usage_count: ""
            )
            
            categories.insert(forYouCategory, at: 0)
            self.categoryList = categories
            
            if selectedButton.isEmpty {
                if !comeFromExploreScreen {
                    selectedButton = forYouCategory.name ?? "For You"
                }
            }
            
            if comeFromExploreScreen {
                if let matchedCategory = categoryList.first(where: {
                    ($0.name ?? "").caseInsensitiveCompare(showCategory) == .orderedSame
                }) {
                    let categoryId = matchedCategory.id ?? 0
                    print("Matched categoryId:", categoryId)
                    await fetchSubCategories(categoryId: "\(categoryId)")
                }
            }
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
    
    /// Processes the API response and updates pagination state
    func success() {
        let response = viewModel.liveShowsResponse
        
        guard response.status == "success", let newShows = response.data else {
            print("❌ API Error: \(response.message ?? "Unknown error")")
            // MC sub-task cmp4935yr00lz3mx130q4x1ku: surface a real error sheet
            // with a Try Again action instead of failing silently.
            let errTitle = (response.error_type?.capitalized).flatMap { $0.isEmpty ? nil : $0 } ?? "Couldn't load feed"
            let errMsg = (response.message?.capitalized).flatMap { $0.isEmpty ? nil : $0 } ?? "We couldn't load the feed right now. Please try again."
            alertType = .sheetType(
                icon: .alert,
                title: errTitle,
                message: errMsg,
                primaryBtnText: "Try Again",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
            isLoadingShowAPI = false
            isLoadingMore = false
            return
        }
        
        // Update total items count
        totalItems = response.total ?? 0
        print("📊 Total items: \(totalItems), Current loaded: \(liveShowsData.count)")
        
        // Add new shows, avoiding duplicates
        var addedCount = 0
        for show in newShows {
            if let roomId = show.room_id, !loadedRoomIDs.contains(roomId) {
                liveShowsData.append(show)
                loadedRoomIDs.insert(roomId)
                addedCount += 1
            }
        }
        print("✅ Added \(addedCount) new shows (Page \(currentPage))")
        
        // Check if there are more pages
        hasMorePages = liveShowsData.count < totalItems
        print("📄 Has more pages: \(hasMorePages)")
        
        // Reset loading states
        isLoadingShowAPI = false
        isLoadingMore = false
    }
    
    func addSocketListeners() {
        socketManager.removeRoomHandler()
        socketManager.hasAddedListeners = false
        socketManager.hasAddedListeners = true

        socketManager.observeRoomUpdates { room in
            print("🔴 Room updated:", room)
            Task {
                await fetchLiveShowForSocketUpdate()
            }
        }

        socketManager.listenForRoomEnded { roomId in
            withAnimation(.easeOut(duration: 0.25)) {
                liveShowsData.removeAll { $0.room_id == roomId }
                loadedRoomIDs.remove(roomId)
                totalItems = max(0, totalItems - 1)
            }
        }
    }

    private func getCategoryName(for categoryType: String) -> String {
        switch categoryType {
        case "Live Now": return "live"
        case "Popular": return "popular"
        default: return "upcoming"
        }
    }
}

// MARK: - Button Title Label (keeping your existing component)
struct ButtonTitleLabel: View {
    var titles: [String] = ["Live Now", "Popular", "Coming Soon"]
    var fontName = poppinsRegular
    var selectedFontName = poppinsSemiBold
    var fontValue: CGFloat = 18
    var textColor: Color = .gray
    var selectedColor: Color = .black
    var separatorColor: Color = .gray
    @Binding var selectedTitle: String
    var spacing: CGFloat = 12
    var onTap: ((String) -> Void)? = nil
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(titles.indices, id: \.self) { index in
                let title = titles[index]
                
                Text(title)
                    .font(.custom(title == selectedTitle ? selectedFontName : fontName,
                                  fixedSize: fontValue))
                    .foregroundColor(title == selectedTitle ? selectedColor : separatorColor)
                    .onTapGesture {
                        selectedTitle = title
                        onTap?(title)
                    }
                
                if index < titles.count - 1 {
                    Text("|")
                        .foregroundColor(separatorColor)
                        .font(.custom(fontName, fixedSize: fontValue))
                }
            }
        }
        .padding(.horizontal, 6)
    }
}
