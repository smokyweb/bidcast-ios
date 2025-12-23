//
//  ShippingCostsScreen.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//

import SwiftUI

// MARK: - Shipping Costs Screen
struct ShippingCostsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedOption: ShippingCostOption? = nil
    @State private var applyToScheduled: Bool = false
    
    enum ShippingCostOption {
        case sellerPays
        case buyerPaysSet
        case buyerPaysAll
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                    .font(.custom(poppinsBold, size: 16))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("Shipping Costs")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Info Box
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        
                        Text("Costs calculated based on buyer's location and shipment weight, Only applies to shipments within the contiguous US.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.defaultTheme.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.defaultTheme.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Shipping Options
                    VStack(spacing: 12) {
                        ShippingCostOptionCard(
                            title: "Seller pays all shipping costs",
                            subtitle: "This is only applies to domestic orders. Buyers have to pay for shipping on international orders.",
                            isSelected: selectedOption == .sellerPays
                        ) {
                            selectedOption = .sellerPays
                        }
                        
                        ShippingCostOptionCard(
                            title: "Buyer pays up to a set shipping cost",
                            subtitle: "Set a maximum shipping cost buyers will pay for unlimited orders within your show.",
                            isSelected: selectedOption == .buyerPaysSet
                        ) {
                            selectedOption = .buyerPaysSet
                        }
                        
                        ShippingCostOptionCard(
                            title: "Buyers pay all shipping costs",
                            subtitle: nil,
                            isSelected: selectedOption == .buyerPaysAll
                        ) {
                            selectedOption = .buyerPaysAll
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 120)
            }
            .background(Color(.systemGroupedBackground))
            
            // Bottom Section
            VStack(spacing: 16) {
                Divider()
                
                // Checkbox
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        applyToScheduled.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(applyToScheduled ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
                                .frame(width: 24, height: 24)
                            
                            if applyToScheduled {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.defaultTheme)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text("Also apply to scheduled shows")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                
                // Save Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.defaultTheme.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
        .toolbar(.hidden,for: .tabBar)
    }
}

// MARK: - Shipping Cost Option Card
struct ShippingCostOptionCard: View {
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.defaultTheme)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.defaultTheme.opacity(0.3) : Color.clear, lineWidth: 2)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
