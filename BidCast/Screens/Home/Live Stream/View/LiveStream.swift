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

struct CommentModel: Codable, Identifiable, Equatable {
    let id = UUID()
    let image: String
    let username: String
    let message: String
    let userId: String 
    let roomId: String

    enum CodingKeys: String, CodingKey {
        case image = "user_image"
        case username = "user_name"
        case message
        case userId = "user_id"
        case roomId = "room_id"
    }
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            image = try container.decode(String.self, forKey: .image)
            username = try container.decode(String.self, forKey: .username)
            message = try container.decode(String.self, forKey: .message)
            roomId = try container.decode(String.self, forKey: .roomId)

            // Handle userId as String or Int
            if let intId = try? container.decode(Int.self, forKey: .userId) {
                userId = String(intId)
            } else {
                userId = try container.decode(String.self, forKey: .userId)
            }
        }
}

struct LiveStream: View {
    @Binding var currentRoomID : String
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
    @State var BiddingDetail = BiddingModel()
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "Stream Ended", message: "The live stream has ended.", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
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
    @State var socket: SocketIOClient!
    @State var socketManager: SocketManager!
    @State var rooms: [RoomModel] = []
    @State var currentIndex : Int = 0
    @State var onRoomsUpdated: (([String]) -> Void)?
    
    @State var maxBidUserName: String = "Demo UserName"
    
    @State var hasHostEndedRoom: Bool = false
    
    var tabBarHeight: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 49
    }
    
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
            return MenuAction.allCases
        }
    }
    
    @State var showSheet: Bool = false
    @State var winnerSheet: Bool = false
    @State var walletPaymentSheet: Bool = false
    @State var maxBidAmountSheet : Bool = false
    @StateObject private var joinManager = SubscriberViewModel(renderer: MCAcceleratedVideoRenderer())
    @State private var renderer = MCAcceleratedVideoRenderer()
    @State var currentProductID: String? = nil
    
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
    
    @State var productData = [ProductData]()
    @State var currentProductIndex = 0
    
    @Binding var category : String
    @Binding var search : String
    @Binding var currentPage : Int
    var body: some View {
        GeometryReader { geometry in
            if liveShowsData.count != 0{
                ZStack(alignment: .top) {
                    if streamID.count != 0 {
                    MCVideoSwiftUIView(renderer: .accelerated(joinManager.renderer as! MCAcceleratedVideoRenderer),scalingMode: .resize,mirror: true)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                                   .ignoresSafeArea()
                                   .background(Color.black)
                        
                    }
                    VStack {
                        HStack(spacing: 12) {
                            Button(action:{
                                id = userId
                                navigateToProfile = true
                            }){
                                let data = liveShowsData[currentIndex]
                               
                                CustomProfileImage(url: data.seller?.image ?? "", isCircular: true,size: 50)
                                
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(liveShowsData[currentIndex].seller?.name ?? "")
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                        .foregroundColor(.white)
                                  
                                }
                            }
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.black)
                                Text("\(socketManagerChat.viewerCount)")
                                    .foregroundColor(.black)
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                            }
                            if isFollow{
                                Button(action: {
                                    Task{
                                        SVProgressHUD.show()
                                        await self.viewModel.followUnfollow(parameters: FollowRequest(following_id: userId))
                                        await SVProgressHUD.dismiss()
                                        followSuccess()
                                    }
                                }) {
                                    Text("Follow")
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.yellow)
                                        .cornerRadius(10)
                                }
                            }
                            Button(action: {
                                logoutRoom()
                               
                                
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(.cancel)
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.danger)
                                    .frame(width: 32,height: 32)
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 40)
                        
                        Spacer()
                        
                        //MARK: Side menu
                        
                        VStack(alignment: .leading, spacing: 12){
                            
                            //MARK: Comment section
                            if socketManagerChat.chats.count > 0 {
                                HStack{
                                    ScrollViewReader { scrollProxy in
                                        ScrollView(.vertical, showsIndicators: false) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                ForEach(socketManagerChat.chats) { comment in
                                                    HStack(alignment: .center, spacing: 6) {
                                                        CustomProfileImage(url: comment.image, isCircular: true,size: 24)
                                                        VStack(alignment: .leading) {
                                                            Text(comment.username.capitalizingFirstLetter())
                                                                .font(.custom(poppinsSemiBold, size: 14.0))
                                                            
                                                                .foregroundColor(.white)
                                                            Text(comment.message)
                                                                .font(.custom(poppinsRegular, size: 12.0))
                                                                .foregroundColor(.white)
                                                        }
                                                        Spacer()
                                                    }
                                                    .id(comment.id)
                                                }
                                            }
                                            .padding(.horizontal,8)
                                            .padding(.vertical,4)
                                        }
                                        .frame(width:screenWidth - 90,height: 150)
//                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                        .onChange(of: socketManagerChat.chats) { _ in
                                            withAnimation {
                                                if let lastID = socketManagerChat.chats.last?.id {
                                                    scrollProxy.scrollTo(lastID, anchor: .bottom)
                                                }
                                            }
                                        }
                                    }
                                    //
                                }
                                
                            }
                            //                        Spacer()
                            //MARK: Add Comment section
                            
                            HStack {
                                ZStack(alignment: .trailing) {
                                    TextField("", text: $commentText, prompt: Text("Say something...")
                                        .foregroundColor(.white)
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                    )
                                    .padding(.horizontal, 8)
                                    .padding(.trailing, commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 14 : 40)
                                    
                                    .frame(height: 50)
                                    .frame(width:screenWidth-90)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.custom(poppinsSemiBold, size: 13))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black.opacity(0.4))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    
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
                                            Image(systemName: "paperplane.fill")
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
                                //MARK: Product Details
                                let currentProducts = productData.filter { $0.isCurrent }
                                if let product = currentProducts.first {
                                    CurrentProductView(product: product,
                                                       currentPrice: $currentPrice,
                                                       bidTime: $socketManagerChat.bidTime,
                                                       userName: $maxBidUserName)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(10)
                                    
                                    //MARK: Swipe fearture
                                    HStack(spacing: 8) {
                                        
                                        // Max Button
                                        Text("Max")
                                            .font(.custom(poppinsBold, size: 13))
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 50)
                                            .background(Color.defaultTheme)
                                            .cornerRadius(10)
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
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.defaultTheme)
                                                .frame(height: 50)

                                            let nextBid = nextBidAmount(for: currentPrice)
                                            
                                            // Then use in Text
                                            Text("Swipe to Bid $\(String(format: "%.2f", nextBid))")
                                                .font(.custom(poppinsSemiBold, size: 14))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                            
                                            // Draggable Arrow
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.darkGreen)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Text(swipeConfirmed ? "$" : "$")
                                                        .foregroundColor(.black)
                                                        .font(.custom(poppinsExtraBold, size: 16))
                                                )
                                                .offset(x: min(dragOffset.width + 4, totalSwipeWidth - 90))
                                                .gesture(
                                                    DragGesture()
                                                        .onChanged { value in
                                                            if value.translation.width >= 0 {
                                                                dragOffset = value.translation
                                                            }
                                                        }
                                                        .onEnded { value in
                                                            if value.translation.width > totalSwipeWidth * 0.5 {
                                                                dragOffset = .zero
                                                                if UserDefaults.allowBidForAllUser{
                                                                    swipeConfirmed = true
                                                                    incrementPrice()
                                                                }else{
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
                                        .frame(height: 50)
                                        .frame(maxWidth: .infinity)
                                        
                                         //Price and Timer
                                        VStack(spacing: 2) {
                                            Text("$\(String(format: "%.2f", currentPrice))")
                                                .font(.custom(poppinsBold, size: 13))
                                                .foregroundColor(.white)
                                            
                                            Text(socketManagerChat.bidTime)
                                                .font(.custom(poppinsSemiBold, size: 13))
                                                .foregroundColor(.white)
                                        }
                                        .frame(width: 70, height: 50)
                                        .background(Color.black.opacity(0.3))
                                        .cornerRadius(10)
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
                                }
                            }
                            //.padding(.bottom,50)
                            .padding(.bottom, keyboardResponder.currentHeight == 0 ? (tabBarHeight + 20) : 10)
                        }
                    }
                    VStack(spacing: 20) {
                        //                            ForEach(MenuAction.allCases, id: \.self) { action in
                        ForEach(filteredActions, id: \.self) { action in
                            Button(action: {
                                if action == .cart {
                                    currentBottomSheet = action
                                    showSheet = true
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
                                Image(systemName: action.iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .fontWeight(.heavy)
                                    .font(.custom(poppinsExtraBold, size: 22.0))
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.white)
                            )
                        }
                    }
                    .position(
                        x: geometry.size.width - 40,
                        y: geometry.size.height / 2
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
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                    verticalDragOffset = .zero
//                                    ZegoExpressEngine.shared().stopPlayingStream(streamID[currentIndex])
//                                    currentStreamIndex += 1
//                                    loginRoom(roomId: liveShowsData[currentStreamIndex].room_id ?? "")
//                                    fetchBiddingDetail(roomId: liveShowsData[currentStreamIndex].room_id ?? "")
//                                }
                            } else if verticalAmount > swipeThreshold && currentIndex > 0 {
                                // Swipe Down
                                withAnimation(.easeInOut) {
                                    verticalDragOffset = CGSize(width: 0, height: geometry.size.height)
                                }
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                    verticalDragOffset = .zero
//                                    ZegoExpressEngine.shared().stopPlayingStream(streamID[currentStreamIndex])
//                                    currentStreamIndex -= 1
//                                    loginRoom(roomId: liveShowsData[currentStreamIndex].room_id ?? "")
//                                    fetchBiddingDetail(roomId: liveShowsData[currentStreamIndex].room_id ?? "")
//                                }
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
                CusNavLink(doNavigate: $navigateToShipping, destination: PaymentAndShipping_Screen())
                CusNavLink(doNavigate: $navigateToEditPayment, destination: PaymentAndShipping_Screen())
                CusNavLink(doNavigate: $navigateToEditAddress, destination: PaymentAndShipping_Screen())
            }
            
        }.gesture(
            TapGesture().onEnded { _ in
                hideKeyboard()
            }
        )
        
        .toast(isPresenting: $showHud,duration: 1.5) {
            AlertToast(displayMode: .alert, type: .regular, title: hudMsg ,style: .style(backgroundColor: .black.opacity(0.4), titleColor: .white))
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
        
        .bottomSheet(isPresented: $showVerificationSheet, height: screenHeight / 2.8, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
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
                    EmptyView()
                case .paperclip:
                    CreateClipBottomSheetView(
                        isPresented: $showSheet,
                        videoURL: URL(string: "https://example.com/video.mp4")!,
                        onCreateClip: { start, end in
                            print("Clip range: \(start.seconds) to \(end.seconds)")
                        }
                    )
                case .share:
                    ShareShowBottomSheetView(
                        isPresented: $showSheet,
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
                        productData : $productData
                    )
                case .none:
                    EmptyView()
                }
            }
        )
        
        .bottomSheet(isPresented: $winnerSheet,height: screenHeight * 0.32) {
            WinnerBottomSheet(
                winnerAmount: $winnerAmount, profileImage: $winnerProfileImage,
                username: $winnerName,
                winnerProfileID : $winnerProfileID,
                showParentToast: $showToast,
                parentToastMessage: $toastMessage,
                onDismiss: {
                    self.winnerSheet = false
                }
            )
        }
        
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
        .onAppear{
            //works as view did load
            UserDefaults.isLiveEnded = false
//            FirebaseManager.shared.removeNewSessionObserver()
//            ZIMChatManager.shared.login(userID: "\(UserDefaults.userId)", userName: UserDefaults.fullName)
           
            Task{
                SVProgressHUD.show()
               
                await self.homeViewModel.getProfile()
                await SVProgressHUD.dismiss()
                await getProfileSuccess()
//               try await joinManager.subscribe(streamName: currentRoomID)
                socketManagerChat.joinRoom(roomId: currentRoomID, completion: {
//                        guard let self = self else { return }
                        joinStreamUsingSocket(roomId: currentRoomID)
                    })
                    
                
            }
        }
        .onDisappear{
            logoutRoom()
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
    
    
    //MARK: walletInfosuccess.
    func getProfileSuccess() async{
        let response  = homeViewModel.accountInfo
        await SVProgressHUD.dismiss()
        if response.status == "success"{
            let response = self.homeViewModel.accountInfo.data
            UserDefaults.buyerVerafied = response?.buyer_identity_status ?? ""
            UserDefaults.sellerVerafied = response?.seller_identity_status ?? ""
            UserDefaults.sellerAddress = response?.has_shipping_address ?? false
            UserDefaults.hasCardAdded = response?.has_card_added ?? false
            
        }else{
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
    
    func startListening(roomId: String) {
        FirebaseManager.shared.observeCountdown(for: roomId) { seconds in
            DispatchQueue.main.async {
                self.countdown = seconds
                print("self.countdown \(self.countdown)")
            }
        }
    }
    @MainActor
    func joinStreamUsingSocket(roomId: String)  {
        let socketRooms = socketManagerChat.rooms
        guard !socketRooms.isEmpty else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: "No Active Streams",
                message: "There are no live streams available at the moment.",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            return
        }
        
        // Check if requested room exists in socket rooms
        guard let matchingRoomIndex = socketRooms.firstIndex(where: { $0.room_id == roomId }) else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: "Stream Not Found",
                message: "The requested stream is not available right now.",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            return
        }
        
        // Set the current room data
        DispatchQueue.main.async {
            self.liveShowsData = socketRooms
            self.roomID = socketRooms.compactMap { $0.room_id }
            self.streamID = self.roomID
            currentIndex = matchingRoomIndex
            self.currentRoomID = roomId
            print("currentStreamIndex \(currentStreamIndex) matchingRoomIndex index \(matchingRoomIndex)")
            // Join the room and send entry message
            Task {
                
                try await joinManager.subscribe(streamName: roomId)
                
//              socketManagerChat.joinRoom(roomId: roomId, userId: UserDefaults.userId)
                let userId = UserDefaults.userId
                let userName = UserDefaults.userName
                let userImage = UserDefaults.profileURL
                SocketManagerService.shared.sendChat(roomId: roomId, message: "Joining the host… ", userId: userId, userName: userName, userImage: userImage)
                socketManagerChat.listenForChat(roomId: roomId)
                socketManagerChat.listenForViewerCount()
                socketManagerChat.listenForBidTimer(roomId: roomId)
                socketManagerChat.listenForRoomEnded(onEnd: { room_Id in
                    if roomId == room_Id {
                        print("🔥 STREAM REMOVED CALLBACK TRIGGERED 🔥")
                        // Show "Stream Ended" alert
                        self.alertType = .sheetType(
                            icon: .alert,
                            title: "Stream Ended",
                            message: "The host has ended the live stream.",
                            primaryBtnText: AppString.ok.localized,
                            secondaryBtnText: ""
                        )
                        self.showError = true
                        self.hasHostEndedRoom = true
                    }
                })
                
                SocketManagerService.shared.listenForBidFinalized(completion: { roomId,productId,winner in
                    fetchProducts(for: roomId)
                    let winnerNameFromServer = winner?.user_name ?? ""
                    let winnerIdFromServer = winner?.user_id ?? ""
                    let winnerProfileImageFromServer = winner?.user_image ?? ""
                    print("id - > \(winnerIdFromServer)")
                    print("name - > \(winnerNameFromServer)")
                    print("image - > \(winnerProfileImageFromServer)")
                    
                    winnerName = winnerNameFromServer
                    winnerProfileID = Int(winnerIdFromServer) ?? 0
                    winnerProfileImage = winnerProfileImageFromServer
                    winnerAmount = winner?.bid_amount ?? ""
                    print("Winner: \(winnerName), Amount: \(winnerAmount)")
                    
                    winnerSheet = true
                })
                SocketManagerService.shared.listenForNextProduct(completion: { roomId,nextProductId in
                    
                    fetchProducts(for: roomId)
                   
                })
            }
            
            // Update follow status
            let currentShow = socketRooms[matchingRoomIndex]
            self.isFollow = currentShow.seller?.isFollowed ?? false
            fetchProducts(for: roomId)
            
            // Handle buyer verification
            switch UserDefaults.buyerVerafied {
            case "pending":
                self.alertType = .sheetType(
                    icon: .info,
                    title: "Become a Verified Buyer!",
                    message: "Your verification is currently pending approval by the admin. You will be notified once the process is complete.",
                    primaryBtnText: "OK",
                    secondaryBtnText: "",
                    buttonWidth: screenWidth - 40,
                    contentSize: 12.0
                )
                withAnimation(.snappy) { self.showVerificationSheet = true }
                
            case "verified":
                if UserDefaults.sellerAddress == false {
                    self.showPaymentShipping = true
                    self.titleText = "Add Address"
                } else if UserDefaults.hasCardAdded == false {
                    self.showPaymentShipping = true
                    self.titleText = "Add Card"
                }
                
            default:
                self.alertType = .sheetType(
                    icon: .info,
                    title: "Become a Verified Buyer!",
                    message: "Before you interact with live shows, you need to become a verified buyer.",
                    primaryBtnText: "OK",
                    secondaryBtnText: "",
                    buttonWidth: screenWidth - 40,
                    contentSize: 12.0
                )
                withAnimation(.snappy) { self.showVerificationSheet = true }
            }
        }
    }
    @MainActor
    func fetchProducts(for roomId: String) {
        guard let socketRoom = socketManagerChat.rooms.first(where: { $0.room_id == roomId }) else {
            self.productData = []
            self.currentProductIndex = 0
            self.currentPrice = 0.0
            return
        }
        
        if let products = socketRoom.products {
            let activeCurrentProducts = products.filter { product in
                let status = product.status?.lowercased() ?? ""
                return (status == "live" || status == "active") && product.isCurrent
            }
            
            if let currentProduct = activeCurrentProducts.first {
                self.productData = [currentProduct]
                self.currentProductIndex = 0
                self.currentProductID = currentProduct.id
                if let priceDouble = Double(currentProduct.price ?? "") {
                    self.currentPrice = priceDouble
                }
            } else {
                self.productData = []
                self.currentProductIndex = 0
                self.currentPrice = 0.0
            }
        } else {
            self.productData = []
            self.currentProductIndex = 0
            self.currentPrice = 0.0
        }
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
        let userId = UserDefaults.userId
        let userName = UserDefaults.userName
        let userImage = UserDefaults.profileURL
        SocketManagerService.shared.sendChat(roomId: roomId, message: commentText, userId: userId, userName: userName, userImage: userImage)
        commentText = ""
    }
    
    
    func loginRoom(roomId: String) {
        let user = ZegoUser(userID: "\(UserDefaults.userId)", userName: UserDefaults.fullName)
        let roomConfig = ZegoRoomConfig()
        roomConfig.isUserStatusNotify = true
        
        
        ZegoExpressEngine.shared().loginRoom(roomId, user: user, config: roomConfig) { errorCode, extendedData in
            if errorCode == 0 {
                print("✅ Login callback | room: \(roomId) | errorCode: \(errorCode)")
                currentRoomID = roomId
                
                ZIMChatManager.shared.joinRoom(roomID: roomId)
                ZIMChatManager.shared.onJOin = {
                    commentText = "Joined 👋"
                    ZIMChatManager.shared.sendMessage(message: commentText,roomId: roomId,image: UserDefaults.profileURL,name: UserDefaults.fullName)
                    commentText = ""
                }
                
                FirebaseManager.shared.observeViewerCount(roomId: roomId) { newCount in
                    print("👀 Viewer Count Updated: \(newCount)")
                    viewwerCount = newCount
                }
                FirebaseManager.shared.observeLiveSessionRemoval(roomId: roomId) {
                    logoutRoom()
                    let streamTitle = "Stream Ended"
                    let streamMessage = "The host has ended the live stream."
                    print("🔥 STREAM REMOVED CALLBACK TRIGGERED 🔥")
                    showVerificationSheet = false
                    alertType = .sheetType(
                        icon: .alert,
                        title: streamTitle,
                        message: streamMessage,
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText:""
                    )
                    showError = true
                }
                FirebaseManager.shared.observeCountdown(for: roomId) {  seconds in
                    self.countdown = seconds
                }
                
                FirebaseManager.shared.observeHighestBidChanges(roomId: roomId) { bidData in
                    if let bidData = bidData,
                       let roomKey = bidData.keys.first,
                       let roomDict = bidData[roomKey] as? [String: Any],
                       let highestBid = roomDict["highestBid"] as? [String: Any] {
                        print("bidData \(bidData)")
                        
                        
                        let winnerNameFromServer = highestBid["userName"] as? String
                           let winnerIdFromServer = highestBid["userId"] as? String
                           let winnerProfileImageFromServer = highestBid["userImage"] as? String
                        print("id - > \(winnerIdFromServer ?? "")")
                        print("name - > \(winnerNameFromServer ?? "")")
                        print("image - > \(winnerProfileImageFromServer ?? "")")
                        
                        winnerName = winnerNameFromServer ?? UserDefaults.fullName
                        winnerProfileID = Int(winnerIdFromServer ?? "") ?? 0
                           winnerProfileImage = winnerProfileImageFromServer ?? UserDefaults.profileURL
                        winnerAmount = highestBid["bidAmount"] as? String ?? ""
                        print("Winner: \(winnerName), Amount: \(winnerAmount)")
                        
                        //MARK: -  For Store bid in database
                        
                        //                        Task{
                        //                            let showId = self.liveShowsData[safe:currentStreamIndex]?.id ?? 0
                        //                            let param = StoreBidRequest(schedule_show_id: "\(showId)", user_id: "\(winnerProfileID)", product_id: productData.first?.id ?? "", bid_price: "\(winnerAmount)")
                        //                            await self.viewModel.storeBid(parameters: param)
                        //                        }
                        
                    } else {
                        print("Could not find highestBid in bidData")
                    }
                    updateSoldStatus()
                }
            } else {
                print("login fail error")
            }
        }
    }
    
//    func fetchBiddingDetail(roomId: String) {
//        FirebaseManager.shared.getLiveSessionData(roomId: roomId) { data in
//            guard let data = data else { return }
//            DispatchQueue.main.async {
//                if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
//                    do {
//                        let model = try JSONDecoder().decode(BiddingModel.self, from: jsonData)
//                        self.BiddingDetail = model
//                        
//                        // Filter products for active & isCurrent only
//                        let activeCurrentProducts = model.products?.filter { product in
//                            product.status?.lowercased() == "active" && product.isCurrent
//                        }
//                        
//                        if let currentProduct = activeCurrentProducts?.first {
//                            self.productData = [currentProduct]
//                            self.currentProductIndex = 0
//                            
//                            if let priceDouble = Double(currentProduct.price ?? "") {
//                                self.currentPrice = priceDouble
//                            }
//                        } else {
//                            self.productData = []
//                            self.currentProductIndex = 0
//                            self.currentPrice = 0.0
//                        }
//                    } catch {
//                        print("❌ Decoding Error: \(error)")
//                    }
//                }
//            }
//        }
//    }
    
    //MARK: logoutRoom
    func logoutRoom() {
        Task{
            try await joinManager.unsubscribe()
        }
        SocketManagerService.shared.chats.removeAll()
        SocketManagerService.shared.leaveRoom(roomId: self.currentRoomID, userId: UserDefaults.userId)
       
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
        
//        // Update Firebase highest bid
//        FirebaseManager.shared.updateHighestBid(
//            roomId: currentRoomId,
//            bidAmount: "\(amount)",
//            bidderId: "\(UserDefaults.userId)",
//            bidderName: UserDefaults.fullName,
//            bidderProfileImage: UserDefaults.profileURL
//        ) { finalBidData in
//            if let data = finalBidData {
//                
//                
//            }
//        }
        
        self.sendBid(roomId: currentRoomId,
                     bidAmount: "\(amount)",
                     productId: currentProductID ?? "")
        
        // Update local price
        currentPrice = amount
        
        commentText = "Current highest bid : $\(currentPrice)"
        let userId = UserDefaults.userId
        let userName = UserDefaults.userName
        let userImage = UserDefaults.profileURL
        SocketManagerService.shared.sendChat(roomId: currentRoomId,
                                             message: commentText,
                                             userId: userId,
                                             userName: userName,
                                             userImage: userImage)
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
            if status == true{
                isFollow = status
            }else{
                isFollow = status
            }
        }
        
    }

}


//MARK: MenuAction
enum MenuAction: CaseIterable {
    
    case gift, paperclip, share, wallet, cart
    
    var iconName: String {
        switch self {
        case .gift: return "gift"
        case .paperclip: return "paperclip"
        case .share: return "arrowshape.turn.up.right"
        case .wallet: return "wallet.pass"
        case .cart: return "cart"
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
