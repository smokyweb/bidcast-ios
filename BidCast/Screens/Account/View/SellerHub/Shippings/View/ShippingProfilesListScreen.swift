//
//  ShippingProfilesListScreen.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//
//
import SwiftUI

struct ShippingProfile: Hashable {
    var name: String
    var weight: Int
    var scale: String
    var maxItems: Bool
    var additionalWeight: Bool
}


// MARK: - Shipping Profiles List Screen
struct ShippingProfilesListScreen: View {
    @State private var profiles: [ShippingProfile] = [
        ShippingProfile(name: "My new shipping", weight: 25, scale: "Pound", maxItems: false, additionalWeight: false)
    ]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showCreateProfile = false
    
    @State private var profiles1: [StoreShippingModel] = []
    @StateObject private var shippingViewModel = ShippingViewModel()
    
    @State var showhud: Bool = false
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
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Shipping Profiles")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible placeholder for alignment
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(profiles, id: \.self) { profile in
                            ShippingProfileCard(profile: profile)
                        }
                    }
                    .padding(20)
                }
                .background(Color(.systemGroupedBackground))
                
                // Bottom Button
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        showCreateProfile = true
                    }) {
                        Text("Create Shipping Profile")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .onAppear {
                    getShippingProfiles()
                }
                .background(Color(.systemBackground))
                NavigationLink(destination: CreateShippingProfileScreen().navigationBarBackButtonHidden(true), isActive: $showCreateProfile) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - API Calls
extension ShippingProfilesListScreen {
    private func getShippingProfiles()  {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.triangle.fill",
                        title: "Error",
                        message: errorDesc(error: error, message: shippingViewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showError = true
                },
                onSuccess: {
                    self.profiles1 = shippingViewModel.getShippingProfilesResponse?.data ?? []
                }
            ) {
                try await shippingViewModel.getShippingProfiles()
            }
        }
    }
}


// MARK: - Shipping Profile Card
struct ShippingProfileCard: View {
    let profile: ShippingProfile
    @State private var isPressed = false
    
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
            VStack(alignment: .leading, spacing: 12) {
                Text(profile.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("\(profile.weight)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Scale:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(profile.scale)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Set max items per package")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(profile.maxItems ? "Yes" : "No")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Additional weight per item")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(profile.additionalWeight ? "Yes" : "No")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.blue)
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
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
