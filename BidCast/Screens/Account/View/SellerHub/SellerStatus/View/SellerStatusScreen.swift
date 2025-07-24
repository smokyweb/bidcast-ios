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
                    title: "Seller Status",
                    isForBoth: true,
                    leadingImgArr: [.icBack,.appName],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            
            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 12) {
                    let seller = sellerData.live_sell_vendor
                    let market = sellerData.marketplace_vendor
                    if seller != nil {
                        SellerStatusCardView(title: seller?.title ?? "", status: seller?.status ?? "", icon: "cart.fill", subtitle: seller?.submitted ?? "",statusColor: .darkGreen)
                    }
                    if market != nil {
                        SellerStatusCardView(title: market?.title ?? "", status: market?.status ?? "", icon: "video.fill", subtitle: market?.vendor_since ?? "",statusColor: .darkYellow)
                    }

                    
                    Spacer(minLength: 80)
                }
                //                .padding(.top, 0)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.bg.opacity(0.4))
        
        
        // MARK: - Primary Button fixed at bottom
        VStack(spacing: 0) {
            Divider()
            PrimaryButton(
                title: "Contact Support",
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
}


// MARK: - Preview
