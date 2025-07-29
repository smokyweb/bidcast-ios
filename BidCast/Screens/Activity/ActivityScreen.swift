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
    @StateObject var viewModel = OffersViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var offerList: [OfferListModel] = []
    @State var currentPage = 1
    @State var messageList: [ChatMessage] = []
    @State private var selectedUserId: String? = nil
    @State private var selectedUserName: String? = nil
    @State private var selectedUserImage: String? = nil
    @State private var isNavigatingToChat = false

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
                            ForEach(messageList) { message in
                                MessageCell(message: message)
                                    .padding(.all , 6)
                                    .onTapGesture {
                                        selectedUserId = message.users.senderId
                                        selectedUserName = message.users.senderName
                                        selectedUserImage = message.users.senderImage
                                        isNavigatingToChat = true
                                    }

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
            
            CusNavLink(doNavigate: $isNavigatingToChat, destination: ChatScreen(viewModel: ChatViewModel(
                currentUserId: "\(UserDefaults.userId)",
                currentUserName: UserDefaults.userName,
                currentUserImage: UserDefaults.profileURL,
                otherUserId: selectedUserId ?? "",
                otherUserName: selectedUserName ?? "",
                otherUserImage: selectedUserImage ?? ""
            )))
            
            CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())
        }
        .background(Color(.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
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
            isLoading = true

            FirebaseManager.shared.fetchMessages(forUserId: "\(UserDefaults.userId)") { messages in
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

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Profile Image
            AsyncImage(url: URL(string: message.users.receiverImage)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            // Name + Message
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(message.users.receiverName)
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




