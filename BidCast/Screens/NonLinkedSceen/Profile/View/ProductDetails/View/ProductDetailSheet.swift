//
//  ProductDetailSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct ProductDetailSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = ProductDetailsViewModel()
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    @State private var showBuyNowSheet = false
    @State private var showMakeOfferSheet = false
    @State private var selectedImageIndex = 0
    var onDismiss: () -> Void = {}
    @State private var productDetail : ProductDetailsModel?
    
    @State  var productImages: [String] = [] // Image URLs or asset names
    @State  var productTitle: String = ""
    @State  var productPrice: Double = 0.0
    @State  var condition: String = ""
    @State  var location: String = ""
    @State var postedTime: String = ""
    @State var sellerName: String = ""
    @State var sellerStatus: String = ""
    @Binding var productID : Int
    @State var sellerImage : String = ""
    @State var offerArr = [Double]()
    @State  var productDescription: String = ""
    @State  var shippingAddress: String = ""
    @State  var shippingID: Int = 0
    @State  var cardID: String = ""
    @State  var promoCode : String = ""
    @State  var shippingCharges : Int = 0
    @State  var taxAmount : Int = 0

    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.custom(poppinsSemiBold, size: 14.0))
                        .foregroundColor(.black)
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.custom(poppinsSemiBold, size: 14.0))
                        .foregroundColor(.gray)
                }
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.custom(poppinsSemiBold, size: 14.0))
                        .foregroundColor(.red)
                }
            }
            .padding()
            
            // Seller Info
            HStack(spacing: 8) {
                AsyncImage(url: URL(string: sellerImage)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 32, height: 32)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(sellerName)
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.gray)
                    Text(sellerStatus)
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            
            // Image Carousel
            TabView(selection: $selectedImageIndex) {
                ForEach(productImages.indices, id: \.self) { index in
                    let img = productImages[index]
                    AsyncImage(url: URL(string: img)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 300)
            
            // Product Info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(productTitle)
                        .font(.custom(poppinsSemiBold, size: 14.0))
                    Spacer()
                    Text("$\(productPrice)")
                        .font(.custom(poppinsSemiBold, size: 14.0))
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Condition")
                            .font(.custom(poppinsRegular, size: 12.0))
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(condition)
                            .font(.custom(poppinsRegular, size: 12.0))
                    }
                    
                    HStack {
                        Text("Location")
                            .font(.custom(poppinsRegular, size: 12.0))
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(location)
                            .font(.custom(poppinsRegular, size: 12.0))
                    }
                    
                    HStack {
                        Text("Posted")
                            .font(.custom(poppinsRegular, size: 12.0))
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(postedTime)
                            .font(.custom(poppinsRegular, size: 12.0))
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            // Bottom Buttons
            HStack(spacing: 16) {
                Button(action: {
                    showBuyNowSheet.toggle()
                }) {
                    Text("Buy Now")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                Button(action: {
                    showMakeOfferSheet.toggle()
                }) {
                    Text("Make Offer")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.defaultTheme.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
            .padding()
        }
        .bottomSheet(isPresented: $showMakeOfferSheet, height: screenHeight * 0.95) {
            MakeOfferBottomSheet(
                isPresented: $showMakeOfferSheet,
                listedPrice: Double(productPrice) ?? 0.0,
                offerOptions: offerArr,onSendOffer : { text in
                    var text = "\(text ?? 0.0)"
                    Task{
                        SVProgressHUD.show()
                        let param = MakeOfferRequest(amount: text, product_id: productID)
                        await viewModel.MakeOffer(param: param)
                        await SVProgressHUD.dismiss()
                        await offerSuccess()
                    }
                    
                }
            ){ selectedOffer in
                print("User selected offer: \(selectedOffer)")
                
            }
        }
        .presentationDetents([.large])
        
        .bottomSheet(isPresented: $showBuyNowSheet, height: screenHeight * 0.98) {
            BuyNowBottomSheetView(
                isPresented: $showBuyNowSheet,
                productImage: productImages.first ?? "",
                productTitle: productTitle,
                productColor: productDescription,
                shippingAddress: shippingAddress,
                subtotal: productPrice,
                shipping: 9.99,
                tax: 24.00,
                shippingID: shippingID,
                productID: productID,
                shippingCharges: shippingCharges,
                taxAmount: taxAmount,
                onConfirmPurchase: {
                    print("Purchase confirmed!")
                    showBuyNowSheet = false
                }
            )
            .presentationDetents([.medium, .large])
        }

        .onAppear {
            UIScrollView.appearance().bounces = false
           
            
        }
        .onChange(of: productID) { newValue in
        
            guard newValue != 0 else {
                print("Invalid productID, skipping API call")
                return
            }
            Task{
                SVProgressHUD.show()
                let param = FetchProductRequest(product_id: newValue)
                await viewModel.getProductDetails(parameters: param)
                await SVProgressHUD.dismiss()
                await handleSuccess()
            }
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
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
                    showMakeOfferSheet = false
                    onDismiss()
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    func offerSuccess(){
        let response = viewModel.offerResponse
        if response?.status == "success"{
            alertType = .sheetType(icon: .success, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: AppString.ok.localized, secondaryBtnText: "", sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }else{
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
    
    func handleSuccess() {
        let response = viewModel.productDetailsResponseDict
        let data = viewModel.productDetailsResponseDict?.data
        if response?.status == "success" {
            productDetail = response?.data
            productImages =  data?.images ?? []
            productTitle = data?.description ?? ""
            productPrice = Double(data?.pricing ?? 0)
            condition =  "New" //currently No Key for this
            location = data?.shippingAdress?.streetAddress ?? ""
            postedTime = data?.createdAt ?? ""
            sellerName =  data?.user?.name ?? ""
            sellerImage = data?.user?.profileImage ?? ""
            sellerStatus = data?.user?.sellerVerification == false ? "Non Verified Seller" : "Verified Seller"
            shippingAddress = data?.shippingAdress?.streetAddress ?? ""
            shippingID = data?.shippingAdress?.id ?? 0
            offerArr.removeAll()
            if let price = data?.pricing {
                    let percentages: [Double] = [0.05, 0.10, 0.15, 0.20]
                    for percent in percentages {
                        let offerPrice = Double(price) * percent
                        
                        offerArr.append(offerPrice)
                    }
                }
            
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
}

