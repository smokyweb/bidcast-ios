//
//  OrderStatusScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

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
                                        // Optionally handle this as well
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


