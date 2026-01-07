//
//  SendGiftScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI
import SVProgressHUD

struct SendGiftScreen: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject var viewModel = BuyNowViewModel()

    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType =
        .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")

    @State private var showhud = false
    @State private var hudMsg = ""
    @State private var isGift = false
    @State var navigateToOrderStatus: Bool = false
    @State var navigateToGiftScreen: Bool = false

    @Binding var request: ProductOrderRequest

    var navigateToBuyNowScreen: Bool = false

    @State private var giftUserID: String = ""
    @State private var giftMessage: String = ""

    var orderID: Int
    var promoCode: String
    var productImage: String
    var productTitle: String
    var productColor: String
    var shippingAddress: String
    var subtotal: Double
    var shipping: Double
    var tax: Double
    var shippingID: Int
    var productID: Int
    var cardID: String
    var shippingCharges: Int
    var taxAmount: Int
    var sendAsGift: Int = 1
    var total: Double

    @State private var searchText: String = ""
    @State private var searchResults: [UserModel] = []
    @State private var selectedUser: UserModel?

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                headerView
                giftIntroView
                searchView
                searchResultView
                messageView
                Spacer()
                continueButton
            }
            CusNavLink(doNavigate: $navigateToOrderStatus, destination: OrderStatusScreen(
                productDetail: .constant(MyOrderModel()),
                comeFrom: "buyNow"
            ))
        }
        .background(Color(.backGround).ignoresSafeArea())
    }
    @ViewBuilder
    private var headerView: some View {
        VStack {
            PrimaryHeader(
                title: "Send as a Gift".localized,
                isForLogo: false,
                leadingImgArr: ["chevron.left"],
                onClickLeading: { _ in
                    presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
        }
        .frame(height: 40)
        .background(.white)
    }
    @ViewBuilder
    private var giftIntroView: some View {
        VStack(spacing: 8) {
            Image(systemName: "gift.fill")
                .font(.system(size: 40))
                .foregroundColor(.defaultTheme)
                .padding()
                .background(Color.defaultThemeLight)
                .clipShape(Circle())

            Text("Gift to a Friend")
                .font(.title3)
                .bold()

            Text("Send this purchase as a gift to someone special")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
    }
    @ViewBuilder
    private var searchView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Find your friend")
                .font(.subheadline)
                .foregroundColor(.black)

            HStack {
                TextField("Search by username or email", text: $searchText)
                    .onChange(of: searchText) { newValue in
                        handleSearch(text: newValue)
                    }
                    .padding(12)
                    .background(.white)

                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.trailing, 12)
            }
            .background(Color.white)
            .cornerRadius(32)
        }
        .padding(.horizontal)
    }
    @ViewBuilder
    private var searchResultView: some View {
        if !searchResults.isEmpty {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(searchResults, id: \.id) { user in
                        UserRowView(
                            user: user,
                            isSelected: selectedUser?.id == user.id
                        )
                        .onTapGesture {
                            selectedUser = user
                            giftUserID = String(user.id ?? 0)
                            searchText = user.username ?? ""
                            searchResults = []
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 250)
        }
    }

    @ViewBuilder
    private var messageView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Add a gift message (optional)")
                .font(.subheadline)
                .foregroundColor(.black)

            TextEditor(text: $giftMessage)
                .frame(height: 100)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
        }
        .padding(.horizontal)
    }
    @ViewBuilder
    private var continueButton: some View {
        Button(action: {
            BuyProductRequest()
        }) {
            Text("Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.defaultTheme)
                .foregroundColor(.white)
                .cornerRadius(32)
                .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }

    func BuyProductRequest() {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            request.gift_msg = giftMessage
            request.gift_user_id = Int(giftUserID)
            SVProgressHUD.show()
            await viewModel.BuyProductRequest(parameters: request)
            await SVProgressHUD.dismiss()
            BuyProductSuccess()
        }
    }

    func handleSearch(text: String) {
        Task {
            guard text.count >= 2 else {
                searchResults = []
                selectedUser = nil
                return
            }

            let param = SearchingRequest(search: text)
            await viewModel.getUserSearch(parameters: param)

            if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                searchResults = viewModel.userList.data ?? []
            }
        }
    }

    func BuyProductSuccess() {
        let response = viewModel.productOrderResponse
        if response.status == "success" {
            navigateToOrderStatus = true
        }
    }

}
import SwiftUI

struct UserRowView: View {

    let user: UserModel
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {

            // Profile Image
            AsyncImage(url: URL(string: user.profileImage ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())

            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name ?? "")
                    .font(.custom(poppinsSemiBold, size: 14))

                Text("@\(user.username ?? "")")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Selection Indicator
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .defaultTheme : .gray)
                .font(.system(size: 20))
        }
        .padding(12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Color.defaultTheme : Color.gray.opacity(0.3),
                    lineWidth: 1.5
                )
        )
        .cornerRadius(12)
    }
}

//
//struct SendGiftScreen: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    @StateObject var viewModel = BuyNowViewModel()
//    @State private var isLoading = false
//    @State private var showError = false
//    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State private var showhud = false
//    @State private var hudMsg = ""
//    @State private var isGift = false
//    @State var navigateToOrderStatus : Bool = false
//    @State var navigateToGiftScreen : Bool = false
//    @Binding var request : ProductOrderRequest
//    
//    var navigateToBuyNowScreen : Bool = false
//    @State private var giftUserID : String = ""
//    @State private var giftMessage : String = ""
//    var orderID : Int
//    var promoCode : String
//    var productImage: String
//    var productTitle: String
//    var productColor: String
//    var shippingAddress: String
//    var subtotal: Double
//    var shipping: Double
//    var tax: Double
//    var shippingID: Int
//    var productID : Int
//    var cardID: String
//    var shippingCharges : Int
//    var taxAmount : Int
//    var sendAsGift : Int = 1
//    var total : Double
//    
//    
//    @State private var searchText: String = ""
//    @State private var searchResults: [UserModel] = []
//    @State private var selectedUser: UserModel?
//    
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            VStack(spacing: 20) {
//                // Header
//                VStack{
//                    PrimaryHeader(
//                        title: "Send as a Gift".localized,
//                        isForLogo : false ,
//                        leadingImgArr: ["chevron.left"],
//                        onClickLeading: { _ in
//                            self.presentationMode.wrappedValue.dismiss()
//                        },
//                        count: .constant(0)
//                    )
//                }.frame(height:40)
//                    .background(.white)
//                
//                // Gift icon and title
//                VStack(spacing: 8) {
//                    Image(systemName: "gift.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(.defaultTheme)
//                        .padding()
//                        .background(Color.defaultThemeLight)
//                        .clipShape(Circle())
//                    
//                    Text("Gift to a Friend")
//                        .font(.title3).bold()
//                    
//                    Text("Send this purchase as a gift to someone special")
//                        .font(.subheadline)
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.gray)
//                        .padding(.horizontal)
//                }
//                
//                // Friend Search
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Find your friend")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    
//                    HStack {
//                        TextField("Search by username or email", text: $searchText)
//                            .onChange(of: searchText) { newValue in
//                                handleSearch(text: newValue)
//                            }
//                            .padding(12)
//                            .background(.white)
//                        
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//                            .padding(.trailing, 12)
//                    }
//                    .background(Color(.white))
//                    .cornerRadius(32)
//                    
//                }
//                .padding(.horizontal)
//                
//                // Message
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Add a gift message (optional)")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    
//                    TextEditor(text: $giftMessage)
//                        .frame(height: 100)
//                    //                        .padding(10)
//                        .background(.white)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color(.systemGray4), lineWidth: 0.5)
//                        )
//                }
//                .padding(.horizontal)
//                
//                Spacer()
//                
//                // Continue Button
//                Button(action: {
//                    BuyProductRequest()
//                }) {
//                    Text("Continue")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.defaultTheme)
//                        .foregroundColor(.white)
//                        .cornerRadius(32)
//                        .padding(.horizontal)
//                }
//                .padding(.bottom, 20)
//            }
//        }
//        .background(Color(.backGround).ignoresSafeArea())
//        
//    }
//    //MARK: BuyProductRequest.
//    func BuyProductRequest() {
//        Task {
//           guard Reachability.isConnectedToNetwork() else {
//                hudMsg = "No Internet Connection"
//                showhud = true
//                return
//            }
//            SVProgressHUD.show()
////            let param = ProductOrderRequest(
////                shipping_id: shippingID,
////                product_id: productID,
////                card_id: cardID,
////                promo_code: promoCode,
////                send_as_gift:  1,
////                gift_user_id: Int(giftUserID) ?? 0,
////                gift_msg: giftMessage,
////                shipping_charges: shippingCharges,
////                tax_amount: taxAmount,
////                sub_total: Int(subtotal),
////                total: Int(total)
////            )
////            
//            await viewModel.BuyProductRequest(parameters: request)
//            await SVProgressHUD.dismiss()
//            BuyProductSuccess()
//        }
//        
//        
//
//    }
//    func handleSearch(text: String) {
//     
//        Task{
//        guard text.count >= 2 else {
//            searchResults = []
//            selectedUser = nil
//            return
//        }
//
//            let param = SearchingRequest(search: text)
//            await viewModel.getUserSearch(parameters: param)
//            if viewModel.errorMessage == "" || viewModel.errorMessage == nil{
//                
//                searchResults = viewModel.userList.data ?? []
//            }
//            
//        }
//    }
//    //MARK: BuyProductSuccess.
//    func BuyProductSuccess() {
//        SVProgressHUD.dismiss()
//        let response = viewModel.productOrderResponse
//        if response.status == "success" {
//            navigateToOrderStatus = true
//        } else {
//            
//        }
//    }
//    
//}
//
//
//
////ProductOrderRequest(shipping_id: 0, product_id: 0, card_id: "", promo_code: "", send_as_gift: 1, gift_user_id: 0, gift_msg: "Jhbbb", shipping_charges: 0, tax_amount: 0, sub_total: 0, total: 0, discount: nil)
