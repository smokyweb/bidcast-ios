//
//  SellerStatusScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

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
    var sections: [SellerStatusSection] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // MARK: - Fixed Header
                PrimaryHeader(
                    title: "Seller Status",
                    isForLogo: true,
                    leadingImgArr: [.appName],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .padding(.horizontal)
                .frame(height: 50.0)

                // MARK: - Scrollable Content
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(sections) { section in
                            SellerStatusCardView(section: section)
                        }
                        .padding([.leading, .trailing], 20)

                        Spacer(minLength: 80)
                    }
                    .padding(.top, 0)
                }
            }
            .background(Color.blue.opacity(0.05).ignoresSafeArea())

            // MARK: - Primary Button fixed at bottom
            VStack(spacing: 0) {
                Divider()
                PrimaryButton(
                    title: AppString.submit.localized,
                    isOutLine: false,
                    onButtonClick: {
                        // Action
                    },
                    btnTextColor: .white
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 0)
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
    }
}


// MARK: - Preview
#Preview {
    SellerStatusScreen(sections: [
        SellerStatusSection(
            title: "Marketplace Vendor Status",
            subtitle: "Vendor since Jan 2025\nSeller Rating: 4.8/5",
            icon: Image(systemName: "cart.fill"),
            statusText: "Active",
            statusColor: .green
        ),
        SellerStatusSection(
            title: "Live Sell Vendor Status",
            subtitle: "Application in Review\nSubmitted: Jan 15, 2025",
            icon: Image(systemName: "video.fill"),
            statusText: "Pending",
            statusColor: .orange
        )
    ])
}


