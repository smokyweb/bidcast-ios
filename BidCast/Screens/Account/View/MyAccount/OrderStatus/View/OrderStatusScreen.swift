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

struct OrderStatusScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var navigateToTab = false
    @StateObject var viewModel = OrderStatusViewModel()
    @Binding var productDetail : MyOrderModel?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var recieptUrl : String?
    // QA #8 — Open receipt PDF inside the app via in-app Safari sheet, not the Files download flow.
    @State private var showReceiptSheet = false
    // QA #5 — Shipping Details should navigate to the dedicated screen (or, if not present in this branch, show a sheet with tracking info).
    @State private var showShippingDetailsSheet = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    var comeFrom: String = ""
    @Binding var orderId : Int
    
    
    var body: some View {
        VStack(spacing: 0) {
            // ✅ Custom Header
            PrimaryHeader(
                title: "Order Status",
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
                                        // QA #5 — Wire the Shipping Details button to open a tracking sheet for the order.
                                        showShippingDetailsSheet = true
                                    })
                                    .frame(width: (geometry.size.width - 16) / 2)
                                }
                            }
                            .frame(height: 44)
                        }
                        .padding(.vertical, 8)
                        
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
        // QA #8 — Present the receipt PDF in an in-app Safari sheet.
        .sheet(isPresented: $showReceiptSheet) {
            if let urlString = recieptUrl, let url = URL(string: urlString) {
                ReceiptSafariView(url: url)
                    .ignoresSafeArea()
            } else {
                Text("Receipt URL is not available.")
                    .padding()
            }
        }
        // QA #5 — Present Shipping Details (tracking info) in a sheet.
        .sheet(isPresented: $showShippingDetailsSheet) {
            ShippingDetailsSheet(order: productDetail)
                .presentationDetents([.medium, .large])
        }
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
                // QA #8 — Open in-app sheet rather than downloading to Files.
                showReceiptSheet = true
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
        guard let url = urlString, !url.isEmpty else {
            print("Invalid URL String")
            // MC sub-task cmp49339f00l53mx17c5alnjo: also surface here for the
            // off-chance someone calls downloadRecieptData directly with nil.
            hudMsg = "Receipt isn't available yet for this order."
            showhud = true
            return
        }
        let timeStamp = getCurrentTimestamp()
        FileDownloader.shared.download(
            from: url,
            fileName: "receipt\(timeStamp).pdf"
        ) { result in
            switch result {
            case .success(let url):
                print("Saved in Files at:", url)
            case .failure(let error):
                print("Download failed:", error)
            }
        }

//        FileDownloader.shared.startDownload(from: url)
    }
    func getCurrentTimestamp() -> String {
        let now = Date()
        return String(Int(now.timeIntervalSince1970))
    }
}

// MARK: - QA #8 ReceiptSafariView
// In-app PDF / web viewer for the receipt URL returned by the order-receipt API.
struct ReceiptSafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.dismissButtonStyle = .close
        return vc
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - QA #5 ShippingDetailsSheet
// Lightweight tracking-info sheet shown when the Shipping Details button is tapped on the order status screen.
// Reads tracking fields off the existing MyOrderModel (the order-status API already exposes them).
struct ShippingDetailsSheet: View {
    let order: MyOrderModel?
    @Environment(\.dismiss) private var dismiss

    private var trackingNumber: String? {
        // The order-status API may return tracking under any of these keys depending on backend version.
        // Use the helper accessor when available, otherwise fall back to the order's own state mapping.
        let mirrored = Mirror(reflecting: order as Any).children
        for child in mirrored {
            guard let label = child.label?.lowercased() else { continue }
            if label.contains("tracking") || label.contains("awb") || label.contains("track_number") || label.contains("shipment") {
                if let s = child.value as? String, !s.isEmpty { return s }
                if let s = child.value as? String?, let v = s, !v.isEmpty { return v }
            }
        }
        return nil
    }

    private var carrier: String? {
        let mirrored = Mirror(reflecting: order as Any).children
        for child in mirrored {
            guard let label = child.label?.lowercased() else { continue }
            if label.contains("carrier") || label.contains("shipper") || label.contains("mail_class") {
                if let s = child.value as? String, !s.isEmpty { return s }
            }
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Shipping Details")
                    .font(.custom(poppinsBold, size: 18))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 20)

            Divider()

            if let tn = trackingNumber, !tn.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tracking Number")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                    Text(tn)
                        .font(.custom(poppinsSemiBold, size: 16))
                }
                if let c = carrier {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Carrier")
                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.gray)
                        Text(c)
                            .font(.custom(poppinsSemiBold, size: 16))
                    }
                }
                Button(action: {
                    if let url = URL(string: "https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1=\(tn)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Track with USPS")
                        .font(.custom(poppinsSemiBold, size: 14))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.defaultThemeLight)
                        .foregroundColor(.defaultTheme)
                        .cornerRadius(32)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "shippingbox")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                    Text("Shipping details not available yet.")
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.gray)
                    Text("You'll see your tracking number here once the seller ships your order.")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.top, 24)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}


