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
   @State  var streamId = ""
    var isLocal: Bool = true
    @Environment(\.presentationMode) var presentaionMode
    @State var viewModel = ShowsViewModel()
    @State var isLive : Bool = false
    @State var roomId = ""
    
    @State var isMicOn: Bool = true
    @State var isUsingFrontCamera: Bool = true
    
    var body: some View {
        ZStack {
            
            ZegoRehearsalScreen(isLive: $isLive,streamID: roomId )

            VStack {
                HStack {
                    HStack(spacing: 8) {
                        Image("profile_icon")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("swiftbid")
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            Text("Show Time 00:00:01")
                                .foregroundColor(.white)
                                .font(.caption2)
                        }
                        
                        Spacer()
                        Text(isLive ? "Live" : "Rehearsal")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            self.presentaionMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                VStack(spacing: 20) {
                    Button(action: {
                        isMicOn.toggle()
                        ZegoExpressEngine.shared().muteMicrophone(!isMicOn)
                    }) {
                        VStack {
                            Image(systemName: isMicOn ? "mic.fill" : "mic.slash.fill")
                            Text(isMicOn ? "Mic On" : "Mic Off")
                        }
                        .padding(8)
                        .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        isUsingFrontCamera.toggle()
                        ZegoExpressEngine.shared().useFrontCamera(isUsingFrontCamera)
                    }) {
                        VStack {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                            Text("Switch")
                        }
                        .padding(8)
                        .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        
                    }) {
                        ZStack {
                            VStack {
                                Image(systemName: "bag.fill")
                                Text("Shop")
                            }
                            .padding(8)
                            .foregroundColor(.white)
                            
                            Circle()
                                .fill(Color.red)
                                .frame(width: 20, height: 20)
                                .overlay(Text("7").foregroundColor(.white).font(.caption))
                                .offset(x: 12, y: -30)
                        }
                    }
                }
                .padding(.trailing)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
           
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("goodgirlsteph97").bold()
                        Text("Mod").padding(4).background(Color.gray.opacity(0.3)).cornerRadius(4)
                        Text("🔥 XL").foregroundColor(.orange)
                    }
                    .foregroundColor(.white)
                    
                    HStack {
                        Text("trapwoc212")
                            .bold()
                        Text("White gold")
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                Button(action: {
                    Task{
                        SVProgressHUD.show()
                        var is_Live = ""
                        if isLive{
                            is_Live = "false"
                           
                        }else{
                            is_Live = "true"
                        }
                        await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: is_Live))
                        await SVProgressHUD.dismiss()
                        await success()
                    }
                }) {
                    Text( isLive ? "End Show " : "Start Show")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onAppear{
            logoutRoom()
        }
        .onDisappear{
            logoutRoom()
        }
    }
    
    func success(){
        let response = viewModel.updateStatusRespone
        if response?.status == "success"{
//            self.streamId = "\(response?.data?.id ?? 0)"
            let data = response?.data ?? UpdateStatusModel()
            
            isLive = data.is_live ?? false
            
            let roomId = "live_room_\(data.user_id ?? 0)_\(data.id ?? 0)"
            self.roomId = roomId
            if data.is_live == false {
                logoutRoom()
                FirebaseManager.shared.checkAndDeleteLiveSession(roomId: roomId)
                return
            }
            
            let product = ProductData(category: "\(data.products?.first?.category_id ?? 0)", id: "\(data.products?.first?.id ?? 0)", image: "\(data.products?.first?.images?.first ?? "")", name: "\(data.products?.first?.title ?? "")", price: "\(data.products?.first?.pricing ?? 0.0)")
            
            let seller = SellerModel(followed: data.user?.is_followed ?? false, id: "\(data.user?.id ?? 0 )", name: data.user?.name ?? "", rating: data.user?.rating ?? "")
            FirebaseManager.shared.createLiveSession(showId:"\(data.id ?? 0)", userId: "\(data.user_id ?? 0)", product: product, seller: seller, thumbnail: data.thumbnail?.first ?? "", time: data.time ?? "")
            
            
            let user = ZegoUser(userID: "\(data.user_id ?? 0)", userName: data.user?.name ?? "")
            let roomConfig = ZegoRoomConfig()
            
            
            ZegoExpressEngine.shared().loginRoom(
                roomId,
                user: user,
                config: roomConfig
            ) { errorCode, _ in
                if errorCode == 0 {
                    print("✅ Logged into room: \(roomId)")
                    ZegoExpressEngine.shared().startPublishingStream(roomId)
                } else {
                    print("❌ Failed to login to room: \(errorCode)")
                }
            }

        }
    }
    func logoutRoom() {
        ZegoExpressEngine.shared().logoutRoom()
    }
    
}
struct ProductData {
    let category: String
    let id: String
    let image: String
    let name: String
    let price: String

    func toDictionary() -> [String: Any] {
        return [
            "category": category,
            "id": id,
            "image": image,
            "name": name,
            "price": price
        ]
    }
}

struct SellerModel {
    let followed: Bool
    let id: String
    let name: String
    let rating: String

    func toDictionary() -> [String: Any] {
        return [
            "followed": followed,
            "id": id,
            "name": name,
            "rating": rating
        ]
    }
}



struct ZegoRehearsalScreen: UIViewRepresentable {
    @Binding var isLive : Bool
    @State var streamID = ""
   
   

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let canvas = ZegoCanvas(view: view)
            ZegoExpressEngine.shared().enableCamera(true)

                ZegoExpressEngine.shared().startPreview(canvas)

        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Optional: handle dynamic stream change if needed
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        // Always stop everything cleanly
//        ZegoExpressEngine.shared().stopPreview()
        ZegoExpressEngine.shared().stopPublishingStream()
        ZegoExpressEngine.shared().stopPlayingStream("")
    }
}
