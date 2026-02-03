//
//  SellerToolsScreen.swift
//  BidCast
//
//  Created by JamTech on 20/12/25.
//
import SwiftUI

// MARK: - Seller Tools Screen
struct SellerToolsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigationState = SellerToolsNavigationState()
    
    var body: some View {
          VStack(spacing: 0) {

              // Header
              headerView
                  .frame(height: 40)

              // Scrollable Content
              ScrollView(showsIndicators: false) {
                  VStack(spacing: 20) {
                      sellerSection
                      promotionSection
                      performanceSection
                      settingsSection
                  }
                  .padding(.horizontal, 16)
                  .padding(.vertical, 12)
                  .padding(.bottom, 24)
              }
              .background(Color(.backGround))

              // Navigation Links
              navigationLinks
          }
          .background(.backGround)
          .toolbar(.hidden, for: .tabBar)
          .navigationBarHidden(true)
//          .padding(.bottom, -70)
      }
        
    // MARK: - Content View
//    private func contentView(geometry: GeometryProxy) -> some View {
//        let safeBottom = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
//            .windows.first?.safeAreaInsets.bottom ?? 0
//        let contentHeight = max(0, geometry.size.height - safeBottom + 23)
//        
//        return ScrollView(showsIndicators: false) {
//            VStack(spacing: 20) {
//                sellerSection
//                promotionSection
//                performanceSection
//                settingsSection
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 4)
//            .padding(.bottom, 60)
//            
//        }
//        .frame(height: contentHeight, alignment: .top)
//        .background(Color(.systemGroupedBackground))
//    }
    
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header
//            headerView
//            
//            // Content
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 20) {
//                    sellerSection
//                    promotionSection
//                    performanceSection
//                    settingsSection
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 20)
//            }
//            .background(Color(.systemGroupedBackground))
//            
//            // Navigation Links
//            navigationLinks
//        }
//        .background(Color(.systemGroupedBackground))
//        .navigationBarHidden(true)
//    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Seller Tools")
                .font(.custom(poppinsBold, size: 20))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Placeholder for symmetry
            Image(systemName: "chevron.left")
                .font(.system(size: 20))
                .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.backGround)
        .shadow(color: .backGround.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Seller Section
    private var sellerSection: some View {
        SectionCard(title: "Seller") {
            VStack(spacing: 0) {
                ToolsRowItem(icon: "sellerTraining", title: "Seller Training") {
                    navigationState.navigateToSellerTraining = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "sellerVerification", title: "Seller Verification") {
                    navigationState.navigateToSellerVerification = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "identityVerification", title: "Identity Verification") {
                    navigationState.navigateToIdentityVerification = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "inventory", title: "Inventory") {
                    navigationState.navigateToInventory = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "shows", title: "Shows") {
                    navigationState.navigateToShows = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "orders", title: "Orders") {
                    navigationState.navigateToOrders = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "wallet", title: "Wallet") {
                    navigationState.navigateToWallet = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "offers", title: "Offers") {
                    navigationState.navigateToOffers = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "tips", title: "Tips") {
                    navigationState.navigateToTips = true
                }
                ToolsRowItem(icon: "tips", title: "Surprise Sets") {
                    navigationState.navigateToSurprise = true
                }
            }
        }
    }
    
    // MARK: - Promotion Section
    private var promotionSection: some View {
        SectionCard(title: "Promotion") {
            VStack(spacing: 0) {
                ToolsRowItem(icon: "affilateProgram", title: "Affiliate Program") {
                    navigationState.navigateToAffiliate = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "promoteTools", title: "Promote Tools") {
                    navigationState.navigateToPromoteTools = true
                }
            }
        }
    }
    
    // MARK: - Performance Section
    private var performanceSection: some View {
        SectionCard(title: "Performance") {
            VStack(spacing: 0) {
                ToolsRowItem(icon: "premierShop", title: "Premier Shop") {
                    navigationState.navigateToPremier = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "sellerAnalytics", title: "Seller Analytics") {
                    navigationState.navigateToAnalytics = true
                }
            }
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        SectionCard(title: "Settings") {
            VStack(spacing: 0) {
                ToolsRowItem(icon: "shipping", title: "Shipping") {
                    navigationState.navigateToShipping = true
                }
                
//                Divider().padding(.leading, 68)
                
                ToolsRowItem(icon: "sellerAnalytics", title: "Seller Status") {
                    navigationState.navigateToSellerStatus = true
                }
            }
        }
    }
    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            CusNavLink(doNavigate: $navigationState.navigateToSellerTraining, destination: SellingTips(isNavFrom: .constant("Account"), backToTabBar: .constant(false)))
            
//            CusNavLink(doNavigate: $navigationState.navigateToSellerTraining, destination: ProductWeightScreen(
//                weight: .constant(""),
//                selectedUnit: .constant(""),
//                isHazardous: .constant(false),
//                unitOptions: [""],
//                quickWeights: [""],
//                imageUrls: .constant([""]),
//                videoUrls: .constant([""]),
//                request: .constant(StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "", accept_offers: "", reserve_for_live: "", shipping_profile_id: "", status: "", width: "", length: "", weight: "", height: "", mail_class: "", processing_category: "", product_condition: "")),
//                storeScheduleRequest: .constant(StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "", is_explicit: false, show_discoverability: "", repeat_value: "", is_repeat: false, language: "")),
//                thumbNail: .constant(""),
//                backToPrepare: .constant(false),
//                fromPrepare: .constant(false),
//                backToCreateProduct: .constant(false), onContinue: {}))
//
            CusNavLink(doNavigate: $navigationState.navigateToSurprise, destination: SurpriseSetScreen())
            
            CusNavLink(doNavigate: $navigationState.navigateToSellerVerification, destination: SellerVerificationScreen())
            CusNavLink(doNavigate: $navigationState.navigateToIdentityVerification, destination: IdentityVerificationScreen())
            CusNavLink(doNavigate: $navigationState.navigateToInventory, destination: InventoryScreen())
            CusNavLink(doNavigate: $navigationState.navigateToShows, destination: ShowsScreen())
            
            CusNavLink(doNavigate: $navigationState.navigateToOrders, destination: MyOrdersScreen())
            
            CusNavLink(doNavigate: $navigationState.navigateToWallet, destination: WalletPayoutView())
            CusNavLink(doNavigate: $navigationState.navigateToOffers, destination: OffersScreen())
            CusNavLink(doNavigate: $navigationState.navigateToTips, destination: TipsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToAffiliate, destination: AffiliateProgramScreen(referralCode: "SELLER2025", stats: ReferralStats(totalReferrals: 0, earnings: 0.0), onShare: {}))
            CusNavLink(doNavigate: $navigationState.navigateToPromoteTools, destination: PromoteToolsView())
            CusNavLink(doNavigate: $navigationState.navigateToPremier, destination: PremierShopScreen())
            CusNavLink(doNavigate: $navigationState.navigateToAnalytics, destination: AnalyticsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToShipping, destination: ShippingSettingsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToSellerStatus, destination: SellerStatusScreen())
        }
        .frame(width: 0, height: 0)
        .hidden()
    }
}

// MARK: - Section Card
struct SectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
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
}
//
// MARK: - Tools Row Item
struct ToolsRowItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Color.defaultThemeLight
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())

                    Image(icon)
                        .foregroundColor(.defaultTheme)
                }

                Text(title)
                    .font(.custom(poppinsRegular, size: 16))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Navigation State
struct SellerToolsNavigationState {
    // Seller Section
    var navigateToSellerTraining = false
    var navigateToSellerVerification = false
    var navigateToIdentityVerification = false
    var navigateToInventory = false
    var navigateToShows = false
    var navigateToOrders = false
    var navigateToWallet = false
    var navigateToOffers = false
    var navigateToTips = false
    var navigateToSurprise = false
    
    // Promotion Section
    var navigateToAffiliate = false
    var navigateToPromoteTools = false
    
    // Performance Section
    var navigateToPremier = false
    var navigateToAnalytics = false
    
    // Settings Section
    var navigateToShipping = false
    var navigateToSellerStatus = false
}

