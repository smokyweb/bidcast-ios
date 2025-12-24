
//
//  LiveStream.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI
import SVProgressHUD
import ZegoExpressEngine
import AlertToast
import MillicastSDK
import SocketIO

enum SwitchStreamType{
    case up
    case down
    case none
}

struct CommentModel: Codable, Identifiable, Equatable {
    let id = UUID()
    let image: String?
    let username: String?
    let message: String?
    let userId: String?
    let roomId: String?
    
    enum CodingKeys: String, CodingKey {
        case image = "user_image"
        case username = "user_name"
        case message
        case userId = "user_id"
        case roomId = "room_id"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Safe decode for image, username, message, roomId
        image = (try? container.decodeIfPresent(String.self, forKey: .image)) ?? ""
        username = (try? container.decodeIfPresent(String.self, forKey: .username)) ?? ""
        message = (try? container.decodeIfPresent(String.self, forKey: .message)) ?? ""
        roomId = (try? container.decodeIfPresent(String.self, forKey: .roomId)) ?? ""
        
        // Handle userId as String or Int or nil
        if let intId = try? container.decodeIfPresent(Int.self, forKey: .userId) {
            userId = String(intId)
        } else if let strId = try? container.decodeIfPresent(String.self, forKey: .userId) {
            userId = strId
        } else {
            userId = ""
        }
    }
}

struct LiveStream: View {
    @Binding var currentRoomID : String
    @Binding var categoryName : String
    @State private var commentText = ""
    @State var comments: [CommentModel] = []
    @State var id : String = ""
    @State var userName : String = ""
    @State var userImage : String = ""
    @State var dragOffset = CGSize.zero
    @State var navigateToProfile = false
    @State private var swipeConfirmed = false
    @Binding var currentStreamIndex : Int
    
    @State private var verticalDragOffset = CGSize.zero
    @GestureState private var verticalGestureOffset = CGSize.zero
    @State var roomID = [String]()
    @State var streamID = [String]()
    var viewModel = LiveShowsViewModel()
    @State var homeViewModel = HomeViewModel()
    @State var liveShowsData = [RoomModel]()
    
    @State var showhudSuccess: Bool = false
    @State var showBlockSeller: Bool = false
    
    @State var productData = [ProductDataModel1]()
    @State var BiddingDetail = BiddingModel()
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "Stream Ended", message: "The live stream has ended.", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var showErrorPopup: Bool = false
    @State var viewwerCount = 0
    @Binding var userId : String
    @Environment(\.presentationMode) var presentationMode
    @State var titleText: String = ""
    @ObservedObject var zegoManager = ZegoManager.shared
    @ObservedObject var chatManager = ZIMChatManager.shared
    @StateObject private var keyboardResponder = KeyboardResponder()
    var localUserID = "\(UserDefaults.userId)"
    @State private var previewResetTrigger = false
    @State private var showStartTime: Date? = nil
    @State private var liveElapsedTime: String = "00:00:00"
    @State var isFollow = false
    @State var showVerificationSheet = false
    @State var navigateToChat = false
    @State var showPaymentShipping = false
    @State var navigateToAddCardScreen = false
    @State var navigateToShipping : Bool = false
    @State var navigateToSellerVerification = false
    @State var hasTrustedBuyerSheetOpen = false
    @State var sheduleShowID : Int = 0
    @State var showToast = false
    @State var toastMessage = ""
    @State var winnerProfileImage : String = ""
    @State var winnerName : String = ""
    @State var winnerAmount : String = ""
    @State var winnerProfileID : Int = 0
    @State private var navigateToEditPayment = false
    @State private var navigateToEditAddress = false
    @State private var navigateToProductList = false
    @State private var showReportSheet = false
    @State var socket: SocketIOClient!
    @State var socketManager: SocketManager!
    @State var rooms: [RoomModel] = []
    @State var currentIndex : Int = 0
    @State var onRoomsUpdated: (([String]) -> Void)?
    @State private var animate = false
    @State var maxBidUserName: String = "Demo UserName"
    @Binding var agoraToken: String
    
    @State var isFollowing: Bool = false
    
    @State private var sellerInfo: SellerInfoResponse? = nil
    
    @State private var followSheetTask: Task<Void, Never>? = nil
    
    var currentProduct: ProductDataModel1? {
        productData.first
    }
    
    @State private var showPollView: Bool = false
    @State private var currentPollModel:PollModel?
    @State private var remainingTimer: Int = 0
    
    @State private var showLivePollScreen: Bool = false
    
    @State var hasHostEndedRoom: Bool = false
    
    var tabBarHeight: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 49
    }
    
    @State private var shareItems: [Any] = []
    @State private var showSystemShareSheet = false
    @State var showHud = false
    @State var hudMsg = ""
    
    @State private var currentPrice: Double = 1.0
    @State private var nextBidPrice: Double = 1.0
    @State private var countdown: Int = 10
    @State private var isBiddingActive: Bool = false
    @State private var priceTimer: Timer?
    @State var countdownTimer: Timer?
    
    let totalSwipeWidth: CGFloat = UIScreen.main.bounds.width - 80
    
    @State var navigateToBuyer = false
    @Binding var comeFromHome : Bool
    @State  var currentBottomSheet: MenuAction? = nil
    
    @State var sellerId = ""
    @State var showId = ""
    
    var filteredActions: [MenuAction] {
        if let userId = viewModel.liveShowsResponse.data?.first?.user?.id,
           UserDefaults.userId != userId {
            return MenuAction.allCases.filter { $0 != .cart }
        }else{
            return MenuAction.allCases.filter { $0 != .cart }
        }
    }
    
    @State var showSheet: Bool = false
    @State var showTipSheet: Bool = false
    @State var showSellerProfileSheet: Bool = false
    @State var showFollowSheet: Bool = false
    @State var winnerSheet: Bool = false
    @State var walletPaymentSheet: Bool = false
    @State var maxBidAmountSheet : Bool = false
    @State private var renderer = MCAcceleratedVideoRenderer()
    @State var currentProductID: String? = nil
    @State var productId: Int = 0
    @State var categoryId : Int = 0
    
    var sheetHeight: CGFloat {
        switch currentBottomSheet {
        case .paperclip: return screenHeight * 0.5
            
        case .share: return screenHeight * 0.6
        case .wallet: return screenHeight * 0.39
        case .cart: return screenHeight * 0.7
        default: return screenHeight * 0.65
        }
    }
    @StateObject var socketManagerChat = SocketManagerService.shared
    
    @StateObject var profileViewModel = ProfileViewModel()
    
    @State var currentProductIndex = 0
    
    @StateObject private var agoraManager = AgoraManager(asHost: false)
    @StateObject private var pipManager = AgoraPiPManager.shared
    @State private var isHost = false
    
    @Binding var category : String
    @Binding var search : String
    @Binding var currentPage : Int
    
    @State private var chatPath: String = ""
    
    @State var messageHeight: CGFloat = 40
    let maxVisibleMessages = 3
  
    
    @State var showItemDetailSheet = false
    
    @State private var auctionStartedRooms: Set<String> = []
    var isAuctionStartedForCurrentRoom: Bool {
        auctionStartedRooms.contains(currentRoomID)
    }
    @State var auctionedProductData: ProductDataModel1? = nil
    @State  var  boosts = [BoostModel]()
    
    var body: some View {
        ZStack {
            baseContentLayer
            toastLayer
            bottomSheetLayer
            
            CusNavLink(
                doNavigate: $navigateToProfile,
                destination: ProfileScreen(
                    id: $id,
                    isComeFrom: .constant(""),
                    userName: $userName,
                    userImage: $userImage
                )
            )
            
            CusNavLink(
                doNavigate: $navigateToBuyer,
                destination: TrustedBuyerScreen(comeFromHome: $comeFromHome)
            )
            
            CusNavLink(
                doNavigate: $navigateToAddCardScreen,
                destination: PaymentAndShipping_Screen()
            )
            
            CusNavLink(
                doNavigate: $navigateToProductList,
                destination: ProductShopListScreen(
                    sellerId: $sellerId ,categoryIds : $categoryId
                )
            )
            
            CusNavLink(
                doNavigate: $navigateToShipping,
                destination: PaymentAndShipping_Screen()
            )
            
            CusNavLink(
                doNavigate: $navigateToEditPayment,
                destination: PaymentAndShipping_Screen()
            )
            
            CusNavLink(
                doNavigate: $navigateToEditAddress,
                destination: PaymentAndShipping_Screen()
            )
            
            CusNavLink(
                doNavigate: $showItemDetailSheet,
                destination: ProductDetailView(
                    onDismiss: {
                        self.showItemDetailSheet = false
                        self.productId = 0
                    },
                    productID: $productId,
                    sellerInfo: $sellerInfo
                )
            )
            
            CusNavLink(
                doNavigate: $navigateToChat,
                destination: ChatScreen(viewModel: prepareChatData())
            )
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            setupInitialState()
            loadInitialData()
            listenForRaidEvents()
        }
       
    }
    @ViewBuilder
    private var baseContentLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            mainContentView
                .gesture(tapGesture)
            
          
        }
    }

    
    // MARK: - Main Content View
    @ViewBuilder
    private var mainContentView: some View {
        GeometryReader { geometry in
            if liveShowsData.count != 0 {
                contentStack(geometry: geometry)
                    .gesture(verticalSwipeGesture(geometry: geometry))
                    .toast(isPresenting: $showHud, duration: 1.5) {
                        AlertToast(
                            displayMode: .alert,
                            type: .regular,
                            title: hudMsg,
                            style: .style(backgroundColor: Color.black.opacity(0.4), titleColor: Color.white)
                        )
                    }
                    .toast(isPresenting: $showhudSuccess, duration: 1.5) {
                        AlertToast(
                            displayMode: .hud,
                            type: .regular,
                            title: hudMsg,
                            style: alertStlyeSuccess
                        )
                    }
            }
        }
    }
    
    @ViewBuilder
    private func contentStack(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            videoPlayerView
            
            VStack(alignment: .leading) {
                headerView
                Spacer()
                bottomContentStack
            }
            
            sideMenuView(geometry: geometry)
        }
    }
    
    // MARK: - Video Player View
    @ViewBuilder
    private var videoPlayerView: some View {
        if let _ = agoraManager.remoteUserId {
            VideoContainerView(uiView: agoraManager.remoteVideoView)
                .frame(width: screenWidth, height: screenHeight)
                .ignoresSafeArea()
                .background(Color.black)
        }
    }
    
    // MARK: - Header View
    @ViewBuilder
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { id = userId }) {
                profileSection
                Spacer()
                viewerCountBadge
                closeButton
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 50)
    }
    
    //MARK: Profile section
    @ViewBuilder
    private var profileSection: some View {
        if let sellerInfo = viewModel.sellerInfo.data {
            HStack(spacing: 12) {
                CustomProfileImage(
                    url: sellerInfo.seller_details?.profile_image ?? "",
                    isCircular: true,
                    size: 40
                ) {
                    showSellerProfileSheet = true
                }
                
                sellerInfoColumn(sellerInfo: sellerInfo)
            }
        } else {
            shimmerProfileSection
        }
    }
    //MARK: Seller info
    @ViewBuilder
    private func sellerInfoColumn(sellerInfo: SellerInfoResponse) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Button {
                showSellerProfileSheet = true
            } label: {
                Text(sellerInfo.seller_details?.name ?? "")
                    .font(.custom(poppinsBold, size: 14.0))
                    .foregroundColor(.white)
            }
            
            statsRow(sellerInfo: sellerInfo)
        }
    }
    
    @ViewBuilder
    private func statsRow(sellerInfo: SellerInfoResponse) -> some View {
        HStack(spacing: 4) {
            ratingView(sellerInfo: sellerInfo)
            Text("•")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
            shippingView(sellerInfo: sellerInfo)
            
            if !isFollowing {
                followButton
            }
        }
    }
    
    @ViewBuilder
    private func ratingView(sellerInfo: SellerInfoResponse) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
            
            Text("\(sellerInfo.review ?? "0.0")")
                .font(.custom(poppinsRegular, size: 12.0))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    @ViewBuilder
    private func shippingView(sellerInfo: SellerInfoResponse) -> some View {
        HStack(spacing: 3) {
            Image(systemName: "shippingbox")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
            
            Text("\(sellerInfo.avg_ship ?? "1d")")
                .font(.custom(poppinsRegular, size: 12.0))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    //MARK: Follow button
    @ViewBuilder
    private var followButton: some View {
        Button(action: { followUnfollow() }) {
            Text("Follow")
                .font(.custom(poppinsSemiBold, size: 12.0))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.defaultTheme)
                .cornerRadius(10)
        }
    }
    //MARK: Shimmer section
    @ViewBuilder
    private var shimmerProfileSection: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .shimmer()
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 14)
                    .shimmer()
                
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 12)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 12)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 24)
                        .shimmer()
                }
            }
        }
    }
    //MARK: Viewwer count badge
    @ViewBuilder
    private var viewerCountBadge: some View {
        HStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 24, height: 24)
                
                Image(systemName: "waveform")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("\(socketManagerChat.viewerCount)")
                .foregroundColor(.white)
                .font(.custom(poppinsSemiBold, size: 16.0))
        }
        .frame(height: 28)
        .padding(.horizontal, 6)
        .background(Color.black.opacity(0.35))
        .clipShape(Capsule())
    }
    
    //MARK: close button section
    @ViewBuilder
    private var closeButton: some View {
        Button(action: {
            logoutRoom()
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.down")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 28, height: 28)
                .background(Color.black.opacity(0.35))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Bottom Content Stack - comment , product and poll
    @ViewBuilder
    private var bottomContentStack: some View {
        VStack(alignment: .leading, spacing: 12) {
            commentSection
            commentInputSection
            productAndPollSection
        }
        .padding(.bottom, keyboardResponder.currentHeight == 0 ? (tabBarHeight + 20) : 10)
    }
    
    //MARK: Comment section
    @ViewBuilder
    private var commentSection: some View {
        if socketManagerChat.chats.count > 0 {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Spacer(minLength: 0)
                        
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(socketManagerChat.chats) { comment in
                                chatBubble(for: comment)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .frame(
                    width: screenWidth - 54,
                    height: chatHeight
                )
                .animation(.easeOut(duration: 0.2), value: socketManagerChat.chats.count)
                .onChange(of: socketManagerChat.chats) { _ in
                    scrollToLastMessage(proxy: proxy)
                }
            }
        }
    }
    
    private var chatHeight: CGFloat {
        socketManagerChat.chats.count == 0
        ? 0
        : min(CGFloat(socketManagerChat.chats.count), CGFloat(maxVisibleMessages)) * messageHeight
    }
    
    @ViewBuilder
    private func chatBubble(for comment: CommentModel) -> some View {
        let data = liveShowsData[currentIndex]
        let isHost = comment.userId == data.seller?.id ?? ""
        let isMod = !isHost
        
        ChatMessageBubble(comment: comment, isHost: isHost)
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear {
                        if messageHeight == 40 {
                            messageHeight = geo.size.height + 10
                        }
                    }
                }
            )
            .id(comment.id)
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastID = socketManagerChat.chats.last?.id {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(lastID, anchor: .bottom)
            }
        }
    }
    
    @ViewBuilder
    private var commentInputSection: some View {
        HStack {
            commentInputField
        }
        .padding(.leading, 16)
        .padding(.trailing, BiddingDetail.products != nil ? 54 : 16)
        .animation(.easeOut(duration: 0.25), value: keyboardResponder.currentHeight)
    }
    
    @ViewBuilder
    private var commentInputField: some View {
        ZStack(alignment: .trailing) {
            TextField(
                "",
                text: $commentText,
                prompt: Text("Say something...")
                    .foregroundColor(.gray)
                    .font(.custom(poppinsRegular, size: 13))
            )
            .foregroundColor(.white)
            .font(.custom(poppinsRegular, size: 13))
            .padding(.horizontal, 8)
            .padding(.trailing, commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 14 : 40)
            .frame(height: 40)
            .frame(width: BiddingDetail.products != nil ? screenWidth - 45 : screenWidth - 90)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.35))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 1)
            )
            
            if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sendButton
            }
        }
    }
    
    //MARK: Send comment section
    @ViewBuilder
    private var sendButton: some View {
        Button(action: {
            hideKeyboard()
            let roomId = liveShowsData[currentIndex].room_id ?? ""
            let userId = UserDefaults.userId
            let userName = UserDefaults.userName
            let userImage = UserDefaults.profileURL
            SocketManagerService.shared.sendChat(
                roomId: roomId,
                message: commentText,
                userId: userId,
                userName: userName,
                userImage: userImage
            )
            commentText = ""
        }) {
            Image(systemName: "chevron.right")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(.white)
                .padding(10)
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: commentText)
    }
    
    // MARK: - Product and Poll Section
    @ViewBuilder
    private var productAndPollSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showPollView, let poll = currentPollModel {
                pollPreview(poll: poll)
            }
            
            productDetailsView
        }
    }
    //MARK: Poll section
    @ViewBuilder
    private func pollPreview(poll: PollModel) -> some View {
        PollPreviewCardView(
            poll: poll,
            remainingTime: remainingTimer,
            onPollCardTapped: {
                print("PollCard clicked")
                showLivePollScreen = true
            }
        )
    }
    //MARK: Product detail section
    @ViewBuilder
    private var productDetailsView: some View {
       
      
        if isAuctionStartedForCurrentRoom {
            let currentProducts = auctionedProductData
            let product = currentProducts
            if product != nil && product?.status != "sold"{
                VStack(alignment: .leading, spacing: 12) {
                    currentProductCard(product: product ?? ProductDataModel1() )
                    biddingControls
                }
                
            } else {
                waitingForProductView
            }
        }else{
            waitingForProductView
        }
    }
    
    //MARK: Current product section
    @ViewBuilder
    private func currentProductCard(product: ProductDataModel1) -> some View {
        CurrentProductView(
            product: product,
            currentPrice: $currentPrice,
            bidTime: $socketManagerChat.bidTime,
            userName: $winnerName,
            userImage: $winnerProfileImage,
            categoryName: $categoryName, hasWon: .constant(false),
            onTap: { self.showItemDetailSheet = true }
        )
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var waitingForProductView: some View {
        Text("Waiting for product...")
            .font(.custom(poppinsBold, size: 14.0))
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.leading, 16)
            .padding(.trailing, 16)
    }
    
    //MARK: Bid  section
    @ViewBuilder
    private var biddingControls: some View {
        HStack(spacing: 8) {
            customBidButton
            swipeToBidSection
        }
        .padding(.horizontal)
        .onAppear {
            setupBiddingIfNeeded()
        }
    }
    //MARK: Cusotm bid section
    @ViewBuilder
    private var customBidButton: some View {
        Text("Custom")
            .font(.custom(poppinsBold, size: 13))
            .foregroundColor(.white)
            .frame(width: 80, height: 42)
            .background(
                Capsule()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .onTapGesture {
                handleCustomBidTap()
            }
    }
    //MARK: Cusotm bid section action
    private func handleCustomBidTap() {
        if UserDefaults.allowBidForAllUser {
            self.maxBidAmountSheet = true
        } else {
            if UserDefaults.buyerVerafied != "verified" {
                showVerificationSheet = true
            } else {
                self.maxBidAmountSheet = true
            }
        }
    }
    
    //MARK: Swipe bid section
    
    @ViewBuilder
    private var swipeToBidSection: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .stroke(.defaultTheme, lineWidth: 1)
                .frame(height: 42)
            
            draggableButton
        }
        .frame(height: 45)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var draggableButton: some View {
        let nextBid = nextBidAmount(for: currentPrice)
        
        RoundedRectangle(cornerRadius: 22)
            .fill(.defaultTheme)
            .frame(width: screenWidth / 2 - 40, height: 36)
            .overlay(bidButtonContent(nextBid: nextBid))
            .offset(x: dragOffsetX)
            .gesture(bidDragGesture)
            .animation(.easeOut, value: dragOffset)
    }
    
    private var dragOffsetX: CGFloat {
        max(4, min(dragOffset.width + 4, screenWidth * 0.3))
    }
    
    @ViewBuilder
    private func bidButtonContent(nextBid: Double) -> some View {
        HStack(spacing: 6) {
            Text("Bid: $\(Int(nextBid))")
                .font(.custom(poppinsSemiBold, size: 14))
                .foregroundColor(.black)
            
            chevronAnimation(offset: 3)
            chevronAnimation(offset: 6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
    
    @ViewBuilder
    private func chevronAnimation(offset: CGFloat) -> some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.black)
            .opacity(animate ? 1 : 0.2)
            .offset(x: animate ? offset : 0)
    }
    
    private var bidDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.width >= 0 {
                    dragOffset = value.translation
                }
            }
            .onEnded { value in
                handleBidDragEnd(value: value)
            }
    }
    
    private func handleBidDragEnd(value: DragGesture.Value) {
        if value.translation.width > totalSwipeWidth * 0.25 {
            dragOffset = .zero
            
            if UserDefaults.allowBidForAllUser {
                swipeConfirmed = true
                incrementPrice()
            } else {
                if UserDefaults.buyerVerafied != "verified" {
                    showVerificationSheet = true
                } else {
                    swipeConfirmed = true
                    incrementPrice()
                }
            }
        } else {
            swipeConfirmed = false
            dragOffset = .zero
        }
    }
    
    private func setupBiddingIfNeeded() {
        if !isBiddingActive {
            if UserDefaults.buyerVerafied != "verified" {
                showVerificationSheet = true
            } else {
                isBiddingActive = true
            }
        }
    }
    
    // MARK: - Side Menu View
    @ViewBuilder
    private func sideMenuView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 12) {
            ForEach(filteredActions, id: \.self) { action in
                sideMenuItem(action: action)
            }
            
            productStackView
        }
        .position(
            x: geometry.size.width - 40,
            y: geometry.size.height / 2 - 20
        )
    }
    
    @ViewBuilder
    private func sideMenuItem(action: MenuAction) -> some View {
        Button(action: { handleMenuAction(action) }) {
            VStack(spacing: 0) {
                Image(action.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.heavy)
                    .font(.custom(poppinsExtraBold, size: 22.0))
                    .frame(width: 25, height: 24)
                    .foregroundColor(.white)
                
                Text(action.label)
                    .font(.custom(poppinsRegular, size: 8.0))
                    .foregroundColor(.white)
            }
        }
        .padding(4)
    }
    
    private func handleMenuAction(_ action: MenuAction) {
        if action == .gift {
            currentBottomSheet = action
            showSheet = true
        } else if action == .promote {
            currentBottomSheet = action
            showSheet = true
        } else  if action == .share {
            shareItems = [
                "Live auction starting in 5 minutes! Don't miss out on exclusive items.",
                URL(string: "https://www.backend.bidcast.betaplanets.com/live-show?roomid=\(currentRoomID)")!
            ]
            print(shareItems)
            showSystemShareSheet = true
        } else if action == .wallet {
            handleWalletAction()
        }
    }
    
    private func handleWalletAction() {
        if UserDefaults.buyerVerafied != "verified" {
            showVerificationSheet = true
        } else {
            if UserDefaults.sellerAddress == false {
                showPaymentShipping = true
                titleText = "Add Address"
            } else if UserDefaults.hasCardAdded == false {
                showPaymentShipping = true
                titleText = "Add Card"
            } else {
                currentBottomSheet = .wallet
                showSheet = true
            }
        }
    }
    
    @ViewBuilder
    private var productStackView: some View {
        VStack {
            if isAuctionStartedForCurrentRoom {
                let currentProducts = auctionedProductData ?? ProductDataModel1()
                let product = currentProducts
                if product != nil{
                 
                    if let img = product.images?.first {
                        StackedImageView(imageURL: img, totalCount: productData.count) {
                            print("productStackTapped")
                            navigateToProductList = true
                        }
                    }
                }
            }else{
                StackedImageView(imageURL: "", totalCount: 0) {
                    print("productStackTapped")
                    navigateToProductList = true
                }
            }
        }
    }
    
    // MARK: - Gestures
    private var tapGesture: some Gesture {
        TapGesture().onEnded { _ in
            hideKeyboard()
        }
    }
    
    private func verticalSwipeGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($verticalGestureOffset) { value, state, _ in
                if abs(value.translation.height) > abs(value.translation.width) {
                    state = value.translation
                }
            }
            .onChanged { value in
                withAnimation {
                    verticalDragOffset = value.translation
                }
            }
            .onEnded { value in
                handleVerticalSwipeEnd(value: value, geometry: geometry)
            }
    }
    private func handleVerticalSwipeEnd(value: DragGesture.Value, geometry: GeometryProxy) {
        let verticalAmount = value.translation.height
        let swipeThreshold: CGFloat = 100
        
        if verticalAmount < -swipeThreshold && currentIndex < streamID.count - 1 {
            handleSwipeUp(geometry: geometry)
        } else if verticalAmount > swipeThreshold && currentIndex > 0 {
            handleSwipeDown(geometry: geometry)
        } else {
            withAnimation {
                verticalDragOffset = .zero
            }
        }
    }

    private func handleSwipeUp(geometry: GeometryProxy) {
        withAnimation(.easeInOut) {
            verticalDragOffset = CGSize(width: 0, height: -geometry.size.height)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            logoutRoom()
            hasHostEndedRoom.toggle()
            
            if currentIndex < liveShowsData.count {
                currentIndex += 1
            }
            
            let currentRoomId = liveShowsData[currentIndex].room_id ?? ""
            switchStream(to: currentRoomId)
        }
    }

    private func handleSwipeDown(geometry: GeometryProxy) {
        withAnimation(.easeInOut) {
            verticalDragOffset = CGSize(width: 0, height: geometry.size.height)
        }
        
        logoutRoom()
        hasHostEndedRoom.toggle()
        
        if currentIndex > 0 {
            currentIndex -= 1
        }
        
        let currentRoomId = liveShowsData[currentIndex].room_id ?? ""
        switchStream(to: currentRoomId)
    }
    
    //MARK: Apply toast
    private var toastLayer: some View {
        EmptyView()
            .toast(isPresenting: $showHud, duration: 1.5) {
                AlertToast(
                    displayMode: .alert,
                    type: .regular,
                    title: hudMsg,
                    style: .style(backgroundColor: Color.black.opacity(0.4), titleColor: Color.white)
                )
            }
            .toast(isPresenting: $showhudSuccess, duration: 1.5) {
                AlertToast(
                    displayMode: .hud,
                    type: .regular,
                    title: hudMsg,
                    style: alertStlyeSuccess
                )
            }
    }
    
    //MARK: Apply bottom sheet
    @ViewBuilder
    private var bottomSheetLayer: some View {
        EmptyView()
            .bottomSheet(
                isPresented: $showError,
                height: screenHeight / 2.8,
                topBarCornerRadius: 25,
                showTopIndicator: false,
                onDismiss: { showError = true }
            ) {
                errorSheetContent
            }
            .bottomSheet(
                isPresented: $showErrorPopup,
                height: screenHeight / 2.8,
                topBarCornerRadius: 25,
                showTopIndicator: false,
                onDismiss: { showErrorPopup = true }
            ) {
                errorPopupSheetContent
            }
            .bottomSheet(
                isPresented: $showPaymentShipping,
                height: screenHeight / 2.8
            ) {
                paymentShippingSheetContent
            }
//            .bottomSheet(
//                isPresented: $maxBidAmountSheet,
//                height: screenHeight * 0.35
//            ) {
//                maxBidSheetContent
//            }
            .sheet(isPresented: $maxBidAmountSheet){
                maxBidSheetContent
                    .presentationDetents([.fraction(0.35)])
                    .presentationCornerRadius(25)
                    .presentationDragIndicator(.hidden)
                    .interactiveDismissDisabled(true)
            }
            
            .bottomSheet(
                isPresented: $showFollowSheet,
                height: screenHeight / 2.5,
                topBarCornerRadius: 20
            ) {
                followSheetContent
            }
            .bottomSheet(
                isPresented: $showSellerProfileSheet,
                height: screenHeight * 0.70,
                topBarCornerRadius: 25,
                showTopIndicator: false,
                onDismiss: { showSellerProfileSheet = false }
            ) {
                sellerProfileSheetContent
            }
            .bottomSheet(
                isPresented: $showVerificationSheet,
                height: screenHeight / 2.5,
                topBarCornerRadius: 25,
                showTopIndicator: false,
                onDismiss: {
                    showVerificationSheet = false
                    handleVerificationDismiss()
                }
            ) {
                verificationSheetContent
            }
            .bottomSheet(
                isPresented: $showBlockSeller,
                height: screenHeight * 0.45,
                topBarCornerRadius: 25,
                showTopIndicator: false,
                onDismiss: { showBlockSeller = false }
            ) {
                blockSellerSheetContent
            }
            .bottomSheet(
                isPresented: $showReportSheet,
                height: screenHeight * 0.65,
                topBarCornerRadius: 0,
                contentBackgroundColor: Color(.white),
                topBarBackgroundColor: Color(.white),
                showTopIndicator: false,
                onDismiss: { showReportSheet = false }
            ) {
                reportSheetContent
            }
            .bottomSheet(
                isPresented: $showTipSheet,
                height: screenHeight * 0.55,
                topBarCornerRadius: 20,
                contentBackgroundColor: Color(.systemBackground),
                topBarBackgroundColor: Color(.systemBackground),
                showTopIndicator: false,
                onDismiss: { showTipSheet = false }
            ) {
                tipSheetContent
            }
            .sheet(isPresented: $showSystemShareSheet) {
                ShareSheet(items: shareItems)
            }
            .bottomSheet(
                isPresented: $showSheet,
                height: sheetHeight,
                topBarCornerRadius: 20,
                contentBackgroundColor: Color(.systemBackground),
                topBarBackgroundColor: Color(.systemBackground),
                showTopIndicator: false,
                onDismiss: { showSheet = false }
            ) {
                mainSheetContent
            }
    }
    
    // MARK: - Sheet Content Views
    
    @ViewBuilder
    private var errorSheetContent: some View {
        CommonBottomSheet(
            sheetType: $alertType,
            onPrimaryClick: {
                withAnimation {
                    showError = false
                    if hasHostEndedRoom {
                        logoutRoom()
                        hasHostEndedRoom.toggle()
                    }
                    self.presentationMode.wrappedValue.dismiss()
                    self.presentationMode.wrappedValue.dismiss()
                }
            },
            onSecondaryClick: {
                withAnimation {
                    showError = false
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
    
    @ViewBuilder
    private var errorPopupSheetContent: some View {
        CommonBottomSheet(
            sheetType: $alertType,
            onPrimaryClick: {
                withAnimation { showErrorPopup = false }
            },
            onSecondaryClick: {
                withAnimation { showErrorPopup = false }
            }
        )
    }
    
    @ViewBuilder
    private var paymentShippingSheetContent: some View {
        PaymentAndShippingInfoSheet(
            isPresented: $showPaymentShipping,
            onAddInfo: {
                if UserDefaults.sellerAddress != true {
                    navigateToShipping = true
                } else if UserDefaults.hasCardAdded != true {
                    navigateToAddCardScreen = true
                }
            },
            buttonText: $titleText
        )
    }
    
    @ViewBuilder
    private var maxBidSheetContent: some View {
        let currentProducts = auctionedProductData ?? ProductDataModel1()
        let product = currentProducts
        if product != nil && product.status != "sold"{
            MaxBidBottomSheet(
                showParentToast: $showToast,
                parentToastMessage: $toastMessage,
                currentProduct: product,
                onSubmit: { amount in
                    if let amount = Double(amount) {
                        placeBid(amount: amount)
                    }
                },
                onDismiss: {
                    self.maxBidAmountSheet = false
                }
            )
        }
        
    }
    
    @ViewBuilder
    private var followSheetContent: some View {
        FollowSellerSheet(
            seller: sellerInfo,
            onFollow: {
                print("Follow tapped")
                showFollowSheet = false
                followUnfollow()
            },
            onNotNow: {
                print("Not now tapped")
                showFollowSheet = false
            },
            onClose: {
                showFollowSheet = false
            }
        )
    }
    
    @ViewBuilder
    private var sellerProfileSheetContent: some View {
        SellerProfileBottomSheet(
            isPresented: $showSellerProfileSheet,
            sellerInfo: sellerInfo,
            onTipOrBoost: {
                print("Tip or Boost")
                showSellerProfileSheet = false
                showTipSheet = true
            },
            onViewProfile: {
                print("View Profile")
                showSellerProfileSheet = false
                navigateToProfile = true
            },
            onMessage: {
                print("Message")
                showSellerProfileSheet = false
                let currentUserId = String(UserDefaults.userId)
                let otherUserId = self.sellerId
                let sortedRoomId = computeRoomId(senderId: currentUserId, receiverId: otherUserId)
                chatPath = "chats/\(sortedRoomId)"
                print("Computed Chat Path: \(chatPath)")
                navigateToChat = true
            },
            onBlock: {
                print("Block")
                showSellerProfileSheet = false
                alertType = .sheetType(
                    icon: .alert,
                    title: "Block Seller!",
                    message: "Are you sure, You want to block this seller.",
                    primaryBtnText: "Block",
                    secondaryBtnText: "Cancel"
                )
                showBlockSeller = true
            },
            onReport: { sellerId in
                print("Report")
                showSellerProfileSheet = false
                showReportSheet = true
            },
            onFollow: {
                print("Follow")
                showSellerProfileSheet = false
            }
        )
    }
    
    @ViewBuilder
    private var verificationSheetContent: some View {
        CommonBottomSheet(
            sheetType: $alertType,
            onPrimaryClick: {
                withAnimation {
                    if UserDefaults.buyerVerafied == "pending" {
                        showVerificationSheet = false
                    } else {
                        navigateToBuyer = true
                        showVerificationSheet = false
                    }
                    
                    if !showVerificationSheet {
                        if !navigateToBuyer {
                            if UserDefaults.sellerAddress == false {
                                showPaymentShipping = true
                                titleText = "Add Address"
                            } else if UserDefaults.hasCardAdded == false {
                                navigateToAddCardScreen = true
                                titleText = "Add Card"
                            }
                        }
                    }
                }
            },
            onSecondaryClick: {
                withAnimation {
                    showVerificationSheet = false
                }
            }
        )
    }
    
    private func handleVerificationDismiss() {
        if !showVerificationSheet {
            if UserDefaults.sellerAddress == false {
                showPaymentShipping = true
                titleText = "Add Address"
            } else if UserDefaults.hasCardAdded == false {
                showPaymentShipping = true
                titleText = "Add Card"
            }
        }
    }
    
    @ViewBuilder
    private var blockSellerSheetContent: some View {
        CommonBottomSheet(
            sheetType: $alertType,
            onPrimaryClick: {
                withAnimation { showBlockSeller = false }
                let sellerId = self.sellerId
                blockSeller(with: sellerId)
            },
            onSecondaryClick: {
                withAnimation { showBlockSeller = false }
            }
        )
    }
    
    @ViewBuilder
    private var reportSheetContent: some View {
        ReportSellerView(onReportSellerClicked: { categoryId, message in
            Task {
                await reportSeller(categoryId: categoryId, message: message)
            }
        })
        .keyboardAwarePadding()
    }
    
    @ViewBuilder
    private var tipSheetContent: some View {
        if liveShowsData.count > 0 {
            SendTipView(
                sellerId: self.sellerId,
                onClose: { showTipSheet = false },
                onSendTip: {
                    print("Sent tip")
                    showTipSheet = false
                }
            )
        }
    }
    
    @ViewBuilder
    private var mainSheetContent: some View {
        switch currentBottomSheet {
        case .gift:
            SendTipView(
                sellerId: self.sellerId,
                onClose: { showSheet = false },
                onSendTip: { print("Sent tip") }
            )
        case .promote:
            PromoteShowSheet(
                boosts: $boosts,
                onPromotionSelected: { selectedBoost in
                    handleBoostClick(selectedBoost)
                },
                onClose: { showSheet = false }
            )
        case .paperclip:
            CreateClipBottomSheetView(
                isPresented: $showSheet,
                videoURL: URL(string: "https://example.com/video.mp4")!,
                onCreateClip: { start, end in
                    print("Clip range: \(start.seconds) to \(end.seconds)")
                }
            )
        case .share:
            ShareSheet(items: shareItems)
        case .wallet:
            walletSheetContentView
        case .cart:
            cartSheetContentView
        case .none:
            EmptyView()
        }
    }
    private func handleBoostClick(_ boost: BoostModel) {
        print("🔥 User clicked boost: \(boost.title)")
        showSheet = false
        storePromoteShow(boost: boost)
    }
    
    func storePromoteShow(boost: BoostModel) {
        guard let promoteId = boost.id else {
            hudMsg = "Either promoteId or ShowId not found."
            showHud = true
            return
        }
        
            let showId = liveShowsData[currentIndex].show_id ?? ""
        Task {
            if isInternetAvailable() {
                SVProgressHUD.show()
                let request = StorePromoteShowRequest(scheduleShowId: "\(showId)", promoteShowId: "\(promoteId)")
                await viewModel.storePromoteShow(parameters: request)
                await SVProgressHUD.dismiss()
                successPromoteShow()
            }
        }
    }
    
    private func successPromoteShow() {
        let response = viewModel.storePromoteShowModel
        if response?.status == "success" {
            hudMsg = "show promoted successfully."
            showhudSuccess = true
            socketManagerChat.sendPromotionEvent(userId: "\(response?.data?.userID ?? 0)", showId: "\(response?.data?.id ?? 0)", promoteShowId: "\(response?.data?.promoteShowID ?? 0)")
        } else {
            hudMsg = response?.message ?? ""
            showHud = true
        }
    }
    
    func getPromoteShows() {
        Task{
            if isInternetAvailable() {
                self.viewModel.errorMessage?.removeAll()
//                SVProgressHUD.show()
                await self.viewModel.getPromoteShows()
//                await SVProgressHUD.dismiss()
                if let message = self.viewModel.errorMessage, message != "" {
                    hudMsg = self.viewModel.promoteShow?.message ?? ""
                    showHud = true
                }else{
                    self.successPromote()
                }
            }
        }
    }
    
    func successPromote(){
        let response  = self.viewModel.promoteShow
        if response?.status == "success"{
            self.boosts = response?.data ?? [BoostModel]()
        }
    }
    
    func isInternetAvailable()  -> Bool {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showHud = true
            return false
        }
        return true
    }
    
    @ViewBuilder
    private var walletSheetContentView: some View {
        let data = homeViewModel.accountInfo.data
        PaymentBottomSheet(
            isPresented: $showSheet,
            paymentMethods: [
                PaymentMethod(creditCard: CreditCard(
                    cardNumber: data?.default_card?.card_id,
                    expirationDate: data?.default_card?.exp_date,
                    cardType: data?.default_card?.cardType
                ))
            ],
            addresses: [
                AddressModel(
                    id: data?.default_shipping_address?.id,
                    user_id: data?.id,
                    type: data?.default_shipping_address?.type,
                    name: data?.default_shipping_address?.name,
                    phone_number: data?.default_shipping_address?.phone_number,
                    street_address: data?.default_shipping_address?.street_address,
                    pincode: data?.default_shipping_address?.pincode,
                    is_default: true
                )
            ],
            onEditPayment: {
                showSheet = false
                navigateToEditPayment = true
            },
            onEditAddress: {
                showSheet = false
                navigateToEditAddress = true
            }
        )
    }
    
    @ViewBuilder
    private var cartSheetContentView: some View {
        ShopBottomSheetView(
            isPresented: $showSheet,
            productData: $productData,
            productShowType: .viewOnly,
            initialSelectedProductId: currentProductID
        )
    }
   
    
}
// MARK: - Helper Functions
extension LiveStream {
    private func setupInitialState() {
        UserDefaults.isLiveEnded = false
    }
    private func loadInitialData() {
        Task { @MainActor in
            SVProgressHUD.show()
            
            do {
                await homeViewModel.getProfile()
                
                await SVProgressHUD.dismiss()
                
                 getProfileSuccess()
                joinChatRoom(roomId: currentRoomID)
                self.getPromoteShows()
            } catch {
                await SVProgressHUD.dismiss()
                print("❌ loadInitialData Error:", error.localizedDescription)
                
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: error.localizedDescription,
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }
        }
    }

    private func joinChatRoom(roomId: String) {
        socketManagerChat.joinRoom(roomId: roomId) {
            joinStreamUsingSocket(roomId: roomId)
        }
    }

    private func listenForRaidEvents() {
        socketManagerChat.listenForRaidEvent { raidInfo in
            guard let info = raidInfo else {
                print("No Raid Info")
                return
            }
            
            logoutRoom()
            
            if ((info.message?.isEmpty) == nil) {
                hudMsg = info.message ?? ""
                showHud = true
            }
            
            currentRoomID = info.target_room_id ?? ""
            agoraToken = info.rtcToken ?? ""
            
            joinChatRoom(roomId: currentRoomID)
        }
    }

    @MainActor
    private func fetchSellerIfAvailable() async {
        guard let product = liveShowsData[currentIndex].products?.first,
                let sellerId = product.user?.id else {
            print("⚠️ Seller ID not available")
            return
        }
        
        do {
            try await viewModel.getSellerInfo(sellerID: "\(sellerId)")
            print("✅ Seller info updated")
            await SVProgressHUD.dismiss()
            
            let response = viewModel.sellerInfo
            print("Seller info: \(response)")
            
            if response.status == "success" {
                self.sellerInfo = response.data
            } else {
                throw NSError(domain: "APIError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: response.message ?? "Something went wrong"
                ])
            }
            
        } catch {
            print("❌ Failed to fetch seller info:", error.localizedDescription)
            await SVProgressHUD.dismiss()
            
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? error.localizedDescription,
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }

    func nextBidAmount(for currentPrice: Double) -> Double {
        let increment: Double
        
        switch currentPrice {
        case 1...30:
            increment = 1
        case 31...50:
            increment = 2
        case 51...100:
            increment = 3
        case 101...300:
            increment = 5
        case 301...1000:
            increment = 10
        case 1001...2000:
            increment = 20
        default:
            increment = 50
        }
        
        return currentPrice + increment
    }

    func timerStringToSeconds(_ time: String) -> Int {
        let parts = time.split(separator: ":")
        guard parts.count == 2,
              let minutes = Int(parts[0]),
              let seconds = Int(parts[1]) else {
            return 0
        }
        return (minutes * 60) + seconds
    }

    func getProfileSuccess() {
        let response = homeViewModel.accountInfo
        if response.status == "success" {
            let response = self.homeViewModel.accountInfo.data
            UserDefaults.buyerVerafied = response?.buyer_identity_status ?? ""
            UserDefaults.sellerVerafied = response?.seller_identity_status ?? ""
            UserDefaults.sellerAddress = response?.has_shipping_address ?? false
            UserDefaults.hasCardAdded = response?.has_card_added ?? false
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

    private func presentError(title: String, message: String) {
        showError = true
        alertType = .sheetType(
            icon: .alert,
            title: title,
            message: message,
            primaryBtnText: "",
            secondaryBtnText: AppString.ok.localized
        )
    }

    //MARK: SOcket listeners-
    @MainActor
    private func setupSocketListeners(for roomId: String) async {
        let userId = UserDefaults.userId
        let userName = UserDefaults.userName
        let userImage = UserDefaults.profileURL
        self.currentRoomID = roomId
        SocketManagerService.shared.sendChat(
            roomId: roomId,
            message: "Joined 👋 ",
            userId: userId,
            userName: userName,
            userImage: userImage
        )
        
        socketManagerChat.listenForChat(roomId: roomId)
        socketManagerChat.listenForViewerCount()
        socketManagerChat.listenForBidTimer(roomId: roomId)
        
        socketManagerChat.listenForRoomEnded { endedRoomId in
            guard roomId == endedRoomId else { return }
            presentError(title: "Stream Ended", message: "The host has ended the live stream.")
            hasHostEndedRoom = true
        }
        
        SocketManagerService.shared.listenForHighestBid(forRoom: roomId) { highestBid in
            guard let bid = highestBid else { return }
            print("🏆 Highest Bid: \(bid.user_name ?? "") - \(bid.bid_amount ?? "")")
            winnerName = bid.user_name ?? ""
            winnerProfileID = Int(bid.user_id ?? "") ?? 0
            winnerProfileImage = bid.user_image ?? ""
            winnerAmount = bid.bid_amount ?? ""
            currentPrice = Double(winnerAmount) ?? 0.0
        }
        
        SocketManagerService.shared.getAllowBidForAll(forRoom: roomId) { allowed in
            UserDefaults.allowBidForAllUser = allowed
            print("⚙️ Allow bid for all: \(allowed)")
        }
        
        SocketManagerService.shared.observeRoomUpdates { newRoom in
            print("🏠 Room updated: \(newRoom.room_id ?? "unknown")")
            fetchProducts(for: newRoom.room_id ?? "")
        }
        
        SocketManagerService.shared.listenForBidFinalized { roomId, productId, winner in
            handleBidFinalized(for: roomId, winner: winner)
        }
        
        SocketManagerService.shared.listenForNextProduct { roomId, _ in
            fetchProducts(for: roomId)
        }
        
//        socketManagerChat.listenForAuctionStarted { roomId,products,startingBidAmount,requireTime,counterBidTime,suddenDeath in
////            guard let self else { return }
//            print("AUCtioned data")
//            print("\(roomId)")
//            print("\(products)")
//            print("\(startingBidAmount)")
//            print("\(requireTime)")
//            print("\(counterBidTime)")
//            print("\(suddenDeath)")
//                self.updateProducts(
//                    for: roomId,
//                    products: products,
//                    startingBidAmount: Double(startingBidAmount) ?? 0.0,
//                    requireTime: requireTime,
//                    counterBidTime: counterBidTime,
//                    suddenDeath: suddenDeath
//                )
//
//                // 🔥 unlock product details for this room
//                self.auctionStartedRooms.insert(roomId)
//           
//        }
//        
        socketManagerChat.listenForAuctionNextProduct { roomID,products,source  in
            guard roomId == roomID else { return}
//            self.auctionedProductData = products
            
        }
        
    }
    
    @MainActor
    private func updateProducts(
        for roomId: String,
        products: [ProductDataModel1],
        startingBidAmount: Double,
        requireTime: Int,
        counterBidTime: Int,
        suddenDeath: Bool
    ) {
        // Update only matching room
        guard currentRoomID == roomId else { return }

        // Update product list
        self.auctionedProductData = products.first ?? ProductDataModel1()

        // Optional: set current product
        self.currentProductID = "\(products.first?.id ?? 0)"
        currentPrice = startingBidAmount
        // Auction config
//        self.startingBidAmount = startingBidAmount
//        self.requireTime = requireTime
//        self.counterBidTime = counterBidTime
//        self.isSuddenDeath = suddenDeath

        print("🟢 Products updated for room:", roomId)
    }


    private func handleBidFinalized(for roomId: String, winner: HighestBid?) {
        fetchProducts(for: roomId)
        
        let name = winner?.user_name ?? ""
        let id = Int(winner?.user_id ?? "") ?? 0
        let image = winner?.user_image ?? ""
        let amount = winner?.bid_amount ?? ""
        
        print("🏁 Bid finalized - Winner: \(name), Amount: \(amount)")
        auctionedProductData = nil
        maxBidAmountSheet = false
        winnerName = name
        winnerProfileID = id
        winnerProfileImage = image
        winnerAmount = amount
        
//        let message = "Congratulations! \(winnerName) has won the bid with an amount of $\(winnerAmount)"
//        let roomId = liveShowsData[currentIndex].room_id ?? ""
//        let userId = UserDefaults.userId
//        let userName = UserDefaults.userName
//        let userImage = UserDefaults.profileURL
//        SocketManagerService.shared.sendChat(
//            roomId: roomId,
//            message: message,
//            userId: userId,
//            userName: userName,
//            userImage: userImage
//        )
    }

    private func handleBuyerVerification() {
        switch UserDefaults.buyerVerafied {
        case "pending":
            alertType = .sheetType(
                icon: .info,
                title: "Become a Verified Buyer!",
                message: "Your verification is currently pending approval by the admin. You will be notified once the process is complete.",
                primaryBtnText: "OK",
                secondaryBtnText: "",
                buttonWidth: screenWidth - 40,
                contentSize: 12.0
            )
            withAnimation(.snappy) { showVerificationSheet = true }
            
        case "verified":
            if !UserDefaults.sellerAddress {
                titleText = "Add Address"
                showPaymentShipping = true
            } else if !UserDefaults.hasCardAdded {
                titleText = "Add Card"
                showPaymentShipping = true
            }
            
        default:
            alertType = .sheetType(
                icon: .info,
                title: "Become a Verified Buyer!",
                message: "Before you interact with live shows, you need to become a verified buyer.",
                primaryBtnText: "OK",
                secondaryBtnText: "",
                buttonWidth: screenWidth - 40,
                contentSize: 12.0
            )
            withAnimation(.snappy) { showVerificationSheet = true }
        }
    }

    @MainActor
    func joinStreamUsingSocket(roomId: String, switchStreamType: SwitchStreamType = .none) {
        let socketRooms = socketManagerChat.rooms
        
        guard !socketRooms.isEmpty else {
            presentError(
                title: "No Active Streams",
                message: "There are no live streams available at the moment."
            )
            return
        }
        
        guard let matchingRoomIndex = socketRooms.firstIndex(where: { $0.room_id == roomId }) else {
            presentError(
                title: "Stream Not Found",
                message: "The requested stream is not available right now."
            )
            return
        }
        
        categoryId = socketRooms[matchingRoomIndex].products?.first?.category?.id ?? 0
        sellerId = "\(socketRooms[matchingRoomIndex].products?.first?.user?.id ?? 0)"
        self.agoraToken = socketRooms[matchingRoomIndex].rtc_token ?? ""
        if !agoraToken.isEmpty && !roomId.isEmpty {
            print("🎥 Joining Agora with token: \(agoraToken)")
            agoraManager.joinChannel(asHost: isHost, channelName: roomId, token: agoraToken)
        }
        
        self.roomID = socketRooms.compactMap { $0.room_id }
        self.streamID = self.roomID
        let showId = socketRooms[matchingRoomIndex].show_id ?? ""
        self.showId = showId
        if switchStreamType == .none {
            self.liveShowsData = socketRooms
            self.currentRoomID = roomId
            sortLiveShowsDataByCurrentRoom()
        }
        
        print("🎬 Joining stream: \(roomId)")
        socketManagerChat.joinShowForPromotionalData(showId: showId, UserId: "\(UserDefaults.userId)")
        socketManagerChat.listenForUserFollowStatus()
        SocketManagerService.shared.removeAllListeners()
        
        Task {
            await setupSocketListeners(for: roomId)
        }
        
//        fetchProducts(for: roomId)
        handleBuyerVerification()
        socketManagerChat.listenForAuctionStarted { status,roomId,products,startingBidAmount,requireTime,counterBidTime,suddenDeath in
//            guard let self else { return }
            print("AUCtioned data")
            print("\(roomId)")
            print("\(products)")
            print("\(startingBidAmount)")
            print("\(requireTime)")
            print("\(counterBidTime)")
            print("\(suddenDeath)")
            if status != "sold" && status != ""{
                self.updateProducts(
                    for: roomId,
                    products: products,
                    startingBidAmount: Double(startingBidAmount) ?? 0.0,
                    requireTime: requireTime,
                    counterBidTime: counterBidTime,
                    suddenDeath: suddenDeath
                )
                
                // 🔥 unlock product details for this room
                self.auctionStartedRooms.insert(roomId)
            }else{
                auctionedProductData = nil
                
                self.auctionStartedRooms.remove(roomId)
            }
        }
    }

    func sortLiveShowsDataByCurrentRoom() {
        guard currentRoomID != "" else { return }
        guard !liveShowsData.isEmpty else { return }
        guard let currentRoom = liveShowsData.first(where: { $0.room_id == currentRoomID }) else { return }
        
        var reordered = liveShowsData.filter { $0.room_id != currentRoomID }
        reordered.insert(currentRoom, at: 0)
        liveShowsData = reordered
        currentIndex = 0
        
        Task { @MainActor in
            do {
                async let sellerTask: Void = fetchSellerIfAvailable()
                async let profileTask: Void = getProfileData()
                
                _ = await (sellerTask, profileTask)
                
            } catch {
                print("❌ loadInitialData Error:", error.localizedDescription)
                
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: error.localizedDescription,
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }
        }
        
        print("🔁 Sorted live shows — current room '\(currentRoomID)' moved to top.")
    }

    func switchStream(to newRoomId: String) {
        guard newRoomId != "" else { return }
        socketManagerChat.joinRoom(roomId: currentRoomID, completion: {
            joinStreamUsingSocket(roomId: newRoomId, switchStreamType: .down)
        })
    }

    @MainActor
    func fetchProducts(for roomId: String) {
        guard let socketRoom = socketManagerChat.rooms.first(where: { $0.room_id == roomId }) else {
            self.productData = []
            self.currentProductIndex = 0
            self.currentPrice = 0.0
            self.auctionedProductData = nil
            return
        }
        
        if let products = socketRoom.products {
            productData = products
            
        }
    }

    func sendBid(roomId: String, bidAmount: String, productId: String) {
        let data: [String: Any] = [
            "room_id": roomId,
            "bid_amount": bidAmount,
            "user_name": UserDefaults.userName,
            "user_image": UserDefaults.profileURL,
            "user_id": "\(UserDefaults.userId)",
            "product_id": productId
        ]
        socketManagerChat.sendBid(payload: data)
        currentPrice = Double(bidAmount) ?? 0.0
        let price = String(format: "%.2f", currentPrice)
        commentText = "Current highest bid : $\(price)"
        commentText = ""
    }

    func logoutRoom() {
        agoraManager.leaveChannel()
        SocketManagerService.shared.chats.removeAll()
            self.comments.removeAll()
            SocketManagerService.shared.leaveRoom(roomId: self.currentRoomID, userId: UserDefaults.userId)
            currentProductID = nil
            productId = 0
            self.currentPrice = 0.0
            self.currentProductIndex = -1
        }

        func incrementPrice() {
            let increment: Double
            
            switch currentPrice {
            case 1..<30:
                increment = 1
            case 30..<50:
                increment = 2
            case 50..<100:
                increment = 3
            case 100..<300:
                increment = 5
            case 300..<1000:
                increment = 10
            case 1000..<2000:
                increment = 20
            default:
                increment = 50
            }
            
            let newPrice = currentPrice + increment
            self.sendBid(
                roomId: currentRoomID,
                bidAmount: newPrice.description,
                productId: currentProductID ?? ""
            )
        }

        func placeBid(amount: Double) {
            guard let currentRoomId = liveShowsData[safe: currentIndex]?.room_id else { return }
            
            self.sendBid(
                roomId: currentRoomId,
                bidAmount: "\(amount)",
                productId: currentProductID ?? ""
            )
            
            currentPrice = amount
            commentText = ""
        }

        func updateSoldStatus() {
            // Implementation
        }

        func soldSuccess() {
            let response = self.viewModel.BidResponse
            if response.status == "success" {
                // Success handling
            } else {
                print("⚠️ Bid failed — not marking as sold.")
            }
        }

        func refreshProductStatus(roomId: String) {
            // Implementation
        }

        @ViewBuilder
        func sheetView(for action: MenuAction) -> some View {
            switch action {
            case .gift:
                Text("🎁 Gift Sheet")
            case .promote:
                Text("📣 Promote Sheet")
            case .paperclip:
                Text("📎 Attachment Sheet")
            case .share:
                Text("🔗 Share Sheet")
            case .wallet:
                Text("💳 Wallet Sheet")
            case .cart:
                Text("🛒 Cart Sheet")
            }
        }

        func followSuccess() {
            let response = viewModel.followDict
            if response.status == "success" {
                let status = response.data?.status ?? false
            }
        }
}
// MARK: - Report Seller Extension
extension LiveStream {
    @MainActor
    func reportSeller(categoryId: Int?, message: String?) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showHud = true
            return
        }
        guard let cId = categoryId, let msg = message else {
            return
        }
        do {
            SVProgressHUD.show()
            let request = SellerReportRequest(
                seller_id: Int(liveShowsData[currentIndex].seller?.id ?? "0") ?? 0,
                category_id: cId,
                notes: msg
            )
            try await viewModel.reportSeller(request: request)
            await SVProgressHUD.dismiss()
            let response = viewModel.reportSellerResponse
            
            if response.status == "success" {
                hudMsg = response.message ?? ""
                showhudSuccess = true
                showReportSheet = false
            } else {
                throw NSError(
                    domain: "APIError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: response.message ?? "Something went wrong"]
                )
            }
        } catch {
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
    
    private func blockSeller(with sellerId: String) {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showHud = true
                return
            }
            SVProgressHUD.show()
            let param = BlockUserRequest(blocked_id: Int(sellerId) ?? 0)
            await self.profileViewModel.blockUser(param: param)
            await SVProgressHUD.dismiss()
            blockSuccess()
        }
    }
    
    func blockSuccess() {
        SVProgressHUD.dismiss()
        let response = profileViewModel.blockUserResponseDict
        if response?.status == "success" {
            hudMsg = response?.message ?? ""
            showhudSuccess = true
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response?.status?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized,
                sheetThemeColor: .defaultTheme
            )
            withAnimation(.snappy) { showErrorPopup = true }
        }
    }
    
    private func computeRoomId(senderId: String, receiverId: String) -> String {
        let sortedIds = [senderId, receiverId].sorted()
        return "\(sortedIds[0])_chats_\(sortedIds[1])"
    }
    
    private func prepareChatData() -> ChatModel {
        guard liveShowsData.count != 0 else{
            return ChatModel()
        }
        let currentUserId = "\(UserDefaults.userId)"
        let currentUserName = UserDefaults.fullName
        let currentUserImage = UserDefaults.profileURL
        let otherUserId = self.sellerId
        let otherUserName = liveShowsData[currentIndex].seller?.name ?? ""
        let otherUserImage = liveShowsData[currentIndex].seller?.image ?? ""
        return ChatModel(
            currentUserId: currentUserId,
            currentUserName: currentUserName,
            currentUserImage: currentUserImage,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserImage: otherUserImage
        )
    }
}
// MARK: - Follow/Unfollow Extension
extension LiveStream {
    private func followUnfollow() {
        guard !liveShowsData.isEmpty else { return }
//        guard let sellerId = liveShowsData[currentIndex].seller?.id, !sellerId.isEmpty else {
//            print("⚠️ Seller ID not available")
//            return
//        }
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showHud = true
            return
        }
        Task {
            SVProgressHUD.show()
            await self.profileViewModel.followUnfollow(
                parameters: FollowRequest(following_id: self.sellerId,show_id: showId)
            )
            await SVProgressHUD.dismiss()
            followUnfollowSuccess()
        }
    }
    private func getProfileData() async {
        guard !liveShowsData.isEmpty else { return }
        let sellerId = liveShowsData[currentIndex].products?.first?.user?.id ?? 0
        guard sellerId != 0 else {
            print("⚠️ Seller ID not available")
            return
        }
        SVProgressHUD.show()
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showHud = true
            return
        }
        await profileViewModel.getProfile(param: ProfileParamRequest(id: "\(sellerId)"))
        await SVProgressHUD.dismiss()
        profileSuccess()
    }

    func profileSuccess() {
        SVProgressHUD.dismiss()
        let response = profileViewModel.getProfileDict
        if response.status == "success" {
            if let data = response.data {
                isFollowing = data.is_following ?? false
                followSheetTask = Task {
                    Task {
                        do {
                            try await Task.sleep(nanoseconds: 30 * 1_000_000_000)

                            guard !Task.isCancelled else { return }
                            guard !isFollowing else { return }

                            await MainActor.run {
                                showFollowSheet = true
                            }
                        } catch {
                            // Task was cancelled — do nothing
                        }
                    }
                }
            }
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: profileViewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }

    func followUnfollowSuccess() {
        SVProgressHUD.dismiss()
        let response = profileViewModel.followDict
        if response.status == "success" {
            hudMsg = response.message ?? ""
            showHud = true
            
            isFollowing = true
//            socketManagerChat.sendFollowUnfollow(followerId: "\(UserDefaults.userId)", followingId: sellerId, showId: showId)
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: profileViewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
}
// MARK: - Menu Action Enum
enum MenuAction: CaseIterable {
    case gift,promote, paperclip, share, wallet, cart
    var iconName: ImageResource {
        switch self {
        case .gift: return .gift
        case .promote: return .rPromote
        case .paperclip: return .clip
        case .share: return .share
        case .wallet: return .wallet
        case .cart: return .shop
        }
    }
    
    var label: String {
        switch self {
        case .gift: return "Gift"
        case .promote: return "Promote"
        case .paperclip: return "Attachment"
        case .share: return "Share"
        case .wallet: return "Wallet"
        case .cart: return "Cart"
        }
    }
}
// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let completion: ((UIActivity.ActivityType?, Bool, [Any]?, Error?) -> Void)? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = completion
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
// MARK: - Chat Message Bubble
struct ChatMessageBubble: View {
    let comment: CommentModel
    let isHost: Bool
    let isMod: Bool = false
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            CustomProfileImage(
                url: comment.image ?? "",
                isCircular: true,
                size: 26
            )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(comment.username?.capitalizingFirstLetter() ?? "")
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.white)
                    
                    if isHost {
                        Text("HOST")
                            .font(.custom(poppinsSemiBold, size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.defaultTheme.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    
                    if isMod {
                        Text("MOD")
                            .font(.custom(poppinsSemiBold, size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.8))
                            .foregroundColor(.black)
                            .cornerRadius(4)
                    }
                }
                
                Text(comment.message ?? "")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(10)
            }
            
            Spacer()
        }
    }
}
