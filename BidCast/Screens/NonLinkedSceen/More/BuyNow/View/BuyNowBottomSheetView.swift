//
//  NotifyMeBottomSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct BuyNowBottomSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = BuyNowViewModel()
    @State var cardViewModel = PaymentViewModel()
    @State var cardArr : [PaymentProfile] = []
    @State var selectedCardIndex: Int = 0
    @State var orderDetails : BuyNowModel?
    @State private var isLoading = false
    @State private var showError = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    @Binding var isPresented: Bool
    @State private var isGift = false
    @State var navigateToOrderStatus : Bool = false
    @State var navigateToGiftScreen : Bool = false
    
    var orderID : Int = 0
    @State private var promoCode = ""
    var productImage: String = ""
    var productTitle: String = ""
    var productColor: String = ""
    var shippingAddress: String = ""
    var subtotal: Double = 0.0
    var shipping: Double = 0.0
    var tax: Double = 0.0
    var shippingID: Int = 0
    var productID : Int = 0
    var cardID: String = ""
    var shippingCharges : Int = 0
    var taxAmount : Int = 0
    var sendAsGift : Int = 0
    var giftUserID : Int = 0
    var giftMsg : String = ""
    
    var onConfirmPurchase: () -> Void
    
    var total: Double {
        subtotal + shipping + tax
    }
    
    var selectedCardID: String {
        cardArr.indices.contains(selectedCardIndex) ? (cardArr[selectedCardIndex].customerPaymentProfileId ?? "") : ""
    }

    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Buy Now")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                    }
                }
                Divider()
                
                // Product Info
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: productImage)) { image in
                        image.resizable()
                    }placeholder: {
                        Color.gray.opacity(0.3)
                    }
                        .frame(width: 56, height: 56)
                        .cornerRadius(8)
                    VStack(alignment: .leading) {
                        Text(productTitle)
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        Text(productColor)
                            .font(.custom(poppinsSemiBold, size: 11.0))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                Divider()
                
                // Gift Toggle
                HStack {
                    Label("Send as a gift?", systemImage: "gift")
                    Spacer()
                    Toggle("", isOn: $isGift)
                        .labelsHidden()
                        .onChange(of: isGift) { newValue in
                            if newValue {
                                navigateToGiftScreen = true
                            }
                        }
                }
                .padding(.vertical, 8)
                Divider()
                
                // Payment Method
                HStack {
                    VStack(alignment: .leading) {
                        Text("Payment Method")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        HStack {
                            Image("visa") // Replace with actual asset if needed
                                .resizable()
                                .frame(width: 32, height: 20)
                            Text("•••• \(cardArr[safe: selectedCardIndex]?.payment?.creditCard?.cardNumber ?? "0000")")
                                .font(.custom(poppinsSemiBold, size: 13.0))

                        }
                    }
                    Spacer()
                    Button("Change") {}.foregroundColor(.red)
                }
                Divider()
                
                // Shipping Address
                HStack {
                    VStack(alignment: .leading) {
                        Text("Shipping Address")
                            .font(.custom(poppinsSemiBold, size: 12.0))
                        Text(shippingAddress)
                            .font(.custom(poppinsSemiBold, size: 12.0))
                    }
                    Spacer()
                    Button("Change") {}.foregroundColor(.red)
                }
                Divider()
                
                // Promo Code
                TextField("Enter promo code", text: $promoCode)
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                Divider()
                
                // Summary
                VStack(spacing: 4) {
                    SummaryRow(label: "Subtotal", value: subtotal)
                    SummaryRow(label: "Shipping", value: shipping)
                    SummaryRow(label: "Tax", value: tax)
                    Divider()
                    SummaryRow(label: "Total", value: total, isBold: true)
                }
                

                // Confirm Button
                Button(action: {
                    BuyProductRequest()
                }) {
                    Text("Confirm Purchase")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme)
                        .cornerRadius(14)
                }

            }
            .padding()
            CusNavLink(
                doNavigate: $navigateToGiftScreen,
                destination: SendGiftScreen(
                    orderID: orderID, promoCode: promoCode,
                    productImage: productImage,
                    productTitle: productTitle,
                    productColor: productColor,
                    shippingAddress: shippingAddress,
                    subtotal: subtotal,
                    shipping: shipping,
                    tax: tax,
                    shippingID: shippingID,
                    productID: productID,
                    cardID: selectedCardID,
                    shippingCharges: shippingCharges,
                    taxAmount: taxAmount,
                    sendAsGift: 1,
                    total: Int(subtotal)
                )
            )
            CusNavLink(doNavigate: $navigateToOrderStatus, destination: OrderStatusScreen())
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onFirstAppear {
            fetchOrderDetail()
            getCard()
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
    
    //MARK: fetchOrderDetail.
    func fetchOrderDetail(){
        Task {
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            let param = ProductOrderDetailRequest(order_id: orderID)
            await viewModel.getMyOrderList(parameters: param)
            await SVProgressHUD.dismiss()
            orderSuccess()
        }
    }
    
    //MARK: getCard.
    func getCard(){
        Task {
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            await self.cardViewModel.getCard()
            await SVProgressHUD.dismiss()
            cardSuccess()
        }
    }
    
    //MARK: cardSuccess.
    func cardSuccess() {
        SVProgressHUD.dismiss()
        let response = cardViewModel.cardDict
        if response.status == "success" {
            cardArr = cardViewModel.cardDict.data?.paymentProfiles ?? [PaymentProfile]()
           
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
    
    //MARK: BuyProductRequest.
    func BuyProductRequest() {
        Task {
          
            guard cardArr.indices.contains(selectedCardIndex),
                  let selectedCardID = cardArr[selectedCardIndex].customerPaymentProfileId else {
                hudMsg = "No valid card selected"
                showhud = true
                return
            }
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            var param = ProductOrderRequest(
                shipping_id: shippingID,
                product_id: productID,
                card_id: selectedCardID,
                promo_code: promoCode,
                send_as_gift: isGift ? 1 : 0,
                shipping_charges: shippingCharges,
                tax_amount: taxAmount,
                sub_total: Int(subtotal),
                total: Int(total)
            )

            if isGift {
                param.gift_user_id = giftUserID
                param.gift_msg = giftMsg
            }


            await viewModel.BuyProductRequest(parameters: param)
            await SVProgressHUD.dismiss()
            BuyProductSuccess()
        }
    }

    //MARK: orderSuccess.
    func orderSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.buyNowResponse
        if response.status == "success" {
            orderDetails = response.data
        } else {
            
        }
    }
    
    //MARK: BuyProductSuccess.
    func BuyProductSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.productOrderResponse
        if response.status == "success" {
            navigateToOrderStatus = true
        } else {
            
        }
    }
}



