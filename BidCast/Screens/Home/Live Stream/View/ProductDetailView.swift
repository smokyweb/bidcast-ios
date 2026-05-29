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
    @State private var isReadMore = false

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
    @State var makeOfferSheet = false
    // Basecamp #9933847997 (2026-05-27): pre-bid state.
    @State private var showPreBidAlert: Bool = false
    @State private var preBidAmountText: String = ""
    @State private var preBidLoading: Bool = false
    @State private var preBidExistingId: Int? = nil
    @State private var preBidExistingAmount: Double? = nil
    // Basecamp #9933847997 (2026-05-29): highest pre-bid on this product
    // from GET /api/pre-bid/highest/{productId}. Shown below the price so
    // buyers know the current leading pre-bid amount.
    @State private var highestPreBid: Double? = nil
    
    @Binding var sellerInfo: SellerInfoResponse?
    
    @State private var isNavigatingToChat = false
    @State private var chatVM: ChatModel?
    
    
    
    var body: some View {
        // QA #22 — Back button must be pinned (not scroll with content) and positioned to avoid sitting behind the clock.
        ZStack(alignment: .topLeading) {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                // MARK: - Product Images Carousel (Clean theme)
                productImageCarousel
                
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Product Basic Info (back button is now an outer overlay; the inner Spacer was inside the old ZStack)
                    productHeaderSection
                    
                    Divider()
                    
                    // MARK: - Save / Share Buttons
                    saveShareSection
                    
                    // MARK: - Seller Stats Section
                    sellerStatsSection
                    productDetailSection
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)
                
                // MARK: - Send Button
                if sellerInfo?.seller_details?.id != UserDefaults.userId{
                    HStack(spacing:0){
                        if viewModel.productDetailsResponseDict?.data.acceptOffers ?? false{
                            PrimaryButton(title: "Make Offer",isOutLine: false,onButtonClick: {
                                makeOfferSheet = true
                            },btnTextColor:.defaultTheme, btnColor: .defaultThemeLight)
                        }
                        
                        PrimaryButton(title: "Buy Now",onButtonClick: {
                            showBuyNowSheet = true
                        })

                        // Basecamp #9933847997 (2026-05-27) + #9938346351 (2026-05-28):
                        // pre-bid button ONLY appears on live-auction products.
                        // Buy-now products and products viewed from a profile page
                        // (no show context) should never see the pre-bid button.
                        // The `auction` flag on the product model is true when the
                        // product is configured as a live-auction listing.
                        if productDetail?.auction == true {
                            PrimaryButton(title: preBidExistingId != nil ? "Update Pre-Bid" : "Pre-Bid", isOutLine: true, onButtonClick: {
                                preBidAmountText = preBidExistingAmount.map { String(format: "%.2f", $0) } ?? ""
                                showPreBidAlert = true
                            }, btnTextColor: .orange, btnColor: .white)
                        }
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
//                    Button(action: {
//                        
//                    }) {
//                        HStack(spacing: 12) {
//                            Text("Buy Now")
//                                .font(.custom(poppinsBold, size: 17))
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        
//                        .padding(.vertical, 18)
//                        .background(
//                            LinearGradient(
//                                gradient: Gradient(colors: [
//                                    Color.defaultTheme,
//                                    Color.defaultTheme.opacity(0.8)
//                                ]),
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
//                        .cornerRadius(32)
//                        .shadow(color: Color.defaultThemeLight, radius: 12, x: 0, y: 6)
//                    }
                    
                    
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
        // Basecamp #9933847997 (2026-05-27): pre-bid alert with text-field input.
        .alert(preBidExistingId != nil ? "Update Pre-Bid" : "Place Pre-Bid", isPresented: $showPreBidAlert) {
            TextField("Amount in USD", text: $preBidAmountText)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) { }
            Button(preBidExistingId != nil ? "Update" : "Place") {
                placePreBid()
            }
            if preBidExistingId != nil {
                Button("Withdraw", role: .destructive) { withdrawPreBid() }
            }
        } message: {
            Text("Lock in your bid before the auction starts. Applied automatically as the opening bid.")
        }
        .onAppear {
            loadCurrentPreBid()
            loadHighestPreBid()
        }
        .sheet(isPresented: $makeOfferSheet)   {
            MakeOfferBottomSheet(isPresented: $makeOfferSheet, listedPrice: "\(productPrice)", offerOptions: offerArr, onSendOffer: { text in
                let text = "\(text ?? 0.0)"
                Task{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    SVProgressHUD.show()
                    let param = MakeOfferRequest(amount: text, product_id: productID)
                    await viewModel.MakeOffer(param: param)
                    await SVProgressHUD.dismiss()
                    if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                        offerSuccess()
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
            })
            .presentationDetents([.fraction(0.7)])
            .presentationCornerRadius(25)
            .presentationDragIndicator(.hidden)
            .presentationBackground(.backGround)
            .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
                      CommonBottomSheet(
                          sheetType: $alertType,
                          onPrimaryClick: {
                              withAnimation { showError = false }
                              makeOfferSheet = false
                              // Handle response when primary button clicked
                          },
                          onSecondaryClick: {
                              withAnimation { showError = false }
                          }
                      )
                  }
        }

        .onFirstAppear {
            loadData()
        }
        // QA #22 — Pinned back button overlay (top-left, padded to avoid clock area)
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            // MC cmpaj2fex0000w5hgq64jp9k4 (Larry 2026-05-23 19:10 EDT):
            // Match the standard floating-on-image back button used on ProfileScreen.
            // Previously was chevron.left.circle.fill / .primary which disappeared
            // against dark product images.
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(Color.black.opacity(0.45))
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
        }
        .padding(.top, 60) // clear status bar / clock
        .padding(.leading, 16)
        .zIndex(10)
        } // end outer ZStack for QA #22 pinned back button
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

    // MARK: - Basecamp #9933847997 (2026-05-27): Pre-Bid
    // Endpoint corrections (2026-05-29): ROBIN_API_SPECS.md confirms the
    // live routes are /api/pre-bid (NOT /api/product/pre-bid). All three
    // methods below are updated accordingly.
    private func loadCurrentPreBid() {
        Task {
            // GET /api/pre-bid — list the current user's pre-bids
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/pre-bid") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                let (data, _) = try await URLSession.shared.data(for: req)
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                let rows = (json?["data"] as? [[String: Any]]) ?? []
                let mine = rows.first { ($0["product_id"] as? Int) == productID }
                await MainActor.run {
                    if let m = mine {
                        preBidExistingId = (m["id"] as? Int)
                        if let amt = m["amount"] as? Double { preBidExistingAmount = amt }
                        else if let amtS = m["amount"] as? String, let amt = Double(amtS) { preBidExistingAmount = amt }
                    } else {
                        preBidExistingId = nil
                        preBidExistingAmount = nil
                    }
                }
            } catch { /* no-op */ }
        }
    }

    private func placePreBid() {
        let amount = Double(preBidAmountText.replacingOccurrences(of: "$", with: "")) ?? 0
        guard amount >= 1 else {
            hudMsg = "Please enter $1 or more."; showhud = true; return
        }
        Task {
            // POST /api/pre-bid  body: product_id, amount, schedule_show_id (nullable)
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/pre-bid") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            req.httpBody = try? JSONSerialization.data(withJSONObject: ["product_id": productID, "amount": amount])
            do {
                let (_, resp) = try await URLSession.shared.data(for: req)
                let ok = (resp as? HTTPURLResponse)?.statusCode == 200
                await MainActor.run {
                    if ok {
                        hudMsg = "Pre-bid placed."; showhud = true
                        loadCurrentPreBid()
                        loadHighestPreBid()
                    } else {
                        hudMsg = "Could not place pre-bid."; showhud = true
                    }
                }
            } catch {
                await MainActor.run { hudMsg = "Network error."; showhud = true }
            }
        }
    }

    private func withdrawPreBid() {
        guard let id = preBidExistingId else { return }
        Task {
            // DELETE /api/pre-bid/{id}
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/pre-bid/\(id)") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "DELETE"
            req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                let (_, resp) = try await URLSession.shared.data(for: req)
                let ok = (resp as? HTTPURLResponse)?.statusCode == 200
                await MainActor.run {
                    if ok {
                        hudMsg = "Pre-bid withdrawn."; showhud = true
                        preBidExistingId = nil
                        preBidExistingAmount = nil
                        highestPreBid = nil
                        loadHighestPreBid()
                    }
                }
            } catch { /* no-op */ }
        }
    }

    /// GET /api/pre-bid/highest/{productId} — fetch the leading pre-bid
    /// amount so we can surface it to ALL viewers (not just the one who bid).
    private func loadHighestPreBid() {
        Task {
            guard productID > 0 else { return }
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/pre-bid/highest/\(productID)") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                let (data, _) = try await URLSession.shared.data(for: req)
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                // Response shape: { status, data: { amount: "12.50" | 12.50 | nil } }
                let payload = json?["data"] as? [String: Any]
                var amt: Double? = nil
                if let a = payload?["amount"] as? Double, a > 0 { amt = a }
                else if let s = payload?["amount"] as? String, let a = Double(s), a > 0 { amt = a }
                await MainActor.run { highestPreBid = amt }
            } catch { /* no-op */ }
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

    private var productDetailSection: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("Detail")
                    .font(.custom(poppinsBold, size: 22))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                  
            }
            
            VStack(alignment: .leading,spacing: 6) {
                Text("\(productDetail?.description ?? "")")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.darkGray)
                    .lineLimit(isReadMore ? nil : 3)
                Button(!isReadMore ? "Read More" : "Read Less") {
                    isReadMore.toggle()
                }
                .font(.custom(poppinsSemiBold, size: 11))
                .foregroundColor(.defaultTheme)
            }
            HStack(spacing: 6) {
                Text("Category")
                    .font(.custom(poppinsBold, size: 13))
                    .foregroundColor(.darkGray)
                Text("\(productDetail?.category?.name ?? "")")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.darkGray)
            }.cardStyle(.lightGray)
       
            HStack(spacing: 6) {
                Text("Sub Category")
                    .font(.custom(poppinsBold, size: 13))
                    .foregroundColor(.darkGray)
                Text("\(productDetail?.sub_category?.name ?? "") ")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.darkGray)
            }.cardStyle(.white)
            HStack(spacing: 6) {
                Text("Condition")
                    .font(.custom(poppinsBold, size: 13))
                    .foregroundColor(.darkGray)
                Text("\(productDetail?.product_condition ?? "")")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.darkGray)
            }.cardStyle(.white)
        }
    }
}

extension View {
    func cardStyle(
        _ background: Color,
        fullWidth: Bool = true
    ) -> some View {
        self
            .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(background)
                    //.shadow(color: .black.opacity(0.12), radius: 6, y: 3)
            )
    }
}


// MARK: - PRODUCT HEADER INFO
extension ProductDetailView {
    // Basecamp #9933973683 (2026-05-27): is this product currently in an
    // active flash sale window?
    private var isFlashSaleActive: Bool {
        guard productDetail?.flashSale == true,
              let price = productDetail?.flashSalePrice, price > 0,
              let endsRaw = productDetail?.flashSaleEndsAt,
              let ends = DateFormatter.parseBidcastDate(endsRaw),
              ends > Date()
        else { return false }
        if let startsRaw = productDetail?.flashSaleStartsAt,
           let starts = DateFormatter.parseBidcastDate(startsRaw),
           starts > Date() {
            return false
        }
        return true
    }

    private var flashSaleCountdownText: String {
        guard let endsRaw = productDetail?.flashSaleEndsAt,
              let ends = DateFormatter.parseBidcastDate(endsRaw)
        else { return "" }
        let diff = max(0, Int(ends.timeIntervalSinceNow))
        let h = diff / 3600
        let m = (diff % 3600) / 60
        let s = diff % 60
        return h > 0 ? "\(h)h \(m)m \(s)s left" : "\(m)m \(s)s left"
    }

    private var productHeaderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Basecamp #9933973683 (2026-05-27): flash sale badge + countdown.
            if isFlashSaleActive {
                HStack(spacing: 6) {
                    Text("⚡ Flash Sale")
                        .font(.custom(poppinsBold, size: 11))
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Capsule())
                    Text(flashSaleCountdownText)
                        .font(.custom(poppinsSemiBold, size: 11))
                        .foregroundColor(.red)
                        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in /* triggers redraw */ }
                }
            }

            Text(productDetail?.title?.capitalizingFirstLetter() ?? "Product Title")
                .font(.custom(poppinsBold, size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: 6) {
                Text("\(productDetail?.quantity ?? "0") Available")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.darkGray)
            }
            
            // QA #7 — Only show "Starting at" for auction items. Buy Now items show just the price.
            // Basecamp #9933973683 (2026-05-27): show strikethrough regular price + flash sale price when active.
            if isFlashSaleActive, let flashPrice = productDetail?.flashSalePrice {
                HStack(spacing: 6) {
                    Text(productPrice.compactCurrency())
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.gray)
                        .strikethrough()
                    Text(flashPrice.compactCurrency())
                        .font(.custom(poppinsBold, size: 16))
                        .foregroundColor(.red)
                    Text("+ Shipping + taxes")
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.darkGray)
                }
            } else if productDetail?.auction == true {
                Text("Starting at \(productPrice.compactCurrency()) + Shipping + taxes")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.darkGray)
                // Basecamp #9933847997 (2026-05-29): highest pre-bid pill.
                // Shows the leading pre-bid amount from GET /api/pre-bid/highest/{id}
                // so all viewers can see the current pre-bid level.
                if let highest = highestPreBid {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)
                        Text("Highest pre-bid: \(highest.compactCurrency())")
                            .font(.custom(poppinsSemiBold, size: 12))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                Text("\(productPrice.compactCurrency()) + Shipping + taxes")
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.darkGray)
            }
        }
    }
}

extension DateFormatter {
    // Basecamp #9933973683 (2026-05-27): Laravel returns ISO timestamps as
    // "2026-05-27 22:00:00" without T separator. This formatter handles that.
    static let bidcastISO: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    // Basecamp #9933973683 (2026-05-29): ROOT-CAUSE FIX for the flash-sale price
    // not showing. The Bidcast API's Product model overrides serializeDate() to
    // emit ALL datetimes as "d-m-Y H:i:s" (e.g. "29-05-2026 10:47:00"), so the
    // old yyyy-MM-dd / ISO8601 parsers always returned nil for the flash window.
    // That made isFlashSaleActive false and suppressed the flash price entirely.
    // parseBidcastDate tries every format the backend can actually return.
    static let bidcastDMY: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd-MM-yyyy HH:mm:ss"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    static func parseBidcastDate(_ raw: String) -> Date? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        // 1. "d-m-Y H:i:s" — the real Product serializeDate() output.
        if let d = bidcastDMY.date(from: trimmed) { return d }
        // 2. "yyyy-MM-dd HH:mm:ss" (legacy assumption / some endpoints).
        if let d = bidcastISO.date(from: trimmed) { return d }
        // 3. ISO8601 with explicit zone or replacing the space with T.
        let isoCandidate = trimmed.replacingOccurrences(of: " ", with: "T")
        if let d = ISO8601DateFormatter().date(from: isoCandidate) { return d }
        if let d = ISO8601DateFormatter().date(from: isoCandidate + "Z") { return d }
        return nil
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
