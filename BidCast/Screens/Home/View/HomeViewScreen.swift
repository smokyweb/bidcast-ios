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
    
    @EnvironmentObject var tabBarRouter: TabBarRouter
     
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
    @State private var isActiveOnHomeScreen = false
    @State var navigateToCategoryDetailScreen : Bool = false
    @State var upCommingSheet : Bool = false
    @State var navigateToAllCategoryScreen : Bool = false
    @State var isNavFrom : String = ""
    @State var searchText: String = ""
    
    @State var selectedShowUserName : String = ""
    @State var selectedShowUserImage : String = ""
    @State var selectedShowStartAt : String = ""
    @State var selectedShowStartDate : String = ""
    @State var categoryName : String = ""
    
    @State private var isCategoryScrolling: Bool = false
    @State private var scrollTimer: Timer?
    
    @State private var loadedRoomIDs = Set<String>()
    @State var agoraToken: String = ""
    
    @State var currentPage = 1
    var body: some View {
        VStack(spacing:0){
            HStack(spacing: 12) {
                if comeFromExploreScreen {
                    //back button
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName:"chevron.left")
                            .font(.custom(poppinsBold, size: 16))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                        
                    }
                    
                }
                SearchBarView(placeholder: "What are you looking for?") { debouncedText in
//                    if debouncedText == "" { return }
                    self.searchText = debouncedText
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
            
            if !comeFromExploreScreen {
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
                                        Task {
                                            await fetchLiveShow()
                                        }
                                    }
                                }
                                
                            }
                            // 🔥 ADD THIS: The final “See All Categories” card
                            HomeCategoryCardView(
                                title: "See All Categories",
                                imageURL: "",                   // icon handled separately
                                backgroundColor: "#000000",
                                isSelected: false,
                                isScrolling: false,
                                isSeeAll: true                  // NEW PARAM
                            )
                            .onTapGesture {
//                                tabBarManager.selectedTab = 1
                                goToExplore()
                            }

                        }
                        .frame(height: 140)
                        .padding(.leading)
                    }
                }
                .background(.backGround)
//                .padding([.leading,.trailing],18)
                .padding(.top , 5)
                
            }
          
            
            ScrollView(showsIndicators:false){
                VStack(alignment: .leading,spacing: 8){
                    // MARK: - Category Horizontal Scroll
                    
                    // MARK: - Filter Pills
                    PillsSelectorView(
                        titles: categoryFilterTitles,
                        selectedIndex: $selectedCategoryIndex,
                                      backgroundStyle: .none,
                                      underlineEnabled: false,
                        onSelectionChanged: { index, data in
                            let selectedCategory = categoryFilterTitles[index]
                            selectedTab = getCategoryName(for: selectedCategory)
                            Task {
                                await fetchLiveShow()
                            }
                        })
                   
                    // MARK: - Live Auction View
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
                            print(" tapped the card!,inex \(index)")
                            self.index = index
                            self.currentRoomId = item.room_id ?? ""
                            self.agoraToken = item.rtc_token ?? ""
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
                        },
                        onTapCategory: { index in
                            let item = liveShowsData[index]
                            self.liveShowsData.removeAll()
                            self.category = item.category?.name ?? ""
                            navigateToCategoryDetailScreen = true
                        }
                    )
                    .padding(.bottom, 20)
                    .onAppear{
                        handlePagination(index: index)
                    }
                    .cornerRadius(10)
                }
            }
            .background(.backGround)
            .padding([.leading,.trailing],18)
            .padding(.top , 10)
            
            CusNavLink(doNavigate: $navigateToLiveStream, destination: LiveStream(currentRoomID: $currentRoomId,
                                                                                  categoryName: $categoryName,
                                                                                  currentStreamIndex :self.$index,
                                                                                  userId : $userId,
                                                                                  agoraToken: $agoraToken,
                                                                                  comeFromHome: $navigateToLiveStream,
                                                                                  category: $selectedButton,
                                                                                  search:self.$searchText,
                                                                                  currentPage:self.$currentPage
                                                                                 ))
            
            CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(
                id:$userId,
                isComeFrom: .constant("Home"),
                userName: $userName,
                userImage: $userImage))
            
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
//            CusNavLink(doNavigate: $navigateToNoti, destination: RandomizerView())
          
            CusNavLink(doNavigate: $navigateToCategoryDetailScreen, destination: HomeViewScreen(showCategory:$category,comeFromExploreScreen : $navigateToCategoryDetailScreen))
        }
        .background(.backGround)
//        .bottomSheet(
//            isPresented: $navigateToNoti,
//            height: screenHeight * 0.8,
//            topBarCornerRadius: 20,
//            contentBackgroundColor: Color(.systemBackground),
//            topBarBackgroundColor: Color(.systemBackground),
//            showTopIndicator: false,
//            onDismiss: {
//                navigateToNoti = false
//            },
//            content: {
//                let poll = PollModel(
//                            pollId: "12345",
//                            roomId: "room_01",
//                            question: "Do you like the product?",
//                            options: [
//                                PollOption(text: "yes", voteCount: 6, percentage: 60),
//                                PollOption(text: "yes", voteCount: 6, percentage: 60),
//                                PollOption(text: "yes", voteCount: 6, percentage: 60),
//                                PollOption(text: "no", voteCount: 3, percentage: 30),
//                                PollOption(text: "yes", voteCount: 6, percentage: 60),
//                                PollOption(text: "not very much", voteCount: 1, percentage: 10)
//                            ],
//                            totalVotes: 10,
//                            remainingTime: 128,
//                            isActive: true
//                        )
//                LivePollHostView(poll: poll) { _, _ in
//                    print("End Poll")
//                }
//            }
//            content: {
//                var poll = PollModel(
//                    pollId: "12345",
//                    roomId: "room_01",
//                    question: "What's your favorite feature of this app?",
//                    options: [
//                        PollOption(text: "Live Streaming", voteCount: 45, percentage: 45),
//                        PollOption(text: "Bidding System", voteCount: 35, percentage: 35),
//                        PollOption(text: "Chat Feature", voteCount: 20, percentage: 20)
//                    ],
//                    totalVotes: 100,
//                    remainingTime: 180,
//                    isActive: true
//                )
//            
//                
//                LivePollViewerView(poll: poll, onVote: { pollId, roomId, opt in
//                    print("Vote emitted:", opt)
//                }, onRequestRefresh: {
//                    print("request refresh")
//                })                
//            }
//        )
        .background(.bg.opacity(0.1))
        .edgesIgnoringSafeArea(.bottom)
//                .padding(.bottom,4)
                .padding(.bottom, -15)
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
                if isActiveOnHomeScreen{
                    await self.viewModel.getProfile()
                }
                
                if isActiveOnHomeScreen{
                    
                    await fetchLiveShow()
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
    
    func goToExplore() {
        tabBarRouter.selectedTab = 1 // Explore tab index
    }
    
    func fetchLiveShow() async {
        if currentPage == 1 {
            liveShowsData.removeAll()
            loadedRoomIDs.removeAll()
        }
        isLoadingShowAPI = true
        let apiCategory = (selectedButton == "For You") ? "for_you" : selectedButton
        await viewModel.getLiveShows(param: GetLiveShowsRequest(
            type: selectedTab,
            category: apiCategory,
            search: searchText,
            page: "\(currentPage)"
        ))
    
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
        isLoadingCategoryAPI = true
        await categoryViewModel.getCategoryList(param: CategoryRequest(type: selectedTab))
        await SVProgressHUD.dismiss()
        categorySuccess()
    }
    
    // MARK: - categorySuccess
    func categorySuccess() {
        let response = categoryViewModel.categoryResponse
        if response.status == "success" {
            isLoadingCategoryAPI = false
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
        isLoadingShowAPI = false
        
        for show in newShows {
            if let roomId = show.room_id, !loadedRoomIDs.contains(roomId) {
                liveShowsData.append(show)
                loadedRoomIDs.insert(roomId)
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
