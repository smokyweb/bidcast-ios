//
//  ActivityScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUICore
import SwiftUI
import SVProgressHUD
import AlertToast

struct ActivityScreen: View {
    
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var selectedRoomId: String = ""
    @StateObject var viewModel = OffersViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var offerList: [OfferListModel] = []
    @State var currentPage = 1
    @State var messageList: [ChatMessage] = []
    @State private var chatVM: ChatViewModel?
    @State private var selectedUserId: String? = nil
    @State private var selectedUserName: String? = nil
    @State private var selectedUserImage: String? = nil
    @State private var isNavigatingToChat = false
    @State private var chatPath: String = ""
    @StateObject private var blockedViewModel = BlockedUserListViewModel()
    @State private var blockedUsers: [BlockedByUserList] = []
    @State var blockedSheet: Bool = false
    @State var navigateToBlockedList : Bool = false

    
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var selected: Segment = .message
    
    @State var navigateToNotification = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                PrimaryHeader(
                    title: "Activity",
                    isForLogo: true,
                    leadingImgArr: [.appName],
                    trailingImgArr: [.notification],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    onClickTrailing: {  _ in
                        
                        navigateToNotification = true
                    },
                    count: .constant(0)
                )
            }
            VStack(alignment: .leading,spacing: 6){
                SegmentedControlView(
                    segments: Segment.allCases,
                    selectedSegment: $selected,
                    isWithBorder: false,
                    fontTitle: robotoMedium,
                    fontSize: 14.0
                )
            }
            
            ScrollView {
                VStack(spacing: 6) {
                    
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
                                    blockedUsers: blockedUsers,
                                    onBlocked: {
                                        blockedSheet = true
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
                        
                    case .purchases:
                        if offerList.isEmpty {
                            NoDataView(message: "No List Found")
                        } else {
                            ForEach(offerList.indices, id: \.self) { i in
                                let offer = offerList[i]
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Purchases",
                                    status: offer.status ?? ""
                                )
                                .onAppear {
                                    Task {
                                        await handlePagination(index: i)
                                    }
                                }
                            }
                        }
                        
                    case .savedItems:
                        if offerList.isEmpty {
                            NoDataView(message: "No List Found")
                        } else {
                            ForEach(offerList.indices, id: \.self) { i in
                                let offer = offerList[i]
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Saved Items",
                                    status: offer.status ?? ""
                                )
                                .onAppear {
                                    Task {
                                        await handlePagination(index: i)
                                    }
                                }
                            }
                        }
                        
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
        .onAppear {
            UIScrollView.appearance().bounces = false
            Task {
                await fetchData(for: selected)
            }
        }
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
        chatVM = ChatViewModel(
            currentUserId: currentUserId,
            currentUserName: UserDefaults.fullName,
            currentUserImage: UserDefaults.profileURL,
            otherUserId: selectedUserId ?? "",
            otherUserName: selectedUserName ?? "",
            otherUserImage: selectedUserImage ?? "",
            chatPath: $chatPath
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
            
            messageList.removeAll()
            await fetchBlockedList()
            isLoading = true
            
            FirebaseManager.shared.fetchMessageList(forUserId: "\(UserDefaults.userId)") { messages in
                DispatchQueue.main.async {
                    self.messageList = messages
                    self.isLoading = false
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
            SVProgressHUD.show()
            offerList.removeAll()
            let request = ItemListRequest(type: "purchased", page: currentPage)
            await viewModel.getItemList(parameters: request)
            await SVProgressHUD.dismiss()
            if viewModel.itemListResponse.status == "success" {
                offerList = viewModel.itemListResponse.data ?? []
            }
        case .savedItems:
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            offerList.removeAll()
            let request = ItemListRequest(type: "saved", page: currentPage)
            await viewModel.getItemList(parameters: request)
            await SVProgressHUD.dismiss()
            if viewModel.itemListResponse.status == "success" {
                offerList = viewModel.itemListResponse.data ?? []
            }
        }
    }
    
    func fetchBlockedList() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await blockedViewModel.getBlockUser(param: BlockUserList(blocked_by: true))
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
            blockedUsers = blockedViewModel.blockedUserListResponse.data?.data ?? []
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
            totalItems = viewModel.itemListResponse.total ?? 0
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
                let request = ItemListRequest(type: "purchased", page: nextPage)
                await viewModel.getItemList(parameters: request)
                if viewModel.itemListResponse.status == "success" {
                    currentPage = nextPage
                    offerList.append(contentsOf: viewModel.itemListResponse.data ?? [])
                }
            case .savedItems:
                let request = ItemListRequest(type: "saved", page: nextPage)
                await viewModel.getItemList(parameters: request)
                if viewModel.itemListResponse.status == "success" {
                    currentPage = nextPage
                    offerList.append(contentsOf: viewModel.itemListResponse.data ?? [])
                }
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
}


// Enum for the segmented control
enum Segment: String, CaseIterable, CustomStringConvertible {
    case message = "Message"
    case bid = "Bids"
    case offer = "Offers"
    case purchases = "Purchases"
    case savedItems = "Saved Items"
    
    var description: String { rawValue }
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
            AsyncImage(url: URL(string: otherUserImage)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            
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
    let blockedUsers: [BlockedByUserList]
    
    var onBlocked: () -> Void
    var onAllowed: () -> Void
    
    private var otherUserId: String {
        let senderId = message.users.senderId ?? ""
        let receiverId = message.users.receiverId ?? ""
        return senderId == currentUserId ? receiverId : senderId
    }
    
    private var isBlocked: Bool {
        blockedUsers.contains { user in
            String(user.id ?? -1) == otherUserId
        }
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: otherUserImage)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            
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
            print("Tapped userId:", otherUserId, "Blocked IDs:", blockedUsers.map { $0.id })
            if isBlocked {
                onBlocked()
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
