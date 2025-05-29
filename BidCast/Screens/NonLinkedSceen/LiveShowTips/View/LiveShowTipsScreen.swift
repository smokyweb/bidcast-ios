//
//  LiveShowTipsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI

struct LiveTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
}

struct LiveShowTipsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    let currentStep: Int
    let totalSteps: Int
    let tips: [LiveTip]
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            PrimaryHeader(
                title: "Bring in Buyers",
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [.icInfo],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 50)
            .background(Color.white)
            
            Divider()
            
            VStack(spacing: 0) {
                // Step progress
                VStack(alignment: .leading, spacing: 4) {
                    Text("Step \(currentStep) of \(totalSteps)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    ProgressView(value: Float(currentStep), total: Float(totalSteps))
                        .accentColor(.blue)
                        .scaleEffect(x: 1, y: 1.2, anchor: .center)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Tips
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(tips) { tip in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(tip.iconColor.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: tip.icon)
                                            .foregroundColor(tip.iconColor)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tip.title)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Text(tip.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(16)
                            .frame(width: 340)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
            }
            
            // Continue button
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 1.0, green: 0.39, blue: 0.38)) // red tone
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .background(Color(red: 0.93, green: 0.96, blue: 1.0)) // light blue
        .ignoresSafeArea(edges: .bottom)
    }
}
