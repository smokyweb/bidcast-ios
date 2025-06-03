//
//  ProductDetailSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import AlertToast

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
    
    @State  var productImages: [String] = [] // Image URLs or asset names
    @State  var productTitle: String = ""
    @State  var productPrice: String = ""
    @State  var condition: String = ""
    @State  var location: String = ""
    @State var postedTime: String = ""
    @State var sellerName: String = ""
    @State var sellerStatus: String = ""
    @Binding var productID : Int
    @State var sellerImage : String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                Button(action: {
                    onDismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
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
                    Text(sellerName).font(.subheadline.bold())
                    Text(sellerStatus).font(.caption).foregroundColor(.gray)
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
                        .font(.headline)
                    Spacer()
                    Text("$\(productPrice)")
                        .font(.title3.bold())
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Condition")
                            .font(.caption.bold())
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(condition)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Location")
                            .font(.caption.bold())
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(location)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("Posted")
                            .font(.caption.bold())
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(postedTime)
                            .font(.caption)
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
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                Button(action: {
                    showMakeOfferSheet.toggle()
                }) {
                    Text("Make Offer")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
            .padding()
        }
        .bottomSheet(isPresented: $showMakeOfferSheet, height: screenHeight * 0.85) {
            MakeOfferBottomSheet(
                isPresented: $showMakeOfferSheet,
                listedPrice: 1299,
                offerOptions: [1039, 1104, 1169, 1234]
            ) { selectedOffer in
                print("User selected offer: \(selectedOffer ?? 0)")
            }
        }
        
        .bottomSheet(isPresented: $showBuyNowSheet, height: screenHeight * 0.98) {
            BuyNowBottomSheetView(
                isPresented: $showBuyNowSheet,
                productImage: Image(systemName: "headphones"),
                productTitle: "Premium Wireless Headphones",
                productColor: "White",
                cardLastDigits: "4242",
                shippingAddress: "123 Main St, Apt 4B New York, NY 10001",
                subtotal: 299.99,
                shipping: 9.99,
                tax: 24.00,
                onConfirmPurchase: {
                    print("Purchase confirmed!")
                    showBuyNowSheet = false
                }
            )
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
            observe()
            
        }
        .onChange(of: productID) { newValue in
            guard newValue != 0 else {
                print("Invalid productID, skipping API call")
                return
            }
            self.isLoading = true
            let param = FetchProductRequest(product_id: newValue)
            viewModel.getProductDetails(parameters: param)
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
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    
    private func observe() {
        viewModel.eventHandler = { event in
            switch event {
            case .loading:
                isLoading = true
            case .stopLoading:
                isLoading = false
            case .dataLoaded:
                self.handleSuccess()
            case .error(let error):
                alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showError = true
            }
        }
    }
    
    func handleSuccess() {
        let response = viewModel.productDetailsResponceDict
        let data = viewModel.productDetailsResponceDict?.data
        if response?.status == "success" {
            productImages =  data?.images ?? []
            productTitle = data?.description ?? ""
            productPrice = "\(data?.pricing ?? 0)"
            condition =  "New" //currently No Key for this
            location = data?.shippingAdress?.streetAddress ?? ""
            postedTime = data?.createdAt ?? ""
            sellerName =  data?.user?.name ?? ""
            sellerImage = data?.user?.profileImage ?? ""
            sellerStatus = data?.user?.sellerVerification == false ? "Non Verified Seller" : "Verified Seller"
            
        } else {
            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
            withAnimation(.snappy) { showError = true }
        }
    }
}

