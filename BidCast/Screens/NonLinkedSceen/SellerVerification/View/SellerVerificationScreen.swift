//
//  SellerVerificationScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

enum VerificationStatus {
    case completed, pending
}

struct SellerVerificationScreen: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            
            // Custom Primary Header
            PrimaryHeader(
                title: "Seller Verification",
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(Color.white)
            .padding(.horizontal)
            .frame(height: 70)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verification Progress")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ProgressView(value: 2, total: 4)
                            .accentColor(.blue)
                        
                        Text("2 of 4")
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)

                    // ID Verification
                    VerificationSectionView(
                        icon: "idcard.fill",
                        title: "ID Verification",
                        subtitle: "Upload your ID card & take a selfie",
                        status: .completed,
                        actions: ["ID Card", "Selfie"]
                    )

                    // Phone Verification
                    VerificationSectionView(
                        icon: "phone.fill",
                        title: "Phone Verification",
                        subtitle: "Verify your phone number",
                        status: .pending,
                        actionLabel: "Verify"
                    )

                    // Payment Method
                    VerificationSectionView(
                        icon: "creditcard.fill",
                        title: "Payment Method",
                        subtitle: "Add your payment details",
                        status: .pending,
                        actionLabel: "Add",
                        showDashedCard: true
                    )

                    // Manual Verification
                    VerificationSectionView(
                        icon: "person.crop.circle.badge.checkmark",
                        title: "Manual Verification",
                        subtitle: "Final review by our team",
                        statusText: "Pending"
                    )
                }
                .padding()
            }

            // Bottom Action Button
            Button(action: {
                print("Complete Verification tapped")
            }) {
                Text("Complete Verification")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .bottom)
    }
}

