//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD
import Combine

// MARK: - MyOrdersScreen
struct MyOrdersScreen: View {
    
    // Enum for the segmented control
    enum Segment: String, CaseIterable, CustomStringConvertible {
        case all = "All"
        case newOrder = "New Order"
//        case created = "Created"
        case processing = "Processing"
        case completed = "Completed"
//        case cancellations = "Cancellations"
//        case refunds = "Refunds"
        
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
        
        var apiValue: String {
            switch self {
            case .newOrder:
                return "new_order"
            case .all:
                return ""
//            case .created:
//                return "created"
            case .processing:
                return "processing"
            case .completed:
                return "completed"
//            case .cancellations:
//                return "cancellations"
//            case .refunds:
//                return "refunds"
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = MyOrdersViewModel()
    @State private var myOrderListArr : [MyOrderModel] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var selectedOrderType: MyOrderValue? = .newOrders
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var debounceCancellable: AnyCancellable?
    @State var searchText: String = ""
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var navigateToOrderDetails = false
    @State private var navigateToProfile = false
    
    @State private var userId: String = ""
    @State private var userImage: String = ""
    @State private var userName: String = ""
    
    @State private var showhud = false
    @State private var hudMsg = ""
    @State var newOrder = ""
    @State var completedOrder = ""
    @State var ProcessingOrder = ""
    @State var currentPage = 1
    
    @State private var isFetchingMore: Bool = false
    @State private var canLoadMore: Bool = true
    
    @State private var selected: Segment = .all
    @State private var selectedTabIndex: Int = Segment.all.index
    
//    var filteredOrder: [MyOrderModel] {
//        if searchText.isEmpty {
//            return myOrderListArr
//        } else {
//            return myOrderListArr.filter {
//                $0.product?.title?.localizedCaseInsensitiveContains(searchText) ?? false
//            }
//        }
//    }
//    
    @State var selectedOrderDetails: MyOrderModel?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 4) {
                VStack{
                    // MARK: - Top Header (fixed)
//                    PrimaryHeader(
//                        title: AppString.MyOrders,
//                        isForBoth: false,
//                        leadingImgArr: [.icBack,.appName],
//                        trailingImgArr: [.icSetting],
//                        onClickLeading: { _ in
//                            self.presentationMode.wrappedValue.dismiss()
//                        },
//                        count: .constant(0)
//                    )
                    TopHeaderView(backBtnTapped: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, title: AppString.MyOrders)
                }
                VStack(spacing: 16) {
                    //                    TwoVerticalLabelCell(
                    //                        dataModel: MyOrderValue.allCases,
                    //                        topLabel: { order in
                    //                            offerCount(for: order)
                    //                        },
                    //                        bottomLabel: { $0.description.localized },
                    //                        selection: $selectedOrderType
                    //                    )
                    //                    .onChange(of: selectedOrderType ?? .newOrders) { newType in
                    //                        searchText = ""
                    ////                        fetchOrders(for: newType)
                    //                    }
                    SearchBarView(placeholder: "What are you looking for?") { debouncedText in
//                        if debouncedText == "" { return }
                        currentPage = 1
                        searchText = debouncedText
                        fetchOrders(for: selected ?? .newOrder)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .cornerRadius(28, corners: .allCorners)
                    // MARK: - Filter Pills
                    PillsSelectorView(
                        titles:  Segment.segmentArray,
                        selectedIndex: $selectedTabIndex,
                        backgroundStyle: .roundedRect,
                        underlineEnabled: false,
                        onSelectionChanged: { index, data in
                            selected = Segment.segment(at: index) ?? .newOrder
                        }
                    )
                    .padding(.bottom, 12)
                    .onChange(of: selected) { newSegment in
                        fetchOrders(for: selected ?? .newOrder)
                    }
                }
//                .padding(.horizontal)
                
                
                // MARK: - Scrollable Order List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if !myOrderListArr.isEmpty {
                            ForEach(Array(myOrderListArr.enumerated()), id: \.element.id) { index, order in
                                OrderCardView(order: order,
                                              onTapCardView: {
                                    selectedOrderDetails = order
                                    navigateToOrderDetails = true
                                }, onTapBuyerView: {
                                    userId = "\(order.user?.id ?? 0)"
                                    userImage = order.user?.profileImage ?? ""
                                    userName = order.user?.name ?? ""
                                    navigateToProfile = true
                                })
                                .padding([.leading , .trailing] , 0)
                                .onAppear {
                                    checkAndLoadMore(currentIndex: index)
                                }
                            }
                            Spacer(minLength: 80)
                        }
                        else  {
                            NoDataView(message: "No Orders found")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                }
                
                if isFetchingMore {
                    ProgressView()
                        .padding(.vertical, 16)
                }
                
            }
        }
        .background(Color.defaultTheme.opacity(0.05).ignoresSafeArea())
        
        .onAppear {
            UIScrollView.appearance().bounces = false
            
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onFirstAppear {
            fetchOrders(for: selected ?? .newOrder)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
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
        if let order = selectedOrderDetails {
            CusNavLink(doNavigate: $navigateToOrderDetails, destination: OrderStatusScreen(
                productDetail: $selectedOrderDetails,
                comeFrom: "myOrder"
            ))
        }
        CusNavLink(doNavigate: $navigateToProfile,
                   destination: ProfileScreen(id:$userId,
                                              isComeFrom: .constant(""),
                                              userName: $userName,
                                              userImage: $userImage))
    }
}

////MARK: API Call Passing Param.
//extension MyOrderValue {
//    var apiValue: String {
//        switch self {
//        case .newOrders: return "new_order"
//        case .processing: return "processing"
//        case .completed: return "completed"
//        }
//    }
//}

//MARK: API CALL LOGIC.
extension MyOrdersScreen{
    //MARK: fetchOrders.
    func fetchOrders(for type: Segment) {
        Task {
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            let param = ProductOrderListingRequest(type: type.apiValue, page: currentPage, search: searchText)
            await viewModel.getMyOrderList(parameters: param)
            await SVProgressHUD.dismiss()
            isFetchingMore = false
            if self.viewModel.errorMessage == "" || viewModel.errorMessage == nil{
                getOrderSuccess()
            }else{
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: viewModel.errorMessage?.capitalizingFirstLetter() ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
            }
        }
    }
    
    //MARK: getOrderSuccess.
    func getOrderSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.myOrderResponse
        if response.status == "success" {
            myOrderListArr = response.data ?? []
            newOrder = "\(response.new_order_count ?? 0)"
            completedOrder = "\(response.completed_order_count ?? 0)"
            ProcessingOrder = "\(response.processing_order_count ?? 0)"
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
    
//    //MARK: fetchMoreOrder.
//    func fetchMoreOrder() {
//        currentPage += 1
//        isFetchingMore = true
//        fetchOrders(for: selected ?? .newOrder)
//    }
//    
//    //MARK: handlePagination
//    func handlePagination(index: Int) {
//        let isLastItem = index == myOrderListArr.count - 1
//        let canFetchMore = (viewModel.myOrderResponse.total ?? 0) > myOrderListArr.count
//        
//        if isLastItem && canFetchMore {
//            fetchMoreOrder()
//        }
//    }
    /// Checks if we should load more data when a specific item appears
    private func checkAndLoadMore(currentIndex: Int) {
        // Don't load if:
        // 1. Already fetching
        // 2. Can't load more (reached end)
        // 3. Still loading initial data
        guard !isFetchingMore, canLoadMore else {
            return
        }
        
        // Calculate threshold (load more when user is 3 items from the end)
        let thresholdIndex = myOrderListArr.count - 3
        
        // Trigger load more when user scrolls near the end
        if currentIndex >= thresholdIndex {
            loadMoreData()
        }
    }
    
    /// Loads the next page of data
    private func loadMoreData() {
        // Prevent multiple simultaneous calls
        guard !isFetchingMore else { return }
        
        // Check if there's more data to load
        let totalItems = viewModel.myOrderResponse.total ?? 0
        let currentItemCount = myOrderListArr.count
        
        guard currentItemCount < totalItems else {
            // We've loaded all items
            canLoadMore = false
            return
        }
        
        // Set fetching flag
        isFetchingMore = true
        
        // Increment page and fetch
        currentPage += 1
        
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: false,
                onError: { error in
                    // ✅ Reset pagination state on error
                    isFetchingMore = false
                    currentPage -= 1 // Rollback page increment
                    
                    alertType = .sheetType(
                     icon: .alert,
                     title: "Error",
                     message: errorDesc(error: error, message: viewModel.errorMessage),
                     primaryBtnText: "",
                     secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                },
                onSuccess: {
                    // ✅ Handle successful data load
                    
                    handlePaginationSuccess()
                    
                }
            ) {
                let param = ProductOrderListingRequest(type: selected.apiValue, page: currentPage, search: searchText)
                await viewModel.getMyOrderList(parameters: param)
                isFetchingMore = false
                if self.viewModel.errorMessage == "" || viewModel.errorMessage == nil{
                    getOrderSuccess()
                }else{
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage?.capitalizingFirstLetter() ?? "",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                }
            }
        }
    }
    
    /// Handles successful pagination response
    private func handlePaginationSuccess() {
        let response = viewModel.myOrderResponse
        
        guard response.status == "success" else {
            // Handle error case
            isFetchingMore = false
            currentPage -= 1 // Rollback
            return
        }
        
        // Append new data
        let newData = response.data ?? []
        myOrderListArr.append(contentsOf: newData)
        
        // Update pagination state
        let totalItems = response.total ?? 0
        let currentItemCount = myOrderListArr.count
        
        // Check if we can load more
        canLoadMore = currentItemCount < totalItems
        isFetchingMore = false
        
        print("📄 Loaded page \(currentPage): \(newData.count) items | Total: \(currentItemCount)/\(totalItems)")
    }
    
    
    //MARK: offerCount.
    func offerCount(for offer: MyOrderValue) -> String {
        switch offer {
        case .newOrders:
            return "\(viewModel.myOrderResponse.new_order_count ?? 0)"
        case .processing:
            return "\(viewModel.myOrderResponse.processing_order_count ?? 0)"
        case .completed:
            return "\(viewModel.myOrderResponse.completed_order_count  ?? 0)"
        }
    }
}


struct TopHeaderView: View {
    var backBtnTapped: (() -> Void) = {}
    var title: String = "Title"
    var body: some View {
        // MARK: - Navigation Header
        HStack {
            Button(action: {
                backBtnTapped()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.custom(poppinsBold, size: 16))
                    
                }
                .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(title)
                .font(.custom(poppinsBold, size: 16))
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - MyOrderValue
enum MyOrderValue: String, CaseIterable, CustomStringConvertible {
    case newOrders, processing, completed

    var labelOlt: String {
        switch self {
        case .newOrders: return "24"
        case .processing: return "156"
        case .completed: return "892"
        }
    }

    var description: String {
        switch self {
        case .newOrders: return NSLocalizedString("New Orders", comment: "")
        case .processing: return NSLocalizedString("Processing", comment: "")
        case .completed: return NSLocalizedString("Completed", comment: "")
        }
    }
}

//
//#Preview {
//    MyOrdersScreen()
//}
