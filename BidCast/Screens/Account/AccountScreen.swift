//
//  AccountScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD

// MARK: - Account Screen
struct AccountScreen: View {
    // MARK: - Environment & Observed Objects
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appRootManager: AppRootManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    // MARK: - State Objects
    @StateObject private var menuViewModel = MenuOptionsViewModel()
    // Profile fetcher — used to refresh UserDefaults.sellerVerafied on first appear
    // so verified sellers don't see a stale "pending" gate when tapping Create
    // Product. (MC: cmp583ppa00c456kdb7wjjsbl)
    @StateObject private var accountViewModel = AccountViewModel()
    
    @EnvironmentObject var tabBarRouter: TabBarRouter
    
    // MARK: - UI State
    @State private var segment: AccountSegment = .sellerHub
    @State private var showSideMenu = false
    @State private var userLogOut = false
    @State private var navigateToDeleteAccount = false
    @State private var showError = false
    @State private var showhud = false
    @State private var showPaymentShipping = false
    @State private var navigateToShipping = false
    @State var showSellerSheet = false
    @State var navigateToSeller = false
    @State private var hudMsg = ""
//    @State private var navigateToInventory = false

    
    @State private var isLoading: Bool = false
    @State private var sellerInfo: SellerhubInfoModel?
    @State private var selectedCredit: AccountCredit?
    @State private var backToAccount: Bool = false
    @State var titleText = ""
    @State private var hasLoadedData = false
   
        @State private var isRefreshing = false
    
    
    
    // MARK: - Data State
    @State private var request = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: [], is_explicit: false, show_discoverability: "", repeat_value: "", is_repeat: false, language: "english")
    
    // MARK: - Navigation State
    @State private var navigationState = NavigationState()
    var isNavFrom: Bool
    
    // MARK: - Alert State
    @State private var alertType: BottomSheetType = .sheetType(
        icon: .alert, title: "", message: "",
        primaryBtnText: "", secondaryBtnText: ""
    )
    // MARK: - Props
    let comeFromSeller: Bool
    
    init(comeFromSeller: Bool = false, isNavFrom: Bool = false) {
        self.comeFromSeller = comeFromSeller
        self.isNavFrom = isNavFrom
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                
                
                    VStack(alignment: .leading, spacing: 4) {
                        VStack {
                            profileCell
                            segmentControl
                        }
                        .padding(12)
                        .background(.white)
                    }
                    .frame(maxWidth: .infinity)
                ScrollView(showsIndicators: false) {
                        VStack {
                            if segment == .sellerHub {
                                sellerHubSection
                            } else {
                                myAccountSection
                            }
                        }
                        .padding(.horizontal, 8)
                   
                }
                
                navigationLinks
                    .frame(width: 0, height: 0)
                    .hidden()  // Hide navigation links from view
            }
            .background(Color.bg.opacity(0.5))
            .edgesIgnoringSafeArea(.bottom)
            .onFirstAppear {
//                getSellerHubInfo()
                if !hasLoadedData {
                    getSellerHubInfo()
                    // Refresh the verification flags from the profile API so the
                    // Create Product gate below reads fresh state. (MC: cmp583ppa00c456kdb7wjjsbl)
                    refreshProfileVerificationFlags()
                    hasLoadedData = true
                }
            }
            .onAppear {
                // Re-fetch seller hub info (including upcoming shows) each time the
                // view re-appears — e.g. after returning from the show-scheduling flow.
                // onFirstAppear already handles the very first load, so we skip it here.
                if hasLoadedData {
                    getSellerHubInfo()
                }
            }
            .refreshable {
                   await refreshData()
               }
        }
        .bottomSheet(
            isPresented: $userLogOut,
            height: screenHeight/2,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                print("Logout sheet dismissed")
            },
            content: {
                LogOutSheet(
                    onLogoutClick: {
                        print("Logout clicked")
                        userLogOut = false
                        handleLogout()
                    },
                    onCancelClick: {
                        print("Cancel clicked")
                        userLogOut = false
                    }
                )
            }
        )
        .bottomSheet(isPresented: $showPaymentShipping, height: screenHeight / 2.2) {
            PaymentAndShippingInfoSheet(
                isPresented: $showPaymentShipping,
                onAddInfo: {
                    if UserDefaults.sellerAddress != true {
                        showPaymentShipping = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToShipping = true
                            
                        }
                    }
                },
                buttonText: $titleText
            )
        }
        .bottomSheet(isPresented: $showSellerSheet, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
            showSellerSheet = false
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation {
                        showSellerSheet = false
                        if UserDefaults.buyerVerafied != "pending" {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                navigateToSeller = true
                            }
                        }
                    }
                },
                onSecondaryClick: {
                    withAnimation {
                        showSellerSheet = false
                    }
                }
            )
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight * 0.45,
            topBarCornerRadius: 25,
            contentBackgroundColor: Color(.systemBackground),
            topBarBackgroundColor: Color(.systemBackground),
            showTopIndicator: false,
            onDismiss: {
                showError = false
            },
            content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showError = false }
                    },
                    onSecondaryClick: {
                        withAnimation { showError = false }
                    }
                )
                .background(Color(.systemBackground))
                .cornerRadius(25, corners: [.topLeft, .topRight])
            }
        )
    }
    /// Case-insensitive check for the canonical "verified" status. The local
    /// `UserDefaults.sellerVerafied` cache mirrors `seller_identity_status` from
    /// the profile API. Some downstream sources have been observed to surface
    /// non-canonical casing (e.g. `"Verified"`) or whitespace, which would make
    /// a strict `== "verified"` check fail for users who are actually verified.
    /// (MC: cmp583ppa00c456kdb7wjjsbl)
    private var isSellerVerified: Bool {
        return UserDefaults.sellerVerafied
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == "verified"
    }

    /// Re-fetch the profile so `UserDefaults.sellerVerafied` reflects current
    /// server state when this screen mounts. Avoids stale-cache cases where a
    /// freshly verified seller still sees the "pending" gate.
    /// (MC: cmp583ppa00c456kdb7wjjsbl)
    private func refreshProfileVerificationFlags() {
        Task {
            await accountViewModel.getProfile()
            let resp = accountViewModel.accountInfo
            guard resp.status == "success", let data = resp.data else { return }
            UserDefaults.buyerVerafied = data.buyer_identity_status ?? UserDefaults.buyerVerafied
            UserDefaults.sellerVerafied = data.seller_identity_status ?? UserDefaults.sellerVerafied
            UserDefaults.sellerAddress = data.has_shipping_address ?? UserDefaults.sellerAddress
            UserDefaults.hasCardAdded = data.has_card_added ?? UserDefaults.hasCardAdded
        }
    }

    private func handleSellerVerification() {
        if UserDefaults.sellerVerafied == "pending" {
            alertType = .sheetType(
                icon: .info,
                title: "Become a Verified Seller!",
                message: "Your verification is currently pending approval by the admin. You will be notified once the process is complete.",
                primaryBtnText: "OK",
                secondaryBtnText: "",
                buttonWidth: screenWidth - 60,
                contentSize: 12.0
            )
        } else {
            alertType = .sheetType(
                icon: .info,
                title: "Become a Verified Seller!",
                message: "Before you interact with live shows.you need to become a verified seller.",
                primaryBtnText: "OK",
                secondaryBtnText: "",
                buttonWidth: screenWidth - 60
            )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.snappy) {
                showSellerSheet = true
            }
        }
    }
    // MARK: - Header View
    private var headerView: some View {
        PrimaryHeader(
            title: AppString.Account.localized,
            isForLogo: false,
            leadingImgArr: [comeFromSeller ? "chevron.left" : ""],
            trailingImgArr: [.sMenu],
            onClickLeading: { _ in
                presentationMode.wrappedValue.dismiss()
            },
            onClickTrailing: { _ in
                showSideMenu = true
            },
            count: .constant(0)
        )
    }
    
    // MARK: - Profile Cell
    private var profileCell: some View {
        ListCell(
            image: UserDefaults.profileURL.isEmpty ? "user_dummy" : UserDefaults.profileURL,
            title: UserDefaults.fullName.capitalizingFirstLetter(),
            vectorImg: .circleEditPencil,
            angle: 0.0,
            subLabel: UserDefaults.userName.capitalizingFirstLetter(),
            titleFontName: poppinsSemiBold,
            titleFontSize: 16.0,
            subLabelFontName: poppinsRegular,
            subLabelFontSize: 12.0,
            isVectorImgHidden: false,
            onTapMenuCell: {
                navigationState.navigateToProfile = true
            }
        )
        .padding(.all, 1)
        .frame(height: 80)
    }
    
    // MARK: - Segment Control
    private var segmentControl: some View {
        CustomSegmentedControl(
            preselectedIndex: $segment,
            options: AccountSegment.allCases
        )
    }
    
    // MARK: - Seller Hub Section
    private var sellerHubSection: some View {
        SellerHubSection(sellerInfo: $sellerInfo, isRefreshing: $isRefreshing) {
            // Create Show entry from the seller-stats block.
            // Verification check uses isSellerVerified (case-insensitive +
            // trimmed) instead of a strict == "verified". (MC: cmp583ppa00c456kdb7wjjsbl)
            if UserDefaults.isFirstShowCreated {
                if isSellerVerified {
                    navigationState.navigateToTitle = true
                } else {
                    handleSellerVerification()
                }
            } else {
                if isSellerVerified {
                    navigationState.navigateToGetStarted = true
                } else {
                    handleSellerVerification()
                }
            }
        } onCreateProduct: {
            // Bug (MC cmp583ppa00c456kdb7wjjsbl): verified sellers were seeing the
            // "account verification pending" sheet when tapping Create Product.
            // Root cause was either case-sensitive comparison or a stale
            // UserDefaults cache. isSellerVerified normalizes the value; the
            // .onFirstAppear hook above also refreshes the profile so the cache
            // is current before this gate runs.
            if isSellerVerified {
                if UserDefaults.sellerAddress {
                    navigationState.navigateToCreateProduct = true
                } else {
                    titleText = "Add Address"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showPaymentShipping = true
                    }
                }
            } else {
                handleSellerVerification()
            }
        } onViewAllShows: {
            navigationState.navigateToShows = true
        }
    }
    
    // MARK: - My Account Section
    private var myAccountSection: some View {
        VStack(spacing: 6) {
            creditSection
            accountTabGrid
            accountMenuList
        }
//        .padding(.bottom, 40)
        .padding(.bottom, 80)
    }
    
    // MARK: - Credit Section
    private var creditSection: some View {
        TwoVerticalLabelCell(
            dataModel: AccountCredit.allCases,
            topLabel: { credit in creditCount(for: credit) },
            bottomLabel: { $0.description },
            selection: $selectedCredit,
            onItemTap: { credit in
                print("Selected coupon:", credit)
                if credit == .coupon{
                    navigationState.navigateToCoupons = true
                }
            },
            columnsPerRow: 2
        )
      
    }
    
    // MARK: - Account Tab Grid
    private var accountTabGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)
        
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(AccountTabSection.allCases.enumerated()), id: \.offset) { index, section in
                VerticalLabelImageCell(
                    topLabel: section.img,
                    bottomLabel: section.description
                ) {
                    handleAccountTabSelection(index: index)
                }
                .aspectRatio(1, contentMode: .fill)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }
    
    // MARK: - Account Menu List
    private var accountMenuList: some View {
        ForEach(Array(AccountMenuSection.allCases.enumerated()), id: \.offset) { index, section in
            AccountMenu(
                title: section.description,
                textColor: .black,
                fontValue: 14.0,
                menuImg: section.img,
                vectorImg: .icArrowUp,
                isSelectable: false,
                isTappedSwitch: .constant(false),
                onToggle: { _ in },
                onTapMenuCell: {
                    handleMenuSelection(index: index)
                }
            )
            .frame(height: 70)
        }
    }
    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            // Profile & Verification
            
            CusNavLink(doNavigate: $navigationState.navigateToProfile, destination: CompleteProfileScreen())
            CusNavLink(doNavigate: $navigationState.navigateToSellerVerification, destination: SellerVerificationScreen())
            CusNavLink(doNavigate: $navigateToDeleteAccount, destination: DeleteAccountScreen())
            
            // My Account Navigation
            myAccountNavigationLinks
            
            // Seller Hub Navigation
            sellerHubNavigationLinks
            
            // Menu Navigation
            CusNavLink(doNavigate: $showSideMenu, destination: SellerToolsScreen())
        }
    }
    
    // MARK: - My Account Navigation Links
    private var myAccountNavigationLinks: some View {
        Group {
            CusNavLink(doNavigate: $navigationState.navigateToPayment, destination: PaymentAndShipping_Screen())
            CusNavLink(doNavigate: $navigationState.navigateToAddress, destination: AddressesScreen())
            CusNavLink(doNavigate: $navigationState.navigateTrustedBuyer, destination: TrustedBuyerScreen(comeFromHome: .constant(false)))
            CusNavLink(doNavigate: $navigationState.navigateToPreference, destination: PreferncesScreen())
            
            CusNavLink(doNavigate: $navigationState.navigateToCategory, destination: MultiSelectionCategoryScreen(isNavFrom: "Account",goToAccount: $navigationState.navigateToCategory))
            
            CusNavLink(doNavigate: $navigationState.navigateToContactus, destination: ContactUs())
            CusNavLink(doNavigate: $navigationState.navigateToSales, destination: SalesTaxScreen())
            CusNavLink(doNavigate: $navigationState.navigateToBlockedList, destination: BlockedUserScreen())
            CusNavLink(doNavigate: $navigationState.navigateToCoupons, destination: CouponListScreen(showApplyButton: false))
            CusNavLink(doNavigate: $navigationState.navigateToClips, destination: ClipsScreen())
//            CusNavLink(doNavigate: $navigationState.navigateToClips, destination:  CreateAddress())
            CusNavLink(doNavigate: $navigateToSeller, destination:  SellerVerificationScreen())
            CusNavLink(doNavigate: $navigationState.navigationToNotification, destination: NotificationScreen())

            
           

        }
    }
    
    // MARK: - Seller Hub Navigation Links
    private var sellerHubNavigationLinks: some View {
        Group {
            CusNavLink(doNavigate: $navigationState.navigateToShows, destination: ShowsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToInventry, destination: InventoryScreen())
            CusNavLink(doNavigate: $navigationState.navigateToOffers, destination: OffersScreen())
            CusNavLink(doNavigate: $navigationState.navigateTips, destination: TipsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToWallet, destination: WalletPayoutView())
            CusNavLink(doNavigate: $navigationState.navigateToMyOrder, destination: MyOrdersScreen())
            CusNavLink(doNavigate: $navigationState.navigateToShipping, destination: ShippingSettingsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToSellerStatus, destination: SellerStatusScreen())
            CusNavLink(doNavigate: $navigationState.navigateToPromoteTool, destination: PromoteToolsView())
            CusNavLink(doNavigate: $navigationState.navigateToSellerTraining, destination: SellingTips(isNavFrom: .constant("Account"), backToTabBar: .constant(true)))
            CusNavLink(doNavigate: $navigationState.navigateToPremierShop, destination: PremierShopScreen())
            CusNavLink(doNavigate: $navigationState.navigateToAnalytics, destination: AnalyticsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToAffilateProgram, destination: AffiliateProgramScreen(referralCode: "SELLER2025", stats: ReferralStats(totalReferrals: 0, earnings: 0.0), onShare: {}))
            CusNavLink(doNavigate: $navigationState.navigateToCreateProduct, destination: ListProductScreen())
            CusNavLink(doNavigate: $navigationState.navigateToTitle, destination: ShowTitleTips(request: $request, fromPrepare: .constant(false), /*backToPrepare: $navigationState.navigateToTitle, */showId: .constant(0)))
            CusNavLink(doNavigate: $navigationState.navigateToGetStarted, destination:  GetStartedScreen(backToTabBar: $navigationState.navigateToGetStarted))
           
        }
    }
}

// MARK: - Actions Extension
extension AccountScreen {
    // MARK: - Handle Account Tab Selection
    private func handleAccountTabSelection(index: Int) {
        withAnimation {
            switch index {
            case 0: navigationState.navigateToPayment = true
            case 1: navigationState.navigateToAddress = true
            case 2: navigationState.navigateTrustedBuyer = true
            case 3: navigationState.navigationToNotification = true
            case 4: navigationState.navigateToPreference = true
            case 5: navigationState.navigateToCategory = true
            case 6: navigationState.navigateToClips = true
            default: break
            }
        }
        
    }
    
    // MARK: - Handle Menu Selection
    private func handleMenuSelection(index: Int) {
        print("Menu selection: \(index)")
        switch index {
        case 0: openURL("https://backend.bidcast.betaplanets.com/about-us")
        case 1: navigationState.navigateToContactus = true
        case 2: navigationState.navigateToSales = true
        case 3: openURL("https://backend.bidcast.betaplanets.com/terms-condition")
        case 4: openURL("https://backend.bidcast.betaplanets.com/privacy-policy")
        case 5: openURL("https://backend.bidcast.betaplanets.com/faq")
        case 6: navigationState.navigateToBlockedList = true
        case 7:
            print("Delete Account tapped")
            DispatchQueue.main.async {
                navigateToDeleteAccount = true
            }
        case 8:
            print("Logout tapped - setting userLogOut to true")
            DispatchQueue.main.async {
                userLogOut = true
            }
        default: break
        }
    }
    
    // MARK: - Open URL
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Handle Logout
    private func handleLogout() {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            
            SVProgressHUD.show()
            await menuViewModel.logOut()
            await SVProgressHUD.dismiss()
            
            if menuViewModel.logOutResponse.data != nil {
                performUserLogout()
            }
        }
    }
    
    func creditCount(for offer: AccountCredit) -> String {
        switch offer {
        case .coupon:
            return UserDefaults.couponCount
        case .credit:
            return "N/A"
        
        }
    }
    private func refreshData() async {
            isRefreshing = true
            await getSellerHubInfo()
            isRefreshing = false
        }
    
    // MARK: - Get Seller Hub Info
    private func getSellerHubInfo() {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: !isRefreshing,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: menuViewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText: ""
                    )
                    showError = true
                    isLoading = true
                },
                onSuccess: {
                    isLoading = true
                    if menuViewModel.sellerHubInfoResponse?.status == "success" {
                        sellerInfo = menuViewModel.sellerHubInfoResponse?.data
                        UserDefaults.vacationMode = sellerInfo?.vacationMode == "true" ? true : false
                    }
                }
            ) {
                isLoading = true
                try await menuViewModel.getSellerHubInfo()
            }
        }
    }
    
    // MARK: - Perform User Logout
    private func performUserLogout() {
        DispatchQueue.main.async {
            // Clear user data
            UserDefaults.userName.removeAll()
            UserDefaults.fullName.removeAll()
            UserDefaults.profileURL.removeAll()
            UserDefaultsManager.shared.setValue(false, forKey: .isLoggedIn)
            
            UserDefaults.accessToken.removeAll()
            UserDefaults.sellerVerafied.removeAll()
            UserDefaults.buyerVerafied.removeAll()
            hasLoadedData = false
            sellerInfo = nil
            let rememberMe = UserDefaults.rememberMe
            if !rememberMe {
                _ = KeychainManager.shared.delete(email: UserDefaults.userEmail)
                UserDefaults.userEmail = ""
                UserDefaults.rememberMe = false
            }
            
            UserDefaults.isFirstShowCreated = false
            UserDefaults.profileURL.removeAll()
            UserDefaults.fullName.removeAll()
            UserDefaults.userName.removeAll()
        
            UserDefaults.buyerVerafied.removeAll()
            UserDefaults.sellerVerafied.removeAll()
            UserDefaults.sellerAddress = false
            UserDefaults.hasCardAdded = false
            // Keep email when remember-me is enabled so login can preload credentials from Keychain.
            if !rememberMe {
                UserDefaults.userEmail.removeAll()
            }
            UserDefaults.default_card =  DefaultCardModel()
            UserDefaults.default_shipping_address =  AddressModel()
            UserDefaults.couponCount.removeAll()
            UserDefaults.vacationMode = false
            
            
            UserDefaults.userId = -1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    appRootManager.currentRoot = .authentication
                }
            }
        }
    }
}

// MARK: - Seller Hub Section
struct SellerHubSection: View {
//    @State private var isLoadingStats = true
    private var isLoadingStats: Bool {
        sellerInfo == nil
    }
    @Binding var sellerInfo: SellerhubInfoModel?
        @Binding var isRefreshing: Bool
    @StateObject private var viewModel = MenuOptionsViewModel()
    // Stats data
    @State private var itemsCount = 0
    @State private var revenue = "$0.00"
    @State private var rating = 0.0
    @State private var onTimeRate = "0"
    // QA #29 — Defaults were showing fake values before the API landed.
    // Use safe zero/blank defaults so users never see filler data.
    @State private var defectFreeRate = "0"
    @State private var policyStanding = ""
    @State private var payouts = "$0.00"
    @State private var totalOrders = "0 Items"
    @State private var vacationToggle = false
    // QA #35 — Vacation mode confirmation
    @State private var showVacationConfirm = false
    @State private var pendingVacationToggle = false
    @State private var navigateToInventory = false
    @State private var navigateToPayouts = false
    @State private var navigateToUserProfile = false

    


    
    @State var showID = ""
    @State var SHowId = 0
    @State var isLive = false
    @State private var selectedProductData: [ProductDataModel] = []
    @State var selectedShowsData = HomeModel()
    @State var navigateToReherseal = false
    @State var navigateToshowTitle = false
    @State var navigateToShowDetails = false
    @State var navigateToOrder = false
    @State var navigateToWallet = false
    @State private var isLoading: Bool = false
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

    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showError = false
    
    var onCreateShow: () -> Void
    var onCreateProduct: () -> Void
    var onViewAllShows: () -> Void

    /// Used to detect when async `getSellerHubInfo()` finishes and `sellerInfo` becomes available.
    /// `SellerhubInfoModel` isn't `Equatable`, so we observe a stable signature `String`.
    private var sellerInfoSignature: String {
        guard let s = sellerInfo else { return "" }
        let h = s.accountHealth
        return "\(s.items ?? -1)|\(s.revenue ?? 0)|\(s.rating ?? 0)|\(s.totalOrders ?? -1)|\(s.payouts ?? -1)|\(h?.onTimeScanRate ?? "")|\(h?.defectFreeOrderRate ?? "")|\(h?.policyStanding ?? "")"
    }

    // MARK: - Apply SellerHub Stats
    private func applySellerInfoToLocalState() {
        guard let info = sellerInfo else { return }
        withAnimation {
            itemsCount = info.items ?? 0
            revenue = "\(formatCurrencyCompact(info.revenue ?? 0.0))"
            rating = info.rating ?? 0.0
            onTimeRate = "\(info.accountHealth?.onTimeScanRate ?? "0")"
            defectFreeRate = "\(info.accountHealth?.defectFreeOrderRate ?? "")"
            policyStanding = info.accountHealth?.policyStanding ?? ""
            payouts = "\(formatCurrencyCompact(Double(info.payouts ?? 0)))"
            totalOrders = "\(info.totalOrders ?? 0) Items"
            vacationToggle = UserDefaults.vacationMode
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Stats Cards Row
            statsCardsRow
            
            // Create Buttons
            createButtonsRow
            
            // Upcoming Shows Section
            upcomingShowsSection
            
            // Account Health Section
            accountHealthSection
            
            // Payout & Orders Row
            payoutOrdersRow
            
            // Vacation Mode
            vacationModeCard
                .padding(.bottom, 40)
//            CusNavLink(doNavigate: $navigateToReherseal,
//                       destination: RehearsalScreen(showUd: $showID,
//                                                    productListData: .constant([]),
//                                                    isLive: isLive,
//                                                    backToTabBar: .constant(true),
//                                                    showsData: $selectedShowsData))
            CusNavLink(doNavigate: $navigateToShowDetails,
                       destination:  ShowDetailsScreen(showId: $showID))
            
            CusNavLink(doNavigate: $navigateToshowTitle, destination:
                        ShowTitleTips(request : $scheduleRequest,
                                      fromPrepare:.constant(false),
//                                      backToPrepare: $navigateToshowTitle,
                                      showId:$SHowId) )
            
            CusNavLink(doNavigate: $navigateToOrder, destination: MyOrdersScreen())
            CusNavLink(doNavigate: $navigateToWallet, destination: WalletPayoutView())
            CusNavLink(doNavigate: $navigateToInventory, destination: InventoryScreen())
            CusNavLink(doNavigate: $navigateToPayouts, destination: WalletPayoutView())
            CusNavLink(
                doNavigate: $navigateToUserProfile,
                destination: ProfileScreen(
                    id: .constant(String(UserDefaults.userId)),
                    isComeFrom: .constant("AccountScreen"),
                    userName: .constant(UserDefaults.fullName.capitalizingFirstLetter()),
                    userImage: .constant(
                        UserDefaults.profileURL.isEmpty
                        ? "user_dummy"
                        : UserDefaults.profileURL
                    )
                )
            )

        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .onAppear {
            applySellerInfoToLocalState()
        }
        .onChange(of: sellerInfoSignature) { _, _ in
            applySellerInfoToLocalState()
        }
        .onChange(of: isRefreshing) { oldValue, newValue in
            if newValue {
//                isLoadingStats = true
            } else {
                // Reload data after refresh completes
                applySellerInfoToLocalState()
            }
        }
    }
    
    // MARK: - Stats Cards Row
    private var statsCardsRow: some View {
        HStack(spacing: 12) {
            StatCardView(
                value: isLoadingStats ? "" : "\(itemsCount)",
                label: "Itemss",
                isLoading: isLoadingStats
            )
            .onTapGesture {
                self.navigateToInventory = true
                  }
            
            StatCardView(
                value: isLoadingStats ? "" : revenue,
                label: "Revenue",
                isLoading: isLoadingStats
            )
            .onTapGesture {
                navigateToPayouts = true
                  }
            
            StatCardView(
                value: isLoadingStats ? "" : String(format: "%.1f", rating),
                label: "Rating",
                isLoading: isLoadingStats
            )
            .onTapGesture {
                navigateToUserProfile = true
                  }
        }
    }
    
    // MARK: - Create Buttons Row
    private var createButtonsRow: some View {
        HStack(spacing: 12) {
            // Create Show Button
            Button(action: onCreateShow) {
                Text("Create Show")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(.defaultTheme)
                            
                    )
//                    .shadow(color: .defaultThemeLight, radius: 1, x: 0, y: 2)
            }
            
            // Create Product Button
            Button(action: onCreateProduct) {
                Text("Create Product")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.defaultTheme)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            .fill(Color.defaultThemeLight)
                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 26)
////                            .stroke(Color.defaultTheme.opacity(0.3), lineWidth: 1.5)
//                    )
            }
        }
    }
    
    // MARK: - Upcoming Shows Section
    private var upcomingShowsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Upcoming Shows")
                    .font(.custom(poppinsBold, size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onViewAllShows) {
                    Text("View All")
                        .font(.custom(poppinsMedium, size: 14))
                        .foregroundColor(.defaultTheme)
                }
            }
            
            if isLoadingStats {
                // Shimmer Loading
                VStack(spacing: 12) {
                    ForEach(0..<2) { _ in
                        ShowShimmerCard()
                    }
                }
            }
            else if let showData = sellerInfo?.upcomingShow {
                // Shows List (Top 5)
                VStack(spacing: 12) {
                    ShowCardView(show: showData,onTap: {
                        showID = "\(showData.id ?? 0)"
                        isLive = showData.is_live ?? false
//                        selectedProductData = showData.products ?? []
                        selectedShowsData = showData
//                        navigateToReherseal = true
                        
                        navigateToShowDetails = true
                       
                    },onTapMenu:{
                        SHowId = showData.id ?? 0
                        navigateToshowTitle = true
                    })
                    .padding(.horizontal , -12)
                }
            }
            else  {
                // Empty State
                EmptyShowsCard()
            }
        }
    }
    
    // MARK: - Account Health Section
    private var accountHealthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account Health")
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.primary)
            
            if isLoadingStats {
                HStack(spacing: 12) {
                    ForEach(0..<3) { _ in
                        HealthShimmerCard()
                    }
                }
            } else {
                HStack(spacing: 0) {
                    HealthStatCard(
                        value: onTimeRate,
                        label: "On-Time\nScan Rate"
                    )
                    Divider().frame(height: 60).padding(.horizontal, 8)
                    HealthStatCard(
                        value: defectFreeRate,
                        label: "Defect-Free\nOrder Rate"
                    )
                    Divider().frame(height: 60).padding(.horizontal, 8)
                    HealthStatCard(
                        value: policyStanding,
                        label: "Policy\nStanding"
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground).opacity(0.9))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Payout & Orders Row
    private var payoutOrdersRow: some View {
        HStack(spacing: 12) {
            // Payouts Card
            if isLoadingStats {
                PayoutShimmerCard()
            } else {
                Button {
                    navigateToWallet = true
                } label: {
                    // cmpcqb3fa (2026-05-20): rename per Trey's option A — see PWA + Android.
                    PayoutCard(
                        title: "Withdrawn",
                        value: payouts
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Total Orders Card
            if isLoadingStats {
                PayoutShimmerCard()
            } else {
                Button {
                    navigateToOrder = true
                } label: {
                    // cmpcqb3fa (2026-05-20): rename per Trey's option A — value is still order COUNT, label is now LIFETIME SALES.
                    PayoutCard(
                        title: "Lifetime Sales",
                        value: totalOrders
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Vacation Mode Card
    private var vacationModeCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "beach.umbrella")
                .font(.system(size: 24))
                .foregroundColor(.defaultTheme)
            
            Text("Vacation Mode")
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            Toggle("", isOn: $vacationToggle)
                .labelsHidden()
                .tint(.defaultTheme)
                .onChange(of: vacationToggle) { oldValue, newValue in
                    // QA #35 — require confirmation before flipping vacation mode
                    guard oldValue != newValue, !showVacationConfirm else { return }
                    pendingVacationToggle = newValue
                    showVacationConfirm = true
                    // Revert visually until user confirms (will re-set in alert handler if confirmed)
                    vacationToggle = oldValue
                }
                .alert("Enable Vacation Mode?", isPresented: $showVacationConfirm) {
                    Button("Cancel", role: .cancel) {
                        // Keep the previous state — nothing to do, vacationToggle was already reverted.
                    }
                    Button(pendingVacationToggle ? "Turn On" : "Turn Off") {
                        vacationToggle = pendingVacationToggle
                        vacationData(valueData: pendingVacationToggle)
                    }
                } message: {
                    Text(pendingVacationToggle
                        ? "While Vacation Mode is on, your store will be marked as away. Buyers can still browse but new orders are paused until you turn it off. Are you sure?"
                        : "Turn off Vacation Mode and resume accepting new orders?")
                }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.bottom, 40)
    }
    
    // MARK: - Load Data
    private func loadData() {
        // Backward-compatible: keep this method name but remove delay.
        applySellerInfoToLocalState()
    }
    
    private func vacationData(valueData : Bool){
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: !isRefreshing,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText: ""
                    )
                    showError = true
                    isLoading = true
                },
                onSuccess: {
                    isLoading = true
                    if viewModel.vacationResponse.status == "success" {
                        let data = viewModel.vacationResponse.data?.vacation_mode ?? ""
                        if data == "true"{
                            UserDefaults.vacationMode = true
                        }else{
                            UserDefaults.vacationMode = false
                        }
                       
                    }
                }
            ) {
                isLoading = true
                let request = vacationRequest(vacation_mode: valueData)
                try await viewModel.UpdateVacation(param: request)
            }
            
        }
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

// MARK: - Stat Card
struct StatCardView: View {
    let value: String
    let label: String
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            if isLoading {
                ShimmerView()
                    .frame(height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text(value)
                    .font(.custom(poppinsBold, size: 20))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}


// MARK: - Empty Shows Card
struct EmptyShowsCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Upcoming Shows!")
                .font(.custom(poppinsMedium, size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Health Stat Card
struct HealthStatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.custom(poppinsBold, size: 20))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.custom(poppinsRegular, size: 11))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

// MARK: - Payout Card
struct PayoutCard: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(poppinsMedium, size: 14))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.custom(poppinsBold, size: 14))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.defaultTheme)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Shimmer Views
struct ShowShimmerCard: View {
    var body: some View {
        HStack(spacing: 12) {
            ShimmerView()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 8) {
                ShimmerView()
                    .frame(height: 16)
                    .frame(maxWidth: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                ShimmerView()
                    .frame(height: 14)
                    .frame(maxWidth: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct HealthShimmerCard: View {
    var body: some View {
        VStack(spacing: 8) {
            ShimmerView()
                .frame(height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            ShimmerView()
                .frame(height: 14)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

struct PayoutShimmerCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ShimmerView()
                .frame(height: 16)
                .frame(maxWidth: 80)
                .clipShape(RoundedRectangle(cornerRadius: 4))

            ShimmerView()
                .frame(height: 24)
                .frame(maxWidth: 120)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Navigation State
struct NavigationState {
    // My Account
    var navigateToProfile = false
    var navigateToPayment = false
    var navigateToAddress = false
    var navigateTrustedBuyer = false
    var navigateToPreference = false
    var navigateToCategory = false
    var navigateToContactus = false
    var navigateToSales = false
    var navigateToBlockedList = false
    var navigateToCoupons = false
    var navigateToClips = false
    // Seller Hub
    var navigateToShows = false
    var navigateToInventry = false
    var navigateToOffers = false
    var navigateTips = false
    var navigateToWallet = false
    var navigateToMyOrder = false
    var navigateToShipping = false
    var navigateToSellerStatus = false
    var navigateToPromoteTool = false
    var navigateToSellerTraining = false
    var navigateToPremierShop = false
    var navigateToAnalytics = false
    var navigateToAffilateProgram = false
    var navigateToSellerVerification = false
    var navigateToCreateProduct = false
    var navigateToTitle = false
    var navigateToGetStarted = false
    var navigationToNotification = false
}

// MARK: - Account Segment Enum
enum AccountSegment: String, CaseIterable, CustomStringConvertible {
    case sellerHub = "Seller Hub"
    case Account = "My Account"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "").localized
    }
}

// MARK: - Account Credit Enum
enum AccountCredit: String, CaseIterable, CustomStringConvertible {
    case credit = "Credits"
    case coupon = "Coupons"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    var labelOlt: String {
        switch self {
        case .credit: return "284"
        case .coupon: return "$5.2K"
        }
    }
}

// MARK: - Account Tab Section Enum
enum AccountTabSection: String, CaseIterable, CustomStringConvertible {
    case paymentShipping = "Payment & Shipping"
    case address = "Addresses"
    case buyer = "Trusted Buyer"
    case notifications = "Notifications"
    case preference = "Preference"
    case favCategory = "Favorite"
    case clips = "Clips"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    var img: ImageResource {
        switch self {
        case .paymentShipping: return .inventory
        case .address: return .addresses
        case .buyer: return .identityVerification
        case .notifications: return .notifications
        case .preference: return .offers
        case .favCategory: return .favourites
        case .clips : return .shows
        }
    }
}

// MARK: - Account Menu Section Enum
enum AccountMenuSection: String, CaseIterable, CustomStringConvertible {
    case about = "About Us"
    case contact = "Contact Us"
    case salesTax = "Sales tax Exemption"
    case termsAndCond = "Terms & Conditions"
    case privacy = "Privacy & Policy"
    case faq = "F.A.Q"
    case blockList = "Blocked Users"
    case deleteAccount = "Delete Account"
    case logout = "Logout"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    var img: ImageResource {
        switch self {
        case .about: return .aboutUs
        case .contact:
            return .contactUs
        case .salesTax:
            return .terms
        case .termsAndCond:
            return .terms
        case .privacy:
            return .privacyPolicy
        case .faq:
            return .faq
        case .blockList:
            return .affilateProgram
        case .deleteAccount:
            return .trash
        case .logout:
            return .logout
        }
    }
}

// MARK: - UIDevice Extension
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}


// MARK: - Coupon List Screen
struct CouponListScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var couponArr : [AssignedCoupon] = []
    @State var cardViewModel = StripeCardViewModel()
    let showApplyButton: Bool
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var selectedCouponId: Int?
    @State private var showError = false
    
    var onApply: ((AssignedCoupon) -> Void)? = nil
    
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            
            VStack{
                // MARK: - Header
                PrimaryHeader(title: "Available Coupon",leadingImgArr: ["chevron.left"],onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
            }
            .background(.white)
            

            ScrollView {
                VStack(spacing: 12) {
                    
                    if couponArr.count != 0{
                        ForEach(couponArr, id: \.id) { item in
                            CouponSelectableRow(
                                coupon: item,
                                isApplied: selectedCouponId == item.coupon?.id,
                                showApplyButton: showApplyButton
                            ) {
                                selectedCouponId = item.coupon?.id
                                onApply?(item)
                            }
                        }
                    }
                    else {
                        NoDataView(message: "No Coupon Avalable")
                    }
                }
                .padding()
            }
           
        }
//        .padding(.horizontal,12)
        .background(Color.backGround)
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
        .onFirstAppear{
            if !showApplyButton{
                Task{
                    getCoupon()
                }
            }
        }
    }
    
    //MARK: getCard.
    func getCoupon(){
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
                    couponSuccess()
                }
                
            ) {
                try await cardViewModel.getCoupon()
            }
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
}

