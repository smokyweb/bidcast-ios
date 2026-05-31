//
//  TabbarScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//@ObservedObject var languageManager = LanguageManager.shared

import SwiftUI

final class TabBarRouter: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var previousTab: Int = 0
    @Published var exploreInitialTab: Int = 0
    // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14): when the user taps
    // a sub-category on the Explore tab we now switch to the Home tab and
    // pass the chosen filter via these properties instead of pushing
    // HomeViewScreen inside the Explore tab's NavigationView. The push
    // path was being hidden by iOS's default hidesBottomBarWhenPushed
    // behaviour, which was making the bottom tab bar disappear on the
    // pushed Home screen. Switching tabs (vs pushing) keeps the tab bar
    // visible and is the semantically-correct behaviour anyway: the user
    // is moving between top-level surfaces, not drilling into a detail.
    @Published var pendingHomeCategory: String = ""
    @Published var pendingHomeSubCategory: String = ""
    @Published var pendingHomeFilterFromExplore: Bool = false
}

struct TabbarScreen: View {
    @EnvironmentObject var productManager: ProductManager
    @EnvironmentObject var tabBarRouter: TabBarRouter
    @EnvironmentObject var deepLink: DeepLinkManager
    @State private var previousTab = 0
    @State private var showSellSheet = false
    @State private var selectedSellTab: SellTabOption? = nil
    @State private var navigateTogetStarted = false
    @State private var navigateTolist = false
    @State private var navigateToAccountScreen = false
    @State var navigateToTitle = false
    @ObservedObject var languageManager = LanguageManager.shared
    
    @State private var homeNavigationPath = NavigationPath()
    // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14): mutable filter state
    // for the Home tab so Explore can hand off a category filter via
    // tabBarRouter and switch tabs (vs pushing inside Explore's nav stack,
    // which used to hide the bottom tab bar).
    @State private var homeShowCategory: String = ""
    @State private var homeShowSubCategory: String = ""
    @State private var homeComeFromExplore: Bool = false
    @State private var exploreNavigationPath = NavigationPath()
    @State private var activityNavigationPath = NavigationPath()
    @State private var accountNavigationPath = NavigationPath()
    
    @State private var homeViewID = UUID()
    @State private var exploreViewID = UUID()
    @State private var activityViewID = UUID()
    @State private var accountViewID = UUID()
    
    @State var request : StoreScheduleShowRequest = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: [], is_explicit: false, show_discoverability: "", repeat_value: "", is_repeat: false, language: "english")
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showSellerSheet = false
    @State var navigateToSeller = false
    @State var showPaymentShipping = false
    @State var navigateToShipping = false
    @State var titleText = ""
    
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var navigateToShow = false
    @State private var selectedShowId: String?

    // Trey QA 2026-05-31: inquiry deep-link state.
    // When a push with type=inquiry_message arrives, switch to Activity tab
    // and broadcast the thread id via NotificationCenter so ActivityScreen
    // can open the InquiryThreadView directly.
    @State private var pendingInquiryThreadId: Int? = nil
    
    // Add navigation state container
    @State private var pendingNavigation: PendingNavigation?
    
    enum PendingNavigation {
        case getStarted
        case title
        case list
        case account
        case seller
        case shipping
    }

    // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14): TabView only fires its
    // selection binding's setter when the selected value actually changes.
    // We need to also catch the case where the user is already on the Home
    // tab with an Explore filter applied and they tap the Home tab icon
    // again — PM wants that to clear the filter and show plain Home.
    // Wrapping the selection in a custom Binding lets us detect every tap
    // (including same-tab re-taps) and clear the filter before forwarding
    // the value to the underlying router.
    private var tabSelectionBinding: Binding<Int> {
        Binding<Int>(
            get: { tabBarRouter.selectedTab },
            set: { newTab in
                if newTab == 0
                    && tabBarRouter.selectedTab == 0
                    && homeComeFromExplore {
                    // Re-tap on Home while filtered → clear filter (plain Home).
                    homeComeFromExplore = false
                    homeShowCategory = ""
                    homeShowSubCategory = ""
                }
                tabBarRouter.selectedTab = newTab
            }
        )
    }

    var body: some View {
        // Wrap everything in NavigationStack
        NavigationStack {
            TabView(selection: tabSelectionBinding) {
                
                NavigationContainer(navigationPath: $homeNavigationPath) {
                    HomeViewScreen(deepLinkShowId:selectedShowId,
                                   showCategory: $homeShowCategory,
                                   showSubCategory: $homeShowSubCategory,
                                   comeFromExploreScreen: $homeComeFromExplore,
                                   isNavFrom: "Login")
                }
                .id(homeViewID)
                .disabled(showSellSheet) // Disable interaction when sheet is open
                .tabItem {
                    VStack {
                        Image(tabIcon(for: 0))
                        Text("Home")
                    }
                }
                .tag(0)
                
                NavigationContainer(navigationPath: $exploreNavigationPath) {
                    ExploreViewScreen()
                }
                .id(exploreViewID)
                .disabled(showSellSheet) // Disable interaction when sheet is open
                .tabItem {
                    VStack {
                        Image(tabIcon(for: 1))
                        Text("Explore")
                    }
                }
                .tag(1)
                
                Color.clear
                    .tabItem {
                        VStack {
                            Image(tabIcon(for: 2))
                            Text("Sell")
                        }
                    }
                    .tag(2)
                
                NavigationContainer(navigationPath: $activityNavigationPath) {
                    ActivityScreen()
                }
                .id(activityViewID)
                .disabled(showSellSheet) // Disable interaction when sheet is open
                .tabItem {
                    VStack {
                        Image(tabIcon(for: 3))
                        Text("Activity")
                    }
                }
                .tag(3)
                
                NavigationContainer(navigationPath: $accountNavigationPath) {
                    AccountScreen()
                }
                .id(accountViewID)
                .disabled(showSellSheet) // Disable interaction when sheet is open
                .tabItem {
                    VStack {
                        Image(tabIcon(for: 4))
                        Text("Account")
                    }
                }
                .tag(4)
            }
            .accentColor(.black)
            .onChange(of: tabBarRouter.selectedTab) { newTab in
                // Prevent onChange from triggering when sheet is open
                guard !showSellSheet else { return }
                
                if newTab == 2 {
                    showSellSheet = true
                    tabBarRouter.selectedTab = previousTab
                } else {
                    // MC cmpewtofs000msahgns50t4yk (2026-05-xx): Fix tab-switch flash
                    // on Home / Explore / Activity.
                    //
                    // Previously we called resetNavigation(for: newTab) here,
                    // which regenerated the destination tab's UUID. Changing
                    // a view's .id() tears down the entire SwiftUI subtree and
                    // rebuilds it from scratch — triggering .onAppear, all API
                    // calls, and any loading-skeleton states. That is the
                    // visible "flash / snap" on Home, Explore, and Activity.
                    // Account does not flash because it reads from UserDefaults
                    // / cached state with no visible loading skeleton.
                    //
                    // Fix: only full-nuke (path + UUID) the tab we are
                    // LEAVING (to collapse any pushed stack and clear the
                    // toolbar-bleed from the Explore drill-in). For the tab we
                    // are ARRIVING on, only reset the NavigationPath — this
                    // collapses any stale pushed stack without destroying the
                    // view tree, keeping the live content visible and
                    // eliminating the flash.
                    //
                    // FOLLOWUP — MC cmpewtofs000msahgns50t4yk (Robin
                    // 2026-05-22): the v1 "keep arriving tab's UUID" fix
                    // wasn't enough. The leaving-tab UUID regen STILL
                    // resets the leaving tab's @State, so when the user
                    // tabs BACK to that tab later, its view rebuilds from
                    // scratch, .onFirstAppear fires again, fetchCategory
                    // re-runs, isLoadingAPI=true + categoryList.removeAll()
                    // — producing the 12-empty-rectangle shimmer skeleton
                    // Larry sees for a split second on every tab visit
                    // (Frame A in the 12:58 screenshot).
                    //
                    // Switch both sides to path-only reset. Toolbar-bleed
                    // from Explore drill-in is already handled by
                    // `.toolbar(.visible, for: .tabBar)` on the
                    // destination (cmp49377u00mb3mx117bl0r4x). If any
                    // residual bleed shows up on QA we re-introduce a
                    // narrower fix scoped to just that destination.
                    resetNavigationPath(for: previousTab)
                    resetNavigationPath(for: newTab)
                    previousTab = newTab
                    // MC cmp5czpw900jo56kdn739kkjp (Ankit 2026-05-14): when we
                    // land on the Home tab and Explore has handed off a filter
                    // via tabBarRouter, apply it to the Home tab's binding
                    // state. Then clear the pending flag so the filter sticks
                    // for the current visit but doesn't auto-re-apply later.
                    if newTab == 0 && tabBarRouter.pendingHomeFilterFromExplore {
                        homeShowCategory = tabBarRouter.pendingHomeCategory
                        homeShowSubCategory = tabBarRouter.pendingHomeSubCategory
                        homeComeFromExplore = true
                        tabBarRouter.pendingHomeFilterFromExplore = false
                        tabBarRouter.pendingHomeCategory = ""
                        tabBarRouter.pendingHomeSubCategory = ""
                    } else if newTab == 0 {
                        // User landed on Home without a hand-off — reset the
                        // explore-derived filter so the regular Home view
                        // shows again.
                        homeComeFromExplore = false
                        homeShowCategory = ""
                        homeShowSubCategory = ""
                    }
                }
            }
            
            .onReceive(deepLinkManager.$liveShowId) { showId in
                guard let showId else { return }

                // 1️⃣ Switch to Home tab
                tabBarRouter.selectedTab = 0

                // 2️⃣ Reset Home navigation stack
                resetNavigation(for: 0)

                // 3️⃣ Store show id & navigate
                selectedShowId = showId
//                navigateToShow = true

                // 4️⃣ Reset deep link
                deepLinkManager.reset()
            }
            // Trey QA 2026-05-31: inquiry deep-link — switch to Activity tab
            // then post NavToInquiryThread so ActivityScreen opens the thread.
            .onReceive(
                NotificationCenter.default.publisher(for: NSNotification.Name("NavToInquiryThread"))
            ) { notification in
                let tid = notification.object as? Int
                // Switch to Activity tab (index 3)
                tabBarRouter.selectedTab = 3
                resetNavigation(for: 3)
                // Slight delay so the tab switch settles before pushing the thread
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("PushInquiryThread"),
                        object: tid
                    )
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: NSNotification.Name("NavToInquiryInbox"))
            ) { _ in
                // No thread_id — switch to Activity tab; user sees inbox from there.
                tabBarRouter.selectedTab = 3
                resetNavigation(for: 3)
            }
            // Navigation destinations
            .navigationDestination(isPresented: $navigateTogetStarted) {
                            GetStartedScreen(backToTabBar: $navigateTogetStarted)
                                .navigationBarHidden(true)
                                .toolbar(.hidden, for: .navigationBar)
                        }
                        .navigationDestination(isPresented: $navigateToTitle) {
                            ShowTitleTips(
                                request: $request,
                                fromPrepare: .constant(false),
//                                backToPrepare: $navigateToTitle,
                                showId: .constant(0)
                            )
                            .environmentObject(productManager)
                            .navigationBarHidden(true)
                            .toolbar(.hidden, for: .navigationBar)
                        }
                        .navigationDestination(isPresented: $navigateTolist) {
                            ListProductScreen()
                                .navigationBarHidden(true)
                                .toolbar(.hidden, for: .navigationBar)
                        }
                        .navigationDestination(isPresented: $navigateToAccountScreen) {
                            AccountScreen(comeFromSeller: true, isNavFrom: true)
                                .navigationBarHidden(true)
                        }
                        .navigationDestination(isPresented: $navigateToSeller) {
                            SellerVerificationScreen()
                                .navigationBarHidden(true)
                                .toolbar(.hidden, for: .navigationBar)
                        }
                        .navigationDestination(isPresented: $navigateToShipping) {
                            CreateAddress()
                                .navigationBarHidden(true)
                                .toolbar(.hidden, for: .navigationBar)
                        }
                      
        }
        .sheet(isPresented: $showSellSheet) {
            // On dismiss, wait a bit before processing any pending navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                processPendingNavigation()
            }
        } content: {
            SellScreen { tappedTab in
                // Store the navigation intent
                storePendingNavigation(for: tappedTab)
                // Dismiss sheet
                showSellSheet = false
            } onTapCancel: {
                showSellSheet = false
                pendingNavigation = nil
            }
            .presentationDetents([.fraction(0.43)])
            .presentationDragIndicator(.visible)
        }
        .bottomSheet(isPresented: $showPaymentShipping, height: screenHeight / 2.8) {
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
    }
    
    // Store navigation intent when sell sheet button is tapped
    private func storePendingNavigation(for tappedTab: SellTabOption) {
        if tappedTab == .lesson {
            if UserDefaults.isFirstShowCreated {
                if UserDefaults.sellerVerafied == "verified" {
                    pendingNavigation = .title
                } else {
                    pendingNavigation = nil
                    handleSellerVerification()
                }
            } else {
                if UserDefaults.sellerVerafied == "verified" {
                    pendingNavigation = .getStarted
                } else {
                    pendingNavigation = nil
                    handleSellerVerification()
                }
            }
        } else if tappedTab == .listProduct {
            if UserDefaults.sellerVerafied == "verified" {
                if UserDefaults.sellerAddress {
                    pendingNavigation = .list
                } else {
                    pendingNavigation = nil
                    titleText = "Add Address"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showPaymentShipping = true
                    }
                }
            } else {
                pendingNavigation = nil
                handleSellerVerification()
            }
        } else if tappedTab == .sellerHub {
            pendingNavigation = .account
        }
    }
    
    // Process the stored navigation after sheet dismisses
    private func processPendingNavigation() {
        guard let navigation = pendingNavigation else { return }
        
        switch navigation {
        case .getStarted:
            navigateTogetStarted = true
        case .title:
            navigateToTitle = true
        case .list:
            navigateTolist = true
        case .account:
            navigateToAccountScreen = true
        case .seller:
            navigateToSeller = true
        case .shipping:
            navigateToShipping = true
        }
        
        pendingNavigation = nil
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
            // MC cmpfokety001boohg7kgtxmwv (2026-05-22): match the narrower
            // "sell or host" copy used in AccountScreen — the old
            // "interact with live shows" wording made buyers feel they
            // needed seller verification just to join a stream.
            alertType = .sheetType(
                icon: .info,
                title: "Become a Verified Seller!",
                message: "Before you can sell or host a live show, you need to become a verified seller.",
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
    
    // Full reset: collapses the NavigationPath AND regenerates the view ID
    // (destroys + rebuilds the entire SwiftUI subtree). Use this for the
    // tab being LEFT on a tab switch, and for deep-link navigation resets
    // where a completely fresh view is required.
    func resetNavigation(for tab: Int) {
        switch tab {
        case 0:
            homeNavigationPath = NavigationPath()
            homeViewID = UUID()
        case 1:
            exploreNavigationPath = NavigationPath()
            exploreViewID = UUID()
        case 3:
            activityNavigationPath = NavigationPath()
            activityViewID = UUID()
        case 4:
            accountNavigationPath = NavigationPath()
            accountViewID = UUID()
        default:
            break
        }
    }

    // Path-only reset: collapses any pushed NavigationPath stack without
    // changing the view ID. Does NOT destroy the SwiftUI subtree — the
    // existing rendered content stays live, so no flash or API-reload.
    // Use this for the tab being ARRIVED ON during a tab switch.
    func resetNavigationPath(for tab: Int) {
        switch tab {
        case 0:
            homeNavigationPath = NavigationPath()
        case 1:
            exploreNavigationPath = NavigationPath()
        case 3:
            activityNavigationPath = NavigationPath()
        case 4:
            accountNavigationPath = NavigationPath()
        default:
            break
        }
    }
    
    func tabIcon(for tab: Int) -> String {
        switch tab {
        case 0:
            return tabBarRouter.selectedTab == 0 ? "homeBold" : "home"
        case 1:
            return tabBarRouter.selectedTab == 1 ? "searchBold" : "search"
        case 2:
            return tabBarRouter.selectedTab == 2 ? "sellerBold" : "seller"
        case 3:
            return tabBarRouter.selectedTab == 3 ? "activityBold" : "activity"
        case 4:
            return tabBarRouter.selectedTab == 4 ? "profileBold" : "profile"
        default: return "circle"
        }
    }
}
        
