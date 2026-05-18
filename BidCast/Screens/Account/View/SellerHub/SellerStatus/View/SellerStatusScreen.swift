//
//  SellerStatusScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import SVProgressHUD

// MARK: - SellerStatusSection
struct SellerStatusSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: Image
    let statusText: String
    let statusColor: Color
}

// MARK: - SellerStatusScreen
struct SellerStatusScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var navigateToContact = false
    @State var viewModel = SellerStatusViewModel()
    @State var sellerData = SellerDataModel ()
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    var body: some View {
        VStack(spacing: 8){
            VStack {
                // MARK: - Fixed Header
                PrimaryHeader(
                    title: AppString.SellerStatus,
                    isForBoth: false,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .padding(.horizontal, 16)
            }
            
            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 12) {
                    let seller = sellerData.live_sell_vendor
                    let market = sellerData.marketplace_vendor
                    if seller != nil {
                        // MC wave-2 #48: derive color from actual status string
                        SellerStatusCardView(title: seller?.title ?? "", status: seller?.status ?? "", icon: "cart.fill", subtitle: seller?.submitted ?? "", statusColor: statusColor(for: seller?.status))
                    }
                    if market != nil {
                        SellerStatusCardView(title: market?.title ?? "", status: market?.status ?? "", icon: "video.fill", subtitle: market?.vendor_since ?? "", statusColor: statusColor(for: market?.status))
                    }

                    
                    Spacer(minLength: 80)
                }
                .padding(.horizontal, 16)
                //                .padding(.top, 0)
            }
            
            // MARK: - Primary Button fixed at bottom
            VStack(spacing: 0) {
                Divider()
                PrimaryButton(
                    title: AppString.ContactSupport,
                    isOutLine: false,
                    onButtonClick: {
                       navigateToContact = true
                    },
                    btnTextColor: .white
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 0)
                .background(Color(UIColor.systemGroupedBackground))
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.bg.opacity(0.4))
        
        
       
        .onAppear{
            Task{
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await self.viewModel.getSellerStatus()
                await SVProgressHUD.dismiss()
                if self.viewModel.errorMessage == nil || self.viewModel.errorMessage == ""{
                    self.sellerData = viewModel.sellerStatusResponse?.data ?? SellerDataModel()
                }else{
                    
                }
                
            }
        }
        CusNavLink(doNavigate: $navigateToContact, destination: ContactUs())
           
    }

    // MC wave-2 #48: map API status string to a semantic color
    // Backend values seen: "approved", "pending", "rejected", "active", "inactive"
    private func statusColor(for status: String?) -> Color {
        switch status?.lowercased().trimmingCharacters(in: .whitespaces) {
        case "approved", "active", "verified":
            return .green
        case "pending", "processing", "under_review":
            return .orange
        case "rejected", "suspended", "banned":
            return .red
        default:
            return .gray
        }
    }
}


// MARK: - Preview
