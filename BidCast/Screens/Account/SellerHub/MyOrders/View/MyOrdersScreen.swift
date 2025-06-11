//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct Order: Identifiable {
    let id = UUID()
    let orderNumber: String
    let date: String
    let name: String
    let location: String
    let image: Image
    let amount: String
    let status: String
    let statusColor: Color
}

// MARK: - MyOrdersScreen
struct MyOrdersScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = MyOrdersViewModel()
    @StateObject var profileViewModel = ProfileViewModel()
    @State private var myOrderListArr : [MyOrderModel] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var selectedOrderType: MyOrderValue? = .newOrders
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // MARK: - Top Header (fixed)
                PrimaryHeader(
                    title: "My Orders",
                    isForLogo: true,
                    leadingImgArr: [.appName],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .padding(.horizontal)
                .padding(.bottom, 10)
                .frame(height: 30)


                // MARK: - Scrollable Order List
                ScrollView {
                    VStack(spacing: 16) {
                        TwoVerticalLabelCell(
                            dataModel: MyOrderValue.allCases,
                            topLabel: { $0.labelOlt },
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
    
    func fetchOrders(for type: MyOrderValue) {
        Task {
            SVProgressHUD.show()
            let param = ProductOrderListingRequest(type: type.apiValue)
            await viewModel.getMyOrderList(parameters: param)
            await SVProgressHUD.dismiss()
            getOrderSuccess()
        }
    }

    func getOrderSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.myOrderResponse
        if response.status == "success" {
            myOrderListArr = response.data ?? []
        } else {
           
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
        case .newOrders: return "New Orders"
        case .processing: return "Processing"
        case .completed: return "Completed"
        }
    }
}
#Preview {
    MyOrdersScreen()
}
