//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

// MARK: - MyOrdersScreen
struct MyOrdersScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = MyOrdersViewModel()
    @State private var myOrderListArr : [MyOrderModel] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var selectedOrderType: MyOrderValue? = .newOrders
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showhud = false
    @State private var hudMsg = ""
    @State var newOrder = ""
    @State var completedOrder = ""
    @State var ProcessingOrder = ""
    @State var currentPage = 1
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 4) {
                VStack{
                    // MARK: - Top Header (fixed)
                    PrimaryHeader(
                        title: AppString.MyOrders,
                        isForBoth: true,
                        leadingImgArr: [.icBack,.appName],
                        trailingImgArr: [.icSetting],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }
                
                
                // MARK: - Scrollable Order List
                ScrollView {
                    VStack(spacing: 16) {
                        TwoVerticalLabelCell(
                            dataModel: MyOrderValue.allCases,
                            topLabel: { order in
                                offerCount(for: order)
                            },
                            bottomLabel: { $0.description.localized },
                            selection: $selectedOrderType
                        )
                        .onChange(of: selectedOrderType ?? .newOrders) { newType in
                            fetchOrders(for: newType)
                        }
                        ForEach(myOrderListArr , id: \.id) { order in
                            OrderCardView(order: order)
                                .padding([.leading , .trailing] , 0)
                        }
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal)
                    .padding(.top, 0)
                }
            }
        }
        .background(Color.blue.opacity(0.05).ignoresSafeArea())
        .onAppear {
            UIScrollView.appearance().bounces = false
            
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onFirstAppear {
            fetchOrders(for: selectedOrderType ?? .newOrders)
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
    }
}

//MARK: API Call Passing Param.
extension MyOrderValue {
    var apiValue: String {
        switch self {
        case .newOrders: return "new_order"
        case .processing: return "processing"
        case .completed: return "completed"
        }
    }
}

//MARK: API CALL LOGIC.
extension MyOrdersScreen{
    //MARK: fetchOrders.
    func fetchOrders(for type: MyOrderValue) {
        Task {
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            let param = ProductOrderListingRequest(type: type.apiValue, page: currentPage)
            await viewModel.getMyOrderList(parameters: param)
            await SVProgressHUD.dismiss()
            getOrderSuccess()
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
    
    //MARK: fetchMoreOrder.
    func fetchMoreOrder() {
        currentPage += 1
        fetchOrders(for: selectedOrderType ?? .newOrders)
    }
    
    //MARK: handlePagination
    func handlePagination(index: Int) {
        let isLastItem = index == myOrderListArr.count - 1
        let canFetchMore = (viewModel.myOrderResponse.total ?? 0) > myOrderListArr.count
        
        if isLastItem && canFetchMore {
            fetchMoreOrder()
        }
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


#Preview {
    MyOrdersScreen()
}
