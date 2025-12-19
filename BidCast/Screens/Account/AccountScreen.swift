//
//  AccountScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//
//
//import SwiftUI
//import SVProgressHUD
//import SwiftUI
//
//// MARK: - Seller Hub Section
//struct SellerHubSection: View {
//    @State private var isLoadingStats = true
//    @State private var isLoadingShows = true
//    @Binding var showsData: [HomeModel]
//    
//    // Stats data
//    @State private var itemsCount = 0
//    @State private var revenue = "$0.00"
//    @State private var rating = 0.0
//    @State private var onTimeRate = "100%"
//    @State private var defectFreeRate = "100%"
//    @State private var policyStanding = "Excellent"
//    @State private var payouts = "$199.00"
//    @State private var totalOrders = "22 Items"
//    
//    @State var showID = ""
//    @State var isLive = false
//    @State private var selectedProductData: [ProductDataModel] = []
//    @State var selectedShowsData = HomeModel()
//    @State var navigateToReherseal = false
//    
//    var onCreateShow: () -> Void
//    var onCreateProduct: () -> Void
//    var onViewAllShows: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            // Stats Cards Row
//            statsCardsRow
//            
//            // Create Buttons
//            createButtonsRow
//            
//            // Upcoming Shows Section
//            upcomingShowsSection
//            
//            // Account Health Section
//            accountHealthSection
//            
//            // Payout & Orders Row
//            payoutOrdersRow
//            
//            // Vacation Mode
//            vacationModeCard
//            CusNavLink(doNavigate: $navigateToReherseal,
//                       destination: RehearsalScreen(showUd: $showID,
//                                                    productListData: $selectedProductData,
//                                                    isLive: isLive,
//                                                    backToTabBar: .constant(true),
//                                                    showsData: $selectedShowsData))
//        }
//        .padding(.horizontal, 12)
//        .padding(.top, 8)
//        .onAppear {
//            loadData()
//        }
//        
//    }
//    
//    // MARK: - Stats Cards Row
//    private var statsCardsRow: some View {
//        HStack(spacing: 12) {
//            StatCardView(
//                value: isLoadingStats ? "" : "\(itemsCount)",
//                label: "Items",
//                isLoading: isLoadingStats
//            )
//            
//            StatCardView(
//                value: isLoadingStats ? "" : revenue,
//                label: "Revenue",
//                isLoading: isLoadingStats
//            )
//            
//            StatCardView(
//                value: isLoadingStats ? "" : String(format: "%.1f", rating),
//                label: "Rating",
//                isLoading: isLoadingStats
//            )
//        }
//    }
//    
//    // MARK: - Create Buttons Row
//    private var createButtonsRow: some View {
//        HStack(spacing: 12) {
//            // Create Show Button
//            Button(action: onCreateShow) {
//                Text("Create Show")
//                    .font(.custom(poppinsSemiBold, size: 16))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 52)
//                    .background(
//                        RoundedRectangle(cornerRadius: 26)
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [.defaultTheme, .defaultTheme.opacity(0.8)]),
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                    )
//                    .shadow(color: .defaultTheme.opacity(0.3), radius: 8, x: 0, y: 4)
//            }
//            
//            // Create Product Button
//            Button(action: onCreateProduct) {
//                Text("Create Product")
//                    .font(.custom(poppinsSemiBold, size: 16))
//                    .foregroundColor(.defaultTheme)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 52)
//                    .background(
//                        RoundedRectangle(cornerRadius: 26)
//                            .fill(Color.defaultTheme.opacity(0.1))
//                    )
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 26)
//                            .stroke(Color.defaultTheme.opacity(0.3), lineWidth: 1.5)
//                    )
//            }
//        }
//    }
//    
//    // MARK: - Upcoming Shows Section
//    private var upcomingShowsSection: some View {
//        VStack(spacing: 12) {
//            HStack {
//                Text("Upcoming Shows")
//                    .font(.custom(poppinsBold, size: 18))
//                    .foregroundColor(.primary)
//                
//                Spacer()
//                
//                Button(action: onViewAllShows) {
//                    Text("View All")
//                        .font(.custom(poppinsMedium, size: 14))
//                        .foregroundColor(.defaultTheme)
//                }
//            }
//            
//            if isLoadingShows {
//                // Shimmer Loading
//                VStack(spacing: 12) {
//                    ForEach(0..<2) { _ in
//                        ShowShimmerCard()
//                    }
//                }
//            } else if showsData.isEmpty {
//                // Empty State
//                EmptyShowsCard()
//            } else {
//                // Shows List (Top 5)
//                VStack(spacing: 12) {
//                    ForEach(showsData.indices,id: \.self) { index in
//                        let data = showsData[index]
//                        ShowCardView(show: data,onTap: {
//                            showID = "\(data.id ?? 0)"
//                            isLive = data.is_live ?? false
//                            selectedProductData = data.products ?? []
//                            selectedShowsData = data
//                            navigateToReherseal = true
//                        })
//                        .padding(.horizontal, -12)
//                    }
//                }
//            }
//        }
//    }
//    
//    // MARK: - Account Health Section
//    private var accountHealthSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Account Health")
//                .font(.custom(poppinsBold, size: 18))
//                .foregroundColor(.primary)
//            
//            if isLoadingStats {
//                HStack(spacing: 12) {
//                    ForEach(0..<3) { _ in
//                        HealthShimmerCard()
//                    }
//                }
//            } else {
//                HStack(spacing: 0) {
//                    HealthStatCard(
//                        value: onTimeRate,
//                        label: "On-Time\nScan Rate"
//                    )
//                    Divider().frame(height: 60).padding(.horizontal, 8)
//                    HealthStatCard(
//                        value: defectFreeRate,
//                        label: "Defect-Free\nOrder Rate"
//                    )
//                    Divider().frame(height: 60).padding(.horizontal, 8)
//                    HealthStatCard(
//                        value: policyStanding,
//                        label: "Policy\nStanding"
//                    )
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 16)
//                .background(
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color(.systemBackground).opacity(0.9))
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//                )
//            }
//        }
//    }
//    
//    // MARK: - Payout & Orders Row
//    private var payoutOrdersRow: some View {
//        HStack(spacing: 12) {
//            // Payouts Card
//            if isLoadingStats {
//                PayoutShimmerCard()
//            } else {
//                PayoutCard(
//                    title: "Payouts",
//                    value: payouts
//                )
//            }
//            
//            // Total Orders Card
//            if isLoadingStats {
//                PayoutShimmerCard()
//            } else {
//                PayoutCard(
//                    title: "Total Orders",
//                    value: totalOrders
//                )
//            }
//        }
//    }
//    
//    // MARK: - Vacation Mode Card
//    private var vacationModeCard: some View {
//        HStack(spacing: 16) {
//            Image(systemName: "beach.umbrella")
//                .font(.system(size: 24))
//                .foregroundColor(.defaultTheme)
//            
//            Text("Vacation Mode")
//                .font(.custom(poppinsSemiBold, size: 16))
//                .foregroundColor(.primary)
//            
//            Spacer()
//            
//            Toggle("", isOn: .constant(false))
//                .labelsHidden()
//                .tint(.defaultTheme)
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//        )
//        .padding(.bottom, 60)
//    }
//    
//    // MARK: - Load Data
//    private func loadData() {
//        // Simulate API call for stats
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            withAnimation {
//                itemsCount = 284
//                revenue = "$5.2K"
//                rating = 4.8
//                isLoadingStats = false
//            }
//        }
//        
//        // Simulate API call for shows
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//            withAnimation {
//                // Load your shows data here
//                isLoadingShows = false
//            }
//        }
//    }
//}
//
//// MARK: - Stat Card
//struct StatCardView: View {
//    let value: String
//    let label: String
//    let isLoading: Bool
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            if isLoading {
//                ShimmerView()
//                    .frame(height: 28)
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//            } else {
//                Text(value)
//                    .font(.custom(poppinsBold, size: 24))
//                    .foregroundColor(.primary)
//            }
//            
//            Text(label)
//                .font(.custom(poppinsRegular, size: 13))
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 16)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - Show Card
////struct ShowCard: View {
////    let show: HomeModel
////    
////    var body: some View {
////        HStack(spacing: 12) {
////            // Show Image
////            RoundedRectangle(cornerRadius: 12)
////                .fill(Color.gray.opacity(0.2))
////                .frame(width: 60, height: 60)
////                .overlay(
////                    Image(systemName: "video.fill")
////                        .foregroundColor(.gray)
////                )
////            
////            VStack(alignment: .leading, spacing: 4) {
////                Text(show.title ?? "")
////                    .font(.custom(poppinsSemiBold, size: 15))
////                    .foregroundColor(.primary)
////                    .lineLimit(1)
////                
////                Text(show.date ?? "")
////                    .font(.custom(poppinsRegular, size: 13))
////                    .foregroundColor(.gray)
////            }
////            
////            Spacer()
////            
////            Image(systemName: "chevron.right")
////                .font(.system(size: 14, weight: .semibold))
////                .foregroundColor(.gray)
////        }
////        .padding(12)
////        .background(
////            RoundedRectangle(cornerRadius: 12)
////                .fill(Color(.systemGray6).opacity(0.5))
////        )
////    }
////}
//
//// MARK: - Empty Shows Card
//struct EmptyShowsCard: View {
//    var body: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "calendar.badge.exclamationmark")
//                .font(.system(size: 40))
//                .foregroundColor(.gray.opacity(0.5))
//            
//            Text("No Upcoming Shows!")
//                .font(.custom(poppinsMedium, size: 16))
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 40)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - Health Stat Card
//struct HealthStatCard: View {
//    let value: String
//    let label: String
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Text(value)
//                .font(.custom(poppinsBold, size: 20))
//                .foregroundColor(.primary)
//            
//            Text(label)
//                .font(.custom(poppinsRegular, size: 11))
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//                .lineLimit(2)
//                .fixedSize(horizontal: false, vertical: true)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 16)
//    }
//}
//
//// MARK: - Payout Card
//struct PayoutCard: View {
//    let title: String
//    let value: String
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.custom(poppinsMedium, size: 14))
//                    .foregroundColor(.gray)
//                
//                Text(value)
//                    .font(.custom(poppinsBold, size: 14))
//                    .foregroundColor(.primary)
//            }
//            
//            Spacer()
//            
//            Image(systemName: "chevron.right")
//                .font(.system(size: 16, weight: .semibold))
//                .foregroundColor(.defaultTheme)
//        }
//        .padding(16)
//        .frame(maxWidth: .infinity)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - Shimmer Views
//struct ShowShimmerCard: View {
//    var body: some View {
//        HStack(spacing: 12) {
//            ShimmerView()
//                .frame(width: 60, height: 60)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//            
//            VStack(alignment: .leading, spacing: 8) {
//                ShimmerView()
//                    .frame(height: 16)
//                    .frame(maxWidth: 200)
//                    .clipShape(RoundedRectangle(cornerRadius: 4))
//                
//                ShimmerView()
//                    .frame(height: 14)
//                    .frame(maxWidth: 120)
//                    .clipShape(RoundedRectangle(cornerRadius: 4))
//            }
//            
//            Spacer()
//        }
//        .padding(12)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemGray6).opacity(0.5))
//        )
//    }
//}
//
//struct HealthShimmerCard: View {
//    var body: some View {
//        VStack(spacing: 8) {
//            ShimmerView()
//                .frame(height: 24)
//                .clipShape(RoundedRectangle(cornerRadius: 6))
//            
//            ShimmerView()
//                .frame(height: 14)
//                .clipShape(RoundedRectangle(cornerRadius: 4))
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 16)
//        .padding(.horizontal, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemGray6).opacity(0.5))
//        )
//    }
//}
//
//struct PayoutShimmerCard: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            ShimmerView()
//                .frame(height: 16)
//                .frame(maxWidth: 80)
//                .clipShape(RoundedRectangle(cornerRadius: 4))
//
//            ShimmerView()
//                .frame(height: 24)
//                .frame(maxWidth: 120)
//                .clipShape(RoundedRectangle(cornerRadius: 6))
//        }
//        .padding(16)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//        )
//    }
//}
//
//// MARK: - Shimmer Effect
////struct ShimmerView: View {
////    @State private var phase: CGFloat = 0
////    
////    var body: some View {
////        GeometryReader { geometry in
////            ZStack {
////                Color.gray.opacity(0.3)
////                
////                LinearGradient(
////                    gradient: Gradient(colors: [
////                        .clear,
////                        .white.opacity(0.6),
////                        .clear
////                    ]),
////                    startPoint: .leading,
////                    endPoint: .trailing
////                )
////                .frame(width: geometry.size.width * 0.4)
////                .offset(x: phase * geometry.size.width - geometry.size.width * 0.2)
////            }
////        }
////        .onAppear {
////            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
////                phase = 1
////            }
////        }
////    }
////}
//
//// MARK: - Show Model
//struct ShowModel: Identifiable {
//    let id = UUID()
//    let title: String
//    let date: String
//}
//
//// MARK: - Usage in Your Account Screen
//// Replace the seller hub section with:
///*
//if segment == .sellerHub {
//    SellerHubSection(
//        onCreateShow: {
//            navigateToShows = true
//        },
//        onCreateProduct: {
//            navigateToInve
// */
//
//
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
// 
// //#Preview {
// //    AccountScreen()
// //}
// 
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
