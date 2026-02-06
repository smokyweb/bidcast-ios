//
//  RehearsalScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/06/25.
//

import SwiftUI
import Foundation
import SVProgressHUD
import AlertToast
import AVKit

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
    @State var productData = [ProductDataModel1]()
    @Binding var productListData: [ProductDataModel1]
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
    @State private var showShopSheet: Bool = false
    @State private var showProductSheet : Bool = false
    @State private var freebieActive : Bool = false
    
    @State private var navigateToProductList : Bool = false
    @State private var navigateToRandomizer : Bool = false
    

    @State private var showPollSheet : Bool = false
    @State private var showButton: Bool = false
    @State private var showEditClip = false

    
    @State private var initialSelectedProductId: String = ""
    
    @State private var commentText = ""
    
    @State var liveRoomId = ""
    
    @State private var previewResetTrigger = false
    
    @State private var showPollCard = false
    @State private var currentPollModel: PollModel?
    @State private var remainingTimer: Int?
    @State var messageList: [ChatMessage] = []
    
    var currentProduct: ProductDataModel1? {
        productData.first /*{ $0.isCurrent }*/
    }
    
    
    @State private var showStartTime: Date? = nil
    @State private var liveElapsedTime: String = "00:00:00"
    
    var tabBarHeight: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 49
    }
    
    @State var comeFromPrepare = false
    @State var comeForLive = false
    
    @State var showSellerSheet = false
    @State var showFreebieSheet = false
    @State var showRaidSheet = false
    @State var showUserSheet = false
    
    @State private var selectedSellers: Int?
    
    
    @State var navigateToSeller = false
    @State var showSpin = false
    
    @State private var showLivePollScreen: Bool = false
    @State var wheelTitles = [FreebieUser]()
    @State var hasWon = false
    
    @State var viewwerCount = 0
    @State private var bidCountdownSeconds = 30
    @State var categoryid = ""
    @State private var auctionTypeId : Int = 0
    @State private var hasCountdownStarted = false
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "Stream Ended", message: "The live stream has ended.", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var showhud: Bool = false
    @State var showhudSuccess: Bool = false
    @State var showhudAlert: Bool = false
    @State var hudMsg: String = ""
    @Binding var backToTabBar : Bool
    @State private var clipStart: CMTime?
    @State private var clipEnd: CMTime?
    
//    @State private var renderer = MCAcceleratedVideoRenderer()
    
    @StateObject private var agoraManager = AgoraManager(asHost: true)
    @State private var isHost = true
    
    @State var agoraToken: String = ""
    @State var uId: Int = 0
    @State var channelName: String = ""
    var sheetHeight: CGFloat {
        switch currentBottomSheet {
        case .more: return screenHeight * 0.7
        case .promote: return screenHeight * 0.7
        case .clip: return screenHeight * 0.75
        case .share: return screenHeight * 0.9 // Or screenHeight * 0.5
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
    @State var clipURL = ""
    @State var clipModel = ClipModel()
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    @State var messageHeight: CGFloat = 40   // single message height
    let maxVisibleMessages = 3
    @State var sellerId = ""
    @State var showItemDetailSheet = false
    @State var showError = false
    @State var productId: Int = 0
    @State var usersCount = 0
    
    @State var showNotes: String = ""
    @State var showNotesSheet = false
    @State var isEditingNotes = false
    
    @State var showAuctionSetting = false
    @State var showAuctionSheet = false
    @State var showTipSetting = false
    @State var hasAuctionStarted = false
    @State var isProductPinned = false
    @State var auctionedProductData = ProductDataModel1()
    @State var nextProductId = ""
    @State var showNotesEditorSheet = false
    
    @State private var showFloatingChat: Bool = false
    @State private var selectedChatMessage: ChatMessage?
    
    // Surprise Set Auction States
    @State private var selectedSurpriseSetForAuction: ProductSurpriseData?
    @State private var showSurpriseAuctionSheet: Bool = false
    
    @State private var showWinnerOnParent = false
    @State private var randomWinner: String = ""
    @State private var randomWinnerImage: String = ""
    
    @State private var showFreeBie : Bool = false
    
    @State private var selectedFreebie = ProductDataModel1()
    @State private var UsersList: [FreebieUser] = []
    @State private var selectedUsersId: [Int] = []
    @State var productCount = 0
    @State private var hasInitialized = false
    @State private var isNavigatingToEdit = false
    @State private var shouldPreventReload = false
    
    @State private var sudden_Death = false
    
    // Surprise Set Auction Tracking States
    @State private var currentSurpriseSetData: ProductSurpriseData?
    @State private var surpriseSetBidTime: Int = 0
    @State private var isSurpriseSetAuctionActive: Bool = false
    
    @StateObject private var viewModelFreebie = RandomizerViewModel()
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                videoLayer(geometry)
                topHeader
                readyAndWelcomeOverlays
                sideControls(geometry)
                chatAndBottomControls
                navigationLinks
                floatingOverlays
                
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
            contentBackgroundColor: Color(.systemGroupedBackground),
            topBarBackgroundColor: Color(.systemGroupedBackground),
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
//                        guard Reachability.isConnectedToNetwork() else {
//                            hudMsg = "No Internet Connection"
//                            showhud = true
//                            return
//                        }
//                        showProductSheet = false
//                        print("product ID is :\(selectedID)")
//                        print("Live Room ID is :\(self.roomId)")
//                        UpdateStatus(status: false, selectedID: selectedID)
                    },
                    initialSelectedProductId: initialSelectedProductId
                )
            }
        )
        
        .sheet(isPresented: $navigateToRandomizer) {
            RandomizerView(roomId : $roomId ,didTapSpin : { value in
                showSpin = value
               
            },didSpinWheel:{
                socketManager.finalizeFreebie(room_id: self.roomId)
            },onWinnerSelected: { winner in
                randomWinner = winner.name ?? ""
                
                
                randomWinnerImage = winner.profile_image ?? ""
                navigateToRandomizer = false
                showWinnerOnParent = true
                showSpin = false
            }, didTapAddManual: {
                navigateToRandomizer = false
                showUserSheet = true
            },didTapRemove:{ index in
                socketManager.removeFreebieuser(room_id: roomId, user_id : "\(wheelTitles[index].id ?? 0)")
                wheelTitles.remove(at: index)
            },usersName: $viewModelFreebie.options, userList:$wheelTitles)
            .presentationDetents([.fraction(showSpin ? 0.90 : 0.55)])
                .presentationCornerRadius(25)
                .presentationDragIndicator(.hidden)
                .presentationBackground(Color.black.opacity(0.1))
//                .interactiveDismissDisabled()
        }
       
 
        .sheet(isPresented: $showPollSheet) {
            CreatePollScreen(
                isPresented: $showPollSheet,
                onCreatePoll: { pollModel in
                    print(pollModel)
                    SocketManagerService.shared.createPoll(poll: pollModel)
                },
                roomId: self.roomId,
                errorMessageClosure: { msg in
                    hudMsg = msg
                    showhudAlert = true
                }
            )
            .presentationDetents([.fraction(0.70)])   // ✅ Bottom-sheet height
            .presentationCornerRadius(25)              // ✅ Rounded top corners
            .presentationDragIndicator(.hidden)        // optional
        }
        

        .sheet(isPresented: $showLivePollScreen) {
            if let poll = currentPollModel {
                LivePollHostView(poll: poll,onEndPoll: { pollId,roomId in
                    socketManager.endPoll(pollId: "\(pollId)", roomId: roomId)
                    showPollCard = false
                    showLivePollScreen = false
                },onCancel:{
                    showLivePollScreen = false
                })
                .presentationDetents([.fraction(0.80)])   // ✅ Bottom-sheet height
                .presentationCornerRadius(24)              // ✅ Rounded top corners
                .presentationDragIndicator(.hidden)
            }
                  // optional
        }
        
        .sheet(isPresented: $showNotesEditorSheet) {
            
                RichTextEditorSheet(
                    onSave: { attributedText in
                        let richText = attributedText.toHTML().htmlToString
                        showNotes = richText
                        socketManager.sendAddShowNote(roomId: self.roomId, showNote: richText)
                        showNotesEditorSheet = false
                    },
                    onCancel: {
                        showNotesEditorSheet = false
                    }
                )
                .presentationDetents([.fraction(0.50)])
                .presentationCornerRadius(25)
                .presentationDragIndicator(.hidden)
            }
        
        .sheet(isPresented: $showNotesSheet) {
            ShowNotesSheet(
                noteText:$showNotes ,
                forHost : .constant(true),
                onPost: { note in
                    showNotes.removeAll()
                    showNotes += note
                    print("Posted note: \(note)")
                    showNotesSheet = false
                    socketManager.sendAddShowNote(roomId: self.roomId,
                                                  showNote: showNotes)
                },didTapCancel: {
                    showNotesSheet = false
                }
            )
            .presentationDetents([.fraction(0.80)])
            .presentationCornerRadius(25)
            .presentationDragIndicator(.hidden)
        }
        .bottomSheet(
            isPresented: $showShopSheet,
            height: screenHeight * 0.85,
            topBarCornerRadius: 20,
            contentBackgroundColor: .backGround,
            topBarBackgroundColor: .backGround,
            showTopIndicator: false,
            onDismiss: {
                showShopSheet = false
            },
            content: {
                shopSheetContent
                
            })
        .sheet(isPresented: $showFreeBie){
            freeBieSheetContent
                .presentationDetents([.fraction(0.70)])   // ✅ Bottom-sheet height
                .presentationCornerRadius(25)              // ✅ Rounded top corners
                .presentationDragIndicator(.hidden)
            
        }

        .sheet(isPresented: $showAuctionSheet) {
            AuctionSettingsSheet(
                startingBid:auctionedProductData.pricing ?? "",
                onTapCancel: {
                    showAuctionSheet = false
                },
                onStartAuction: { bid, reqTime, counterTime, suddenDeath in
                    showAuctionSheet = false
                    showShopSheet = false
                    hasAuctionStarted = true

                    socketManager.startAuction(
                        roomId: roomId,
                        products: [nextProductId],
                        startingBidAmount: bid,
                        requireTime: reqTime,
                        counterBidTime: counterTime,
                        suddenDeath: suddenDeath,auctionTypeId:self.auctionTypeId
                    )
                },
                onShowToast: { message in
                           hudMsg = message
                    showhudAlert = true
                       },
            )
            .presentationDetents([.fraction(0.70)])   // ✅ Bottom-sheet height
            .presentationCornerRadius(25)              // ✅ Rounded top corners
            .presentationDragIndicator(.hidden)        // optional
        }
        
        // Surprise Set Auction Sheet
        .sheet(isPresented: $showSurpriseAuctionSheet) {
            if let surpriseSet = selectedSurpriseSetForAuction {
                AuctionSettingsSheet(
                    startingBid: "\(surpriseSet.price ?? 0)",
                    onTapCancel: {
                        showSurpriseAuctionSheet = false
                        selectedSurpriseSetForAuction = nil
                    },
                    onStartAuction: { bid, reqTime, counterTime, suddenDeath in
                        showSurpriseAuctionSheet = false
                        showShopSheet = false
                        hasAuctionStarted = true
                        
                        // Store the surprise set data for UI display
                        currentSurpriseSetData = surpriseSet
                        
                        // Get first available item and unit
                        let firstItem = surpriseSet.items?.first
                        let firstAvailableUnit = firstItem?.units?.first(where: { $0.status != "sold" }) ?? firstItem?.units?.first
                        
                        socketManager.startAuctionBreakSpot(
                            roomId: roomId,
                            productSetId: surpriseSet.id,
                            productSetItemId: firstItem?.id ?? 0,
                            productSetItemUnitId: firstAvailableUnit?.id ?? 0,
                            startingBidAmount: Double(bid) ?? 0,
                            requireTime: reqTime,
                            counterBidTime: counterTime,
                            suddenDeath: suddenDeath
                        )
                        
                        selectedSurpriseSetForAuction = nil
                    },
                    onShowToast: { message in
                        hudMsg = message
                        showhudAlert = true
                    }
                )
                .presentationDetents([.fraction(0.70)])
                .presentationCornerRadius(25)
                .presentationDragIndicator(.hidden)
            }
        }
        
        .bottomSheet(
            isPresented: $showSellSheet,
            height: sheetHeight, // Adjust as needed
            topBarCornerRadius: 20,
            contentBackgroundColor: .backGround,
            topBarBackgroundColor: .backGround,
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
                        onTipSettings: {
                            print("Tip Settings")
                            showTipSetting = true
                            showSellSheet  = false
                        },
                        onMulticast: { print("Multicast") },
                        onAddCoupons: { print("Add Coupons") },
                        onClickRandomizer:  {
                            showSellSheet = false
                            navigateToRandomizer = true
                        },
                        onRaid: {
                            print("Raid")
                            showRaidSheet = true
                            showSellSheet = false
//                            SellerScreen(
//                                sellers: $sellers,
//                                selectedSellerID: $selectedSellers,
//                                onRaidCreated: { selectedSellers in
//                                    // Handle the selected sellers when raid is created
//                                    print("Raid created with sellers: \(String(describing: selectedSellers))")
//                                    handleRaid(selectedSeller: selectedSellers)
//                                },onCancel: {
//                                    showRaidSheet = false
//                                    selectedSellers = nil
//                                }
//                            )
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
                                socketManager.AllowBidForAll(roomId: roomId, allow_bid_for_all: allowBidForAll)
                                print("✅ allowBidForAll updated to \(allowBidForAll) for room: \(liveRoomId)")
                            }
                        }
                    )
                case .promote:
                    PromoteShowSheet(
                        boosts: $boosts,
                        onPromotionSelected: { selectedBoost in
                            handleBoostClick(selectedBoost)
                            handleBoostClick(selectedBoost)
                        },
                        onClose: { showSellSheet = false }
                    )
                case .clip:
                    CreateClipBottomSheetView(
                        isPresented: $showSellSheet,
                        videoURL: URL(string: clipURL)!,
                        onCreateClip: { start, end in
                            print("Clip range: \(start.seconds) to \(end.seconds)")
                        },onEditClip: {
                            //                            showEditClip = true
                            print("🚀 Starting navigation to edit screen")
                            
                            // ✅ Set BOTH flags
                            isNavigatingToEdit = true
                            shouldPreventReload = true
                            
                            showSellSheet = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                showEditClip = true
                            }
                            
                        }
                    )
                case .share:
//                    ShareShowBottomSheetView(
//                        isPresented: $showSellSheet,
//                        showTitle: "John's Live Show",
//                        username: "johnsmith",
//                        showImage: Image("icWatch"),
//                        message: "Live auction starting in 5 minutes! Don’t miss out on exclusive items.",
//                        onShare: { platform in
//                            print("Shared to \(platform)")
//                        }
//
//                    )
                    
                    DynamicShareBottomSheetView(
                            isPresented: $showSellSheet,
                            contentType: .show(
                                title: showsData.title ?? "Live Show",
                                username: UserDefaults.userName,
                                imageURL: showsData.thumbnail?.first ?? "",
                                isLive: isLive,
                                message: "Join my live auction! Don't miss out."
                            ),
                            messageList: messageList,
                            onSendToChat: { chat, message in
                                // Handle chat opening
                                handleOpenChat(with: chat)
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
                            if freebieActive{
                           
                                alertType = .sheetType(
                                    icon: .info,
                                    title: "Freebie Live",
                                    message: "A freebie is currently running. Ending the show will stop the freebie. Are you sure you want to continue?",
                                    primaryBtnText: "Okay",
                                    secondaryBtnText: "Cancel",
                                    sheetSecondaryColor: .defaultThemeLight,
                                    secondaryTextColor: .defaultTheme,
                                    buttonWidth: screenWidth - 60,
                                    contentSize: 12.0
                                )
                                withAnimation(.snappy){
                                    showSellSheet = false
                                    showFreebieSheet = true
                                }
                            }else{
                                self.endShow()
                                
                                self.isLive = false
                            }
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
        .bottomSheet(isPresented: $showUserSheet, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showUserSheet = false
        }) {
            UserScreenFreeBie(users: $UsersList, selectedSellerID: $selectedUsersId, onSelected: { user in
                let id = user?.id ?? 0
                selectedUsersId.append(id)
                socketManager.enterInFreebie(room_id: self.roomId, userId: id)
            }, onCancel: {
                showUserSheet = false
            })
        }
        
//        .bottomSheet(isPresented: $showTipSetting, height: screenHeight * 0.75, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
//            showTipSetting = false
//            showSellSheet = false
//        }) {
//
//        }
        .sheet(isPresented: $showTipSetting) {
            TipSettingsSheet(
                onSave: { message, showMessages in
                    print("Tip Message: \(message)")
                    print("Show Buyer Tip Messages: \(showMessages)")
                    showTipSetting = false
                    socketManager.saveTipSettings(showId: self.roomId, tipMessage: message, showInLiveChat: showMessages)
                },onCancel: {
                    showTipSetting = false
                }
            )
            .presentationDetents([.fraction(0.70)])   // ✅ Bottom-sheet height
            .presentationCornerRadius(25)              // ✅ Rounded top corners
            .presentationDragIndicator(.hidden)        // optional
        }
        .sheet(isPresented: $showRaidSheet) {
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
            .presentationDetents([.fraction(0.70)])   // ✅ Bottom-sheet height
            .presentationCornerRadius(25)              // ✅ Rounded top corners
            .presentationDragIndicator(.hidden)        // optional
        }
        .overlay(
            Group {
                if let selectedChat = selectedChatMessage {
                    FloatingChatView(
                        isPresented: $showFloatingChat,
                        chat: selectedChat,
                        showURL: generateShowURL()
                    )
                    .zIndex(1000)
                }
            }
        )
        .overlay(
            winnerOverlay
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
        .bottomSheet(isPresented: $showFreebieSheet, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showFreebieSheet = false
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation {
                        showFreebieSheet = false
                        self.endShow()
                        self.isLive = false
                        
                    }
                },
                onSecondaryClick: {
                    withAnimation {
                        showFreebieSheet = false
                        
                    }
                }
            )
        }
        
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
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
            AlertToast(displayMode: .hud, type:.regular, title: hudMsg)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg)
        }
        .toast(isPresenting: $showhudAlert) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg)
        }
//        .onAppear {
//
//            logoutRoom()
//            showTopBadge = true
//            agoraManager.setupLocalVideo()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                if comeFromPrepare && !comeForLive{
//                    showReadyModal = false
//                }else{
//                    showReadyModal = true
//                }
//            }
//        }
        .onChange(of: showEditClip) { newValue in
            print("📊 showEditClip = \(newValue)")
        }

        .onChange(of: shouldPreventReload) { newValue in
            print("📊 shouldPreventReload = \(newValue)")
        }

        .onAppear {
            // ✅ Early exit if returning from edit
            guard !shouldPreventReload else {
                print("🔄 Returned from edit - SKIPPING ALL INITIALIZATION")
                shouldPreventReload = false
                isNavigatingToEdit = false
                return // ⚠️ THIS IS THE KEY - EXIT IMMEDIATELY
            }
            
            // ✅ Only run initialization ONCE
            guard !hasInitialized else {
                print("⚪ Already initialized - skipping")
                return
            }
            
            print("🟢 First time initialization ONLY")
            hasInitialized = true
            
            logoutRoom()
            showTopBadge = true
            agoraManager.setupLocalVideo()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if comeFromPrepare && !comeForLive {
                    showReadyModal = false
                } else {
                    showReadyModal = true
                }
            }
        }
        .onDisappear {
            guard !shouldPreventReload else {
                print("🔄 Just navigating to edit - keeping everything alive")
                return // ⚠️ DON'T RUN endShow()
            }
            
            Task {
                if agoraManager.isJoined {
                    print("❌ Truly leaving - ending show")
                    self.endShow()
                    hasInitialized = false // Reset for next time
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
//            productData.append(mappedProducts)
            categoryName = showsData.category?.name ?? ""
            
            //get agora token -> did not call it on preview screen
//            fetchAgoraToken()
        }
//        .onDisappear {
//            Task {
//                if agoraManager.isJoined {
//                    if !showEditClip{
//                        self.endShow()
//                    }
//                }
//            }
//        }
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
    
//    @ViewBuilder
//    private func videoLayer(_ geometry: GeometryProxy) -> some View {
//        ZStack {
//            if agoraManager.remoteUserId != nil {
//                VideoContainerView(uiView: agoraManager.remoteVideoView)
//            } else {
//                VideoContainerView(uiView: agoraManager.localVideoView)
//            }
//        }
//        .frame(width: geometry.size.width, height: geometry.size.height)
//        .background(Color.black)
//        .ignoresSafeArea()
//    }
    
    @ViewBuilder
    private func videoLayer(_ geometry: GeometryProxy) -> some View {
        ZStack {

            // 🔒 Remote video view (ALWAYS mounted)
            VideoContainerView(uiView: agoraManager.remoteVideoView)
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .opacity(agoraManager.remoteUserId != nil ? 1 : 0)

            // 🔒 Local video view (ALWAYS mounted)
            VideoContainerView(uiView: agoraManager.localVideoView)
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .opacity(agoraManager.remoteUserId == nil ? 1 : 0)

            // ⏳ Waiting overlay
//            if agoraManager.isJoined && agoraManager.remoteUserId == nil {
//                VStack(spacing: 12) {
//                    ProgressView()
//                        .progressViewStyle(
//                            CircularProgressViewStyle(tint: .white)
//                        )
//
//                    Text("Waiting for stream…")
//                        .font(.custom(poppinsRegular, size: 14))
//                        .foregroundColor(.white.opacity(0.7))
//                }
//            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }


    
    @ViewBuilder
    private var shopSheetContent: some View {
        ProductShopRehersalScreen(
            mode: .auction,
            roomId: roomId,
            auctionTypeId: $auctionTypeId,
            productDataFromEvent: $productListData,
            categoryId: "\(showsData.category_id ?? 0)",
            onTapCancel: {
                showShopSheet = false
            },
            onProductSelected: { product in
                auctionedProductData = product
                nextProductId = "\(product.id ?? 0)"
                if self.auctionTypeId == 8{
                    showAuctionSheet = true
                }else{
                    if self.auctionTypeId == 5{
                        showAuctionSheet = false
                        showShopSheet = false
                        hasAuctionStarted = true
                        socketManager.startAuction(
                            roomId: roomId,
                            products: [nextProductId],
                            auctionTypeId:self.auctionTypeId
                        )
                    }
                }
            },onSurpriseSetSelected:{ surprise in
                // Store the surprise set and show auction settings sheet
                selectedSurpriseSetForAuction = surprise
                currentSurpriseSetData = surprise
                showSurpriseAuctionSheet = true
            } ,onSurpriseSetUnitSelected : { surpriseData, bidAmount, requiredTime, counterBidTime, isSuddenDeath in
                // Store the surprise set data for UI display
                currentSurpriseSetData = surpriseData
                
                // Get first available item and unit
                let firstItem = surpriseData.items?.first
                let firstAvailableUnit = firstItem?.units?.first(where: { $0.status != "sold" }) ?? firstItem?.units?.first
                
                socketManager.startAuctionBreakSpot(
                    roomId: roomId,
                    productSetId: surpriseData.id,
                    productSetItemId: firstItem?.id ?? 0,
                    productSetItemUnitId: firstAvailableUnit?.id ?? 0,
                    startingBidAmount: Double(bidAmount) ?? 0,
                    requireTime: requiredTime,
                    counterBidTime: counterBidTime,
                    suddenDeath: isSuddenDeath
                )
                showShopSheet = false
            }
        )
    }
    
    @ViewBuilder
    private var freeBieSheetContent: some View {
        ProductShopRehersalScreen(
            mode: .freebie,
            roomId: roomId,
            auctionTypeId: $auctionTypeId,
            productDataFromEvent: $productListData,
            categoryId: "\(showsData.category_id ?? 0)",
            onTapCancel: {
                showFreeBie = false
            },
            onProductSelected: { product in
                selectedFreebie = product
                freebieActive = true
                socketManager.createFreebie(room_id: self.roomId, productId: "\(product.id ?? 0)", time: 100)
                showFreeBie = false
                navigateToRandomizer = true
            }, onSurpriseSetUnitSelected: { _, _, _, _, _ in
                            // Freebie mode - no action needed for surprise sets
            }
        )
    }
    
    @ViewBuilder
    private var topHeader: some View {
        VStack {
            HStack(spacing: 8) {
                CustomProfileImage(
                    url: UserDefaults.profileURL,
                    isCircular: true
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(UserDefaults.userName.capitalizingFirstLetter())
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.white)

                    Text("Show Time \(socketManager.showTime)")
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.white)
                }

                Spacer()

                viewerCountView
                liveBadge
                closeButton
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            if showButton{
                showNotesButton
            }
            Spacer()
        }
        .padding(.top, 40)
    }
    
    private var viewerCountView: some View {
        HStack(spacing: 4) {
            Image(systemName: "eye.fill")
            Text("\(socketManager.viewerCount)")
                .font(.custom(poppinsSemiBold, size: 13))
        }
        .foregroundColor(.black)
    }

    private var liveBadge: some View {
        Text(isLive ? "Live" : "Rehearsal")
            .font(.custom(poppinsRegular, size: 12))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.defaultTheme)
            .cornerRadius(4)
            .foregroundColor(.white)
    }

    private var closeButton: some View {
        Button {
            if isLive {
                currentBottomSheet = .endShow
                showSellSheet = true
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        } label: {
            Image(.cancel)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.danger)
                .frame(width: 32, height: 32)
        }
    }

//    private var showNotesButton: some View {
//        HStack {
//            Button {
//                showNotesSheet = true
//                isEditingNotes = false
//            } label: {
//                Text("Show\nNotes")
//                    .font(.custom(poppinsSemiBold, size: 13))
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(.black)
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 12)
//                    .background(Color.white)
//                    .cornerRadius(8)
//            }
//            .padding(16)
//
//            Spacer()
//        }
//    }
    @ViewBuilder
    private var showNotesButton: some View {
        if isLive{
            HStack(alignment: .top) {
                
                // MARK: - Show Notes (Leading)
                Button(action: {
                    showNotesSheet = true
                    isEditingNotes = false
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
                Button(action: {
                    showFreeBie = true
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
            .padding(.horizontal, 0)
            .padding(.top, 10)
        }
    }

    @ViewBuilder
    private var readyAndWelcomeOverlays: some View {
        if showReadyModal {
            readyModal
        }

        if showWelcomeDialog {
            welcomeModal
        }
    }

    @ViewBuilder
    private func sideControls(_ geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 4) {
                if showLiveControls {
                    liveSideButtons
                }

                if showPreLiveControls {
                    preLiveSideButtons
                }
            }
            .position(
                x: geometry.size.width - 40,
                y: geometry.size.height / 2
            )
        }
        .zIndex(2)
    }

    @ViewBuilder
    private var chatAndBottomControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer()

            chatMessages
            messageInputAndProductView
            startOrContinueButtons
        }
        .zIndex(1)
        .padding(.bottom,-20)
    }
    @ViewBuilder
    private var messageInputAndProductView: some View {
        if showButton {
            if showLiveControls {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // MARK: - Text Input & Send Button
                    HStack {
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
                            .frame(width: BiddingDetail.products != nil ? screenWidth-45 : screenWidth-90)
                            .cornerRadius(8)
                            .background(
                                Capsule().fill(Color.black.opacity(0.35))
                            )
                            .overlay(
                                Capsule().stroke(Color.white, lineWidth: 1)
                            )
                            
                            Button(action: {
                                hideKeyboard()
                                if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    let userId = UserDefaults.userId
                                    let userName = UserDefaults.userName
                                    let userImage = UserDefaults.profileURL
                                    SocketManagerService.shared.sendChat(roomId: roomId, message: commentText, userId: userId, userName: userName, userImage: userImage)
                                    commentText = ""
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.white)
                                    .padding(10)
                            }
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.2), value: commentText)
                        }
                    }
                    .padding(.leading,16)
                    .padding(.trailing, productData != nil ? 54 : 16)
                    .animation(.easeOut(duration: 0.25), value: keyboardResponder.currentHeight)
                    
                    // MARK: - Poll Card
                    if showPollCard, let poll = currentPollModel {
                        PollPreviewCardView(
                            poll: poll,
                            remainingTime: remainingTimer ?? 0,
                            onPollCardTapped: { showLivePollScreen = true }
                        )
                        .preferredColorScheme(.light)
                        .padding()
                    }
                    
                    // MARK: - Product Details
                    if hasAuctionStarted {
                        // Show Surprise Set View when surprise set auction is active
                        if isSurpriseSetAuctionActive, let surpriseSet = currentSurpriseSetData {
                            CurrentSurpriseSetView(
                                surpriseSet: surpriseSet,
                                currentPrice: $currentPrice,
                                suddenDeath: $sudden_Death,
                                bidTime: $surpriseSetBidTime,
                                userName: $winnerName,
                                userImage: $winnerProfileImage,
                                hasWon: $socketManager.hasWon,
                                sellerId: $sellerId,
                                onTap: {
                                    // Handle tap on surprise set
                                },
                                onTapRunNext: {
                                    // Run next surprise set item
                                    showShopSheet = true
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal, 16)
                        }
                        // Show regular product view for normal auctions
                        else if !isSurpriseSetAuctionActive, auctionedProductData.id != nil {
                            CurrentProductView(
                                product: auctionedProductData,
                                auctionTypeId: $auctionTypeId,
                                currentPrice: $currentPrice,
                                suddenDeath: $sudden_Death,
                                bidTime: $socketManager.bidTime,
                                userName: $winnerName,
                                userImage: $winnerProfileImage,
                                categoryName: $categoryName,
                                hasWon: $socketManager.hasWon,
                                sellerId: $sellerId,
                                onTap: { showItemDetailSheet = true },
                                onTapRunNext: { socketManager.runNextProduct(roomId: roomId) }
                            )
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal, 16)
                        }
                    } else {
                        Text("Awaiting for product...")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.leading, 16)
                            .padding(.trailing, 16)
                    }
                }
                .padding(.bottom, keyboardResponder.currentHeight == 0 ? (tabBarHeight + 20) : 10)
            }
        }
    }
    @ViewBuilder
    private var startOrContinueButtons: some View {
        VStack {
            if showButton {
                if !isLive {
                    Button(action: {
                        fetchAgoraToken()
                        
                    }) {
                        Text("Start Show")
                            .font(.custom(poppinsBold, size: 13))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.defaultTheme)
                            .foregroundColor(.white)
                            .cornerRadius(32)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 28)
                }
            }
            
            
            if comeFromPrepare && !comeForLive {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("Continue")
                        .font(.custom(poppinsBold, size: 13))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme)
                        .foregroundColor(.white)
                        .cornerRadius(32)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
        }
    }


    private var navigationLinks: some View {
        Group {
            CusNavLink(
                doNavigate: $navigateToSeller,
                destination: SellerVerificationScreen()
            )
//            CusNavLink(
//                doNavigate: $showEditClip,
//                destination: EditClipScreen(videoURL: $clipURL) { trimmedVideoURL in
//                    print("Trimmed video:", trimmedVideoURL)
//
//                }
//            )
            
            NavigationLink(
                        destination: EditClipScreen(videoURL: $clipURL) { trimmedVideoURL in
                            print("✅ Video trimmed successfully:", trimmedVideoURL)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showEditClip = false
                            }
                        }
                        .navigationBarHidden(true),
                        isActive: $showEditClip,
                        label: { EmptyView() }
                    )
            
        }
    }

    private var floatingOverlays: some View {
        Group {
            if let selectedChat = selectedChatMessage {
                FloatingChatView(
                    isPresented: $showFloatingChat,
                    chat: selectedChat,
                    showURL: generateShowURL()
                )
                .zIndex(1000)
            }

            winnerOverlay
        }
    }
    @ViewBuilder
    private var readyModal: some View {
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
                    .cornerRadius(32)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.95))
        .cornerRadius(12)
        .frame(width: 300)
    }

    
    @ViewBuilder
    private var welcomeModal: some View {
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
                if UserDefaults.sellerVerafied == "verified" {
                    showButton = true
                    showPreLiveControls = true
                } else {
                    alertType = .sheetType(
                        icon: .info,
                        title: "Become a Verified Seller!",
                        message: "Before you interact with live shows.you need to become a verified seller.",
                        primaryBtnText: "OK",
                        secondaryBtnText: "",
                        buttonWidth: screenWidth - 60,
                        contentSize: 12.0
                    )
                    withAnimation(.snappy){
                        showSellerSheet = true
                    }
                }
            }) {
                Text("Okay")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.defaultTheme)
                    .cornerRadius(32)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.gray.opacity(0.95))
        .cornerRadius(12)
    }

    @ViewBuilder
    private var liveSideButtons: some View {
        VStack(spacing: 4) {
            SideButton(label: "More", icon: .more, action: .more)
            SideButton(label: "Promote", icon: .rPromote , action: .promote)
            SideButton(label: "Clip", icon: .clip, action: .clip)
            SideButton(label: "Share", icon: .sharee, action: .share)
            SideButton(label: "Switch", icon: .camera, action: .switchView)
            
            VStack {
                if hasAuctionStarted, let product = currentProduct, let img = product.images?.first {
                    StackedImageView(imageURL: img, totalCount: productCount) {
                        showShopSheet = true
                    }
                } else {
                    StackedImageView(imageURL: productData.first?.images?.first ?? "", totalCount: productCount) {
                        showShopSheet = true
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var preLiveSideButtons: some View {
        VStack {
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
                        .font(.custom(poppinsRegular, size: 8))
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
                        .font(.custom(poppinsRegular, size: 8))
                        .foregroundColor(.white)
                }
                .padding()
            }
            
            VStack {
                if let product = currentProduct, let img = product.images?.first {
                    StackedImageView(imageURL: img, totalCount: productData.count) {}
                }
            }
            Spacer()
        }
    }
    @ViewBuilder
    private var chatMessages: some View {
        if socketManager.chats.count > 0 {
            HStack {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            Spacer(minLength: 0)
                            LazyVStack(alignment: .leading, spacing: 6) {
                                ForEach(socketManager.chats) { comment in
                                    let isHost = comment.userId == "\(UserDefaults.userId)"
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
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .frame(
                        width: screenWidth - 54,
                        height: socketManager.chats.count == 0
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
    }



    private func handleOpenChat(with chat: ChatMessage) {
        print("📱 Opening chat with: \(chat.users.receiverName)")
        
        // Close share sheet
        showSellSheet = false
        
        // Set selected chat
        selectedChatMessage = chat
        
        // Open floating chat with animation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showFloatingChat = true
            }
        }
    }
    private func sendURLDirectly(to chat: ChatMessage) {
        // Determine other user details
        let isReceiver = chat.users.receiverId != "\(UserDefaults.userId)"
        let otherUserId = isReceiver ? chat.users.receiverId : chat.users.senderId
        let otherUserName = isReceiver ? chat.users.receiverName : chat.users.senderName
        let otherUserImage = isReceiver ? chat.users.receiverImage : chat.users.senderImage
        
        // Create temporary ChatViewModel
        let chatViewModel = ChatViewModel(
            currentUserId: "\(UserDefaults.userId)",
            currentUserName: UserDefaults.userName,
            currentUserImage: UserDefaults.profileURL,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserImage: otherUserImage
        )
        
        // Send URL
        let showURL = generateShowURL()
        chatViewModel.messageText = "Check out this live show: \(showURL)"
        chatViewModel.sendMessage()
        
        // Show success
        hudMsg = "Show link sent to \(otherUserName)"
        showhudSuccess = true
        
        // Close sheet
        showSellSheet = false
    }
    
    private func generateShowURL() -> String {
            let currentRoomID = self.roomId
        let url = "https://www.backend.bidcast.betaplanets.com/live-show?roomid=\(currentRoomID)"
       
            return url
        }
    func fetchLatestProductList(){
        
        print("DEBUG: fetchLatestProductList with roomId = \(self.roomId)")
        print("DEBUG: initialSelectedProductId= \(initialSelectedProductId)")
        initialSelectedProductId = "\(productData.first?.id ?? 0)"
        if !socketManager.hasWon{
            currentPrice = Double(productData.first?.pricing ?? "") ?? 0.0
        }
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
        
        let roomId = "live_room_\(userId)_\(showId)"
        self.roomId = roomId
        print("🎬 Preparing live stream room: \(roomId)")
        
        DispatchQueue.global(qos: .userInitiated).async {
//            let products = self.makeProductList(from: data.products, selectedID: selectedID)
//            guard !products.isEmpty else {
//                DispatchQueue.main.async {
//                    self.showhudMessage("Unable to start streaming — product category is missing.")
//                }
//                return
//            }
            
            // STEP 3: Join Agora Channel — runs best on background thread
            self.joinAgoraChannelIfNeeded()
            self.categoryid = "\(data.category?.id ?? 0)"
            // STEP 4: Prepare seller data (light, can stay background)
            self.auctionTypeId = data.auction?.id ?? 0
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
                products: data.product_ids,
                seller: seller,
                thumbnail: data.thumbnail?.first ?? "",
                time: data.time ?? "",
                date: data.date ?? "",
                allowBidForAll: true,
                showTimer: "",auctionTypeId: data.auction?.id ?? 0
            )
            sellerId = "\(UserDefaults.userId)"
            // STEP 6: Socket setup in background
            self.setupLiveSocketListeners(for: roomId,showId: showId)
            
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
    //MARK: - Socket listener -
    private func setupLiveSocketListeners(for roomId: String,showId: Int = 0) {
        print("🔌 Setting up socket listeners for \(roomId)")
        
        SocketManagerService.shared.observeRoomUpdates { newRoom in
            print("🏠 Room updated: \(newRoom.room_id ?? "unknown")")
            productCount = newRoom.productCount ?? 0
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
        
        socketManager.listenForNextProduct {roomId, _ in
            self.fetchProducts(for: roomId)
        }
        
        socketManager.listenForHighestBid(forRoom: roomId) { highestBid in
            self.updateHighestBid(bid: highestBid)
        }
        
        socketManager.listenForGetShowNote { notes in
            self.showNotes = notes
        }
        
        socketManager.listenForFreebieWinner{ userId in
         freebieActive = false
        }
        
        socketManager.listenForFreebie{ freebie,user in
            let roomID = freebie.room_id ?? ""
            guard self.roomId == roomID else{
                return
            }
            usersCount = user.count
            self.wheelTitles = user
            let title = user.map { $0.name ?? ""}
            self.viewModelFreebie.options.removeAll()
            viewModelFreebie.options.append(contentsOf: title)
            print("Freebie user data \(wheelTitles) for showId : \(showId)")
        }
       
        socketManager.listenForBidTimer(roomId: roomId)
        socketManager.listenForChat(roomId: roomId)
        socketManager.listenForViewerCount()
        socketManager.listenForShowTimer(roomId: roomId)
        // Bid finalized listener
        SocketManagerService.shared.listenForBidFinalized { roomId, productId, winner in
            handleBidFinalized(for: roomId, winner: winner)
        }
        socketManager.observePollVoteUpdate { pollModel in
            guard pollModel.roomId == self.roomId else { return }
            print(pollModel)
            self.remainingTimer = timerStringToSeconds(pollModel.remainingTime)
            self.currentPollModel = pollModel
            if pollModel.isActive{
                showPollCard = true
            }else{
                showPollCard = false
            }
        }
        socketManager.listenForAuctionStarted { status,roomId,products,startingBidAmount,requireTime,counterBidTime,suddenDeath in
//            guard let self else { return }
            print("AUCtioned data")
            print("\(roomId)")
            print("\(products)")
            print("\(startingBidAmount)")
            print("\(requireTime)")
            print("\(counterBidTime)")
            print("\(suddenDeath)")
            if status != "sold"{
                
                self.updateProducts(
                    for: roomId,
                    products: products,
                    startingBidAmount: Double(startingBidAmount) ?? 0.0,
                    requireTime: requireTime,
                    counterBidTime: counterBidTime,
                    suddenDeath: suddenDeath
                )
                
                // 🔥 unlock product details for this room
//                self.auctionStartedRooms.insert(roomId)
//            }else{
//                self.auctionStartedRooms.remove(roomId)
            }
        }
        socketManager.listenForAuctionNextProduct { roomId, product,source in
            print("====get next product for auctioned====")
            print("Room Id :- \(roomId)")
            print("Product :- \(product)")
            guard self.roomId ==  roomId else{
                return
            }
//            auctionedProductData = product.first ?? ProductDataModel1()
            nextProductId = "\(product.id ?? 0)"
           
            if self.auctionTypeId == 8{
                socketManager.startAuction(
                    roomId: roomId,
                    products: [nextProductId],auctionTypeId:self.auctionTypeId
                )
                showAuctionSheet = false
                showShopSheet = false
                hasAuctionStarted = true
            }else{
                showAuctionSheet = true
            }
        }
        socketManager.listenForRunNextProductError { roomID , message in
            print("No Pinned products found for \(roomID)")
            guard self.roomId ==  roomId else{
                return
            }
            showShopSheet = true
        }
        
        socketManager.listenForUserJoinedShows{ data , users in
            self.UsersList = users
            
        }
        FirebaseManager.shared.fetchMessageList(forUserId: "\(UserDefaults.userId)") { messages in
            DispatchQueue.main.async {
                self.messageList = messages
            }
        }
        
        // MARK: - Break Spot Listeners
        socketManager.listenForAuctionStartedBreakSpot { response , status, roomID, productSetId, productSetItemId, productSetItemUnitId, startingBidAmount, requireTime, counterBidTime, suddenDeath in
            guard self.roomId == roomID else { return }
            print("🎁 Surprise Set Auction Started - Set: \(productSetId), Item: \(productSetItemId), Unit: \(productSetItemUnitId)")
            
            DispatchQueue.main.async {
                self.isSurpriseSetAuctionActive = true
                self.hasAuctionStarted = true
                self.currentPrice = Double(startingBidAmount) ?? 0.0
                self.sudden_Death = suddenDeath
            }
        }
        
        socketManager.listenForBidTimerUpdateBreakSpot(roomId: roomId) { remaining in
            DispatchQueue.main.async {
                self.surpriseSetBidTime = remaining
                self.socketManager.bidTime = self.socketManager.formatElapsedTime(seconds: remaining)
            }
        }
        
        socketManager.listenForAuctionEndedBreakSpot { roomID, productSetId, productSetItemId, productSetItemUnitId, message in
            guard self.roomId == roomID else { return }
            print("🏁 Surprise Set Auction Ended - Set: \(productSetId), Message: \(message ?? "N/A")")
            
            DispatchQueue.main.async {
                self.isSurpriseSetAuctionActive = false
            }
        }
        
        socketManager.listenForBidFinalizedBreakSpot { roomID, productSetId, productSetItemId, productSetItemUnitId, winner in
            guard self.roomId == roomID else { return }
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
                        self.randomWinner = self.winnerName.capitalizingFirstLetter()
                        self.randomWinnerImage = self.winnerProfileImage
                    }
                }
            }
        }
        
        socketManager.listenForAuctionOrderFailed { roomID, productSetId, productSetItemId, errorMessage, errorCode in
            guard self.roomId == roomID else { return }
            print("❌ Surprise Set Order Failed - \(errorMessage ?? "Unknown error")")
            
            DispatchQueue.main.async {
                self.hudMsg = errorMessage ?? "Order failed"
                self.showhudAlert = true
                self.isSurpriseSetAuctionActive = false
            }
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
        guard self.roomId == roomId else { return }
        self.auctionedProductData = products.first ?? ProductDataModel1()
        
        if startingBidAmount == 0.0{
            let price = Double(products.first?.pricing ?? "") ?? 0.0
            currentPrice = price
        }else{
            currentPrice = startingBidAmount
        }
       sudden_Death = suddenDeath
        print("🟢 Products updated for room:", roomId)
    }
    private func handleBidFinalized(for roomId: String, winner: HighestBid?) {
        fetchProducts(for: roomId)
        
        let name = winner?.user_name ?? ""
        let id = Int(winner?.user_id ?? "") ?? 0
        let image = winner?.user_image ?? ""
        let amount = winner?.bid_amount ?? ""
        
        print("🏁 Bid finalized - Winner: \(name), Amount: \(amount)")
//        auctionedProductData = nil
        winnerName = name
        winnerProfileID = id
        winnerProfileImage = image
        winnerAmount = amount
        currentPrice = Double(winnerAmount) ?? 0.0
        if !winnerName.isEmpty{
            showWinnerOnParent = true
            randomWinner = winnerName.capitalizingFirstLetter()
            randomWinnerImage = winnerProfileImage
            
            let message = "We have a winner! \(winnerName)"
            
            SocketManagerService.shared.sendChat(
                roomId: roomId,
                message: message,
                userId: id,
                userName: name,
                userImage: image
            )
        }
    }
    
    private func handleCountdownCompletion() {
        fetchProducts(for: roomId)
        currentBottomSheet = .shop
//        showShopSheet = true
//        navigateToProductList = true
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
//            let currentProducts = productData.filter { $0.isCurrent }
            let currentProducts = productData.first
            if !socketManager.hasWon{
                self.currentPrice = Double(currentProducts?.pricing ?? "") ?? 0.0
            }
            self.productId = currentProducts?.id ?? 0
            print("after product \(productData)")
        }
    }
    
    func endShow1(){
        Task{
          
            //            if agoraManager.isJoined {
            agoraManager.leaveChannel()
            //            }
            SocketManagerService.shared.endStreaming(roomId: self.roomId)
            SocketManagerService.shared.stopLiveScheduler()
            
            //clear chats and remove listener
            SocketManagerService.shared.removeChatListener()
            self.comments.removeAll()
            SocketManagerService.shared.chats.removeAll()
            initialSelectedProductId = ""
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
            
            
        }
    }
    
    func sendCreateRoomEvent(
        showId: String,
        roomId: String,
        products: [String]?,
        seller: SellerModel,
        thumbnail: String,
        time: String,
        date: String,
        allowBidForAll: Bool,
        showTimer:String,
        auctionTypeId : Int = -1
    ) {
        
//        let productPayload = products.map { product in
//            [
//                "category": product.category,
//                "id": product.id,
//                "image": product.image,
//                "name": product.name,
//                "price": product.price,
//                "status": product.status,
//                "is_current": product.isCurrent,
//                "quantity": product.quantity
//            ] as [String : Any]
//        }
        
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
            "products": products,
            "seller": sellerPayload,
            "thumbnail": thumbnail,
            "time": timestamp,
            "date": date,
            "allow_bid_for_all": allowBidForAll,
            "viewer_count": "",
            "is_live": true,
            "show_detail": "Live auction room created via Rehearsal",
            "show_timer":showTimer,
            "category_id":categoryid,
            "auction_type_id":auctionTypeId
        ]
        guard auctionTypeId != -1 else{
           
            hudMsg = "Auction Type missing"
            showhud = true
            return
        }
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
                agoraManager.switchCamera()
            } else  if action == .clip {
                if socketManager.hasHit60SecAPI{
                    Task{
                        SVProgressHUD.show()
                        let request = ClipRequest(room_id: self.roomId)
                        viewModel.errorMessage?.removeAll()
                        clipModel = ClipModel()
                        await viewModel.makeClip(param: request)
                        await SVProgressHUD.dismiss()
                        if let msg = viewModel.errorMessage{
                           
                            alertType = .sheetType(
                                icon: .alert,
                                title: "Failed",
                                message: msg,
                                primaryBtnText: "",
                                secondaryBtnText: AppString.ok.localized
                            )
                            showError = true
                        }else{
                            let response = viewModel.clipResponse
                            if response?.status == "success"{
                                clipURL = response?.data?.clipURL ?? ""
                                clipModel = response?.data ?? ClipModel()
                                if !clipURL.isEmpty{
                                    currentBottomSheet = action
                                    showSellSheet = true
                                }
                            }
                        }
                    }
                }else{
                  
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Failed",
                        message: "Clip generation failed, minimum 60 sec required.",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
               
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
            showhudSuccess = false
            print("channelName: \(channelName), uid: \(uId), token: \(agoraToken)")
            if UserDefaults.sellerVerafied == "verified" {
                Task { UpdateStatus(status: false) }
            } else {
                showSellerSheet = true
            }
        } else {
            hudMsg = response?.message ?? ""
            showhud = true
        }
    }
    
    private func successPromoteShow() {
        let response = viewModel.storePromoteShowModel
        if response?.status == "success" {
            hudMsg = "Show promoted successfully."
            showhudSuccess = true
            socketManager.sendPromotionEvent(userId: "\(response?.data?.userID ?? 0)", showId: "\(response?.data?.id ?? 0)", promoteShowId: "\(response?.data?.promoteShowID ?? 0)")
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
