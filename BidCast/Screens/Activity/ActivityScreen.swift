//
//  ActivityScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct ActivityScreen: View {
    
    @State private var showError: Bool = false
    @State private var isLoading: Bool = true
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var selectedRoomId: String = ""
    @StateObject var viewModel = OffersViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var offerList: [OfferListModel] = []
    @State var purchaseOrderList: [PurchasedOrderModel] = []
    @State var currentPage = 1
    @State var messageList: [ChatMessage] = []
    @State private var chatVM: ChatModel?
    @State private var selectedUserId: String? = nil
    @State private var selectedUserName: String? = nil
    @State private var selectedUserImage: String? = nil
    @State private var isNavigatingToChat = false
    @State private var chatPath: String = ""
    @StateObject private var blockedViewModel = BlockedUserListViewModel()
    @State private var blockedMe: [BlockedByUserList] = []
    @State private var blockedByMe: [BlockedByUserList] = []
    @State var blockedSheet: Bool = false
    @State var blockedBySheet: Bool = false
    @State var navigateToBlockedList : Bool = false
    @State var showToast = false
    @State var toastMessage = ""
    @State var blockUserName = ""
    @State var blockUserImage = ""
    @State var productId : Int = 0
    @State var productViewModel = ProductViewModel()
    
    @State private var navigateToUserProfile: Bool = false
    @State private var navigateToOrderTracking: Bool = false
    
    @State private var selectedOrder: PurchasedOrderModel?
    @State private var selectedOrderId: String = ""
    @State private var selectedProductId: String = ""
    @State private var userId: String = ""
    @State private var userImage: String = ""
    @State private var userName: String = ""
    
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var filterArray: [String] = ["All", "In Progress", "Completed"]
    
    @State private var selected: Segment = .message
    @State private var selectedTabIndex: Int = Segment.message.index
    @State private var selectedFilterIdex: Int = 0
    @State var navigateToDetail = false
    
    @State var navigateToNotification = false
    @Environment(\.presentationMode) var presentationMode

    // Trey QA 2026-05-31: inquiry messaging deep-link entry.
    // TabbarScreen posts PushInquiryThread notification → we open the thread.
    // Also exposes an Inquiries tab entry point via navigateToInquiryInbox.
    @State private var navigateToInquiryInbox: Bool = false
    @State private var navigateToInquiryThread: Bool = false
    @State private var deepLinkInquiryThreadId: Int? = nil
    
    @State var sellerInfo : SellerInfoResponse? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing:0) {
                HStack(spacing: 12) {
                    Text("Activity")
//                        .frame(maxWidth: .infinity)
                        .font(.custom(robotoSemiBold, fixedSize: 20))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Spacer()
                    // Trey QA 2026-05-31: Inquiries button in Activity header.
                    Button {
                        navigateToInquiryInbox = true
                    } label: {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 4)
                    HeaderMenuIconView(
                        didTapMenuButton: {
                            navigateToNotification = true
                        },
                        count: .constant(0)
                    )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - Filter Pills
                PillsSelectorView(
                    titles:  Segment.segmentArray,
                    selectedIndex: $selectedTabIndex,
                    backgroundStyle: .none,
                    underlineEnabled: false,
                    onSelectionChanged: { index, data in
                        selected = Segment.segment(at: index) ?? .message
                    }
                )
                .padding(.horizontal, 12)
                .padding(.top, 10)
                
                if selected == .purchases {
                    ScrollView(.horizontal, showsIndicators: false) {
                        PillsSelectorView(
                            titles:  filterArray,
                            selectedIndex: $selectedFilterIdex,
                            backgroundStyle: .pill,
                            underlineEnabled: false,
                            onSelectionChanged: { index, data in
                                Task {
                                    await fetchData(for: .purchases)
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
            }
            .background(.white)
            
            ScrollView(showsIndicators: false){
                VStack(spacing: 8) {
                    
                    switch selected {
                    case .message:
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if messageList.isEmpty {
                            NoDataView(message: "No message Found")
                        } else {
//                            ForEach(messageList) { message in
//                                MessageCell(message: message, currentUserId: String(UserDefaults.userId))
//                                    .padding(.all , 6)
//                                    .onTapGesture {
//                                        prepareChatNavigation(for: message)
//                                    }
//                            }
                            ForEach(messageList) { message in
                                MessageRow(
                                    message: message,
                                    currentUserId: String(UserDefaults.userId),
                                    blockedMe: blockedMe,
                                    blockedByMe: blockedByMe,
                                    onBlockedByMe: {
                                        blockedSheet = true
                                    },
                                    onBlockedMe: {
                                        blockUserName = message.users.senderId == String(UserDefaults.userId) ? message.users.receiverName : message.users.senderName
                                        blockUserImage = message.users.senderId == String(UserDefaults.userId) ? message.users.receiverImage : message.users.senderImage
                                        blockedBySheet = true
                                    },
                                    onAllowed: {
                                        prepareChatNavigation(for: message)
                                    }
                                )
                            }

                        }
                        
                    case .bid:
                        if offerList.isEmpty {
                            // Basecamp #9922137463 (Trey 2026-05-20): tell the user this tab shows
                            // INCOMING bids on their items so they know to look here. Old empty
                            // state "No bids Found" was ambiguous (bids placed? bids received?).
                            NoDataView(message: "No bids on your items yet.\nWhen buyers bid on your products, they'll show up here.")
                        } else {
                            ForEach(offerList.indices, id: \.self) { i in
                                let offer = offerList[i]
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Bids",
                                    onDecline: {
                                        handleOfferAction(offer: offer, newStatus: "rejected")
                                    },
                                    onAccept: {
                                        handleOfferAction(offer: offer, newStatus: "accepted")
                                    },
                                    status: offer.status ?? ""
                                )
                                .onAppear {
                                    Task {
                                        await handlePagination(index: i)
                                    }
                                }
                            }
                        }
                    case .offer:
                        TwoVerticalLabelCell(
                            dataModel: OffersValue.allCases,
                            topLabel: { offer in offerCount(for: offer) },
                            bottomLabel: { $0.description.localized }
                        )
                        
                        if offerList.isEmpty {
                            // Basecamp #9922137463 (Trey 2026-05-20): clearer empty-state copy so
                            // users understand this tab shows INCOMING offers on their items.
                            NoDataView(message: "No offers on your items yet.\nWhen buyers make offers on your products, they'll show up here.")
                        } else {
                            ForEach(offerList.indices, id: \.self) { i in
                                let offer = offerList[i]
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Offers",
                                    onDecline: {
                                        handleOfferAction(offer: offer, newStatus: "rejected")
                                    },
                                    onAccept: {
                                        handleOfferAction(offer: offer, newStatus: "accepted")
                                    },
                                    status: offer.status ?? ""
                                )
                                .onAppear {
                                    Task {
                                        await handlePagination(index: i)
                                    }
                                }
                            }
                        }
                        
                    case .purchases:
                        if isLoading {
                            ForEach(0..<8) { _ in
                                PurchasesViewShimmerView()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                        }
                        else if purchaseOrderList.isEmpty {
                            NoDataView(message: "No List Found")
                        }
                        else {
                            ForEach(Array(purchaseOrderList.enumerated()), id: \.element.id) { i, txn in
                                let offer = purchaseOrderList[i]
                                PurchasesViewScreen(
                                    purchaseList: offer,
                                    onTapOrderTracking: { order in
                                        // MC cmpex02ro/cmpfposve/cmpgie0de (Larry 2026-05-22 15:27 EDT):
                                        // Reverts the Karyashala-side Tenali fix (092a6f9c) for
                                        // cmpgie0de008r1nxy8xpjceq0 — the Bluestone-US side wants
                                        // a purchase tile to open the **Order Details / Order
                                        // Tracking** screen (with Item Title, Cost, Taxes,
                                        // Shipping, Total rows added in cmpex02ro + the row-
                                        // reorder from cmpfposve), and only then let the user
                                        // tap the product row inside Order Details to drill
                                        // into ProductDetailView. Saved Items branch below
                                        // keeps its current Product-Detail target since that's
                                        // a save-for-later flow, not a purchase flow.
                                        selectedOrder = order
                                        selectedOrderId = selectedOrder?.orderID ?? ""
                                        selectedProductId = "\(selectedOrder?.productID ?? 0)"
                                        navigateToOrderTracking = true
                                    },onTapUserProfile: { userId, userImage, userName in
                                        self.userId = userId
                                        self.userImage = userImage
                                        self.userName = userName
                                        navigateToUserProfile = true
                                    }
                                )
                                .padding(.horizontal,8)
                                .padding(.vertical, 8)
                                .onAppear {
                                        Task {
                                            await handlePurchasePagination(index: i)
                                        }
                                    }
//                                .background(Color.gray.opacity(0.1))
                            }
                        }
                        
                    case .savedItems:
                        if isLoading {
                            ForEach(0..<8) { _ in
                                PurchasesViewShimmerView()
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                        }
                        else if purchaseOrderList.isEmpty {
                            NoDataView(message: "No List Found")
                        }
                        else {
                            ForEach(Array(purchaseOrderList.enumerated()), id: \.element.id) { i, txn in
                                let offer = purchaseOrderList[i]
                                SavedViewScreen(
                                    purchaseList: offer,
                                    onTapOrderTracking: { order in
                                        productId = order?.product?.id ?? 0
                                        navigateToDetail = true
                                    },onTapUserProfile: { userId, userImage, userName in
//                                        self.userId = userId
//                                        self.userImage = userImage
//                                        self.userName = userName
//                                        navigateToUserProfile = true
                                    }
                                )
                                .padding(.horizontal,8)
                                .padding(.vertical, 8)
//                                .background(Color.gray.opacity(0.1))
                            }
                        }
//
                    }
                }
            }
            .padding(.top,4)
            .edgesIgnoringSafeArea(.bottom)
            .padding(.bottom,-40)
            .padding(.horizontal, 8)
            
            if let chatVM = chatVM {
                CusNavLink(
                    doNavigate: $isNavigatingToChat,
                    destination: ChatScreen(viewModel: chatVM)
                )
            }
            CusNavLink(doNavigate: $navigateToDetail, destination: ProductDetailView(productID: $productId, sellerInfo: $sellerInfo))
            CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())
            // Trey QA 2026-05-31: inquiry deep-link navigation targets
            CusNavLink(doNavigate: $navigateToInquiryInbox,
                       destination: InquiryInboxView())
            if let tid = deepLinkInquiryThreadId {
                CusNavLink(
                    doNavigate: $navigateToInquiryThread,
                    destination: InquiryThreadView(
                        threadId: tid,
                        otherUserName: "Seller",
                        subject: nil
                    )
                )
            }
            CusNavLink(doNavigate: $navigateToBlockedList, destination: BlockedUserScreen())
            CusNavLink(doNavigate: $navigateToUserProfile,
                       destination: ProfileScreen(id:$userId,
                                                  isComeFrom: .constant(""),
                                                  userName: $userName,
                                                  userImage: $userImage))
            CusNavLink(
                doNavigate: $navigateToOrderTracking,
                destination: OrderTrackingView(orderId: $selectedOrderId,
                                               productId: $selectedProductId)
            )
            
        }
        .background(Color.backGround)
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
         .bottomSheet(isPresented: $blockedSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {  }, content: {
             UnblockedUserSheet(onLogoutClick: {
                 withAnimation(.snappy) { blockedSheet = false }
                 navigateToBlockedList = true
             }, onCancelClick: {
                 withAnimation(.snappy) { blockedSheet = false }
             })
         })
         .bottomSheet(isPresented: $blockedBySheet,height: screenHeight * 0.40) {
             BlockedUserSheet(profileImage: blockUserImage,
                              username: blockUserName,
                              winnerProfileID: 1,
                              showParentToast: $showToast,
                              parentToastMessage: $toastMessage,
                              onDismiss: {
                 self.blockedBySheet = false
             }
             )
         }
         
        .onAppear {
            UIScrollView.appearance().bounces = false
            Task {
                await fetchData(for: selected)
            }
        }
        // Trey QA 2026-05-31: inquiry deep-link — TabbarScreen posts
        // PushInquiryThread after switching to Activity tab.
        .onReceive(
            NotificationCenter.default.publisher(for: NSNotification.Name("PushInquiryThread"))
        ) { notification in
            if let tid = notification.object as? Int {
                deepLinkInquiryThreadId = tid
                navigateToInquiryThread = true
            } else {
                navigateToInquiryInbox = true
            }
        }
        .padding(.bottom, -27)
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onChange(of: selected) { oldValue, newValue in
            Task {
                await fetchData(for: newValue)
            }
        }
    }
    
    func prepareChatNavigation(for chat: ChatMessage) {
        let currentUserId = String(UserDefaults.userId)
        let isCurrentUserSender = chat.users.senderId == currentUserId
        
        selectedUserId = isCurrentUserSender ? chat.users.receiverId : chat.users.senderId
        selectedUserName = isCurrentUserSender ? chat.users.receiverName : chat.users.senderName
        selectedUserImage = isCurrentUserSender ? chat.users.receiverImage : chat.users.senderImage
        
        print("currentUserId: \(currentUserId), selectedUserId: \(selectedUserId ?? "")")
        
        selectedRoomId = computeRoomId(senderId: currentUserId, receiverId: selectedUserId ?? "")
        print("Computed Room ID: \(selectedRoomId)")
        
        chatPath = "chats/\(selectedRoomId)"
        print("Computed Chat Path: \(chatPath)")
        
        chatVM = ChatModel(
            currentUserId: currentUserId,
            currentUserName: UserDefaults.fullName,
            currentUserImage: UserDefaults.profileURL,
            otherUserId: selectedUserId ?? "",
            otherUserName: selectedUserName ?? "",
            otherUserImage: selectedUserImage ?? ""
        )
        
        // Now, we can navigate to the chat screen
        isNavigatingToChat = true
    }
    
    
    func computeRoomId(senderId: String, receiverId: String) -> String {
        let sortedIds = [senderId, receiverId].sorted()
        return "\(sortedIds[0])_chats_\(sortedIds[1])"
    }
    
    
    
    // Fetch data based on the selected segment
    func fetchData(for segment: Segment) async {
        currentPage = 1
        switch segment {
        case .message:
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            isLoading = true
            messageList.removeAll()
            await fetchBlockedList()
            
            self.isLoading = false 
            
            FirebaseManager.shared.fetchMessageList(forUserId: "\(UserDefaults.userId)") { messages in
                DispatchQueue.main.async {
                    self.messageList = messages
                    
                }
            }
            
        case .bid:
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            offerList.removeAll()
            let request = PageRequest(page: currentPage)
            await viewModel.getBidList(param: request)
            await SVProgressHUD.dismiss()
            if viewModel.offerListResponse.status == "success" {
                offerList = viewModel.offerListResponse.data ?? []
            }
        case .offer:
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            offerList.removeAll()
            let request = PageRequest(page: currentPage)
            await viewModel.getOfferList(param: request)
            await SVProgressHUD.dismiss()
            if viewModel.offerListResponse.status == "success" {
                offerList = viewModel.offerListResponse.data ?? []
            }
        case .purchases:
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            isLoading = true
//            SVProgressHUD.show()
            offerList.removeAll()
            var filter = ""
            if selectedFilterIdex < filterArray.count {
                filter = filterArray[selectedFilterIdex]
            }
            isLoading = false
//            fetchPurchasedOrderList(type: "purchased", status: filter)
            currentPage = 1
            purchaseOrderList.removeAll()
            fetchPurchasedOrderList(type: "purchased", status: filter, page: currentPage)
        case .savedItems:
            offerList.removeAll()
            isLoading = false
            fetchPurchasedOrderList(type: "saved", status: "")
        }
    }
    func handlePurchasePagination(index: Int) async {
        let isLastItem = index == purchaseOrderList.count - 1
        let totalItems = viewModel.purchasedOrderListResponse.total ?? 0
        let canFetchMore = totalItems > purchaseOrderList.count
        
        if isLastItem && canFetchMore {
            currentPage += 1
            
            var filter = ""
            if selectedFilterIdex < filterArray.count {
                filter = filterArray[selectedFilterIdex]
            }
            
            fetchPurchasedOrderList(
                type: "purchased",
                status: filter,
                page: currentPage
            )
        }
    }

    
    func fetchBlockedList() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await blockedViewModel.getBlockUser()
        await SVProgressHUD.dismiss()
        
        if blockedViewModel.blockedUserListResponse.status != "success" {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: blockedViewModel.blockedUserListResponse.message ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK",
                sheetThemeColor: .pinkBtn
            )
            withAnimation(.snappy) { showError = true }
        } else {
            blockedMe = blockedViewModel.blockedUserListResponse.data?.blockedMe ?? []
            blockedByMe = blockedViewModel.blockedUserListResponse.data?.blockedByMe ?? []
        }
    }

    
    func fetchPurchasedOrderList(type: String, status: String = "", page: Int = 1) {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: page == 1,
                onError: { error in
//                    canLoadMore = false
//                    isFetchingMore = false
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText:""
                    )
                    showError = true
                },
                onSuccess: {
                    if viewModel.purchasedOrderListResponse.status == "success" {
                        
                        let newData = viewModel.purchasedOrderListResponse.data ?? []
                        
                        if page == 1 {
                            purchaseOrderList = newData
                        } else {
                            purchaseOrderList.append(contentsOf: newData)
                        }
                    }
                }
            ) {
                isLoading = false
                var filter = ""
                
                if status == "All" { filter = "" }
                else if status == "In Progress" { filter = "in_progress" }
                else if status == "Completed" { filter = "completed" }
                
                let request = PurchaseOrderRequuest(
                    type: type,
                    status: filter,
                    page: page    // 👈 make sure your request supports page
                )
                await viewModel.getMyPurchasedOrderList(parameters: request)
            }
        }
    }

    
    
    //MARK: fetchListing.
    func getOfferSuccess() {
        SVProgressHUD.dismiss()
        if viewModel.offerListResponse.status == "success" {
            offerList = viewModel.offerListResponse.data ?? []
        } else {
            
        }
    }
    
    func handlePagination(index: Int) async {
        let isLastItem = index == offerList.count - 1
        let totalItems: Int
        
        switch selected {
        case .bid, .offer:
            totalItems = viewModel.offerListResponse.total ?? 0
        case .purchases, .savedItems:
            totalItems = productViewModel.productsResponse?.total ?? 0
        default:
            totalItems = 0
        }
        
        let canFetchMore = totalItems > offerList.count
        
        if isLastItem && canFetchMore {
            let nextPage = currentPage + 1
            switch selected {
            case .bid:
                let request = PageRequest(page: nextPage)
                await viewModel.getBidList(param: request)
                if viewModel.offerListResponse.status == "success" {
                    currentPage = nextPage
                    offerList.append(contentsOf: viewModel.offerListResponse.data ?? [])
                }
            case .offer:
                let request = PageRequest(page: nextPage)
                await viewModel.getOfferList(param: request)
                if viewModel.offerListResponse.status == "success" {
                    currentPage = nextPage
                    offerList.append(contentsOf: viewModel.offerListResponse.data ?? [])
                }
            case .purchases:
                currentPage = nextPage
                fetchPurchasedOrderList(type: "purchased", status: filterArray[selectedFilterIdex])
            case .savedItems:
                currentPage = nextPage
                fetchPurchasedOrderList(type: "saved")
            default:
                break
            }
        }
    }
    
    
    
    func handleOfferAction(offer: OfferListModel, newStatus: String) {
        // Basecamp #9938459971 (2026-05-29 RETURN): optimistic local flip so
        // buttons clear immediately (endpoint URL fix is in ProjectEndPoint).
        if let idx = offerList.firstIndex(where: { $0.id == offer.id }) {
            let old = offerList[idx]
            offerList[idx] = OfferListModel(
                id: old.id, order_id: old.order_id, user_id: old.user_id,
                product_id: old.product_id, shipping_address: old.shipping_address,
                card_id: old.card_id,
                customer_payment_profile_id: old.customer_payment_profile_id,
                promo_code: old.promo_code, send_as_gift: old.send_as_gift,
                gift_user_id: old.gift_user_id, gift_msg: old.gift_msg,
                status: newStatus,
                created_at: old.created_at,
                product: old.product, user: old.user
            )
        }
        let param = OfferUpdateStatusRequest(offer_id: offer.id ?? 0, status: newStatus, page: currentPage)
        SVProgressHUD.show()
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"; showhud = true; return
            }
            await viewModel.updateOfferStatus(parameters: param)
            let pageParam = PageRequest(page: currentPage)
            await viewModel.getOfferList(param: pageParam)
            await SVProgressHUD.dismiss()
            if viewModel.offerListResponse.status == "success" {
                self.offerList = viewModel.offerListResponse.data ?? []
            }
            self.hudMsg = "Offer \(newStatus)"
            self.showhud = true
        }
    }
    
    func offerCount(for offer: OffersValue) -> String {
        switch offer {
        case .pending:
            return "\(viewModel.offerListResponse.pending ?? 0)"
        case .accepted:
            return "\(viewModel.offerListResponse.accepted ?? 0)"
        case .decline:
            return "\(viewModel.offerListResponse.declined ?? 0)"
        }
    }
    
    func checkBlockStatus(for targetUserId: Int, blockedData: BlockedUserList) -> BlockStatus {
        if ((blockedData.blockedByMe?.contains(where: { $0.id == targetUserId })) != nil) {
            return .blockedByMe
        } else if ((blockedData.blockedByMe?.contains(where: { $0.id == targetUserId })) != nil) {
            return .blockedMe
        } else {
            return .notBlocked
        }
    }

    enum BlockStatus {
        case blockedByMe
        case blockedMe
        case notBlocked
    }

}


// Enum for the segmented control
enum Segment: String, CaseIterable, CustomStringConvertible {
    case message = "Message"
    case bid = "Bids"
    case offer = "Offers"
    case purchases = "Purchases"
    case savedItems = "Saved Items"
    
    var description: String { rawValue }
    
    static var segmentArray: [String] {
        return Segment.allCases.map { $0.rawValue }
    }
    
    // Get segment by index
    static func segment(at index: Int) -> Segment? {
        let allSegments = Segment.allCases
        guard allSegments.indices.contains(index) else {
            return nil
        }
        return Array(allSegments)[index]
    }
    
    // Get index of current segment
    var index: Int {
        return Array(Segment.allCases).firstIndex(of: self) ?? 0
    }
}

struct MessageCell: View {
    let message: ChatMessage
    let currentUserId: String
    
    var otherUserName: String {
        message.users.senderId == currentUserId
        ? message.users.receiverName
        : message.users.senderName
    }
    
    var otherUserImage: String {
        message.users.senderId == currentUserId
        ? message.users.receiverImage
        : message.users.senderImage
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            CustomProfileImage(url: otherUserImage, isCircular: true, size: 48)
//            AsyncImage(url: URL(string: otherUserImage)) { image in
//                image.resizable()
//            } placeholder: {
//                Color.gray
//            }
//            .frame(width: 48, height: 48)
//            .clipShape(Circle())
//            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(otherUserName.capitalizingFirstLetter())
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Text(timestampString)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Text(message.message)
                    .font(.system(size: 15))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var timestampString: String {
        let date = Date(timeIntervalSince1970: message.timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}


struct MessageRow: View {
    let message: ChatMessage
    let currentUserId: String
    let blockedMe: [BlockedByUserList]
    let blockedByMe: [BlockedByUserList]
    
    var onBlockedByMe: () -> Void
    var onBlockedMe: () -> Void
    var onAllowed: () -> Void
    
    private var otherUserId: String {
        let senderId = message.users.senderId ?? ""
        let receiverId = message.users.receiverId ?? ""
        return senderId == currentUserId ? receiverId : senderId
    }
    
    private var isBlockedByMe: Bool {
        blockedByMe.contains { String($0.id ?? -1) == otherUserId }
    }
    
    private var isBlockedMe: Bool {
        blockedMe.contains { String($0.id ?? -1) == otherUserId }
    }
    
    // QA #37 — read/responded state on the messages list.
    // "Unread" means: last message came from the other user AND I haven't opened the thread since.
    // When unread, the row shows bold name + a small primary-color dot indicator.
    // When seen (I responded or just read it), the preview text dims to gray.
    private var isUnread: Bool {
        // ChatUsers.senderId is a non-optional String on ChatMessage.
        let lastSenderIsOther = message.users.senderId != currentUserId
        return lastSenderIsOther && !message.seen
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            CustomProfileImage(url: otherUserImage, isCircular: true, size: 48)
//            AsyncImage(url: URL(string: otherUserImage)) { image in
//                image.resizable()
//            } placeholder: {
//                Color.gray
//            }
//            .frame(width: 48, height: 48)
//            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(otherUserName.capitalizingFirstLetter())
                        // QA #37 — bold name only when there's a fresh unread message.
                        .font(.system(size: 16, weight: isUnread ? .bold : .semibold))
                    // QA #37 — unread indicator dot (hidden when message is seen / I responded).
                    if isUnread {
                        Circle()
                            .fill(Color.defaultTheme)
                            .frame(width: 8, height: 8)
                    }
                    Spacer()
                    Text(timestampString)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Text(message.message)
                    .font(.system(size: 15))
                    // QA #37 — dim preview text to gray when the thread is already read/responded;
                    // keep it black when there's an unread message so it draws the eye.
                    .foregroundColor(isUnread ? .primary : .gray)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onTapGesture {
            if isBlockedByMe {
                onBlockedByMe()
            } else if isBlockedMe {
                onBlockedMe()
            } else {
                onAllowed()
            }
        }
    }
    
    private var otherUserName: String {
        message.users.senderId == currentUserId
        ? message.users.receiverName
        : message.users.senderName
    }
    
    private var otherUserImage: String {
        message.users.senderId == currentUserId
        ? message.users.receiverImage
        : message.users.senderImage
    }
    
    private var timestampString: String {
        let date = Date(timeIntervalSince1970: message.timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}

