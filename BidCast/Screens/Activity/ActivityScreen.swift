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
    
    @State var navigateToNotification = false
    @Environment(\.presentationMode) var presentationMode
    
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
                VStack(spacing: 0) {
                    
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
                            NoDataView(message: "No bids Found")
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
                            NoDataView(message: "No offers Found")
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
                        
                    case .purchases, .savedItems:
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
//                                .background(Color.gray.opacity(0.1))
                            }
                        }
                        
//                    case .savedItems:
//                        if purchaseOrderList.isEmpty {
//                            NoDataView(message: "No List Found")
//                        } else {
//                            ForEach(purchaseOrderList.indices, id: \.self) { i in
//                                let offer = purchaseOrderList[i]
//                                ActivityCell(
//                                    offerListing: offer,
//                                    isFor: "Saved Items",
//                                    status: offer.status ?? ""
//                                )
//                                .onAppear {
//                                    Task {
//                                        await handlePagination(index: i)
//                                    }
//                                }
//                            }
//                        }
//                        
                    }
                }
            }
            .padding(.top,4)
            .padding(.horizontal, 8)
            
            if let chatVM = chatVM {
                CusNavLink(
                    doNavigate: $isNavigatingToChat,
                    destination: ChatScreen(viewModel: chatVM)
                )
            }
            
            CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())
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
        .background(Color(.systemGroupedBackground))
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
        .padding(.bottom, -27)
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onChange(of: selected) { newSegment in
            Task {
                await fetchData(for: newSegment)
            }
        }
    }
    
    func prepareChatNavigation(for chat: ChatMessage) {
        let currentUserId = String(UserDefaults.userId)
        let isCurrentUserSender = chat.users.senderId == currentUserId
        
        // Assign the correct user ID and names
        selectedUserId = isCurrentUserSender ? chat.users.receiverId : chat.users.senderId
        selectedUserName = isCurrentUserSender ? chat.users.receiverName : chat.users.senderName
        selectedUserImage = isCurrentUserSender ? chat.users.receiverImage : chat.users.senderImage
        
        // Log to ensure correct IDs are being passed
        print("currentUserId: \(currentUserId), selectedUserId: \(selectedUserId ?? "")")
        
        // Compute the sorted chat ID to ensure correct Firebase path
        selectedRoomId = computeRoomId(senderId: currentUserId, receiverId: selectedUserId ?? "")
        print("Computed Room ID: \(selectedRoomId ?? "")")
        chatPath = "chats/\(selectedRoomId)"
        print("Computed Chat Path: \(chatPath)")
        
        // Reinitialize the ChatViewModel with the correct user information
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
            fetchPurchasedOrderList(type: "purchased", status: filter)
        case .savedItems:
            offerList.removeAll()
            isLoading = false
            fetchPurchasedOrderList(type: "saved", status: "")
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

    
    func fetchPurchasedOrderList(type: String, status: String = "") {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
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
                        purchaseOrderList = viewModel.purchasedOrderListResponse.data ?? []
                    }
                }
            ) {
                isLoading = false
                var filter = ""
               
                if status == "All" { filter = "" }
                else  if status == "In Progress"  { filter = "in_progress" }
                else  if status == "Completed"  { filter = "completed" }
                let request = PurchaseOrderRequuest(type: type, status: filter)
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
        let param = OfferUpdateStatusRequest(offer_id: offer.id ?? 0, status: newStatus, page: currentPage)
        SVProgressHUD.show()
        
        Task {
            do {
                guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                await viewModel.updateOfferStatus(parameters: param)
                let param = PageRequest(page: currentPage)
                await viewModel.getOfferList(param: param)
                await SVProgressHUD.dismiss()
                if viewModel.offerListResponse.status == "success" {
                    self.offerList = viewModel.offerListResponse.data ?? []
                    self.hudMsg = "Offer \(newStatus)"
                } else {
                    self.hudMsg = "Failed to refresh offers"
                }
                self.showhud = true
            } catch {
                await SVProgressHUD.dismiss()
                self.hudMsg = "Failed to update offer"
                self.showhud = true
            }
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

