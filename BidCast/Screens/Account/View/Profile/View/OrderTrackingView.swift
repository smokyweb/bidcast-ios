//
//  OrderTrackingView.swift
//  BidCast
//
//  Created by JamTech on 27/11/25.
//

import SwiftUI

struct OrderTrackingView: View {
    @State private var progress: CGFloat = 0
    @State private var showCopied = false
    @State private var bounceAnimation = false
    @State private var showProductDetails = false
    
    @State private var navigateToProfile: Bool = false
    @State private var navigateToChat: Bool = false
    @State private var navigateToContact: Bool = false
    @State private var navigateToReferScreen: Bool = false
    @State private var navigateToOrderDetails: Bool = false
    @State private var navigateToVideoReceipt: Bool = false
    
    @State private var videoURL: String = ""
    
    @State private var chatPath: String = ""
    
    @Binding var orderId: String
    @Binding var productId: String
    //    @State var orderId : Int = 0
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel =  OffersViewModel()
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    @State private var showError: Bool = false
    @State private var orderResponse: OrderDetailsModel?
    @State var selectedOrderDetails: MyOrderModel?
    
    @State private var userId: String = ""
    @State private var userImage: String = ""
    @State private var userName: String = ""
    
    var body: some View {
        VStack {
            VStack{
                PrimaryHeader(title: orderResponse?.order?.product?.title?.capitalizingFirstLetter() ?? "" ,
                              leadingImgArr: ["chevron.left"],
                              onClickLeading: {_ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
            }
            .background(.white)
            .frame(height:50)
            
            ScrollView {
                VStack(spacing: 16) {
                    // Main Status Card
                    mainStatusCard
                    
                    // Product Image Card
                    productImageCard
                    
                    // Order Details Card
                    orderDetailsCard
                    
                    // Buyer Protections Card
                    buyerProtectionsCard
                    
                    // Seller Info Card
                    sellerInfoCard
                }
                .padding(.horizontal, 12)
                .padding(.top,12)
                .padding(.bottom, 0)
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(.backGround)
            
            CusNavLink(doNavigate: $navigateToProfile,
                       destination: ProfileScreen(id:$userId,
                                                  isComeFrom: .constant(""),
                                                  userName: $userName,
                                                  userImage: $userImage))
            CusNavLink(
                doNavigate: $navigateToChat,
                destination: ChatScreen(
                    viewModel: ChatModel(
                        currentUserId: "\(UserDefaults.userId)",
                        currentUserName: UserDefaults.fullName,
                        currentUserImage: UserDefaults.profileURL,
                        otherUserId: userId,
                        otherUserName: userName,
                        otherUserImage: userImage
                    )
                )
            )
            
            CusNavLink(doNavigate: $navigateToContact, destination: ContactUs())
            
            CusNavLink(doNavigate: $navigateToReferScreen, destination: ReferEarnScreen())
            
            CusNavLink(doNavigate: $navigateToOrderDetails, destination: OrderStatusScreen(
                productDetail: $selectedOrderDetails,
                comeFrom: "myOrder", orderId:.constant(0)
            ))
            CusNavLink(doNavigate: $navigateToVideoReceipt, destination: VideoPlayerScreen(videoURL: $videoURL))
        }
        .overlay(
            CustomBottomSheetView(
                isPresented: $showError,
                config: config,
                primaryAction: {
                    withAnimation {
                        showError = false
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showError = false
                    }
                }
            )
        )
        //            .navigationBarTitleDisplayMode(.inline)
        //            .toolbar {
        //                ToolbarItem(placement: .principal) {
        //                    HStack(spacing: 12) {
        //                        // Back Button
        //                        Button {
        //                            presentationMode.wrappedValue.dismiss()
        //                        } label: {
        //                            Image(systemName: "chevron.left")
        //                                .font(.custom(poppinsSemiBold, size: 16))
        //                                .foregroundColor(.black)
        //                                .padding(.leading, 4)
        //                        }
        //
        //                        Spacer()
        //
        //                        // Title
        //                        Text(orderResponse?.order?.product?.title?.capitalizingFirstLetter() ?? "Single #212")
        //                            .font(.custom("Poppins-SemiBold", size: 18))
        //                            .foregroundColor(.black)
        //                            .lineLimit(1)
        //
        //                        Spacer()
        //                    }
        //                    .background(.white)
        //                    .frame(maxWidth: .infinity)
        ////                    .background(.white)
        //                }
        //
        //            }
        .edgesIgnoringSafeArea(.bottom)
        .background(.backGround)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                progress = 0.25
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever()) {
                bounceAnimation.toggle()
            }
            
            //API Call
            Task {
                await getOrderDetails()
            }
        }
    }
    
    private func getOrderDetails() async {
        
        await performAPICalls(
            isConcurrent: false,
            showLoader: true,
            onError: { error in
                config = BottomSheetConfig(
                    icon: "exclamationmark.circle",
                    title: "Error",
                    message: errorDesc(error: error, message: viewModel.errorMessage),
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil
                )
                showError = true
            },
            onSuccess: {
                let response = viewModel.purchaseOrderDetailsResponse
                orderResponse = response?.data
                videoURL = orderResponse?.bidVideoURL ?? ""
                userId = "\(response?.data?.sellerDetails?.id ?? 0)"
                userImage = response?.data?.sellerDetails?.profile_image ?? ""
                userName = response?.data?.sellerDetails?.name ?? ""
                selectedOrderDetails = MyOrderModel.convertToMyOrderModel(from: response?.data)
            }
        ) {
            let request = PurchaseOrderDetailsRequest(order_id: "\(orderId)", product_id: "\(productId)")
            try await viewModel.getPurchasedOrderDetails(request: request)
        }
    }

    // MARK: - Main Status Card
    var mainStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Preparing Package")
                .font(.custom(poppinsBold, size: 22))
                .foregroundColor(.black)
            
            Text("Typically ships in 1 day")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.black)
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            colors: [Color.defaultTheme.opacity(0.4), Color.defaultTheme],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("The seller is preparing your package to ship. They typically ship in 1 day. Once the package is scanned, you'll receive tracking updates to follow its journey to you.")
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.secondary)
                .lineSpacing(2)
            
            Button(action: {}) {
                HStack {
                    Text("Bundled with 5 other items")
                        .font(.custom("Poppins-SemiBold", size: 12))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.blue)
            }
            
            Text("Order placed \(formattedDate(orderResponse?.order?.createdAt))") // dynamic update
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.secondary)
            
            // Action Buttons
            VStack(spacing: 12) {
                ActionButtonView(
                    icon: "mappin",
                    title: "Shipping to",
                    subtitle: formattedShippingAddress(orderResponse?.shippingAddress)
                ) {
                    
                }
                
                ActionButtonView(
                    icon: "message",
                    title: "Message the seller"
                ) {
                    let currentUserId = String(UserDefaults.userId)
                    let selectedUserId = userId
                    let sortedRoomId = computeRoomId(senderId: currentUserId, receiverId: selectedUserId)
                    chatPath = "chats/\(sortedRoomId)"
                    
                    print("Computed Chat Path: \(chatPath)")
                    navigateToChat = true
                }
                
                ActionButtonView(
                    icon: "questionmark.circle",
                    title: "Get help with this purchase",
                    subtitle: "Eligible for a refund within 7 days of delivery."
                ) {
                    navigateToContact = true
                }
                
                ActionButtonView(
                    icon: "gift",
                    title: "Refer a buyer, earn $5!",
                    subtitle: "Get credit towards your next purchase"
                ) {
                    navigateToReferScreen = true
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        .transition(.opacity.combined(with: .offset(y: 10)))
    }
    
    // MARK: - Date Formatter
    private func formattedDate(_ isoDate: String?) -> String {
        guard let isoDate = isoDate else { return "" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: isoDate) {
            let output = DateFormatter()
            output.dateFormat = "MMM dd, yyyy 'at' hh:mm a"
            return output.string(from: date)  // dynamic update
        }
        
        return isoDate
    }
    
    private func computeRoomId(senderId: String, receiverId: String) -> String {
        let sortedIds = [senderId, receiverId].sorted()
        return "\(sortedIds[0])_chats_\(sortedIds[1])"
    }
    
    // MARK: - Shipping Address Formatter
    private func formattedShippingAddress(_ address: ShippingAddressModel?) -> String {
        guard let address else { return "" }
        
        return """
        \(address.name ?? "")
        \(address.streetAddress ?? "")
        \(address.city ?? "") \(address.state ?? "") \(address.pincode ?? "")
        """ // dynamic update
    }
    
    func formatOrderDate(_ isoDate: String?) -> String {
        guard let isoDate else { return "" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: isoDate) else { return isoDate }
        
        let output = DateFormatter()
        output.dateFormat = "MMM dd yyyy"   // May 25 2025
        
        return output.string(from: date)
    }
    
    // MARK: - Product Image Card
    var productImageCard: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        CustomProfileImage(
                            url: orderResponse?.order?.product?.images?.first,
                            isCircular: false,
                            cornerRadius: 12,
                            size: 200,
                            height: 200,
                            defaultImage: "photo"
                        ) {
                            print("profile icon tapped")
                        }
                        
                        Text(orderResponse?.order?.product?.title?.capitalizingFirstLetter() ?? "Single #212")
                            .font(.custom("Poppins-Bold", size: 20))
                        
                        Text(orderResponse?.order?.product?.description ?? "Near Mint")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.secondary)
                        
                        Button {
                            withAnimation(.spring()) { showProductDetails.toggle() }
                        } label: {
                            HStack(spacing: 4) {
                                Text("View Product Details")
                                    .font(.custom("Poppins-SemiBold", size: 14))
                                
                                Image(systemName: showProductDetails ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                }
                if showProductDetails {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Product Details")
                            .font(.custom("Poppins-Bold", size: 18))
                            .padding(.top, 8)
                        
                        VStack(spacing: 0) {
                            DetailRowView(label: "Category", value: orderResponse?.order?.product?.category?.name ?? "Near Mint")
                            DetailRowView(label: "Price", value: orderResponse?.order?.product?.pricing ?? "0.0", showDivider: false)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                }
            }
            
        
        }
        .padding(0)
    }
    
    // MARK: - Order Details Card
    var orderDetailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Expanded / Collapsed Product Details
            Text("Order Details")
                .font(.custom("Poppins-Bold", size: 18))
                .padding(.top, 8)
            
            VStack(spacing: 0) {
                DetailRowView(label: "Order ID", value: orderResponse?.order?.orderID ?? "#ORD-123-345", isCopyable: false, showCopied: $showCopied)
                DetailRowView(label: "Order Date", value: formatOrderDate(orderResponse?.order?.createdAt) ?? "Nov 25, 2025")
                DetailRowView(label: "Sold By", value: orderResponse?.sellerDetails?.name ?? "wyynaut")
                DetailRowView(label: "Qty", value: orderResponse?.order?.product?.purchasedQuantity ?? "1")
                DetailRowView(label: "Category", value: orderResponse?.order?.product?.category?.name ?? "Near Mint")
            }
            
            VStack(spacing: 12) {
                CompactActionButton(icon: "doc.text", title: "Receipt & shipping details") {
                    navigateToOrderDetails = true
                }
                CompactActionButton(icon: "play.fill", title: "Video Receipt", subtitle: "Video receipt available for 60 more days") {
                    if let videooURL = orderResponse?.bidVideoURL {
                        navigateToVideoReceipt = true
                    }
                }
            }
            .padding(.top, 8)
            
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Buyer Protections Card
    var buyerProtectionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Buyer Protections")
                .font(.custom("Poppins-Bold", size: 18))
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.defaultThemeLight)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Whatnot Buyer Guarantee")
                        .font(.custom("Poppins-SemiBold", size: 14))
                    
                    Text("Receive your purchase on time and as described or we'll make it right.")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                //                Spacer()
                //
                //                Image(systemName: "chevron.right")
                //                    .font(.system(size: 14, weight: .semibold))
                //                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    // MARK: - Seller Info Card
    var sellerInfoCard: some View {
        
        VStack(spacing: 12) {
            
            Text("About the Seller")
                .font(.custom("Poppins-Bold", size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZStack(alignment: .bottom) {
                // Seller Banner / Cover
                LinearGradient(
                    colors: [Color.yellow, Color.orange, Color.purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 120)
                .cornerRadius(8)
                //                .overlay(
                //                    Text("😎")
                //                        .font(.system(size: 60))
                //                )
                
                // MARK: - UPDATED: Seller Profile Image
                CustomProfileImage(
                    url: orderResponse?.sellerDetails?.profile_image,   // dynamic seller image
                    isCircular: true,
                    cornerRadius: 50,
                    size: 100,
                    height: 100,
                    defaultImage: "user_dummy"
                ) {
                    print("Seller tapped")
                    navigateToProfile = true
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                )
                .offset(y: 40)
            }
            
            VStack(spacing: 12) {
                
                // Seller Name
                Text(orderResponse?.sellerDetails?.name ?? "Unknown Seller")
                    .font(.custom("Poppins-Bold", size: 20))
                    .padding(.top, 40)
                
                // -----------------------
                // MARK: Stats Row
                // -----------------------
                HStack(spacing: 0) {
                    StatScreen(
                        icon: "star.fill",
                        value: String(format: "%.1f", orderResponse?.ratingAvg ?? 0.0),
                        label: "Rating"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: nil,
                        value: "\(orderResponse?.review ?? "0")",
                        label: "Reviews"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: nil,
                        value: "\(orderResponse?.soldCount ?? 0)",
                        label: "Sold"
                    )
                    
                    Divider().frame(height: 40).padding(.horizontal, 8)
                    
                    StatScreen(
                        icon: "clock",
                        value: orderResponse?.avgShip ?? "0",
                        label: "Avg Ship"
                    )
                }
                .padding(12)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                
                //                // Seller Bio
                //                VStack(alignment: .leading, spacing: 4) {
                //                    Text(orderResponse?.sellerDetails?.username ?? "-")
                //                    Text(orderResponse?.sellerDetails?.email ?? "-")
                //                }
                //                .font(.custom("Poppins-Regular", size: 14))
                //                .foregroundColor(.primary)
                //                .frame(maxWidth: .infinity, alignment: .leading)
                //
                // View Profile Button
                Button(action: {
                    navigateToProfile = true
                }) {
                    Text("View Profile")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
            }
        }
        .padding(0)
        //        .background(Color.white)
        //        .cornerRadius(20)
        //        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Action Button Component
struct ActionButtonView: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    
    @State private var isPressed = false
    var btnTappedClosure: (() -> Void) = {}
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            btnTappedClosure()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.primary)
                }
                .scaleEffect(isPressed ? 1.1 : 1.0)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Detail Row Component
struct DetailRowView: View {
    let label: String
    let value: String
    var isLink: Bool = false
    var isCopyable: Bool = false
    @Binding var showCopied: Bool
    
    var showDivider: Bool = true
    
    init(label: String, value: String, isLink: Bool = false, isCopyable: Bool = false, showCopied: Binding<Bool> = .constant(false), showDivider: Bool = true) {
        self.label = label
        self.value = value
        self.isLink = isLink
        self.isCopyable = isCopyable
        self._showCopied = showCopied
        self.showDivider = showDivider
    }
    
    var body: some View {
        if showDivider {
            HStack {
                Text(label)
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(value)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(isLink ? .blue : .primary)
                    
                    if isCopyable {
                        Button(action: {
                            UIPasteboard.general.string = value
                            showCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopied = false
                            }
                        }) {
                            ZStack {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.blue)
                                
                                if showCopied {
                                    Text("Copied!")
                                        .font(.custom("Poppins-Medium", size: 10))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.8))
                                        .cornerRadius(6)
                                        .offset(y: -30)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .overlay(
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
        }
        else {
            HStack {
                Text(label)
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(value)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(isLink ? .blue : .primary)
                    
                    if isCopyable {
                        Button(action: {
                            UIPasteboard.general.string = value
                            showCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopied = false
                            }
                        }) {
                            ZStack {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.blue)
                                
                                if showCopied {
                                    Text("Copied!")
                                        .font(.custom("Poppins-Medium", size: 10))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.8))
                                        .cornerRadius(6)
                                        .offset(y: -30)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Compact Action Button
struct CompactActionButton: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var btnAction: (() -> Void) = { }
    var body: some View {
        Button(action: {
            btnAction()
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            btnAction()
        }
    }
}


extension OrderTrackingView {
    private func errorDesc(error: Error?, message: String?) -> String {
        guard let msg = message else {
            return error?.localizedDescription ?? "Something went wrong"
        }
        return msg
    }
}

