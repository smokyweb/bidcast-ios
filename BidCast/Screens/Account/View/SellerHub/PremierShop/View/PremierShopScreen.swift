//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//


import SwiftUI
import SVProgressHUD

// MARK: - PremierShopScreen
struct PremierShopScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showError: Bool = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var viewModel = PremierShopViewModel()
    @State private var premierShopData = PremierShopModel()
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            PrimaryHeader(
                title: AppString.PremierShop,
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                count: .constant(0)
            )
            .padding(.horizontal)
            .frame(height: 50)
            .background(Color(.systemBackground))
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: Header Section
                    ZStack(alignment: .top) {
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
                                .font(.custom(poppinsBold, size: 24))
                                .foregroundColor(.white)
                            
                            Text(premierShopData.pageDetails ?? "")
                                .font(.custom(poppinsRegular, size: 14))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .padding(.bottom, 80)
                        .frame(maxWidth: .infinity, minHeight: 220)
                        .background(.darkRed)
//                        .background(
//                            LinearGradient(colors: [Color.defaultTheme.opacity(0.9), Color.darkRed],
//                                           startPoint: .top, endPoint: .bottom)
//                        )
                        
                        // Shop Status Card
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
                                
                                VStack(alignment: .leading) {
                                    Text(premierShopData.shopTitle ?? "")
                                        .font(.custom(poppinsSemiBold, size: 16))
                                    Text(premierShopData.shopDetails ?? "")
                                        .font(.custom(poppinsRegular, size: 14))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            
                            HStack {
                                if let options = premierShopData.shopOptions {
                                    MetricView(title: "Rating", value: String(format: "%.1f", options.rating))
                                    MetricView(title: "Response", value: options.response)
                                    MetricView(title: "Delivery", value: options.delivery)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        .offset(y: 150)
                    }
                    .padding(.bottom, 50)
                    
                    // MARK: Benefits Grid
                    if let features = premierShopData.features {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppString.PremierBenefits)
                                .font(.custom(poppinsSemiBold, size: 18))
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(features, id: \.title) { feature in
                                    BenefitView(benefit: feature)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: Requirements
                    if let requirements = premierShopData.requirements {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(AppString.Requirements)
                                .font(.custom(poppinsSemiBold, size: 18))
                            
                            ForEach(requirements, id: \.platform) { req in
                                RequirementView(requirement: req)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: Review Process
                    VStack(alignment: .leading, spacing: 12) {
                        Text(AppString.ReviewProcess)
                            .font(.custom(poppinsSemiBold, size: 18))
                        
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
                            .progressViewStyle(LinearProgressViewStyle(tint: .darkRed))
                            
                            Text("Next review in \(premierShopData.nextReview ?? "0") days")
                                .font(.custom(poppinsRegular, size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // MARK: Apply Button
                    Button(action: {
                        // TODO: Apply for Premier Status action
                    }) {
                        Text(AppString.ApplyForPremierStatus)
                            .foregroundColor(.white)
                            .font(.custom(poppinsMedium, size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.darkRed)
                            .cornerRadius(12)
                    }
                    .padding()
                }
                .padding(.top)
            }
        }
        .onFirstAppear {
            Task { await loadData() }
        }
    }
    
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

