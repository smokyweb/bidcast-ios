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

    @State private var showPreLiveControls: Bool = true
    @State private var showLiveControls: Bool = false
    
    
    @State private var verifiedOnly = false
    
    @State private var currentBottomSheet: SideMenu?
    @State private var showSellSheet: Bool = false
    
    @State private var showButton: Bool = false

    var body: some View {
        ZStack {
            ZegoRehearsalScreen(isLive: $isLive, streamID: roomId)

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
                            .background(Color.red)
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
                        showButton = true
                    }) {
                        Text("Ok")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
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
                    if showPreLiveControls {
                        SideButton(label: "More", icon: "ellipsis.circle",action: .more)
                        SideButton(label: "Promote", icon: "megaphone.fill",action: .promote)
                        SideButton(label: "Clip", icon: "scissors",action: .clip)
                        SideButton(label: "Share", icon: "square.and.arrow.up",action: .share)
                        SideButton(label: "Switch", icon: "arrow.left.arrow.right",action: .switchView)
                        ShopButton(action: .shop)
                    }

                    if showLiveControls {
                        Button(action: {
                            isMicOn.toggle()
                            ZegoExpressEngine.shared().muteMicrophone(!isMicOn)
                        }) {
                            VStack {
                                Image(systemName: isMicOn ? "mic.fill" : "mic.slash.fill")
                                Text(isMicOn ? "Mic On" : "Mic Off")
                                    .font(.custom(poppinsThin, size: 12.0))
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
                                    .font(.custom(poppinsThin, size: 12.0))
                            }
                            .padding(8)
                            .foregroundColor(.white)
                        }

                        ShopButton(action: .shop)
                    }
                }
                .padding(.trailing)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // 💬 Bottom Chat & Start Button
            VStack(alignment: .leading, spacing: 8) {
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("goodgirlsteph97").font(.custom(poppinsBold, size: 13.0))
                        Text("Mod")
                            .font(.custom(poppinsBold, size: 13.0))
                            .padding(4)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(4)
                        Text("🔥 XL")
                            .font(.custom(poppinsBold, size: 13.0))
                            .foregroundColor(.orange)
                    }.foregroundColor(.white)

                    HStack {
                        Text("trapwoc212").font(.custom(poppinsBold, size: 13.0))
                        Text("White gold").font(.custom(poppinsSemiBold, size: 12.0))
                    }.foregroundColor(.white)
                }
                .padding(.horizontal)
                if showButton{
                    Button(action: {
                        Task {
                            SVProgressHUD.show()
                            let is_Live = isLive ? "false" : "true"
                            await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: is_Live))
                            await SVProgressHUD.dismiss()
                            await success()
                        }
                    }) {
                        Text(isLive ? "End Show" : "Start Show")
                            .font(.custom(poppinsBold, size: 13.0))
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
        }
        .bottomSheet(
            isPresented: $showSellSheet,
            height: screenHeight * 0.65, // Adjust as needed
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
                        onEndShow: { print("End Show") },
                        onCloneItems: { print("Clone Items") },
                        onTipSettings: { print("Tip Settings") },
                        onMulticast: { print("Multicast") },
                        onAddCoupons: { print("Add Coupons") },
                        onRaid: { print("Raid") },
                        onCreatePoll: { print("Create Poll") },
                        onRotateCamera: { print("Rotate Camera") },
                        onZoomIn: { print("Zoom In") },
                        onMicToggle: { print("Mic Toggled") }
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
                    ShopBottomSheetView(
                        isPresented: $showSellSheet,
                        products: [
                            Product(imageName: "IMG_1340", title: "iPhone 15 Pro", subtitle: "Starting bid: $999", detail: "05:23:45 left", statusColor: .red),
                            Product(imageName: "IMG_1340", title: "AirPods Max", subtitle: "Buy Now: $549", detail: "0 Bids", statusColor: .green)
                        ]
                    )
                       case .none:
                           EmptyView()
                       }
               
            }
        )
        .onAppear {
            logoutRoom()
            showTopBadge = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showReadyModal = true
            }
        }
        .onDisappear {
            logoutRoom()
        }
    }
    func success(){
        let response = viewModel.updateStatusRespone
        if response?.status == "success"{
            let data = response?.data ?? UpdateStatusModel()
            
            isLive = data.is_live ?? false
            
            let roomId = "live_room_\(data.user_id ?? 0)_\(data.id ?? 0)"
            self.roomId = roomId
            if data.is_live == false {
                logoutRoom()
                FirebaseManager.shared.checkAndDeleteLiveSession(roomId: roomId)
                self.showLiveControls = false
                self.showPreLiveControls = true
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
                    self.showLiveControls = true
                    self.showPreLiveControls = false
                } else {
                    print("❌ Failed to login to room: \(errorCode)")
                }
            }

        }
    }
    func logoutRoom() {
        ZegoExpressEngine.shared().logoutRoom()
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
                  Text(label)
                      .font(.custom(poppinsThin, size: 12.0))
              }
              .padding(8)
              .foregroundColor(.white)
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
                      Text("Shop")
                          .font(.custom(poppinsThin, size: 12.0))
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
        ZegoExpressEngine.shared().stopPublishingStream()
        ZegoExpressEngine.shared().stopPlayingStream("")
    }
}


enum SideMenu {
    case more, promote, clip, share, switchView, shop
}
