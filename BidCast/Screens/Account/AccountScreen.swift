//
//  AccountScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD
import SwiftUI

// MARK: - Seller Hub Section
struct SellerHubSection: View {
    @State private var isLoadingStats = true
    @Binding var sellerInfo: SellerhubInfoModel?
    
    // Stats data
    @State private var itemsCount = 0
    @State private var revenue = "$0.00"
    @State private var rating = 0.0
    @State private var onTimeRate = "100"
    @State private var defectFreeRate = "100"
    @State private var policyStanding = "Excellent"
    @State private var payouts = "$199.00"
    @State private var totalOrders = "22 Items"
    
    @State var showID = ""
    @State var isLive = false
    @State private var selectedProductData: [ProductDataModel] = []
    @State var selectedShowsData = HomeModel()
    @State var navigateToReherseal = false
    
    var onCreateShow: () -> Void
    var onCreateProduct: () -> Void
    var onViewAllShows: () -> Void
    
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
            CusNavLink(doNavigate: $navigateToReherseal,
                       destination: RehearsalScreen(showUd: $showID,
                                                    productListData: .constant([]),
                                                    isLive: isLive,
                                                    backToTabBar: .constant(true),
                                                    showsData: $selectedShowsData))
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .onAppear {
            loadData()
        }
        
    }
    
    // MARK: - Stats Cards Row
    private var statsCardsRow: some View {
        HStack(spacing: 12) {
            StatCardView(
                value: isLoadingStats ? "" : "\(itemsCount)",
                label: "Items",
                isLoading: isLoadingStats
            )
            
            StatCardView(
                value: isLoadingStats ? "" : revenue,
                label: "Revenue",
                isLoading: isLoadingStats
            )
            
            StatCardView(
                value: isLoadingStats ? "" : String(format: "%.1f", rating),
                label: "Rating",
                isLoading: isLoadingStats
            )
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
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.defaultTheme, .defaultTheme.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: .defaultTheme.opacity(0.3), radius: 8, x: 0, y: 4)
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
                            .fill(Color.defaultTheme.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 26)
                            .stroke(Color.defaultTheme.opacity(0.3), lineWidth: 1.5)
                    )
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
                        navigateToReherseal = true
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
                PayoutCard(
                    title: "Payouts",
                    value: payouts
                )
            }
            
            // Total Orders Card
            if isLoadingStats {
                PayoutShimmerCard()
            } else {
                PayoutCard(
                    title: "Total Orders",
                    value: totalOrders
                )
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
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: .constant(false))
                .labelsHidden()
                .tint(.defaultTheme)
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
        // Simulate API call for stats
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
//                itemsCount = 284
//                revenue = "$5.2K"
//                rating = 4.8
                if let info = sellerInfo {
                    itemsCount = info.items ?? 0
                    revenue = "\(info.revenue ?? 0.0)"
                    rating = info.rating ?? 0.0
                    onTimeRate = "\(info.accountHealth?.onTimeScanRate ?? "0")%"
                    defectFreeRate = "\(info.accountHealth?.defectFreeOrderRate ?? "")%"
                    policyStanding = "Excellent"
                    payouts = "$\(info.payouts ?? 0)"
                    totalOrders = "\(info.totalOrders ?? 0) Items"
                    isLoadingStats = false
                }
            }
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
                    .font(.custom(poppinsBold, size: 24))
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

// MARK: - Show Card
//struct ShowCard: View {
//    let show: HomeModel
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            // Show Image
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.gray.opacity(0.2))
//                .frame(width: 60, height: 60)
//                .overlay(
//                    Image(systemName: "video.fill")
//                        .foregroundColor(.gray)
//                )
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(show.title ?? "")
//                    .font(.custom(poppinsSemiBold, size: 15))
//                    .foregroundColor(.primary)
//                    .lineLimit(1)
//                
//                Text(show.date ?? "")
//                    .font(.custom(poppinsRegular, size: 13))
//                    .foregroundColor(.gray)
//            }
//            
//            Spacer()
//            
//            Image(systemName: "chevron.right")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.gray)
//        }
//        .padding(12)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemGray6).opacity(0.5))
//        )
//    }
//}

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

// MARK: - Shimmer Effect
//struct ShimmerView: View {
//    @State private var phase: CGFloat = 0
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                Color.gray.opacity(0.3)
//                
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        .clear,
//                        .white.opacity(0.6),
//                        .clear
//                    ]),
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//                .frame(width: geometry.size.width * 0.4)
//                .offset(x: phase * geometry.size.width - geometry.size.width * 0.2)
//            }
//        }
//        .onAppear {
//            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
//                phase = 1
//            }
//        }
//    }
//}

// MARK: - Show Model
//struct ShowModel: Identifiable {
//    let id = UUID()
//    let title: String
//    let date: String
//}

// MARK: - Usage in Your Account Screen
// Replace the seller hub section with:
/*
if segment == .sellerHub {
    SellerHubSection(
        onCreateShow: {
            navigateToShows = true
        },
        onCreateProduct: {
            navigateToInve
 */


// struct AccountScreen: View {
// 
//     @Environment(\.presentationMode) var presentationMode
//     @EnvironmentObject var appRootManager: AppRootManager
//     @State var userLogOut: Bool = false
//     @State var isLoading: Bool = false
//     @State var showAlert: Bool = false
//     @State var showError: Bool = false
//     @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//     @EnvironmentObject var networkMonitor: NetworkMonitor
//     @State var showhud: Bool = false
//     @State var hudMsg: String = ""
//     @State var segment : AccountSegment = .sellerHub
//     @State var selectedSegmentSourceType = 0
//     @State var isTappedSwitch : Bool = false
//     @State var navigateToAboutUs : Bool = false
//     @State var navigateToFAQ : Bool = false
//     @State var navigateToContactus : Bool = false
//     @State var navigateToSales : Bool = false
//     @State var navigateToBlockedList : Bool = false
//     @State var navigateToPrivacy : Bool = false
//     @State var navigateToTerms : Bool = false
//     @State var navigateToInventry : Bool = false
//     @State var navigateToPromoteTool : Bool = false
//     @State var navigateToAddress : Bool = false
//     @State var navigateToShows : Bool = false
//     @State var navigateToWallet : Bool = false
//     @State var navigateTips : Bool = false
//     @State var navigateToOffers : Bool = false
//     @State var navigateToShipping : Bool = false
//     @State var navigateToSellerStatus : Bool = false
//     @State var navigateToMyOrder : Bool = false
//     @State var navigateToSellerTraining : Bool = false
//     @State var navigateToPreference : Bool = false
//     @State var navigateToCategory : Bool = false
//     @State var navigateToPayment : Bool = false
//     @State var navigateToTrustedBuyer : Bool = false
//     @State var navigateToPremierShop : Bool = false
//     @State var navigateToAffilateProgram : Bool = false
//     @State var navigateToAnalytics : Bool = false
//     @State var isNavFrom : Bool = false
//     @State var navigateToSellerVerification = false
//     @State var navigateToProfile : Bool = false
//     @State var comeFromSeller = false
//     
//     @State private var showSideMenu = false
//     
//     @State var showsViewModel = ShowsViewModel()
//     @State var showsData = [HomeModel]()
//     
//     @State private var navigateToTitle: Bool = false
//     @State private var navigateToCreateProduct : Bool = false
//     @State var request : StoreScheduleShowRequest = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "", isExplicitContent: false, discoverablitity: "", primaryLanguage: "", repeats: "")
//     
//     
//     @State var newTab = Int()
//     @State var viewModal = MenuOptionsViewModel()
//     @State private var headerHeight: CGFloat = 0
//     let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)
//     var body: some View {
//         GeometryReader { geo in
//             // safe area bottom (tab bar safe area)
//             let safeBottom = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
//                 .windows.first?.safeAreaInsets.bottom ?? 0
//             let tabBarHeight: CGFloat = -23
//             let contentHeight = max(0, geo.size.height - headerHeight - safeBottom - tabBarHeight)
//             VStack{
////                 VStack{
////                     PrimaryHeader(
////                         title: AppString.Account.localized,
////                         isForLogo: comeFromSeller ? false : true,
////                         leadingImgArr: comeFromSeller ? [.icBack] : [.appName],
////                         trailingImgArr: [],
////                         onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
////                         onClickTrailing: nil,
////                         count: .constant(0)
////                     )
////                     
////                     .background(
//// //                        GeometryReader { ph -> Color in
//// ////                            DispatchQueue.main.async {
//// //                                self.headerHeight = ph.size.height
//// //
//// //                            Color.clear
//// //                        }
////                     )
////                     .zIndex(1)
////                 }
//                 VStack {
//                     // Your existing content
//                     
//                     PrimaryHeader(
//                        title: AppString.Account.localized,
//                        isForLogo: comeFromSeller ? false : true,
//                        leadingImgArr: [.icBack],
//                        trailingImgArr: [.icMenu], onClickLeading: { _ in presentationMode.wrappedValue.dismiss() }, // Add menu icon
//                         onClickTrailing: { _ in
//                             showSideMenu = true
//                         }, count: .constant(0)
//                     )
//                 }
// 
//                 ScrollView(showsIndicators: false){
//                     VStack(alignment: .leading,spacing: 4){
//                         ListCell(image: UserDefaults.profileURL.isEmpty ? "user_dummy" : UserDefaults.profileURL,
//                                  title: UserDefaults.fullName.capitalizingFirstLetter() ,
//                                  vectorImg : .circleEditPencil,angle:0.0,
//                                  subLabel : UserDefaults.userName.capitalizingFirstLetter(),
//                                  titleFontName: poppinsSemiBold,
//                                  titleFontSize: 16.0,
//                                  subLabelFontName: poppinsRegular,
//                                  subLabelFontSize: 12.0,
//                                  isVectorImgHidden: false,
//                                  onTapMenuCell: {
// 
//                             self.navigateToProfile = true
// 
//                         })
//                         .padding(.all,1)
//                         .frame(height: 80)
// 
//                         CustomSegmentedControl(preselectedIndex: $segment ,
//                                                options: AccountSegment.allCases)
// 
// 
// 
//                         if segment == .sellerHub {
//                             SellerHubSection(showsData: $showsData){
//                                     navigateToTitle = true
//                                 }
//                                 onCreateProduct: {
//                                     navigateToCreateProduct = true
//                                 }
//                                 onViewAllShows: {
//                                     navigateToShows = true
//                                 }
//                             
//                         }
////                         if segment == .sellerHub{
////                             //Seller hub
////                             TwoVerticalLabelCell(dataModel: Credit.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description.localized})
//// 
////                             LazyVGrid(columns: columns, spacing: 6) { // ✅ uniform vertical spacing
////                                 ForEach(0 ..< TabSection.allCases.count, id: \.self) { index in
////                                     VerticalLabelImageCell(
////                                         topLabel: TabSection.allCases[index].img,
////                                         bottomLabel: TabSection.allCases[index].description.localized
////                                     ) {
////                                         withAnimation {
////                                             switch index {
////                                             case 0: navigateToInventry = true
////                                             case 1: navigateToShows = true
////                                             case 2: navigateToMyOrder = true
////                                             case 3: navigateToWallet = true
////                                             case 4: navigateToOffers = true
////                                             case 5: navigateTips = true
////                                             case 6: navigateToShipping = true
////                                             case 7: navigateToAffilateProgram = true
////                                             case 8: navigateToSellerTraining = true
////                                             case 9: navigateToPremierShop = true
////                                             case 10: navigateToSellerStatus = true
////                                             case 11: navigateToAnalytics = true
////                                             case 12: navigateToPromoteTool = true
////                                             case 13: navigateToSellerVerification = true
////                                             default: break
////                                             }
////                                         }
////                                     }
////                                     .aspectRatio(1, contentMode: .fill)
////                                 }
////                             }
////                             .padding(.horizontal, 4)
////                             .padding(.vertical, 6)
//// 
////                             MenuCell(title: "Vacation Mode", textColor: .black, fontValue: 14.0, menuImg:"vacation", vectorImg: .vacation,isSelectable: true,isTappedSwitch: $isTappedSwitch,
////                                      onToggle: { newValue in
////                                 print("Vacation Mode state is now \(newValue ? "ON" : "OFF")")
////                             })
////                             .padding(.bottom,10)
//// 
////                         }
//                         else{
//                             TwoVerticalLabelCell(dataModel: AccountCredit.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description},columnsPerRow: 2)
// 
//                             LazyVGrid(columns: columns, spacing: 6) {
//                                 ForEach(0 ..< AccountTabSection.allCases.count, id: \.self) { index in
//                                     VerticalLabelImageCell(
//                                         topLabel: AccountTabSection.allCases[index].img,
//                                         bottomLabel: AccountTabSection.allCases[index].description
//                                     ) {
//                                         withAnimation {
//                                             switch index {
//                                             case 0: navigateToPayment = true
//                                             case 1: navigateToAddress = true
//                                             case 2: navigateToTrustedBuyer = true
//                                             case 4: navigateToPreference = true
//                                             case 5: navigateToCategory = true
//                                             default: break
//                                             }
//                                         }
//                                     }
//                                     .aspectRatio(1, contentMode: .fill)
//                                 }
//                             }
//                             .padding(.horizontal, 4)
//                             .padding(.vertical, 6)
// 
//                             ForEach(0 ..< AccountMenuSection.allCases.count,id :\.self) { index in
// 
//                                 MenuCell(title: AccountMenuSection.allCases[index].description, textColor: .black, fontValue: 14.0, menuImg:"vacation", vectorImg: .icArrowUp ,isSelectable: false,isTappedSwitch: $isTappedSwitch,
//                                          onToggle: { newValue in
// 
//                                     print("Vacation Mode state is now \(newValue ? "ON" : "OFF")")
// 
//                                 },onTapMenuCell: {
//                                     if index == 0 {
//                                         withAnimation {
//                                             //                                        navigateToAboutUs = true
//                                             if let url = URL(string: "https://backend.bidcast.betaplanets.com/about-us") {
//                                                 UIApplication.shared.open(url)
//                                             }
//                                         }
//                                     }else
//                                     if index == 1{
//                                         withAnimation {
//                                             navigateToContactus = true
//                                         }
//                                     }else
//                                     if index == 2{
//                                         withAnimation {
//                                             navigateToSales = true
//                                         }
//                                     }else
//                                     if index == 3{
//                                         withAnimation {
//                                             //                                        navigateToTerms = true
//                                             if let url = URL(string: "https://backend.bidcast.betaplanets.com/terms-condition") {
//                                                 UIApplication.shared.open(url)
//                                             }
//                                         }
//                                     }else
//                                     if index == 4{
//                                         withAnimation {
//                                             //                                        navigateToPrivacy = true
//                                             if let url = URL(string: "https://backend.bidcast.betaplanets.com/privacy-policy") {
//                                                 UIApplication.shared.open(url)
//                                             }
//                                         }
//                                     }
//                                     else if index == 5 {
//                                         withAnimation {
//                                             //                                        navigateToFAQ = true
//                                             if let url = URL(string: "https://backend.bidcast.betaplanets.com/faq") {
//                                                 UIApplication.shared.open(url)
//                                             }
//                                         }
//                                     }
//                                     else if index == 6 {
//                                         navigateToBlockedList = true
//                                     }
//                                     else if index == 7 {
//                                         withAnimation {
//                                             userLogOut = true
//                                         }
//                                     }
//                                     print(AccountMenuSection.allCases[index].description)
//                                 })
// 
//                                 .frame(height:70)
//                             }
//                         }
// 
//                     }
//                     .frame(maxWidth: .infinity)
//                 }
//                 //            .padding(.horizontal,8)
//                 //            .background(.clear)
//                 //            .edgesIgnoringSafeArea(.bottom)
//                 ////            .frame(maxHeight: .infinity)
//                 //            .padding(.bottom,isNavFrom ? -300 : UIDevice.current.hasNotch ? -260 : -110)
//                 .frame(height: contentHeight, alignment: .top)
//                 .padding(.horizontal, 8)
//                 .padding(.bottom, safeBottom)
// 
//                 CusNavLink(doNavigate: $navigateToProfile, destination: CompleteProfileScreen())
//                 //MARK: My Account navigation
//                 CusNavLink(doNavigate: $navigateToAboutUs, destination: AboutUsScreen())
//                 CusNavLink(doNavigate: $navigateToPremierShop, destination: PremierShopScreen())
//                 CusNavLink(doNavigate: $navigateToSales, destination: SalesTaxScreen())
//                 CusNavLink(doNavigate: $navigateToFAQ, destination: FAQScreen())
//                 CusNavLink(doNavigate: $navigateToTerms, destination: TermsOfServicesScreen())
//                 CusNavLink(doNavigate: $navigateToPrivacy, destination: PrivacyPolicyScreen())
//                 CusNavLink(doNavigate: $navigateToContactus, destination: ContactUs())
//                 CusNavLink(doNavigate: $navigateToAddress, destination: AddressesScreen())
//                 CusNavLink(doNavigate: $navigateToShipping, destination: ShippingSettingsScreen())
//                 CusNavLink(doNavigate: $navigateToPreference, destination: PreferncesScreen())
//                 CusNavLink(doNavigate: $navigateToCategory, destination: MultiSelectionCategoryScreen(isNavFrom : "Account"))
//                 CusNavLink(doNavigate: $navigateToPayment, destination: PaymentAndShipping_Screen())
//                 CusNavLink(doNavigate: $navigateToTrustedBuyer, destination: TrustedBuyerScreen(comeFromHome: .constant(false)))
//                 CusNavLink(doNavigate: $navigateToSellerVerification, destination: SellerVerificationScreen())
//                 
//                 CusNavLink(doNavigate: $showSideMenu, destination: SellerMenuScreen())
//                 CusNavLink(doNavigate: $navigateToCreateProduct, destination: ListProductScreen())
//                 CusNavLink(doNavigate: $navigateToTitle,
//                            destination: ShowTitleTips(request:$request,
//                                                       fromPrepare:.constant(false),
//                                                       backToPrepare: $navigateToTitle
//                                                      ))
//                 //MARK: Seller hub navigation
//                 CusNavLink(doNavigate: $navigateToShows, destination: ShowsScreen())
//                 CusNavLink(doNavigate: $navigateToInventry, destination: InventoryScreen(selectedProductIDs: .constant([]), selectedProductData: .constant([])))
//                 CusNavLink(doNavigate: $navigateToOffers, destination: OffersScreen())
//                 CusNavLink(doNavigate: $navigateToSellerTraining, destination: SellingTips(isNavFrom : "Account", backToTabBar: .constant(true)))
//                 CusNavLink(doNavigate: $navigateToPromoteTool, destination: PromoteToolsView())
//                 CusNavLink(doNavigate: $navigateTips, destination: TipsScreen())
//                 CusNavLink(doNavigate: $navigateToWallet, destination: WalletPayoutView())
//                 CusNavLink(doNavigate: $navigateToSellerStatus, destination:   SellerStatusScreen())
//                 CusNavLink(doNavigate: $navigateToMyOrder, destination: MyOrdersScreen())
//                 CusNavLink(doNavigate: $navigateToBlockedList, destination: BlockedUserScreen())
//                 CusNavLink(doNavigate: $navigateToAffilateProgram, destination: AffiliateProgramScreen(
//                     referralCode: "SELLER2025",
//                     stats: ReferralStats(totalReferrals: 0, earnings: 0.0),
//                     onShare: {
//                         print("Share link tapped")
//                     }
//                 ))
//                 CusNavLink(doNavigate: $navigateToAnalytics, destination: AnalyticsScreen())
// 
//             }
////             .sellerSideMenu(isPresented: $showSideMenu)
//             .onAppear {
//                 getUpcomingShows()
//             }
//             .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
//         }
// //        .edgesIgnoringSafeArea(.bottom)
//         .background(.bg.opacity(0.5))
// //        .toolbar(isNavFrom ? .hidden : .visible, for: .tabBar)
//         .bottomSheet(isPresented: $userLogOut, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {  }, content: {
//             LogOutSheet(onLogoutClick: {
//                 withAnimation(.snappy) { userLogOut = false }
//                 Task{
//                    guard Reachability.isConnectedToNetwork() else {
//                         hudMsg = "No Internet Connection"
//                         showhud = true
//                         return
//                     }
//                     SVProgressHUD.show()
//                     await viewModal.logOut()
//                     SVProgressHUD.show()
//                     handleSuccess()
//                 }
// 
//             }, onCancelClick: {
//                 withAnimation(.snappy) { userLogOut = false }
//             })
//         })
//     }
// 
//    private func getUpcomingShows() {
//         Task {
//             await performAPICalls(
//                isConcurrent: true,
//                onError: { error in
//                    alertType = .sheetType(
//                        icon: .alert,
//                        title: "Error",
//                        message: showsViewModel.errorMessage ?? "",
//                        primaryBtnText: "",
//                        secondaryBtnText: AppString.ok.localized
//                    )
//                    showError = true
//                }, onSuccess: {
//                    scheduleSuccess()
//                }
//                
//             ) {
//                 try await showsViewModel.getLiveSHows(param: GetLiveShowsRequest(type: "upcoming", page: "1"))
//             }
//         }
//         
//     }
//     
//     func scheduleSuccess(){
//         let response = showsViewModel.scheduledShow
//         if response?.status == "success"{
//             showsData = response?.data ?? [HomeModel]()
//         }else{
//             alertType = .sheetType(
//                 icon: .alert,
//                 title: "Error",
//                 message: showsViewModel.errorMessage ?? "",
//                 primaryBtnText: "",
//                 secondaryBtnText: AppString.ok.localized
//             )
//             showError = true
//         }
//     }
//     
//     func handleSuccess() {
//         SVProgressHUD.dismiss()
//         if viewModal.logOutResponse != nil {
//             handleUserLogout()
//         }
//     }
//     func handleUserLogout() {
//         DispatchQueue.main.async {
//             UserDefaults.accessToken.removeAll()
//             UserDefaults.sellerVerafied.removeAll()
//             UserDefaults.buyerVerafied.removeAll()
//             let rememberMe = UserDefaults.rememberMe
//             if !rememberMe {
//                 let _ = KeychainManager.shared.delete(email: UserDefaults.userEmail)
//                 UserDefaults.userEmail = ""
//                 UserDefaults.rememberMe = false
//             }
//             UserDefaults.userId = -1
//             DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                 withAnimation {
//                     appRootManager.currentRoot = .authentication
//                 }
//             }
//         }
//     }
// }
 
 //#Preview {
 //    AccountScreen()
 //}
 
// 
// enum AccountSegment : String, CaseIterable, CustomStringConvertible{
//     case sellerHub = "Seller Hub"
//     case Account = "My Account"
// 
//     var description: String {
//         return NSLocalizedString(rawValue, comment: "").localized
//     }
// }
// 
// 
// 
// enum Credit : String, CaseIterable, CustomStringConvertible{
// 
//     case items = "Items"
//     case Revenue = "Revenue"
//     case sorting = "Sorting"
// 
//     var description: String {
//             return NSLocalizedString(rawValue, comment: "")
//         }
// 
//     var labelOlt : String{
//         switch self {
// 
//         case .items:
//             return "284"
//         case .Revenue:
//             return "$5.2K"
//         case .sorting:
//             return "4.8"
//         }
//     }
// }
// 
// enum TabSection : String, CaseIterable, CustomStringConvertible{
// 
//     case Inventory = "Inventory"
//     case Shows = "Shows"
//     case orders = "My Orders"
//     case wallet = "Wallet"
//     case offer = "Offers"
//     case tips = "Tips"
//     case shipping = "Shipping"
//     case affilaite = "Affiliate Program"
//     case training = "Seller Training"
//     case premier = "Premier Shop"
//     case sellerStatus = "Seller Status"
//     case sellerAna = "Seller Analytics"
//     case promoteTool = "Promote Tools"
//     case sellerVerificatiob = "Seller Verification"
// 
//     var description: String {
//             return NSLocalizedString(rawValue, comment: "")
//         }
// 
//     var img : ImageResource{
//         switch self {
// 
// 
//         case .Inventory:
//             return .inventory
//         case .Shows:
//             return .mic
//         case .orders:
//             return .orders
//         case .wallet:
//             return .wallet
//         case .offer:
//             return .tag
//         case .tips:
//             return .tag
//         case .shipping:
//             return .shipping
//         case .affilaite:
//             return .people
//         case .training:
//             return .gradCap
//         case .premier:
//             return .shop
//         case .sellerStatus:
//             return .analysis
//         case .sellerAna:
//             return .analysis
//         case .promoteTool:
//             return .promoteTool
//         case .sellerVerificatiob:
//             return .seller
//         }
//     }
// }
// 
// enum AccountCredit : String, CaseIterable, CustomStringConvertible{
// 
//     case credit = "Credits"
//     case coupon = "Coupons"
// 
// 
//     var description: String {
//             return NSLocalizedString(rawValue, comment: "")
//         }
// 
//     var labelOlt : String{
//         switch self {
// 
//         case .credit:
//             return "284"
//         case .coupon:
//             return "$5.2K"
//         }
//     }
// }
// 
// enum AccountTabSection : String, CaseIterable, CustomStringConvertible{
// 
//     case paymentShipping = "Payment & Shipping"
//     case address = "Addresses"
//     case buyer = "Trusted Buyer"
//     case notifications = "Notifications"
//     case preference = "Preference"
//     case favCategory = "Favourite"
// 
// 
//     var description: String {
//             return NSLocalizedString(rawValue, comment: "")
//         }
// 
//     var img : ImageResource{
//         switch self {
// 
//         case .paymentShipping:
//             return .inventory
//         case .address:
//             return .mic
//         case .buyer:
//             return .orders
//         case .notifications:
//             return .wallet
//         case .preference:
//             return .tag
//         case .favCategory:
//             return .categories
// 
//         }
//     }
// }
// enum AccountMenuSection : String, CaseIterable, CustomStringConvertible{
// 
//     case about = "About Us"
//     case comntact = "Contact Us"
//     case salesTax = "Sales tax Exemption"
//     case TermsandCond = "Terms & Conditions"
//     case privacy = "Privacy & Policy"
//     case faq = "F.A.Q"
//     case blockList = "Blocked Users"
//     case logout = "Logout"
// 
// 
//     var description: String {
//             return NSLocalizedString(rawValue, comment: "")
//         }
// }
// 
// extension UIDevice {
//     var hasNotch: Bool {
//         let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
//         return bottom > 0
//     }
// }
// 
//
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
    
    // MARK: - UI State
    @State private var segment: AccountSegment = .sellerHub
    @State private var showSideMenu = false
    @State private var userLogOut = false
    @State private var showError = false
    @State private var showhud = false
    @State private var hudMsg = ""

    @State private var isLoading: Bool = false
    
    @State private var sellerInfo:SellerhubInfoModel?
    
    // MARK: - Data State
//    @State private var showsData: [HomeModel] = []
    @State private var request = StoreScheduleShowRequest(
        title: "", date: "", time: "", category_id: "",
        auction_type_id: "", product_ids: "", isExplicitContent: false,
        discoverablitity: "", primaryLanguage: "", repeats: ""
    )
    
    // MARK: - Navigation State
    @State private var navigationState = NavigationState()
    var isNavFrom : Bool
    
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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                headerView
                contentView(geometry: geometry)
                navigationLinks
            }
            .background(Color.bg.opacity(0.5))
            .onAppear {
                getSellerHubInfo()
            }
            
            .bottomSheet(
                isPresented: $userLogOut,
                height: screenHeight / 2,
                topBarCornerRadius: 25,
                showTopIndicator: false,
                content: { logoutSheet }
            )
            .bottomSheet(isPresented: $showError,
                         height: screenHeight * 0.35,
                         topBarCornerRadius: 25,
                         contentBackgroundColor: Color(.systemBackground),
                         topBarBackgroundColor: Color(.systemBackground),
                         showTopIndicator: false,
                         onDismiss: {
                showError = false
            }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showError = false }
                    }, onSecondaryClick: {
                        withAnimation { showError = false }
                    })
                .background(Color(.systemBackground))
                .cornerRadius(25, corners: [.topLeft, .topRight])
            })

        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        PrimaryHeader(
            title: AppString.Account.localized,
            isForLogo: !comeFromSeller,
            leadingImgArr: [.icBack],
            trailingImgArr: [.icMenu],
            onClickLeading: { _ in
                presentationMode.wrappedValue.dismiss()
            },
            onClickTrailing: { _ in
                showSideMenu = true
            },
            count: .constant(0)
        )
    }
    
    // MARK: - Content View
    private func contentView(geometry: GeometryProxy) -> some View {
        let safeBottom = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets.bottom ?? 0
        let contentHeight = max(0, geometry.size.height - safeBottom + 23)
        
        return ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 4) {
                profileCell
                segmentControl
                
                if segment == .sellerHub {
                    sellerHubSection
                } else {
                    myAccountSection
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: contentHeight, alignment: .top)
        .padding(.horizontal, 8)
        .padding(.bottom, safeBottom)
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
        SellerHubSection(sellerInfo: $sellerInfo) {
            navigationState.navigateToTitle = true
        } onCreateProduct: {
            navigationState.navigateToCreateProduct = true
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
        .padding(.bottom, 40)
    }
    
    // MARK: - Credit Section
    private var creditSection: some View {
        TwoVerticalLabelCell(
            dataModel: AccountCredit.allCases,
            topLabel: { $0.labelOlt },
            bottomLabel: { $0.description },
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
            MenuCell(
                title: section.description,
                textColor: .black,
                fontValue: 14.0,
                menuImg: "vacation",
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
    
    // MARK: - Logout Sheet
    private var logoutSheet: some View {
        LogOutSheet(
            onLogoutClick: {
                withAnimation(.snappy) { userLogOut = false }
                handleLogout()
            },
            onCancelClick: {
                withAnimation(.snappy) { userLogOut = false }
            }
        )
    }
    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            // Profile & Verification
            CusNavLink(doNavigate: $navigationState.navigateToProfile, destination: CompleteProfileScreen())
            CusNavLink(doNavigate: $navigationState.navigateToSellerVerification, destination: SellerVerificationScreen())
            
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
            CusNavLink(doNavigate: $navigationState.navigateToCategory, destination: MultiSelectionCategoryScreen(isNavFrom: "Account"))
            CusNavLink(doNavigate: $navigationState.navigateToContactus, destination: ContactUs())
            CusNavLink(doNavigate: $navigationState.navigateToSales, destination: SalesTaxScreen())
            CusNavLink(doNavigate: $navigationState.navigateToBlockedList, destination: BlockedUserScreen())
        }
    }
    
    // MARK: - Seller Hub Navigation Links
    private var sellerHubNavigationLinks: some View {
        Group {
            CusNavLink(doNavigate: $navigationState.navigateToShows, destination: ShowsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToInventry, destination: InventoryScreen(selectedProductIDs: .constant([]), selectedProductData: .constant([])))
            CusNavLink(doNavigate: $navigationState.navigateToOffers, destination: OffersScreen())
            CusNavLink(doNavigate: $navigationState.navigateTips, destination: TipsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToWallet, destination: WalletPayoutView())
            CusNavLink(doNavigate: $navigationState.navigateToMyOrder, destination: MyOrdersScreen())
            CusNavLink(doNavigate: $navigationState.navigateToShipping, destination: ShippingSettingsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToSellerStatus, destination: SellerStatusScreen())
            CusNavLink(doNavigate: $navigationState.navigateToPromoteTool, destination: PromoteToolsView())
            CusNavLink(doNavigate: $navigationState.navigateToSellerTraining, destination: SellingTips(isNavFrom: "Account", backToTabBar: .constant(true)))
            CusNavLink(doNavigate: $navigationState.navigateToPremierShop, destination: PremierShopScreen())
            CusNavLink(doNavigate: $navigationState.navigateToAnalytics, destination: AnalyticsScreen())
            CusNavLink(doNavigate: $navigationState.navigateToAffilateProgram, destination: AffiliateProgramScreen(referralCode: "SELLER2025", stats: ReferralStats(totalReferrals: 0, earnings: 0.0), onShare: {}))
            CusNavLink(doNavigate: $navigationState.navigateToCreateProduct, destination: ListProductScreen())
            CusNavLink(doNavigate: $navigationState.navigateToTitle, destination: ShowTitleTips(request: $request, fromPrepare: .constant(false), backToPrepare: $navigationState.navigateToTitle))
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
            case 4: navigationState.navigateToPreference = true
            case 5: navigationState.navigateToCategory = true
            default: break
            }
        }
    }
    
    // MARK: - Handle Menu Selection
    private func handleMenuSelection(index: Int) {
        switch index {
        case 0: openURL("https://backend.bidcast.betaplanets.com/about-us")
        case 1: navigationState.navigateToContactus = true
        case 2: navigationState.navigateToSales = true
        case 3: openURL("https://backend.bidcast.betaplanets.com/terms-condition")
        case 4: openURL("https://backend.bidcast.betaplanets.com/privacy-policy")
        case 5: openURL("https://backend.bidcast.betaplanets.com/faq")
        case 6: navigationState.navigateToBlockedList = true
        case 7: userLogOut = true
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
            
            if menuViewModel.logOutResponse != nil {
                performUserLogout()
            }
        }
    }
    
    // MARK: - Handle Logout
    private func getSellerHubInfo() {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: menuViewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText:""
                    )
                    showError = true
                    isLoading = true
                },
                onSuccess: {
                    isLoading = true
                    if menuViewModel.sellerHubInfoResponse?.status == "success" {
                        sellerInfo = menuViewModel.sellerHubInfoResponse?.data
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
            UserDefaults.accessToken.removeAll()
            UserDefaults.sellerVerafied.removeAll()
            UserDefaults.buyerVerafied.removeAll()
            
            // Handle remember me
            let rememberMe = UserDefaults.rememberMe
            if !rememberMe {
                _ = KeychainManager.shared.delete(email: UserDefaults.userEmail)
                UserDefaults.userEmail = ""
                UserDefaults.rememberMe = false
            }
            
            UserDefaults.userId = -1
            
            // Navigate to authentication
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    appRootManager.currentRoot = .authentication
                }
            }
        }
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
    case favCategory = "Favourite"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
    
    var img: ImageResource {
        switch self {
        case .paymentShipping: return .inventory
        case .address: return .mic
        case .buyer: return .orders
        case .notifications: return .wallet
        case .preference: return .tag
        case .favCategory: return .categories
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
    case logout = "Logout"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
}

// MARK: - UIDevice Extension
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
