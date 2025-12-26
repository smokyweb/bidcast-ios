//
//  ShippingSettingsScreen.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//

import SwiftUI

// MARK: - Enhanced Version with More Details
struct ShippingSettingsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isFreePickupEnabled: Bool = false
    @State private var selectedDomesticMethods: String = "USPS Priority Mail and 1 other"
    @State private var selectedShippingCost: String = "Buyer pays all shipping costs"
    @State private var savedProfilesCount: Int = 0
    @State private var navigateToFreePickup = false
    @State private var navigateToDomestic = false
    @State private var navigateToShippingCosts = false
    @State private var navigateToProfiles = false
    
    var body: some View {
        NavigationView {
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
                    
                    Text("Shipping")
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
                
                // MARK: - Content
                ScrollView {
                    VStack(spacing: 16) {
                        ShippingOptionCard(
                            icon: "mappin.and.ellipse",
                            iconColor: .green,
                            title: "Free Pickup",
                            badge: "New",
                            subtitle: "Allow buyers to pick up any order from a specified address.",
                            status: isFreePickupEnabled ? "ON" : "OFF",
                            freePickup: true) {
                                navigateToFreePickup = true
                            }
                        
                        ShippingOptionCard(
                            icon: "shippingbox.fill",
                            iconColor: .orange,
                            title: "Domestic Shipments",
                            badge: nil,
                            subtitle: "Customize your default shipping options.",
                            status: selectedDomesticMethods ) {
                                navigateToDomestic = true
                            }
                        
                        ShippingOptionCard(
                            icon: "dollarsign.circle.fill",
                            iconColor: .blue,
                            title: "Shipping Costs",
                            badge: nil,
                            subtitle: "Offer reduced or free shipping to buyers. Selections apply to all future shipments.",
                            status: selectedShippingCost ) {
                                navigateToShippingCosts = true
                            }
                        
                        ShippingOptionCard(
                            icon: "doc.text.fill",
                            iconColor: .purple,
                            title: "Shipping Profiles",
                            badge: nil,
                            subtitle: nil,
                            status: "You have \(savedProfilesCount) saved shipping profiles") {
                                navigateToProfiles = true
                            }
                    }
                    .padding(20)
                }
                .background(.backGround)
                // MARK: - Navigation Links
                NavigationLink(destination: FreePickupScreen(changeFreeToggle: { status in
                    isFreePickupEnabled = status
                })) {
                    EmptyView()
                }
                .hidden()
                NavigationLink(destination: DomesticShipmentsScreen(), isActive: $navigateToDomestic) {
                    EmptyView()
                }
                .hidden()
                NavigationLink(destination: ShippingCostsScreen(), isActive: $navigateToShippingCosts) {
                    EmptyView()
                }
                .hidden()
                NavigationLink(destination: ShippingProfilesListScreen().navigationBarBackButtonHidden(true), isActive: $navigateToProfiles) {
                    EmptyView()
                }
                .hidden()
                
            }
            .navigationBarHidden(true)
            .toolbar(.hidden,for: .tabBar)
        }
    }
}

// MARK: - Shipping Option Card Component
struct ShippingOptionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let badge: String?
    let subtitle: String?
    let status: String
    var freePickup: Bool = false
    
    var cardTapped: (() -> Void)? = nil
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with Icon and Title
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.custom(poppinsSemiBold, size: 20))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.primary)
                
                
                Spacer()
            }
            
            // Subtitle
            if let subtitle = subtitle {
                if freePickup {
                    HStack {
                        Text(subtitle)
                            .font(.custom(poppinsRegular, size: 14))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        
                        Text(status)
                            .font(.custom(poppinsMedium, size: 15))
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.secondary)
                            .opacity(0.6)
                    }
                }
                else  {
                    Text(subtitle)
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
            }
            
            // Status Row
            if !freePickup {
                HStack {
                    
                    Text(status)
                        .font(.custom(poppinsMedium, size: 15))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.secondary)
                        .opacity(0.6)
                }
                .padding(.top, 4)
            }
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
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            cardTapped?()
        }
    }
}
