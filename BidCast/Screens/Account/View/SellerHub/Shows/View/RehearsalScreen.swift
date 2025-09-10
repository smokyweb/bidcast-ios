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

struct RehearsalScreen: View {
    @Binding var showUd: String
    var roomID: String = ""
    @State var streamId = ""
    var isLocal: Bool = true
    @Environment(\.presentationMode) var presentaionMode
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
    @State var comments: [Comment] = []
    @State var liveRoomId = ""
    
    @State private var previewResetTrigger = false
    
    @State private var showStartTime: Date? = nil
    @State private var liveElapsedTime: String = "00:00:00"
    
    @ObservedObject var chatManager = ZIMChatManager.shared
    
    @State var comeFromPrepare = false
    @State var comeForLive = false
    
    @State var showSellerSheet = false
    @State var navigateToSeller = false
    
    @State var viewwerCount = 0
    @State private var bidCountdownSeconds = 30
    @State private var hasCountdownStarted = false
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "Stream Ended", message: "The live stream has ended.", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
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
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZegoRehearsalScreen(isLive: $isLive, streamID: roomId)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .id(previewResetTrigger)
                
                VStack {
                    HStack {
                        HStack(spacing: 8) {
                            CustomProfileImage(url: UserDefaults.profileURL,isCircular: true)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(UserDefaults.userName.capitalizingFirstLetter())
                                    .foregroundColor(.white)
                                    .font(.custom(poppinsSemiBold, size: 14.0))
                                
                                Text("Show Time \(liveElapsedTime)")
                                    .foregroundColor(.white)
                                    .font(.custom(poppinsRegular, size: 11.0))
                            }
                            
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.black)
                                Text("\(viewwerCount)")
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
                                    self.presentaionMode.wrappedValue.dismiss()
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
                    VStack(spacing: 20) {
                        if showLiveControls {
                            SideButton(label: "More", icon: "ellipsis.circle",action: .more)
                            SideButton(label: "Promote", icon: "megaphone.fill",action: .promote)
                            SideButton(label: "Clip", icon: "scissors",action: .clip)
                            SideButton(label: "Share", icon: "square.and.arrow.up",action: .share)
                            SideButton(label: "Switch", icon: "arrow.left.arrow.right",action: .switchView)
                            ShopButton(action: .shop)
                        }
                        
                        if showPreLiveControls {
                            Spacer()
                            Button(action: {
                                isMicOn.toggle()
                                ZegoExpressEngine.shared().muteMicrophone(!isMicOn)
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
                                ZegoExpressEngine.shared().useFrontCamera(isUsingFrontCamera)
                            }) {
                                VStack {
                                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                                        .resizable()
                                        .scaledToFit()
                                        .fontWeight(.heavy)
                                        .font(.custom(poppinsExtraBold, size: 22.0))
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.black)
                                    //                                Text("Switch")
                                    //                                    .font(.custom(poppinsThin, size: 12.0))
                                }
                                .padding()
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                )
                            }
                            
                            ShopButton(action: .shop)
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
                
                // 💬 Bottom Chat & Start Button
                
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    if chatManager.messages.count > 0{
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(chatManager.messages) { comment in
                                        HStack {
                                            CustomProfileImage(url: comment.image, isCircular: true,size: 24)
                                            Text(comment.username.capitalizingFirstLetter())
                                                .font(.custom(poppinsSemiBold, size: 14.0))
                                                .foregroundColor(.white)
                                            
                                            Text(comment.message)
                                                .font(.custom(poppinsRegular, size: 12.0))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.trailing,40)
                                        .padding(.leading,Leading)
                                        .id(comment.id) // 💡 For scroll targeting
                                    }
                                }
                            }
                            .onChange(of: chatManager.messages) { _ in
                                // 💬 Auto scroll to last message
                                if let last = chatManager.messages.last {
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
                                            ZIMChatManager.shared.sendMessage(message: textToSend,roomId: self.liveRoomId,image: UserDefaults.profileURL,name: UserDefaults.userName)
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
                                    }
                                }
                            }
                            .padding(.horizontal,8)
                            .padding(.bottom,20)
                        }
                        if !isLive{
                            Button(action: {
                                if UserDefaults.sellerVerafied == "verified"{
                                    if !isLive{
                                        showProductSheet = true
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
                            self.presentaionMode.wrappedValue.dismiss()
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
                        print("Live Room ID is :\(liveRoomId)")
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
                            ZegoExpressEngine.shared().useFrontCamera(isUsingFrontCamera)
                        },
                        onZoomIn: { print("Zoom In") },
                        onMicToggle: {
                            isMicOn.toggle()
                            ZegoExpressEngine.shared().muteMicrophone(!isMicOn)
                        },
                        onVerifiedBuyerToggle: { isOn in
                            let allowBidForAll = !isOn
                            if !liveRoomId.isEmpty {
                                FirebaseManager.shared.databaseRef.child("live_sessions")
                                    .child(liveRoomId)
                                    .updateChildValues(["allowBidForAll": allowBidForAll])
                                print("✅ allowBidForAll updated to \(allowBidForAll) for room: \(liveRoomId)")
                            }
                        }
                    )
                case .promote:
                    PromoteShowSheet(boosts: exampleBoosts) {
                        showSellSheet = false
                    }
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
                                    print("Live Room ID is :\(liveRoomId)")
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
                        },
                        onEndShow: {
                            Task {
                                SVProgressHUD.show()
                                let is_Live = "false"
                                await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: is_Live))
                                await SVProgressHUD.dismiss()
                                success()
                            }
                            
                            
                            self.isLive = false
                        }
                    )
                case .none:
                    EmptyView()
                }
                
            }
        )
        
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
        
        .onAppear {
            logoutRoom()
            showTopBadge = true
            
            ZIMChatManager.shared.login(userID: "\(UserDefaults.userId)", userName: UserDefaults.userName)
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
                        price: String(format: "%.2f", productModel.pricing ?? 0),
                        status: productModel.status ?? "inactive",
                        isCurrent: false
                    )
                }
                productData.append(contentsOf: mappedProducts)
//            }
        }
        .onDisappear {
            logoutRoom()
        }
    }
    
    func fetchLatestProductList(){
        FirebaseManager.shared.listenToLiveProducts(roomId: liveRoomId) { products in
            self.productData = products
            print("DEBUG: fetchLatestProductList with roomId = \(liveRoomId)")
            print("DEBUG: initialSelectedProductId= \(initialSelectedProductId)")
            initialSelectedProductId = products.first(where: { $0.isCurrent })?.id ?? ""
        }
    }
    
    func setProductAsCurrent(selectedID : String){
        FirebaseManager.shared.setProductAsCurrent(roomId: liveRoomId, selectedID: selectedID) { result in
            switch result {
            case .success():
                hudMsg = "Product is now ready for bidding."
                showhud = true
                print("✅ Product is now ready for bidding.")
                
            case .failure(.alreadyCurrent):
                hudMsg = "Your product is already live for bidding."
                showhud = true
                print("⚠️ Already current product.")
                
            case .failure(.productNotFound):
                hudMsg = "Product not available"
                showhud = true
                print("❌ Product not found.")
                
            case .failure(.firebaseError(let msg)):
                hudMsg = "Firebase error: \(msg)"
                showhud = true
                print("❌ Firebase error: \(msg)")
            }
        }
    }
    
    func fetchBiddingDetail(roomId: String) {
        FirebaseManager.shared.getLiveSessionData(roomId: roomId) { data in
            guard let data = data else { return }
            DispatchQueue.main.async {
                if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
                    do {
                        let model = try JSONDecoder().decode(BiddingModel.self, from: jsonData)
                        self.BiddingDetail = model
                        self.productData = self.BiddingDetail.products ?? [ProductData]()
                        
                    } catch {
                        print("❌ Decoding Error: \(error)")
                    }
                }
                
            }
        }
    }
    
    func success(selectedID : String? = nil){
        let response = viewModel.updateStatusRespone
        if response?.status == "success"{
            let data = response?.data ?? UpdateStatusModel()
            
            isLive = data.is_live ?? false
            
            let roomId = "live_room_\(data.user_id ?? 0)_\(data.id ?? 0)"
            self.roomId = roomId
            if data.is_live == false {
                logoutRoom()
                self.comments.removeAll()
                FirebaseManager.shared.checkAndDeleteLiveSession(roomId: roomId)
                previewResetTrigger.toggle()
                self.showLiveControls = false
                self.showPreLiveControls = true
                self.presentaionMode.wrappedValue.dismiss()
                return
            }
            
            //            let product: [ProductData] = (data.products ?? []).compactMap { product in
            //                guard let id = product.id,
            //                      let categoryId = product.category_id,
            //                      let title = product.title,
            //                      let price = product.pricing
            //                        //                    let isCurrent = true
            //                else {
            //                    return nil
            //                }
            //
            //                return ProductData(
            //                    category: "\(categoryId)",
            //                    id: "\(id)",
            //                    image: product.images?.first ?? "",  // 🛡️ ensure clean array
            //                    name: title,
            //                    price: String(format: "%.2f", price),
            //                    status:product.status ?? "",
            //                    isCurrent: true
            //                )
            //            }
            
            let product: [ProductData] = (data.products ?? []).compactMap { product in
                guard let id = product.id,
                      let categoryId = product.category_id,
                      let title = product.title,
                      let price = product.pricing
                else {
                    return nil
                }
                
                return ProductData(
                    category: "\(categoryId)",
                    id: "\(id)",
                    image: product.images?.first ?? "",
                    name: title,
                    price: String(format: "%.2f", price),
                    status: /*product.status ??*/ "active",
                    isCurrent: selectedID == "\(id)"
                )
            }
            
            
            let seller = SellerModel(isFollowed: data.user?.is_followed ?? false, id: "\(data.user?.id ?? 0 )", name: data.user?.name ?? "", rating: data.user?.rating ?? "")
            
            
            
            FirebaseManager.shared.createLiveSession(showId:"\(data.id ?? 0)", userId: "\(data.user_id ?? 0)", product: product, seller: seller, thumbnail: data.thumbnail?.first ?? "", time: data.time ?? "", date: data.date ?? "", allowBidForAll: true)
            
            
            let user = ZegoUser(userID: "\(data.user_id ?? 0)", userName: data.user?.name ?? "")
            let roomConfig = ZegoRoomConfig()
            
            
            ZegoExpressEngine.shared().loginRoom(
                roomId,
                user: user,
                config: roomConfig
            ) { errorCode, _ in
                if errorCode == 0 {
                    print("✅ Logged into room: \(roomId)")
                    self.liveRoomId = roomId
                    
                    ZegoExpressEngine.shared().startPublishingStream(roomId)
                    ZIMChatManager.shared.joinRoom(roomID: roomId)
                    self.showLiveControls = true
                    self.showPreLiveControls = false
                    self.isLive = true
                    FirebaseManager.shared.observeViewerCount(roomId: self.liveRoomId) { newCount in
                        print("👀 Viewer Count Updated: \(newCount)")
                        viewwerCount = newCount
                    }
                    
                    FirebaseManager.shared.startObservingSessionTimer(roomId: roomId) {
                        //                        self.UpdateStatus(status : true)
                    }
                    fetchBiddingDetail(roomId: roomId)
                    //For Show Automatic Sheet
                    if isLive {
                        print("👀 Starting countdown observer for roomId: \(roomId)")
                        FirebaseManager.shared.observeCountdown(for: roomId) { seconds in
                            DispatchQueue.main.async {
                                print("🟡 Countdown update: \(seconds)s")
                                self.bidCountdownSeconds = seconds
                                
                                if seconds == 30 {
                                    // Countdown just started
                                    self.hasCountdownStarted = true
                                }
                                
                                if self.hasCountdownStarted && seconds == 0 {
                                    print("⏰ Countdown reached zero, showing sheet")
                                    currentBottomSheet = .shop
                                    fetchLatestProductList()
                                    self.showSellSheet = true
                                    self.hasCountdownStarted = false
                                }
                            }
                        }
                    }
                } else {
                    print("❌ Failed to login to room: \(errorCode)")
                }
            }
            
            if data.is_live == true {
                self.showStartTime = Date()
                startLiveTimer()
            }
            
        }
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
                SVProgressHUD.show()
                let is_Live = "true"
                await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: is_Live))
                await SVProgressHUD.dismiss()
                // ✅ Only call success if we have a valid product ID
                if let validID = selectedID, !validID.isEmpty {
                    success(selectedID: validID)
                } else {
                    print("⚠️ Skipping success(): selectedID is nil or empty")
                }
            }
        }
    }
    
    
    func startLiveTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let start = showStartTime, isLive {
                let elapsed = Int(Date().timeIntervalSince(start))
                let hours = elapsed / 3600
                let minutes = (elapsed % 3600) / 60
                let seconds = elapsed % 60
                liveElapsedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                timer.invalidate()
            }
        }
    }
    
    func logoutRoom() {
        ZegoExpressEngine.shared().logoutRoom()
        ZIMChatManager.shared.logout()
        chatManager.messages.removeAll()
        showSellSheet = false
        self.isLive = false
        FirebaseManager.shared.stopObserving()
        self.productData.removeAll()
    }
    
    @ViewBuilder
    func SideButton(label: String, icon: String, action: SideMenu) -> some View {
        Button(action: {
            if action == .switchView {
                isUsingFrontCamera.toggle()
                ZegoExpressEngine.shared().useFrontCamera(isUsingFrontCamera)
            } else {
                currentBottomSheet = action
                showSellSheet = true
            }
        }) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.heavy)
                    .font(.custom(poppinsExtraBold, size: 22.0))
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black)
                //                Text(label)
                //                    .font(.custom(poppinsThin, size: 12.0))
            }
            .padding()
            .background(
                Circle()
                    .fill(Color.white)
            )
        }
    }
    
    @ViewBuilder
    func ShopButton(action : SideMenu) -> some View {
        Button(action: {
            if action == .switchView {
                isUsingFrontCamera.toggle()
                ZegoExpressEngine.shared().useFrontCamera(isUsingFrontCamera)
            } else {
                currentBottomSheet = action
                showSellSheet = true
            }
        }) {
            ZStack {
                VStack {
                    Image(systemName: "bag.fill")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.heavy)
                        .font(.custom(poppinsExtraBold, size: 22.0))
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                    //                    Text("Shop")
                    //                        .font(.custom(poppinsThin, size: 12.0))
                }
                .padding()
                .background(
                    Circle()
                        .fill(Color.white)
                )
                
                Circle()
                    .fill(Color.defaultTheme)
                    .frame(width: 20, height: 20)
                    .overlay(Text("7")
                        .foregroundColor(.black)
                        .font(.custom(poppinsRegular, size: 13.0))
                    )
                    .offset(x: 12, y: -30)
            }
        }
    }
    
    var exampleBoosts: [ShowBoost] {
        [
            ShowBoost(
                title: "15 Minute Boost",
                subtitle: "Quick visibility boost",
                description: "Get featured in the top shows for 15 minutes",
                price: "$3.99",
                iconName: "bolt.fill",
                gradient: LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                action: { print("Selected 15 Minute Boost") }
            ),
            ShowBoost(
                title: "Full Show Promote",
                subtitle: "Extended visibility",
                description: "Stay featured for your entire show duration",
                price: "$7.99",
                iconName: "star.fill",
                gradient: LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
                action: { print("Selected Full Show Promote") }
            ),
            ShowBoost(
                title: "Community Boost",
                subtitle: "Power of the crowd",
                description: "Rally your community for massive exposure",
                price: "$12.99",
                iconName: "person.3.fill",
                gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
                action: { print("Selected Community Boost") }
            )
        ]
    }
    
    
}




struct ZegoRehearsalScreen: UIViewRepresentable {
    @Binding var isLive : Bool
    @State var streamID = ""
    
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let canvas = ZegoCanvas(view: view)
            canvas.viewMode = .aspectFill
            ZegoExpressEngine.shared().enableCamera(true)
            ZegoExpressEngine.shared().startPreview(canvas)
            
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Optional: handle dynamic stream change if needed
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        
        ZegoExpressEngine.shared().stopPublishingStream()
        ZegoExpressEngine.shared().stopPlayingStream("")
    }
}


enum SideMenu {
    case more, promote, clip, share, switchView, shop,endShow
}


//Task{
//    SVProgressHUD.show()
//    await self.viewModel.productDetails(parameters: UserProductRequest(user_id: Int(id) ?? 0,page : currentPage))
//    await SVProgressHUD.dismiss()
//    success()
//}
