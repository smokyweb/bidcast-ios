//
//  OrderStatusScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast
import SafariServices

// MARK: - SafariView — in-app PDF/receipt viewer (MC wave-2 #8)
private struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// Identifiable wrapper so URL can drive .fullScreenCover(item:)
private struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct OrderStatusScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var navigateToTab = false
    @StateObject var viewModel = OrderStatusViewModel()
    @Binding var productDetail : MyOrderModel?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var recieptUrl : String?
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    // MC Wave 4 cmpbefoaj00033ghgs38av42u — #31/#34 seller status actions
    @State private var showStatusConfirm = false
    @State private var pendingStatus: String = ""
    @State private var isChangingStatus = false
    // MC Wave 4 — #32 tracking number sheet
    @State private var showTrackingSheet = false
    @State private var trackingInput: String = ""
    // MC Wave 4 — #33 Get Label
    @State private var isFetchingLabel = false
    @State private var labelUrl: String? = nil
    var comeFrom: String = ""
    @Binding var orderId : Int
    // MC wave-2 #5/#8/#9: Shipping Details sheet + in-app receipt viewer
    @State private var showShippingDetailsSheet = false
    @State private var receiptURLToShow: IdentifiableURL? = nil
    
    
    var body: some View {
        VStack(spacing: 0) {
            // ✅ Custom Header
            PrimaryHeader(
                title: comeFrom == "myOrder" ? "Order Management" : "Order Status",
                isForLogo: false,
                leadingImgArr: ["chevron.left"],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(Color.white)
            .frame(height: 50)
            
            ScrollView {
                VStack(spacing: 24) {
                    // 📦 Preparing Icon
                    VStack(spacing: 8) {
                        Image(systemName: "shippingbox.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.defaultTheme)
                        
                        Text("Preparing Your Order")
                            .font(.custom(poppinsBold, size: 18.0))
                            .foregroundColor(.black)
                        
                        Text("Send this purchase as a gift to someone special")
                            .font(.custom(poppinsMedium, size: 13.0))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    
                    // 📦 Product Details
                    if let order = productDetail {
                        OrderProductCardView(order: order)
                        ShippingStatusView(order: order)
                        DeliveryAddressView(order: order)
                        
                        // 📃 Equal Width Buttons
                        HStack(spacing: 16) {
                            GeometryReader { geometry in
                                HStack(spacing: 16) {
                                    OutlinedButtonView(title: "Receipt", onTap: {
                                        fetchReciept()
                                    })
                                    .frame(width: (geometry.size.width - 16) / 2)
                                    
                                    OutlinedButtonView(title: "Shipping Details", onTap: {
                                        // MC wave-2 #5/#9: was empty — now shows delivery address sheet
                                        showShippingDetailsSheet = true
                                    })
                                    .frame(width: (geometry.size.width - 16) / 2)
                                }
                            }
                            .frame(height: 44)
                        }
                        .padding(.vertical, 8)

                        // 🏪 MC Wave 4 #31/#34 — Seller order progression actions
                        // comeFrom == "myOrder" means the seller is viewing this from MyOrdersScreen
                        if comeFrom == "myOrder" {
                            sellerActionButtons(order: order)
                        }
                        
                    }
                    
                    // 🛡️ Buyer Protection
                    BuyerProtectionView()
                    
                    Spacer()
                }
                .padding()
            }
            
            if comeFrom == "buyNow" {
                // 🔙 Home Button
                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
                    navigateToTab = true
                }) {
                    Text("Home")
                        .font(.custom(poppinsSemiBold, size: 16.0))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme)
                        .cornerRadius(32)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
            CusNavLink(doNavigate: $navigateToTab, destination:
                TabbarScreen()
                    .environmentObject(TabBarRouter())
            )
        }
        .background(Color.backGround.ignoresSafeArea())
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onFirstAppear {
            fetchOrderDetail()
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
        // MC wave-2 #5/#9: Shipping Details bottom sheet
        .bottomSheet(
            isPresented: $showShippingDetailsSheet,
            height: screenHeight * 0.4,
            topBarCornerRadius: 25,
            showTopIndicator: true
        ) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Shipping Details")
                    .font(.custom(poppinsSemiBold, size: 18))
                    .padding(.top, 8)
                if let order = productDetail {
                    DeliveryAddressView(order: order)
                } else {
                    Text("No shipping information available.")
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        // MC wave-2 #8: in-app receipt viewer via SFSafariViewController
        .fullScreenCover(item: $receiptURLToShow) { wrapped in
            SafariView(url: wrapped.url)
                .ignoresSafeArea()
        }
                // MC Wave 4 #32 — Tracking number entry sheet
        .sheet(isPresented: $showTrackingSheet) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Enter Tracking Number")
                        .font(.custom(poppinsBold, size: 18))
                        .padding(.top, 24)
                    Text("Enter the USPS tracking number for this shipment. The buyer will be notified.")
                        .font(.custom(poppinsMedium, size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    TextField("e.g. 9400100000000000000001", text: $trackingInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .keyboardType(.asciiCapable)
                        .autocapitalization(.allCharacters)
                    Button(action: {
                        showTrackingSheet = false
                        changeOrderStatusWithTracking(to: "out_for_delivery", tracking: trackingInput)
                    }) {
                        Text("Confirm Shipment")
                            .font(.custom(poppinsSemiBold, size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(trackingInput.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.orange)
                            .cornerRadius(28)
                            .padding(.horizontal)
                    }
                    .disabled(trackingInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    Spacer()
                }
                .navigationBarItems(leading: Button("Cancel") { showTrackingSheet = false })
            }
            .presentationDetents([.fraction(0.45)])
            .presentationCornerRadius(25)
        }
    }
    

    
    func fetchOrderDetail(){
        Task {
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            let param = ProductOrderDetailRequest(order_id: orderId)
            await viewModel.getMyOrderList(parameters: param)
            await SVProgressHUD.dismiss()
            if let errorMsg = viewModel.errorMessage{
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: errorMsg ,
                    primaryBtnText: "Ok",
                    secondaryBtnText: ""
                   
                )
                showError = true
            }
            orderSuccess()
        }
    }
    func orderSuccess(){
        let response = viewModel.myOrderResponse
        if response.status == "success"{
            productDetail = response.data
        }else{
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: response.message ?? "" ,
                primaryBtnText: "Ok",
                secondaryBtnText: ""
               
            )
            showError = true
        }
    }
    
    func fetchReciept(){
        Task {
            guard let orderID = productDetail?.id else {
                hudMsg = "Order Id is not present"
                showhud = true
                return
            }
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            let param = getOrderReceiptRequest(order_id: orderId)
            await viewModel.getReceipt(parameters: param)
            await SVProgressHUD.dismiss()
            if let errorMsg = viewModel.errorMessage {
                hudMsg = errorMsg
                showhud = true
                return
            }
            getRecieptSuccess()
        }
    }
    
//    func getPurchaseSuccess() {
//       guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.dismiss()
//        let response = viewModel.purchaseDetailResponse
//        if response.status == "success" {
//            productDetail = response.data
//        }else {
//            
//        }
//    }
    
//    func getPurchaseSuccess() {
//       guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.dismiss()
//        let response = viewModel.purchaseDetailResponse
//        if response.status == "success" {
//            productDetail = response.data
//        }else {
//            
//        }
//    }
    
    func getRecieptSuccess() {
       guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.dismiss()
        let response = viewModel.recieptResponse
        if response.status == "success" {
            // MC sub-task cmp49339f00l53mx17c5alnjo (Trey 2026-05-13):
            // a successful response with an empty/missing data URL used to
            // silently no-op, leaving the user with a blank screen. Surface a
            // clear message so they know the receipt isn't available yet.
            if let url = response.data, !url.isEmpty {
                recieptUrl = url
                downloadRecieptData(with: url)
            } else {
                hudMsg = "Receipt isn't available yet for this order."
                showhud = true
            }
        } else {
            // Same ticket: was a silent failure. Now surface server error or
            // a generic fallback.
            let serverMsg = (response.message ?? "").trimmingCharacters(in: .whitespaces)
            hudMsg = serverMsg.isEmpty ? "Couldn't load the receipt. Please try again." : serverMsg
            showhud = true
        }
    }
    
    func downloadRecieptData(with urlString: String?) {
        guard let urlStr = urlString, !urlStr.isEmpty, let url = URL(string: urlStr) else {
            print("Invalid URL String")
            // MC sub-task cmp49339f00l53mx17c5alnjo: surface missing receipt.
            hudMsg = "Receipt isn't available yet for this order."
            showhud = true
            return
        }
        // MC wave-2 #8: open receipt in-app via SFSafariViewController.
        receiptURLToShow = IdentifiableURL(url: url)
    }
    func getCurrentTimestamp() -> String {
        let now = Date()
        return String(Int(now.timeIntervalSince1970))
    }

    // MARK: - MC Wave 4 #31/#34 cmpbefoaj00033ghgs38av42u — Seller action buttons
    @ViewBuilder
    func sellerActionButtons(order: MyOrderModel) -> some View {
        let status = order.status?.lowercased() ?? ""
        VStack(spacing: 12) {
            // #31: New/Pending order → seller can mark as Processing
            if status == "pending" || status == "new_order" {
                Button(action: {
                    pendingStatus = "processing"
                    showStatusConfirm = true
                }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Mark as Processing")
                            .font(.custom(poppinsSemiBold, size: 15))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.defaultTheme)
                    .cornerRadius(28)
                    .padding(.horizontal)
                }
                .disabled(isChangingStatus)
            }

            // #31: Processing order → seller can mark as Shipped (out_for_delivery)
            if status == "processing" {
                // #32: Show tracking number input before marking shipped
                Button(action: {
                    trackingInput = order.trackingNumber ?? ""
                    showTrackingSheet = true
                }) {
                    HStack {
                        Image(systemName: "shippingbox")
                        Text("Mark as Shipped")
                            .font(.custom(poppinsSemiBold, size: 15))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .cornerRadius(28)
                    .padding(.horizontal)
                }
                .disabled(isChangingStatus)

                // #33: Get USPS Label button
                Button(action: {
                    fetchLabel(orderId: order.id ?? 0)
                }) {
                    HStack {
                        if isFetchingLabel {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "doc.text.fill")
                        }
                        Text(isFetchingLabel ? "Generating Label..." : "Get Shipping Label")
                            .font(.custom(poppinsSemiBold, size: 15))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.2, green: 0.5, blue: 0.85))
                    .cornerRadius(28)
                    .padding(.horizontal)
                }
                .disabled(isFetchingLabel || isChangingStatus)
            }

            // Show existing tracking number if set
            if let tn = order.trackingNumber, !tn.isEmpty {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tracking Number")
                            .font(.custom(poppinsMedium, size: 11))
                            .foregroundColor(.gray)
                        Text(tn)
                            .font(.custom(poppinsSemiBold, size: 13))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button(action: { UIPasteboard.general.string = tn }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.defaultTheme)
                    }
                }
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(10)
                .padding(.horizontal)
            }

            // #34: Out-for-delivery → seller can mark as Delivered (triggers Stripe capture)
            if status == "out_for_delivery" {
                Button(action: {
                    pendingStatus = "delivered"
                    showStatusConfirm = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Mark as Delivered")
                            .font(.custom(poppinsSemiBold, size: 15))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .cornerRadius(28)
                    .padding(.horizontal)
                }
                .disabled(isChangingStatus)
            }
        }
        .padding(.vertical, 8)
        .alert(isPresented: $showStatusConfirm) {
            let statusLabel = pendingStatus == "processing" ? "Processing"
                : pendingStatus == "out_for_delivery" ? "Shipped"
                : "Delivered"
            let warningNote = pendingStatus == "delivered"
                ? " This will capture the buyer's payment and cannot be undone."
                : ""
            return Alert(
                title: Text("Mark as \(statusLabel)?"),
                message: Text("Confirm you want to update this order to \(statusLabel).\(warningNote)"),
                primaryButton: .default(Text("Confirm")) {
                    changeOrderStatus(to: pendingStatus)
                },
                secondaryButton: .cancel()
            )
        }
    }

    func changeOrderStatus(to newStatus: String) {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            isChangingStatus = true
            SVProgressHUD.show()
            let param = ChangeOrderStatusRequest(order_id: orderId, status: newStatus)
            await viewModel.changeOrderStatus(parameters: param)
            await SVProgressHUD.dismiss()
            isChangingStatus = false
            if let err = viewModel.errorMessage, !err.isEmpty {
                hudMsg = err
                showhud = true
                return
            }
            // Refresh the order detail
            fetchOrderDetail()
            let statusLabel = newStatus == "processing" ? "Processing"
                : newStatus == "out_for_delivery" ? "Shipped"
                : "Delivered"
            hudMsg = "Order marked as \(statusLabel) ✔️"
            showhud = true
        }
    }

    // MC Wave 4 #32 — Mark as Shipped with tracking number
    func changeOrderStatusWithTracking(to newStatus: String, tracking: String) {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"; showhud = true; return
            }
            isChangingStatus = true
            SVProgressHUD.show()
            var param = ChangeOrderStatusRequest(order_id: orderId, status: newStatus)
            let tn = tracking.trimmingCharacters(in: .whitespaces)
            if !tn.isEmpty { param.tracking_number = tn }
            await viewModel.changeOrderStatus(parameters: param)
            await SVProgressHUD.dismiss()
            isChangingStatus = false
            if let err = viewModel.errorMessage, !err.isEmpty {
                hudMsg = err; showhud = true; return
            }
            fetchOrderDetail()
            hudMsg = "Order marked as Shipped ✔️"
            showhud = true
        }
    }

    // MC Wave 4 #33 — Get USPS shipping label
    func fetchLabel(orderId: Int) {
        guard !isFetchingLabel else { return }
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"; showhud = true; return
            }
            isFetchingLabel = true
            SVProgressHUD.show()
            let param = CreateLabelRequest(order_id: orderId)
            await viewModel.createLabel(parameters: param)
            await SVProgressHUD.dismiss()
            isFetchingLabel = false
            if let err = viewModel.errorMessage, !err.isEmpty {
                hudMsg = err; showhud = true; return
            }
            let resp = viewModel.createLabelResponse
            if resp.status == "success" {
                if let url = resp.data?.labelUrl, !url.isEmpty,
                   let labelURL = URL(string: url) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(labelURL)
                    }
                } else if let tn = resp.data?.trackingNumber {
                    hudMsg = "Label generated. Tracking: \(tn)"
                    showhud = true
                } else {
                    hudMsg = "Label generated successfully ✔️"
                    showhud = true
                }
                fetchOrderDetail()
            } else {
                hudMsg = resp.message ?? "Failed to generate label"
                showhud = true
            }
        }
    }

}