//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//


import SwiftUI
import SVProgressHUD
import AlertToast

// MARK: - Account Health Screen
struct PremierShopScreen: View {
    @Environment(\.presentationMode) var presentationMode
//    @StateObject private var viewModel = AccountHealthViewModel()
    
    @StateObject private var viewModel = PremierShopViewModel()
    @State private var premierShopData = PremierShopModel()
    @State private var applyPremierShopData: ApplyPremierShopModel?
    
    @State private var onTimeScanRate = "100%"
    @State private var defectFreeRate = "100%"
    @State private var policyStanding = "Excellent"
    @State private var totalSales = "$5,240"
    @State private var ordersCompleted = 142
    @State private var averageRating = 4.8
    
    @State private var animateCard = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State private var isLoading = true
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Welcome/Tip Section
                    tipSection
                    
                    // Shop Performance Section
                    ShopView
                        .padding(.bottom, 20)
                    
//                    .background(.white)
//                    .padding(.bottom, 60)
                    
                    // Policy Standing (Excellent)
                    policyStandingSection
                    
                  
                    
                    premierShopSection
                    
                   
                    RequirnmentView
                    
//                    // Sales Performance
//                    salesPerformanceSection
                    if premierShopData.isPremierApplied != 1{
                        ApplyPremiumButton
                        }
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            showShimmerEffect()
            Task {
                await loadData()
            }
        }
        
        .bottomSheet(isPresented: $showError, height: screenHeight/2.8, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            if viewModel.errorMessage == nil || viewModel.errorMessage == ""{
                let response = viewModel.applyPremierShopResponse
                if response?.status == "success" {
                    withAnimation { showError = true }
                }else{
                    withAnimation { showError = false }
                }
            }else{
                withAnimation { showError = false }
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if alertType.primaryBtnText == AppString.proceedToLogin.localized {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    let response = viewModel.applyPremierShopResponse
                    if response?.status == "success" {
                        self.presentationMode.wrappedValue.dismiss()
                    }else{
                        withAnimation { showError = false }
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                })
        })
        
        
        .toast(isPresenting: $showhud) {
              AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
          }
         
      
    }
    
    private func showShimmerEffect() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    
    private var RequirnmentView: some View {
        // MARK: Requirements
        VStack(alignment: .leading, spacing: 12) {
            Text(AppString.Requirements)
                .font(.custom(poppinsBold, size: 20))
                .foregroundColor(.primary)
            
            HStack {
                if let requirements = premierShopData.requirements {
                    VStack(alignment: .leading, spacing: 12) {
//                        Text(AppString.Requirements)
//                            .font(.custom(poppinsSemiBold, size: 18))
                        
                        ForEach(requirements, id: \.platform) { req in
                            RequirementView(requirement: req)
                        }
                    }
//                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                         .stroke(.defaultTheme.opacity(0.15), lineWidth: 1)
                    )
            )
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color(.systemBackground))
//                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//            )
        }
    }
    
    // MARK: - Premier Shop Section
       private var premierShopSection: some View {
           VStack(alignment: .leading, spacing: 12) {
               
               Text("Become a Premier Shop")
                   .font(.custom(poppinsBold, size: 20))
                   .foregroundColor(.primary)
               
               VStack(alignment: .leading, spacing: 12) {
                   
                   Text("""
   These are your key seller performance rates based on the past three months. These rates reflect the % of orders where buyers had positive experiences, with no seller-fault issues based on ship time or refunds and seller-driven cancellations.
   """)
                   .font(.custom(poppinsRegular, size: 14))
                   .foregroundColor(.secondary)
//                   .lineSpacing(1)
                   
                   Text("""
   Premier Shop status helps buyers identify top-performing sellers. Keep in mind performance rates are rarely 100% because buyer issues covered under our Buyer Protection Policy are excluded.
   """)
                   .font(.custom(poppinsRegular, size: 14))
                   .foregroundColor(.secondary)
//                   .lineSpacing(4)
                   
//                   Text("Buyer Protection Policy")
//                       .font(.custom(poppinsMedium, size: 14))
//                       .foregroundColor(.defaultTheme)
               }
               .padding(16)
               .background(
                   RoundedRectangle(cornerRadius: 18)
                       .fill(Color.white)
                       .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                       .overlay(
                           RoundedRectangle(cornerRadius: 18)
                            .stroke(.defaultTheme.opacity(0.15), lineWidth: 1)
                       )
               )
               .scaleEffect(animateCard ? 1 : 0.98)
               .animation(.spring(response: 0.4, dampingFraction: 0.8), value: animateCard)
               .onAppear { animateCard = true }
           }
          
       }

    
    private var ReviewProcessView: some View {
        // MARK: Review Process
        VStack(alignment: .leading, spacing: 12) {
//            Text(AppString.ReviewProcess)
//                .font(.custom(poppinsSemiBold, size: 18))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    AsyncImage(url: URL(string: premierShopData.reviewLogo ?? "")) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.defaultTheme)
                    }
                    .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading) {
                        Text(premierShopData.reviewTitle ?? "")
                            .font(.custom(poppinsMedium, size: 16))
                            .fontWeight(.semibold)
                        Text(premierShopData.reviewDetails ?? "")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    Text(AppString.CurrentProgress)
                        .font(.custom(poppinsRegular, size: 14))
                    Spacer()
                    Text(premierShopData.currentProgress ?? "0%")
                }
                ProgressView(value: Double(premierShopData.currentProgress?.replacingOccurrences(of: "%", with: "") ?? "0") ?? 0,
                             total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .defaultTheme))
                
                Text("Next review in \(premierShopData.nextReview ?? "0") days")
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.gray)
            }
//            .padding()
//            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
//        .padding(.horizontal)
        
    }
    private var ApplyPremiumButton: some View {
        // MARK: Apply Button
        Button(action: {
            // TODO: Apply for Premier Status action
            Task {
                await self.applyPremierShopAPI()
            }
        }) {
            Text(AppString.ApplyForPremierStatus)
                .foregroundColor(.white)
                .font(.custom(poppinsMedium, size: 16))
                .frame(maxWidth: .infinity)
                .padding()
                .background(.defaultTheme)
                .cornerRadius(32)
        }
//        .padding()
        //
    }
    

    // MARK: - Best Solution: Proper Container
    private var ShopView: some View {
        VStack(spacing: 0) {
            // Top section with blue background
            VStack(spacing: 8) {
                AsyncImage(url: URL(string: premierShopData.pageLogo ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.white)
                    } else if phase.error != nil {
                        Image(systemName: "photo")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color.white)
                    } else {
                        ProgressView()
                    }
                }
                .frame(height: 40)
                
                Text(premierShopData.pageTitle ?? "")
                    .font(.custom(poppinsSemiBold, size: 24))
                    .foregroundColor(.white)
                
                Text(premierShopData.pageDetails ?? "")
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            .padding(.bottom, 100)  // Space for overlapping card
            .frame(maxWidth: .infinity)
            .background(.defaultTheme)
            .cornerRadius(12)
            
            // Spacer for card overlap
            Spacer()
                .frame(height: 80)  // Half of card height visible below
        }
        .overlay(
            // Overlapping card
            VStack(spacing: 12) {
                HStack {
                    AsyncImage(url: URL(string: premierShopData.shopLogo ?? "")) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Image(systemName: "bag.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.defaultTheme)
                    }
                    .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(premierShopData.shopTitle ?? "")
                            .font(.custom(poppinsSemiBold, size: 16))
                        Text(premierShopData.shopDetails ?? "")
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    if let options = premierShopData.shopOptions {
                        PerformanceMetricCard(
                            value: String(format: "%.1f", options.rating),
                            outOf: 5.0,
                            title: "Rating",
                            color: .green,
                            size: 40,
                            rightArraowRequired: false
                        )
                        PerformanceMetricCard(
                            value: options.response,
                            outOf: 100.0,
                            title: "Response",
                            color: .green,
                            size: 40,
                            rightArraowRequired: false
                        )
                        PerformanceMetricCard(
                            value: options.delivery,
                            outOf: 100.0,
                            title: "Delivery",
                            color: .green,
                            size: 40,
                            rightArraowRequired: false
                        )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
            .padding(.horizontal, 16)
            .offset(y: 150)  // Position card to overlap
            ,
            alignment: .top
        )
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Account Health")
                .font(.custom(poppinsBold, size: 20))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Tip Section
    private var tipSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.defaultTheme)
                
                Text("Welcome!")
                    .font(.custom(poppinsSemiBold, size: 13))
                    .foregroundColor(.primary)
            }
            
            Text("This is where you can monitor your key performance metrics, and any other issues on your account.")
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.defaultTheme.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.defaultTheme.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Shop Performance Section
    private var shopPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Seller Performance")
                .font(.custom(poppinsSemiBold, size: 18))
                .foregroundColor(.primary)
            
            if isLoading {
                ShopPerformanceShimmer()
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("These are your key seller performance rates based on the past three months. These rates reflect the % of orders where buyers had positive experiences, with no seller-fault issues based on ship time (On-Time Scan Rate) or refunds and seller-driven cancellations (Defect-Free Order Rate).")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("These are provided to help you manage your shop's performance. Keep in mind seller performance rates are rarely 100% because we take care of buyers if their issue is covered in our ")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                    + Text("Buyer Protection Policy")
                        .font(.custom(poppinsSemiBold, size: 13))
                        .foregroundColor(.defaultTheme)
                    + Text(".")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Performance Metrics Section
//    private var performanceMetricsSection: some View {
//        HStack(spacing: 16) {
//            if isLoading {
//                PerformanceMetricShimmer()
//                PerformanceMetricShimmer()
//            } else {
//                PerformanceMetricCard(
//                    percentage: onTimeScanRate,
//                    title: "On-Time Scan\nRate",
//                    color: .green
//                )
//                
//                PerformanceMetricCard(
//                    percentage: defectFreeRate,
//                    title: "Defect-Free Order\nRate",
//                    color: .green
//                )
//            }
//        }
//    }
    
//    // MARK: - Requirements Section
//    private var requirementsSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Requirements")
//                .font(.custom(poppinsBold, size: 18))
//                .foregroundColor(.primary)
//            
//            if isLoading {
//                RequirementShimmer()
//                RequirementShimmer()
//            } else {
//                ForEach(requirements, id: \.title) { requirement in
//                    RequirementCard(requirement: requirement)
//                }
//            }
//        }
//    }
//    
    // MARK: - Policy Standing Section
    private var policyStandingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Policy Standing")
                    .font(.custom(poppinsBold, size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
//                if isLoading {
//                    ShimmerView()
//                        .frame(width: 80, height: 24)
//                        .clipShape(Capsule())
//                } else {
//                    Text(policyStanding)
//                        .font(.custom(poppinsSemiBold, size: 14))
//                        .foregroundColor(.green)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(
//                            Capsule()
//                                .fill(Color.green.opacity(0.15))
//                        )
//                }
            }
            
            if isLoading {
                VStack(alignment: .leading, spacing: 8) {
                    ShimmerView()
                        .frame(height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    ShimmerView()
                        .frame(height: 16)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("If you have ")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                    + Text("Community Guidelines")
                        .font(.custom(poppinsSemiBold, size: 13))
                        .foregroundColor(.defaultTheme)
                    + Text(" violations, they'll display here. Violations typically remain on your account for 180 days. If you think a violation was issued in error, you can appeal by responding to the email from Trust & Safety with details about the violation. ")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
//                    + Text("Learn more")
//                        .font(.custom(poppinsSemiBold, size: 13))
//                        .foregroundColor(.defaultTheme)
//                    + Text(".")
//                        .font(.custom(poppinsRegular, size: 13))
//                        .foregroundColor(.secondary)
                    
                    ReviewProcessView
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                             .stroke(.defaultTheme.opacity(0.15), lineWidth: 1)
                        )
                )
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color(.systemBackground))
//                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//                )
//                
            }
            
           
        }
    }
    
    // MARK: - Sales Performance Section
    private var salesPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sales Performance")
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.primary)
            
            if isLoading {
                SalesPerformanceShimmer()
            } else {
                VStack(spacing: 12) {
                    SalesMetricRow(
                        title: "Total Sales",
                        value: totalSales
                    )
                    
                    Divider()
                    
                    SalesMetricRow(
                        title: "Orders Completed",
                        value: "\(ordersCompleted)"
                    )
                    
                    Divider()
                    
                    SalesMetricRow(
                        title: "Average Rating",
                        value: String(format: "%.1f", averageRating)
                    )
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
            }
        }
        .padding(.bottom, 20)
    }
   
}

extension PremierShopScreen {
    
    // MARK: Load API
    func loadData() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await viewModel.getPremierShopContent()
        await SVProgressHUD.dismiss()
        
        if viewModel.premierShopResponse.status != "success" {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.premierShopResponse.message ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK",
                sheetThemeColor: .pinkBtn
            )
            withAnimation(.snappy) { showError = true }
        } else {
            premierShopData = viewModel.premierShopResponse.data ?? PremierShopModel()
        }
    }
    
    // MARK: Apply Premier Shop
    func applyPremierShopAPI() async  {
        
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        await viewModel.applyForPremierShop()
        await SVProgressHUD.dismiss()
        
        guard let status = viewModel.applyPremierShopResponse?.status, status != "success" else {
            alertType = .sheetType(
                icon: .success,
                title: "Success",
                message: "Already Applied",
                primaryBtnText: "",
                secondaryBtnText: "OK",
                sheetThemeColor: .defaultTheme
            )
            withAnimation(.snappy) { showError = true }
            return
        }
        hudMsg = "Premier shop application submitted successfully."
        showhud = true
        applyPremierShopData = viewModel.applyPremierShopResponse?.data
    }
}

// MARK: - Performance Metric Card
struct PerformanceMetricCard: View {
    
    var value: String
    var outOf: Double
    
    let title: String
    let color: Color
    var size: CGFloat = 120
    var rightArraowRequired: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: rightArraowRequired ? 12 : 4)
                    .frame(width: size, height: size)
                
                Circle()
                    .trim(from: 0, to: CGFloat(Double(value.replacingOccurrences(of: "%", with: "")) ?? 0) / outOf)
                    .stroke(color, style: StrokeStyle(lineWidth: rightArraowRequired ? 12 : 4, lineCap: .round))
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                
                Text(value)
                    .font(rightArraowRequired ? .custom(poppinsBold, size: 32) : .custom(poppinsBold, size: 16))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 4) {
                Text(title)
                    .font(.custom(poppinsMedium, size: 13))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                if rightArraowRequired {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.defaultTheme)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
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

// MARK: - Requirement Card
struct RequirementCard: View {
    let requirement: RequirementModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: requirement.icon)
                .font(.system(size: 24))
                .foregroundColor(.defaultTheme)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.defaultThemeLight)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(requirement.title)
                    .font(.custom(poppinsSemiBold, size: 15))
                    .foregroundColor(.primary)
                
                Text(requirement.description)
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
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
    }
}

// MARK: - Sales Metric Row
struct SalesMetricRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Shimmer Views
struct ShopPerformanceShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ShimmerView()
                .frame(height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            ShimmerView()
                .frame(height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            ShimmerView()
                .frame(height: 16)
                .frame(maxWidth: 200)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

struct PerformanceMetricShimmer: View {
    var body: some View {
        VStack(spacing: 16) {
            ShimmerView()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            
            ShimmerView()
                .frame(height: 16)
                .frame(maxWidth: 80)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

struct RequirementShimmer: View {
    var body: some View {
        HStack(spacing: 12) {
            ShimmerView()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 8) {
                ShimmerView()
                    .frame(height: 16)
                    .frame(maxWidth: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                ShimmerView()
                    .frame(height: 14)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

struct SalesPerformanceShimmer: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3) { _ in
                HStack {
                    ShimmerView()
                        .frame(height: 16)
                        .frame(maxWidth: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Spacer()
                    
                    ShimmerView()
                        .frame(height: 16)
                        .frame(maxWidth: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Divider()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - View Models
//class AccountHealthViewModel: ObservableObject {
//    @Published var onTimeScanRate = "100%"
//    @Published var defectFreeRate = "100%"
//    @Published var policyStanding = "Excellent"
//    @Published var totalSales = "$5,240"
//    @Published var ordersCompleted = 142
//    @Published var averageRating = 4.8
//    
//    @Published var requirements: [RequirementModel] = [
//        RequirementModel(
//            icon: "star.fill",
//            title: "Maintain High Rating",
//            description: "Keep your rating above 4.5"
//        ),
//        RequirementModel(
//            icon: "clock.fill",
//            title: "Ship On Time",
//            description: "Ship 95% of orders on time"
//        )
//    ]
//}

struct RequirementModel {
    let icon: String
    let title: String
    let description: String
}

// MARK: - Metric View
struct MetricView: View {
    let title: String
    let value: String
    var body: some View {
        VStack {
            Text(value)
                .font(.custom(poppinsSemiBold, size: 18))
            Text(title)
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}


// MARK: - Preview
//struct AccountHealthScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            AccountHealthScreen()
//        }
//    }
//}

//// MARK: - PremierShopScreen
//struct PremierShopScreen: View {
//    
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showError: Bool = false
//    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State private var showhud: Bool = false
//    @State private var hudMsg: String = ""
//    
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    @StateObject private var viewModel = PremierShopViewModel()
//    @State private var premierShopData = PremierShopModel()
//    @State private var applyPremierShopData: ApplyPremierShopModel?
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            
//            // Header
//            PrimaryHeader(
//                title: AppString.PremierShop,
//                isForLogo: false,
//                leadingImgArr: ["chevron.left"],
//                trailingImgArr: [],
//                onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
//                count: .constant(0)
//            )
//            .padding(.horizontal)
//            .frame(height: 50)
//            .background(Color(.systemBackground))
//            
//            ScrollView {
//                VStack(spacing: 20) {
//                    
//                    // MARK: Header Section
//                    ZStack(alignment: .top) {
//                        VStack(spacing: 8) {
//                            AsyncImage(url: URL(string: premierShopData.pageLogo ?? "")) { phase in
//                                if let image = phase.image {
//                                    image
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .foregroundColor(Color.white)
//                                } else if phase.error != nil {
//                                    Image(systemName: "photo")
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .foregroundColor(Color.white)
//                                } else {
//                                    ProgressView()
//                                }
//                            }
//                            .frame(height: 40)
//                            
//                            Text(premierShopData.pageTitle ?? "")
//                                .font(.custom(poppinsSemiBold, size: 24))
//                                .foregroundColor(.white)
//                            
//                            Text(premierShopData.pageDetails ?? "")
//                                .font(.custom(poppinsRegular, size: 14))
//                                .foregroundColor(.white.opacity(0.9))
//                                .multilineTextAlignment(.center)
//                        }
//                        .padding()
//                        .padding(.bottom, 80)
//                        .frame(maxWidth: .infinity, minHeight: 220)
//                        .background(.defaultTheme)
////                        .background(
////                            LinearGradient(colors: [Color.defaultTheme.opacity(0.9), Color.darkRed],
////                                           startPoint: .top, endPoint: .bottom)
////                        )
//                        
//                        // Shop Status Card
//                        VStack(spacing: 12) {
//                            HStack {
//                                AsyncImage(url: URL(string: premierShopData.shopLogo ?? "")) { image in
//                                    image.resizable().scaledToFit()
//                                } placeholder: {
//                                    Image(systemName: "bag.fill")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .foregroundColor(.defaultTheme)
//                                }
//                                .frame(width: 32, height: 32)
//                                
//                                VStack(alignment: .leading) {
//                                    Text(premierShopData.shopTitle ?? "")
//                                        .font(.custom(poppinsSemiBold, size: 16))
//                                    Text(premierShopData.shopDetails ?? "")
//                                        .font(.custom(poppinsRegular, size: 14))
//                                        .foregroundColor(.gray)
//                                }
//                                Spacer()
//                            }
//                            
//                            HStack {
//                                if let options = premierShopData.shopOptions {
//                                    MetricView(title: "Rating", value: String(format: "%.1f", options.rating))
//                                    MetricView(title: "Response", value: options.response)
//                                    MetricView(title: "Delivery", value: options.delivery)
//                                }
//                            }
//                        }
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(16)
//                        .shadow(radius: 2)
//                        .padding(.horizontal)
//                        .offset(y: 150)
//                    }
//                    .padding(.bottom, 50)
//                    
//                    // MARK: Benefits Grid
//                    if let features = premierShopData.features {
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text(AppString.PremierBenefits)
//                                .font(.custom(poppinsSemiBold, size: 18))
//                            
//                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//                                ForEach(features, id: \.title) { feature in
//                                    BenefitView(benefit: feature)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                    
//                    // MARK: Requirements
//                    if let requirements = premierShopData.requirements {
//                        VStack(alignment: .leading, spacing: 12) {
//                            Text(AppString.Requirements)
//                                .font(.custom(poppinsSemiBold, size: 18))
//                            
//                            ForEach(requirements, id: \.platform) { req in
//                                RequirementView(requirement: req)
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
//                    
//                    // MARK: Review Process
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text(AppString.ReviewProcess)
//                            .font(.custom(poppinsSemiBold, size: 18))
//                        
//                        VStack(alignment: .leading, spacing: 8) {
//                            HStack {
//                                AsyncImage(url: URL(string: premierShopData.reviewLogo ?? "")) { image in
//                                    image.resizable().scaledToFit()
//                                } placeholder: {
//                                    Image(systemName: "calendar.badge.clock")
//                                        .foregroundColor(.defaultTheme)
//                                }
//                                .frame(width: 24, height: 24)
//                                
//                                VStack(alignment: .leading) {
//                                    Text(premierShopData.reviewTitle ?? "")
//                                        .font(.custom(poppinsMedium, size: 16))
//                                        .fontWeight(.semibold)
//                                    Text(premierShopData.reviewDetails ?? "")
//                                        .font(.custom(poppinsRegular, size: 14))
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                            
//                            HStack {
//                                Text(AppString.CurrentProgress)
//                                    .font(.custom(poppinsRegular, size: 14))
//                                Spacer()
//                                Text(premierShopData.currentProgress ?? "0%")
//                            }
//                            ProgressView(value: Double(premierShopData.currentProgress?.replacingOccurrences(of: "%", with: "") ?? "0") ?? 0,
//                                         total: 100)
//                            .progressViewStyle(LinearProgressViewStyle(tint: .defaultTheme))
//                            
//                            Text("Next review in \(premierShopData.nextReview ?? "0") days")
//                                .font(.custom(poppinsRegular, size: 14))
//                                .foregroundColor(.gray)
//                        }
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .cornerRadius(12)
//                    }
//                    .padding(.horizontal)
//                    
//                    // MARK: Apply Button
//                    Button(action: {
//                        // TODO: Apply for Premier Status action
//                        Task {
//                            await self.applyPremierShopAPI()
//                        }
//                    }) {
//                        Text(AppString.ApplyForPremierStatus)
//                            .foregroundColor(.white)
//                            .font(.custom(poppinsMedium, size: 16))
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(.defaultTheme)
//                            .cornerRadius(12)
//                    }
//                    .padding()
//                    
//                }
//                .padding(.top)
//            }
//        }
//        .toast(isPresenting: $showhud) {
//            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
//        }
//        .onFirstAppear {
//            Task { await loadData() }
//        }
//    }
//    
//    // MARK: Load API
//    func loadData() async {
//        guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.show()
//        await viewModel.getPremierShopContent()
//        await SVProgressHUD.dismiss()
//        
//        if viewModel.premierShopResponse.status != "success" {
//            alertType = .sheetType(
//                icon: .alert,
//                title: "Error",
//                message: viewModel.premierShopResponse.message ?? "Something went wrong.",
//                primaryBtnText: "",
//                secondaryBtnText: "OK",
//                sheetThemeColor: .pinkBtn
//            )
//            withAnimation(.snappy) { showError = true }
//        } else {
//            premierShopData = viewModel.premierShopResponse.data ?? PremierShopModel()
//        }
//    }
//    
//    // MARK: Apply Premier Shop
//    func applyPremierShopAPI() async  {
//        guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.show()
//        await viewModel.applyForPremierShop()
//        await SVProgressHUD.dismiss()
//        
//        guard let status = viewModel.applyPremierShopResponse?.status, status != "success" else {
//            alertType = .sheetType(
//                icon: .alert,
//                title: "Error",
//                message: viewModel.premierShopResponse.message ?? "Something went wrong.",
//                primaryBtnText: "",
//                secondaryBtnText: "OK",
//                sheetThemeColor: .pinkBtn
//            )
//            withAnimation(.snappy) { showError = true }
//            return
//        }
//        hudMsg = "Premier shop application submitted successfully."
//        showhud = true
//        applyPremierShopData = viewModel.applyPremierShopResponse?.data
//    }
//}
//


