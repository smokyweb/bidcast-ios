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
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Content
                    contentView(geometry: geometry)
                    
                    // Navigation Links
                    navigationLinks
                }
                .background(.backGround)
                .toolbar(.hidden,for: .tabBar)
                .navigationBarHidden(true)
            }
        }
        
    // MARK: - Content View
    private func contentView(geometry: GeometryProxy) -> some View {
        let safeBottom = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.bottom ?? 0
        let contentHeight = max(0, geometry.size.height - safeBottom + 23)
        
        return ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                sellerSection
                promotionSection
                performanceSection
                settingsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .padding(.bottom, 60)
            
        }
        .frame(height: contentHeight, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }
    
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
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
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
            CusNavLink(doNavigate: $navigationState.navigateToSellerTraining, destination: SellingTips(isNavFrom: "SellerTools", backToTabBar: .constant(false)))
            CusNavLink(doNavigate: $navigationState.navigateToSellerVerification, destination: SellerVerificationScreen())
            CusNavLink(doNavigate: $navigationState.navigateToIdentityVerification, destination: IdentityVerificationScreen())
            CusNavLink(doNavigate: $navigationState.navigateToInventory, destination: InventoryScreen(selectedProductIDs: .constant([]), selectedProductData: .constant([])))
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
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Color.defaultTheme.opacity(0.2)
                          .frame(width: 36, height: 36)
                          .clipShape(Circle())
                        
                    Image(icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                // Title
                Text(title)
                    .font(.custom(poppinsRegular, size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(isPressed ? Color(.systemGray6).opacity(0.5) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
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

// MARK: - Identity Verification Screen Placeholder
struct IdentityVerificationScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Identity Verification")
                .font(.custom(poppinsBold, size: 24))
            
            Text("Coming Soon")
                .font(.custom(poppinsRegular, size: 16))
                .foregroundColor(.gray)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Preview
//struct SellerToolsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SellerToolsScreen()
//        }
//    }
//}
