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

struct Comment: Identifiable, Equatable {
    let id = UUID()
    let image : String
    let username: String
    let message: String
}

struct LiveStream: View {
    @State private var commentText = ""
    @State var comments: [Comment] = []
    
    @State var id : String = ""
    @State var dragOffset = CGSize.zero
    @State var navigateToProfile = false
    @State private var swipeConfirmed = false
    @Binding var currentStreamIndex : Int
    @State private var verticalDragOffset = CGSize.zero
    @GestureState private var verticalGestureOffset = CGSize.zero
    @State var roomID = [String]()
    @State var streamID = [String]()
    var viewModel = LiveShowsViewModel()
    @State var liveShowsData = [LiveShowsModel]()
    @State var BiddingDetail = BiddingModel()
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "Stream Ended", message: "The live stream has ended.", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @Binding var userId : String
    @Environment(\.presentationMode) var presentationMode
    
    @State var titleStream = "Stream Ended"
    @State var messageStream = "The live stream has ended."
    @ObservedObject var zegoManager = ZegoManager.shared
    @ObservedObject var chatManager = ZIMChatManager.shared
    @StateObject private var keyboardResponder = KeyboardResponder()
    var localUserID = "\(UserDefaults.userId)"
    @State private var previewResetTrigger = false
    @State private var showStartTime: Date? = nil
    @State private var liveElapsedTime: String = "00:00:00"
    
    @State  var currentRoomID = ""
    @State var streamInterrrupted = false
    
    var tabBarHeight: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 49
    }
    
    @State var showHud = false
    @State var hudMsg = ""
    //MARK: - for swipe
           @State private var currentPrice: Int = 1
           @State private var countdown: Int = 5
           @State private var isBiddingActive: Bool = false
           @State private var priceTimer: Timer?
           @State private var countdownTimer: Timer?
    
           let totalSwipeWidth: CGFloat = UIScreen.main.bounds.width - 80
    
    var body: some View {
        
        GeometryReader { geometry in
            if liveShowsData.count != 0{
                ZStack(alignment: .top) {
                    if streamID.count != 0 {
                        ZegoPreviewView(streamID: streamID[currentStreamIndex])
                            .offset(y: verticalDragOffset.height)
                            .frame(width: geometry.size.width, height: geometry.size.height + 50)
                            .edgesIgnoringSafeArea(.all)
                        
                    }
                    VStack {
                        HStack(spacing: 12) {
                            Button(action:{
                                id = userId
                                navigateToProfile = true
                            }){
                                CustomProfileImage(url: liveShowsData[currentStreamIndex].user?.profile_image ?? "", isCircular: true)
                                
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(liveShowsData[currentStreamIndex].user?.name ?? "")
                                        .foregroundColor(.white)
                                        .bold()
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.yellow)
                                        Text("99")
                                            .font(.custom(poppinsSemiBold, size: 13.0))
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(.black)
                                Text("\(liveShowsData[currentStreamIndex].viewer_count ?? 0)")
                                    .foregroundColor(.black)
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                            }
                            Button(action: {}) {
                                Text("Follow")
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.yellow)
                                    .cornerRadius(10)
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
                        .padding(.top, 30)
                        
                        Spacer()
                        
                        //MARK: Side menu
                      
                        VStack(spacing: 20) {
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "gift")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Button(action: {}) {
                                Image(systemName: "paperclip")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Button(action: {}) {
                                Image(systemName: "arrowshape.turn.up.right")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Button(action: {}) {
                                Image(systemName: "wallet.pass")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            Button(action: {}) {
                                Image(systemName: "cart")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.trailing)
                        .padding(.bottom, 200)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Spacer()
                        
                        
                        //MARK: Comment section
                        if chatManager.messages.count > 0 {
                            HStack{
                                ScrollViewReader { scrollProxy in
                                    ScrollView(.vertical, showsIndicators: false) {
                                        VStack(alignment: .leading, spacing: 8) {
                                            ForEach(chatManager.messages) { comment in
                                                HStack(alignment: .center, spacing: 6) {
                                                    Image(comment.image)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24, height: 24)
                                                        .clipShape(Circle())
                                                    VStack(alignment: .leading) {
                                                        Text(comment.username)
                                                            .font(.custom(poppinsSemiBold, size: 12.0))
                                                            .bold()
                                                            .foregroundColor(.white)
                                                        Text(comment.message)
                                                            .font(.footnote)
                                                            .foregroundColor(.white)
                                                    }
                                                    Spacer()
                                                }
                                                .id(comment.id)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .onChange(of: chatManager.messages) { _ in
                                        withAnimation {
                                            
                                            if let lastID = chatManager.messages.last?.id {
                                                scrollProxy.scrollTo(lastID, anchor: .bottom)
                                            }
                                        }
                                    }
                                    .frame(width:screenWidth - 50,height: 150)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                                }
                                Spacer()
                            }
                            .padding(.bottom,50)
                        }
                        //MARK: Product Details
                        HStack(spacing: 12) {
                            CustomProfileImage(url: liveShowsData[currentStreamIndex].category?.image ?? "", isCircular: false,cornerRadius: 8.0,size: 60.0)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(BiddingDetail.product?.name.capitalizingFirstLetter() ?? "")
                                    .font(.custom(poppinsBold, size: 13.0))
                                    .foregroundColor(.black)
                                HStack(spacing: 6) {
                                    Text("Tag")
                                        .font(.custom(poppinsSemiBold, size: 12.0))
                                        .padding(4)
                                        .background(Color.purple.opacity(0.7))
                                        .cornerRadius(4)
                                    Text("Tag")
                                        .font(.custom(poppinsSemiBold, size: 12.0))
                                        .padding(4)
                                        .background(Color.pink.opacity(0.7))
                                        .cornerRadius(4)
                                }
                                Text("Lorem ipsum dolor sit amet")
                                    .font(.custom(poppinsSemiBold, size: 12.0))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                       
                        //MARK: Swipe fearture
                        HStack(spacing: 0) {
                                // 3/4 Swipe Area
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.black.opacity(0.3))
                                        .frame(height: 60)

                                  
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.defaultTheme)
                                        .frame(width: 50, height: 40)
                                        .overlay(
                                            Text(swipeConfirmed ? "✓" : "→")
                                                .foregroundColor(.white)
                                                .bold()
                                        )
                                        .offset(x: min(dragOffset.width + 110, totalSwipeWidth - 90))
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    if value.translation.width >= 0 {
                                                        dragOffset = value.translation
                                                    }
                                                }
                                                .onEnded { value in
                                                    if value.translation.width > totalSwipeWidth * 0.8 {
                                                        swipeConfirmed = true
                                                        dragOffset = .zero
                                                        incrementPrice()
                                                    } else {
                                                        swipeConfirmed = false
                                                        dragOffset = .zero
                                                    }
                                                }
                                        )
                                        .animation(.easeOut, value: dragOffset)
                                    
                                    Text("Swipe to Bid")
                                        .font(.custom(poppinsSemiBold, size: 14.0))
                                        .foregroundColor(.white)
                                        .padding(.leading)

                                }
//                                .frame(width: UIScreen.main.bounds.width * 0.75)

                                // 1/4 Price & Timer Area
                                VStack {
                                    Text("$ \(String(format: "%.2f", Double(currentPrice)))")
                                        .font(.custom(poppinsBold, size: 18))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 4)

                                    Text(String(format: "00:00:%02d", countdown))
                                        .font(.custom(poppinsSemiBold, size: 14))
                                        .foregroundColor(.white)
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.25)
                                .background(.defaultTheme)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .onAppear {
                                if !isBiddingActive {
                                    startCountdown()
                                    isBiddingActive = true
                                }
                            }
                        
                        
                        //MARK: Add Comment section
                        
                        HStack {
                            ZStack(alignment: .trailing) {
                                TextField("", text: $commentText, prompt: Text("Say something...")
                                    .foregroundColor(.white)
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                                )
                                .font(.custom(poppinsSemiBold, size: 13.0))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.trailing, commentText.isEmpty ? 14 : 36) // extra space for send button
                                .frame(height: 40)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                                
                                if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Button(action: {
                                        let roomId = liveShowsData[currentStreamIndex].room_id ?? ""
                                        ZIMChatManager.shared.sendMessage(message: commentText,roomId: roomId)
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
                        .padding(.horizontal)
                        .padding(.bottom)
                        .padding(.bottom, keyboardResponder.currentHeight == 0 ? (tabBarHeight + 20) : keyboardResponder.currentHeight)
                        .animation(.easeOut(duration: 0.25), value: keyboardResponder.currentHeight)
                    }
                }
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
                            
                            if verticalAmount < -swipeThreshold {
                                if currentStreamIndex < streamID.count - 1 {
                                    withAnimation(.easeInOut) {
                                        ZegoExpressEngine.shared().stopPlayingStream(streamID[currentStreamIndex])
                                        currentStreamIndex += 1
                                        verticalDragOffset = .zero // Reset swipe offset
                                    }
                                    
                                    let newRoomId = liveShowsData[currentStreamIndex].room_id ?? ""
                                    loginRoom(roomId: newRoomId)
                                    fetchBiddingDetail(roomId: newRoomId)
                                } else {
                                    withAnimation {
                                        verticalDragOffset = .zero // If last item, reset
                                    }
                                }
                            } else if verticalAmount > swipeThreshold { // Swipe Down
                                if currentStreamIndex > 0 {
                                    withAnimation(.easeInOut) {
                                        ZegoExpressEngine.shared().stopPlayingStream(streamID[currentStreamIndex])
                                        currentStreamIndex -= 1
                                        verticalDragOffset = .zero // Reset swipe offset
                                    }
                                    
                                    let newRoomId = liveShowsData[currentStreamIndex].room_id ?? ""
                                    loginRoom(roomId: newRoomId)
                                    fetchBiddingDetail(roomId: newRoomId)
                                } else {
                                    withAnimation {
                                        verticalDragOffset = .zero // If first item, reset
                                    }
                                }
                            } else {
                                withAnimation {
                                    verticalDragOffset = .zero // If not enough swipe, reset
                                }
                            }
                        }
                )
                CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(id:$id))
            }
        }.gesture(
            TapGesture().onEnded { _ in
                hideKeyboard()
            }
        )
        .toast(isPresenting: $showHud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
            
        
        
        .bottomSheet(isPresented: $streamInterrrupted, height: screenHeight / 2.2, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            streamInterrrupted = true
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation {
                        streamInterrrupted = false
                        logoutRoom()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                },
                onSecondaryClick: {
                    withAnimation {
                        streamInterrrupted = false
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .edgesIgnoringSafeArea(.bottom)
       
        .toolbar(.hidden,for: .tabBar)
        .foregroundColor(.white)
        .onAppear{
            ZIMChatManager.shared.login(userID: "\(UserDefaults.userId)", userName: UserDefaults.userName)
            Task{
                SVProgressHUD.show()
                liveShowsData.removeAll()
                roomID.removeAll()
                streamID.removeAll()
                await self.viewModel.getLiveShows(param:GetLiveShowsRequest(type: "live"))
                await SVProgressHUD.dismiss()
                success()
            }
        }
        .onDisappear{
            logoutRoom()
        }
        
    }
    
    
    func success() {
        SVProgressHUD.dismiss()
        let response = viewModel.liveShowsResponse
        if response.status == "success" {
            
            FirebaseManager.shared.fetchAllLiveSessions { firebaseRoomIds in
                let validShows = response.data?.filter { show in
                    guard let roomId = show.room_id else { return false }
                    return firebaseRoomIds.contains(roomId)
                }
                
                DispatchQueue.main.async {
                    if validShows?.isEmpty == true {
                        
                    }else{
                        liveShowsData = validShows ?? [LiveShowsModel]()
                        roomID = liveShowsData.compactMap { $0.room_id }
                        streamID = roomID
                        if !liveShowsData.isEmpty {
                            let initialRoomID = liveShowsData[currentStreamIndex].room_id ?? ""
                            loginRoom(roomId: initialRoomID)
                            fetchBiddingDetail(roomId: initialRoomID)
                            ZIMChatManager.shared.joinRoom(roomID: initialRoomID)
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
    
    
    func loginRoom(roomId: String) {
        let user = ZegoUser(userID: "\(UserDefaults.userId)", userName: UserDefaults.userName)
        let roomConfig = ZegoRoomConfig()
        roomConfig.isUserStatusNotify = true
        
        ZegoExpressEngine.shared().loginRoom(roomId, user: user, config: roomConfig) { errorCode, extendedData in
            if errorCode == 0 {
                print("✅ Login callback | room: \(roomId) | errorCode: \(errorCode)")
                currentRoomID = roomId
                FirebaseManager.shared.observeLiveSessionRemoval(roomId: roomId) {
                    let streamTitle = self.titleStream
                    let streamMessage = self.messageStream
                    showHud = true
                    hudMsg = "Live stream has been ended"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                        logoutRoom()
                        self.presentationMode.wrappedValue.dismiss()
                    }
//                    print("🔥 STREAM REMOVED CALLBACK TRIGGERED 🔥")
//                    alertType = .sheetType(icon: .alert,
//                                           title: streamTitle,
//                                           message: streamMessage,
//                                           primaryBtnText: "",
//                                           secondaryBtnText: AppString.ok.localized,
//                                           sheetThemeColor: .defaultTheme)
//                    
//                      
//                           withAnimation(.snappy) {
//                               streamInterrrupted = false
//                           }
                       
                    
                    
                }
            } else {
                print("login fail error")
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
                        if let priceString = self.BiddingDetail.product?.price,
                           let priceDouble = Double(priceString) {
                            self.currentPrice = Int(priceDouble)
                        }
                    } catch {
                        print("❌ Decoding Error: \(error)")
                    }
                }
            
            }
        }
    }
    
    func logoutRoom() {
        ZegoExpressEngine.shared().logoutRoom()
        chatManager.logout()
        chatManager.messages.removeAll()
        if let currentRoomId = liveShowsData[safe: currentStreamIndex]?.room_id {
            FirebaseManager.shared.databaseRef.child("live_sessions").child(currentRoomId).removeAllObservers()
        }
        
    }
       
   
    func startCountdown() {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if countdown > 0 {
                    countdown -= 1
                } else {
                    incrementPrice()
                }
            }
        }

        func incrementPrice() {
            let range = (currentPrice / 10) * 10
            let increment = (range / 10 + 1)
            currentPrice += increment
            countdown = 5
        }
}



struct ZegoPreviewView: UIViewRepresentable {
    let streamID: String
    func makeCoordinator() -> Coordinator {
        Coordinator(streamID: streamID)
    }
    
    class Coordinator {
        var streamID: String
        init(streamID: String) {
            self.streamID = streamID
        }
    }
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let canvas = ZegoCanvas(view: view)
            canvas.viewMode = .aspectFill
            ZegoExpressEngine.shared().startPlayingStream(streamID, canvas: canvas)
        }
        
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        ZegoExpressEngine.shared().stopPlayingStream(context.coordinator.streamID)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let canvas = ZegoCanvas(view: uiView)
            canvas.viewMode = .aspectFill
            ZegoExpressEngine.shared().startPlayingStream(streamID, canvas: canvas)
            context.coordinator.streamID = streamID
        }
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: (Coordinator)) {
        
        ZegoExpressEngine.shared().stopPlayingStream(coordinator.streamID)
    }
}



