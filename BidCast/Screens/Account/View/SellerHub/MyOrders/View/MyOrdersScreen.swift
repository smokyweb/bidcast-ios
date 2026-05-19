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
    @State private var isInitialLoad: Bool = true
    @State private var debounceCancellable: AnyCancellable?
    @State var searchText: String = ""
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var navigateToOrderDetails = false
    @State private var navigateToProfile = false
    
    @State private var userId: String = ""
    @State private var userImage: String = ""
    @State private var userName: String = ""
    @State var orderId : Int = 0
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
      
    @State var selectedOrderDetails: MyOrderModel?
    
    var body: some View {
        VStack {
           
                VStack{
                    TopHeaderView(backBtnTapped: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, title: AppString.MyOrders)
                }
                .background(.white)
                VStack(spacing: 16) {
                    SearchBarView(placeholder: "What are you looking for?") { debouncedText in
                        currentPage = 1
                        searchText = debouncedText
                        fetchOrders(for: selected ?? .newOrder)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .cornerRadius(28, corners: .allCorners)
                    // MARK: - Filter Pills
                    // QA #30 — append live counts to each pill (e.g. "New Order (24)") so the New Orders count
                    // isn't blank. Counts come from the same API response that populates the list.
                    PillsSelectorView(
                        titles:  segmentTitlesWithCounts,
                        selectedIndex: $selectedTabIndex,
                        backgroundStyle: .roundedRect,
                        underlineEnabled: false,
                        onSelectionChanged: { index, data in
                            selected = Segment.segment(at: index) ?? .newOrder
                        }
                    )
                    .padding(.bottom, 12)
                    .onChange(of: selected) { _ in
                        resetAndFetch()
                    }
//                    .onChange(of: selected) { newSegment in
//                        fetchOrders(for: selected ?? .newOrder)
//                    }
                }
                .background(.backGround)
//                .padding(.horizontal)
                
                
                // MARK: - Scrollable Order List
                ScrollView {
                    VStack(spacing: 12) {
                        if !myOrderListArr.isEmpty {
                            ForEach(Array(myOrderListArr.enumerated()), id: \.element.id) { index, order in
                                OrderCardView(order: order,
                                              onTapCardView: {
                                    selectedOrderDetails = order
                                    orderId = selectedOrderDetails?.id ?? 0
                                    navigateToOrderDetails = true
                                }, onTapBuyerView: {
                                    userId = "\(order.user?.id ?? 0)"
                                    userImage = order.user?.profileImage ?? ""
                                    userName = order.user?.name ?? ""
                                    navigateToProfile = true
                                })
                                .padding([.leading , .trailing] , 0)
                                .padding(.bottom,4)
                                .onAppear {
                                    checkAndLoadMore(currentIndex: index)
                                }
                            }
//                            Color.clear
//                                .frame(height: 1)
//                                .padding(.bottom, 80)
                        }
                        else  {
                            NoDataView(message: "No Orders found")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                }
                .background(.backGround)
                if isFetchingMore {
                    ProgressView()
                        .padding(.vertical, 16)
                        .padding(.bottom, 30)
                }
                
            
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .padding(.bottom,-20)
        .background(.backGround)
        
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
        .sheet(isPresented: $showError) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            ) .presentationDetents([.fraction(0.40)])
                .presentationCornerRadius(25)
                .presentationDragIndicator(.hidden)
        }
        if let order = selectedOrderDetails {
            CusNavLink(doNavigate: $navigateToOrderDetails, destination: OrderStatusScreen(
                productDetail: $selectedOrderDetails,
                comeFrom: "myOrder", orderId: $orderId
            ))
        }
        CusNavLink(doNavigate: $navigateToProfile,
                   destination: ProfileScreen(id:$userId,
                                              isComeFrom: .constant(""),
                                              userName: $userName,
                                              userImage: $userImage))
    }
}



//MARK: API CALL LOGIC.
extension MyOrdersScreen{
    private func resetAndFetch() {
        currentPage = 1
        canLoadMore = true
        isFetchingMore = false
        isInitialLoad = true
        myOrderListArr.removeAll()
        fetchOrders(for: selected)
    }
    //MARK: fetchOrders.
    func fetchOrders(for type: Segment) {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }

            if isInitialLoad {
                SVProgressHUD.show()
            }

            let param = ProductOrderListingRequest(
                type: type.apiValue,
                page: currentPage,
                search: searchText
            )

            await viewModel.getMyOrderList(parameters: param)

            await SVProgressHUD.dismiss()
            isFetchingMore = false

            if viewModel.errorMessage?.isEmpty ?? true {
                handleSuccess(isPagination: !isInitialLoad)
            } else {
                showError = true
            }
        }
    }

    private func handleSuccess(isPagination: Bool) {
        let response = viewModel.myOrderResponse
        guard response.status == "success" else { return }

        let newData = response.data ?? []

        if isPagination {
            myOrderListArr.append(contentsOf: newData)
        } else {
            myOrderListArr = newData
        }

        newOrder = "\(response.new_order_count ?? 0)"
        completedOrder = "\(response.completed_order_count ?? 0)"
        ProcessingOrder = "\(response.processing_order_count ?? 0)"

        let total = response.total ?? 0
        canLoadMore = myOrderListArr.count < total

        isInitialLoad = false
    }
    
    private func loadMoreData() {
        guard !isFetchingMore, canLoadMore else { return }

        isFetchingMore = true
        currentPage += 1
        isInitialLoad = false

        fetchOrders(for: selected)
    }

    //MARK: getOrderSuccess.
//    func getOrderSuccess() {
//        SVProgressHUD.dismiss()
//        let response = viewModel.myOrderResponse
//        if response.status == "success" {
//            myOrderListArr = response.data ?? []
//            newOrder = "\(response.new_order_count ?? 0)"
//            completedOrder = "\(response.completed_order_count ?? 0)"
//            ProcessingOrder = "\(response.processing_order_count ?? 0)"
//        } else {
//            showError = true
//            alertType = .sheetType(
//                icon: .alert,
//                title: response.error_type?.capitalized ?? "",
//                message: response.message?.capitalized ?? "",
//                primaryBtnText: "",
//                secondaryBtnText: AppString.ok.localized
//            )
//        }
//    }
    

    private func checkAndLoadMore(currentIndex: Int) {
        let thresholdIndex = myOrderListArr.count - 2
        if currentIndex >= thresholdIndex {
            loadMoreData()
        }
    }
    
    /// Loads the next page of data
//    private func loadMoreData() {
//        // Prevent multiple simultaneous calls
//        guard !isFetchingMore else { return }
//        
//        // Check if there's more data to load
//        let totalItems = viewModel.myOrderResponse.total ?? 0
//        let currentItemCount = myOrderListArr.count
//        
//        guard currentItemCount < totalItems else {
//            // We've loaded all items
//            canLoadMore = false
//            return
//        }
//        
//        // Set fetching flag
//        isFetchingMore = true
//        
//        // Increment page and fetch
//        currentPage += 1
//        
//        Task {
//            await performAPICalls(
//                isConcurrent: false,
//                showLoader: false,
//                onError: { error in
//                    // ✅ Reset pagination state on error
//                    isFetchingMore = false
//                    currentPage -= 1 // Rollback page increment
//                    
//                    alertType = .sheetType(
//                     icon: .alert,
//                     title: "Error",
//                     message: errorDesc(error: error, message: viewModel.errorMessage),
//                     primaryBtnText: "",
//                     secondaryBtnText: AppString.ok.localized
//                    )
//                    showError = true
//                },
//                onSuccess: {
//                    // ✅ Handle successful data load
//                    
//                    handlePaginationSuccess()
//                    
//                }
//            ) {
//                let param = ProductOrderListingRequest(type: selected.apiValue, page: currentPage, search: searchText)
//                await viewModel.getMyOrderList(parameters: param)
//                isFetchingMore = false
//                if self.viewModel.errorMessage == "" || viewModel.errorMessage == nil{
//                    getOrderSuccess()
//                }else{
//                    alertType = .sheetType(
//                        icon: .alert,
//                        title: "Error",
//                        message: viewModel.errorMessage?.capitalizingFirstLetter() ?? "",
//                        primaryBtnText: "",
//                        secondaryBtnText: AppString.ok.localized
//                    )
//                }
//            }
//        }
//    }
    
    /// Handles successful pagination response
    private func handlePaginationSuccess() {
        let response = viewModel.myOrderResponse
        
        guard response.status == "success" else {
            isFetchingMore = false
            currentPage -= 1
            return
        }
        
        let newData = response.data ?? []
        myOrderListArr.append(contentsOf: newData)
        
        let totalItems = response.total ?? 0
        let currentItemCount = myOrderListArr.count
        
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

    // QA #30 — build pill titles with the live count baked in. Falls back to bare title if no count available.
    private var segmentTitlesWithCounts: [String] {
        Segment.allCases.map { seg in
            let count: Int?
            switch seg {
            case .all:        count = viewModel.myOrderResponse.total
            case .newOrder:   count = viewModel.myOrderResponse.new_order_count
            case .processing: count = viewModel.myOrderResponse.processing_order_count
            case .completed:  count = viewModel.myOrderResponse.completed_order_count
            }
            if let c = count { return "\(seg.rawValue) (\(c))" }
            return seg.rawValue
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
