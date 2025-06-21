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

struct Comment: Identifiable, Equatable {
    let id = UUID()
    let username: String
    let message: String
}

struct LiveStream: View {
    @State private var commentText = ""
    @State var comments: [Comment] = []
    
    @State var id : String = ""
    @GestureState private var dragOffset = CGSize.zero
    @State var navigateToProfile = false
    @State private var swipeConfirmed = false
    @Binding var currentStreamIndex : Int
    @State private var verticalDragOffset = CGSize.zero
    @GestureState private var verticalGestureOffset = CGSize.zero
    @State var roomID = [String]()
    @State var streamID = [String]()
    var viewModel = LiveShowsViewModel()
    @State var liveShowsData = [LiveShowsModel]()
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @Binding var userId : String
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var zegoManager = ZegoManager.shared
    //    @ObservedObject var chatManager = ZegoChatManager.shared
    
    var localUserID = "\(UserDefaults.userId)"
    
    
    @State private var previewResetTrigger = false
    
    @State private var showStartTime: Date? = nil
    @State private var liveElapsedTime: String = "00:00:00"
    var body: some View {
      
            GeometryReader { geometry in
                if liveShowsData.count != 0{
                    ZStack(alignment: .top) {
                        if streamID.count != 0 {
                            ZegoPreviewView(streamID: streamID[currentStreamIndex])
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
                                       Image(systemName: "xmark.circle.fill")
                                           .foregroundColor(.danger)
                                           .font(.custom(poppinsSemiBold, size: 20.0))
                                   }
                               
                            }
                            .padding(.horizontal)
                            .padding(.top, 30)
                            
                            Spacer()
                            
                            // Floating action icons on the right
                            VStack(spacing: 16) {
                                Button(action: {}) {
                                    Image(systemName: "info.circle")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                Button(action: {}) {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                                Button(action: {}) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(systemName: "cart")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 14, height: 14)
                                            .overlay(Text("7").font(.caption2).foregroundColor(.white))
                                    }
                                }
                            }
                            .padding(.trailing)
                            .padding(.bottom, 180)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            // Comments Section
                            if ZegoManager.shared.isCommentsAvailable {
                                HStack{
                                    ScrollViewReader { scrollProxy in
                                        ScrollView(.vertical, showsIndicators: false) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                ForEach(zegoManager.incomingComments) { comment in
                                                    HStack(alignment: .center, spacing: 6) {
//                                                        Image("defaultUser")
//                                                            .resizable()
//                                                            .scaledToFit()
//                                                            .frame(width: 24, height: 24)
//                                                            .clipShape(Circle())
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
                                        .onChange(of: zegoManager.incomingComments) { _ in
                                            withAnimation {
                                               
                                                if let lastID = zegoManager.incomingComments.last?.id {
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
                            }
                            
                            HStack(spacing: 12) {
                                CustomProfileImage(url: liveShowsData[currentStreamIndex].category?.image ?? "", isCircular: false,cornerRadius: 8.0,size: 60.0)
                               
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Item Name")
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
                            
                            // Swipe to Bid Button
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.black.opacity(0.3))
                                    .frame(height: 50)
                                
                                Text("Swipe to Bid")
                                    .font(.custom(poppinsSemiBold, size: 14.0))
                                    .foregroundColor(.white)
                                    .padding(.leading)
                                Spacer()
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.white, lineWidth: 2)
                                    .frame(width: 50, height: 40)
                                    .overlay(
                                        Text(swipeConfirmed ? "✓" : "→")
                                            .foregroundColor(.white)
                                            .bold()
                                    )
                                    .offset(x: (screenWidth / 2 - 50) + dragOffset.width)
                                    .gesture(
                                        DragGesture()
                                            .updating($dragOffset) { value, state, _ in
                                                if value.translation.width >= 0 {
                                                    
                                                    let maxDrag = screenWidth - 40 - (screenWidth / 2 - 50)
                                                    state = CGSize(width: min(value.translation.width, maxDrag), height: 0)
                                                }
                                            }
                                            .onEnded { value in
                                                let maxDrag = screenWidth - 40 - (screenWidth / 2 - 50)
                                                if value.translation.width > maxDrag * 0.8 {
                                                    swipeConfirmed = true
                                                    
                                                } else {
                                                    swipeConfirmed = false
                                                }
                                            }
                                    )
                                    .animation(.spring(), value: dragOffset)
                            }
                            .padding(.horizontal)
                            
                            // Comment Input
                         
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
                                            let textToSend = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                                            let roomId = liveShowsData[currentStreamIndex].room_id ?? ""
                                            ZegoExpressEngine.shared().sendBroadcastMessage(commentText, roomID: roomId) { errorCode, messageID in
                                                
                                                if errorCode == 0 {
                                                    let newComment = Comment(username: UserDefaults.userName.capitalizingFirstLetter(), message: textToSend)
                                                    comments.append(newComment)
                                                    print("✅ Broadcast message sent successfully, msgID: \(messageID)")
                                                } else {
                                                    print("❌ Failed to send broadcast message, errorCode: \(errorCode)")
                                                }
                                            }
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
                            .padding(.bottom,80)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .updating($verticalGestureOffset) { value, state, _ in
                                
                                if abs(value.translation.height) > abs(value.translation.width) {
                                    state = value.translation
                                }
                            }
                            .onEnded { value in
                                let verticalAmount = value.translation.height
                                
                                if verticalAmount < -100 { // Swipe Up
                                    withAnimation {
                                        currentStreamIndex = min(currentStreamIndex + 1, streamID.count - 1)
                                        print("Switched to stream index: \(currentStreamIndex)")
                                    }
                                } else if verticalAmount > 100 { // Swipe Down
                                    withAnimation {
                                        currentStreamIndex = max(currentStreamIndex - 1, 0)
                                        print("Switched to stream index: \(currentStreamIndex)")
                                    }
                                }
                            }
                    )
                    CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(id:$id))
                }
            }
            .bottomSheet(isPresented: $zegoManager.streamInterrupted, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
                CommonBottomSheet(
                    sheetType: $zegoManager.alertType,
                    onPrimaryClick: {
                        withAnimation {
                            zegoManager.resetError()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    },
                    onSecondaryClick: {
                        withAnimation {
                            zegoManager.resetError()
                        }
                    }
                )
            }
            .foregroundColor(.white)
            .onAppear{
                Task{
                    SVProgressHUD.show()
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
            liveShowsData = response.data ?? [LiveShowsModel]()
            roomID = liveShowsData.compactMap { $0.room_id }
            streamID = roomID
            if !liveShowsData.isEmpty {
                let initialRoomID = liveShowsData[currentStreamIndex].room_id ?? ""
                loginRoom(roomId: initialRoomID)
//                ZegoExpressEngine.shared().setEventHandler(ZegoManager.shared)
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
    
    
    func loginRoom(roomId : String) {
        
        let user = ZegoUser(userID: "\(UserDefaults.userId)",userName: UserDefaults.userName)
        let roomConfig = ZegoRoomConfig()
        
        roomConfig.isUserStatusNotify = true
        
        ZegoExpressEngine.shared().loginRoom(roomId, user: user, config: roomConfig) { errorCode, extendedData in
            if errorCode == 0 {
                print("✅ Login callback | room: \(roomId) | errorCode: \(errorCode)")
            } else {
                print("login fail error")
            }
        }
    }
    
    func logoutRoom() {
        ZegoExpressEngine.shared().logoutRoom()
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
        
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: (Coordinator)) {
        
        ZegoExpressEngine.shared().stopPlayingStream(coordinator.streamID)
    }
}



