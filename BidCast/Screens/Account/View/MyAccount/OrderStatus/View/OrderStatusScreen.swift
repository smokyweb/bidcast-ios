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
import WebKit

struct OrderStatusScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var navigateToTab = false
    @StateObject var viewModel = OrderStatusViewModel()
    // QA Wave 2 Orange tier (#31/#32/#33/#34) — seller-side workflow VM.
    @StateObject private var workflowVM = OrderWorkflowViewModel()
    @Binding var productDetail : MyOrderModel?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var recieptUrl : String?
    // QA #8 — Open receipt PDF inside the app via in-app Safari sheet, not the Files download flow.
    @State private var showReceiptSheet = false
    // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): SwiftUI was rendering the
    // receipt sheet body with `recieptUrl` still nil even though we'd set it
    // BEFORE flipping `showReceiptSheet = true` (state batching race — NSLog
    // captured `[Receipt-Sheet] presenting with recieptUrl=nil` even though
    // the prior line showed `data=https://...`). Use `.sheet(item:)` with an
    // Identifiable wrapper so the sheet only presents once the URL exists,
    // atomically. Eliminates the empty-state-flash race.
    @State private var receiptSheetItem: ReceiptSheetItem? = nil
    // Drives the explicit "receipt isn't ready" empty-state sheet so it can
    // coexist with the .sheet(item:) URL-only flow above without colliding.
    @State private var showReceiptEmptyState = false
    // QA #5 — Shipping Details should navigate to the dedicated screen (or, if not present in this branch, show a sheet with tracking info).
    @State private var showShippingDetailsSheet = false
    // QA #33 — share / preview shipping label PDF after createLabel returns.
    @State private var labelShareItems: [Any] = []
    @State private var showLabelShareSheet = false
    // QA #31/#34 — seller workflow toast feedback.
    @State private var sellerActionToast: String? = nil
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    // Basecamp #9934033253 (2026-05-29): order-cancellation reason-entry flow.
    @State private var showCancelReasonSheet = false
    @State private var cancelReasonText = ""
    @State private var showRejectReasonSheet = false
    @State private var rejectReasonText = ""
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
                    
                    // QA Wave 2 Orange tier — seller actions only show when this screen was opened
                    // from the seller's My Orders flow (comeFrom == "myOrder").
                    if comeFrom == "myOrder", let order = productDetail {
                        SellerOrderWorkflowSection(
                            order: order,
                            workflowVM: workflowVM,
                            onActionFeedback: { msg in
                                sellerActionToast = msg
                                hudMsg = msg
                                showhud = true
                                // Refresh the order so the new status reflects in the UI.
                                fetchOrderDetail()
                            },
                            onLabelReady: { items in
                                labelShareItems = items
                                showLabelShareSheet = true
                            }
                        )
                    }
                    
                    // Basecamp #9934033253 (2026-05-29): order-cancellation flow.
                    if let order = productDetail {
                        // Basecamp #9934033253 (2026-06-04 return): `comeFrom == "myOrder"`
                        // is overloaded — BOTH the seller's MyOrdersScreen and the BUYER's
                        // Activity → Purchases → OrderTrackingView path pass comeFrom: "myOrder".
                        // Deriving isSeller from comeFrom therefore wrongly marked the BUYER as
                        // the seller, hiding the "Request Cancellation" button + reason sheet
                        // (Trey: "cancellation request doesn't give user entry field"). Determine
                        // the real role by comparing the logged-in user to the order's buyer id
                        // (order.user_id). If we ARE the buyer on this order, we're not the seller.
                        let buyerOnOrder = order.userID
                        let isSellerForOrder: Bool = {
                            guard let buyerId = buyerOnOrder else {
                                // Fall back to the old behaviour only when we can't tell.
                                return comeFrom == "myOrder"
                            }
                            return UserDefaults.userId != buyerId
                        }()
                        OrderCancellationSection(
                            order: order,
                            isSeller: isSellerForOrder,
                            isWorking: workflowVM.isWorking,
                            onRequestCancel: { showCancelReasonSheet = true },
                            onApprove: { approveCancellation() },
                            onReject: { showRejectReasonSheet = true }
                        )
                    }

                    // 🛡️ Buyer Protection (buyer-side only — not relevant to a seller managing their order)
                    if comeFrom != "myOrder" {
                        BuyerProtectionView()
                    }
                    
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
        //
        // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): Larry's QA caught the
        // sheet opening with a bare "Receipt URL is not available." text in
        // the middle of an otherwise empty modal. Two issues:
        //   1) The fallback UI looked broken (no header, no dismiss button).
        //   2) Reaching this branch at all means `recieptUrl` was nil/invalid
        //      AFTER `showReceiptSheet` was set to true — a state that
        //      should never happen via the normal `getRecieptSuccess()` flow
        //      (which only sets the sheet true when the URL is non-empty),
        //      but apparently does happen sometimes (race / stale state).
        // Now: validate the URL at the sheet-trigger boundary AND give the
        // fallback a proper modal layout with a Close button so users aren't
        // stuck staring at unstyled centered text.
        // Receipt sheet — only presents when we have a validated URL (atomic).
        .sheet(item: $receiptSheetItem) { item in
            ReceiptSafariView(url: item.url)
                .ignoresSafeArea()
        }
        // Separate empty-state sheet — shown when receipt truly isn't ready.
        .sheet(isPresented: $showReceiptEmptyState) {
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: { showReceiptEmptyState = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                Spacer()
                Image(systemName: "doc.text")
                    .font(.system(size: 40))
                    .foregroundColor(.gray.opacity(0.6))
                Text("Receipt not available yet")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.primary)
                Text("The receipt for this order isn't ready yet. Please check back once the order is processed.")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                Spacer()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        // Basecamp #9934033253 (2026-05-29): buyer cancellation reason entry.
        .sheet(isPresented: $showCancelReasonSheet) {
            CancellationReasonSheet(
                title: "Request Cancellation",
                message: "Tell the seller why you'd like to cancel this order. They'll review your request.",
                placeholder: "Reason for cancellation",
                confirmTitle: "Submit Request",
                text: $cancelReasonText,
                onConfirm: { reason in
                    showCancelReasonSheet = false
                    submitCancellationRequest(reason: reason)
                },
                onCancel: { showCancelReasonSheet = false }
            )
            .presentationDetents([.medium])
        }
        // Basecamp #9934033253 (2026-05-29): seller reject reason entry.
        .sheet(isPresented: $showRejectReasonSheet) {
            CancellationReasonSheet(
                title: "Reject Cancellation",
                message: "Optionally tell the buyer why you're rejecting this cancellation request.",
                placeholder: "Reason for rejection (optional)",
                confirmTitle: "Reject Request",
                text: $rejectReasonText,
                allowEmpty: true,
                onConfirm: { reason in
                    showRejectReasonSheet = false
                    rejectCancellation(reason: reason)
                },
                onCancel: { showRejectReasonSheet = false }
            )
            .presentationDetents([.medium])
        }
        // QA #5 — Present Shipping Details (tracking info) in a sheet.
        .sheet(isPresented: $showShippingDetailsSheet) {
            ShippingDetailsSheet(order: productDetail)
                .presentationDetents([.medium, .large])
        }
        // QA #33 — share / open shipping label PDF.
        .sheet(isPresented: $showLabelShareSheet) {
            if #available(iOS 16.0, *) {
                ActivityShareSheet(items: labelShareItems)
                    .presentationDetents([.medium, .large])
            } else {
                ActivityShareSheet(items: labelShareItems)
            }
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
    // MARK: - Basecamp #9934033253 (2026-05-29) order-cancellation actions
    private func submitCancellationRequest(reason: String) {
        guard let id = productDetail?.id else { return }
        Task {
            SVProgressHUD.show()
            let ok = await workflowVM.requestCancellation(orderId: id, reason: reason)
            await SVProgressHUD.dismiss()
            cancelReasonText = ""
            hudMsg = ok ? "Cancellation request sent to the seller." : (workflowVM.lastError ?? "Couldn't send the cancellation request.")
            showhud = true
            if ok { fetchOrderDetail() }
        }
    }

    private func approveCancellation() {
        guard let id = productDetail?.id else { return }
        Task {
            SVProgressHUD.show()
            let ok = await workflowVM.decideCancellation(orderId: id, decision: "approve")
            await SVProgressHUD.dismiss()
            hudMsg = ok ? "Cancellation approved." : (workflowVM.lastError ?? "Couldn't approve the cancellation.")
            showhud = true
            if ok { fetchOrderDetail() }
        }
    }

    private func rejectCancellation(reason: String) {
        guard let id = productDetail?.id else { return }
        Task {
            SVProgressHUD.show()
            let trimmed = reason.trimmingCharacters(in: .whitespacesAndNewlines)
            let ok = await workflowVM.decideCancellation(
                orderId: id,
                decision: "reject",
                rejectReason: trimmed.isEmpty ? nil : trimmed
            )
            await SVProgressHUD.dismiss()
            rejectReasonText = ""
            hudMsg = ok ? "Cancellation rejected." : (workflowVM.lastError ?? "Couldn't reject the cancellation.")
            showhud = true
            if ok { fetchOrderDetail() }
        }
    }

    func orderSuccess(){
        let response = viewModel.myOrderResponse
        if response.status == "success"{
            productDetail = response.data
            // Basecamp #9904579913 + #9922137437 (Trey 2026-05-21): inventory
            // quantity wasn't decrementing in product detail / inventory views
            // because those screens cache the product locally and only refetch
            // on productID change. Broadcast an order-placed event so any
            // visible product/inventory screen can refetch and reflect the
            // post-purchase quantity immediately.
            //
            // The backend itself decrements correctly (ApiController.php:759-760)
            // — this is purely a client-side cache-staleness fix.
            //
            // Pass the product id (and the quantity delta if we have it) in
            // userInfo so observers can target-refetch instead of refetching
            // everything they show.
            var userInfo: [String: Any] = [:]
            if let productId = response.data?.productID {
                userInfo["productId"] = productId
            }
            NotificationCenter.default.post(
                name: .bidcastOrderPlaced,
                object: nil,
                userInfo: userInfo
            )
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
        // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): Larry's QA caught the
        // Receipt button being flaky — first tap returned empty URL (lazy
        // server-side PDF generation), second tap returned the real URL.
        // Clear stale state up front AND retry once after a short delay if
        // the first response comes back success-but-empty (the backend is
        // generating the PDF and it's not ready yet).
        recieptUrl = nil
        receiptSheetItem = nil
        showReceiptEmptyState = false
        showReceiptSheet = false
        viewModel.errorMessage = nil

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
            SVProgressHUD.show(withStatus: "Loading receipt...")
            let param = getOrderReceiptRequest(order_id: orderId)
            await viewModel.getReceipt(parameters: param)

            // First-attempt error — surface immediately, don't retry.
            if let errorMsg = viewModel.errorMessage {
                await SVProgressHUD.dismiss()
                hudMsg = errorMsg
                showhud = true
                return
            }

            // If the first response came back success-but-empty, the backend
            // is most likely still generating the PDF. Wait briefly and
            // retry once before giving up. This eliminates the "first tap
            // shows empty, second tap shows real receipt" race Larry caught.
            //
            // (2026-05-24 17:10 EDT): 1.5s wasn't enough — Larry still saw
            // empty on first tap. Now we retry up to 3 times with 2s waits
            // (total ≤7s) before giving up. Also treat the literal string
            // "null" as empty (backend has been observed serializing missing
            // URLs as the string "null" rather than a real null/nil).
            func isUsableUrl(_ raw: String?) -> Bool {
                let trimmed = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty { return false }
                if trimmed.lowercased() == "null" { return false }
                guard let url = URL(string: trimmed) else { return false }
                return url.scheme == "http" || url.scheme == "https"
            }

            var attempts = 0
            while viewModel.recieptResponse.status == "success" && !isUsableUrl(viewModel.recieptResponse.data) && attempts < 3 {
                attempts += 1
                SVProgressHUD.show(withStatus: "Generating receipt (\(attempts)/3)...")
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s
                viewModel.errorMessage = nil
                await viewModel.getReceipt(parameters: param)
                if let errorMsg = viewModel.errorMessage {
                    await SVProgressHUD.dismiss()
                    hudMsg = errorMsg
                    showhud = true
                    return
                }
            }

            await SVProgressHUD.dismiss()
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
            //
            // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24 17:10): tightened the
            // empty check — backend has been observed serializing missing
            // URLs as the literal string "null" (and sometimes URLs without
            // an http(s) scheme). Treat all of those as empty so we show the
            // proper empty-state modal instead of an invalid-URL sheet.
            let trimmed = (response.data ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let lower = trimmed.lowercased()
            let isValidScheme: Bool = {
                guard let u = URL(string: trimmed) else { return false }
                return u.scheme == "http" || u.scheme == "https"
            }()
            if !trimmed.isEmpty && lower != "null" && isValidScheme,
               let url = URL(string: trimmed) {
                // QA #8 — Open in-app sheet via .sheet(item:) so presentation
                // is atomic with the URL value. No more state-batching race.
                recieptUrl = trimmed
                receiptSheetItem = ReceiptSheetItem(url: url)
            } else {
                showReceiptEmptyState = true
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

// MARK: - Receipt sheet item wrapper
// MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): wraps the validated receipt URL
// so `.sheet(item:)` can present atomically (avoids the state-batching race
// where `recieptUrl` would log as nil even though we set it before flipping
// the boolean sheet trigger).
struct ReceiptSheetItem: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - QA #8 ReceiptSafariView
// In-app PDF / web viewer for the receipt URL returned by the order-receipt API.
//
// MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): switched from SFSafariViewController
// to a WKWebView wrapper because SFSafariViewController honors the receipt
// HTML's `<meta name="apple-itunes-app">` tag and renders Apple's Smart App
// Banner ("Open in the BidSwipe app" with an OPEN button). Tapping OPEN is a
// no-op since the user is already in BidSwipe. WKWebView ignores that meta
// tag, so no spurious banner. Includes a Done button + URL bar via a wrapping
// NavigationStack so the user can dismiss the sheet.
struct ReceiptSafariView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ReceiptWebView(url: url)
                .ignoresSafeArea(edges: .bottom)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { dismiss() }
                    }
                }
                .navigationTitle("Receipt")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ReceiptWebView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.load(URLRequest(url: url))
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
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



// MARK: - QA Wave 2 Orange tier — Seller Order Workflow
// Renders progression buttons (#31), shipping label create + download/share (#32 / #33),
// and a "Mark Delivered" button that flips the order into Completed (#34).
// Only mounted when OrderStatusScreen is opened from the seller's My Orders flow.

import UIKit

struct SellerOrderWorkflowSection: View {
    let order: MyOrderModel
    @ObservedObject var workflowVM: OrderWorkflowViewModel
    /// Called after a successful API mutation; parent re-fetches the order to refresh UI.
    var onActionFeedback: (String) -> Void
    /// Called when createLabel returns a base64 PDF; parent presents the share sheet.
    var onLabelReady: ([Any]) -> Void
    
    private var currentStatus: String {
        (order.status ?? "").lowercased()
    }
    
    /// Allowed backend statuses: pending | processing | out_for_delivery | delivered.
    /// Decide which next-step button to surface based on where we currently are.
    private var nextStatusOption: (label: String, status: String)? {
        switch currentStatus {
        case "pending":
            return ("Mark Processing", "processing")
        case "processing":
            // Processing → next step is "Create label + mark shipped" (#32) handled separately.
            return nil
        case "out_for_delivery", "shipped":
            return ("Mark Delivered", "delivered")
        case "delivered", "completed":
            return nil
        default:
            return ("Mark Processing", "processing")
        }
    }
    
    private var showCreateLabel: Bool {
        currentStatus == "processing" && (order.tracking_number ?? "").isEmpty
    }
    private var showDownloadLabel: Bool {
        // Label was created (server set tracking_number) — let seller re-download / share it.
        !(order.tracking_number ?? "").isEmpty || workflowVM.lastLabel?.labelImage != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shippingbox.and.arrow.backward.fill")
                    .foregroundColor(.defaultTheme)
                Text("Seller Actions")
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.black)
                Spacer()
                Text(prettyStatus(currentStatus))
                    .font(.custom(poppinsMedium, size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(statusColor(currentStatus)))
            }
            
            // QA #31 / #34 — single progression button per state.
            if let next = nextStatusOption {
                Button(action: { progressStatus(to: next.status) }) {
                    progressButtonLabel(text: next.label, primary: true)
                }
                .disabled(workflowVM.isWorking)
            }
            
            // QA #32 — create USPS shipping label (transitions status to out_for_delivery once tracking comes back).
            if showCreateLabel {
                Button(action: { createLabelTapped() }) {
                    progressButtonLabel(text: "Create Shipping Label (USPS)", primary: false)
                }
                .disabled(workflowVM.isWorking)
            }
            
            // QA #33 — once a label exists, let the seller download or share the PDF.
            if showDownloadLabel {
                HStack(spacing: 12) {
                    Button(action: { shareExistingLabel() }) {
                        progressButtonLabel(text: "Share Label", primary: false)
                    }
                    .disabled(workflowVM.isWorking)
                }
            }
            
            if let err = workflowVM.lastError, !err.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(err)
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.red)
                    // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): When the
                    // backend returns the missing-shipping-details error,
                    // tell the seller WHERE to fix it. The fields live on
                    // the Product (EditProductScreen), not on the order.
                    if err.lowercased().contains("shipping details are missing") ||
                       err.lowercased().contains("weight") && err.lowercased().contains("mail class") {
                        Text("→ Open Inventory → tap this product → Edit to add weight, dimensions, mail class, and processing category.")
                            .font(.custom(poppinsRegular, size: 11))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Actions
    
    private func progressStatus(to status: String) {
        guard let id = order.id else { return }
        Task {
            let ok = await workflowVM.changeStatus(orderId: id, status: status, trackingNumber: nil)
            await MainActor.run {
                onActionFeedback(ok ? "Order moved to \(prettyStatus(status))." : (workflowVM.lastError ?? "Update failed."))
            }
        }
    }
    
    private func createLabelTapped() {
        guard let id = order.id else { return }
        Task {
            if let data = await workflowVM.createLabel(orderId: id) {
                // After label exists, automatically advance the order to out_for_delivery with the new tracking #.
                if let trk = data.trackingNumber, !trk.isEmpty {
                    _ = await workflowVM.changeStatus(orderId: id, status: "out_for_delivery", trackingNumber: trk)
                }
                await MainActor.run {
                    presentLabelPDF(base64: data.labelImage, orderId: id)
                    onActionFeedback("Shipping label created. Tracking: \(data.trackingNumber ?? "—")")
                }
            } else {
                // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): the inline
                // `workflowVM.lastError` text below the button already shows
                // this same message in red. Firing onActionFeedback() here
                // would surface a duplicate toast at the top of the screen
                // for the same failure (Larry's QA caught the duplicate).
                // Inline error stays as the canonical feedback; skip the toast.
                // We also intentionally skip fetchOrderDetail() on failure
                // since the order didn't change.
            }
        }
    }
    
    private func shareExistingLabel() {
        if let base64 = workflowVM.lastLabel?.labelImage {
            presentLabelPDF(base64: base64, orderId: order.id ?? 0)
        } else if let urlString = order.label_url, let url = URL(string: urlString) {
            // Server already persisted label_url on the Order — share that URL.
            onLabelReady([url])
        } else {
            onActionFeedback("No label available yet — tap Create Shipping Label first.")
        }
    }
    
    private func presentLabelPDF(base64: String?, orderId: Int) {
        guard let b64 = base64,
              let fileURL = OrderWorkflowViewModel.writeLabelPDFToTempFile(b64, orderId: orderId)
        else {
            onActionFeedback("Could not decode label PDF.")
            return
        }
        onLabelReady([fileURL])
    }
    
    // MARK: - Helpers
    
    private func progressButtonLabel(text: String, primary: Bool) -> some View {
        HStack {
            if workflowVM.isWorking {
                ProgressView().tint(primary ? .white : .defaultTheme)
            }
            Text(text)
                .font(.custom(poppinsSemiBold, size: 14))
                .foregroundColor(primary ? .white : .defaultTheme)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(primary ? Color.defaultTheme : Color.defaultTheme.opacity(0.10))
        )
    }
    
    private func prettyStatus(_ s: String) -> String {
        switch s {
        case "pending":           return "Pending"
        case "processing":        return "Processing"
        case "out_for_delivery":  return "Out for Delivery"
        case "delivered":         return "Delivered"
        case "completed":         return "Completed"
        case "shipped":           return "Shipped"
        default: return s.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
    
    private func statusColor(_ s: String) -> Color {
        switch s {
        case "pending":          return .gray
        case "processing":       return .orange
        case "out_for_delivery", "shipped": return .blue
        case "delivered", "completed":      return .green
        default: return .gray
        }
    }
}

// MARK: - QA #33 — UIActivityViewController wrapper for sharing the label PDF.
struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - Basecamp #9934033253 (2026-05-29) — Order Cancellation Section
// Matches the PWA UX: buyer can request a cancellation (with a reason) only
// while the order has NOT shipped/delivered/been cancelled. Once requested,
// shows the pending/approved/rejected state. On the seller side
// (isSeller == true) a pending request surfaces Approve / Reject controls.
struct OrderCancellationSection: View {
    let order: MyOrderModel
    let isSeller: Bool
    let isWorking: Bool
    var onRequestCancel: () -> Void
    var onApprove: () -> Void
    var onReject: () -> Void

    // Normalised order status (shipping_status preferred, falls back to status).
    private var effectiveStatus: String {
        let s = (order.shipping_status ?? order.status ?? "").lowercased()
        return s
    }

    // Cancellation workflow status: nil/"" = none, "pending", "approved", "rejected".
    private var cancelStatus: String {
        (order.cancellationStatus ?? "").lowercased()
    }

    // Buyer may request cancellation only before the order has shipped /
    // been delivered / already cancelled, and only when there isn't already
    // a pending or decided request.
    private var canRequestCancellation: Bool {
        let blockedStatuses = ["shipped", "out_for_delivery", "delivered", "completed", "cancelled", "canceled"]
        if blockedStatuses.contains(effectiveStatus) { return false }
        // tracking_number present means a label was created / shipped.
        if !(order.tracking_number ?? "").isEmpty { return false }
        // No existing request in flight or decided.
        if ["pending", "approved", "rejected", "requested"].contains(cancelStatus) { return false }
        return true
    }

    private var hasPendingRequest: Bool {
        cancelStatus == "pending" || cancelStatus == "requested"
    }

    var body: some View {
        // Only render when there's something meaningful to show.
        if canRequestCancellation || !cancelStatus.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "xmark.octagon")
                        .foregroundColor(.defaultTheme)
                    Text("Cancellation")
                        .font(.custom(poppinsBold, size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }

                // Existing request state (buyer + seller both see this).
                if !cancelStatus.isEmpty {
                    cancellationStateView
                }

                // Buyer: request button.
                if !isSeller && canRequestCancellation {
                    Button(action: onRequestCancel) {
                        Text("Request Cancellation")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.defaultTheme)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.defaultTheme.opacity(0.10))
                            )
                    }
                    .disabled(isWorking)
                }

                // Seller: approve / reject a pending request.
                if isSeller && hasPendingRequest {
                    HStack(spacing: 12) {
                        Button(action: onApprove) {
                            Text("Approve")
                                .font(.custom(poppinsSemiBold, size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.green))
                        }
                        .disabled(isWorking)

                        Button(action: onReject) {
                            Text("Reject")
                                .font(.custom(poppinsSemiBold, size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
                        }
                        .disabled(isWorking)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
    }

    @ViewBuilder
    private var cancellationStateView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(stateLabel)
                    .font(.custom(poppinsMedium, size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(stateColor))
            }
            if let reason = order.cancellationReason, !reason.isEmpty {
                Text("Reason: \(reason)")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
            }
            if cancelStatus == "rejected",
               let rej = order.cancellationRejectReason, !rej.isEmpty {
                Text("Seller's note: \(rej)")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
            }
        }
    }

    private var stateLabel: String {
        switch cancelStatus {
        case "pending", "requested": return "Cancellation Requested"
        case "approved":             return "Cancellation Approved"
        case "rejected":             return "Cancellation Rejected"
        default:                     return cancelStatus.capitalized
        }
    }

    private var stateColor: Color {
        switch cancelStatus {
        case "pending", "requested": return .orange
        case "approved":             return .green
        case "rejected":             return .red
        default:                     return .gray
        }
    }
}

// MARK: - Basecamp #9934033253 (2026-05-29) — Reason entry sheet
// Reused for the buyer's cancellation reason and the seller's reject reason.
struct CancellationReasonSheet: View {
    let title: String
    let message: String
    let placeholder: String
    let confirmTitle: String
    @Binding var text: String
    var allowEmpty: Bool = false
    var onConfirm: (String) -> Void
    var onCancel: () -> Void

    @FocusState private var focused: Bool

    private var trimmed: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var canConfirm: Bool {
        allowEmpty || !trimmed.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.custom(poppinsBold, size: 18))
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 16)

            Text(message)
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.gray)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                if text.isEmpty {
                    Text(placeholder)
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                }
                TextEditor(text: $text)
                    .focused($focused)
                    .font(.custom(poppinsRegular, size: 14))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .frame(height: 110)
                    .scrollContentBackground(.hidden)
            }
            .frame(height: 110)

            Button(action: { onConfirm(trimmed) }) {
                Text(confirmTitle)
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(canConfirm ? Color.defaultTheme : Color.gray.opacity(0.4))
                    )
            }
            .disabled(!canConfirm)

            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear { focused = true }
    }
}
