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
    @Binding var productId : Int
    @State var cardViewModel = StripeCardViewModel()
    @State var cardArr : [CardDataModel] = []
    @State var couponArr : [AssignedCoupon] = []
    
    @State var selectedCardIndex: Int = 0
    @State var orderDetails : MyOrderModel?
    @State private var isLoading = false
    @State private var showError = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
//    @Binding var isPresented: Bool
    @State private var isGift = false
    @State var navigateToOrderStatus : Bool = false
    @State var navigateToGiftScreen : Bool = false
    @State var addressArr = [AddressModel]()
    
    var orderID : Int = 10
    @State private var promoCode = ""
    var productImage: String = ""
    var productTitle: String = ""
    var productColor: String = ""
    @State private var shippingAddress: String = ""
   @State private var subtotal: Double = 0.0
    @State private var price: Double = 0.0
    
    @State private var shipping: Double = 0.0
    @State private var tax: Double = 0.0
    @State private var discount: Double = 0.0
    @State private var shippingID: Int = 0
    @State private var productID : Int = 0
    @State private var cardID: String = ""
    @State private var shippingCharges : Int = 0
    @State private var taxAmount : Int = 0
    @State private var sendAsGift : Int = 0
    @State private var giftUserID : Int = 0
    @State private var giftMsg : String = ""
    @State var orderId : Int = 0
    @State private var showCouponSheet = false
    
    @State private var showAddressSheet = false
    @State private var showCardSheet = false
    
    @State var request = ProductOrderRequest(shipping_id: 0, product_id: 0, card_id: "", promo_code: "", send_as_gift: 0, shipping_charges: 0, tax_amount: 0, sub_total: 0, total: 0 )
    
    
    @State private var total: Double  = 0.0
    
    var selectedCardID: String {
        cardArr.indices.contains(selectedCardIndex) ? (cardArr[selectedCardIndex].cardID ?? "") : ""
    }

    @State private var purchaseDetail : ProductPurchaseModel = ProductPurchaseModel()
    @State private var appliedCouponId: Int? = nil
    
    var body: some View {
        VStack{
            VStack{
                PrimaryHeader(title: "Buy Now",
                              leadingImgArr: ["chevron.left"],
                              onClickLeading: {_ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: productImage)) { image in
                            image.resizable()
                        }placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 56, height: 56)
                        .cornerRadius(8)
                        VStack(alignment: .leading) {
                            Text(purchaseDetail.product?.title?.capitalizingFirstLetter() ?? "")
                                .font(.custom(poppinsSemiBold, size: 13.0))
//                            Text(purchaseDetail.product?.category?.color ?? "")
//                                .font(.custom(poppinsSemiBold, size: 11.0))
//                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    Divider()
                    
                    // Gift Toggle
                    HStack {
                        Label("Send as a gift?", systemImage: "gift")
                            .font(.custom(poppinsRegular, size: 11.0))
                        Spacer()
                        Toggle("", isOn: $isGift)
                            .labelsHidden()
                            .onChange(of: isGift) { newValue in
//                                if newValue {
//                                    navigateToGiftScreen = true
//                                }
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
//                                Image("visa") // Replace with actual asset if needed
//                                    .resizable()
//                                    .frame(width: 32, height: 20)
                                Text("**** **** **** \(cardArr[safe: selectedCardIndex]?.last4 ?? "0000")")
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                                
                            }
                        }
                        Spacer()
                        Button("Change") {
                            showCardSheet = true
                        }
                            .font(.custom(poppinsSemiBold, size: 12.0))
                            .foregroundColor(.red)
                    }
                    Divider()
                    
                    // Shipping Address
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Shipping Address")
                                .font(.custom(poppinsSemiBold, size: 13.0))
                            Text(shippingAddress)
                                .font(.custom(poppinsSemiBold, size: 13.0))
                        }
                        Spacer()
                        Button("Change") {
                            showAddressSheet = true
                        }
                            .font(.custom(poppinsSemiBold, size: 12.0))
                            .foregroundColor(.red)
                    }
                    Divider()
                    
                    // Promo Code
                    VStack(spacing: 8) {
                        
                        HStack {
                            HStack {
                                Text(promoCode.isEmpty ? "Enter promo code" : promoCode)
                                    .font(.custom(poppinsSemiBold, size: 13))
                                    .foregroundColor(promoCode.isEmpty ? .gray : .black)

                                Spacer()

                                if !promoCode.isEmpty {
                                    Button {
                                        promoCode = ""
                                        appliedCouponId = nil
                                        getProductDetails(shippingId: shippingID, productId: productId)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.custom(poppinsSemiBold, size: 13.0))
                                            .foregroundColor(.black)
                                            .padding(8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )

                            if !couponArr.isEmpty {
                                Button("View All") {
                                    showCouponSheet = true
                                }
                                .font(.custom(poppinsSemiBold, size: 12))
                                .foregroundColor(.red)
                            }
                        }
                        
                        // Divider with 2 coupons
                        ZStack {
                            Divider()

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(couponArr, id: \.id) { item in
                                        CouponApplyCard(
                                            coupon: item,
                                            isApplied: appliedCouponId == item.coupon?.id
                                        ) {
                                            appliedCouponId = item.coupon?.id ?? 0
                                            promoCode = item.coupon?.name ?? ""

                                            getProductDetails(
                                                shippingId: shippingID,
                                                productId: productId,
                                                coupon_name: promoCode
                                            )
                                        }
                                        .frame(width: 170)
                                    }
                                }
                                .padding(.horizontal,2)
                                .padding(.vertical, 4)
                            }
                            .background(Color.backGround)
                        }
                    }
                    Divider()
                    
                    // Summary
                    VStack(spacing: 4) {
                        SummaryRow(label: "Price", value: price)
                        SummaryRow(label: "Shipping", value: shipping)
                        SummaryRow(label: "Tax", value: tax)
                        SummaryRow(label: "Subtotal", value: subtotal)
                        Divider()
                        SummaryRow(label: "Discount", value: discount)
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
                            .cornerRadius(32)
                    }
                    
                }
                .padding()
                CusNavLink(
                    doNavigate: $navigateToGiftScreen,
                    destination: SendGiftScreen(
                        request: $request, orderID: orderID, promoCode: promoCode,
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
                        total: subtotal
                    )
                )
//                if let order = orderDetails {
                    CusNavLink(doNavigate: $navigateToOrderStatus, destination: OrderStatusScreen(
                        productDetail: $orderDetails,
                        comeFrom: "buyNow", orderId: $orderId
                    ))
//                }
            }
            .background(Color.backGround)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .onFirstAppear {
//                fetchOrderDetail()
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
            .sheet(isPresented: $showAddressSheet) {
                ShippingAddressSelectionSheet(
                    addressArr: addressArr,
                    initialSelectedId: shippingID,
                    onSelect: { address in
                        showAddressSheet = false
                        shippingID = address.id ?? 0
                        shippingAddress = "\(address.street_address ?? "")"
                    }
                )
            }

            .sheet(isPresented: $showCardSheet) {
                CardSelectionSheet(
                    cardArr: cardArr,
                    initialIndex: selectedCardIndex,
                    onSelect: { index in
                        showCardSheet = false
                        selectedCardIndex = index
                    }
                )
            }
            .sheet(isPresented: $showCouponSheet) {
                CouponListSheet(
                    coupons: couponArr,
                    selectedCode: appliedCouponId
                ) { selectedCoupon in
                    appliedCouponId = selectedCoupon.coupon?.id ?? 0
                    promoCode = selectedCoupon.coupon?.name ?? ""
                    showCouponSheet = false
                    getProductDetails(shippingId: shippingID, productId: productId, coupon_name: promoCode)
                }
                .presentationBackground(Color.backGround)
            }
        }
        
    }
    
  
    //MARK: getCard.
    func getCard(){
        Task {
            await performAPICalls(
                isConcurrent: true,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: cardViewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }, onSuccess: {
                    // On success
                    AddressSuccess()
                    cardSuccess()
                    couponSuccess()
                }
                
            ) {
                try await cardViewModel.getAddresses()
                try await cardViewModel.getCards()
                try await cardViewModel.getCoupon()
            }
        }
    }
    func AddressSuccess() {
        
        SVProgressHUD.dismiss()
        let response = cardViewModel.getAddressDict
        if response.status == "success" {
            addressArr = response.data ?? []
            Task{
                if let shippingId = addressArr.first(where: { $0.is_default ?? false })?.id {
                    SVProgressHUD.show()
                    shippingID = shippingId
                    shippingAddress = "\(addressArr.first(where: { $0.is_default ?? false })?.street_address ?? "")"
                    
                    getProductDetails(shippingId: shippingID, productId: productId)
                }
            }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
        
    }
    
    func getProductDetails(shippingId : Int,productId : Int,coupon_name : String? = nil){
        Task{
            SVProgressHUD.show()
            await viewModel.getPurchaseDetail(
                parameters: ProductPurchaseDetailRequest(
                    shipping_id: shippingId,
                    product_id: productId,
                    coupon_name: coupon_name
                )
            )
            await SVProgressHUD.dismiss()
            if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                let response = viewModel.purchaseDetailResponse
                if response.status == "success"{
                    purchaseDetail = response.data ?? ProductPurchaseModel()
                    price = Double(purchaseDetail.price ?? "") ?? 0.0
                    subtotal = Double(purchaseDetail.sub_total ?? "") ?? 0.0
                    shipping = Double(purchaseDetail.shipping_charges ?? "") ?? 0.0
                    tax = Double(purchaseDetail.tax_amount ?? "") ?? 0.0
                    total = Double(purchaseDetail.total ?? "") ?? 0.0
                    discount = Double(purchaseDetail.discount_amount ?? "") ?? 0.0
                }
            }else{
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: viewModel.errorMessage ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }
        }
    }
    
    //MARK: cardSuccess.
    func cardSuccess() {
        let response = cardViewModel.cards
        if response?.status == "success" {
            cardArr = response?.data ?? []
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: cardViewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
    
    func couponSuccess() {
        let response = cardViewModel.couponDict
        if response.status == "success" {
            couponArr = response.data ?? []
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: cardViewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
    
    //MARK: BuyProductRequest.
    func BuyProductRequest() {
        Task {
          
            guard cardArr.indices.contains(selectedCardIndex),
                  let selectedCardID = cardArr[selectedCardIndex].cardID else {
                hudMsg = "No valid card selected"
                showhud = true
                return
            }
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
           
            var param = ProductOrderRequest(
                shipping_id: shippingID,
                product_id: productId,
                card_id: selectedCardID,
                promo_code: promoCode,
                send_as_gift: isGift ? 1 : 0,
                shipping_charges: Int(shipping),
                tax_amount: Int(tax),
                sub_total: Int(subtotal),
                total: Int(total)
            )

            if isGift {
                param.gift_user_id = giftUserID
                param.gift_msg = giftMsg
                request = param
                navigateToGiftScreen = true
            }else{
                SVProgressHUD.show()
                request = param
                viewModel.errorMessage?.removeAll()
                await viewModel.BuyProductRequest(parameters: param)
                await SVProgressHUD.dismiss()
                if let error = viewModel.errorMessage{
                    hudMsg = error
                    showhud = true
                }
                BuyProductSuccess()
            }
        }
    }

   

    
    //MARK: BuyProductSuccess.
    func BuyProductSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.productOrderResponse
        if response.status == "success" {
//            navigateToOrderStatus = response.data
            navigateToOrderStatus = true
            
            orderId = response.data?.id ?? 0
        } else {
            
            hudMsg = response.message ?? ""
                showhud = true
            
        }
    }
}
struct CouponApplyCard: View {
    let coupon: AssignedCoupon
    let isApplied: Bool
    let onApply: () -> Void

    var discountText: String {
        guard let coupon = coupon.coupon else { return "" }
        switch coupon.type {
        case "percentage": return "\(coupon.value ?? 0)% OFF"
        case "flat": return "₹\(coupon.value ?? 0) OFF"
        default: return ""
        }
    }

    var body: some View {
        HStack(spacing: 12) {

            VStack(alignment: .leading, spacing: 2) {
                Text(coupon.coupon?.name ?? "")
                    .font(.custom(poppinsSemiBold, size: 12))
                    .lineLimit(1)

                Text(discountText)
                    .font(.custom(poppinsRegular, size: 11))
                    .foregroundColor(.defaultTheme)
            }

            Spacer()

            Button(action: onApply) {
                Text(isApplied ? "Applied" : "Apply")
                    .font(.custom(poppinsSemiBold, size: 11))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isApplied ? Color.gray.opacity(0.3) : Color.red)
            )
            .foregroundColor(isApplied ? .gray : .white)
            .disabled(isApplied)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isApplied ? Color.defaultTheme : Color.gray.opacity(0.3))
        )
    }
}


// MARK: - Coupon List Sheet (View All)
struct CouponListSheet: View {
    let coupons: [AssignedCoupon]
    let selectedCode: Int?
    let onSelect: (AssignedCoupon) -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack {
                Text("Available Coupons")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(coupons, id: \.id) { item in
                        CouponSelectableRow(
                            coupon: item,
                            isApplied: selectedCode == item.coupon?.id, showApplyButton: true
                        ) {
                            onSelect(item)
                        }
                    }
                }
            }
            .background(.backGround)
        }
        
        .padding(.horizontal,8)
        .padding(.top,8)
        .background(.backGround)
        
    }
}

// MARK: - Coupon Row (Full List)
struct CouponSelectableRow: View {
    
    let coupon: AssignedCoupon
    let isApplied: Bool
    let showApplyButton: Bool
    let onApply: () -> Void
    
    var discountText: String {
        guard let coupon = coupon.coupon else { return "" }
        switch coupon.type {
        case "percentage":
            return "\(coupon.value ?? 0)% OFF"
        case "flat":
            return "₹\(coupon.value ?? 0) OFF"
        default:
            return ""
        }
    }
    
    var body: some View {
        HStack {
            
            // MARK: - Left Badge
            Text(discountText)
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(.defaultTheme)
                .multilineTextAlignment(.center)
                .padding()
                .frame(width: 100, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.defaultThemeLight)
                )
            
            // MARK: - Right Content
            HStack(alignment: .center, spacing: 12) {
                
                // Name + Description (VStack)
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text(coupon.coupon?.name ?? "")
                        .font(.custom(poppinsSemiBold, size: 14))
                        .lineLimit(1)
                    
                    Text(coupon.coupon?.description ?? "")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Apply Button
                if showApplyButton {
                    Button(isApplied ? "Applied" : "Apply") {
                        onApply()
                    }
                    .font(.custom(poppinsSemiBold, size: 11))
                    .foregroundColor(isApplied ? .gray : .red)
                    .disabled(isApplied)
                }
            }
            .padding(.leading, 10)
            .frame(maxHeight: .infinity)
            
            Spacer()
        }
        .padding(.all,8)
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isApplied ? Color.defaultTheme : Color.clear,
                            lineWidth: 1.5
                        )
                )
        )
        .padding(.horizontal, 12)
    }
}


