//
//  ShowDetailsScreen.swift
//  BidCast
//
//  Created by JamTech on 26/12/25.
//

import SwiftUI

struct ShowDetailsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Show Data
    @Binding var showId : String
    @State var show = HomeModel()
    @State var products: [ProductDataModel1] = []
    @StateObject var viewModel = ShowsViewModel()
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError = false
    // States
    
    @State var navigateToReherseal = false
    @State private var selectedProductIds: [String] = []
    @State var isLive = false
    @State var navigateToshowTitle = false
    @State var showID = 0
    // Basecamp #9934001770 (2026-05-29): co-host pairing ("take-over") popup.
    // Previously only reachable from the view-all-shows list; Trey wants it on
    // the show-details entry path too. `showCoHostPairing` presents the same
    // CoHostPairingSheet the host uses in-show; `navigateToCoHostJoin` mirrors
    // the ShowsScreen "Join as Co-Host (second device)" entry.
    @State private var showCoHostPairing: Bool = false
    @State private var navigateToCoHostJoin: Bool = false
    @State private var showSecondDeviceTakeoverPrompt: Bool = false
    @State private var launchAsSameAccountSecondDevice: Bool = false
    @State private var launchAsControlOnlyDevice: Bool = false
    @State private var launchAsVideoTakeoverDevice: Bool = false
    // FIX-3 (2026-05-30): Add Products to an existing show from ShowDetailsScreen.
    // AddProductsScreen requires LetsPrepareCoordinator + ProductManager environment objects.
    @StateObject private var addProductsCoordinator = LetsPrepareCoordinator()
    @StateObject private var addProductsManager = ProductManager()
    @State private var addProductsThumb: String = ""
    @State private var addProductsFromPrepare: Bool = false
    @State private var addProductsNavFromLib: Bool = false
    @State private var navigateToAddProducts: Bool = false
    @State private var scheduleRequest = StoreScheduleShowRequest(
        title: "",
        date: "",
        time: "",
        category_id: "",
        auction_type_id: "",
        product_ids: [],
        is_explicit: false,
        show_discoverability: "",
        repeat_value: "",
        is_repeat: false,
        language: "english"
    )
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Show Header Card
                    showHeaderCard
                    
                    // Basic Info Card
                    basicInfoCard
                    
                    // Content Info Card
                    contentInfoCard
                    
                    // Added Products Card
                    addedProductsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(.backGround)
            
            // Bottom Action Buttons
            bottomActionButtons
            
            CusNavLink(doNavigate: $navigateToReherseal,
                       destination: RehearsalScreen(showUd: $showId,
                                                    productListData: $products,
                                                    isLive: isLive,
                                                    sameAccountSecondDevice: launchAsSameAccountSecondDevice,
                                                    startControlOnly: launchAsControlOnlyDevice,
                                                    takeOverVideo: launchAsVideoTakeoverDevice,
                                                    backToTabBar: .constant(true),
                                                    showsData: $show))
            
            CusNavLink(doNavigate: $navigateToshowTitle, destination:
                        ShowTitleTips(request : $scheduleRequest,
                                      fromPrepare:.constant(false),
//                                      backToPrepare: $navigateToshowTitle,
                                      showId: $showID))
            // Basecamp #9934001770 (2026-05-29): second-device co-host join.
            CusNavLink(doNavigate: $navigateToCoHostJoin,
                       destination: CoHostJoinScreen())
            // FIX-3 (2026-05-30): Add Products navigation
            CusNavLink(
                doNavigate: $navigateToAddProducts,
                destination: AddProductsScreen(
                    request: $scheduleRequest,
                    thumbNail: $addProductsThumb,
                    fromPrepare: $addProductsFromPrepare,
                    NavFromProductLibrary: $addProductsNavFromLib,
                    backToCreateProduct: $navigateToAddProducts,
                    didTapBack: { _, _, _ in },
                    didTapEdit: { _, _ in }
                )
                .environmentObject(addProductsManager)
                .environmentObject(addProductsCoordinator)
            )
        }
        // Basecamp #9934001770 (2026-05-29): host-side pairing ("take-over")
        // popup, now reachable from show-details (was view-all-shows only).
        .sheet(isPresented: $showCoHostPairing) {
            CoHostPairingSheet(scheduleShowId: show.id ?? (Int(showId) ?? 0))
        }
        .alert("Would you like to enter and take over video?", isPresented: $showSecondDeviceTakeoverPrompt) {
            Button("No", role: .cancel) {
                launchRehearsal(secondDevice: true, controlOnly: true, takeOverVideo: false)
            }
            Button("Yes") {
                launchRehearsal(secondDevice: true, controlOnly: false, takeOverVideo: true)
            }
        }
        .background(Color.backGround)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .onFirstAppear {
            Task {
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: viewModel.errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        // On success
                        successShowData()
                    }
                    
                ) {
                    // 👇 These run in parallel
                    await viewModel.getScheduleShowData(param: getShowRequest(show_id: Int(showId) ?? 0))
                   
                    
                }
            }
        }
      
    }
    func successShowData(){
        let response = viewModel.scheduledShowData
        if response?.status == "success" {
            show = response?.data ?? HomeModel()
            self.products = show.products ?? []
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
    }
   
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Show Details")
                .font(.custom(poppinsSemiBold, size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            Color.clear
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Show Header Card
    private var showHeaderCard: some View {
        HStack(spacing: 16) {
            // Show Thumbnail
            if let thumbnail = show.thumbnail?.first {
                CustomProfileImage(url: thumbnail, isCircular: false, size: 100)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.5))
                    )
            }
            
            // Show Info
            VStack(alignment: .leading, spacing: 6) {
                Text(show.title?.capitalizingFirstLetter() ?? "Show Title")
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Text(show.category?.name ?? "Category")
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.darkGray)
                
                HStack(spacing: 4) {
//                    Image(systemName: "calendar")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
                    
                    Text(show.date?.formattedDateAndTimeString(input: "yyyy-MM-dd",output: "dd-MM-yyyy") ?? "")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.darkGray)
                    
                    Text("•")
                        .foregroundColor(.darkGray)
                    
//                    Image(systemName: "clock")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
                    
                    Text(formatTo12HourTime(show.time ?? "---"))
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.darkGray)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Basic Info Card
    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Info")
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                InfoRowView(
                    label: "Show Format",
                    value: show.auction?.name?.capitalizingFirstLetter()  ?? "Live Auction"
                )
                
                InfoRowView(
                    label: "Repeat Mode",
                    value: show.is_repeat == true ? show.repeat_value?.capitalizingFirstLetter() ?? "None" : "None"
                )

                
                InfoRowView(
                    label: "Discoverability",
                    value: show.show_discoverability?.capitalizingFirstLetter() ?? "Public"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Content Info Card
    private var contentInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content Info")
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                InfoRowView(
                    label: "Explicit Content",
                    value: show.is_explicit == true ? "Yes" : "No"
                )
                
                InfoRowView(
                    label: "Primary Language",
                    value: show.language?.capitalizingFirstLetter() ?? "English"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Added Products Card
    private var addedProductsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Added Products")
                    .font(.custom(poppinsBold, size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(products.count)/100")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.secondary)
            }
            
            if products.isEmpty {
                emptyProductsView
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                        ProductRowItem(product: product)
                            .padding(.vertical, 8)
                        if index < products.count - 1 {
                            Divider()
//                                .padding(.leading, 90)
                                .frame(height: 2)
                        }
                    }
                }
            }
            
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Empty Products View
    private var emptyProductsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "cube.box")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("No Products Added")
                .font(.custom(poppinsMedium, size: 16))
                .foregroundColor(.secondary)
            
            Text("Add products to your show")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Bottom Action Buttons
    private var bottomActionButtons: some View {
        VStack(spacing: 0) {
            Divider()

            // Basecamp #9934001770 (2026-05-29): co-host entry points on the
            // show-details path (parity with the view-all-shows screen).
            HStack(spacing: 12) {
                Button {
                    showCoHostPairing = true
                } label: {
                    coHostButtonLabel(icon: "iphone.and.arrow.forward", text: "Pair Second Device")
                }
                Button {
                    navigateToCoHostJoin = true
                } label: {
                    coHostButtonLabel(icon: "person.2.fill", text: "Join as Co-Host")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // FIX-3 (2026-05-30): Add Products button so sellers can add products to an
            // already-created show without re-entering the full creation flow.
            Button(action: {
                // Pre-populate coordinator request from the existing show
                addProductsCoordinator.request = scheduleRequest
                // Seed the product manager from the products already on this show
                addProductsManager.clearAll()
                addProductsManager.addProducts(products)
                navigateToAddProducts = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Products")
                        .font(.custom(poppinsSemiBold, size: 15))
                }
                .foregroundColor(.defaultTheme)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.defaultThemeLight)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.defaultTheme, lineWidth: 1.5)
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)

            HStack(spacing: 12) {
                // Edit Show Button
                Button(action: {
                    showID = show.id ?? 0
                    navigateToshowTitle = true
                }) {
                    Text("Edit Show")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.defaultTheme)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.defaultThemeLight)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.defaultTheme, lineWidth: 1.5)
                        )
                }
                
                // Start Show Button
                Button(action: {
                    handleStartShowTapped()
                }) {
                    Text("Start Show")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(
                                    .defaultTheme
                                )
                        )
                        .shadow(color: Color.defaultTheme.opacity(0.1), radius: 2, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.backGround)

        }
    }
    
    // Basecamp #9934001770: shared label for the co-host entry buttons.
    private func coHostButtonLabel(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.custom(poppinsSemiBold, size: 13))
        }
        .foregroundColor(.defaultTheme)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.defaultTheme.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.defaultTheme.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Helper Functions
    private func handleStartShowTapped() {
        isLive = show.is_live ?? false
        selectedProductIds = show.product_ids ?? []

        guard show.is_live == true else {
            launchRehearsal(secondDevice: false, controlOnly: false, takeOverVideo: false)
            return
        }

        Task { await checkSecondDevicePresenceBeforeLaunch() }
    }

    private func checkSecondDevicePresenceBeforeLaunch() async {
        let scheduleShowId = show.id ?? (Int(showId) ?? 0)
        guard scheduleShowId > 0,
              let url = URL(string: "https://backend.bidcast.betaplanets.com/api/product/co-host/show/\(scheduleShowId)/presence") else {
            await MainActor.run {
                launchRehearsal(secondDevice: false, controlOnly: false, takeOverVideo: false)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let scheme = "Be" + "arer"
        request.setValue("\(scheme) \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            let payload = json?["data"] as? [String: Any]
            let shouldOffer = Self.boolValue(payload?["should_offer_takeover"])
            await MainActor.run {
                if shouldOffer {
                    showSecondDeviceTakeoverPrompt = true
                } else {
                    launchRehearsal(secondDevice: false, controlOnly: false, takeOverVideo: false)
                }
            }
        } catch {
            await MainActor.run {
                launchRehearsal(secondDevice: false, controlOnly: false, takeOverVideo: false)
            }
        }
    }

    private func launchRehearsal(secondDevice: Bool, controlOnly: Bool, takeOverVideo: Bool) {
        launchAsSameAccountSecondDevice = secondDevice
        launchAsControlOnlyDevice = controlOnly
        launchAsVideoTakeoverDevice = takeOverVideo
        navigateToReherseal = true
    }

    private static func boolValue(_ any: Any?) -> Bool {
        if let value = any as? Bool { return value }
        if let value = any as? Int { return value != 0 }
        if let value = any as? String {
            return ["1", "true", "yes"].contains(value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
        }
        return false
    }

    private func formatDate(_ dateString: String) -> String {
        // Format: 12-25-2025
        let components = dateString.split(separator: "-")
        guard components.count == 3 else { return dateString }
        
        let month = components[0]
        let day = components[1]
        let year = components[2]
        
        return "\(month)-\(day)-\(year)"
    }
    func formatTo12HourTime(_ timeString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"  // input format
        if let date = dateFormatter.date(from: timeString) {
            dateFormatter.dateFormat = "h:mm a" // output format
            return dateFormatter.string(from: date)
        }
        return timeString // fallback
    }
}

// MARK: - Info Row Component
struct InfoRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Product Row Item Component
struct ProductRowItem: View {
    let product: ProductDataModel1
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            VStack(alignment: .leading) {
                if let imageUrl = product.images?.first {
                    CustomProfileImage(url: imageUrl, isCircular: false, size: 80)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray.opacity(0.5))
                        )
                }
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text(product.productCondition ?? "New")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(product.category?.name ?? "Category")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(formatCurrencyCompact(Double(product.pricing ?? "0.0") ?? 0.0))")
                        .font(.custom(poppinsBold, size: 16))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 0) {
                        Text("\(product.bidCount ?? 0) bids")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Stock: \(product.quantity ?? "0")")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    private func formatCurrencyCompact(_ value: Double) -> String {
            let absValue = abs(value)
            let sign = value < 0 ? "-" : ""
            
            switch absValue {
            case 1_000_000_000...:
                // Billions
                return String(format: "%@$%.2fB", sign, absValue / 1_000_000_000)
            case 1_000_000...:
                // Millions
                return String(format: "%@$%.2fM", sign, absValue / 1_000_000)
            case 1_000...:
                // Thousands
                return String(format: "%@$%.1fK", sign, absValue / 1_000)
            default:
                // Less than 1000 - show full amount
                return String(format: "%@$%.2f", sign, absValue)
            }
        }
}

// MARK: - Show Model (Example - Adjust to your actual model)
struct ShowModel {
    var id: Int?
    var title: String?
    var thumbnail: String?
    var category: CategoryDataModel?
    var date: String?
    var time: String?
    var auctionType: AuctionType?
    var isRepeat: Bool?
    var repeatValue: String?
    var showDiscoverability: String?
    var isExplicit: Bool?
    var language: String?
}

struct AuctionType {
    var name: String?
}

// MARK: - Loading Shimmer View
struct ShowDetailsShimmer: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Header Card Shimmer
                HStack(spacing: 16) {
                    ShimmerView()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ShimmerView()
                            .frame(width: 200, height: 18)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        ShimmerView()
                            .frame(width: 150, height: 14)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        ShimmerView()
                            .frame(width: 180, height: 13)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                
                // Info Cards Shimmer
                ForEach(0..<3) { _ in
                    VStack(alignment: .leading, spacing: 16) {
                        ShimmerView()
                            .frame(width: 120, height: 18)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(spacing: 12) {
                            ForEach(0..<2) { _ in
                                HStack {
                                    ShimmerView()
                                        .frame(width: 100, height: 15)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                    Spacer()
                                    
                                    ShimmerView()
                                        .frame(width: 80, height: 15)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}


//#Preview {
//    ShowDetailsScreen(show: ShowModel())
//}
