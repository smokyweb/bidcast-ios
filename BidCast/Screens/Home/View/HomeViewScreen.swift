//
//  HomeViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD

struct HomeViewScreen: View {
    
    @State private var selectedButton: HomeButton = .For_you
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor

    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var navigateToLiveStream = false
    @State var index = 0
    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)
    @Binding var showCategory : String
    @State var viewModel = HomeViewModel()
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
    
    @State var navigateToCategoryDetailScreen : Bool = false
    
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
                        SearchView()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    SegmentedControlView(segments: HomeButton.allCases, selectedSegment:$selectedButton, isWithBorder: true)
                    ButtonTitleLabel(
                        titles: ["Live Now", "Popular", "Coming Soon"],
                        fontValue: 16,
                        textColor: .blue
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
                            await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: selection,category: showCategory))
                            await SVProgressHUD.dismiss()
                            self.success()
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
                                                    liveCount: item.viewer_count ?? 0,
                                                    onTapProfile: {
                                    userId = "\(item.user?.id ?? 0)"
                                    navigateToProfile = true
                                },onTapProfileName: {
                                    userId = "\(item.user?.id ?? 0)"
                                    userImage = item.user?.profile_image ?? ""
                                    userName = item.user?.username ?? ""
                                    navigateToProfile = true
                                },onTapMainImage: {
                                    print(" tapped the card!,inex \(index)")
                                    self.index = index
                                    userId = "\(item.user?.id ?? 0)"
                                    userImage = item.user?.profile_image ?? ""
                                    userName = item.user?.username ?? ""
                                    navigateToLiveStream = true
                                },onTapCategory: {
                                    self.category = item.category?.name ?? ""
                                    navigateToCategoryDetailScreen = true
                                })
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
            
            CusNavLink(doNavigate: $navigateToLiveStream, destination: LiveStream(currentStreamIndex :self.$index, userId : $userId,comeFromHome: $navigateToLiveStream))
            CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(id:$userId,isComeFrom : .constant("Home"),userName: $userName,userImage: $userImage))

            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
            CusNavLink(doNavigate: $navigateToCategoryDetailScreen, destination: HomeViewScreen(showCategory:$category,comeFromExploreScreen : $navigateToCategoryDetailScreen))
        }
        .background(.bg.opacity(0.1))
        .onAppear{
            NotificationCenter.default.addObserver(forName: Notification.Name("Notification"), object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo {
                    print("🔔 Babumoshai, Notification Payload: \(userInfo)")
                    let type = userInfo["type"] as? String ?? ""
//                           let senderName = userInfo["sender_name"] as? String ?? ""
//                           let senderImage = userInfo["sender_image"] as? String ?? ""
//                           let title = userInfo["title"] as? String ?? ""
//                           let body = userInfo["body"] as? String ?? ""

                    if type == "bid_show_start" {
//                        navigateToLiveStream = true
                    }
                }
            }
            Task{
                liveShowsData.removeAll()
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: self.selectedTab,category: showCategory))
                await SVProgressHUD.dismiss()
                self.success()
                await self.viewModel.getProfile()
                if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                    let response = self.viewModel.accountInfo.data
                    UserDefaults.isFirstShowCreated = response?.is_FirstShowCreated ?? false
                    UserDefaults.profileURL = response?.profile_image ?? ""
                    UserDefaults.userName = response?.name ?? ""
                    UserDefaults.buyerVerafied = response?.buyer_identity_status ?? ""
                    UserDefaults.sellerVerafied = response?.seller_identity_status ?? ""
                    UserDefaults.sellerAddress = response?.has_shipping_address ?? false
                    UserDefaults.hasCardAdded = response?.has_card_added ?? false
                    UserDefaults.userEmail = response?.email ?? ""
                }else{
                    
                }
            }
            
            FirebaseManager.shared.observeNewLiveSessionNodes {
                   
                Task{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    
                    liveShowsData.removeAll()
                    SVProgressHUD.show()
                    await self.viewModel.getLiveShows(param: GetLiveShowsRequest(type: "live",category: showCategory))
                    await SVProgressHUD.dismiss()
                    self.success()
                }
               }
        }
        .onDisappear {
            FirebaseManager.shared.removeNewSessionObserver()
        }
    }
    
    
    
    func success() {
        let response = viewModel.liveShowsResponse
        if response.status == "success" {
            FirebaseManager.shared.fetchAllLiveSessions { firebaseRoomIds in
                let validShows = response.data?.filter { show in
                    guard let roomId = show.room_id else { return false }
                    return firebaseRoomIds.contains(roomId)
                }

                DispatchQueue.main.async {
                    liveShowsData = validShows ?? []
                    print("✅ Loaded \(liveShowsData.count) live shows")

                    // 🔁 Loop through all valid live shows and observe each viewer count
                    for (index, show) in liveShowsData.enumerated() {
                        if let roomId = show.room_id {
                            FirebaseManager.shared.observeViewerCount(roomId: roomId) { newCount in
                                DispatchQueue.main.async {
                                    // Ensure index is still valid
                                    if index < liveShowsData.count {
                                        liveShowsData[index].viewer_count = newCount
                                    }
                                }
                            }
                        }
                    }
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
}

//#Preview {
//    HomeViewScreen()
//}

enum HomeButton: String, CaseIterable, CustomStringConvertible {
    case For_you = "For You"
    case collectibles = "Collectibles"
    case trading = "Trading"
    case purchases = "Purchases"
    case savedItems = "Saved Items"
    
    var description: String {
        return rawValue
    }
}



struct ButtonTitleLabel: View {
    
    var titles: [String] = ["Live Now", "Popular", "Coming Soon"]
    var fontName = poppinsRegular
    var selectedFontName = poppinsSemiBold
    var fontValue: CGFloat = 18
    var textColor: Color = .gray
    var selectedColor: Color = .black
    var separatorColor: Color = .gray
    var spacing: CGFloat = 12
    var onTap: ((String) -> Void)? = nil
    
    @State var selectedTitle: String = "Live Now"
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(titles.indices, id: \.self) { index in
                HStack(spacing: spacing) {
                    let title = titles[index]
                    
                    Text(title)
                        .font(.custom(title == selectedTitle ? selectedFontName : fontName, fixedSize: fontValue))
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
        }
        .padding(.horizontal, 6)
    }
}


