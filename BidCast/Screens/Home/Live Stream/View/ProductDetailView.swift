//
//  ProductDetailView.swift
//  BidCast
//
//  Created by JamTech on 25/11/25.
//

import SwiftUI
import Foundation
import SVProgressHUD
import AlertToast

struct ProductDetailView: View {
    
    @StateObject var viewModel = ProductDetailsViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var isLoading = false
    @State private var showError = false
    
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    @State private var style : AlertToast.AlertStyle? = alertStlyeSuccess
    
    var onDismiss: () -> Void = {}
    
    @State private var selectedImageIndex = 0
    @State private var productDetail : ProductDetailsModel?
    
    @State  var productImages: [String] = [] // Image URLs or asset names
    @State  var productTitle: String = ""
    @State  var description: String = ""
    @State var isProductSaved : Bool = false
    
    @Binding var productID : Int
    
    @State  var productPrice: Double = 0.0
    @State  var condition: String = ""
    @State  var location: String = ""
    @State var postedTime: String = ""
    @State var sellerName: String = ""
    @State var sellerStatus: String = ""
    
    @State var sellerImage : String = ""
    @State var offerArr = [Double]()
    @State  var productDescription: String = ""
    @State  var shippingAddress: String = ""
    @State  var shippingID: Int = 0
    @State  var cardID: String = ""
    @State  var promoCode : String = ""
    @State  var shippingCharges : Int = 0
    @State  var taxAmount : Int = 0
    @State var showBuyNowSheet = false
    
    @Binding var sellerInfo: SellerInfoResponse?
    
    @State private var isNavigatingToChat = false
    @State private var chatVM: ChatModel?
    
    
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                // MARK: - Product Images Carousel (Clean theme)
                ZStack(alignment: .topLeading) {
                    productImageCarousel
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.custom(poppinsBold, size: 16))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                    }
                    .padding(12)
                    .padding(.top,24)
                    .padding(.leading,8)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Product Basic Info
                    productHeaderSection
                    
                    Divider()
                    
                    // MARK: - Save / Share Buttons
                    saveShareSection
                    
                    // MARK: - Seller Stats Section
                    sellerStatsSection
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)
                
                // MARK: - Send Button
                if sellerInfo?.seller_details?.id != UserDefaults.userId{
                Button(action: {
                    showBuyNowSheet = true
                }) {
                    HStack(spacing: 12) {
                        Text("Buy Now")
                            .font(.custom(poppinsBold, size: 17))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                   
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.defaultTheme,
                                Color.defaultTheme.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(32)
                    .shadow(color: Color.defaultThemeLight, radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 32)
               
            }
            }
            CusNavLink(doNavigate: $showBuyNowSheet, destination:BuyNowBottomSheetView(productId: $productID) )
            if let chatVM = chatVM {
                CusNavLink(
                    doNavigate: $isNavigatingToChat,
                    destination: ChatScreen(viewModel: chatVM)
                )
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(.backGround)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: style)
            
        }

        .onFirstAppear {
            loadData()
        }
    }
    func prepareChatNavigation() {
        let currentUserId = String(UserDefaults.userId)
      
        
        chatVM = ChatModel(
            currentUserId: currentUserId,
            currentUserName: UserDefaults.fullName,
            currentUserImage: UserDefaults.profileURL,
            otherUserId:  "\(sellerInfo?.seller_details?.id ?? 0)",
            otherUserName: sellerInfo?.seller_details?.username ?? "",
            otherUserImage:  sellerInfo?.seller_details?.profile_image ?? ""
        )
        
        // Now, we can navigate to the chat screen
        isNavigatingToChat = true
    }
    
    
    func handleSuccess(firstTime:Bool) {
        let response = viewModel.productDetailsResponseDict
        let data = viewModel.productDetailsResponseDict?.data
        if response?.status == "success" {
            productDetail = response?.data
            productImages =  data?.images ?? []
            productTitle = data?.title ?? ""
            description = data?.description ?? ""
            productPrice = Double(data?.pricing ?? "0.0") ?? 0.0
            condition =  "New" //currently No Key for this
            location = data?.shippingAdress?.streetAddress ?? ""
            postedTime = data?.createdAt ?? ""
            sellerName =  data?.user?.name ?? ""
            sellerImage = data?.user?.profileImage ?? ""
            sellerStatus = data?.user?.sellerVerification == false ? "Non Verified Seller" : "Verified Seller"
            shippingAddress = data?.shippingAdress?.streetAddress ?? ""
            shippingID = data?.shippingAdress?.id ?? 0
            isProductSaved = data?.product_save_status ?? false
//            sellerInfo = data?.user ?? SellerUser()
            offerArr.removeAll()
            if firstTime{
                Task{
                    SVProgressHUD.show()
                    await fetchSellerIfAvailable(id:"\(data?.user?.id ?? 0)")
                }
            }
            if let price = data?.pricing {
                let percentages: [Double] = [0.05, 0.10, 0.15, 0.20]
                for percent in percentages {
                    let offerPrice = (Double(price) ?? 0.0) * percent
                    
                    offerArr.append(offerPrice)
                }
            }
            
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "Failed", message: response?.message?.capitalized ?? "Something Went Wrong", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
    private func fetchSellerIfAvailable(id:String) async {
        Task{
            viewModel.errorMessage?.removeAll()
            await viewModel.getSellerInfo(sellerID: id)
            await SVProgressHUD.dismiss()
            let response = viewModel.sellerInfo
            print("Seller info: \(String(describing: response))")
             await SVProgressHUD.dismiss()
            if response?.status == "success" {
                self.sellerInfo = response?.data ?? SellerInfoResponse()
            } else {
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
}

// MARK: - SELLER HEADER
extension ProductDetailView {
    private var sellerHeaderSection: some View {
        VStack(spacing: 14) {
            
            HStack {
                CustomProfileImage(
                    url: sellerInfo?.seller_details?.profile_image ?? "",
                    isCircular: true,
                    size: 30
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sellerInfo?.seller_details?.name?.capitalizingFirstLetter() ?? "Seller Name")
                        .font(.custom(poppinsSemiBold, size: 16))
                }
                
                Spacer()
                if sellerInfo?.seller_details?.id != UserDefaults.userId{
                    Button {
                        print("Chat tapped")
                        prepareChatNavigation()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "text.bubble")
                                .font(.custom(poppinsSemiBold, size: 16))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Color.defaultTheme)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            /*.clipShape(RoundedRectangle(cornerRadius: 12))*/
        }
    }
}


// MARK: - PRODUCT CAROUSEL
extension ProductDetailView {
    private var productImageCarousel: some View {
        TabView(selection: $selectedImageIndex) {
            ForEach(productImages.indices, id: \.self) { index in
                CustomProfileImage(
                    url: productImages[index],
                    isCircular: false,
                    size: screenWidth,
                    height: 320
                )
                .clipped()
                .tag(index)
            }
        }
        .frame(height: 320)
        .tabViewStyle(PageTabViewStyle())
    }
}


// MARK: - PRODUCT HEADER INFO
extension ProductDetailView {
    private var productHeaderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text(productDetail?.title?.capitalizingFirstLetter() ?? "Product Title")
                .font(.custom(poppinsBold, size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 6) {
                Text("\(productDetail?.quantity ?? "0") Available")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.darkGray)
            }
            
            Text("Starting at \(productPrice.compactCurrency()) + Shipping + taxes")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.darkGray)
        }
    }
}


// MARK: - SAVE & SHARE
extension ProductDetailView {
    private var saveShareSection: some View {
        HStack(spacing: 12) {
            
            // SAVE
            if sellerInfo?.seller_details?.id != UserDefaults.userId{
                Button {
                    print("Save")
                    Task{
                        SVProgressHUD.show()
                        let param = MakeOfferListRequest(product_id: productID)
                        viewModel.errorMessage?.removeAll()
                        await viewModel.saveProduct(param: param)
                        await SVProgressHUD.dismiss()
                        if let error = viewModel.errorMessage{
                            
                            hudMsg = error
                            showhud = true
                            style = alertStlye
                        }
                        savedSuccess()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: !isProductSaved ? "bookmark" : "bookmark.fill")
                            .font(.system(size: 18))
                        Text(!isProductSaved ? "Save" : "Saved")
                            .font(.custom(poppinsSemiBold, size: 15))
                            .foregroundStyle(.defaultTheme)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.defaultTheme)
                    .background(.defaultThemeLight)
                    .cornerRadius(32)
                }
            }
            
            // SHARE
            Button {
                print("Share")
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                    Text("Share")
                        .font(.custom(poppinsSemiBold, size: 15))
                        .foregroundStyle(.defaultTheme)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(.defaultTheme)
                .background(.defaultThemeLight)
                .cornerRadius(32)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 32)
//                        .fill(Color.defaultThemeLight)
//                )
            }
        }
    }
    func savedSuccess(){
        let response = viewModel.savedResponse
        if response?.status == "success"{
            if response?.data.is_saved ?? false{
                style = alertStlyeSuccess
                hudMsg = "Product saved successfully"
                showhud = true
                isProductSaved = true
            }else{
                style = alertStlyeSuccess
                hudMsg = "Product removed from the saved list"
                showhud = true
                isProductSaved  = false
            }
            loadData(firstTime: false)
        }
    }
}


// MARK: - SELLER STATS SECTION
extension ProductDetailView {
    private var sellerStatsSection: some View {
        VStack(spacing: 0) {
            // MARK: - Seller Section (Screenshot 2 layout, Screenshot 1 style)
            sellerHeaderSection
            
            HStack {
                StatScreen(icon: "star.fill",
                           value: String(format: "%.1f", sellerInfo?.rating_avg ?? 0.0),
                           label: "Rating")
                
                Divider().frame(height: 40).padding(.horizontal, 8)
                
                StatScreen(icon: nil,
                           value: "\(sellerInfo?.review ?? "0")",
                           label: "Reviews")
                
                Divider().frame(height: 40).padding(.horizontal, 8)
                
                StatScreen(icon: nil,
                           value: "\(sellerInfo?.sold_count ?? 0)",
                           label: "Sold")
                
                Divider().frame(height: 40).padding(.horizontal, 8)
                
                StatScreen(icon: "clock",
                           value: sellerInfo?.avg_ship ?? "0",
                           label: "Avg Ship")
            }
            .padding(.vertical, 10)
        }
        .background(Color.gray.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
    }
}


// MARK: - LOAD DATA
extension ProductDetailView {
    private func loadData(firstTime:Bool = true) {
        Task {
            guard Reachability.isConnectedToNetwork() else { return }
            if firstTime{
                SVProgressHUD.show()
            }
            
            let param = FetchProductRequest(product_id: productID)
            await viewModel.getProductDetails(parameters: param)
            
            await SVProgressHUD.dismiss()
            handleSuccess(firstTime:firstTime)
        }
        
        
        
        
    }
}
//#Preview {
//    ProductDetailView(productID: .constant(1), sellerInfo: .constant(SellerUser()))
//}


//import SwiftUI
//import AlertToast
//import SVProgressHUD
//
//struct ProductDetailSheet1: View {
//    @Environment(\.presentationMode) var presentationMode
//    @StateObject var viewModel = ProductDetailsViewModel()
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    @State private var isLoading = false
//    @State private var showError = false
//    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State private var showhud = false
//    @State private var hudMsg = ""
//    @State private var showBuyNowSheet = false
//    @State private var showMakeOfferSheet = false
//    @State private var selectedImageIndex = 0
//    var onDismiss: () -> Void = {}
//    @State private var productDetail : ProductDetailsModel?
//    
//    @State  var productImages: [String] = [] // Image URLs or asset names
//    @State  var productTitle: String = ""
//    @State  var description: String = ""
//    
//    @State  var productPrice: Double = 0.0
//    @State  var condition: String = ""
//    @State  var location: String = ""
//    @State var postedTime: String = ""
//    @State var sellerName: String = ""
//    @State var sellerStatus: String = ""
//    @Binding var productID : Int
//    @State var sellerImage : String = ""
//    @State var offerArr = [Double]()
//    @State  var productDescription: String = ""
//    @State  var shippingAddress: String = ""
//    @State  var shippingID: Int = 0
//    @State  var cardID: String = ""
//    @State  var promoCode : String = ""
//    @State  var shippingCharges : Int = 0
//    @State  var taxAmount : Int = 0
//  
//    
//    var onTapEdit : (ProductDetailsModel) -> () = {_ in }
//    var onTapDelete: () async -> () = { }
//
//    @State var showoption : Bool = true
//    @State var showButton : Bool = true
//    var body: some View {
//        VStack(spacing: 12) {
//            // Image Carousel
//            TabView(selection: $selectedImageIndex) {
//                ForEach(productImages.indices, id: \.self) { index in
//                    let img = productImages[index]
//                    CustomProfileImage(url: img,isCircular: false,size: screenWidth, height: 300)
//
//                    .tag(index)
//                }
//            }
//            .tabViewStyle(PageTabViewStyle())
//            .frame(height: 300)
//            
//            // Product Info
//            VStack(alignment: .leading, spacing: 12){
//                VStack {
//                    HStack {
//                        Text(productTitle.capitalizingFirstLetter())
//                            .font(.custom(poppinsBold, size: 20.0))
////                        Spacer()
////                        let price = String(format: "$%.2f", productPrice)
////                        Text("\(price)")
////                            .font(.custom(poppinsSemiBold, size: 16.0))
////
//                    }
//                    if !description.isEmpty{
//                        
//                        HStack {
//                            Text(description.capitalizingFirstLetter())
//                                .font(.custom(poppinsSemiBold, size: 13.0))
//                            Spacer()
//                            
//                        }
//                    }
//                    VStack(alignment: .leading, spacing: 6) {
//                        if !condition.isEmpty{
//                            HStack {
//                                Text("Condition")
//                                    .font(.custom(poppinsRegular, size: 13.0))
//                                    .frame(width: 80, alignment: .leading)
//                                Spacer()
//                                Text(condition)
//                                    .font(.custom(poppinsRegular, size: 13.0))
//                            }
//                        }
//                        if !location.isEmpty{
//                            HStack {
//                                Text("Location")
//                                    .font(.custom(poppinsRegular, size: 13.0))
//                                    .frame(width: 80, alignment: .leading)
//                                Spacer()
//                                Text(location)
//                                    .font(.custom(poppinsRegular, size: 13.0))
//                            }
//                        }
//                        if !postedTime.isEmpty{
//                            HStack {
//                                Text("Posted")
//                                    .font(.custom(poppinsRegular, size: 13.0))
//                                    .frame(width: 80, alignment: .leading)
//                                Spacer()
//                                Text(postedTime)
//                                    .font(.custom(poppinsRegular, size: 13.0))
//                            }
//                        }
//                    }
//                }
//                .padding(.all,8)
//            }
//            
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .padding(.horizontal)
////            .padding(.horizontal)
//            
//            
//            if showButton{
//                Spacer()
//                // Bottom Buttons
//                HStack(spacing: 16) {
//                    Button(action: {
//                        showBuyNowSheet.toggle()
//                    }) {
//                        Text("Buy Now")
//                            .font(.custom(poppinsSemiBold, size: 13.0))
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.defaultTheme)
//                            .foregroundColor(.white)
//                            .cornerRadius(30)
//                    }
//                    Button(action: {
//                        showMakeOfferSheet.toggle()
//                    }) {
//                        Text("Make Offer")
//                            .font(.custom(poppinsSemiBold, size: 13.0))
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.defaultTheme.opacity(0.8))
//                            .foregroundColor(.white)
//                            .cornerRadius(30)
//                    }
//                }
//                .padding()
//            }
//        }
//        .edgesIgnoringSafeArea(.top)
//        .bottomSheet(isPresented: $showMakeOfferSheet, height: screenHeight * 0.95) {
//            MakeOfferBottomSheet(
//                isPresented: $showMakeOfferSheet,
//                listedPrice: "\(productPrice)",
//                offerOptions: offerArr,onSendOffer : { text in
//                    let text = "\(text ?? 0.0)"
//                    Task{
//                       guard Reachability.isConnectedToNetwork() else {
//                            hudMsg = "No Internet Connection"
//                            showhud = true
//                            return
//                        }
//                        SVProgressHUD.show()
//                        let param = MakeOfferRequest(amount: text, product_id: productID)
//                        await viewModel.MakeOffer(param: param)
//                        await SVProgressHUD.dismiss()
//                        offerSuccess()
//                    }
//                    
//                }
//            ){ selectedOffer in
//                print("User selected offer: \(selectedOffer)")
//                
//            }
//        }
//        .presentationDetents([.large])
//        
//
//        .onAppear {
//            UIScrollView.appearance().bounces = false
//           
//            
//        }
//        .onChange(of: productID) { newValue in
//        
//            guard newValue != 0 else {
//                print("Invalid productID, skipping API call")
//                return
//            }
//            Task{
//               guard Reachability.isConnectedToNetwork() else {
//                    hudMsg = "No Internet Connection"
//                    showhud = true
//                    return
//                }
//                SVProgressHUD.show()
//                let param = FetchProductRequest(product_id: newValue)
//                await viewModel.getProductDetails(parameters: param)
//                await SVProgressHUD.dismiss()
//                handleSuccess(firstTime: false)
//            }
//        }
//        .onDisappear {
//            UIScrollView.appearance().bounces = true
//        }
//        
//        .toast(isPresenting: $showhud) {
//            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
//        }
//        .bottomSheet(
//            isPresented: $showError,
//            height: screenHeight / 2.3,
//            topBarCornerRadius: 25,
//            showTopIndicator: false
//        ) {
//            CommonBottomSheet(
//                sheetType: $alertType,
//                onPrimaryClick: {
//                    showMakeOfferSheet = false
//                    onDismiss()
//                    withAnimation { showError = false }
//                },
//                onSecondaryClick: {
//                    withAnimation { showError = false }
//                }
//            )
//        }
//    }
//    func offerSuccess(){
//        let response = viewModel.offerResponse
//        if response?.status == "success"{
//            alertType = .sheetType(icon: .success, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: AppString.ok.localized, secondaryBtnText: "", sheetThemeColor: .defaultTheme)
//            withAnimation(.snappy) { showError = true }
//        }else{
//            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
//            withAnimation(.snappy) { showError = true }
//        }
//    }
//    
//    func handleSuccess(firstTime:Bool) {
//        let response = viewModel.productDetailsResponseDict
//        let data = viewModel.productDetailsResponseDict?.data
//        if response?.status == "success" {
//            productDetail = response?.data
//            productImages =  data?.images ?? []
//            productTitle = data?.title ?? ""
//            description = data?.description ?? ""
//            productPrice = Double(data?.pricing ?? "0.0") ?? 0.0
//            condition =  "New" //currently No Key for this
//            location = data?.shippingAdress?.streetAddress ?? ""
//            postedTime = data?.createdAt ?? ""
//            sellerName =  data?.user?.name ?? ""
//            sellerImage = data?.user?.profileImage ?? ""
//            sellerStatus = data?.user?.sellerVerification == false ? "Non Verified Seller" : "Verified Seller"
//            shippingAddress = data?.shippingAdress?.streetAddress ?? ""
//            shippingID = data?.shippingAdress?.id ?? 0
//            offerArr.removeAll()
//            if let price = data?.pricing {
//                    let percentages: [Double] = [0.05, 0.10, 0.15, 0.20]
//                    for percent in percentages {
//                        let offerPrice = (Double(price) ?? 0.0) * percent
//                        
//                        offerArr.append(offerPrice)
//                    }
//                }
//            
//        } else {
//            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "Failed", message: response?.message?.capitalized ?? "Something Went Wrong", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
//            withAnimation(.snappy) { showError = true }
//        }
//    }
//}



extension Double {

    /// Returns a compact currency string (e.g. $1.2K, $3.45M, $2.00B)
    func compactCurrency() -> String {
        let absValue = abs(self)
        let sign = self < 0 ? "-" : ""

        switch absValue {
        case 1_000_000_000...:
            return String(format: "%@$%.2fB", sign, absValue / 1_000_000_000)

        case 1_000_000...:
            return String(format: "%@$%.2fM", sign, absValue / 1_000_000)

        case 1_000...:
            return String(format: "%@$%.1fK", sign, absValue / 1_000)

        default:
            return String(format: "%@$%.2f", sign, absValue)
        }
    }
}
