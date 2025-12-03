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
    
    
    var body: some View {
        VStack(spacing: 0) {
            // ✅ Custom Header
            PrimaryHeader(
                title: "Order Status",
                isForLogo: false,
                leadingImgArr: [.icBack],
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
                            .font(.title3).bold()
                        
                        Text("Send this purchase as a gift to someone special")
                            .font(.subheadline)
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
            /*
            @State ->
             a property wrapper type that can read and write values managed by swiftUI
             you can not modify properity of struct directly because struct is value type
             when you declared  a property as @state the  its value is stored and managed by swiftUI outside of struct to make it modify the value
             when ever state property valuue changes, the view invalidates its current state and re-renders the body property to reflect the updated state
             @Binding ->
                a property wrapper type that can read and write a value owned by a source of truth outside of the current view
             @ObserableObject ->
             
            */
            if comeFrom == "buyNow" {
                // 🔙 Home Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Home")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .background(Color(red: 240/255, green: 247/255, blue: 255/255).ignoresSafeArea())
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onFirstAppear {
//            fetchPurchaseDetail()
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
    
//    func fetchPurchaseDetail(){
//        Task {
//           guard Reachability.isConnectedToNetwork() else {
//                hudMsg = "No Internet Connection"
//                showhud = true
//                return
//            }
//            SVProgressHUD.show()
//            let param = ProductPurchaseDetailRequest(shipping_id: shippingID,product_id: productID)
//            await viewModel.getPurchaseDetail(parameters: param)
//            await SVProgressHUD.dismiss()
//            getPurchaseSuccess()
//        }
//    }
    
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
            let param = OrderRecieptRequest(order_id: orderID)
            await viewModel.getReceipt(parameters: param)
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
            recieptUrl = response.data
            downloadRecieptData(with: recieptUrl)
        } else {
            
        }
    }
    
    func downloadRecieptData(with urlString: String?) {
        guard let url = urlString, !url.isEmpty else {
            print("Invalid URL String")
            return
        }
        FileDownloader.shared.startDownload(from: url)
    }
}


