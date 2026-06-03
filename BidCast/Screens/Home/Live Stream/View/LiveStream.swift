
//
//  LiveStream.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI
import SVProgressHUD
//import ZegoExpressEngine
import AlertToast
//import MillicastSDK
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
    @State var sudden_Death = false
    
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
//    @ObservedObject var zegoManager = ZegoManager.shared
//    @ObservedObject var chatManager = ZIMChatManager.shared
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
    @State private var auctionTypeId = -1
    
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

    // Basecamp #9943369910 (re-fix #2, 2026-06-02): deterministic schedule-show
    // id for scoping the in-show product list. The live room id is always
    // formatted `live_room_<userId>_<showId>` (RehearsalScreen builds it that
    // way and parses it identically), so the trailing segment is the
    // schedule_shows.id the backend get-product endpoint filters on. Prefer
    // parsing it from the room id; fall back to the room model's show_id, then
    // the @State showId. Returns "" only if none are available (then the
    // product list falls back to the full catalog, as before).
    private var resolvedScheduleShowId: String {
        // 1) Parse from the current room id: live_room_<userId>_<showId>
        let rid = currentRoomID.isEmpty
            ? (liveShowsData[safe: currentIndex]?.room_id ?? "")
            : currentRoomID
        if rid.hasPrefix("live_room_") {
            if let last = rid.split(separator: "_").last,
               last.allSatisfy({ $0.isNumber }), !last.isEmpty {
                return String(last)
            }
        }
        // 2) Fall back to the room model's show_id
        if let sid = liveShowsData[safe: currentIndex]?.show_id, !sid.isEmpty {
            return sid
        }
        // 3) Fall back to the @State showId set in joinStreamUsingSocket
        return showId
    }

    @State var productCount = 0
    
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
//    @State private var renderer = MCAcceleratedVideoRenderer()
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
    
    @State var showNotes: String = ""
    @State var showNotesSheet = false
    
    @State private var showWinnerOnParent = false
    @State private var randomWinner: String = ""
    @State private var randomWinnerImage: String = ""
    @State private var navigateToRandomizer : Bool = false
    
    @State private var auctionStartedRooms: Set<String> = []
    var isAuctionStartedForCurrentRoom: Bool {
        auctionStartedRooms.contains(currentRoomID)
    }

    // MARK: - Auction-Type Helpers (Mission Control: cmp55p2y8007b56kdfowbf5wr)
    // auctionTypeId taxonomy (per PM Ankit Verma, 2026-05-14):
    //   == 5  -> Buy Now Auction       (Buy Now button only, no timer, no swipe-to-bid)
    //   == 9  -> Sports Break / Surprise Set (handled separately, existing flow preserved)
    //   other -> Live Auction          (swipe-to-bid + countdown timer + "Bidding Closed")
    private var isBuyNowOnlyAuction: Bool {
        // Sports break (9) is handled via shouldShowBuyNow above; Buy Now only is 5.
        return auctionTypeId == 5
    }
    private var isSportsBreakAuction: Bool {
        return auctionTypeId == 9 || isSurpriseSetAuctionActive
    }
    private var isLiveAuction: Bool {
        return !isBuyNowOnlyAuction && !isSportsBreakAuction
    }

    // Flips true once we've seen at least one non-"00:00" tick from `bid_timer_update`
    // for the current product/auction. Reset on auction or product change. Without this
    // gate we'd briefly show "Bidding Closed" between product switch and the first
    // server tick (when bidTime is still the previous auction's "00:00").
    @State private var hasObservedBidTimerThisAuction: Bool = false

    // MARK: - Bid Timer Expiry Guard (Mission Control: cmp55p2y8007b56kdfowbf5wr)
    /// True when the auction bid countdown has elapsed for the current product and the
    /// server has not yet emitted `bid_finalized`. Used to lock the swipe-to-bid UI and
    /// the bid action sites so no more bids are accepted after the timer reaches 00:00.
    ///
    /// Buy Now Auction (auctionTypeId == 5) has no timer, so this is always false there.
    /// Sports Break / Surprise Set (auctionTypeId == 9) keeps its existing flow.
    private var isBidTimerExpired: Bool {
        guard isAuctionStartedForCurrentRoom else { return false }
        // Buy Now has no countdown timer at all -> never expired.
        if isBuyNowOnlyAuction { return false }
        // Sports break keeps its current behavior -- the surprise-set Int countdown still
        // gates the existing UI elsewhere; we don't lock bidding from this path.
        if isSportsBreakAuction { return false }
        // Live Auction: lock bids once the server-driven countdown hits 00:00 AND we know
        // the countdown was actually running for this auction (avoids false-positive at
        // auction-start before the first bid_timer_update tick, and at product switch).
        guard hasObservedBidTimerThisAuction else { return false }
        guard let product = auctionedProductData else { return false }
        if product.status == "sold" { return false }
        return socketManagerChat.bidTime == "00:00"
            && socketManagerChat.hasWon == false
    }
    @State var auctionedProductData: ProductDataModel1? = nil
    @State  var  boosts = [BoostModel]()
    @StateObject private var viewModelFreebie = FreebieViewModel()
    @State var wheelTitles = [FreebieUser]()
    
    @State var isFreebieActive : Bool = false
    @State var usersCount = 0
    
    @State private var freebieWinner = FreebieUser()
    
    // Add these state variables to LiveStream struct
    @State private var isSurpriseSetAuctionActive: Bool = false
    @State private var currentSurpriseSetData: ProductSurpriseData?
    @State private var surpriseSetBidTime: Int = 0
    
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
                    sellerId: $sellerId,
                    categoryIds: $categoryId,
                    // Basecamp #4 (PWA refs 27688115, 1ec77674, fa249bc9): pass
                    // the currently-auctioned product id so the live product list
                    // can show the disabled "Bidding Live" state on that row.
                    currentAuctionedProductId: currentProductID,
                    // Basecamp #9943369910 (re-fix #2, 2026-06-02): scope the
                    // product list to THIS show so the seller only sees items
                    // added to the show, not their whole catalog.
                    // Backend is correct (verified live: get-product with
                    // show_id=559 -> 3 products; without -> all 10). Prior fixes
                    // sourced the id from self.showId / RoomModel.show_id, which
                    // were empty in the seller's live session (Trey: "nothing
                    // changed", still all 10). Deterministic source instead:
                    // the host roomId is ALWAYS formatted live_room_<userId>_<showId>
                    // (see RehearsalScreen which parses it the same way at
                    // lines 282 & 382), so the trailing _-segment IS the
                    // schedule_shows.id that get-product filters on. Parse that,
                    // with fallbacks to the room model / @State value.
                    scheduleShowId: resolvedScheduleShowId
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
                    // Trey QA 2026-05-31: products opened from a live-show ARE
                    // in a show context — pre-bid button should be visible here.
                    isFromShowContext: true,
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
        .onFirstAppear {
            setupInitialState()
            loadInitialData()
            listenForRaidEvents()
            // Basecamp #9934003774 (2026-05-27): listen for the host kicking us.
            socketManagerChat.listenForKickedFromShow { msg in
                // Exit the room — host removed us, can't rejoin. Show the toast
                // FIRST, then dismiss after a beat so the message is actually
                // visible (dismissing immediately tears down the toast before it
                // renders — Basecamp #9956272376).
                logoutRoom()
                toastMessage = msg
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            // Basecamp #9956272376 (2026-06-02): the server rejects the join
            // with join_room_error (e.g. the buyer was removed from this show
            // earlier → code "kicked"). Without handling it the buyer was stuck
            // forever on the black "Loading show…" screen. Show the removal
            // message, THEN dismiss after a short delay so the buyer actually
            // sees WHY they were bounced (previously the immediate dismiss tore
            // the toast down before it could render → silent bounce to Home).
            socketManagerChat.listenForJoinRoomError { msg, code in
                logoutRoom()
                let shown = (code == "kicked")
                    ? "You have been removed from this show by the host."
                    : msg
                toastMessage = shown
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
       
    }
    @ViewBuilder
    private var baseContentLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            mainContentView
                .gesture(tapGesture)

            // Basecamp #9938441753 (2026-05-28): if the show data never
            // loads (socket room_create_get never fires, network issue,
            // etc.), the previous behavior was a solid black screen with
            // NO close button visible because the headerView lived inside
            // mainContentView which only renders when liveShowsData has
            // entries. Result: buyer is stuck and has to force-quit the app.
            // Add a fallback overlay with a close button + status text so
            // the buyer can ALWAYS exit the screen.
            if liveShowsData.isEmpty {
                liveStreamFallbackOverlay
            }
        }
    }

    // Fallback overlay shown when liveShowsData is empty. Provides a
    // back/close button + a status message so the buyer can exit.
    @ViewBuilder
    private var liveStreamFallbackOverlay: some View {
        VStack {
            HStack {
                Button(action: {
                    // Tear down Agora + dismiss the screen.
                    agoraManager.leaveChannel()
                    SocketManagerService.shared.removeAllListeners()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                .padding(.leading, 16)
                Spacer()
            }
            .padding(.top, 50)
            Spacer()
            // Basecamp #9956272376: when the join is rejected (e.g. the buyer
            // was kicked), show the removal reason IN PLACE of the loading
            // spinner. The previous AlertToast approach didn't render on this
            // full-screen black overlay, so the buyer saw a silent bounce. This
            // is guaranteed visible because it's part of the overlay already on
            // screen. `showToast` is set by listenForJoinRoomError/Kicked.
            if showToast {
                VStack(spacing: 14) {
                    Image(systemName: "hand.raised.slash.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.85))
                    Text(toastMessage.isEmpty
                         ? "You have been removed from this show by the host."
                         : toastMessage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                    Text("Returning to home…")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.4)
                    Text("Loading show…")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                    Text("If the show doesn't load in a few seconds, tap the X above to go back.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            Spacer()
            Spacer()
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
                notesAndFreebieOverlay
                Spacer()
                bottomContentStack
            }
            if navigateToRandomizer {
                RandomizerView
            }
            
            sideMenuView(geometry: geometry)
        }
    }

//    .presentationBackground(Color.black.opacity(0.1))
    @ViewBuilder
    private var RandomizerView: some View {
        
        RandomizerEnterTopView(
            usersName: $viewModelFreebie.options,
            usersData: $wheelTitles,
            isPresented: $navigateToRandomizer,
            roomId: $currentRoomID,
            winnerUser: $freebieWinner,
            didEnterFreBie: {
                socketManagerChat.enterInFreebie(
                    room_id: currentRoomID,
                    userId: UserDefaults.userId
                )
            },
            onShuffleEnd: { winner in
                   print("Winner is: \(winner.name ?? "Unknown")")
                randomWinner = winner.name ?? ""
                randomWinnerImage = winner.profile_image ?? ""
                navigateToRandomizer = false
                showWinnerOnParent = true
                   
               }
        )
           
    }
    @ViewBuilder
    private var notesAndFreebieOverlay: some View {
        HStack(alignment: .top) {
            
            // MARK: - Show Notes (Leading)
            Button(action: {
                showNotesSheet = true
//                isEditingNotes = false
            }) {
                Text("Show\nNotes")
                    .font(.custom(poppinsSemiBold, size: 13))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 12,
                            topTrailingRadius: 12
                        )
                        .fill(Color.white)
                    )
//                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            // MARK: - Freebie (Trailing)
            if isFreebieActive{
                Button(action: {
                    navigateToRandomizer = true
                }) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Freebie")
                                .font(.custom(poppinsSemiBold, size: 13))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 12))
                                Text("\(usersCount) Entries")
                                    .font(.custom(poppinsRegular, size: 11))
                                    .foregroundColor(.white)
                            }
                            .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 12,
                            bottomLeadingRadius: 12,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                        .fill(Color.black.opacity(0.4))
                    )
                }
            }
        }
        .padding(.horizontal, 0)
        .padding(.top, 10)
    }

    // MARK: - Video Player View
//    @ViewBuilder
//    private var videoPlayerView: some View {
//        if let _ = agoraManager.remoteUserId {
//            VideoContainerView(uiView: agoraManager.remoteVideoView)
//                .frame(width: screenWidth, height: screenHeight)
//                .ignoresSafeArea()
//                .background(Color.black)
//        }
//    }
    @ViewBuilder
    private var videoPlayerView: some View {
        // ✅ FIXED: Always show the view so Agora can attach video to it
        ZStack {
            // Always render the video container
            VideoContainerView(uiView: agoraManager.remoteVideoView)
                .frame(width: screenWidth, height: screenHeight)
                .ignoresSafeArea()
                .background(Color.black)
            
            // Show loading indicator until remote user joins
//            if agoraManager.remoteUserId == nil && agoraManager.isJoined {
//                VStack(spacing: 16) {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        .scaleEffect(1.5)
//                    
//                    Text("Waiting for stream...")
//                        .font(.custom(poppinsRegular, size: 14))
//                        .foregroundColor(.white.opacity(0.7))
//                }
//            }
        }
        .onChange(of: agoraManager.remoteUserId) { newValue in
            print("🔄 Remote User ID changed to: \(String(describing: newValue))")
        }
        .onChange(of: agoraManager.isJoined) { joined in
            print("📡 Channel joined status: \(joined)")
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
        if self.sellerInfo != nil {
            HStack(spacing: 12) {
                CustomProfileImage(
                    url: sellerInfo?.seller_details?.profile_image ?? "",
                    isCircular: true,
                    size: 40
                ) {
                    showSellerProfileSheet = true
                }
                
                sellerInfoColumn(sellerInfo: sellerInfo ?? SellerInfoResponse())
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
                .foregroundColor(.white)
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
//    @ViewBuilder
//    private var productDetailsView: some View {
//       
//      
//        if isAuctionStartedForCurrentRoom {
//            let currentProducts = auctionedProductData
//            let product = currentProducts
//            if product != nil /*&& product?.status != "sold"*/{
//                VStack(alignment: .leading, spacing: 12) {
//                    currentProductCard(product: product ?? ProductDataModel1() )
//                    if product?.status != "sold"{
//                        biddingControls
//                    }else{
//                        waitingForProductView
//                    }
//                }
//                
//            } else {
//                waitingForProductView
//            }
//        }else{
////            waitingForProductView
//        }
//    }
    @ViewBuilder
    private var productDetailsView: some View {
        if isAuctionStartedForCurrentRoom {
            // Check if it's a surprise set / sports break auction (auctionTypeId == 9 path).
            // Existing flow is preserved per PM spec; no "Bidding Closed" injected here.
            if isSurpriseSetAuctionActive, let surpriseSet = currentSurpriseSetData {
                VStack(alignment: .leading, spacing: 12) {
                    surpriseSetProductCard(surpriseSet: surpriseSet)
                    biddingControls
                }
            }
            // Regular product auction (Buy Now == 5 OR Live Auction otherwise)
            else if let product = auctionedProductData {
                VStack(alignment: .leading, spacing: 12) {
                    currentProductCard(product: product)
                    if product.status != "sold" {
                        // Only Live Auction shows "Bidding Closed" — Buy Now has no timer.
                        if isLiveAuction && isBidTimerExpired {
                            biddingClosedView
                        } else {
                            biddingControls
                        }
                    } else {
                        waitingForProductView
                    }
                }
                // Track that we've seen at least one non-zero tick for this auction so a
                // momentary "00:00" between product switch and first server tick doesn't
                // flip the UI to "Bidding Closed" prematurely. Reset whenever we move to
                // a new product (currentProductID) or the auction stops/starts.
                .onChange(of: socketManagerChat.bidTime) { _, newValue in
                    if newValue != "00:00" {
                        hasObservedBidTimerThisAuction = true
                    }
                }
                .onChange(of: currentProductID) { _, _ in
                    hasObservedBidTimerThisAuction = false
                }
                .onChange(of: isAuctionStartedForCurrentRoom) { _, started in
                    if !started { hasObservedBidTimerThisAuction = false }
                }
            } else {
                waitingForProductView
            }
        }
    }

    // MARK: - Bidding Closed View
    /// Replaces the bid controls when the auction countdown has elapsed but the server
    /// has not yet finalized the bid. Prevents the user from sliding-to-bid or tapping
    /// Buy Now / Custom after the timer reaches 00:00. (MC: cmp55p2y8007b56kdfowbf5wr)
    @ViewBuilder
    private var biddingClosedView: some View {
        Text("Bidding Closed")
            .font(.custom(poppinsBold, size: 14.0))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal)
    }
    
    //MARK: Current product section
    @ViewBuilder
    private func currentProductCard(product: ProductDataModel1) -> some View {
        CurrentProductView(
            product: product,
            auctionTypeId:$auctionTypeId,
            currentPrice: $currentPrice,
            suddenDeath: $sudden_Death,
            bidTime: $socketManagerChat.bidTime,
            userName: $winnerName,
            userImage: $winnerProfileImage,
            categoryName: $categoryName, hasWon: $socketManagerChat.hasWon,sellerId: $sellerId,
            onTap: { self.showItemDetailSheet = true }
        )
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func surpriseSetProductCard(surpriseSet: ProductSurpriseData) -> some View {
        CurrentSurpriseSetView(
            surpriseSet: surpriseSet,
            currentPrice: $currentPrice,
            suddenDeath: $sudden_Death,
            bidTime: $surpriseSetBidTime,
            userName: $winnerName,
            userImage: $winnerProfileImage,
            hasWon: $socketManagerChat.hasWon,
            sellerId: $sellerId,
            onTap: {
                // Handle tap on surprise set if needed
                print("Tapped surprise set")
            },
            onTapRunNext: {
                // Only host can run next - viewers shouldn't see this button
                print("Run next not available for viewers")
            }
        )
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var waitingForProductView: some View {
        Text("Awaiting next product...")
            .font(.custom(poppinsBold, size: 14.0))
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.leading, 16)
            .padding(.trailing, 16)
    }
    
    //MARK: Bid  section
//    @ViewBuilder
//    private var biddingControls: some View {
//        HStack(spacing: 8) {
//            if self.auctionTypeId != 5 {
//                if auctionTypeId == 9{
//                    if currentSurpriseSetData?.type == "auction"{
//                        customBidButton
//                        swipeToBidSection
//                    }else{
//                        PrimaryButton(title: "Buy Now",isOutLine: false,onButtonClick: {
//                            
//                            if UserDefaults.allowBidForAllUser {
//                                self.sendBid(
//                                    roomId: currentRoomID,
//                                    bidAmount: currentPrice.description,
//                                    productId: currentProductID ?? "", auctionTypeId: auctionTypeId
//                                    
//                                )
//                            } else {
//                                if handleBidding(){
//                                    self.sendBid(
//                                        roomId: currentRoomID,
//                                        bidAmount: currentPrice.description,
//                                        productId: currentProductID ?? "", auctionTypeId: auctionTypeId
//                                        
//                                        
//                                    )
//                                }
//                            }
//                            
//                        })
//                    }
//                }else{
//                    customBidButton
//                    swipeToBidSection
//                }
//            }
//            else{
//                
//                PrimaryButton(title: "Buy Now",isOutLine: false,onButtonClick: {
//                    
//                    if UserDefaults.allowBidForAllUser {
//                        self.sendBid(
//                            roomId: currentRoomID,
//                            bidAmount: currentPrice.description,
//                            productId: currentProductID ?? "", auctionTypeId: auctionTypeId
//                            
//                        )
//                    } else {
//                        if handleBidding(){
//                            self.sendBid(
//                                roomId: currentRoomID,
//                                bidAmount: currentPrice.description,
//                                productId: currentProductID ?? "", auctionTypeId: auctionTypeId
//                                
//                                
//                            )
//                        }
//                    }
//                    
//                })
//            }
//                
//            
//            
//        }
//        .padding(.horizontal)
//        .onAppear {
//            setupBiddingIfNeeded()
//        }
//    }
    
    private var shouldShowBuyNow: Bool {
        if auctionTypeId == 5 {
            return true
        }

        if auctionTypeId == 9 {
            return currentSurpriseSetData?.type != "auction"
        }

        return false
    }
    
    @ViewBuilder
    private var biddingControls: some View {
        HStack(spacing: 8) {
            if shouldShowBuyNow {
                buyNowButton
            } else {
                customBidButton
                swipeToBidSection
            }
        }
        .padding(.horizontal)
        .onAppear {
            setupBiddingIfNeeded()
        }
    }
    private var buyNowButton: some View {
        PrimaryButton(
            title: "Buy Now",
            isOutLine: false
        ) {
            // Buy Now Auction (auctionTypeId == 5) has no timer, so this guard is a
            // Live-Auction-only safeguard for Buy-It-Now-within-live-auction edge cases.
            // (MC: cmp55p2y8007b56kdfowbf5wr)
            if isLiveAuction && isBidTimerExpired { return }
            if UserDefaults.allowBidForAllUser || handleBidding() {
                sendBid(
                    roomId: currentRoomID,
                    bidAmount: currentPrice.description,
                    productId: currentProductID ?? "",
                    auctionTypeId: auctionTypeId
                )
            }
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
        // Live Auction only: stop custom bids once countdown hits 00:00.
        // (MC: cmp55p2y8007b56kdfowbf5wr)
        if isLiveAuction && isBidTimerExpired { return }
        if handleBidding(){
//            if UserDefaults.allowBidForAllUser {
//                self.maxBidAmountSheet = true
//            } else {
                self.maxBidAmountSheet = true
                
//            }
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
                .foregroundColor(.white)
           
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
            .foregroundColor(.white)
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
            // Live Auction only: stop swipe-to-bid once countdown hits 00:00.
            // (Swipe is only ever shown in Live Auction mode, but defense in depth.)
            // (MC: cmp55p2y8007b56kdfowbf5wr)
            if isLiveAuction && isBidTimerExpired {
                swipeConfirmed = false
                return
            }
            if UserDefaults.allowBidForAllUser {
                swipeConfirmed = true
                incrementPrice()
            } else {
                if handleBidding(){
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
            if handleBidding(){
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
    
    // Basecamp #9933877362 (2026-05-27): verified-buyer becomes optional.
    // Returns true when the currently-viewed show requires the buyer to be
    // verified. Sellers can opt their show in with #9933883175's toggle.
    // When false, the only requirement to interact (bid/tip/purchase/wallet)
    // is having a verified payment method on file.
    private var currentShowRequiresVerification: Bool {
        return liveShowsData[safe: currentIndex]?.is_verified_only == true
    }

    private func handleWalletAction() {
        // Basecamp #9933877362 (2026-05-27): only enforce identity verification
        // when the seller has opted this show into verified-buyers-only.
        if currentShowRequiresVerification && UserDefaults.buyerVerafied != "verified" {
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
    private func handleBidding() -> Bool {
        // MC cmpaj2fex0000w5hgq64jp9k4 / Basecamp 9922137425 (2026-05-24):
        // Refuse to let the logged-in user place a bid or Buy Now on their
        // own product. Previously there was no client-side guard — the host
        // of a live stream could place bids on their own auctioned items,
        // and a buyer could end up auto-buying their own listed product
        // through the Buy-It-Now socket flow. Backend may also reject but
        // surfacing it as a toast here is the better UX.
        if let hostIdStr = liveShowsData[safe: currentIndex]?.seller?.id,
           let hostId = Int(hostIdStr),
           hostId == UserDefaults.userId {
            toastMessage = "You can't bid on your own items."
            showToast = true
            return false
        }

        // Basecamp #9933877362 (2026-05-27): identity verification only required
        // when the seller has opted this show into verified-buyers-only.
        if currentShowRequiresVerification && UserDefaults.buyerVerafied != "verified" {
            showVerificationSheet = true
            return false
        } else {
            if UserDefaults.sellerAddress == false {
                showPaymentShipping = true
                titleText = "Add Address"
                return false
            } else if UserDefaults.hasCardAdded == false {
                showPaymentShipping = true
                titleText = "Add Card"
                return false
            } else {
                return true
            }
        }
    }
    
    @ViewBuilder
    private var productStackView: some View {
        VStack {
            if isAuctionStartedForCurrentRoom {
                let currentProducts = auctionedProductData ?? ProductDataModel1()
                let product = currentProducts
                if product != nil {
                    // FIX cmp41hieh00rj4axy15wpcmqz: resolve product image URL.
                    // Android sends images[] as relative paths (e.g.
                    // "uploads/products/img.jpg"). iOS sends full URLs in
                    // thumbnail[]. Check both and prepend the backend base
                    // URL for relative paths so AsyncImage can load them.
                    let rawImg = product.images?.first(where: { !$0.isEmpty })
                        ?? product.thumbnail?.first(where: { !$0.isEmpty })
                        ?? ""
                    let resolvedImg: String = {
                        guard !rawImg.isEmpty else { return "" }
                        if rawImg.hasPrefix("http://") || rawImg.hasPrefix("https://") {
                            return rawImg
                        }
                        return "https://backend.bidcast.betaplanets.com/" + rawImg
                    }()
                    StackedImageView(imageURL: resolvedImg, totalCount: productCount) {
                        print("productStackTapped")
                        navigateToProductList = true
                    }
                }
            }else{
                StackedImageView(imageURL: "", totalCount: productCount) {
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
            // Basecamp #9956272376: kicked/rejected-join message. This lives in
            // the always-rendered top-level toastLayer so it shows even on the
            // black "Loading show…" overlay (where liveShowsData is empty and the
            // in-content toast never renders). Duration matches the 1.8s dismiss
            // delay in the join_room_error / kicked handlers.
            .toast(isPresenting: $showToast, duration: 1.7) {
                AlertToast(
                    displayMode: .alert,
                    type: .regular,
                    title: toastMessage,
                    style: .style(backgroundColor: Color.black.opacity(0.85), titleColor: Color.white)
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
                onDismiss: {
                    print("Erorrrrrr3")
                    showError = true
                }
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
            .sheet(isPresented: $showNotesSheet) {
                showNotesSheetContent
                    .presentationDetents([.fraction(0.80)])
                    .presentationCornerRadius(25)
                    .presentationDragIndicator(.hidden)
            }
//            .sheet(isPresented: $navigateToRandomizer) {
//                RandomizerSheet
//               
//                .presentationDetents([.fraction(0.55)])
//                    .presentationCornerRadius(25)
//                    .presentationDragIndicator(.hidden)
//                    .presentationBackground(Color.black.opacity(0.1))
//    //                .interactiveDismissDisabled()
//            }
            .overlay(
                Group{
                    if navigateToRandomizer{
                        RandomizerSheet
                    }
                }
            )
            .overlay(
                Group{
                    if showWinnerOnParent{
                        winnerOverlay
                    }
                }
            )
            
    }
    
    // MARK: - Sheet Content Views
    
    @ViewBuilder
    private var showNotesSheetContent: some View {
        ShowNotesSheet(
            noteText: $showNotes,
            forHost : .constant(false),
            onPost: { note in
//                showNotes += note
                showNotesSheet = false
            },
            didTapCancel: {
                showNotesSheet = false
            }
        )
    }
    
    
    @ViewBuilder
    private var RandomizerSheet: some View {
//        RandomizerLiveView(usersName: $viewModelFreebie.options, isPresented: $navigateToRandomizer, roomId: $currentRoomID,onWinnerSelected: { winner in
//            randomWinner = winner.name ?? ""
//            randomWinnerImage = winner.profile_image ?? ""
//            navigateToRandomizer = false
//            showWinnerOnParent = true
////            showSpin = false
//        },didEnterFreBie: {
//            socketManagerChat.enterInFreebie(room_id : currentRoomID, userId: UserDefaults.userId)
//        })
//            .presentationBackground(Color.black.opacity(0.1))
        
//        RandomizerEnterTopView(
//            usersName: $viewModelFreebie.options,
//            isPresented: $navigateToRandomizer,
//            roomId: $currentRoomID,
//            didEnterFreBie: {
//                socketManagerChat.enterInFreebie(
//                    room_id: currentRoomID,
//                    userId: UserDefaults.userId
//                )
//            }
//        )
//        .presentationBackground(Color.black.opacity(0.1))
    }
    @ViewBuilder
    private var winnerOverlay: some View {
        if showWinnerOnParent {
            TikTokStyleWinnerView(
                winner: randomWinner,
                winnerImage: randomWinnerImage,
                isShowing: $showWinnerOnParent
            )
            .transition(.opacity)
            .zIndex(1000)
        }
    }
    
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
//                    self.presentationMode.wrappedValue.dismiss()
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
                    exp_year: data?.default_card?.exp_year,
                    exp_month: data?.default_card?.exp_month,
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
                if homeViewModel.errorMessage == "" || homeViewModel.errorMessage == nil {
                    getProfileSuccess()
                }
                
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
                print("Erorrrrrr5")
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
//        guard let product = liveShowsData[currentIndex].products?.first else {
//            print("⚠️ product not available")
//            return
//        }
        guard let sellerId = liveShowsData[currentIndex].seller?.id else {
            print("⚠️ product not available")
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
                self.sellerId = sellerId
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
            print("Erorrrrrr6")
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
            print("Erorrrrrr7")
            showError = true
        }
    }

    private func presentError(title: String, message: String) {
        showError = true
        print("Erorrrrrr8")
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

        // Basecamp #9933402746 (2026-05-27): wire the buyer-side show-notes
        // listener. Previously this was only called in RehearsalScreen (seller),
        // so iOS buyers received the initial show_notes on join (via the
        // get_show_note broadcast that fires on every join_room) but never
        // received subsequent updates when the seller edited notes mid-stream.
        // Now the listener stays subscribed for the full duration of the
        // viewer session and updates `showNotes` whenever the seller updates.
        socketManagerChat.listenForGetShowNote { notes in
            showNotes = notes
        }
        // Basecamp #9933402746 (2026-05-27 round 2): defensive explicit fetch
        // for show notes. The join_room broadcast can race against listener
        // registration; this guarantees the buyer pulls the current notes
        // even if the initial broadcast was missed.
        socketManagerChat.requestShowNote(roomId: roomId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            socketManagerChat.requestShowNote(roomId: roomId)
        }

        // MC cmpfokeza001doohgkt8xc8d0 (2026-05-22): wire the viewer-side
        // poll listeners. Previously this screen declared `showPollView`
        // and `currentPollModel` but never subscribed to the socket
        // events that populate them, so polls created by the host were
        // invisible on the buyer side. Mirrors the pattern in
        // RehearsalScreen.swift:1937 (host) but adds `observePollCreated`
        // and `observePollEnded` for resilience — the host can rely on
        // vote-update alone because it created the poll, but viewers
        // need the create event to know to show the card in the first
        // place.
        socketManagerChat.observePollCreated { pollModel in
            // MC cmpfokeza001doohgkt8xc8d0 (2026-05-22): match against the
            // local `roomId` parameter on setupSocketListeners(for:) — the
            // LiveStream view does not expose a `roomId` property of its
            // own. (`self.currentRoomID` is the @Binding equivalent if a
            // future caller wants to use that instead.)
            guard pollModel.roomId == roomId else { return }
            DispatchQueue.main.async {
                self.remainingTimer = timerStringToSeconds(pollModel.remainingTime)
                self.currentPollModel = pollModel
                self.showPollView = pollModel.isActive
            }
        }

        socketManagerChat.observePollVoteUpdate { pollModel in
            guard pollModel.roomId == roomId else { return }
            DispatchQueue.main.async {
                self.remainingTimer = timerStringToSeconds(pollModel.remainingTime)
                self.currentPollModel = pollModel
                self.showPollView = pollModel.isActive
            }
        }

        socketManagerChat.observePollEnded { pollId in
            DispatchQueue.main.async {
                // `pollId` arrives as a String from the socket payload;
                // PollModel.pollId is an Int. Compare via String coercion
                // so a numeric mismatch doesn't leak a stale poll into
                // the UI.
                if let current = self.currentPollModel,
                   String(current.pollId) == pollId {
                    self.currentPollModel = nil
                }
                self.showPollView = false
            }
        }

        socketManagerChat.listenForRoomEnded { endedRoomId in
            logoutRoom()
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
            if winnerName != ""{
                currentPrice = Double(winnerAmount) ?? 0.0
            }
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
        
        socketManagerChat.listenForAuctionNextProduct { roomID,products,source  in
            guard roomId == roomID else { return}
            
        }
        
        socketManagerChat.listenForFreebieWinner { user in
            print("🏆 ===== WINNER RECEIVED =====")
            print("   Winner Name: \(user.name ?? "unknown")")
            print("   Winner ID: \(user.id ?? 0)")
            DispatchQueue.main.async {
                freebieWinner = user
                navigateToRandomizer = true
            }
        }
        
        socketManagerChat.listenForFreebie{ freebie,user in
            let roomID = freebie.room_id ?? ""
            guard self.currentRoomID == roomID else{
                return
            }
            freebieWinner = FreebieUser()
            isFreebieActive = true
            self.wheelTitles = user
            let title = user.map { $0.name ?? ""}
            self.viewModelFreebie.options.removeAll()
            viewModelFreebie.options.append(contentsOf: title)
            usersCount = user.count
            // Basecamp #9889548312 + #9929848961 (2026-05-26): show the buyer
            // randomizer overlay immediately on get-freebie. Previously the
            // overlay only appeared after get-freebie-winner, so buyers had
            // no way to enter or see the wheel animate. Matches Android,
            // which shows the freebieLayout + sets up the wheel here.
            DispatchQueue.main.async {
                navigateToRandomizer = true
            }
            print("Freebie user data \(wheelTitles) for showId : \(freebie.show_id ?? "")")
        }

        // Basecamp #9889548312 + #9929848961 (2026-05-26): listen for the
        // mid-flight spin event. When it arrives, the overlay is already
        // visible (set in listenForFreebie above); we just confirm it stays
        // up so the shuffle animation in RandomizerEnterTopView keeps running.
        socketManagerChat.listenForFreebieSpinning { roomId, _, _ in
            guard self.currentRoomID == roomId else { return }
            DispatchQueue.main.async {
                if !navigateToRandomizer { navigateToRandomizer = true }
            }
        }
       

        // MARK: - Break Spot (Surprise Set) Listeners
        socketManagerChat.listenForAuctionStartedBreakSpot { response,status, roomID, productSetId, productSetItemId, productSetItemUnitId, startingBidAmount, requireTime, counterBidTime, suddenDeath in
            guard self.currentRoomID == roomID else { return }
            self.auctionStartedRooms.insert(roomID)
            print("🎁 Surprise Set Auction Started - Set: \(productSetId), Item: \(productSetItemId), Unit: \(productSetItemUnitId)")
            
            DispatchQueue.main.async {
                self.isSurpriseSetAuctionActive = true
                
                self.updateCurrentSurpriseSet(from: response)
                
                self.currentPrice = Double(startingBidAmount) ?? 0.0
                self.sudden_Death = suddenDeath
                self.currentProductID = "\(productSetId)_\(productSetItemId)_\(productSetItemUnitId)"
               
            }
        }

        socketManagerChat.listenForBidTimerUpdateBreakSpot(roomId: roomId) { remaining in
            DispatchQueue.main.async {
                self.surpriseSetBidTime = remaining
                self.socketManagerChat.bidTime = self.socketManagerChat.formatElapsedTime(seconds: remaining)
            }
        }

        socketManagerChat.listenForAuctionEndedBreakSpot { roomID, productSetId, productSetItemId, productSetItemUnitId, message in
            guard self.currentRoomID == roomID else { return }
            print("🏁 Surprise Set Auction Ended - Set: \(productSetId), Message: \(message ?? "N/A")")
            
            DispatchQueue.main.async {
                self.isSurpriseSetAuctionActive = false
                self.currentSurpriseSetData = nil
            }
        }

        socketManagerChat.listenForBidFinalizedBreakSpot { roomID, productSetId, productSetItemId, productSetItemUnitId, winner in
            guard self.currentRoomID == roomID else { return }
            print("🏆 Surprise Set Winner - \(winner?.user_name ?? "No winner")")
            
            DispatchQueue.main.async {
                self.isSurpriseSetAuctionActive = false
                
                if let winner = winner {
                    self.winnerName = winner.user_name ?? ""
                    self.winnerProfileID = Int(winner.user_id ?? "") ?? 0
                    self.winnerProfileImage = winner.user_image ?? ""
                    self.winnerAmount = winner.bid_amount ?? ""
                    self.currentPrice = Double(self.winnerAmount) ?? 0.0
                    
                    if !self.winnerName.isEmpty {
                        self.showWinnerOnParent = true
                        if self.winnerProfileID == UserDefaults.userId {
                            self.randomWinner = "You"
                        } else {
                            self.randomWinner = self.winnerName.capitalizingFirstLetter()
                        }
                        self.randomWinnerImage = self.winnerProfileImage
                    }
                }
                
                self.currentSurpriseSetData = nil
            }
        }

        socketManagerChat.listenForAuctionOrderFailed { roomID, productSetId, userid  in
            guard self.currentRoomID == roomID else { return }
            print("❌ Surprise Set Order Failed - )")
            DispatchQueue.main.async {
               
                self.isSurpriseSetAuctionActive = false
                self.currentSurpriseSetData = nil
            }
        }
      
        // Listen for highest bid updates on surprise sets
        socketManagerChat.listenForHighestBidBreakSpot(forRoom: roomId) { highestBid in
            guard let bid = highestBid else { return }
            
            // Only update if surprise set auction is active
            guard self.isSurpriseSetAuctionActive else { return }
            
            DispatchQueue.main.async {
                print("🏆 Highest Bid (Surprise Set): \(bid.user_name ?? "") - \(bid.bid_amount ?? "")")
                self.winnerName = bid.user_name ?? ""
                self.winnerProfileID = Int(bid.user_id ?? "") ?? 0
                self.winnerProfileImage = bid.user_image ?? ""
                self.winnerAmount = bid.bid_amount ?? ""
                
                if self.winnerName != "" {
                    self.currentPrice = Double(self.winnerAmount) ?? 0.0
                }
            }
        }
    }
    private func updateCurrentSurpriseSet(from response: AuctionStartedBreakSpotResponse) {

        // 1️⃣ Map product_set_item → ProductItemResponse array
        var items: [ProductItemResponse]? = nil

        if let productSetItem = response.surpriseSetDetails?.productSetItem {
            let item = ProductItemResponse(
                id: productSetItem.id ?? 0,
                name: productSetItem.name,
                quantity: productSetItem.quantity,
                soldQuantity: productSetItem.soldQuantity,
                description: productSetItem.description,
                status: productSetItem.status
            )
            items = [item]
        }

        // 2️⃣ Map product_set → ProductSurpriseData
        if let productSet = response.surpriseSetDetails?.productSet {

            let surpriseData = ProductSurpriseData(
                name: productSet.name,
                type: productSet.type,
                description: productSet.description,
                price: productSet.price,
                shippingProfileId: nil,
                quickSpin: nil,
                autoRandomizer: nil,
                userId: nil,
                isLiveBid: nil,
                id: productSet.id ?? 0,
                items: items
            )

            self.currentSurpriseSetData = surpriseData
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
        if startingBidAmount == 0.0{
            let price = Double(products.first?.pricing ?? "") ?? 0.0
            currentPrice = price
        }else{
            currentPrice = startingBidAmount
        }
        sudden_Death = suddenDeath
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
        
        maxBidAmountSheet = false
        winnerName = name
        winnerProfileID = id
        winnerProfileImage = image
        winnerAmount = amount
        
        // Mark as sold based on auction type
        if isSurpriseSetAuctionActive {
            // Surprise set completed
            isSurpriseSetAuctionActive = false
            currentSurpriseSetData = nil
        } else {
            auctionedProductData?.status = "sold"
        }
        
        if !winnerName.isEmpty {
            showWinnerOnParent = true
            if winnerProfileID == UserDefaults.userId {
                randomWinner = "You"
            } else {
                randomWinner = winnerName.capitalizingFirstLetter()
            }
            randomWinnerImage = winnerProfileImage
            currentPrice = Double(winnerAmount) ?? 0.0
            self.auctionStartedRooms.remove(roomId)
        }
    }

//    private func handleBidFinalized(for roomId: String, winner: HighestBid?) {
//        fetchProducts(for: roomId)
//        
//        let name = winner?.user_name ?? ""
//        let id = Int(winner?.user_id ?? "") ?? 0
//        let image = winner?.user_image ?? ""
//        let amount = winner?.bid_amount ?? ""
//        
//        print("🏁 Bid finalized - Winner: \(name), Amount: \(amount)")
////        auctionedProductData = nil
//        
//        maxBidAmountSheet = false
//        winnerName = name
//        winnerProfileID = id
//        winnerProfileImage = image
//        winnerAmount = amount
//        auctionedProductData?.status = "sold"
//        if !winnerName.isEmpty{
//            showWinnerOnParent = true
//            if winnerProfileID == UserDefaults.userId{
//                randomWinner = "You"
//            }else{
//                randomWinner = winnerName.capitalizingFirstLetter()
//            }
//            randomWinnerImage = winnerProfileImage
//            currentPrice = Double(winnerAmount) ?? 0.0
//        }
//        
//
//    }

    private func handleBuyerVerification() {
        switch UserDefaults.buyerVerafied {
        case "pending":
            alertType = .sheetType(
                icon: .info,
                title: "Become a Verified Buyer!",
                message: "Your verification is currently pending approval by the admin. You will be notified once the process is complete.",
                primaryBtnText: "OK",
                secondaryBtnText: "",
                buttonWidth: screenWidth - 60,
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
                buttonWidth: screenWidth - 60,
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
        let currentRoomData = socketRooms[matchingRoomIndex]
        // MC cmp5g5h0k00qs56kd2etclc2a (Ankit 2026-05-14): the first product's
        // category can be nil (auctioned-and-cleared, or the product hasn't
        // pinned yet for a fresh viewer). Walk the products array and pick
        // the first non-zero category id. If none of the products have a
        // category, leave categoryId at 0 — ProductShopListScreen now
        // interprets that as "no category filter" and fetches the seller's
        // full inventory instead of returning an empty list.
        categoryId = currentRoomData.products?
            .compactMap { $0.category?.id }
            .first(where: { $0 > 0 }) ?? 0
        // Same fall-through for sellerId: the first product may be missing
        // user info on a fresh join — walk the list until we find one with
        // a real user id. Falls back to 0 if nothing matches (caller checks).
        let resolvedSellerId = currentRoomData.products?
            .compactMap { $0.user?.id }
            .first(where: { $0 > 0 }) ?? 0
        sellerId = "\(resolvedSellerId)"
        auctionTypeId = currentRoomData.auction_type_id ?? 0
        self.agoraToken = socketRooms[matchingRoomIndex].rtc_token ?? ""
        if !agoraToken.isEmpty && !roomId.isEmpty {
            print("🎥 Joining Agora with token: \(agoraToken)")
            agoraManager.joinChannel(asHost: isHost, channelName: roomId, token: agoraToken)
        }
        
        self.roomID = socketRooms.compactMap { $0.room_id }
        self.streamID = self.roomID
        let showId = socketRooms[matchingRoomIndex].show_id ?? ""
        self.showId = showId
        productCount = socketRooms[matchingRoomIndex].productCount ?? 0
        if switchStreamType == .none {
            self.liveShowsData = socketRooms
            self.currentRoomID = roomId
            sortLiveShowsDataByCurrentRoom()
        }
        
        print("🎬 Joining stream: \(roomId)")
        socketManagerChat.joinShowForPromotionalData(room_id: currentRoomID, UserId: "\(UserDefaults.userId)")
        socketManagerChat.listenForUserFollowStatus()
        SocketManagerService.shared.removeAllListeners()
        
        Task {
            await setupSocketListeners(for: roomId)
        }
        
//        fetchProducts(for: roomId)
        // Basecamp #9933877362 (2026-05-27): only pop the verification reminder
        // on join when the show is gated to verified buyers only. For open
        // shows, do NOT block the viewer with an identity-verification modal
        // — they only need a verified payment method later, at bid/tip/buy time.
        if currentShowRequiresVerification {
            handleBuyerVerification()
        }
        socketManagerChat.listenForAuctionStarted { status,roomId,products,startingBidAmount,requireTime,counterBidTime,suddenDeath in
//            guard let self else { return }
            print("AUCtioned data")
            print("RoomId -> \(roomId)")
            print("products -> \(products)")
            print(" ->\(startingBidAmount)")
            print(" -> \(requireTime)")
            print("-> \(counterBidTime)")
            print("-> \(suddenDeath)")
            print("Status -> \(status)")
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
//                auctionedProductData = nil
                
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
//                async let profileTask: Void = getProfileData()

                do {
                    try await sellerTask
                    print("✅ Seller fetched")
                } catch {
                    print("❌ Seller error:", error.localizedDescription)
                    throw error
                }

//                do {
//                    try await profileTask
//                    print("✅ Profile fetched")
//                } catch {
//                    print("❌ Profile error:", error.localizedDescription)
//                    throw error
//                }

            } catch {
                print("❌ loadInitialData Error:", error.localizedDescription)

                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: error.localizedDescription,
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                print("Erorrrrrr9")
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

//    func sendBid(roomId: String, bidAmount: String, productId: String,auctionTypeId :Int) {
//        let data: [String: Any] = [
//            "room_id": roomId,
//            "bid_amount": bidAmount,
//            "user_name": UserDefaults.userName,
//            "user_image": UserDefaults.profileURL,
//            "user_id": "\(UserDefaults.userId)",
//            "product_id": productId,
//            "auction_type_id":auctionTypeId
//        ]
//        socketManagerChat.sendBid(payload: data)
//        currentPrice = Double(bidAmount) ?? 0.0
//        let price = String(format: "%.2f", currentPrice)
//        commentText = "Current highest bid : $\(price)"
//        commentText = ""
//    }
    
    func sendBid(roomId: String, bidAmount: String, productId: String, auctionTypeId: Int) {
        // Defense-in-depth: refuse to emit any bid socket event once a Live Auction
        // countdown has elapsed. Buy Now (5) has no timer; Sports Break (9) uses its
        // own surprise-set flow so we don't gate it from here.
        // (MC: cmp55p2y8007b56kdfowbf5wr)
        if isLiveAuction && isBidTimerExpired {
            print("⛔ sendBid blocked — bid timer expired for room \(roomId), product \(productId)")
            return
        }
        // Check if this is a surprise set auction
        if isSurpriseSetAuctionActive{
           let components = productId.split(separator: "_").map(String.init)
            if components.count == 3{
                // This is a surprise set bid
                let productSetId = Int(components[0]) ?? 0
                        let productSetItemId = Int(components[1]) ?? 0
                        let productSetItemUnitId = Int(components[2]) ?? 0
                        
                        socketManagerChat.placeBidBreakSpot(
                            roomId: roomId,
                            bidAmount: bidAmount,
                            userName: UserDefaults.userName,
                            userImage: UserDefaults.profileURL,
                            userId: "\(UserDefaults.userId)",
                            productSetId: productSetId,
                            productSetItemId: productSetItemId,
                            productSetItemUnitId: productSetItemUnitId,
                            productSetType: currentSurpriseSetData?.type ?? ""
                        )
            }

        } else {
            // Regular product bid
            let data: [String: Any] = [
                "room_id": roomId,
                "bid_amount": bidAmount,
                "user_name": UserDefaults.userName,
                "user_image": UserDefaults.profileURL,
                "user_id": "\(UserDefaults.userId)",
                "product_id": productId,
                "auction_type_id": auctionTypeId
            ]
            socketManagerChat.sendBid(payload: data)
        }
        
        currentPrice = Double(bidAmount) ?? 0.0
        let price = String(format: "%.2f", currentPrice)
        commentText = "Current highest bid : $\(price)"
        commentText = ""
    }

//    func logoutRoom() {
//        agoraManager.leaveChannel()
//        SocketManagerService.shared.chats.removeAll()
//            self.comments.removeAll()
//            SocketManagerService.shared.leaveRoom(roomId: self.currentRoomID, userId: UserDefaults.userId)
//            currentProductID = nil
//            productId = 0
//            self.currentPrice = 0.0
//            self.currentProductIndex = -1
//        auctionedProductData = nil
//        socketManagerChat.leaveShow(showId: showId, UserId: "\(UserDefaults.userId)")
//        }
    func logoutRoom() {
        agoraManager.leaveChannel()
        SocketManagerService.shared.chats.removeAll()
        self.comments.removeAll()
        SocketManagerService.shared.leaveRoom(roomId: self.currentRoomID, userId: UserDefaults.userId)
        currentProductID = nil
        productId = 0
        self.currentPrice = 0.0
        self.currentProductIndex = -1
        auctionedProductData = nil
        
        // Clean up surprise set state
        isSurpriseSetAuctionActive = false
        currentSurpriseSetData = nil
        surpriseSetBidTime = 0
        
        socketManagerChat.leaveShow(showId: showId, UserId: "\(UserDefaults.userId)")
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
                productId: currentProductID ?? "", auctionTypeId: auctionTypeId
                
                
            )
        }

        func placeBid(amount: Double) {
            guard let currentRoomId = liveShowsData[safe: currentIndex]?.room_id else { return }
            
            self.sendBid(
                roomId: currentRoomId,
                bidAmount: "\(amount)",
                productId: currentProductID ?? "", auctionTypeId: auctionTypeId
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
            print("Erorrrrrr1")
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
        let sellerId = Int(liveShowsData[currentIndex].seller?.id ?? "") ?? 0
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
            print("Erorrrrrr2")
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
            print("Erorrrrrr3")
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
