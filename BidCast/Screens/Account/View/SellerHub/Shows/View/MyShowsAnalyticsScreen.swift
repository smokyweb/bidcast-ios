//
//  MyShowsAnalyticsScreen.swift
//  BidCast
//
//  Created by JamTech on 09/12/25.
//

import SwiftUI

struct MyShowsAnalyticsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var showsViewModel = ShowsViewModel()
    @State private var showsOverviewData = GetShowOverviewModel()
    
    @Binding var showId: String
    @State var showhud: Bool = false
    
    @State var navigateToVideoReceipt: Bool = false
    @State private var videoURL: String = ""
    
    @State var hudMsg: String = ""
    @State var showError = false
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    
    @State private var duration: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.custom(poppinsBold, size: 16))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("My Shows")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: Watch VOD Card
//                    Button {
//                        
//                    } label: {
                    WatchVODCard(duration: showsOverviewData.videoDuration ?? "--:--") {
                        navigateToVideoReceipt = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    //                    }
                    //                    .buttonStyle(.plain)
                    
                    
                    
                    // MARK: Overview Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Overview")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                StatCard(title: "Sales",
                                         value: formatCurrencyCompact(Double(showsOverviewData.totalSales ?? "") ?? 0.0),
                                         icon: "dollarsign.circle.fill",
                                         color: .green)
                                
                                StatCard(title: "Orders",
                                         value: "\(showsOverviewData.orderCount ?? 0)",
                                         icon: "bag.fill",
                                         color: .blue)
                            }
                            
                            HStack(spacing: 12) {
                                StatCard(title: "Show Duration",
                                         value: showsOverviewData.videoDuration ?? "--:--",
                                         icon: "clock.fill",
                                         color: .orange)
                                
                                StatCard(title: "Shares",
                                         value: "\(showsOverviewData.shareCount ?? 0)",
                                         icon: "square.and.arrow.up.fill",
                                         color: .purple)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // MARK: Community Boost
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Community Boost")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                StatCard(title: "Viewers",
                                         value: "\(showsOverviewData.viewerCount ?? 0)",
                                         icon: "eye.fill",
                                         color: .blue)
                                
                                StatCard(title: "New Followers",
                                         value: "\(showsOverviewData.newFollowers ?? 0)",
                                         icon: "person.badge.plus.fill",
                                         color: .pink)
                            }
                            
                            ContributionCard(total: showsOverviewData.contributionsCount ?? "")
                            
                            StatCard(title: "Total Bids",
                                     value: "\(showsOverviewData.totalBids ?? 0)",
                                     icon: "hammer.fill",
                                     color: .red,
                                     isFullWidth: true)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    SellerAnalyticsCTA()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
            .background(Color.backGround)
            
            CusNavLink(doNavigate: $navigateToVideoReceipt, destination: VideoPlayerScreen(videoURL: showsOverviewData.fileURL ?? ""))
        }
        .onFirstAppear {
            getShowOverviewData()
        }
        .navigationBarHidden(true)
    }
    
    private func formatCurrencyCompact(_ value: Double) -> String {
           let absValue = abs(value)
           let sign = value < 0 ? "-" : ""
           
           switch absValue {
           case 1_000_000_000...:
               // Billions
               return String(format: "%@$%.2fB", sign, absValue / 1_000_000_000)
           case 1_000_000...:
               // Millions
               return String(format: "%@$%.2fM", sign, absValue / 1_000_000)
           case 1_000...:
               // Thousands
               return String(format: "%@$%.1fK", sign, absValue / 1_000)
           default:
               // Less than 1000 - show full amount
               return String(format: "%@$%.2f", sign, absValue)
           }
       }
}

extension MyShowsAnalyticsScreen {
    private func getShowOverviewData()  {
        
        // Convert showId from String → Int
        guard let id = Int(showId), id > 0 else {
            print("❌ Invalid showId →", showId)
            return
        }
        
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
                
                // ----------------------
                // MARK: ERROR HANDLER
                // ----------------------
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.circle",
                        title: "Error",
                        message: errorDesc(error: error, message: showsViewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized
                    )
                    showError = true
                },
                
                // ----------------------
                // MARK: SUCCESS HANDLER
                // ----------------------
                onSuccess: handleShowOverviewSuccess(id: id)
                
            ) {
                // ----------------------
                // MARK: API CALL
                // ----------------------
                try await showsViewModel.getShowOverview(
                    request: ShowOverviewRequest(show_id: showId)
                )
            }
        }
    }
    
    private func handleShowOverviewSuccess(id: Int) -> () -> Void {
        return {
            let api = showsViewModel.getShowOverviewModel?.data

            let overview = GetShowOverviewModel(
                orderCount: api?.orderCount ?? 0,
                videoDuration: api?.videoDuration ?? "--:--",
                totalSales: api?.totalSales ?? "0",
                shareCount: api?.shareCount ?? 0,
                viewerCount: api?.viewerCount ?? 0,
                newFollowers: api?.newFollowers ?? 0,
                contributionsCount: api?.contributionsCount ?? "",
                totalBids: api?.totalBids ?? 0,
                fileURL: api?.fileURL ?? ""
            )

            DispatchQueue.main.async {
                self.showsOverviewData = overview
                self.videoURL = overview.fileURL ?? ""
            }
        }
    }


}

// MARK: - Watch VOD Card
struct WatchVODCard: View {
    var duration: String
    @State private var isPressed: Bool = false
    var buttonPressedClosure: (() -> Void)?
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            buttonPressedClosure?()
        }) {
            HStack(spacing: 16) {
                // Play Button Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: 2)
                }
                .shadow(color: Color.defaultTheme.opacity(0.3), radius: 12, x: 0, y: 6)
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Watch VOD")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Show Duration: \(duration)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    var value: String
    let icon: String
    let color: Color
    var isFullWidth: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
               
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.leading, 12)
        }
        .frame(maxWidth: isFullWidth ? .infinity : nil)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Contribution Card
struct ContributionCard: View {
    var total: String
    @State private var showInfo: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "giftcard.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Contributions Total")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                }
               
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showInfo.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.defaultThemeLight)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(total)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.leading, 12)
            
            if showInfo {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    
                    Text("Total contributions from viewers during this show")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.defaultTheme.opacity(0.05))
                )
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Seller Analytics CTA
struct SellerAnalyticsCTA: View {
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 16) {
                // Chart Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.defaultTheme.opacity(0.12))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Visit Seller Analytics for more!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Take a look at our new and improved seller analytics design!")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.defaultThemeLight, Color.defaultTheme.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.defaultTheme.opacity(0.2), lineWidth: 1.5)
            )
            .shadow(color: Color.defaultTheme.opacity(0.15), radius: 12, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Preview
//struct MyShowsAnalyticsScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        MyShowsAnalyticsScreen(showId: .constant("1"))
//    }
//}
