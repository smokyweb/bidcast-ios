//
//  TabbarScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//@ObservedObject var languageManager = LanguageManager.shared

import SwiftUI

struct TabbarScreen: View {
    @State private var selectedTab = 0
    @State private var showSellSheet = false
    @State private var selectedSellTab: SellTabOption? = nil
    @State private var navigateTogetStarted = false
    @State private var navigateTolist = false
    @State private var navigateToseller = false
    @State private var isGift = false
    @State private var promoCode = ""
    @ObservedObject var languageManager = LanguageManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showOptions = true
    @State private var verifiedOnly = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationContainer { HomeViewScreen() }
                    .tabItem { Label("Home", systemImage: "house") }
                
                NavigationContainer { ExploreViewScreen() }
                    .tabItem { Label("Explore", systemImage: "safari.fill") }
                
                Color.clear
                    .tabItem {
                        Label("Sell",
                              systemImage: "plus.circle.fill")
                    }
                    .tag(2)
                
                
                NavigationContainer { ActivityScreen() }
                    .tabItem { Label("Activity", systemImage: "suit.heart.fill") }
                
                NavigationContainer { AccountScreen() }
                    .tabItem { Label("Account", systemImage: "person.fill") }
            }
            .onChange(of: selectedTab) { newTab in
                if newTab == 2 {
                    showSellSheet = true
                    selectedTab = 0
                }
            }
            
            CusNavLink(doNavigate: $navigateTogetStarted, destination: GetStartedScreen())
            //CusNavLink(doNavigate: $navigateToLesson, destination: SelectShowScreen())
            CusNavLink(doNavigate: $navigateTolist, destination: ListProductScreen())
            
        }
        //
        
        .bottomSheet(
            isPresented: $showSellSheet,
            height: screenHeight / 2.6,
            topBarCornerRadius: 12,
            contentBackgroundColor: .clear,
            topBarBackgroundColor: .clear,
            showTopIndicator: false,
            onDismiss: {
                showSellSheet = false
                
            },
            content: {
                SellScreen { tappedTab in
                    if tappedTab == .lesson {
                        navigateTogetStarted = true
                    } else if tappedTab == .listProduct {
                        navigateTolist = true
                    }
                } onTapCancel: {
                    showSellSheet = false
                    
                }
                .presentationDetents([.fraction(0.35)])
            })
        
            
        
    }
}

        
        
        
//        .bottomSheet(
//            isPresented: $showSellSheet,
//            height: screenHeight / 2.6,
//            topBarCornerRadius: 12,
//            contentBackgroundColor: .clear,
//            topBarBackgroundColor: .clear,
//            showTopIndicator: false,
//            onDismiss: {
//                showSellSheet = false
//                
//            },
//            content: {
//                SellScreen { tappedTab in
//                    if tappedTab == .lesson {
//                        navigateToLesson = true
//                    } else if tappedTab == .listProduct {
//                        navigateTolist = true
//                    }
//                } onTapCancel: {
//                    showSellSheet = false
//                    
//                }
//                .presentationDetents([.fraction(0.35)])
//            }
//        )
//    }
//}



//
//    }
//}


//MARK: For MoreOptionsScreen Sheet
//    .bottomSheet(
//        isPresented: $showSellSheet,
//        height: screenHeight * 0.75, // Adjust as needed
//        topBarCornerRadius: 20,
//        contentBackgroundColor: Color(.systemBackground),
//        topBarBackgroundColor: Color(.systemBackground),
//        showTopIndicator: false,
//        onDismiss: {
//            showSellSheet = false
//        },
//        content: {
//            MoreOptionsScreen(
//                isPresented: $showSellSheet,
//                isVerifiedBuyersOn: $verifiedOnly,
//                onEndShow: { print("End Show") },
//                onCloneItems: { print("Clone Items") },
//                onTipSettings: { print("Tip Settings") },
//                onMulticast: { print("Multicast") },
//                onAddCoupons: { print("Add Coupons") },
//                onRaid: { print("Raid") },
//                onCreatePoll: { print("Create Poll") },
//                onRotateCamera: { print("Rotate Camera") },
//                onZoomIn: { print("Zoom In") },
//                onMicToggle: { print("Mic Toggled") }
//            )
//        }
//    )

//MARK: For PromoteShowSheet Sheet
//    .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.75) {
//        PromoteShowSheet(boosts: exampleBoosts) {
//            showSellSheet = false
//        }
//    }
//    var exampleBoosts: [ShowBoost] {
//           [
//               ShowBoost(
//                   title: "15 Minute Boost",
//                   subtitle: "Quick visibility boost",
//                   description: "Get featured in the top shows for 15 minutes",
//                   price: "$3.99",
//                   iconName: "bolt.fill",
//                   gradient: LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
//                   action: { print("Selected 15 Minute Boost") }
//               ),
//               ShowBoost(
//                   title: "Full Show Promote",
//                   subtitle: "Extended visibility",
//                   description: "Stay featured for your entire show duration",
//                   price: "$7.99",
//                   iconName: "star.fill",
//                   gradient: LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
//                   action: { print("Selected Full Show Promote") }
//               ),
//               ShowBoost(
//                   title: "Community Boost",
//                   subtitle: "Power of the crowd",
//                   description: "Rally your community for massive exposure",
//                   price: "$12.99",
//                   iconName: "person.3.fill",
//                   gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
//                   action: { print("Selected Community Boost") }
//               )
//           ]
//       }

//MARK: For ShowSummarySheet Sheet
//    .bottomSheet(
//        isPresented: $showSellSheet,
//        height: screenHeight * 0.50,
//        topBarCornerRadius: 20,
//        contentBackgroundColor: Color(.systemBackground),
//        topBarBackgroundColor: Color(.systemBackground),
//        showTopIndicator: false,
//        onDismiss: {
//            showSellSheet = false
//        },
//        content: {
//            ShowSummarySheet(
//                avatarImage: Image("defaultUser"),
//                showTitle: "Live Sales",
//                showDuration: "00:45:22",
//                estimatedSales: "$4,521",
//                salesGrowth: "+12.5%",
//                totalOrders: "127",
//                orderGrowth: "+8.3%",
//                onShare: { print("Share tapped") },
//                onAnalytics: { print("Analytics tapped") },
//                onSettings: { print("Settings tapped") },
//                onEndShow: { print("End Show tapped") },
//                isPresented: $showSellSheet
//            )
//        }
//    )

//MARK: For ShopBottomSheetView Sheet
//    .bottomSheet(
//        isPresented: $showSellSheet,
//        height: screenHeight * 0.85,
//        topBarCornerRadius: 20,
//        contentBackgroundColor: Color(.systemBackground),
//        topBarBackgroundColor: Color(.systemBackground),
//        showTopIndicator: false,
//        onDismiss: { showSellSheet = false },
//        content: {
//            ShopBottomSheetView(
//                isPresented: $showSellSheet,
//                products: [
//                    Product(imageName: "IMG_1340", title: "iPhone 15 Pro", subtitle: "Starting bid: $999", detail: "05:23:45 left", statusColor: .red),
//                    Product(imageName: "IMG_1340", title: "AirPods Max", subtitle: "Buy Now: $549", detail: "0 Bids", statusColor: .green)
//                ]
//            )
//        }
//    )

//MARK: For EndShowBottomSheetView Sheet
//    .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.35) {
//        EndShowBottomSheetView(
//            isPresented: $showSellSheet,
//            onCreateRaid: {
//                print("Raid Created")
//            },
//            onEndShow: {
//                print("Show Ended")
//            }
//        )
//    }

//MARK: For ShareShowBottomSheetView Sheet
//    .bottomSheet(isPresented: $showSellSheet,height: screenHeight * 0.80) {
//        ShareShowBottomSheetView(
//            isPresented: $showSellSheet,
//            showTitle: "John's Live Show",
//            username: "johnsmith",
//            showImage: Image("icWatch"),
//            message: "Live auction starting in 5 minutes! Don’t miss out on exclusive items.",
//            onShare: { platform in
//                print("Shared to \(platform)")
//            },
//            onSavePDF: {
//                print("PDF Saved")
//            },
//            onShareEmail: {
//                print("Email sent")
//            }
//        )
//        .presentationDetents([.height(500)])
//        .presentationDragIndicator(.visible)
//    }

//MARK: For NotifyMeBottomSheet Sheet
//    .bottomSheet(isPresented: $showSellSheet,height: screenHeight * 0.45) {
//        NotifyMeBottomSheet(
//            isPresented: $showSellSheet,
//            profileImage: Image("defaultUser"),
//            username: "username",
//            onNotify: {
//                print("User wants notifications")
//            },
//            onDismiss: {
//                print("User dismissed")
//            }
//        )
//    }

//MARK: For BuyNowBottomSheetView Sheet
//    .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.98) {
//        BuyNowBottomSheetView(
//            isPresented: $showSellSheet,
//            productImage: Image(systemName: "headphones"),
//            productTitle: "Premium Wireless Headphones",
//            productColor: "White",
//            cardLastDigits: "4242",
//            shippingAddress: "123 Main St, Apt 4B New York, NY 10001",
//            subtotal: 299.99,
//            shipping: 9.99,
//            tax: 24.00,
//            onConfirmPurchase: {
//                print("Purchase confirmed!")
//                showSellSheet = false
//            }
//        )
//        .presentationDetents([.medium, .large])
//    }

//MARK: For MakeOfferBottomSheet Sheet
//    .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.85) {
//           MakeOfferBottomSheet(
//               isPresented: $showSellSheet,
//               listedPrice: 1299,
//               offerOptions: [1039, 1104, 1169, 1234]
//           ) { selectedOffer in
//               print("User selected offer: \(selectedOffer ?? 0)")
//           }
//       }


//MARK: For ProductDetailSheet Sheet
//    .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.95) {
//        ProductDetailSheet(
//            productImage: Image("icWatch"),
//            productTitle: "Canon DSLR",
//            productPrice: 1299,
//            condition: "Like New",
//            location: "New York, NY",
//            postedTime: "2 days ago",
//            sellerName: "Sarah Williams",
//            sellerStatus: "Verified Seller"
//        )
//    }

//MARK: For CreateClipBottomSheetView Sheet
//    .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.65) {
//        CreateClipBottomSheetView(
//            isPresented: $showSellSheet,
//            videoURL: URL(string: "https://example.com/video.mp4")!,
//            onCreateClip: { start, end in
//                print("Clip range: \(start.seconds) to \(end.seconds)")
//            }
//        )
//    }




//GetStartedScreen()
