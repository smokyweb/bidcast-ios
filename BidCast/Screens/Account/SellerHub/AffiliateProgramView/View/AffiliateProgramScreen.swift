//
//  MyOrdersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//
import SwiftUI
import SVProgressHUD
import AlertToast

// MARK: - ReferralStats
struct ReferralStats {
    var totalReferrals: Int = 0
    var earnings: Double = 0.0
}

// MARK: - AffiliateProgramScreen
struct AffiliateProgramScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = AffiliateProgramViewModel()
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    
    @State var referralCode: String = ""
    @State var stats: ReferralStats
    var onShare: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            PrimaryHeader(
                title: "Affiliate Program",
                leadingImgArr: [.icBack],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 50)
            .background(Color.white)
            .zIndex(1)

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Earn $100 Per Referral")
                            .font(.title2)
                            .bold()
                        Text("Invite sellers and earn rewards when they succeed")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    ReferralCodeCardView(code: referralCode, onShare: onShare)

                    // 🔥 Share + Copy Buttons
                    HStack(spacing: 16) {
                        Button(action: {
                            let message = "Join with my referral code: \(referralCode)"
                            let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Invite")
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }

                        Button(action: {
                            UIPasteboard.general.string = referralCode
                            hudMsg = "Code copied!"
                            showhud = true
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Code")
                            }
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }

                    RewardInfoCardView()
                    ReferralStatsView(stats: stats)
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            UIScrollView.appearance().bounces = false
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onFirstAppear {
            Task {
                SVProgressHUD.show()
                await viewModel.getReferralCode()
                await SVProgressHUD.dismiss()
                await getReferralSuccess()
            }
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }

    func getReferralSuccess() {
        guard let data = viewModel.referralResponse.data else { return }
        referralCode = data.referralCode ?? ""
        stats.earnings = data.totalEarnings ?? 0.0
        stats.totalReferrals = data.totalReferred ?? 0
    }
}
