//
//  LiveStream.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI

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
//    var updatedViewModel = LiveShowsViewModel1()
    @State var homeViewModel = HomeViewModel()
    @State var liveShowsData = [RoomModel]()
    
    @State var showhudSuccess: Bool = false
    @State var showBlockSeller: Bool = false
    
    
    @State var productData = [ProductData]()
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
    //    @State  var currentRoomID = ""
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
    
    @State private var isFollowing: Bool = false
    
    @State private var sellerInfo: SellerInfoResponse? = nil
    
    @State private var followSheetTask: Task<Void, Never>? = nil
    
    var currentProduct: ProductData? {
        productData.first { $0.isCurrent }
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
    
    //MARK: - for swipe
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
    
    @State var messageHeight: CGFloat = 40   // single message height
    let maxVisibleMessages = 3
    @State var sellerId = ""
    
    @State var showItemDetailSheet = false
    
    var body: some View {
        GeometryReader { geometry in
            if liveShowsData.count != 0{
                ZStack(alignment: .top) {
                    if let _ = agoraManager.remoteUserId {
                        VideoContainerView(uiView: agoraManager.remoteVideoView)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .ignoresSafeArea()
                            .background(Color.black)
                    }
                    VStack(alignment:.leading) {
                        HStack(spacing: 12) {
                            Button(action:{
                                id = userId
                            }){
                                let data = liveShowsData[currentIndex]
                                if let sellerInfo = viewModel.sellerInfo.data {
                                    CustomProfileImage(url: sellerInfo.seller_details?.profile_image ?? "", isCircular: true,size: 40) {
                                        showSellerProfileSheet = true
                                    }
                                    
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Button {
                                            showSellerProfileSheet = true
                                        } label: {
                                            Text( sellerInfo.seller_details?.name ?? "")
                                                .font(.custom(poppinsBold, size: 14.0))
                                                .foregroundColor(.white)
                                        }
                                        
                                        HStack(spacing:4){
                                            HStack(spacing: 4) {
                                                Image(systemName: "star.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white.opacity(0.9))
                                                
                                                Text("\(sellerInfo.review ?? "0.0")")
                                                    .font(.custom(poppinsRegular, size: 12.0))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                            
                                            
                                            Text("•")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.9))
                                            
                                            
                                            HStack(spacing: 3) {
                                                Image(systemName: "shippingbox")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white.opacity(0.9))
                                                
                                                Text("\(sellerInfo.avg_ship ?? "1d")")
                                                    .font(.custom(poppinsRegular, size: 12.0))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                            
                                            //                                        Spacer(minLength: 4)
                                            if !isFollowing {
                                                Button(action: {
                                                    //                                                if let sellerId = liveShowsData[currentIndex].seller?.id {
                                                    //                                                    socketManagerChat.sendFollowUnfollow(followerId: "\(UserDefaults.userId)", followingId:  sellerId)
                                                    //                                                }
                                                    followUnfollow()
                                                }) {
                                                    Text("Follow")
                                                        .font(.custom(poppinsSemiBold, size: 12.0))
                                                        .foregroundColor(.black)
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 4)
                                                        .background(.defaultTheme)
                                                        .cornerRadius(10)
                                                }
                                            }
                                        }
                                    }
                                }
                                else  {
                                    HStack(spacing: 12) {
                                        // Profile Image Shimmer
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 40, height: 40)
                                            .shimmer()
                                        
                                        // Info Shimmer
                                        VStack(alignment: .leading, spacing: 6) {
                                            // Name Shimmer
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 120, height: 14)
                                                .shimmer()
                                            
                                            // Stats Shimmer
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
                                Spacer()
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
                                //                                .padding(.vertical, 4)
                                .frame(height: 28)
                                .padding(.horizontal, 6)
                                .background(Color.black.opacity(0.35))
                                .clipShape(Capsule())
                                
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
                        }
                        .padding(.horizontal,12)
                        .padding(.top, 50)
                        
                        Spacer()
                        
                        //MARK: Side menu
                        
                        VStack(alignment: .leading, spacing: 12){
                            
                            //MARK: Comment section
                            if socketManagerChat.chats.count > 0 {
                                HStack{
                                    ScrollViewReader { proxy in
                                        ScrollView(.vertical, showsIndicators: false) {
                                            
                                            VStack {
                                                Spacer(minLength: 0)  // bottom alignment
                                                
                                                LazyVStack(alignment: .leading, spacing: 6) {
                                                    
                                                    ForEach(socketManagerChat.chats) { comment in
                                                        let data = liveShowsData[currentIndex]
                                                        let isHost = comment.userId == data.seller?.id ?? ""
                                                        let isMod = !isHost
                                                        
                                                        ChatMessageBubble(comment: comment, isHost: isHost, isMod: isMod)
                                                            .background(
                                                                GeometryReader { geo in
                                                                    Color.clear.onAppear {
                                                                        // Capture height of ONE message (only once)
                                                                        if messageHeight == 40 {
                                                                            messageHeight = geo.size.height + 10
                                                                        }
                                                                    }
                                                                }
                                                            )
                                                            .id(comment.id)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                        }
                                        .frame(width:screenWidth - 54
                                               , height: socketManagerChat.chats.count == 0
                                               ? 0
                                               : min(CGFloat(socketManagerChat.chats.count), CGFloat(maxVisibleMessages)) * messageHeight
                                        )
                                        .animation(.easeOut(duration: 0.2), value: socketManagerChat.chats.count)
                                        .onChange(of: socketManagerChat.chats) { _ in
                                            if let lastID = socketManagerChat.chats.last?.id {
                                                withAnimation(.easeOut(duration: 0.25)) {
                                                    proxy.scrollTo(lastID, anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                            //                        Spacer()
                            //MARK: Add Comment section
                            
                            HStack {
                                ZStack(alignment: .trailing) {
                                    TextField(
                                        "",
                                        text: $commentText,
                                        prompt: Text("Say something...")
                                            .foregroundColor(.gray)    // placeholder color
                                            .font(.custom(poppinsRegular, size: 13))
                                    )
                                    .foregroundColor(.white)            // typed text color
                                    .font(.custom(poppinsRegular, size: 13))
                                    
                                    .padding(.horizontal, 8)
                                    .padding(.trailing, commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 14 : 40)
                                    
                                    .frame(height: 40)
                                    .frame(width:BiddingDetail.products != nil ? screenWidth-45 : screenWidth-90 )
                                    .font(.custom(poppinsSemiBold, size: 13))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .background(
                                        Capsule()
                                            .fill(Color.black.opacity(0.35))     // translucent fill
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white, lineWidth: 1)   // border
                                    )
                                    
                                    
                                    if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Button(action: {
                                            let roomId = liveShowsData[currentIndex].room_id ?? ""
                                            //                                            ZIMChatManager.shared.sendMessage(message: commentText,roomId: roomId,image: UserDefaults.profileURL,name: UserDefaults.fullName)
                                            let userId = UserDefaults.userId
                                            let userName = UserDefaults.userName
                                            let userImage = UserDefaults.profileURL
                                            SocketManagerService.shared.sendChat(roomId: roomId, message: commentText, userId: userId, userName: userName, userImage: userImage)
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
                                }
                                
                            }
                            .padding(.leading,16)
                            .padding(.trailing, BiddingDetail.products != nil ? 54 : 16)
                            
                            .animation(.easeOut(duration: 0.25), value: keyboardResponder.currentHeight)
                            
                            VStack(alignment: .leading,spacing: 12) {
                                if showPollView {
                                    if let poll = currentPollModel {
                                        PollPreviewCardView(poll: poll, remainingTime: remainingTimer, onPollCardTapped: {
                                            print("PollCard clicked")
                                            showLivePollScreen = true
                                        })
                                    }
                                }
                                
                                //MARK: Product Details
                                let currentProducts = productData.filter { $0.isCurrent }
                                if let product = currentProducts.first {
                                    
                                    CurrentProductView(product: product,
                                                       currentPrice: $currentPrice,
                                                       bidTime: $socketManagerChat.bidTime,
                                                       userName: $winnerName, userImage: $winnerProfileImage,
                                                       categoryName: $categoryName,
                                                       onTap: {
                                        self.showItemDetailSheet = true
                                    }
                                                       
                                    )
                                    .frame(maxWidth: .infinity)
                                    
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(10)
                                    .padding(.horizontal,16)
                                    
                                    //MARK: Swipe fearture
                                    HStack(spacing: 8) {
                                        
                                        // Max Button
                                        Text("Custom")
                                            .font(.custom(poppinsBold, size: 13))
                                            .foregroundColor(.white)
                                            .frame(width: 80, height: 42)
                                            .background(
                                                Capsule()
                                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                            )
                                            .onTapGesture {
                                                if UserDefaults.allowBidForAllUser{
                                                    self.maxBidAmountSheet = true
                                                }else{
                                                    if UserDefaults.buyerVerafied != "verified" {
                                                        showVerificationSheet = true
                                                    }else{
                                                        self.maxBidAmountSheet = true
                                                    }
                                                }
                                            }
                                        
                                        // Swipe to Bid Section
                                        ZStack(alignment: .leading) {
                                            
                                            // Background Capsule (Yellow fill)
                                            //                                            Capsule()
                                            //                                                .frame(height: 45)
                                            
                                            // Inner Outline
                                            //                                            Capsule()
                                            ////                                                .fill(Color(hex: "F4D447") ?? Color.darkYellow)
                                            //                                                .frame(height: 45)
                                            Capsule()
                                                .stroke(.defaultTheme , lineWidth: 1)
                                                .frame(height: 42)
                                            
                                            // Center Text + Arrows
                                            let nextBid = nextBidAmount(for: currentPrice)
                                            
                                            
                                            
                                            // Draggable Button (Styled)
                                            RoundedRectangle(cornerRadius: 22)
                                                .fill(.defaultTheme)
                                                .frame(width: screenWidth/2 - 40, height: 36)
                                                .overlay(
                                                    HStack(spacing: 6) {
                                                        Text("Bid: $\(Int(nextBid))")
                                                            .font(.custom(poppinsSemiBold, size: 14))
                                                            .foregroundColor(.black)
                                                        
                                                        Image(systemName: "chevron.right")
                                                            .font(.system(size: 13, weight: .bold))
                                                            .foregroundColor(.black)
                                                            .opacity(animate ? 1 : 0.2)
                                                            .offset(x: animate ? 3 : 0)
                                                        
                                                        // Chevron 2
                                                        Image(systemName: "chevron.right")
                                                            .font(.system(size: 13, weight: .bold))
                                                            .foregroundColor(.black)
                                                            .opacity(animate ? 1 : 0.2)
                                                            .offset(x: animate ? 6 : 0)
                                                    }
                                                        .onAppear {
                                                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                                                animate = true
                                                            }
                                                        }
                                                )
                                                .offset(x: max(4, min(dragOffset.width + 4, screenWidth * 0.3)))
                                                .gesture(
                                                    DragGesture()
                                                        .onChanged { value in
                                                            if value.translation.width >= 0 {
                                                                dragOffset = value.translation
                                                            }
                                                        }
                                                        .onEnded { value in
                                                            if value.translation.width > totalSwipeWidth * 0.25 {
                                                                
                                                                // Trigger Bid
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
                                                )
                                                .animation(.easeOut, value: dragOffset)
                                        }
                                        .frame(height: 45)
                                        .frame(maxWidth: .infinity)
                                        
                                    }
                                    
                                    .padding(.horizontal)
                                    .onAppear {
                                        if !isBiddingActive {
                                            if UserDefaults.buyerVerafied != "verified" {
                                                showVerificationSheet = true
                                                
                                            }else{
                                                //                                                startCountdown()
                                                isBiddingActive = true
                                            }
                                            
                                        }
                                    }
                                }else {
                                    Text("Waiting for next product...")
                                        .font(.custom(poppinsSemiBold, size: 14.0))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.leading,16)
                                        .padding(.trailing, 16)
                                }
                            }
                            //                            .padding(.horizontal,16)
                            .padding(.bottom, keyboardResponder.currentHeight == 0 ? (tabBarHeight + 20) : 10)
                        }
                    }
                    VStack(spacing: 12) {
                        //                            ForEach(MenuAction.allCases, id: \.self) { action in
                        ForEach(filteredActions, id: \.self) { action in
                            Button(action: {
                                if action == .gift {
                                    currentBottomSheet = action
                                    showSheet = true
                                }
                                //                                else if action == .cart {
                                //                                    currentBottomSheet = action
                                //                                    showSheet = true
                                //                                }
                                else if action == .share {
                                    shareItems = ["Live auction starting in 5 minutes! Don’t miss out on exclusive items.", URL(string: "https://www.backend.bidcast.betaplanets.com/live-show?roomid=\(currentRoomID)")!]
                                    print(shareItems)
                                    showSystemShareSheet = true
                                }
                                else if action == .wallet{
                                    if UserDefaults.buyerVerafied != "verified" {
                                        showVerificationSheet = true
                                    }else{
                                        if UserDefaults.sellerAddress == false{
                                            showPaymentShipping = true
                                            titleText = "Add Address"
                                        }else if UserDefaults.hasCardAdded == false{
                                            showPaymentShipping = true
                                            titleText = "Add Card"
                                        }else{
                                            currentBottomSheet = action
                                            showSheet = true
                                        }
                                    }
                                }
                            }) {
                                VStack(spacing:0){
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
                        
                        VStack {
                            if let product = currentProduct,
                               let img = product.image {
                                StackedImageView(imageURL: img, totalCount: productData.count) {
                                    print("productStackTapped")
//                                    if pipManager.isPiPActive {
//                                        pipManager.stopPiP()
//                                    } else {
//                                        pipManager.startPiP()
//                                    }
                                    navigateToProductList = true
                                }
                            }
                        }
                        
                    }
                    .position(
                        x: geometry.size.width - 40,
                        y: geometry.size.height / 2 - 20
                    )
                }
                //                .edgesIgnoringSafeArea(.all)
                .gesture(
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
                            let verticalAmount = value.translation.height
                            let swipeThreshold: CGFloat = 100
                            
                            if verticalAmount < -swipeThreshold && currentIndex < streamID.count - 1 {
                                // Swipe Up
                                withAnimation(.easeInOut) {
                                    verticalDragOffset = CGSize(width: 0, height: -geometry.size.height)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    //leave current stream
                                    logoutRoom()
                                    hasHostEndedRoom.toggle()
                                    //shift to next stream
                                    if currentIndex < liveShowsData.count {
                                        currentIndex += 1
                                    }
                                    
                                    let currentRoomId = liveShowsData[currentIndex].room_id ?? ""
                                    switchStream(to: currentRoomId)
                                    //get next show agora token
                                    //get currentroom id
                                    //call beelow func for updated room id
                                }
                            } else if verticalAmount > swipeThreshold && currentIndex > 0 {
                                // Swipe Down
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
                            } else {
                                withAnimation {
                                    verticalDragOffset = .zero
                                }
                            }
                        }
                )
                .bottomSheet(isPresented: $showPaymentShipping, height: screenHeight / 2.8) {
                    PaymentAndShippingInfoSheet(
                        isPresented: $showPaymentShipping,
                        onAddInfo: {
                            if UserDefaults.sellerAddress != true {
                                navigateToShipping = true
                            } else if UserDefaults.hasCardAdded != true {
                                navigateToAddCardScreen = true
                            }
                        }, buttonText: $titleText
                    )
                }
                CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(id:$id, isComeFrom: .constant(""),userName: $userName,userImage: $userImage))
                
                CusNavLink(doNavigate: $navigateToBuyer, destination: TrustedBuyerScreen(comeFromHome:$comeFromHome))
                
                CusNavLink(doNavigate: $navigateToAddCardScreen, destination: PaymentAndShipping_Screen())
                CusNavLink(doNavigate: $navigateToProductList,
                           destination: ProductShopListScreen(sellerId: liveShowsData[currentIndex].seller?.id ?? "")
                )
                
                CusNavLink(doNavigate: $navigateToShipping, destination: PaymentAndShipping_Screen())
                CusNavLink(doNavigate: $navigateToEditPayment, destination: PaymentAndShipping_Screen())
                CusNavLink(doNavigate: $navigateToEditAddress, destination: PaymentAndShipping_Screen())
                CusNavLink(doNavigate: $showItemDetailSheet,
                           destination: ProductDetailView(
                            onDismiss : {
                                self.showItemDetailSheet = false
                                productId = 0
                            },
                            productID: $productId,
                            sellerInfo: $sellerInfo)
                )
                CusNavLink(
                    doNavigate: $navigateToChat,
                    destination: ChatScreen(
                        viewModel: prepareChatData()
                    )
                )
            }
            
        }.gesture(
            TapGesture().onEnded { _ in
                hideKeyboard()
            }
        )
        
        .toast(isPresenting: $showHud,duration: 1.5) {
            AlertToast(displayMode: .alert, type: .regular, title: hudMsg ,style: .style(backgroundColor: .black.opacity(0.4), titleColor: .white))
        }
        .toast(isPresenting: $showhudSuccess,duration: 1.5) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlyeSuccess)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.8, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showError = true
        }) {
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
        .bottomSheet(isPresented: $showErrorPopup, height: screenHeight / 2.8, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showErrorPopup = true
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation {
                        showErrorPopup = false
                    }
                },
                onSecondaryClick: {
                    withAnimation {
                        showErrorPopup = false
                    }
                }
            )
        }
        .bottomSheet(
            isPresented: $showFollowSheet,
            height: screenHeight / 2.5,
            topBarCornerRadius: 20
        ) {
            FollowSellerSheet(
                seller: sellerInfo,
                onFollow: {
                    print("Follow tapped")
                    showFollowSheet = false
                    //API Call
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
        
        .bottomSheet(isPresented: $showSellerProfileSheet, height: screenHeight * 0.70, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showSellerProfileSheet = false
        }) {
            SellerProfileBottomSheet(
                isPresented: $showSellerProfileSheet,
                sellerInfo: sellerInfo,
                onTipOrBoost: { print("Tip or Boost")
                    showSellerProfileSheet = false
                    showTipSheet = true
                },
                onViewProfile: { print("View Profile")
                    showSellerProfileSheet = false
                    navigateToProfile = true
                },
                onMessage: { print("Message")
                    showSellerProfileSheet = false
                    let currentUserId = String(UserDefaults.userId)
                    let otherUserId =   liveShowsData[currentIndex].seller?.id ?? ""
                    let sortedRoomId = computeRoomId(senderId: currentUserId, receiverId: otherUserId)
                    chatPath = "chats/\(sortedRoomId)"
                    print("Computed Chat Path: \(chatPath)")
                    navigateToChat = true
                },
                onBlock: { print("Block")
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
                onFollow: { print("Follow")
                    showSellerProfileSheet = false
                }
            )

        }
        
        .bottomSheet(isPresented: $showReportSheet,
                     height: screenHeight * 0.65,
                     topBarCornerRadius: 0,
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
            isPresented: $showBlockSeller,
            height: screenHeight * 0.45,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                showBlockSeller = false
            },  content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showBlockSeller = false }
                        //yes tapped -> block seller
                        let sellerId = liveShowsData[currentIndex].seller?.id ?? ""
                        blockSeller(with: sellerId)
                    }, onSecondaryClick: {
                        withAnimation { showBlockSeller = false }
                    })
            })

        
//        .bottomSheet(
//            isPresented: $showLivePollScreen,
//            height: screenHeight * 0.8,
//            topBarCornerRadius: 20,
//            contentBackgroundColor: Color(.systemBackground),
//            topBarBackgroundColor: Color(.systemBackground),
//            showTopIndicator: false,
//            onDismiss: {
//                showLivePollScreen = false
//            },
//            content: {
//                LivePollViewerView(poll: poll, onVote: { poll in
//                    print("Vote emitted:", poll)
//                    currentPollModel = poll
//                }, onRequestRefresh: {
//                    print("request refresh")
//                    showPollView = false
//                    showLivePollScreen = false
//                })
//            }
//        )
        
        .bottomSheet(isPresented: $showVerificationSheet, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showVerificationSheet = false
            if !showVerificationSheet{
                if UserDefaults.sellerAddress == false{
                    showPaymentShipping = true
                    titleText = "Add Address"
                }else if UserDefaults.hasCardAdded == false{
                    showPaymentShipping = true
                    titleText = "Add Card"
                }
            }
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation {
                        if UserDefaults.buyerVerafied == "pending" {
                            showVerificationSheet = false
                        }else{
                            navigateToBuyer = true
                            showVerificationSheet = false
                        }
                        
                        if !showVerificationSheet{
                            if !navigateToBuyer{
                                if UserDefaults.sellerAddress == false{
                                    showPaymentShipping = true
                                    titleText = "Add Address"
                                }else if UserDefaults.hasCardAdded == false{
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
        
        .bottomSheet(
            isPresented: $showTipSheet,
            height: screenHeight * 0.55,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                showTipSheet = false
            },
            content: {
                if liveShowsData.count > 0 {
                    SendTipView(
                        sellerId: liveShowsData[currentIndex].seller?.id ?? "",
                        onClose: {
                            showTipSheet = false
                        },
                        onSendTip: {
                            print("Sent tip")
                            showTipSheet = false
                        })
                }
            }
        )
                    
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
            onDismiss: {
                showSheet = false
            },
            content: {
                switch currentBottomSheet {
                case .gift:
                    SendTipView(
                        sellerId: liveShowsData[currentIndex].seller?.id ?? "",
                        onClose: {
                            showSheet = false
                        },
                        onSendTip: {
                            print("Sent tip")
                        }
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
                    //                    ShareShowBottomSheetView(
                    //                        isPresented: $showSheet,
                    //                        showTitle: "John's Live Show",
                    //                        username: "johnsmith",
                    //                        showImage: Image("icWatch"),
                    //                        message: "Live auction starting in 5 minutes! Don’t miss out on exclusive items.",
                    //                        onShare: { platform in
                    //                            print("Shared to \(platform)")
                    //                        },
                    //                        onSavePDF: {
                    //                            print("PDF Saved")
                    //                        },
                    //                        onShareEmail: {
                    //                            print("Email sent")
                    //                        }
                    //                    )
                    
                    ShareSheet(items: shareItems)
                case .wallet:
                    let data = homeViewModel.accountInfo.data
                    PaymentBottomSheet(
                        isPresented: $showSheet,
                        paymentMethods: [
                            PaymentMethod(creditCard: CreditCard(
                                cardNumber: data?.default_card?.card_id,
                                expirationDate: data?.default_card?.exp_date,
                                cardType:  data?.default_card?.cardType
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
                case .cart:
                    ShopBottomSheetView(
                        isPresented: $showSheet,
                        productData : $productData,
                        productShowType: .viewOnly,
                        initialSelectedProductId: currentProductID
                    )
                case .none:
                    EmptyView()
                }
            }
        )
        
        .bottomSheet(
            isPresented: $showSheet,
            height: sheetHeight,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                showSheet = false
            },
            content: {
                ShopBottomSheetView(
                    isPresented: $showSheet,
                    productData : $productData,
                    productShowType: .viewOnly,
                    initialSelectedProductId: currentProductID
                )
            }
            )
        
//        .bottomSheet(isPresented: $winnerSheet,height: screenHeight * 0.38) {
//            WinnerBottomSheet(
//                winnerAmount: $winnerAmount, profileImage: $winnerProfileImage,
//                username: $winnerName,
//                winnerProfileID : $winnerProfileID,
//                showParentToast: $showToast,
//                parentToastMessage: $toastMessage,
//                onDismiss: {
//                    self.winnerSheet = false
//                }
//            )
//        }
        
        .bottomSheet(isPresented: $maxBidAmountSheet, height: screenHeight * 0.35) {
            if let currentProduct = productData.first {
                MaxBidBottomSheet(
                    showParentToast: $showToast,
                    parentToastMessage: $toastMessage,
                    currentProduct: currentProduct,
                    onSubmit: { amount in
                        if let amount = Double(amount) {
                            placeBid(amount: amount)
                        }
                        //                        self.maxBidAmountSheet = false
                    },
                    onDismiss: {
                        self.maxBidAmountSheet = false
                    }
                )
            }
        }
        
        .edgesIgnoringSafeArea(.all)
        .toolbar(.hidden,for: .tabBar)
        .foregroundColor(.black)
        .background(.black)
//        .onAppear{
//            
//            //works as view did load
//            UserDefaults.isLiveEnded = false
//            //            FirebaseManager.shared.removeNewSessionObserver()
//            //            ZIMChatManager.shared.login(userID: "\(UserDefaults.userId)", userName: UserDefaults.fullName)
//            
//            Task{
//                SVProgressHUD.show()
//                await self.homeViewModel.getProfile()
//                await SVProgressHUD.dismiss()
//                await getProfileSuccess()
//                //               try await joinManager.subscribe(streamName: currentRoomID)
//                socketManagerChat.joinRoom(roomId: currentRoomID, completion: {
//                    //                        guard let self = self else { return }
//                    joinStreamUsingSocket(roomId: currentRoomID)
//                })
//            }
//            
//            socketManagerChat.listenForRaidEvent { raidInfo in
//                print(raidInfo ?? "No Raid Info")
//                logoutRoom()
//                let roomId = raidInfo?.target_room_id ?? ""
//                let rtcToken = raidInfo?.rtcToken ?? ""
//                let message = raidInfo?.message ?? ""
//                if message != "" {
//                    hudMsg = message
//                    showHud = true
//                }
//                currentRoomID = roomId
//                self.agoraToken = rtcToken
//                socketManagerChat.joinRoom(roomId: roomId) {
//                    joinStreamUsingSocket(roomId: roomId)
//                }
//            }
        //        }
        .onAppear {
            setupInitialState()
            loadInitialData()
            listenForRaidEvents()
           
        }

//        .onDisappear{
//            logoutRoom()
//        }
    }
    
    private func setupInitialState() {
        UserDefaults.isLiveEnded = false
    }

    private func loadInitialData() {
        Task { @MainActor in
            SVProgressHUD.show()

            do {
                // Run in parallel — but handle throws
                async let profileTask: Void = homeViewModel.getProfile()

                // Await both tasks safely
                try await profileTask

                await SVProgressHUD.dismiss()

                await getProfileSuccess()
                joinChatRoom(roomId: currentRoomID)

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
            
            // update room + token
            currentRoomID = info.target_room_id ?? ""
            agoraToken = info.rtcToken ?? ""
            
            joinChatRoom(roomId: currentRoomID)
        }
    }
    
    @MainActor
    private func fetchSellerIfAvailable() async {
        guard let sellerId = liveShowsData[currentIndex].seller?.id, !sellerId.isEmpty else {
            print("⚠️ Seller ID not available")
            return
        }

        do {
            // API Call
            try await viewModel.getSellerInfo(sellerID: sellerId)

            print("✅ Seller info updated")

            await SVProgressHUD.dismiss()

            let response = viewModel.sellerInfo
            print("Seller info: \(response)")
            // Ensure we got success
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



    
    // Compute next bid
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

    
    //MARK: walletInfosuccess.
    func getProfileSuccess() async{
        let response  = homeViewModel.accountInfo
        if response.status == "success"{
            let response = self.homeViewModel.accountInfo.data
            UserDefaults.buyerVerafied = response?.buyer_identity_status ?? ""
            UserDefaults.sellerVerafied = response?.seller_identity_status ?? ""
            UserDefaults.sellerAddress = response?.has_shipping_address ?? false
            UserDefaults.hasCardAdded = response?.has_card_added ?? false
            
        }else{
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
    
    @MainActor
    private func setupSocketListeners(for roomId: String) async {
        let userId = UserDefaults.userId
        let userName = UserDefaults.userName
        let userImage = UserDefaults.profileURL
        
        // Notify entry
        SocketManagerService.shared.sendChat(
            roomId: roomId,
            message: "Joined 👋 ",
            userId: userId,
            userName: userName,
            userImage: userImage
        )
        
        // Core listeners
        socketManagerChat.listenForChat(roomId: roomId)
        socketManagerChat.listenForViewerCount()
        socketManagerChat.listenForBidTimer(roomId: roomId)
//        socketManagerChat.observePollUpdates { pollModel in
//            print(pollModel)
//            self.remainingTimer = timerStringToSeconds(pollModel.remainingTime)
//            self.currentPollModel = pollModel
//            showPollView = true
//        }
        
        // Stream end listener
        socketManagerChat.listenForRoomEnded { endedRoomId in
            guard roomId == endedRoomId else { return }
            presentError(title: "Stream Ended", message: "The host has ended the live stream.")
            hasHostEndedRoom = true
        }
        
        // Highest bid listener
        SocketManagerService.shared.listenForHighestBid(forRoom: roomId) { highestBid in
            guard let bid = highestBid else { return }
            print("🏆 Highest Bid: \(bid.user_name ?? "") - \(bid.bid_amount ?? "")")
            winnerName = bid.user_name ?? ""
            winnerProfileID = Int(bid.user_id ?? "") ?? 0
            winnerProfileImage = bid.user_image ?? ""
            winnerAmount = bid.bid_amount ?? ""
        }
        
        // Bid permission listener
        SocketManagerService.shared.getAllowBidForAll(forRoom: roomId) { allowed in
            UserDefaults.allowBidForAllUser = allowed
            print("⚙️ Allow bid for all: \(allowed)")
        }
        
        // Room updates listener
        SocketManagerService.shared.observeRoomUpdates { newRoom in
            print("🏠 Room updated: \(newRoom.room_id ?? "unknown")")
            fetchProducts(for: newRoom.room_id ?? "")
        }
        
        // Bid finalized listener
        SocketManagerService.shared.listenForBidFinalized { roomId, productId, winner in
            handleBidFinalized(for: roomId, winner: winner)
        }
        
        // Next product listener
        SocketManagerService.shared.listenForNextProduct { roomId, _ in
            fetchProducts(for: roomId)
        }
    }
    
    private func handleBidFinalized(for roomId: String, winner: HighestBid?) {
        fetchProducts(for: roomId)
        
        let name = winner?.user_name ?? ""
        let id = Int(winner?.user_id ?? "") ?? 0
        let image = winner?.user_image ?? ""
        let amount = winner?.bid_amount ?? ""
        
        print("🏁 Bid finalized - Winner: \(name), Amount: \(amount)")
        
        winnerName = name
        winnerProfileID = id
        winnerProfileImage = image
        winnerAmount = amount
//        winnerSheet = true
        let message = "Congratulations! You won the bid with an amount of $\(winnerAmount)"
        let roomId = liveShowsData[currentIndex].room_id ?? ""
        let userId = UserDefaults.userId
        let userName = UserDefaults.userName
        let userImage = UserDefaults.profileURL
        SocketManagerService.shared.sendChat(roomId: roomId, message: message, userId: userId, userName: userName, userImage: userImage)
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
        
        // 🧱 STEP 1: Validate rooms
        guard !socketRooms.isEmpty else {
            presentError(
                title: "No Active Streams",
                message: "There are no live streams available at the moment."
            )
            return
        }
        
        
        // 🧱 STEP 2: Validate room existence
        guard let matchingRoomIndex = socketRooms.firstIndex(where: { $0.room_id == roomId }) else {
            presentError(
                title: "Stream Not Found",
                message: "The requested stream is not available right now."
            )
            return
        }
        
        // 🧱 STEP 3: Join Agora Channel
        self.agoraToken = socketRooms[matchingRoomIndex].rtc_token ?? ""
        if !agoraToken.isEmpty && !roomId.isEmpty {
            print("🎥 Joining Agora with token: \(agoraToken)")
            agoraManager.joinChannel(asHost: isHost, channelName: roomId, token: agoraToken)
        }
        
        
        // 🧱 STEP 4: Update local state
        
        self.roomID = socketRooms.compactMap { $0.room_id }
        self.streamID = self.roomID
        
        
        if switchStreamType == .none {
            self.liveShowsData = socketRooms
            self.currentRoomID = roomId
            sortLiveShowsDataByCurrentRoom()
        }
        
        
        print("🎬 Joining stream: \(roomId)")
        
        
        
        // 🧱 STEP 5: Setup follow/unfollow listener
        socketManagerChat.listenForUserFollowStatus()
        
        // 🧱 STEP 6: Clean up previous stream listeners before joining a new one
        SocketManagerService.shared.removeAllListeners()
        
        // 🧱 STEP 7: Join room and setup listeners
        Task {
            await setupSocketListeners(for: roomId)
        }
        
        // 🧱 STEP 8: Update follow status (if available)
        // self.isFollow = currentShow.seller?.isFollowed ?? false
        
        // 🧱 STEP 9: Fetch initial product info
        fetchProducts(for: roomId)
        
        // 🧱 STEP 10: Handle buyer verification
        handleBuyerVerification()
        
    }
    
    /// Reorders the liveShowsData array so that the currentRoomID is at the top (index 0)
    func sortLiveShowsDataByCurrentRoom() {
        guard currentRoomID != "" else { return }
        
        // Ensure we have valid data
        guard !liveShowsData.isEmpty else { return }
        
        // Find current room
        guard let currentRoom = liveShowsData.first(where: { $0.room_id == currentRoomID }) else { return }
        
        // Move current room to top
        var reordered = liveShowsData.filter { $0.room_id != currentRoomID }
        reordered.insert(currentRoom, at: 0)
        liveShowsData = reordered
        
        // Update the current index to 0
        currentIndex = 0
        
        Task { @MainActor in
            do {
                async let sellerTask: Void = fetchSellerIfAvailable()
                async let profileTask: Void =  getProfileData()
                
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
    
    /// Updates the current stream when user switches streams (scroll/swipe)
    func switchStream(to newRoomId: String) {
        guard newRoomId != "" else { return }
        let socketRooms = socketManagerChat.rooms
        socketManagerChat.joinRoom(roomId: currentRoomID, completion: {
            joinStreamUsingSocket(roomId: newRoomId, switchStreamType: .down) //no need to differentiate up and down -> same work
        })
        
    }
    
    
    //    @MainActor
    //    func joinStreamUsingSocket1(roomId: String)  {
    //        let socketRooms = socketManagerChat.rooms
    //        guard !socketRooms.isEmpty else {
    //            showError = true
    //            alertType = .sheetType(
    //                icon: .alert,
    //                title: "No Active Streams",
    //                message: "There are no live streams available at the moment.",
    //                primaryBtnText: "",
    //                secondaryBtnText: AppString.ok.localized
    //            )
    //            return
    //        }
    //
    //        // Check if requested room exists in socket rooms
    //        guard let matchingRoomIndex = socketRooms.firstIndex(where: { $0.room_id == roomId }) else {
    //            showError = true
    //            alertType = .sheetType(
    //                icon: .alert,
    //                title: "Stream Not Found",
    //                message: "The requested stream is not available right now.",
    //                primaryBtnText: "",
    //                secondaryBtnText: AppString.ok.localized
    //            )
    //            return
    //        }
    //        if self.agoraToken != "" && roomId != "" {
    //            print("AAgora Token: \(self.agoraToken)")
    //            agoraManager.joinChannel(asHost: isHost, channelName: roomId, token: agoraToken)
    //        }
    //
    //        //add follow unfollow status
    //        socketManagerChat.listenForUserFollowStatus()
    //
    //        // Set the current room data
    //        DispatchQueue.main.async {
    //            self.liveShowsData = socketRooms
    //            self.roomID = socketRooms.compactMap { $0.room_id }
    //            self.streamID = self.roomID
    //
    //            let currentShow = socketRooms[matchingRoomIndex]
    //
    //            currentIndex = matchingRoomIndex
    //            self.currentRoomID = roomId
    //
    //
    //            print("currentStreamIndex \(currentStreamIndex) matchingRoomIndex index \(matchingRoomIndex)")
    //            // Join the room and send entry message
    //
    //            Task {
    //
    ////                try await joinManager.subscribe(streamName: roomId)
    //
    ////              socketManagerChat.joinRoom(roomId: roomId, userId: UserDefaults.userId)
    //                let userId = UserDefaults.userId
    //                let userName = UserDefaults.userName
    //                let userImage = UserDefaults.profileURL
    //                SocketManagerService.shared.sendChat(roomId: roomId, message: "Joining the host… ", userId: userId, userName: userName, userImage: userImage)
    //                socketManagerChat.listenForChat(roomId: roomId)
    //                socketManagerChat.listenForViewerCount()
    //                socketManagerChat.listenForBidTimer(roomId: roomId)
    //                socketManagerChat.listenForRoomEnded(onEnd: { room_Id in
    //                    if roomId == room_Id {
    //                        print("🔥 STREAM REMOVED CALLBACK TRIGGERED 🔥")
    //                        // Show "Stream Ended" alert
    //                        self.alertType = .sheetType(
    //                            icon: .alert,
    //                            title: "Stream Ended",
    //                            message: "The host has ended the live stream.",
    //                            primaryBtnText: AppString.ok.localized,
    //                            secondaryBtnText: ""
    //                        )
    //                        self.showError = true
    //                        self.hasHostEndedRoom = true
    //                    }
    //                })
    //
    //                SocketManagerService.shared.listenForHighestBid(forRoom: roomId) { highestBid in
    //                    if let bid = highestBid {
    //                        print("🏆 Updated bid in this room: \(bid.user_name ?? "") - \(bid.bid_amount ?? "")")
    //                        winnerName = bid.user_name ?? ""
    //                        winnerProfileID = Int(bid.user_id ?? "") ?? 0
    //                        winnerProfileImage = bid.user_image ?? ""
    //                        winnerAmount = bid.bid_amount  ?? ""
    ////                        print("Winner: \(winnerName), Amount: \(winnerAmount)")
    //                    }
    //                }
    //                SocketManagerService.shared.getAllowBidForAll(forRoom: roomId){ allowed in
    //                    print("alllow BUd \(UserDefaults.allowBidForAllUser)")
    //                    UserDefaults.allowBidForAllUser = allowed
    //
    //                }
    //
    //                SocketManagerService.shared.observeRoomUpdates { newRoom in
    //                    print("🏠 New room received:", newRoom.room_id ?? "unknown")
    //                    fetchProducts(for: newRoom.room_id ?? "")
    //                }
    //
    //                SocketManagerService.shared.listenForBidFinalized(completion: { roomId,productId,winner in
    //                    fetchProducts(for: roomId)
    //                    let winnerNameFromServer = winner?.user_name ?? ""
    //                    let winnerIdFromServer = winner?.user_id ?? ""
    //                    let winnerProfileImageFromServer = winner?.user_image ?? ""
    //                    print("id - > \(winnerIdFromServer)")
    //                    print("name - > \(winnerNameFromServer)")
    //                    print("image - > \(winnerProfileImageFromServer)")
    //
    //                    winnerName = winnerNameFromServer
    //                    winnerProfileID = Int(winnerIdFromServer) ?? 0
    //                    winnerProfileImage = winnerProfileImageFromServer
    //                    winnerAmount = winner?.bid_amount ?? ""
    //                    print("Winner: \(winnerName), Amount: \(winnerAmount)")
    //
    //                    winnerSheet = true
    //                })
    //                SocketManagerService.shared.listenForNextProduct(completion: { roomId,nextProductId in
    //
    //                    fetchProducts(for: roomId)
    //
    //                })
    //            }
    //
    //            // Update follow status
    ////            self.isFollow = currentShow.seller?.isFollowed ?? false
    //            fetchProducts(for: roomId)
    //
    //            // Handle buyer verification
    //            switch UserDefaults.buyerVerafied {
    //            case "pending":
    //                self.alertType = .sheetType(
    //                    icon: .info,
    //                    title: "Become a Verified Buyer!",
    //                    message: "Your verification is currently pending approval by the admin. You will be notified once the process is complete.",
    //                    primaryBtnText: "OK",
    //                    secondaryBtnText: "",
    //                    buttonWidth: screenWidth - 40,
    //                    contentSize: 12.0
    //                )
    //                withAnimation(.snappy) { self.showVerificationSheet = true }
    //
    //            case "verified":
    //                if UserDefaults.sellerAddress == false {
    //                    self.showPaymentShipping = true
    //                    self.titleText = "Add Address"
    //                } else if UserDefaults.hasCardAdded == false {
    //                    self.showPaymentShipping = true
    //                    self.titleText = "Add Card"
    //                }
    //
    //            default:
    //                self.alertType = .sheetType(
    //                    icon: .info,
    //                    title: "Become a Verified Buyer!",
    //                    message: "Before you interact with live shows, you need to become a verified buyer.",
    //                    primaryBtnText: "OK",
    //                    secondaryBtnText: "",
    //                    buttonWidth: screenWidth - 40,
    //                    contentSize: 12.0
    //                )
    //                withAnimation(.snappy) { self.showVerificationSheet = true }
    //            }
    //        }
    //    }
    @MainActor
    func fetchProducts(for roomId: String) {
        guard let socketRoom = socketManagerChat.rooms.first(where: { $0.room_id == roomId }) else {
            self.productData = []
            self.currentProductIndex = 0
            self.currentPrice = 0.0
            return
        }
        if let products = socketRoom.products {
            productData = products
            //            let activeCurrentProducts = products.filter { product in
            //                let status = product.status?.lowercased() ?? ""
            //                return (status == "live" || status == "active") && product.isCurrent
            //            }
            //
            //            if let currentProduct = activeCurrentProducts.first {
            //
            //                if let priceDouble = Double(currentProduct.price ?? "") {
            //                    self.currentPrice = priceDouble
            //                }
            //            }
            if let index = productData.firstIndex(where: { $0.isCurrent }) {
                let currentProduct = productData[index]
                self.currentPrice = Double(currentProduct.price ?? "") ?? 0.0
                self.currentProductIndex = index
                self.currentProductID = currentProduct.id
                self.productId = Int(currentProduct.id ?? "") ?? 0
                print("Current product: \(currentProduct), index: \(index)")
            }
        }
        //        if let products = socketRoom.products {
        //            let activeCurrentProducts = products.filter { product in
        //                let status = product.status?.lowercased() ?? ""
        //                return (status == "live" || status == "active") && product.isCurrent
        //            }
        //
        //            if let currentProduct = activeCurrentProducts.first {
        //                self.productData = [currentProduct]
        //                self.currentProductIndex = 0
        //                self.currentProductID = currentProduct.id
        //                if let priceDouble = Double(currentProduct.price ?? "") {
        //                    self.currentPrice = priceDouble
        //                }
        //            } else {
        //                self.productData = []
        //                self.currentProductIndex = 0
        //                self.currentPrice = 0.0
        //            }
        //        } else {
        //            self.productData = []
        //            self.currentProductIndex = 0
        //            self.currentPrice = 0.0
        //        }
    }
    
    
    func sendBid(roomId: String,
                 bidAmount:String,
                 productId:String ) {
        let data: [String: Any] = [
            "room_id" : roomId,
            "bid_amount": bidAmount,
            "user_name" : UserDefaults.userName,
            "user_image" : UserDefaults.profileURL,
            "user_id" : "\(UserDefaults.userId)",
            "product_id" : productId
        ]
        socketManagerChat.sendBid(payload: data)
        currentPrice = Double(bidAmount) ?? 0.0
        let price = String(format: "%.2f", currentPrice)
        commentText = "Current highest bid : $\(price)"
        commentText = ""
    }
    
    //MARK: logoutRoom
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
    
    func logoutRoom11() {
        // leave RTC
        agoraManager.leaveChannel()
        
        // leave socket room on server
        SocketManagerService.shared.leaveRoom(roomId: self.currentRoomID, userId: UserDefaults.userId)
        
        // clear chats on both manager and local state
        SocketManagerService.shared.chats.removeAll()
        socketManagerChat.chats.removeAll()
        self.comments.removeAll()
        
        // remove room entry from shared rooms to avoid stale product state
        if !self.currentRoomID.isEmpty {
            if let idx = SocketManagerService.shared.rooms.firstIndex(where: { $0.room_id == self.currentRoomID }) {
                SocketManagerService.shared.rooms.remove(at: idx)
            }
        }
        
        // stop/cleanup timers used for bidding/countdown
        priceTimer?.invalidate()
        priceTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        // reset local product / bidding state
        currentProductID = nil
        productId = 0
        self.currentProductIndex = -1
        
        self.productData.removeAll()
        self.currentPrice = 0.0
        
        self.isBiddingActive = false
        
        // reset UI triggers used for preview / sheets
        previewResetTrigger.toggle()
        showSheet = false
        winnerSheet = false
        showVerificationSheet = false
        maxBidAmountSheet = false
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
        self.sendBid(roomId: currentRoomID, bidAmount: newPrice.description, productId: currentProductID ?? "")
        //        placeBid(amount: newPrice)
    }
    
    
    func placeBid(amount: Double) {
        // Ensure we have the current room and product
        guard let currentRoomId = liveShowsData[safe: currentIndex]?.room_id else { return }
        
        self.sendBid(roomId: currentRoomId,
                     bidAmount: "\(amount)",
                     productId: currentProductID ?? "")
        
        // Update local price
        currentPrice = amount
        
      
        commentText = ""
    }
    
    
    func updateSoldStatus(){
        if let currentRoomId = liveShowsData[safe: currentIndex]?.room_id,
           let productId = productData.first?.id {
            
            FirebaseManager.shared.markProductAsSold(roomId: currentRoomId, productId: productId) { error in
                if let error = error {
                    print("❌ Failed to mark as sold: \(error.localizedDescription)")
                } else {
                    print("✅ Product marked as sold in Firebase.")
                    // Remove highestBid after marking sold
                    let highestBidRef = FirebaseManager.shared.databaseRef.child("live_sessions").child(currentRoomId).child("highestBid")
                    highestBidRef.removeValue { error, _ in
                        if let error = error {
                            print("❌ Failed to remove highestBid: \(error.localizedDescription)")
                        } else {
                            print("✅ highestBid removed successfully after sale.")
                        }
                    }
                    winnerSheet = true
                    refreshProductStatus(roomId: liveShowsData[currentIndex].room_id ?? "")
                }
            }
        }
    }
    
    
    func soldSuccess() {
        let response = self.viewModel.BidResponse
        if response.status == "success" {
            
        } else {
            print("⚠️ Bid failed — not marking as sold.")
        }
    }
    
    func refreshProductStatus(roomId: String) {
        
        FirebaseManager.shared.observeProductChanges(roomId: roomId) { updatedProducts in
            DispatchQueue.main.async {
                
                // 🔹 Reset isCurrent if sold
                let cleanedProducts = updatedProducts.map { product -> ProductData in
                    var mutable = product
                    if product.status?.lowercased() == "sold" {
                        mutable.isCurrent = false
                    }
                    return mutable
                }
                
                self.BiddingDetail.products = cleanedProducts
                let availableProducts = cleanedProducts.filter { $0.status?.lowercased() != "sold" }
                
                if let currentIndex = availableProducts.firstIndex(where: { $0.isCurrent }) {
                    var reordered = availableProducts
                    let currentProduct = reordered.remove(at: currentIndex)
                    reordered.insert(currentProduct, at: 0)
                    
                    self.productData = reordered
                    self.currentProductIndex = 0
                    
                    // Default to product base price
                    if let priceString = self.productData.first?.price,
                       let priceDouble = Double(priceString) {
                        self.currentPrice = priceDouble
                    }
                } else {
                    self.productData = availableProducts
                    self.currentProductIndex = 0
                }
            }
        }
        
        FirebaseManager.shared.observeHighestBid(roomId: roomId) { highestBid in
            DispatchQueue.main.async {
                guard let product = self.productData.first else { return }
                let basePrice = Double(product.price ?? "") ?? 0
                
                if let bidAmountString = highestBid["bidAmount"] as? String,
                   let bidAmountDouble = Double(bidAmountString),
                   bidAmountDouble > basePrice {
                    self.currentPrice = bidAmountDouble
                } else {
                    self.currentPrice = basePrice
                }
            }
        }
    }
    
    
    @ViewBuilder
    func sheetView(for action: MenuAction) -> some View {
        switch action {
        case .gift:
            Text("🎁 Gift Sheet")
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
    
    func followSuccess(){
        let response = viewModel.followDict
        if response.status == "success"{
            let status = response.data?.status ?? false
           
        }
        
    }
    
}


//MARK: MenuAction
enum MenuAction: CaseIterable {
    
    case gift, paperclip, share, wallet, cart
    
    var iconName: ImageResource {
        switch self {
        case .gift: return .gift
        case .paperclip: return .clip
        case .share: return .share
        case .wallet: return .wallet
        case .cart: return .shop
        }
    }
    
    var label: String {
        switch self {
        case .gift: return "Gift"
        case .paperclip: return "Attachment"
        case .share: return "Share"
        case .wallet: return "Wallet"
        case .cart: return "Cart"
        }
    }
}

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


struct ChatMessageBubble: View {
    let comment: CommentModel
    let isHost: Bool
    let isMod: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 6) {

            CustomProfileImage(
                url: comment.image ?? "",
                isCircular: true,
                size: 26
            )

            VStack(alignment: .leading, spacing: 4) {

                // Username + Badges
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

                // Bubble
                Text(comment.message ?? "")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(10)
            }
//            .frame(width:screenWidth - 45)
            Spacer()
        }
    }
}

extension LiveStream {
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
            
            let request = SellerReportRequest(seller_id: Int(liveShowsData[currentIndex].seller?.id ?? "0") ?? 0,
                                              category_id: cId,
                                              notes: msg)
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
    
    private func blockSeller(with sellerId: String) {
        Task{
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
    
    //MARK: blockSuccess.
    func blockSuccess(){
        SVProgressHUD.dismiss()
        let response = profileViewModel.blockUserResponseDict
        if response?.status == "success" {
            hudMsg = response?.message ?? ""
            showhudSuccess = true
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showErrorPopup = true }
        }
    }
    
    private func computeRoomId(senderId: String, receiverId: String) -> String {
        let sortedIds = [senderId, receiverId].sorted()
        return "\(sortedIds[0])_chats_\(sortedIds[1])"
    }
    
    private func prepareChatData() -> ChatModel {
        let currentUserId = "\(UserDefaults.userId)"
        let currentUserName = UserDefaults.fullName
        let currentUserImage = UserDefaults.profileURL
        let otherUserId =   liveShowsData[currentIndex].seller?.id ?? ""
        let otherUserName = liveShowsData[currentIndex].seller?.name ?? ""
        let otherUserImage = liveShowsData[currentIndex].seller?.image ?? ""
        return ChatModel(currentUserId: currentUserId,
                             currentUserName: currentUserName,
                             currentUserImage: currentUserImage,
                             otherUserId: otherUserId,
                             otherUserName: otherUserName,
                             otherUserImage: otherUserImage)
    }
}

extension LiveStream {
    
    private func followUnfollow() {
        guard !liveShowsData.isEmpty else  { return }
        guard let sellerId = liveShowsData[currentIndex].seller?.id, !sellerId.isEmpty else {
            print("⚠️ Seller ID not available")
            return
        }
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showHud = true
            return
        }
        Task{
            SVProgressHUD.show()
            await self.profileViewModel.followUnfollow(parameters: FollowRequest(following_id: sellerId))
            await SVProgressHUD.dismiss()
            followUnfollowSuccess()
        }
    }
    
    private func getProfileData() async {
        guard !liveShowsData.isEmpty else  { return }
        guard let sellerId = liveShowsData[currentIndex].seller?.id, !sellerId.isEmpty else {
            print("⚠️ Seller ID not available")
            return
        }
        SVProgressHUD.show()
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showHud = true
            return
        }
        await profileViewModel.getProfile(param: ProfileParamRequest(id: sellerId))
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
                    try? await Task.sleep(nanoseconds: 30 * 1_000_000_000)  // 30 sec
                    if !Task.isCancelled {
                        await MainActor.run {
                            if !isFollowing {
                                showFollowSheet = true
                            }
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
