//
//  HomeViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct HomeViewScreen: View {
    
    @State private var selectedButton: String = "For You"
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var navigateToLiveStream = false
    @State var index = 0
    @State var currentRoomId = ""
    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)
    @Binding var showCategory : String
    @State var viewModel = HomeViewModel()
    var categoryViewModel = SelectCategoryViewModel()
    @State var categoryList = [CategoryDataModel]()
    @State var liveShowsData = [HomeModel]()
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
    @State private var isActiveOnHomeScreen = false
    @State var navigateToCategoryDetailScreen : Bool = false
    @State var upCommingSheet : Bool = false
    @State var isNavFrom : String = ""
    @State var searchText: String = ""
    
    @State var selectedShowUserName : String = ""
    @State var selectedShowUserImage : String = ""
    @State var selectedShowStartAt : String = ""
    @State var selectedShowStartDate : String = ""
    @State var categoryName : String = ""
    
    @State private var loadedRoomIDs = Set<String>()

    
    @State var currentPage = 1
    var body: some View {
        VStack(spacing:0){
            VStack{
                PrimaryHeader(
                    title: comeFromExploreScreen ? showCategory.capitalizingFirstLetter() : "",
                    isForLogo: comeFromExploreScreen ? false : true,
                    leadingImgArr: [comeFromExploreScreen ? .icBack : .appName],
                    trailingImgArr: [.search,.notification],
                    onClickLeading: { index in
                        if comeFromExploreScreen{
                            navigateToCategoryDetailScreen = false
                            self.presentationMode.wrappedValue.dismiss()
                           
                        }
                    },
                    onClickTrailing: { index in
                        if index == 0{
                            withAnimation {
                                showSearchView.toggle()
                            }
                        }else{
                            navigateToNoti = true
                        }
                    },
                    count: .constant(0)
                )
            }
            
            ScrollView(showsIndicators:false){
                VStack(alignment: .leading,spacing: 12){
                    
                    if showSearchView {
                        SearchView(searchText: $searchText) { _ in
                            Task { await fetchLiveShow() }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.bottom, 10)
                        .onChange(of: searchText) { newValue in
                            Task { await fetchLiveShow() }
                        }
                    }
                    if !comeFromExploreScreen{
                        SegmentedControlView(
                            segments: categoryList.map { $0.name ?? "" },
                            selectedSegment: $selectedButton,
                            isWithBorder: true
                        ) { selection in
                            Task {
                                await fetchLiveShow()
                            }
                        }
                    }
                    ButtonTitleLabel(
                        titles: ["Live Now", "Popular", "Coming Soon"],
                        fontValue: 16,
                        textColor: .blue,
                        selectedTitle : Binding(
                            get: {
                                switch selectedTab {
                                case "live": return "Live Now"
                                case "popular": return "Popular"
                                case "upcoming": return "Coming Soon"
                                default: return "Live Now"
                                }
                            },
                            set: { newValue in
                                if newValue == "Live Now" {
                                    selectedTab = "live"
                                }else if newValue == "Popular"{
                                    selectedTab = "popular"
                                }else if newValue == "Coming Soon"{
                                    selectedTab = "upcoming"
                                }
                            }
                        )
                    ) { selected in
                        print("Tapped:", selected)
                        Task{
                            guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            
                            SVProgressHUD.show()
                            liveShowsData.removeAll()
                            var selection = ""
                            if selected == "Live Now"{
                                selection = "live"
                            }else if selected == "Popular"{
                                selection = "popular"
                            }else{
                                selection = "upcoming"
                            }
                            self.selectedTab = selection
                            if isActiveOnHomeScreen{
                                //                                let apiCategory = (selectedButton == "For You") ? "for_you" : selectedButton
                                //                                await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: selection,category: apiCategory))
                                await fetchLiveShow()
                            }
                            //                            await SVProgressHUD.dismiss()
                            //                            self.success()
                        }
                    }
                    if liveShowsData.isEmpty{
                        NoDataView(message: "No Shows found")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }else{
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(liveShowsData.indices, id: \.self) { index in
                                let item = liveShowsData[index]
                                
                                ImageCollectionView(profileImg: item.user?.profile_image ?? "",
                                                    profileName: item.user?.username ?? item.user?.name ?? "".capitalizingFirstLetter(),
                                                    textSize: 14.0,
                                                    image: item.thumbnail?.first ?? "",
                                                    category: item.category?.name ?? "",
                                                    title2:item.title ?? "",
                                                    categorySize: 14,
                                                    title2Size: 16.0,
                                                    liveCount: item.latest_viewer_count ?? 0,
                                                    isLive : item.is_live ?? false,
                                                    onTapProfile: {
                                    self.liveShowsData.removeAll()
                                    userId = "\(item.user?.id ?? 0)"
//                                    if selectedTab != "upcoming" {
                                        navigateToProfile = true
//                                    }else{
//                                        selectedShowUserName = item.user?.name ?? ""
//                                        selectedShowUserImage = item.user?.profile_image ?? ""
//                                        selectedShowStartAt = item.time ?? ""
//                                        selectedShowStartDate =  item.date ?? ""
//                                        upCommingSheet = true
//                                    }
                                },onTapProfileName: {
                                    self.liveShowsData.removeAll()
                                    userId = "\(item.user?.id ?? 0)"
                                    userImage = item.user?.profile_image ?? ""
                                    userName = item.user?.username ?? ""
//                                    if selectedTab != "upcoming" {
                                        navigateToProfile = true
//                                    }else{
//                                        selectedShowUserName = item.user?.name ?? ""
//                                        selectedShowUserImage = item.user?.profile_image ?? ""
//                                        selectedShowStartAt = item.time ?? ""
//                                        selectedShowStartDate = item.date ?? ""
//                                        upCommingSheet = true
//                                    }
                                },onTapMainImage: {
                                    print(" tapped the card!,inex \(index)")
                                    self.index = index
                                    self.currentRoomId = item.room_id ?? ""
                                    userId = "\(item.user?.id ?? 0)"
                                    userImage = item.user?.profile_image ?? ""
                                    userName = item.user?.username ?? ""
                                    self.selectedButton =  selectedButton == "For You" ? "for_you" : selectedButton
                                   if selectedTab == "upcoming"{
                                        selectedShowUserName = item.user?.name ?? ""
                                        selectedShowUserImage = item.user?.profile_image ?? ""
                                        selectedShowStartAt = item.time ?? ""
                                        selectedShowStartDate = item.date ?? ""
                                        upCommingSheet = true
                                    }else  if selectedTab == "popular"{
                                        if item.is_live == false{
                                            hudMsg = "This show is not live yet"
                                            showhud = true
                                        }else{
                                            navigateToLiveStream = true
                                        }
                                    }else{
                                        categoryName = item.category?.name ?? ""
                                        navigateToLiveStream = true
                                    }
                                   
                                },onTapCategory: {
//                                    self.liveShowsData.removeAll()
                                    self.category = item.category?.name ?? ""
                                    navigateToCategoryDetailScreen = true
                                })
                                .onAppear{
                                    handlePagination(index: index)
                                }
                                .background(.clear)
                                .cornerRadius(10)
                            }
                        }
                        
                        .padding(.vertical,3)
                    }
                }
            }
            .padding([.leading,.trailing],12)
            .padding(.top , 10)
            
            CusNavLink(doNavigate: $navigateToLiveStream, destination: LiveStream(currentRoomID: $currentRoomId, categoryName: $categoryName,currentStreamIndex :self.$index, userId : $userId, comeFromHome: $navigateToLiveStream,category: $selectedButton,search:self.$searchText,currentPage:self.$currentPage))
            
            CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(
                id:$userId,
                isComeFrom: .constant("Home"),
                userName: $userName,
                userImage: $userImage))
            
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
            CusNavLink(doNavigate: $navigateToCategoryDetailScreen, destination: HomeViewScreen(showCategory:$category,comeFromExploreScreen : $navigateToCategoryDetailScreen))
        }
        .background(.bg.opacity(0.1))
        .edgesIgnoringSafeArea(.bottom)
        //        .padding(.bottom,4)
        .onAppear{
            isActiveOnHomeScreen = true
            SocketManagerService.shared.setupSocket()
        }
        .onFirstAppear{
            isActiveOnHomeScreen = true
            
            if isActiveOnHomeScreen{
                Task { await fetchCategory(for: "for_you") }
            }
            Task{
                liveShowsData.removeAll()
                guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                if isActiveOnHomeScreen{
                    
                    await fetchLiveShow()
                }
                
                if isActiveOnHomeScreen{
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
                }else{
                    
                }
            }
            
            if isActiveOnHomeScreen && !comeFromExploreScreen {
                FirebaseManager.shared.observeNewLiveSessionNodes {
                    Task {
                        // Check internet before fetching/adding new shows
                        guard Reachability.isConnectedToNetwork() else {
                            hudMsg = "No Internet Connection"
                            showhud = true
                            return
                        }
                        await fetchLiveShow()
                    }
                }
            }

            
            FirebaseManager.shared.observeLiveSessionRemovals { removedRoomId in
                DispatchQueue.main.async {
                    liveShowsData.removeAll { $0.room_id == removedRoomId }
                }
            }
        }
        .onDisappear {
            isActiveOnHomeScreen = false
            FirebaseManager.shared.removeNewSessionObserver()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $upCommingSheet, height: screenHeight * 0.37) {
            UpcomingBottomSheet(
                profileImage: selectedShowUserImage,
                username: selectedShowUserName,
                showStartAt: selectedShowStartAt,
                showStartDate : selectedShowStartDate,
                onDismiss: {
                    upCommingSheet = false
                }
            )
        }
    }
    
    func fetchLiveShow() async {
        if currentPage == 1 {
            liveShowsData.removeAll()
            loadedRoomIDs.removeAll()
        }
        SVProgressHUD.show()
        let apiCategory = (selectedButton == "For You") ? "for_you" : selectedButton
        await viewModel.getLiveShows(param: GetLiveShowsRequest(
            type: selectedTab,
            category: apiCategory,
            search: searchText,
            page: "\(currentPage)"
        ))
        await SVProgressHUD.dismiss()
        success()
    }

    
    func handlePagination(index: Int) {
        let isLastItem = index == liveShowsData.count - 1
        let canFetchMore = (viewModel.liveShowsResponse.total ?? 0) > liveShowsData.count
        
        if isLastItem && canFetchMore {
            fetchMoreShows()
        }
    }
    
    func fetchMoreShows() {
        Task {
            let apiCategory = (selectedButton == "For You") ? "for_you" : selectedButton
            currentPage += 1
            await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: self.selectedTab,category: apiCategory,search: searchText,page: "\(currentPage)"))
            success()
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
        await categoryViewModel.getCategoryList(param: CategoryRequest(type: selectedTab))
        await SVProgressHUD.dismiss()
        categorySuccess()
    }
    
    // MARK: - categorySuccess
    func categorySuccess() {
        let response = categoryViewModel.categoryResponse
        if response.status == "success" {
            // Filter only selected categories
            var categories = (response.data ?? []).filter { $0.is_selected == true }
            
            // Always add "For You" at first
            let forYouCategory = CategoryDataModel(
                id : -1,
                name: "For You",
                image: "",
                thumbnail: "",
                color: "",
                subLabel : "",
                is_selected : false,
                usage_count : ""
            )
            
            categories.insert(forYouCategory, at: 0)
            
            self.categoryList = categories
            
            // Default selection
            if selectedButton.isEmpty {
                selectedButton = forYouCategory.name ?? "For You"
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

    
    
    func success() {
        let response = viewModel.liveShowsResponse
        guard response.status == "success", let newShows = response.data else {
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
        
        for show in newShows {
            if let roomId = show.room_id, !loadedRoomIDs.contains(roomId) {
                liveShowsData.append(show)
                loadedRoomIDs.insert(roomId)
            }
        }
    }
}

//#Preview {
//    HomeViewScreen()
//}

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
