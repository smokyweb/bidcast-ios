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

    var body: some View {
        // Wrap everything in NavigationStack
        NavigationStack {
            TabView(selection: $tabBarRouter.selectedTab) {
                
                NavigationContainer(navigationPath: $homeNavigationPath) {
                    HomeViewScreen(deepLinkShowId:selectedShowId,showCategory: .constant(""), showSubCategory: .constant(""), comeFromExploreScreen: .constant(false), isNavFrom: "Login")
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
                    resetNavigation(for: newTab)
                    previousTab = newTab
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
        
