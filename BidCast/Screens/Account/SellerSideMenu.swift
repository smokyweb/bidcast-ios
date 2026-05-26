//
//  SellerSideMenu.swift
//  BidCast
//
//  Created by JamTech on 19/12/25.
//
//
//  SellerSideMenu.swift
//  BidCast
//
//  Created by JamTech on 19/12/25.
//
import SwiftUI

// MARK: - Seller Menu Screen (Fixed Scrolling & Touch)
struct SellerMenuScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Navigation states
    @State private var navigateToRandomizerTemplates = false
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
    
    private let twoColumnGrid = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            menuHeader

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    manageSection
                    salesSection
                    promotionsSection
                    performanceSection
                    settingsSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .frame(maxHeight: .infinity)
            .ignoresSafeArea(.container, edges: .bottom)
            .padding(.bottom, 12)

            navigationLinks
        }
        .background(Color.bg)
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
            LazyVGrid(columns: twoColumnGrid, spacing: 12) {
                MenuSubsectionCard(
                    icon: .asset(.inventory),
                    title: "Inventory"
                ) {
                    navigateToInventory = true
                }

                MenuSubsectionCard(
                    icon: .asset(.mic),
                    title: "Shows"
                ) {
                    navigateToShows = true
                }

                MenuSubsectionCard(
                    icon: .system("dice"),
                    title: "Randomizer"
                ) {
                    navigateToRandomizerTemplates = true
                }
            }
        }
    }

    
    // MARK: - Sales Section
    private var salesSection: some View {
        MenuSection(title: "Sales") {
            LazyVGrid(columns: twoColumnGrid, spacing: 12) {

                MenuSubsectionCard(
                    icon: .asset(.wallet),
                    title: "Payouts"
                ) {
                    navigateToPayouts = true
                }

                MenuSubsectionCard(
                    icon: .asset(.shipping),
                    title: "Fulfillment"
                ) {
                    navigateToFulfillment = true
                }

                MenuSubsectionCard(
                    icon: .asset(.orders),
                    title: "Orders"
                ) {
                    navigateToOrders = true
                }

                MenuSubsectionCard(
                    icon: .asset(.tag),
                    title: "Tips"
                ) {
                    navigateToTips = true
                }
            }
        }
    }

    
    // MARK: - Promotions Section
    private var promotionsSection: some View {
        MenuSection(title: "Promotions") {
            LazyVGrid(columns: twoColumnGrid, spacing: 12) {

                MenuSubsectionCard(
                    icon: .asset(.people),
                    title: "Invite Seller\n& Earn $100"
                ) {
                    navigateToSellerReferrals = true
                }

                MenuSubsectionCard(
                    icon: .asset(.people),
                    title: "Refer Buyers\nGain Followers"
                ) {
                    navigateToBuyerReferrals = true
                }

                MenuSubsectionCard(
                    icon: .asset(.promoteTool),
                    title: "Promote Tools"
                ) {
                    navigateToPromote = true
                }
            }
        }
    }

    
    // MARK: - Performance Section
    private var performanceSection: some View {
        MenuSection(title: "Performance") {
            LazyVGrid(columns: twoColumnGrid, spacing: 12) {

                MenuSubsectionCard(
                    icon: .asset(.shop),
                    title: "Premier Shop"
                ) {
                    navigateToPremier = true
                }

                MenuSubsectionCard(
                    icon: .asset(.analysis),
                    title: "Seller Analytics"
                ) {
                    navigateToAnalytics = true
                }

                MenuSubsectionCard(
                    icon: .asset(.analysis),
                    title: "Account Health"
                ) {
                    navigateToAccountHealth = true
                }
            }
        }
    }

    
    // MARK: - Settings Section
    private var settingsSection: some View {
        MenuSection(title: "Settings") {
            LazyVGrid(columns: twoColumnGrid, spacing: 12) {

                MenuSubsectionCard(
                    icon: .asset(.shipping),
                    title: "Shipping Settings"
                ) {
                    navigateToShipping = true
                }

                MenuSubsectionCard(
                    icon: .asset(.seller),
                    title: "Seller Status"
                ) {
                    navigateToSellerStatus = true
                }

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

    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            CusNavLink(doNavigate: $navigateToRandomizerTemplates, destination: RandomizerTemplatesView())
            CusNavLink(doNavigate: $navigateToInventory, destination: InventoryScreen())
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

// MARK: - Menu Subsection Card (Fixed Touch Handling)
struct MenuSubsectionCard: View {
    let icon: MenuIcon
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 8) {

                iconView
                    .frame(width: 26, height: 26)

                Text(title)
                    .font(.custom(poppinsMedium, size: 12))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isPressed ? Color.defaultTheme : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .pressAnimation($isPressed)
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
                .foregroundColor(.black)

        case .asset(let image):
            Image(image)
                .resizable()
                .scaledToFit()
                .foregroundColor(.black)
        }
    }
}

extension View {
    func pressAnimation(_ isPressed: Binding<Bool>) -> some View {
        self
            .scaleEffect(isPressed.wrappedValue ? 0.97 : 1)
            .onLongPressGesture(
                minimumDuration: .infinity,
                pressing: { pressing in
                    withAnimation(.easeInOut(duration: 0.12)) {
                        isPressed.wrappedValue = pressing
                    }
                },
                perform: {}
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

enum MenuIcon {
    case system(String)
    case asset(ImageResource)
}
