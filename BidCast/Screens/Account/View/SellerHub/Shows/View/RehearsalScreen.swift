//
//  RehearsalScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/06/25.
//

import SwiftUI
import Foundation
import ZegoExpressEngine
import SVProgressHUD
import MillicastSDK
import AlertToast

enum ProductShowType {
    case shop
    case nextProduct
    case viewOnly
}

struct RehearsalScreen: View {
    @EnvironmentObject  var appRootManager: AppRootManager
    @Binding var showUd: String
    var roomID: String = ""
    @State var streamId = ""
    var isLocal: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    @State var viewModel = ShowsViewModel()
    @StateObject var agoraViewModel = AgoraViewModel()
    
    @State var BiddingDetail = BiddingModel()
    @State var productData = [ProductData]()
    @Binding var productListData: [ProductDataModel]
    @State var comments: [CommentModel] = []
    @State  var  boosts = [BoostModel]()
    @State var sellers = [SellerUserModel]()
    
    @State private var bottomSheetHeight: CGFloat = screenHeight * 0.85
    
    @State var isLive: Bool = false
    @State var roomId = ""
    @State var isMicOn: Bool = true
    @State var isUsingFrontCamera: Bool = true
    @State private var showTopBadge: Bool = true
    @State private var showReadyModal: Bool = false
    @State private var showWelcomeDialog: Bool = false
    @State private var showPreLiveControls: Bool = false
    @State private var showLiveControls: Bool = false
    @State private var verifiedOnly = false
    @State private var currentBottomSheet: SideMenu?
    @State private var showSellSheet: Bool = false
    @State private var showProductSheet : Bool = false

    @State private var showPollSheet : Bool = false
    @State private var showButton: Bool = false
    
    @State private var initialSelectedProductId: String = ""
    
    @State private var commentText = ""
    
    @State var liveRoomId = ""
    
    @State private var previewResetTrigger = false
    
    @State private var showPollCard = false
    @State private var currentPollModel: PollModel?
    @State private var remainingTimer: Int?
    
    var currentProduct: ProductData? {
        productData.first { $0.isCurrent }
    }
    
    
    @State private var showStartTime: Date? = nil
    @State private var liveElapsedTime: String = "00:00:00"
    
    var tabBarHeight: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 49
    }
    
    @State var comeFromPrepare = false
    @State var comeForLive = false
    
    @State var showSellerSheet = false
    @State var showRaidSheet = false
    
    @State private var selectedSellers: Int?
    
    
    @State var navigateToSeller = false
    
    @State private var showLivePollScreen: Bool = false
    
    @State var hasWon = false
    
    @State var viewwerCount = 0
    @State private var bidCountdownSeconds = 30
    @State private var hasCountdownStarted = false
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "Stream Ended", message: "The live stream has ended.", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var showhud: Bool = false
    @State var showhudSuccess: Bool = false
    @State var hudMsg: String = ""
    @Binding var backToTabBar : Bool
    
    @State private var renderer = MCAcceleratedVideoRenderer()
    
    @StateObject private var agoraManager = AgoraManager(asHost: true)
    @State private var isHost = true
    
    
    
    @State var agoraToken: String = ""
    @State var uId: Int = 0
    @State var channelName: String = ""
    var sheetHeight: CGFloat {
        switch currentBottomSheet {
        case .more: return screenHeight * 0.7
        case .promote: return screenHeight * 0.7
        case .clip: return screenHeight * 0.6
        case .share: return screenHeight * 0.6 // Or screenHeight * 0.5
        case .shop: return screenHeight * 0.8
        case .endShow: return screenHeight * 0.3
        default: return screenHeight * 0.65
        }
    }
    @StateObject var socketManager = SocketManagerService.shared
    @Binding var showsData : HomeModel
    
    @State var winnerProfileImage : String = ""
    @State var winnerName : String = ""
    @State var winnerAmount : String = ""
    @State var winnerProfileID : Int = 0
    
    @State var categoryName: String = ""
    
    @State var currentPrice: Double = 1.0
    
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    @State var messageHeight: CGFloat = 40   // single message height
    let maxVisibleMessages = 3
    @State var sellerId = ""
    @State var showItemDetailSheet = false
    @State var productId: Int = 0
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                if let _ = agoraManager.remoteUserId {
                    VideoContainerView(uiView: agoraManager.remoteVideoView)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                        .background(Color.black)
                } else {
                    VideoContainerView(uiView: agoraManager.localVideoView)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                        .background(Color.black)
                }
                
                //                MCVideoSwiftUIView(renderer: .accelerated(castManager.renderer as! MCAcceleratedVideoRenderer),scalingMode: .resize,mirror: castManager.isFrontCamera)
                //                    .frame(width: geometry.size.width, height: geometry.size.height)
                //                    .ignoresSafeArea()
                //                    .background(Color.black)
                
                VStack {
                    HStack {
                        HStack(spacing: 8) {
                            CustomProfileImage(url: UserDefaults.profileURL,isCircular: true)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(UserDefaults.userName.capitalizingFirstLetter())
                                    .foregroundColor(.white)
                                    .font(.custom(poppinsSemiBold, size: 14.0))
                                
                                Text("Show Time \(socketManager.showTime)")
                                    .foregroundColor(.white)
                                    .font(.custom(poppinsRegular, size: 11.0))
                            }
                            
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.black)
                                Text("\(socketManager.viewerCount)")
                                    .foregroundColor(.black)
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                            }
                            Text(isLive ? "Live" : "Rehearsal")
                                .font(.custom(poppinsRegular, size: 12.0))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.defaultTheme)
                                .cornerRadius(4)
                                .foregroundColor(.white)
                            
                            
                            Button(action: {
                                if !isLive{
                                    self.presentationMode.wrappedValue.dismiss()
                                }else{
                                    self.showSellSheet = true
                                    currentBottomSheet = .endShow
                                }
                                //
                                
                            }) {
                                Image(.cancel)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.danger)
                                    .frame(width: 32,height: 32)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                }
                
                // 🔳 Ready Modal
                if showReadyModal {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 12) {
                        Text("Show Starts at 4:00 PM")
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("Ready to Begin?")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            showReadyModal = false
                            showWelcomeDialog = true
                        }) {
                            Text("Share Show")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.defaultTheme)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.95))
                    .cornerRadius(12)
                    .frame(width: 300)
                }
                
                // ✅ Welcome Dialog
                if showWelcomeDialog {
                    Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                        
                        Text("Welcome to your Auction")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("You may edit and begin your auction from here")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showWelcomeDialog = false
                            if UserDefaults.sellerVerafied == "verified"{
                                showButton = true
                                showPreLiveControls = true
                            }else{
                                alertType = .sheetType(
                                    icon: .info,
                                    title: "Become a Verified Seller!",
                                    message: "Before you interact with live shows.you need to become a verified seller.",
                                    primaryBtnText: "OK",
                                    secondaryBtnText: "",
                                    buttonWidth:screenWidth - 24,
                                    contentSize: 12.0
                                )
                                withAnimation(.snappy){
                                    showSellerSheet = true
                                }
                            }
                        }) {
                            Text("Ok")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.defaultTheme)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.95))
                    .cornerRadius(12)
                }
                // 🎛️ Dynamic Side Controls
                VStack {
                    Spacer()
                    VStack(spacing: 4) {
                        if showLiveControls {
                            SideButton(label: "More", icon: .more,action: .more)
                            SideButton(label: "Promote", icon: .rPromote ,action: .promote)
                            SideButton(label: "Clip", icon: .clip,action: .clip)
                            SideButton(label: "Share", icon: .sharee,action: .share)
                            SideButton(label: "Switch", icon: .camera,action: .switchView)
                            VStack {
                                if let product = currentProduct,
                                   let img = product.image {
                                    StackedImageView(imageURL: img, totalCount: productData.count) {
                                        print("productStackTapped")
                                        showSellSheet = true
                                    }
                                }
                            }
                        }
                        
                        if showPreLiveControls {
                            Spacer()
                            Button(action: {
                                isMicOn.toggle()
                                agoraManager.toggleAudioMute()
                            }) {
                                VStack {
                                    Image(systemName: isMicOn ? "mic.fill" : "mic.slash.fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .fontWeight(.heavy)
                                        .font(.custom(poppinsExtraBold, size: 22.0))
                                        .frame(width: 25, height: 24)
                                        .foregroundColor(.white)
                                    Text(isMicOn ? "Mic On" : "Mic Off")
                                        .font(.custom(poppinsRegular, size: 8.0))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                
                                
                            }
                            
                            Button(action: {
                                isUsingFrontCamera.toggle()
                                agoraManager.switchCamera()
                            }) {
                                VStack {
                                    Image(.camera)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .fontWeight(.heavy)
                                        .font(.custom(poppinsExtraBold, size: 22.0))
                                        .frame(width: 25, height: 24)
                                        .foregroundColor(.white)
                                    Text("Switch")
                                        .font(.custom(poppinsRegular, size: 8.0))
                                        .foregroundColor(.white)
                                }
                                .padding()
                               
                            }
                            ShopButton(action: .shop, count: "0")
                            Spacer()
                        }
                    }
                  
                    .position(
                        x: geometry.size.width - 40,
                        y: geometry.size.height / 2
                    )
                }.zIndex(2)
                
                // 💬 bottom Chat & Start Button
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    if socketManager.chats.count > 0 {
                        HStack{
                            ScrollViewReader { proxy in
                                ScrollView(.vertical, showsIndicators: false) {

                                    VStack {
                                        Spacer(minLength: 0)  // bottom alignment

                                        LazyVStack(alignment: .leading, spacing: 6) {

                                            ForEach(socketManager.chats) { comment in
//                                                let data = liveShowsData[currentIndex]
                                                let isHost = comment.userId == "\(UserDefaults.userId)"
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
                                    ,height: socketManager.chats.count == 0
                                        ? 0
                                        : min(CGFloat(socketManager.chats.count), CGFloat(maxVisibleMessages)) * messageHeight
                                )
                                .animation(.easeOut(duration: 0.2), value: socketManager.chats.count)
                                .onChange(of: socketManager.chats) { _ in
                                    if let lastID = socketManager.chats.last?.id {
                                        withAnimation(.easeOut(duration: 0.25)) {
                                            proxy.scrollTo(lastID, anchor: .bottom)
                                        }
                                    }
                                }
                            }

                        }
                        
                    }
                  
                    if showButton{
                        if showLiveControls{
                            VStack(alignment: .leading, spacing: 12){
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
                                                let roomId = self.roomId
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
                                .padding(.trailing, productData != nil ? 54 : 16)
                                
                                .animation(.easeOut(duration: 0.25), value: keyboardResponder.currentHeight)

                                VStack(alignment: .leading,spacing: 12) {
                                    
                                    if showPollCard {
                                        if let poll = currentPollModel {
                                            PollPreviewCardView(
                                                poll: poll,
                                                remainingTime: remainingTimer ?? 0,
                                                onPollCardTapped: {
                                                    print("PollCard clicked")
                                                    showLivePollScreen = true
                                                }
                                            )
                                            .preferredColorScheme(.dark)
                                            .padding()
                                        }
                                    }
                                    
                                    //MARK: Product Details
                                    let currentProducts = productData.filter { $0.isCurrent }
                                    if let product = currentProducts.first {
                                        
                                        CurrentProductView(product: product,
                                                           currentPrice: $currentPrice,
                                                           bidTime: $socketManager.bidTime,
                                                           userName: $winnerName,
                                                           userImage: $winnerProfileImage,
                                                           categoryName: $categoryName,
                                                           hasWon: socketManager.hasWon,onTap: {
                                            showItemDetailSheet = true
                                        })
                                        .frame(maxWidth: .infinity)
                                        
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(10)
                                        .padding(.horizontal,16)
                                        
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
                        if !isLive{
                            Button(action: {
                                if UserDefaults.sellerVerafied == "verified"{
                                    if !isLive{
                                        //                                        showProductSheet = true
                                        Task {
                                            //                                            if !castManager.isPublishing {
                                            
                                            showProductSheet = true
                                            //                                            self.isLive = true
                                            //                                            self.UpdateStatus(status : false)
                                            //                                            } else {
                                            //                                                try await castManager.unpublish()
                                            //                                            }
                                        }
                                    }
                                    //                                    self.UpdateStatus(status : false)
                                }else{
                                    showSellerSheet = true
                                }
                            }) {
                                Text("Start Show")
                                    .font(.custom(poppinsBold, size: 13.0))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.defaultTheme)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                    if comeFromPrepare && !comeForLive{
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Continue")
                                .font(.custom(poppinsBold, size: 13.0))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.defaultTheme)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }.zIndex(1)
                CusNavLink(doNavigate: $navigateToSeller, destination: SellerVerificationScreen())
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .toolbar(.hidden,for: .tabBar)
        .foregroundColor(.black)
        .bottomSheet(
            isPresented: $showProductSheet,
            height: screenHeight * 0.6,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                showProductSheet = false
            },
            content: {
                ShopBottomSheetView(
                    isPresented: $showProductSheet,
                    productData: $productData,
                    productShowType: .shop,
                    onLiveStreamStart: { selectedID in
                        guard Reachability.isConnectedToNetwork() else {
                            hudMsg = "No Internet Connection"
                            showhud = true
                            return
                        }
                        showProductSheet = false
                        print("product ID is :\(selectedID)")
                        print("Live Room ID is :\(self.roomId)")
                        UpdateStatus(status: false, selectedID: selectedID)
                    },
                    initialSelectedProductId: initialSelectedProductId
                )
            }
        )
        
        .bottomSheet(
            isPresented: $showPollSheet,
            height: bottomSheetHeight,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                showPollSheet = false
            },
            content: {
                CreatePollScreen(
                    isPresented: $showPollSheet,
                    onCreatePoll: { pollModel in
                        print(pollModel)
                        SocketManagerService.shared.createPoll(poll: pollModel)
                    },
                    roomId: self.roomId
                )
            }
        )
        
        .bottomSheet(
            isPresented: $showLivePollScreen,
            height: screenHeight * 0.8,
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                showLivePollScreen = false
            },
            content: {
                if let poll = currentPollModel {
                    LivePollHostView(poll: poll) { pollId, rooomId in
                        print("End Poll")
                        showPollCard = false
                        showLivePollScreen = false
                    }
                }
            }
        )
        
        
        .bottomSheet(
            isPresented: $showSellSheet,
            height: sheetHeight, // Adjust as needed
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                showSellSheet = false
            },
            content: {
                if isLive{
                    ShopBottomSheetView(
                        isPresented: $showSellSheet,
                        productData: $productData,
                        productShowType: .nextProduct,
                        onAddProduct: { selectedID in
                            showSellSheet = false
                            if !selectedID.isEmpty {
                                print("product ID is :\(selectedID)")
                                print("Live Room ID is :\(self.roomId)")
                                setProductAsCurrent(selectedID: selectedID)
                                fetchLatestProductList()
                            }
                        },
                        initialSelectedProductId: initialSelectedProductId
                    )
                    .onAppear {
                        fetchLatestProductList()
                    }
                }else{
                    ShopBottomSheetView(
                        isPresented: $showSellSheet,
                        productData: $productData,
                        productShowType: .shop
                    )
                }
            })
        
        
        .bottomSheet(
            isPresented: $showSellSheet,
            height: sheetHeight, // Adjust as needed
            topBarCornerRadius: 20,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                showSellSheet = false
            },
            content: {
                switch currentBottomSheet {
                case .more:
                    MoreOptionsScreen(
                        isPresented: $showSellSheet,
                        isVerifiedBuyersOn: $verifiedOnly,
                        isMicOn: $isMicOn,
                        onEndShow: {
                            print("End Show")
                            endShow()
                        },
                        onCloneItems: { print("Clone Items") },
                        onTipSettings: { print("Tip Settings") },
                        onMulticast: { print("Multicast") },
                        onAddCoupons: { print("Add Coupons") },
                        onRaid: {
                            print("Raid")
                            SellerScreen(
                                sellers: $sellers,
                                selectedSellerID: $selectedSellers,
                                onRaidCreated: { selectedSellers in
                                    // Handle the selected sellers when raid is created
                                    print("Raid created with sellers: \(String(describing: selectedSellers))")
                                    handleRaid(selectedSeller: selectedSellers)
                                },onCancel: {
                                    showRaidSheet = false
                                    selectedSellers = nil
                                }
                            )
                        },
                        onCreatePoll: {
                            print("Create Poll")
                            showPollSheet = true
                            showSellSheet = false
                        },
                        onZoomOut: {
                            print("Zoom Out")
                            var zoomFactor = agoraManager.zoomFactor
                            if zoomFactor > 1.0 {
                                zoomFactor -= 0.2
                            }
                            agoraManager.adjustZoom(with: zoomFactor)
                        },
                        onZoomIn: {
                            print("Zoom In")
                            var zoomFactor = agoraManager.zoomFactor
                            if zoomFactor < 2.0 {
                                zoomFactor += 0.2
                            }
                            agoraManager.adjustZoom(with: zoomFactor)
                        },
                        onMicToggle: {
                            isMicOn.toggle()
                            agoraManager.toggleAudioMute()
                            //                            castManager.toggleAudioMute()
                        },
                        onVerifiedBuyerToggle: { isOn in
                            let allowBidForAll = !isOn
                            if !roomId.isEmpty   {
                                //                                FirebaseManager.shared.databaseRef.child("live_sessions")
                                //                                    .child(liveRoomId)
                                //                                    .updateChildValues(["allowBidForAll": allowBidForAll])
                                socketManager.AllowBidForAll(roomId: roomId, allow_bid_for_all: allowBidForAll)
                                print("✅ allowBidForAll updated to \(allowBidForAll) for room: \(liveRoomId)")
                            }
                        }
                    )
                case .promote:
                    PromoteShowSheet(
                        boosts: $boosts,
                        onClose: { showSellSheet = false },
                        onBoostCardClick: { selectedBoost in
                            handleBoostClick(selectedBoost)
                        }
                    )
                case .clip:
                    CreateClipBottomSheetView(
                        isPresented: $showSellSheet,
                        videoURL: URL(string: "https://example.com/video.mp4")!,
                        onCreateClip: { start, end in
                            print("Clip range: \(start.seconds) to \(end.seconds)")
                        }
                    )
                case .share:
                    ShareShowBottomSheetView(
                        isPresented: $showSellSheet,
                        showTitle: "John's Live Show",
                        username: "johnsmith",
                        showImage: Image("icWatch"),
                        message: "Live auction starting in 5 minutes! Don’t miss out on exclusive items.",
                        onShare: { platform in
                            print("Shared to \(platform)")
                        },
                        onSavePDF: {
                            print("PDF Saved")
                        },
                        onShareEmail: {
                            print("Email sent")
                        }
                    )
                    //                          .presentationDetents([.height(500)])
                    .presentationDragIndicator(.visible)
                case .switchView:
                    EmptyView()
                case .shop:
                    EmptyView()
                case .endShow:
                    EndShowBottomSheetView(
                        isPresented: $showSellSheet,
                        onCreateRaid: {
                            print("Raid Created")
                            getLiveSeller()
                        },
                        onEndShow: {
                            //                            Task {
                            //                                            if !castManager.isPublishing {
                            //                                    try await castManager.publish()
                            //                                            } else {
                            //                                                try await castManager.unpublish()
                            //                                self.presentationMode.wrappedValue.dismiss()
                            //                                            }
                            //                            }
                            //                            Task {
                            //                                SVProgressHUD.show()
                            //                                let is_Live = "false"
                            //                                await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: is_Live))
                            //                                await SVProgressHUD.dismiss()
                            //                                success()
                            //                            }
                            self.endShow()
                            
                            self.isLive = false
                        }
                    )
                case .none:
                    EmptyView()
                }
                
            }
        )
        
        .bottomSheet(isPresented: $showRaidSheet, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showRaidSheet = false
        }) {
            SellerScreen(
                sellers: $sellers,
                selectedSellerID: $selectedSellers,
                onRaidCreated: { selectedSellers in
                    // Handle the selected sellers when raid is created
                    print("Raid created with sellers: \(String(describing: selectedSellers))")
                    handleRaid(selectedSeller: selectedSellers)
                },onCancel: {
                    showRaidSheet = false
                    selectedSellers = nil
                }
            )
        }
        .bottomSheet(isPresented: $showSellerSheet, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showSellerSheet = false
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation {
                        navigateToSeller = true
                        showSellerSheet = false
                        
                    }
                },
                onSecondaryClick: {
                    withAnimation {
                        showSellerSheet = false
                        
                    }
                }
            )
        }
        .bottomSheet(isPresented: $showItemDetailSheet, height: screenHeight * 0.65) {
            ProductDetailSheet(
                onDismiss : {
                    self.showItemDetailSheet = false
                    productId = 0
                },
                productID: $productId,showoption: false,showButton: false
                
            )
        }
        .toast(isPresenting: $showhudSuccess) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg)
        }
        .onAppear {
            
            logoutRoom()
            showTopBadge = true
            agoraManager.setupLocalVideo()
            //            Task {
            //                do {
            //                    try await castManager.startPreview()
            //                } catch {
            //                    print("erro \(error.localizedDescription)")
            //                }
            //            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if comeFromPrepare && !comeForLive{
                    showReadyModal = false
                }else{
                    showReadyModal = true
                }
            }
        }
        .onFirstAppear {
            
            //listen for follow status
            //            socketManager.listenForFollowUnfollowStatus()
            //            if socketManager.lastActionSuccess {
            //                hudMsg = "started following you"
            //                showhud = true
            //            }
            //            else {
            //                hudMsg = "unfollow you"
            //                showhud = true
            //            }
            //            if !comeFromPrepare && !comeForLive {
            let mappedProducts = productListData.map { productModel in
                ProductData(
                    category: productModel.category?.name ?? "Unknown",
                    id: String(productModel.id ?? 0),
                    image: productModel.images?.first ?? "",
                    name: productModel.title ?? "Unnamed",
                    price: productModel.pricing ?? "",
                    status: productModel.status ?? "inactive",
                    isCurrent: false,
                    quantity: productModel.quantity ?? ""
                )
            }
            productData.append(contentsOf: mappedProducts)
            categoryName = showsData.category?.name ?? ""
            
            //get agora token -> did not call it on preview screen
            fetchAgoraToken()
        }
        .onDisappear {
            Task {
                if agoraManager.isJoined {
                    self.endShow()
                }
            }
        }
    }
    
    func fetchLatestProductList(){
        
        print("DEBUG: fetchLatestProductList with roomId = \(self.roomId)")
        print("DEBUG: initialSelectedProductId= \(initialSelectedProductId)")
        initialSelectedProductId = productData.first(where: { $0.isCurrent })?.id ?? ""
        currentPrice = Double(productData.first(where: { $0.isCurrent })?.price ?? "") ?? 0.0
    }
    
    func setProductAsCurrent(selectedID : String){
        socketManager.setNextProduct(roomId: self.roomId, productId: selectedID)
    }
    
    private func handleBoostClick(_ boost: BoostModel) {
        print("🔥 User clicked boost: \(boost.title)")
        showSellSheet = false
        storePromoteShow(boost: boost)
    }
    
    func showData(from data: HomeModel, selectedID: String? = nil) {
        // STEP 1: Validate data first (main thread is fine)
        guard let userId = data.user_id, let showId = data.id else {
            showhudMessage("Invalid stream data — missing show ID or user ID.")
            return
        }
        
        // Prepare room ID (light operation)
        let roomId = "live_room_\(userId)_\(showId)"
        self.roomId = roomId
        print("🎬 Preparing live stream room: \(roomId)")
        
        // STEP 2: Build product list in background (to avoid blocking UI)
        DispatchQueue.global(qos: .userInitiated).async {
            let products = self.makeProductList(from: data.products, selectedID: selectedID)
            guard !products.isEmpty else {
                DispatchQueue.main.async {
                    self.showhudMessage("Unable to start streaming — product category is missing.")
                }
                return
            }
            
            // STEP 3: Join Agora Channel — runs best on background thread
            self.joinAgoraChannelIfNeeded()
            
            // STEP 4: Prepare seller data (light, can stay background)
            let seller = SellerModel(
                isFollowed: data.user?.is_followed ?? false,
                id: "\(data.user?.id ?? 0)",
                name: data.user?.name ?? "",
                rating: data.user?.rating ?? "",
                image: data.user?.profile_image ?? ""
            )
            
            // STEP 5: Send "Create Room" event — network I/O (background)
            self.sendCreateRoomEvent(
                showId: "\(showId)",
                roomId: roomId,
                products: products,
                seller: seller,
                thumbnail: data.thumbnail?.first ?? "",
                time: data.time ?? "",
                date: data.date ?? "",
                allowBidForAll: true,
                showTimer: ""
            )
            
            // STEP 6: Socket setup in background
            self.setupLiveSocketListeners(for: roomId)
            
            // STEP 7: Update UI & start scheduler on main thread
            DispatchQueue.main.async {
                SocketManagerService.shared.startLiveScheduler(roomId: roomId)
                self.isLive = true
                self.showLiveControls = true
                self.showPreLiveControls = false
                self.getPromoteShows()
            }
        }
    }
    
    
    private func makeProductList(from products: [ProductDataModel]?, selectedID: String?) -> [ProductData] {
        guard let products else { return [] }
        
        return products.compactMap { product in
            guard
                let id = product.id,
                let categoryId = product.category_id,
                let title = product.title,
                let price = product.pricing,
                let quantity = product.quantity
            else { return nil }
            
            return ProductData(
                category: "\(categoryId)",
                id: "\(id)",
                image: product.images?.first ?? "",
                name: title,
                price: price,
                status: "active",
                isCurrent: selectedID == "\(id)",
                quantity: quantity
            )
        }
    }
    
    private func joinAgoraChannelIfNeeded() {
        guard !agoraToken.isEmpty, !channelName.isEmpty else {
            print("⚠️ Missing Agora credentials — skipping join.")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            print("🎥 Joining Agora Channel: \(channelName)")
            agoraManager.joinChannel(asHost: true, channelName: channelName, token: agoraToken)
        }
    }
    
    private func setupLiveSocketListeners(for roomId: String) {
        print("🔌 Setting up socket listeners for \(roomId)")
        
        SocketManagerService.shared.observeRoomUpdates { newRoom in
            print("🏠 Room updated: \(newRoom.room_id ?? "unknown")")
            self.fetchProducts(for: roomId)
        }
        
        SocketManagerService.shared.observeBidCountdown(
            for: roomId,
            onUpdate: { seconds in
                self.bidCountdownSeconds = seconds
                print("🟡 Countdown: \(seconds)s")
            },
            onStart: {
                self.hasCountdownStarted = true
                print("🚀 Countdown started (30s left)")
            },
            onComplete: {
                print("⏰ Countdown ended, showing product sheet.")
                self.handleCountdownCompletion()
            }
        )
        
        SocketManagerService.shared.listenForNextProduct {roomId, _ in
            self.fetchProducts(for: roomId)
        }
        
        socketManager.listenForHighestBid(forRoom: roomId) { highestBid in
            self.updateHighestBid(bid: highestBid)
        }
        
        socketManager.listenForBidTimer(roomId: roomId)
        socketManager.listenForChat(roomId: roomId)
        socketManager.listenForViewerCount()
        socketManager.listenForShowTimer(roomId: roomId)
        socketManager.listenForBidFinalized()
        socketManager.observePollVoteUpdate { pollModel in
            print(pollModel)
            self.remainingTimer = timerStringToSeconds(pollModel.remainingTime)
            self.currentPollModel = pollModel
            showPollCard = true
        }
    }
    
    private func handleCountdownCompletion() {
        fetchProducts(for: roomId)
        currentBottomSheet = .shop
        showSellSheet = true
        fetchLatestProductList()
        hasCountdownStarted = false
    }
    
    
    private func updateHighestBid(bid: HighestBid?) {
        guard let bid = bid else { return }
        
        winnerName = bid.user_name ?? ""
        winnerProfileID = Int(bid.user_id ?? "") ?? 0
        winnerProfileImage = bid.user_image ?? ""
        winnerAmount = bid.bid_amount ?? ""
        currentPrice = Double(winnerAmount) ?? 0.0
        
        print("🏆 Highest Bid — \(winnerName): \(winnerAmount)")
    }
    
    
    private func showhudMessage(_ message: String) {
        hudMsg = message
        showhud = true
    }
    
    
    
    
    //    func ShowData(data:HomeModel ,selectedID : String? = nil) {
    //        let roomId = "live_room_\(data.user_id ?? 0)_\(data.id ?? 0)"
    //        self.roomId = roomId
    //        let product: [ProductData] = (data.products ?? []).compactMap { product in
    //            guard let id = product.id,
    //                  let categoryId = product.category_id,
    //                  let title = product.title,
    //                  let price = product.pricing,
    //                  let quantity = product.quantity
    //            else {
    //                return nil
    //            }
    //            return ProductData(
    //                category: "\(categoryId)",
    //                id: "\(id)",
    //                image: product.images?.first ?? "",
    //                name: title,
    //                price: price,
    //                status: /*product.status ??*/ "active",
    //                isCurrent: selectedID == "\(id)",
    //                quantity: quantity
    //            )
    //        }
    //        if product.count != 0{
    ////
    ////            Task{
    //                //live stream
    //
    ////                try await castManager.publish(streamName: self.roomId)
    ////            }
    //
    //            if agoraToken != "" && channelName != "" {
    //                agoraManager.joinChannel(asHost: true, channelName: channelName, token: agoraToken)
    //            }
    //
    //            let seller = SellerModel(isFollowed: data.user?.is_followed ?? false, id: "\(data.user?.id ?? 0 )", name: data.user?.name ?? "", rating: data.user?.rating ?? "",image: data.user?.profile_image ?? "")
    //
    //            sendCreateRoomEvent(
    //                showId: "\(data.id ?? 0)",
    //                roomId: self.roomId,
    //                products: product,
    //                seller: seller,
    //                thumbnail: data.thumbnail?.first ?? "",
    //                time: data.time ?? "",
    //                date: data.date ?? "",
    //                allowBidForAll: true,
    //                showTimer: ""
    //            )
    //
    //
    //            SocketManagerService.shared.observeRoomUpdates { newRoom in
    //                print("🏠 New room received:", newRoom.room_id ?? "unknown")
    //                fetchProducts(for: self.roomId)
    //            }
    //
    //
    //            SocketManagerService.shared.startLiveScheduler(roomId: self.roomId)
    //            isLive = true
    //            self.showLiveControls = true
    //            self.showPreLiveControls = false
    //            socketManager.listenForBidTimer(roomId: self.roomId)
    //            socketManager.listenForChat(roomId: self.roomId)
    //            socketManager.listenForViewerCount()
    //            socketManager.listenForShowTimer(roomId: self.roomId)
    //
    //
    //            SocketManagerService.shared.observeBidCountdown(
    //                for: self.roomId,
    //                onUpdate: { seconds in
    //                    print("🟡 Countdown update: \(seconds)s")
    //                    self.bidCountdownSeconds = seconds
    //                },
    //                onStart: {
    //                    print("🚀 Countdown started (30s left)")
    //                    self.hasCountdownStarted = true
    //                },
    //                onComplete: {
    //                    print("⏰ Countdown reached zero, showing sheet")
    //                    fetchProducts(for: self.roomId)
    //                    self.currentBottomSheet = .shop
    //                    self.showSellSheet = true
    //                    self.fetchLatestProductList()
    //                    self.hasCountdownStarted = false
    //                }
    //            )
    //
    //            SocketManagerService.shared.listenForNextProduct(completion: { roomId,nextProductId in
    //                fetchProducts(for: roomId)
    //            })
    //
    //            socketManager.listenForHighestBid(forRoom: self.roomId) { highestBid in
    //                if let bid = highestBid {
    //                    print("🏆 Updated bid in this room: \(bid.user_name ?? "") - \(bid.bid_amount ?? "")")
    //                    winnerName = bid.user_name ?? ""
    //                    winnerProfileID = Int(bid.user_id ?? "") ?? 0
    //                    winnerProfileImage = bid.user_image ?? ""
    //                    winnerAmount = bid.bid_amount  ?? ""
    //                    currentPrice = Double(winnerAmount) ?? 0.0
    //                }
    //            }
    //
    //
    //            socketManager.listenForBidFinalized()
    //
    //            //        if data.is_live == true {
    //            //            self.showStartTime = Date()
    //            //            startLiveTimer()
    //            //        }
    //            getPromoteShows()
    //        }else{
    //
    //            hudMsg = "Unable to start streaming as product category is missing"
    //            showhud = true
    //        }
    //    }
    
    @MainActor
    func fetchProducts(for roomId: String) {
        print("print PRoduct")
        guard let socketRoom = socketManager.rooms.first(where: { $0.room_id == roomId }) else {
            self.productData = []
            //            self.currentProductIndex = 0
            self.currentPrice = 0.0
            return
        }
        
        if let products = socketRoom.products {
            productData = products
            print("print PRoduct: \(products)")
            let currentProducts = productData.filter { $0.isCurrent }
            self.currentPrice = Double(currentProducts.first?.price ?? "") ?? 0.0
            self.productId = Int(currentProducts.first?.id ?? "") ?? 0
            print("after product \(productData)")
        }
    }
    
    func endShow1(){
        Task{
            //            try await castManager.unpublish()
            //            if agoraManager.isJoined {
            agoraManager.leaveChannel()
            //            }
            SocketManagerService.shared.endStreaming(roomId: self.roomId)
            SocketManagerService.shared.stopLiveScheduler()
            
            //clear chats and remove listener
            SocketManagerService.shared.removeChatListener()
            self.comments.removeAll()
            SocketManagerService.shared.chats.removeAll()
            //
            initialSelectedProductId = ""
            //            SocketManagerService.shared.reset(with: self.roomId)
            //
            //            self.comments.removeAll()
            //            SocketManagerService.shared.chats.removeAll()
            //
            //            initialSelectedProductId = ""
            //            self.productData = []
            //            self.currentPrice = 0.0
            //            isLive = false
            
            
            previewResetTrigger.toggle()
            self.showLiveControls = false
            self.showPreLiveControls = true
            if comeFromPrepare{
                backToTabBar = false
            }else{
                self.presentationMode.wrappedValue.dismiss()
            }
            
        }
        return
        
    }
    
    
    // Updated cleanup helpers inside RehearsalScreen
    func endShow(){
        Task{
            // stop RTC
            if agoraManager.isJoined {
                agoraManager.leaveChannel()
            }
            
            // notify socket server & stop scheduler
            SocketManagerService.shared.endStreaming(roomId: self.roomId)
            SocketManagerService.shared.stopLiveScheduler()
            
            // remove listeners & chats
            SocketManagerService.shared.removeChatListener()
            SocketManagerService.shared.chats.removeAll()
            self.comments.removeAll()
            
            // remove the room entry from manager so stale product state is not retained
            if let idx = SocketManagerService.shared.rooms.firstIndex(where: { $0.room_id == self.roomId }) {
                SocketManagerService.shared.rooms.remove(at: idx)
            }
            
            // call reset helper if available (keeps compatibility with existing commented call)
            // this method was used previously in this file as a comment; if implemented in the service it will do additional cleanup
            //            SocketManagerService.shared.reset(with: self.roomId)
            
            // local UI / model cleanup
            initialSelectedProductId = ""
            productData.removeAll()
            currentPrice = 0.0
            
            previewResetTrigger.toggle()
            self.showLiveControls = false
            self.showPreLiveControls = true
            
            
            // navigate / dismiss
            if comeFromPrepare {
                backToTabBar = false
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func logoutRoom() {
        // clear UI & socket state for a clean slate
        SocketManagerService.shared.chats.removeAll()
        self.comments.removeAll()
        showSellSheet = false
        self.isLive = false
        
        // remove room-specific data if present
        if !self.roomId.isEmpty {
            if let idx = SocketManagerService.shared.rooms.firstIndex(where: { $0.room_id == self.roomId }) {
                SocketManagerService.shared.rooms.remove(at: idx)
            }
            SocketManagerService.shared.reset(with: self.roomId)
        }
        
        self.productData.removeAll()
        self.currentPrice = 0.0
        initialSelectedProductId = ""
    }
    
    
    //this func is not calling
    func success(selectedID : String? = nil) {
        let response = viewModel.updateStatusRespone
        if response?.status == "success"{
            let data = response?.data ?? UpdateStatusModel()
            
            isLive = data.is_live ?? false
            
            let roomId = "live_room_\(data.user_id ?? 0)_\(data.id ?? 0)"
            self.roomId = roomId
            if data.is_live == false {
                Task{
                    //                    try await castManager.unpublish()
                    
                    self.comments.removeAll()
                    previewResetTrigger.toggle()
                    self.showLiveControls = false
                    self.showPreLiveControls = true
                    if comeFromPrepare{
                        backToTabBar = false
                    }else{
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                }
                return
            }
            //            Task{
            //                try await castManager.publish(streamName:  self.roomId)
            //            }
            //
            
            let product: [ProductData] = (data.products ?? []).compactMap { product in
                guard let id = product.id,
                      let categoryId = product.category_id,
                      let title = product.title,
                      let price = product.pricing,
                      let quantity = product.quantity
                else {
                    return nil
                }
                
                return ProductData(
                    category: "\(categoryId)",
                    id: "\(id)",
                    image: product.images?.first ?? "",
                    name: title,
                    price: price,
                    status: /*product.status ??*/ "active",
                    isCurrent: selectedID == "\(id)",
                    quantity: quantity
                )
            }
            
            
            let seller = SellerModel(isFollowed: data.user?.is_followed ?? false, id: "\(data.user?.id ?? 0 )", name: data.user?.name ?? "", rating: data.user?.rating ?? "")
            
            
            sendCreateRoomEvent(
                showId: "\(data.id ?? 0)",
                roomId: self.roomId,
                products: product,
                seller: seller,
                thumbnail: data.thumbnail?.first ?? "",
                time: data.time ?? "",
                date: data.date ?? "",
                allowBidForAll: true,
                showTimer: ""
            )
            
            
        }
    }
    
    func sendCreateRoomEvent(
        showId: String,
        roomId: String,
        products: [ProductData],
        seller: SellerModel,
        thumbnail: String,
        time: String,
        date: String,
        allowBidForAll: Bool,
        showTimer:String
    ) {
        
        let productPayload = products.map { product in
            [
                "category": product.category,
                "id": product.id,
                "image": product.image,
                "name": product.name,
                "price": product.price,
                "status": product.status,
                "is_current": product.isCurrent,
                "quantity": product.quantity
            ] as [String : Any]
        }
        
        let sellerPayload: [String: Any] = [
            "id": seller.id,
            "name": seller.name,
            "rating": seller.rating,
            "is_followed": seller.isFollowed
        ]
        let timestamp = getCurrentTimestamp()
        print("📅 Timestamp: \(timestamp)")
        
        let payload: [String: Any] = [
            "show_id": showId,
            "room_id": roomId,
            "products": productPayload,
            "seller": sellerPayload,
            "thumbnail": thumbnail,
            "time": timestamp,
            "date": date,
            "allow_bid_for_all": allowBidForAll,
            "viewer_count": "",
            "is_live": true,
            "show_detail": "Live auction room created via Rehearsal",
            "show_timer":showTimer
        ]
        
        SocketManagerService.shared.createRoom(payload: payload)
    }
    
    //MARK: Current Timestamp
    func getCurrentTimestamp() -> String {
        let now = Date()
        return String(Int(now.timeIntervalSince1970))
    }
    
    func UpdateStatus(status : Bool,selectedID : String? = nil){
        if status{
            updateLiveShowData()
        }else{
            Task {
                guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                var is_Live = "true"
                showData(from: showsData,selectedID: selectedID)
            }
        }
    }
    
    @ViewBuilder
    func SideButton(label: String, icon: ImageResource, action: SideMenu) -> some View {
        Button(action: {
            if action == .switchView {
                isUsingFrontCamera.toggle()
                //                ZegoExpressEngine.shared().useFrontCamera(isUsingFrontCamera)
                //                Task{
                //                    await castManager.switchCamera()
                //                }
                agoraManager.switchCamera()
            } else {
                currentBottomSheet = action
                showSellSheet = true
            }
        }) {
            VStack(spacing:4) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.heavy)
                    .font(.custom(poppinsExtraBold, size: 22.0))
                    .frame(width: 25, height: 24)
                    .foregroundColor(.white)
                Text(label)
                    .font(.custom(poppinsRegular, size: 8.0))
                    .foregroundColor(.white)
            }
            .padding(6)
            //            .background(
            //                Circle()
            //                    .fill(Color.white)
            //            )
        }
    }
    
    @ViewBuilder
    func ShopButton(action : SideMenu,count:String) -> some View {
        Button(action: {
            if action == .switchView {
                isUsingFrontCamera.toggle()
                //                castManager.switchCamera()
                agoraManager.switchCamera()
            } else {
                currentBottomSheet = action
                showSellSheet = true
            }
        }) {
            ZStack {
                VStack(spacing:4) {
                    Image(.shop)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.heavy)
                        .font(.custom(poppinsExtraBold, size: 22.0))
                        .frame(width: 25, height: 24)
                        .foregroundColor(.white)
                    Text("Shop")
                        .font(.custom(poppinsRegular, size: 8.0))
                        .foregroundColor(.white)
                    
                }
                .padding(6)
                //                .background(
                //                    Circle()
                //                        .fill(Color.white)
                //                )
                
//                Circle()
//                    .fill(Color.defaultTheme)
//                    .frame(width: 20, height: 20)
//                    .overlay(Text(count == "0" ? "" : count)
//                        .foregroundColor(.black)
//                        .font(.custom(poppinsRegular, size: 13.0))
//                    )
//                    .offset(x: 18, y: -15)
            }
        }
    }
}

enum SideMenu {
    case more, promote, clip, share, switchView, shop,endShow
}


struct VideoContainerView: UIViewRepresentable {
    let uiView: UIView
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .black
        
        // Add the Agora video view
        containerView.addSubview(uiView)
        uiView.frame = containerView.bounds
        uiView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
    
    // Add this to get the container view reference
    static func extractView(from uiView: UIView) -> UIView? {
        return uiView.subviews.first
    }
}


//API Call and their success handlers
extension RehearsalScreen {
    func isInternetAvailable()  -> Bool {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return false
        }
        return true
    }
    
    func fetchAgoraToken() {
        Task {
            if isInternetAvailable() {
                let data = showsData
                let channelName = "live_room_\(data.user_id ?? 0)_\(data.id ?? 0)"
                let uid = data.user?.id ?? 0
                self.channelName = channelName
                self.uId = uid
                print("channelName: \(channelName), uid: \(uid), token: \(agoraToken)")
                //            let request = AgoraTokenRequest(channelName: channelName, uid: self.uId)
                let param: [String: Any] = [
                    "channel": channelName
                    //                "uid": uid
                ]
                SVProgressHUD.show()
                await agoraViewModel.getAgoraToken(param: param)
                await SVProgressHUD.dismiss()
                successAgoraToken()
            }
        }
    }
    
    func storePromoteShow(boost: BoostModel) {
        guard let promoteId = boost.id,
              let showId = showsData.id else {
            hudMsg = "Either promoteId or ShowId not found."
            showhud = true
            return
        }
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
    
    func getPromoteShows() {
        Task{
            if isInternetAvailable() {
                self.viewModel.errorMessage?.removeAll()
//                SVProgressHUD.show()
                await self.viewModel.getPromoteShows()
//                await SVProgressHUD.dismiss()
                if let message = self.viewModel.errorMessage, message != "" {
                    hudMsg = self.viewModel.promoteShow?.message ?? ""
                    showhud = true
                }else{
                    self.successPromote()
                }
            }
        }
    }
    
    func updateLiveShowData() {
        Task {
            if isInternetAvailable() {
                let is_Live = "true"
                await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: is_Live))
            }
        }
       
    }
    
    func getLiveSeller() {
        Task {
            self.viewModel.errorMessage?.removeAll()
//            SVProgressHUD.show()
            await viewModel.getLiveSeller()
//            await SVProgressHUD.dismiss()
            if let message = self.viewModel.errorMessage, message != "" {
                hudMsg = self.viewModel.sellerResponse?.message ?? ""
                showhud = true
            }else{
                showRaidSheet = true
                successSeller()
            }
            
        }
    }
    
    func successAgoraToken() {
        let response  = self.agoraViewModel.getAgoraDict
        if response?.status == "success" {
            self.agoraToken = response?.data?.token ?? ""
            hudMsg = response?.message ?? ""
            showhudSuccess = true
            print("channelName: \(channelName), uid: \(uId), token: \(agoraToken)")
        } else {
            hudMsg = response?.message ?? ""
            showhud = true
        }
    }
    
    private func successPromoteShow() {
        let response = viewModel.storePromoteShowModel
        if response?.status == "success" {
            hudMsg = "show promoted successfully."
            showhudSuccess = true
        } else {
            hudMsg = response?.message ?? ""
            showhud = true
        }
    }
    
   
    func successPromote(){
        let response  = self.viewModel.promoteShow
        if response?.status == "success"{
            self.boosts = response?.data ?? [BoostModel]()
        }
    }
    
    func successSeller(){
        let response = viewModel.sellerResponse
        if response?.status == "success"{
            sellers = response?.data ?? [SellerUserModel]()
        }
    }
}

extension RehearsalScreen {
    func handleRaid(selectedSeller: SellerUserModel?) {
        guard let seller = selectedSeller else  {
            return
        }
        selectedSellers = nil
        //send raid
        SocketManagerService.shared.sendRaidEvent(sourceRoomId: self.roomId,
                                                  targetRoomId: seller.room_id ?? "",
                                                  sourceHostId: "\(showsData.user?.id ?? 0)" ,
                                                  targetHostId: "\(seller.id ?? 0)")
        
        //leave room
        endShow()
    }
}
