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
    @State private var productDetail : ProductPurchaseModel?
    @State private var recieptUrl : String?
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    @State var productID : Int = 2
    @State var shippingID : Int = 1
    @State var orderID : Int = 0
    
    
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
                            .foregroundColor(.red)
                        
                        Text("Preparing Your Order")
                            .font(.title3).bold()
                        
                        Text("The seller is preparing your package for shipping")
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
                    }
                    
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

                    
                    // 🛡️ Buyer Protection
                    BuyerProtectionView()
                    
                    Spacer()
                }
                .padding()
            }
            
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
        .background(Color(red: 240/255, green: 247/255, blue: 255/255).ignoresSafeArea())
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onFirstAppear {
            fetchPurchaseDetail()
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
    
    func fetchPurchaseDetail(){
        Task {
            SVProgressHUD.show()
            let param = ProductPurchaseDetailRequest(shipping_id: shippingID,product_id: productID)
            await viewModel.getPurchaseDetail(parameters: param)
            await SVProgressHUD.dismiss()
            getPurchaseSuccess()
        }
    }
    
    func fetchReciept(){
        Task {
            SVProgressHUD.show()
            let param = OrderRecieptRequest(order_id: orderID)
            await viewModel.getReceipt(parameters: param)
            await SVProgressHUD.dismiss()
            getPurchaseSuccess()
        }
    }
    
    func getPurchaseSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.purchaseDetailResponse
        if response.status == "success" {
            productDetail = response.data
        }else {
            
        }
    }
    
    func getRecieptSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.recieptResponse
        if response.status == "success" {
            recieptUrl = response.data
        } else {
            
        }
    }
}


