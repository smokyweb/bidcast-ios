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

struct RehearsalScreen: View {
    @EnvironmentObject  var appRootManager: AppRootManager
    @Binding var showUd: String
    var roomID: String = ""
    @State var streamId = ""
    var isLocal: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel = ShowsViewModel()
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
    @State private var showButton: Bool = false
    @State var BiddingDetail = BiddingModel()
    @State var productData = [ProductData]()
    @State private var initialSelectedProductId: String = ""
    @Binding var productListData: [ProductDataModel]
    @State private var commentText = ""
    @State var comments: [CommentModel] = []
    @State var liveRoomId = ""
    @State  var  boosts = [BoostModel]()
    @State private var previewResetTrigger = false
    
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
    @State var sellers = [SellerUserModel]()
    
    @State var navigateToSeller = false
    
    @State var hasWon = false
    
    @State var viewwerCount = 0
    @State private var bidCountdownSeconds = 30
    @State private var hasCountdownStarted = false
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "Stream Ended", message: "The live stream has ended.", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @Binding var backToTabBar : Bool
    
    //    @StateObject var castManager: PublisherViewModel
    //    @State var renderer = MCAcceleratedVideoRenderer()
    @StateObject private var castManager = PublisherViewModel(renderer: MCAcceleratedVideoRenderer())
    @State private var renderer = MCAcceleratedVideoRenderer()
    
    @StateObject private var agoraManager = AgoraManager()
    @State private var isHost = true
    
    
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
                    VStack(spacing: 0) {
                        if showLiveControls {
                            SideButton(label: "More", icon: .sMore,action: .more)
                            SideButton(label: "Promote", icon: .sPromote,action: .promote)
                            SideButton(label: "Clip", icon: .sClip,action: .clip)
                            SideButton(label: "Share", icon: .sShare,action: .share)
                            SideButton(label: "Switch", icon: .sSwitch,action: .switchView)
                            ShopButton(action: .shop, count: "\(productData.count)")
                        }
                        
                        if showPreLiveControls {
                            Spacer()
                            Button(action: {
                                isMicOn.toggle()
                                agoraManager.toggleAudioMute()
//                                castManager.toggleAudioMute()
                                //                                ZegoExpressEngine.shared().muteMicrophone(!isMicOn)
                            }) {
                                VStack {
                                    Image(systemName: isMicOn ? "mic.fill" : "mic.slash.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .fontWeight(.heavy)
                                        .font(.custom(poppinsExtraBold, size: 22.0))
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.black)
                                    //                                Text(isMicOn ? "Mic On" : "Mic Off")
                                    //                                    .font(.custom(poppinsThin, size: 12.0))
                                }
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                )
                                
                            }
                            
                            Button(action: {
                                isUsingFrontCamera.toggle()
                                //                                ZegoExpressEngine.shared().useFrontCamera(isUsingFrontCamera)
                                agoraManager.switchCamera()
//                                Task{
//                                    await castManager.switchCamera()
//                                }
                            }) {
                                VStack {
                                    Image(.sSwitch)
                                        .resizable()
                                        .scaledToFit()
                                        .fontWeight(.heavy)
                                        .font(.custom(poppinsExtraBold, size: 22.0))
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.black)
                                    //                                Text("Switch")
                                    //                                    .font(.custom(poppinsThin, size: 12.0))
                                }
                                .padding()
//                                .background(
//                                    Circle()
//                                        .fill(Color.white)
//                                )
                            }
                            
                            ShopButton(action: .shop, count: "0")
                            Spacer()
                        }
                    }
                    //                    .padding(.trailing)
                    //                    .padding(.bottom, 150)
                    //                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .position(
                        x: geometry.size.width - 40,
                        y: geometry.size.height / 2
                    )
                }
                
                // 💬 bottom Chat & Start Button
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    if socketManager.chats.count > 0{
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(socketManager.chats) { comment in
                                        HStack {
                                            CustomProfileImage(url: comment.image, isCircular: true,size: 24)
                                            Text(comment.username.capitalizingFirstLetter())
                                                .font(.custom(poppinsSemiBold, size: 14.0))
                                                .foregroundColor(.white)
                                            
                                            Text(comment.message)
                                                .font(.custom(poppinsRegular, size: 12.0))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.trailing,60)
                                        .padding(.leading,Leading)
                                        .id(comment.id) // 💡 For scroll targeting
                                    }
                                }
                            }
                            .onChange(of: socketManager.chats) { _ in
                                // 💬 Auto scroll to last message
                                if let last = socketManager.chats.last {
                                    withAnimation {
                                        proxy.scrollTo(last.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                    
                    
                    if showButton{
                        if showLiveControls{
                            VStack(alignment: .leading, spacing: 12){
                                HStack {
                                    ZStack(alignment: .trailing) {
                                        TextField("", text: $commentText, prompt: Text("Say something...")
                                            .foregroundColor(.white)
                                            .font(.custom(poppinsSemiBold, size: 13.0))
                                        )
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.trailing, commentText.isEmpty ? 14 : 36) // extra space for send button
                                        .frame(height: 50)
                                        
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.white, lineWidth: 1)
                                            
                                            
                                        )
                                        .background(.black.opacity(0.4))
                                        
                                        if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            Button(action: {
                                                print("📨 Sending message: \(commentText)")
                                                let textToSend = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                                                //                                            ZIMChatManager.shared.sendMessage(message: textToSend,roomId: self.liveRoomId,image: UserDefaults.profileURL,name: UserDefaults.userName)
                                                
                                                let userId = UserDefaults.userId
                                                let userName = UserDefaults.userName
                                                let userImage = UserDefaults.profileURL
                                                SocketManagerService.shared.sendChat(roomId: self.roomId, message: textToSend, userId: userId, userName: userName, userImage: userImage)
                                                commentText = ""
                                            }) {
                                                Image(systemName: "paperplane.fill")
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                                    .foregroundColor(.defaultTheme)
                                                    .padding(10)
                                            }
                                            .transition(.opacity)
                                            .animation(.easeInOut(duration: 0.2), value: commentText)
                                            .padding(.leading,16)
//                                            .padding(.trailing, BiddingDetail.products != nil ? 54 : 16)
                                        }
                                    }
                                }
                                .padding(.leading,12)
                                .padding(.trailing, productData != nil ? 70 : 12)
                                .padding(.bottom,20)
                                VStack(alignment: .leading,spacing: 12) {
                                    //MARK: Product Details
                                    let currentProducts = productData.filter { $0.isCurrent }
                                    if let product = currentProducts.first {
                                        
                                        CurrentProductView(product: product,
                                                           currentPrice: $currentPrice,
                                                           bidTime: $socketManager.bidTime,
                                                           userName: $winnerName, userImage: $winnerProfileImage,
                                                           categoryName: $categoryName,
                                                           hasWon: socketManager.hasWon
                                                          
                                        )
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
                }
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
                    NavFrom: "Rehearsal",
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
                        onEndShow: { print("End Show") },
                        onCloneItems: { print("Clone Items") },
                        onTipSettings: { print("Tip Settings") },
                        onMulticast: { print("Multicast") },
                        onAddCoupons: { print("Add Coupons") },
                        onRaid: { print("Raid") },
                        onCreatePoll: { print("Create Poll") },
                        onRotateCamera: {
                            isUsingFrontCamera.toggle()
                            agoraManager.switchCamera()
//                            Task{
//                                await castManager.switchCamera()
                                
//                            }
                        },
                        onZoomIn: { print("Zoom In") },
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
                    //                    ShopBottomSheetView(
                    //                        isPresented: $showSellSheet,
                    //                        userId : .constant("\(UserDefaults.userId)")
                    //
                    //                    )
                    
                    if isLive{
                        ShopBottomSheetView(
                            isPresented: $showSellSheet,
                            productData: $productData,
                            NavFrom: "",
                            onAddProduct: { selectedID in
                                showSellSheet = false
                                if !selectedID.isEmpty {
                                    print("product ID is :\(selectedID)")
                                    print("Live Room ID is :\(self.roomId)")
                                    setProductAsCurrent(selectedID: selectedID)
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
                            NavFrom: "Shop"
                        )
                    }
                    
                case .endShow:
                    EndShowBottomSheetView(
                        isPresented: $showSellSheet,
                        onCreateRaid: {
                            print("Raid Created")
                            showRaidSheet = true
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
        
        .bottomSheet(isPresented: $showRaidSheet, height: screenHeight / 1.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showRaidSheet = false
        }) {
            SellerScreen(
                sellers: $sellers,
                selectedSellerID: $selectedSellers,
                onRaidCreated: { selectedSellers in
                    // Handle the selected sellers when raid is created
                    print("Raid created with sellers: \(String(describing: selectedSellers))")
                    SocketManagerService.shared.sendRaidEvent(sourceRoomId: self.roomId, targetRoomId: selectedSellers?.room_id ?? "", sourceHostId: "\(showsData.user?.id ?? 0)" ,targetHostId: "\(selectedSellers?.id ?? 0)")
                },onCancel: {
                    showRaidSheet = false
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
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .onAppear {
            logoutRoom()
            showTopBadge = true
            agoraManager.joinChannel(asHost: isHost)
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
        }
        .onDisappear {
            Task {
                if castManager.isPublishing {
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
        guard let promoteId = boost.id,
              let showId = showsData.id else {
            hudMsg = "Either promoteId or ShowId not found."
            showhud = true
            return
        }
        Task {
            SVProgressHUD.show()
            let request = StorePromoteShowRequest(scheduleShowId: "\(showId)", promoteShowId: "\(promoteId)")
            await viewModel.storePromoteShow(parameters: request)
            await SVProgressHUD.dismiss()
            successPromoteShow()
        }
    }
    
    private func successPromoteShow() {
        let response = viewModel.storePromoteShowModel
        if response?.status == "success" {
            hudMsg = "show promoted successfully."
            showhud = true
        } else {
            hudMsg = response?.message ?? ""
            showhud = true
        }
    }
    
    
    func ShowData(data:HomeModel ,selectedID : String? = nil) {
        let roomId = "live_room_\(data.user_id ?? 0)_\(data.id ?? 0)"
        self.roomId = roomId
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
        if product.count != 0{
            Task{
                //live stream
                try await castManager.publish(streamName: self.roomId)
            }
            
            let seller = SellerModel(isFollowed: data.user?.is_followed ?? false, id: "\(data.user?.id ?? 0 )", name: data.user?.name ?? "", rating: data.user?.rating ?? "",image: data.user?.profile_image ?? "")
            
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
            
            
            SocketManagerService.shared.observeRoomUpdates { newRoom in
                print("🏠 New room received:", newRoom.room_id ?? "unknown")
                fetchProducts(for: self.roomId)
            }
            
            SocketManagerService.shared.startLiveScheduler(roomId: self.roomId)
            isLive = true
            self.showLiveControls = true
            self.showPreLiveControls = false
            socketManager.listenForBidTimer(roomId: self.roomId)
            socketManager.listenForChat(roomId: self.roomId)
            socketManager.listenForViewerCount()
            socketManager.listenForShowTimer(roomId: self.roomId)
            
            
            SocketManagerService.shared.observeBidCountdown(
                for: self.roomId,
                onUpdate: { seconds in
                    print("🟡 Countdown update: \(seconds)s")
                    self.bidCountdownSeconds = seconds
                },
                onStart: {
                    print("🚀 Countdown started (30s left)")
                    self.hasCountdownStarted = true
                },
                onComplete: {
                    print("⏰ Countdown reached zero, showing sheet")
                    fetchProducts(for: self.roomId)
                    self.currentBottomSheet = .shop
                    self.fetchLatestProductList()
                    self.showSellSheet = true
                    self.hasCountdownStarted = false
                }
            )
            
            socketManager.listenForHighestBid(forRoom: self.roomId) { highestBid in
                if let bid = highestBid {
                    print("🏆 Updated bid in this room: \(bid.user_name ?? "") - \(bid.bid_amount ?? "")")
                    winnerName = bid.user_name ?? ""
                    winnerProfileID = Int(bid.user_id ?? "") ?? 0
                    winnerProfileImage = bid.user_image ?? ""
                    winnerAmount = bid.bid_amount  ?? ""
                    currentPrice = Double(winnerAmount) ?? 0.0
                }
            }
            
            
            socketManager.listenForBidFinalized()
            
            //        if data.is_live == true {
            //            self.showStartTime = Date()
            //            startLiveTimer()
            //        }
            Task{
                self.viewModel.errorMessage?.removeAll()
                await self.viewModel.getPromoteShows()
                if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil {
                    self.successPromote()
                }else{
                    
                }
            }
        }else{
           
            hudMsg = "Unable to start streaming as product category is missing"
            showhud = true
        }
    }
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
            let currentProducts = productData.filter { $0.isCurrent }
            self.currentPrice = Double(currentProducts.first?.price ?? "") ?? 0.0
            print("after product \(productData)")
        }
    }
    
    func successPromote(){
        let response  = self.viewModel.promoteShow
        if response?.status == "success"{
            self.boosts = response?.data ?? [BoostModel]()
            Task {
                self.viewModel.errorMessage?.removeAll()
                await viewModel.getLiveSeller()
                if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                    successSeller()
                }else{
                    
                }
                
            }
        }
    }
    func successSeller(){
        let response = viewModel.sellerResponse
        if response?.status == "success"{
            sellers = response?.data ?? [SellerUserModel]()
        }
    }
    
    func endShow(){
        
        Task{
//            try await castManager.unpublish()
            if agoraManager.isJoined {
                agoraManager.leaveChannel()
            }
            SocketManagerService.shared.endStreaming(roomId: self.roomId)
            SocketManagerService.shared.stopLiveScheduler()
            self.comments.removeAll()
            SocketManagerService.shared.chats.removeAll()
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
            
            Task{
                try await castManager.publish(streamName:  self.roomId)
            }
            
            
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
            Task {
                guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                let is_Live = "true"
                await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: is_Live))
            }
        }else{
            Task {
                guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                //                SVProgressHUD.show()
                var is_Live = "true"
                ShowData(data: showsData,selectedID: selectedID)
                //                await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: is_Live))
                //                await SVProgressHUD.dismiss()
                //                // ✅ Only call success if we have a valid product ID
                //                if let validID = selectedID, !validID.isEmpty {
                //                    success(selectedID: validID)
                //                } else {
                //                    print("⚠️ Skipping success(): selectedID is nil or empty")
                //                }
            }
        }
    }
    
 
    func logoutRoom() {
        SocketManagerService.shared.chats.removeAll()
        showSellSheet = false
        self.isLive = false
        FirebaseManager.shared.stopObserving()
        self.productData.removeAll()
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
            VStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.heavy)
                    .font(.custom(poppinsExtraBold, size: 22.0))
                    .frame(width: 49, height: 50)
                    .foregroundColor(.black)
                //                Text(label)
                //                    .font(.custom(poppinsThin, size: 12.0))
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
                VStack {
                    Image(.sShop)
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.heavy)
                        .font(.custom(poppinsExtraBold, size: 22.0))
                        .frame(width: 49, height: 50)
                        .foregroundColor(.black)
                    //                    Text("Shop")
                    //                        .font(.custom(poppinsThin, size: 12.0))
                }
                .padding(6)
//                .background(
//                    Circle()
//                        .fill(Color.white)
//                )
                
                Circle()
                    .fill(Color.defaultTheme)
                    .frame(width: 20, height: 20)
                    .overlay(Text(count == "0" ? "" : count)
                        .foregroundColor(.black)
                        .font(.custom(poppinsRegular, size: 13.0))
                    )
                    .offset(x: 18, y: -15)
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
        uiView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
