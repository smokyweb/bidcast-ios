//
//  SendGiftScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI

import SwiftUI
import SVProgressHUD

struct SendGiftScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = BuyNowViewModel()
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    @State private var isGift = false
    @State var navigateToOrderStatus : Bool = false
    @State var navigateToGiftScreen : Bool = false
    
    
    var navigateToBuyNowScreen : Bool = false
    @State private var giftUserID : String = ""
    @State private var giftMessage : String = ""
    var orderID : Int
    var promoCode : String
    var productImage: String
    var productTitle: String
    var productColor: String
    var shippingAddress: String
    var subtotal: Double
    var shipping: Double
    var tax: Double
    var shippingID: Int
    var productID : Int
    var cardID: String
    var shippingCharges : Int
    var taxAmount : Int
    var sendAsGift : Int = 1
    var total : Int
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 20) {
                // Header
                VStack{
                    PrimaryHeader(
                        title: "Send as a Gift".localized,
                        isForLogo : false ,
                        leadingImgArr: [.icBack],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }.frame(height:40)
                    .background(.white)
                
                // Gift icon and title
                VStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red.opacity(0.8))
                        .padding()
                        .background(Color.defaultTheme.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text("Gift to a Friend")
                        .font(.title3).bold()
                    
                    Text("Send this purchase as a gift to someone special")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                
                // Friend Search
                VStack(alignment: .leading, spacing: 6) {
                    Text("Find your friend")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        TextField("Search by username or email", text: $giftUserID)
                            .padding(12)
                            .background(.white)
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 12)
                    }
                    .background(Color(.white))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Message
                VStack(alignment: .leading, spacing: 6) {
                    Text("Add a gift message (optional)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextEditor(text: $giftMessage)
                        .frame(height: 100)
                    //                        .padding(10)
                        .background(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    BuyProductRequest()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        
    }
    //MARK: BuyProductRequest.
    func BuyProductRequest() {
        Task {
            SVProgressHUD.show()
            let param = ProductOrderRequest(
                shipping_id: shippingID,
                product_id: productID,
                card_id: cardID,
                promo_code: promoCode,
                send_as_gift:  1,
                gift_user_id: Int(giftUserID) ?? 0,
                gift_msg: giftMessage,
                shipping_charges: shippingCharges,
                tax_amount: taxAmount,
                sub_total: Int(subtotal),
                total: Int(total)
            )
            
            await viewModel.BuyProductRequest(parameters: param)
            await SVProgressHUD.dismiss()
            BuyProductSuccess()
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



//ProductOrderRequest(shipping_id: 0, product_id: 0, card_id: "", promo_code: "", send_as_gift: 1, gift_user_id: 0, gift_msg: "Jhbbb", shipping_charges: 0, tax_amount: 0, sub_total: 0, total: 0, discount: nil)
