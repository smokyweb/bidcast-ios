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
    @Binding var id : String
    @Binding var  isComeFrom : String
    @Binding var userName : String
    @Binding var userImage : String
    @State var isLoading: Bool = false
    @State var currentPage = 1
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var profileData = ProfileModel()
    @State var showSellSheet = false
    @State var showNotify = false
    @State var profileId = 0
    @State  var showhud = false
    @State  var hudMsg = ""
    @State  var productData = ProductListingDataModel()
    @State var isFollowing = false
    @State var productId : Int = 0
    @State var productArr = [ProductListingDataModel]()
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
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        ProfileHeaderView(name: profileData.name?.capitalizingFirstLetter() ?? "",
                                          email: profileData.username ?? "",
                                          profileImage: profileData.profile_image ?? "",
                                          followers: "\(profileData.follower_count ?? 0)",
                                          following: "\(profileData.following_count ?? 0)" ,
                                          bio: profileData.bio ?? "Professional photographer specializing in portrait and wedding photography. Available for bookings worldwide.",
                                          onTapNotify: {
                            showNotify = true
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
                                           onTapMessage: {
                            navigateToChat = false
                            
                        })
                        
                        ProfileTabsView(selectedTab: $selectedTab) { tab in
                            print("Selected Tab: \(tab)")
                            Task {
                                switch tab {
                                case "Shop":
                                    print("")
                                    Task{
                                        guard Reachability.isConnectedToNetwork() else {
                                            hudMsg = "No Internet Connection"
                                            showhud = true
                                            return
                                        }
                                        SVProgressHUD.show()
                                        await self.viewModel.productDetails(parameters: UserProductRequest(user_id: Int(id) ?? 0,page : currentPage))
                                        await SVProgressHUD.dismiss()
                                        success()
                            
                                    success()
                                }
                                //                                await viewModel.fetchShopItems()
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
                        SearchAndFiltersView()
                        ProductListView(
                            prouduct: $productArr,
                            onTapProduct: { index in
                                productData = productArr[index]
                                productId = productData.id ?? 0
                                showSellSheet = true
                            },
                            onItemAppear: { index in
                                Task {
                                    await handlePagination(for: .shop, index: index)
                                }
                            }
                        )
                    }

                    else if selectedTab == "Shows" {
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(scheduleShowArr.indices, id: \.self) { i in
                                let show = scheduleShowArr[i]
                                //                            ShowMyScheduleCardView(show: show, onTap: {
                                //                                showID = "\(show.id ?? 0)"
                                //                                isLive = show.isLive ?? false
                                //                                navigateToReherseal = false
                                //                            })
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
                                    profileImage: Image("defaultUser"),
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
                
                .edgesIgnoringSafeArea(.top)
                .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.95) {
                    ProductDetailSheet(
                        onDismiss : {
                            self.showSellSheet = false
                            productId = 0
                        },
                        productID: $productId
                        
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
                
            }
            
        }
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
                if isComeFrom == "Home" {
                    selectedTab = "Shows"
                    await self.viewModel.getMyScheduleShow(parameters: GetMyScheduleShowRequest(type: "upcoming", user_id: Int(id), page: currentPage))
                    await SVProgressHUD.dismiss()
                    scheduleShowSuccess()

                    }else{
                        selectedTab = "Shop"
                        Task{
                           guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            SVProgressHUD.show()
                            await self.viewModel.productDetails(parameters: UserProductRequest(user_id: Int(id) ?? 0,page : currentPage))
                            await SVProgressHUD.dismiss()
                            success()
                        }
                    }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        CusNavLink(
            doNavigate: $navigateToChat,
            destination: ChatScreen(
                viewModel: ChatViewModel(
                    currentUserId: "\(UserDefaults.userId)",
                    currentUserName: UserDefaults.userName,
                    currentUserImage: UserDefaults.profileURL,
                    otherUserId: id,
                    otherUserName: userName,
                    otherUserImage: userImage, chatPath: $chatPath
                )
            )
        )
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
            if !isForFollow{
                Task{
                    guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    SVProgressHUD.show()
                    await self.viewModel.productDetails(parameters: UserProductRequest(user_id: Int(id) ?? 0, page: currentPage))
                    await SVProgressHUD.dismiss()
                    success()
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
    
    //MARK: success.
    func success(){
        SVProgressHUD.dismiss()
        let response = viewModel.productDetailsResponseDict
        if response?.status == "success" {
            productArr = response?.data ?? []
            
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
    
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
        let nextPage = currentPage + 1
        switch tab {
        case .shop:
            let isLast = index == productArr.count - 1
            let total = viewModel.productDetailsResponseDict?.total ?? 0
            
            if isLast && productArr.count < total {
                SVProgressHUD.show()
                await viewModel.productDetails(parameters: UserProductRequest(user_id: Int(id) ?? 0, page: nextPage))
                await SVProgressHUD.dismiss()
                if viewModel.productDetailsResponseDict?.status == "success" {
                    currentPage = nextPage
                    productArr.append(contentsOf: viewModel.productDetailsResponseDict?.data ?? [])
                }
            }
            
        case .shows:
            let isLast = index == scheduleShowArr.count - 1
            let total = viewModel.getMyScheduleShowResponseDict?.total ?? 0
            
            if isLast && scheduleShowArr.count < total {
                SVProgressHUD.show()
                await viewModel.getMyScheduleShow(parameters: GetMyScheduleShowRequest(type: "upcoming", user_id: Int(id) ?? 0, page: nextPage))
                await SVProgressHUD.dismiss()
                if viewModel.getMyScheduleShowResponseDict?.status == "success" {
                    currentPage = nextPage
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
    
    var name : String
    var email : String
    var profileImage : String
    var followers : String
    var following : String
    var bio : String
    var onTapNotify: () -> () = {}
    var onTapMore: () -> () = {}
    
    @Binding var sellerID : String
    @State private var navigateToRating = false
    @State private var showMoreMenu = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background image
            VStack(spacing: 0) {
                Image("IMG_2678")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                Spacer()
            }
            
            // Back Button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
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
                            ProgressView().frame(width: 80, height: 80)
                        case .success(let image):
                            image
                                .resizable()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .frame(width: 80, height: 80)
                                .offset(x: 16, y: 160)
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .frame(width: 80, height: 80)
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
                        // Handle Block Seller
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
                    Button(action: {
                        onTapNotify()
                    }) {
                        Image(systemName: "bell")
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    
                    Button(action: {
                        // Share action
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                    
                    Button(action: {
                        withAnimation {
                            showMoreMenu.toggle()
                        }
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 2)
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
        .padding(.horizontal, 8)
        CusNavLink(doNavigate: $navigateToRating, destination: RateSellerView(sellerID: Int(sellerID) ?? 0, sellerImage: profileImage, sellerName: name))
    }
}


//MARK: ProfileActionsView.
struct ProfileActionsView: View {
    @Binding var isFollowing: Bool
    var onTapFollow :() -> () = { }
    var onTapMessage :() -> () = { }
    
    
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
                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                    if selectedTab == tab {
                        Capsule().fill(Color.blue).frame(height: 3)
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

struct SearchAndFiltersView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("What are you looking for?", text: .constant(""))
                    .font(.custom(poppinsRegular, size: 13.0))
                    .padding(.leading, 12)
                Image(systemName: "slider.horizontal.3")
                    .padding(.trailing, 12)
            }
            .frame(height: 44)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            
            HStack {
                ForEach(["Filter", "Sort", "Buy Now", "Category"], id: \.self) { title in
                    Button(title) {
                        // Handle filter
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
                }
                
            }
            .padding(.horizontal)
        }
        .padding(.horizontal,12)
    }
}

struct ProductListView: View {
    @Binding var prouduct: [ProductListingDataModel]
    @State var onTap = false
    var onTapProduct: (Int) -> () = { _ in }
    var onItemAppear: ((Int) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(prouduct.indices, id: \.self) { index in
                let item = prouduct[index]
                ProductCardView(
                    imageName: item.images?.first ?? "",
                    productName: item.title ?? "",
                    description: item.description ?? "",
                    pricing: "$\(item.pricing ?? 0)"
                )
                .onTapGesture {
                    self.onTap.toggle()
                    self.onTapProduct(index)
                }
                .onAppear {
                    onItemAppear?(index)
                }
            }
        }
    }
}


struct ProductCardView: View {
    var imageName: String = "ic_bidder"
    var productName = "Product Name"
    var description = "Category - Condition"
    var pricing = "$2"
    var body: some View {
        HStack {
            
            //                Image(imageName)
            //                    .resizable()
            //                    .frame(width: 80, height: 80)
            //                    .cornerRadius(10)
            AsyncImage(url: URL(string: imageName)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                case .failure:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .frame(width: 80, height: 80)
                        .offset(x: 16, y: 160)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading) {
                Text(productName)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                Text(description)
                    .foregroundColor(.gray)
                    .font(.custom(poppinsSemiBold, size: 11.0))
                Text(pricing)
                    .font(.custom(poppinsBold, size: 13.0))
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
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
