//
//  ProfileScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast
import FirebaseAuth

enum ProfileTabType {
    case shop
    case shows
    case reviews
    case clips
}

struct ProfileScreen: View {
    
    @State var viewModel = ProfileViewModel()
    @State var productViewModel = ProductViewModel()
    
    @Binding var id : String
    @State private var sellerID : String = ""
    @Binding var  isComeFrom : String
    @Binding var userName : String
    @Binding var userImage : String
    @State private var isLoading: Bool = false
    @State private var currentPage = 1
    @State private var showhud: Bool = false
    @State private var hudMsg = ""
    @State private var showhudSuccess: Bool = false
    
    @State private var showHud = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var profileData = ProfileModel()
    @State var showSellSheet = false
    @State var showNotify = false
    @State var profileId = 0
    
    @State var isFollowing = false
    @State var productId : Int = 0
//    @State var productArr = [ProductListingDataModel]()
    @State var scheduleShowArr = [GetMyScheduleShowModel]()
    @State var totalRatingArr = [RatingDetail]()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var isForFollow = false
    @State var showToast = false
    @State var toastMessage = ""
    @State var showID = ""
    @State var isLive = false
    @State var navigateToReherseal = false
    @State var navigateToChat = false
    @State private var chatPath: String = ""
    @State private var isTipAmountButtoClicked: Bool = false
    @State private var showReportSheet: Bool = false
    
    @State private var scheduleViewModel = ScheduleViewModel()
    @StateObject var showViewModel = LiveShowsViewModel()
    //    @State var profileImage: String
    
    var options:[String] = ["Sort", "Auction", "Buy Now"]
    @State private var selectedIndex: Int = 0
    @State private var showSortSheet = false
    @State private var selectedSort: String = "newest"
    @State private var selectedOptions: String = ""
    
    @State private var isFetchingMore = false
    @State private var canLoadMore = true
    
    @State private var totalCount = 0
    @State var productData: [ProductDataModel1] = []
    @State var searchText: String = ""
    
    @State var reviewList: [ReviewModel] = [
        ReviewModel(username: "Alice", profileImageName: "user1", rating: 4.5),
        ReviewModel(username: "Bob", profileImageName: "user1", rating: 3.0),
        ReviewModel(username: "Cathy", profileImageName: "user1", rating: 5.0),
        ReviewModel(username: "Dan", profileImageName: "user1", rating: 2.5),
        ReviewModel(username: "Eve", profileImageName: "user1", rating: 4.0)
    ]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)
    
    @State private var selectedTab = ""
    //Review Variab
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        ProfileHeaderView(name: $userName,
                                          email: profileData.username ?? "",
                                          profileImage: $userImage,
                                          followers: "\(profileData.follower_count ?? 0)",
                                          following: "\(profileData.following_count ?? 0)" ,
                                          bio: profileData.bio ?? "Professional photographer specializing in portrait and wedding photography. Available for bookings worldwide.",
                                          onTapNotify: {
                            showNotify = true
                        },
                                          onTapMore: {
                            showReportSheet = true
                        },sellerID : $id)
                        
                        ProfileActionsView(isFollowing: $isFollowing ,
                                           onTapFollow: {
                            isForFollow = true
                            Task{
                                SVProgressHUD.show()
                                guard Reachability.isConnectedToNetwork() else {
                                    hudMsg = "No Internet Connection"
                                    showhud = true
                                    return
                                }
                                await self.viewModel.followUnfollow(parameters: FollowRequest(following_id: id))
                                await viewModel.getProfile(param: ProfileParamRequest(id: id))
                                await SVProgressHUD.dismiss()
                                profileSuccess()
                            }
                        },
                                           
                                           
                                           // Inside ProfileActionsView
                                           onTapMessage: {
                            let currentUserId = String(UserDefaults.userId)
                            let selectedUserId = id
                            let sortedRoomId = computeRoomId(senderId: currentUserId, receiverId: selectedUserId)
                            chatPath = "chats/\(sortedRoomId)"
                            
                            print("Computed Chat Path: \(chatPath)")
                            
                            navigateToChat = true
                        },
                                           onTapTipAmount:  {
                            self.isTipAmountButtoClicked = true
                        })
                        .padding(.top, -50)
                        
                        ProfileTabsView(selectedTab: $selectedTab) { tab in
                            print("Selected Tab: \(tab)")
                            Task {
                                switch tab {
                                case "Shop":
                                    resetShopData()
                                    fetchProduct()
                                case "Shows":
                                    guard Reachability.isConnectedToNetwork() else {
                                        hudMsg = "No Internet Connection"
                                        showhud = true
                                        return
                                    }
                                    SVProgressHUD.show()
                                    await self.viewModel.getMyScheduleShow(parameters: GetMyScheduleShowRequest(type: "upcoming", user_id: Int(id),page : currentPage))
                                    await SVProgressHUD.dismiss()
                                    scheduleShowSuccess()
                                case "Reviews":
                                    guard Reachability.isConnectedToNetwork() else {
                                        hudMsg = "No Internet Connection"
                                        showhud = true
                                        return
                                    }
                                    SVProgressHUD.show()
                                    await self.viewModel.getTotalRating(parameters: GetTotalRatingRequest(seller_id: 7))
                                    await SVProgressHUD.dismiss()
                                    ratingSuccess()
                                case "Clips":
                                    print("")
                                    //                                await viewModel.fetchClips()
                                default:
                                    break
                                }
                            }
                        }
                        if selectedTab == "Shop" {
                            // MARK: - Pills Selector
                            VStack(spacing: 12){
                                SearchBarView(placeholder: "Search") { debouncedText in
                                    if debouncedText == "" { return }
                                    resetShopData()
                                    self.searchText = debouncedText
                                    fetchProduct()
                                }.padding(.horizontal, 16)
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
                                            resetShopData()
                                            selectedOptions = "auction"
                                            fetchProduct()
                                        }
                                        else if index == 2 {
                                            resetShopData()
                                            selectedOptions = "accept_offers"
                                            fetchProduct()
                                        }
                                    })
                                
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
                        }
                        
                        else if selectedTab == "Shows" {
                            LazyVGrid(columns: columns, spacing: 6) {
                                ForEach(scheduleShowArr.indices, id: \.self) { i in
                                    let show = scheduleShowArr[i]
                                    ImageCollectionView(profileImg: show.user?.profile_image ?? "",
                                                        profileName: show.user?.username ?? show.user?.name ?? "".capitalizingFirstLetter(),
                                                        textSize: 14.0,
                                                        image: show.imgThumbnail?.first ?? "",
                                                        category: show.category?.name ?? "",
                                                        title2:show.title ?? "",
                                                        categorySize: 14,
                                                        title2Size: 16.0,
                                                        liveCount:  0,
                                                        onTapProfile: {
                                        //                                userId = "\(show.user?.id ?? 0)"
                                        //                                navigateToProfile = true
                                    },onTapProfileName: {
                                        //                                userId = "\(show.user?.id ?? 0)"
                                        //                                navigateToProfile = true
                                    },onTapMainImage: {
                                        print(" tapped the card!,inex \(index)")
                                        //                                self.index = i
                                        //                                userId = "\(show.user?.id ?? 0)"
                                        //                                navigateToLiveStream = true
                                    },onTapCategory: {
                                        //                                self.category = show.category?.name ?? ""
                                        //                                navigateToCategoryDetailScreen = true
                                    })
                                    //                                .background(.white)
                                    .cornerRadius(10)
                                    .onAppear {
                                        Task {
                                            await handlePagination(for: .shows, index: i)
                                        }
                                    }
                                }
                            } .padding(.vertical,3)
                                .padding(.horizontal,8)
                        }
                        
                        else if selectedTab == "Reviews" {
                            ForEach(totalRatingArr, id: \.id) { review in
                                ReviewCard(
                                    username: review.user.name ?? "",
                                    profileImage: review.user.profile_image ?? "",
                                    rating: Double(review.overallRating ?? "0.0") ?? 0.0,
                                    comment: review.comment
                                )
                                .padding(.horizontal,0)
                            }
                        }else{
                            
                        }
                    }
                    //                .padding()
                }
                
                .edgesIgnoringSafeArea(.all)
                
                
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.95) {
            ProductDetailSheet(
                onDismiss : {
                    self.showSellSheet = false
                    productId = 0
                },
                productID: $productId,showoption: false
                
            )
        }
        .toast(isPresenting: $showToast) {
            AlertToast(displayMode: .alert, type: .regular, title: toastMessage)
        }
        .bottomSheet(isPresented: $showNotify,height: screenHeight * 0.45) {
            NotifyMeBottomSheet(
                userId: $profileId, profileImage: profileData.profile_image ?? "" ,
                username: profileData.username ?? "",
                showParentToast: $showToast,
                parentToastMessage: $toastMessage,
                onDismiss: {
                    self.showNotify = false
                }
            )
        }
        .bottomSheet(isPresented: $showError,
                     height: screenHeight * 0.35,
                     topBarCornerRadius: 25,
                     contentBackgroundColor: Color(.systemBackground),
                     topBarBackgroundColor: Color(.systemBackground),
                     showTopIndicator: false,
                     onDismiss: {
                showError = false
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                }, onSecondaryClick: {
                    withAnimation { showError = false }
                })
            .background(Color(.systemBackground))
            .cornerRadius(25, corners: [.topLeft, .topRight])
        })
        //        .overlay(
        //            NotifyMeBottomSheet(
        //                userId: $profileId, profileImage: profileData.profile_image ?? "" ,
        //                username: profileData.username ?? "",
        //                showParentToast: $showToast,
        //                parentToastMessage: $toastMessage,
        //                onDismiss: {
        //                    self.showNotify = false
        //                }
        //            )
        //        )
        
        .bottomSheet(
            isPresented: $isTipAmountButtoClicked,
            height: screenHeight * 0.55,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                isTipAmountButtoClicked = false
            },
            content: {
                SendTipView(
                    sellerId: "\(profileData.id ?? -1)" ?? "",
                    onClose: {
                        isTipAmountButtoClicked = false
                    },
                    onSendTip: {
                        print("Sent tip")
                        isTipAmountButtoClicked = false
                    })
            }
        )
        
        .bottomSheet(isPresented: $showReportSheet,
                     height: screenHeight * 0.50,
                     topBarCornerRadius: 25,
                     contentBackgroundColor: Color(.white),
                     topBarBackgroundColor: Color(.white),
                     showTopIndicator: false,
                     onDismiss: {
            showReportSheet = false
        }) {
            ReportSellerView(onReportSellerClicked: { categoryId, message in
                Task {
                    await reportSeller(categoryId: categoryId, message: message)
                }
            })
            .keyboardAwarePadding()
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
        .onAppear{
            
            let param = ProfileParamRequest(id: id)
            print(param)
            Task{
                guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await self.viewModel.getProfile(param:param)
                profileSuccess()
                if isComeFrom == "Home"{
                    selectedTab = "Shows"
                    await self.viewModel.getMyScheduleShow(parameters: GetMyScheduleShowRequest(type: "upcoming", user_id: Int(id), page: currentPage))
                    await SVProgressHUD.dismiss()
                    scheduleShowSuccess()
                }else{
                    selectedTab = "Shop"
                    resetShopData()
                    fetchProduct()
                }
            }
        }
        CusNavLink(
            doNavigate: $navigateToChat,
            destination: ChatScreen(
                viewModel: ChatModel(
                    currentUserId: "\(UserDefaults.userId)",
                    currentUserName: UserDefaults.fullName,
                    currentUserImage: UserDefaults.profileURL,
                    otherUserId: id,
                    otherUserName: userName,
                    otherUserImage: userImage
                )
            )
        )
        //        CusNavLink(
        //            doNavigate: $isTipAmountButtoClicked,
        //            destination: PayoutView(sellerID: id)
        //        )
    }
    
    func computeRoomId(senderId: String, receiverId: String) -> String {
        let sortedIds = [senderId, receiverId].sorted()
        return "\(sortedIds[0])_chats_\(sortedIds[1])"
    }
    
    @MainActor
    func reportSeller(categoryId: Int?, message: String?) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showHud = true
            return
        }
        guard let cId = categoryId, let msg = message else  {
            return
        }
        do {
            SVProgressHUD.show()
            
            let request = SellerReportRequest(seller_id: profileData.id ?? 0,
                                              category_id: cId,
                                              notes: msg)
            try await showViewModel.reportSeller(request: request)
            await SVProgressHUD.dismiss()
            let response = showViewModel.reportSellerResponse
            
            if response.status == "success" {
                hudMsg = response.message ?? ""
                showhudSuccess = true
                showReportSheet = false
            } else {
                throw NSError(
                    domain: "APIError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey : response.message ?? "Something went wrong"]
                )
            }
        }
        catch {
            print("❌ Failed to load categories:", error.localizedDescription)
            
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? error.localizedDescription,
                primaryBtnText: "",
                secondaryBtnText: "OK"
            )
            
            showError = true
        }
    }
    
    
    func profileSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.getProfileDict
        if response.status == "success" {
            profileData = response.data ?? ProfileModel()
            isFollowing = profileData.is_following ?? false
            profileId = profileData.id ?? 0
            userName = response.data?.username ?? ""
            userImage = response.data?.profile_image ?? ""
//            if !isForFollow{
//                Task{
//                    guard Reachability.isConnectedToNetwork() else {
//                        hudMsg = "No Internet Connection"
//                        showhud = true
//                        return
//                    }
//                    SVProgressHUD.show()
//                    let request  = ProductRequest(user_id: id, page: currentPage)
//                    await self.productViewModel.getProductsData(parameters: request)
//                    await SVProgressHUD.dismiss()
//                    success()
//                }
//            }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
    
//    //MARK: success.
//    func success(){
//        SVProgressHUD.dismiss()
//        let response = viewModel.productDetailsResponseDict
//        if response?.status == "success" {
//            productArr = response?.data ?? []
//            
//        } else {
//            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
//            withAnimation(.snappy) { showError = true }
//        }
//    }
    
    //MARK: scheduleShowSuccess.
    func scheduleShowSuccess(){
        SVProgressHUD.dismiss()
        let response = viewModel.getMyScheduleShowResponseDict
        if response?.status == "success" {
            scheduleShowArr = response?.data ?? []
            
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
    
    //MARK: ratingSuccess.
    func ratingSuccess(){
        SVProgressHUD.dismiss()
        let response = viewModel.getTotalRatingResponseDict
        if response?.status == "success" {
            totalRatingArr = response?.data.ratings ?? []
            
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
    
    func handlePagination(for tab: ProfileTabType, index: Int) async {
        currentPage = currentPage + 1
        switch tab {
        case .shop:
            let isLast = index == productData.count - 1
            let total = productViewModel.productsResponse1?.total ?? 0
            
            if isLast && productData.count < total {
                fetchProduct(isLoaderShown: true)
            }
            
        case .shows:
            let isLast = index == scheduleShowArr.count - 1
            let total = viewModel.getMyScheduleShowResponseDict?.total ?? 0
            
            if isLast && scheduleShowArr.count < total {
                SVProgressHUD.show()
                await viewModel.getMyScheduleShow(parameters: GetMyScheduleShowRequest(type: "upcoming", user_id: Int(id) ?? 0, page: currentPage))
                await SVProgressHUD.dismiss()
                if viewModel.getMyScheduleShowResponseDict?.status == "success" {
                    currentPage = currentPage
                    scheduleShowArr.append(contentsOf: viewModel.getMyScheduleShowResponseDict?.data ?? [])
                }
            }
            
        case .reviews:
            // Add this once your review API is paginated
            break
            
        case .clips:
            // Add this once your clips API is paginated
            break
        }
    }
}

//MARK: ProfileHeaderView
struct ProfileHeaderView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appRootManager: AppRootManager
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var showToast = false
    @State var toastMessage = ""
    @State  var showhud = false
    @State  var hudMsg = ""
    
    @Binding var name : String
    var email : String
    @Binding var profileImage : String
    var followers : String
    var following : String
    var bio : String
    
    var onTapNotify: () -> () = {}
    var onTapMore: () -> () = {}
    
    @Binding var sellerID : String
    @State var viewModel = ProfileViewModel()
    @State private var navigateToRating = false
    @State private var navigateToHome = false
    @State private var showMoreMenu = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background image
            VStack(spacing: 0) {
                Image("IMG_2678")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                Spacer()
            }
            
            // Back Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.top, 30)
            .padding(.leading, 16)
            .zIndex(2)
            
            // Profile Image
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    AsyncImage(url: URL(string: profileImage)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView().frame(width: 100, height: 100)
                        case .success(let image):
                            image
                                .resizable()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .frame(width: 100, height: 100)
                                .offset(x: 16, y: 160)
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .frame(width: 100, height: 100)
                                .offset(x: 16, y: 160)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    Spacer()
                }
            }
            
            // Tap outside to dismiss menu
            if showMoreMenu {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMoreMenu = false
                        }
                    }
                    .zIndex(1)
            }
            
            // More menu
            if showMoreMenu {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        showMoreMenu = false
                        navigateToRating = true
                    }) {
                        Text("Rate Seller")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Divider()
                    
                    Button(action: {
                        showMoreMenu = false
                        Task{
                            guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            SVProgressHUD.show()
                            let param = BlockUserRequest(blocked_id: Int(sellerID) ?? 0)
                            await self.viewModel.blockUser(param: param)
                            await SVProgressHUD.dismiss()
                            blockSuccess()
                        }
                    }) {
                        Text("Block Seller")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Divider()
                    
                    Button(action: {
                        showMoreMenu = false
                        // Handle Report
                        onTapMore()
                    }) {
                        Text("Report")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 8)
                .frame(width: 180)
                .padding(.top, 80) // Align under button
                .padding(.trailing, 16)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(2)
            }
        }
        .frame(height: 220)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        Spacer()
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.custom(poppinsBold, size: 16.0))
                    
                    Text(email)
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    let buttonSize: CGFloat = 44 // Adjust size as needed
                    
                    Button(action: {
                        onTapNotify()
                    }) {
                        Image(systemName: "bell")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black)
                            .padding(12)
                            .frame(width: buttonSize, height: buttonSize)
                            .fontWeight(.semibold)
                    }
                    
                    Button(action: {
                        // Share action
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black)
                            .padding(12)
                            .frame(width: buttonSize, height: buttonSize)
                            .fontWeight(.semibold)
                    }
                    
                    Button(action: {
                        withAnimation {
                            showMoreMenu.toggle()
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.black)
                            .padding(12)
                            .frame(width: buttonSize, height: buttonSize)
                            .fontWeight(.semibold)
                    }
                }
                
            }
            
            HStack(spacing: 16) {
                Text("\(followers) Followers")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                Text("\(following) Following")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)
            }
            
            Text(bio)
                .font(.custom(poppinsRegular, size: 13.0))
                .foregroundColor(.gray)
        }
        .padding(.vertical,8)
        .padding(.horizontal, 8)
        CusNavLink(doNavigate: $navigateToRating, destination: RateSellerView(sellerID: Int(sellerID) ?? 0, sellerImage: $profileImage, sellerName: $name))
        CusNavLink(doNavigate: $navigateToHome, destination: HomeViewScreen(showCategory: .constant(""), comeFromExploreScreen: .constant(false)))
        
    }
    
    
    //MARK: blockSuccess.
    func blockSuccess(){
        SVProgressHUD.dismiss()
        let response = viewModel.blockUserResponseDict
        if response?.status == "success" {
            hudMsg = response?.message ?? ""
            showhud = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                //                navigateToHome = true
                self.presentationMode.wrappedValue.dismiss()
            }
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
}


//MARK: ProfileActionsView.
struct ProfileActionsView: View {
    @Binding var isFollowing: Bool
    var onTapFollow :() -> () = { }
    var onTapMessage :() -> () = { }
    var onTapTipAmount :() -> () = { }
    
    
    var body: some View {
        HStack(spacing: 16) {
            Button(isFollowing ? "Unfollow" : "Follow") {
                self.onTapFollow()
            }
            .font(.custom(poppinsSemiBold, size: 14.0))
            .frame(maxWidth: .infinity)
            .frame(height: 18)
            .padding()
            .background(Color(UIColor.systemGray5))
            .foregroundColor(.defaultTheme)
            .cornerRadius(12)
            
            Button("Message") {
                self.onTapMessage()
            }
            .font(.custom(poppinsSemiBold, size: 14.0))
            .frame(maxWidth: .infinity)
            .frame(height: 18)
            .padding()
            .background(.defaultTheme)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Button(action: {
                // Handle action
                self.onTapTipAmount()
            }) {
                Image(systemName: "dollarsign.circle")
                    .resizable()
                    .frame(width:32,height: 32)
                    .foregroundColor(.defaultTheme)
                    .font(.title2)
            }
        }
        .padding(.horizontal,12)
    }
}

struct ProfileTabsView: View {
    let tabs = ["Shop", "Shows", "Reviews", "Clips"]
    @Binding var selectedTab: String
    var onTabSelected: (String) -> Void = { _ in }
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                VStack {
                    Text(tab)
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .fontWeight(selectedTab == tab ? .bold : .regular)
                        .foregroundColor(selectedTab == tab ? .defaultTheme : .gray)
                    if selectedTab == tab {
                        Capsule().fill(Color.defaultTheme).frame(height: 3)
                    } else {
                        Capsule().fill(Color.clear).frame(height: 3)
                    }
                }
                .onTapGesture {
                    selectedTab = tab
                    onTabSelected(tab)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 13)
    }
}

struct TabIcon: View {
    var title: String
    var systemImage: String
    var selected: Bool = false
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .foregroundColor(selected ? .purple : .gray)
            Text(title)
                .font(.custom(poppinsRegular, size: 13.0))
                .foregroundColor(selected ? .purple : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    ProfileScreen()
//}

extension ProfileScreen {
    
    private func resetShopData() {
        productData = []
        currentPage = 1
        canLoadMore = true
        isFetchingMore = false
    }
    
    
    func fetchProduct(isLoaderShown: Bool = true) {
        guard let sellerId = profileData.id else  {
            print("seller id is not present")
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
                        message:  errorDesc(error: error, message: productViewModel.errorMessage),
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText: ""
                    )
                    showError = true
                },
                onSuccess: {
                    productSuccess()
                }
            ) {
                let request = ProductRequest(user_id: "\(sellerId)",
                                             search: searchText, page: currentPage,
                                             sale_type: selectedOptions,
                                             sort_by: selectedSort
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
                message: scheduleViewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
        isFetchingMore = false
    }
}
