//
//  SellerSideMenu.swift
//  BidCast
//
//  Created by JamTech on 19/12/25.
//
import SwiftUI

// MARK: - Seller Menu Screen (Normal Navigation)
struct SellerMenuScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Navigation states
    @State private var navigateToInventory = false
    @State private var navigateToShows = false
    @State private var navigateToPayouts = false
    @State private var navigateToFulfillment = false
    @State private var navigateToOrders = false
    @State private var navigateToTips = false
    @State private var navigateToSellerReferrals = false
    @State private var navigateToBuyerReferrals = false
    @State private var navigateToPromote = false
    @State private var navigateToPremier = false
    @State private var navigateToAnalytics = false
    @State private var navigateToAccountHealth = false
    @State private var navigateToShipping = false
    @State private var navigateToSellerStatus = false
    
    @State private var isRehearsalMode = false
    @State private var isVacationMode = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            menuHeader
            
            // Menu Sections
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    manageSection
                    salesSection
                    promotionsSection
                    performanceSection
                    settingsSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
                .padding(.bottom, 40)
            }
            
            // Navigation Links (Hidden)
            navigationLinks
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    private var menuHeader: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Seller Menu")
                    .font(.custom(poppinsBold, size: 20))
                    .foregroundColor(.primary)
                
                Text(UserDefaults.fullName.capitalizingFirstLetter())
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Manage Section
    private var manageSection: some View {
        MenuSection(title: "Manage") {
            HStack(spacing: 12) {
                MenuSubsectionCard(
                    icon: "cube.box",
                    title: "Inventory"
                ) {
                    navigateToInventory = true
                }
                
                MenuSubsectionCard(
                    icon: "tv",
                    title: "Shows"
                ) {
                    navigateToShows = true
                }
            }
        }
    }
    
    // MARK: - Sales Section
    private var salesSection: some View {
        MenuSection(title: "Sales") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MenuSubsectionCard(
                        icon: "dollarsign.circle",
                        title: "Payouts"
                    ) {
                        navigateToPayouts = true
                    }
                    
                    MenuSubsectionCard(
                        icon: "shippingbox",
                        title: "Fulfillment"
                    ) {
                        navigateToFulfillment = true
                    }
                }
                
                HStack(spacing: 12) {
                    MenuSubsectionCard(
                        icon: "cart",
                        title: "Orders"
                    ) {
                        navigateToOrders = true
                    }
                    
                    MenuSubsectionCard(
                        icon: "star.circle",
                        title: "Tips"
                    ) {
                        navigateToTips = true
                    }
                }
            }
        }
    }
    
    // MARK: - Promotions Section
    private var promotionsSection: some View {
        MenuSection(title: "Promotions") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MenuSubsectionCard(
                        icon: "person.badge.plus",
                        title: "Invite Seller\n& Earn $100"
                    ) {
                        navigateToSellerReferrals = true
                    }
                    
                    MenuSubsectionCard(
                        icon: "person.2",
                        title: "Refer Buyers\nGain Followers"
                    ) {
                        navigateToBuyerReferrals = true
                    }
                }
                
                HStack(spacing: 12) {
                    MenuSubsectionCard(
                        icon: "megaphone",
                        title: "Promote Tools"
                    ) {
                        navigateToPromote = true
                    }
                    
                    // Empty spacer for alignment
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // MARK: - Performance Section
    private var performanceSection: some View {
        MenuSection(title: "Performance") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MenuSubsectionCard(
                        icon: "crown",
                        title: "Premier Shop"
                    ) {
                        navigateToPremier = true
                    }
                    
                    MenuSubsectionCard(
                        icon: "chart.bar",
                        title: "Seller Analytics"
                    ) {
                        navigateToAnalytics = true
                    }
                }
                
                HStack(spacing: 12) {
                    MenuSubsectionCard(
                        icon: "heart.text.square",
                        title: "Account Health"
                    ) {
                        navigateToAccountHealth = true
                    }
                    
                    // Empty spacer for alignment
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // MARK: - Settings Section
    private var settingsSection: some View {
        MenuSection(title: "Settings") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    MenuSubsectionCard(
                        icon: "box.truck",
                        title: "Shipping Settings"
                    ) {
                        navigateToShipping = true
                    }
                    
                    MenuSubsectionCard(
                        icon: "person.crop.circle.badge",
                        title: "Seller Status"
                    ) {
                        navigateToSellerStatus = true
                    }
                }
                
                // Toggle Cards
                HStack(spacing: 12) {
                    ToggleSubsectionCard(
                        icon: "play.circle",
                        title: "Rehearsal Mode",
                        isOn: $isRehearsalMode
                    )
                    
                    ToggleSubsectionCard(
                        icon: "beach.umbrella",
                        title: "Vacation Mode",
                        isOn: $isVacationMode
                    )
                }
            }
        }
    }
    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            CusNavLink(doNavigate: $navigateToInventory, destination: InventoryScreen(selectedProductIDs: .constant([]), selectedProductData: .constant([])))
            CusNavLink(doNavigate: $navigateToShows, destination: ShowsScreen())
            CusNavLink(doNavigate: $navigateToPayouts, destination: WalletPayoutView())
            CusNavLink(doNavigate: $navigateToFulfillment, destination: MyOrdersScreen())
            CusNavLink(doNavigate: $navigateToOrders, destination: MyOrdersScreen())
            CusNavLink(doNavigate: $navigateToTips, destination: TipsScreen())
            CusNavLink(doNavigate: $navigateToSellerReferrals, destination: AffiliateProgramScreen(referralCode: "SELLER2025", stats: ReferralStats(totalReferrals: 0, earnings: 0.0), onShare: {}))
            CusNavLink(doNavigate: $navigateToBuyerReferrals, destination: AffiliateProgramScreen(referralCode: "BUYER2025", stats: ReferralStats(totalReferrals: 0, earnings: 0.0), onShare: {}))
            CusNavLink(doNavigate: $navigateToPromote, destination: PromoteToolsView())
            CusNavLink(doNavigate: $navigateToPremier, destination: PremierShopScreen())
            CusNavLink(doNavigate: $navigateToAnalytics, destination: AnalyticsScreen())
            CusNavLink(doNavigate: $navigateToAccountHealth, destination: SellerStatusScreen())
            CusNavLink(doNavigate: $navigateToShipping, destination: ShippingSettingsScreen())
            CusNavLink(doNavigate: $navigateToSellerStatus, destination: SellerStatusScreen())
        }
    }
}

// MARK: - Menu Section
struct MenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            content
        }
    }
}

// MARK: - Menu Subsection Card
struct MenuSubsectionCard: View {
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
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.defaultTheme)
                    .frame(height: 30)
                
                Text(title)
                    .font(.custom(poppinsMedium, size: 12))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(isPressed ? 0.1 : 0.05), radius: isPressed ? 4 : 8, x: 0, y: isPressed ? 1 : 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.defaultTheme.opacity(0.2),
                                Color.defaultTheme.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
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

// MARK: - Toggle Subsection Card
struct ToggleSubsectionCard: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(isOn ? .defaultTheme : .gray)
                .frame(height: 28)
            
            Text(title)
                .font(.custom(poppinsMedium, size: 11))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 30)
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.defaultTheme)
                .scaleEffect(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isOn ? Color.defaultTheme.opacity(0.3) : Color.gray.opacity(0.1),
                    lineWidth: isOn ? 1.5 : 1
                )
        )
    }
}

// MARK: - Usage in AccountScreen
/*
// Add this in your AccountScreen navigation links:
CusNavLink(doNavigate: $navigateToSellerMenu, destination: SellerMenuScreen())

// Trigger from a button or menu item:
Button("Open Seller Menu") {
    navigateToSellerMenu = true
}
*/

// MARK: - Preview
//struct SellerMenuScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SellerMenuScreen()
//        }
//    }
//}
