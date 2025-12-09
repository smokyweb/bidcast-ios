//
//  FreeShippingView.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//

import SwiftUI

// MARK: - Free Pickup Screen
struct FreePickupScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isFreePickupEnabled: Bool = false
    @StateObject var viewModel = PreferenceViewModel()
    
    @State private var showError: Bool = false
    
    var changeFreeToggle: ((Bool) -> Void) = {_ in}
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    var body: some View {
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
                
                Text("Free Pickup")
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
                VStack(spacing: 24) {
                    // Toggle Card
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle(isOn: $isFreePickupEnabled) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Enable Free Pickup")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Allow buyers to pick up any order from an address of your choice")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFreePickupEnabled ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: isFreePickupEnabled ? 2 : 1)
                                .animation(.easeInOut(duration: 0.2), value: isFreePickupEnabled)
                        )
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            
            // Save Button
            VStack(spacing: 0) {
                Divider()
                
                Button(action: {
                   updateFreePickup()
                }) {
                    Text("Save")
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
            .background(Color(.systemBackground))
        }
        .overlay(
            CustomBottomSheetView(
                isPresented: $showError,
                config: config,
                primaryAction: {
                    withAnimation {
                        showError = false
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showError = false
                    }
                }
            )
        )
        .navigationBarHidden(true)
        .toolbar(.hidden,for: .tabBar)
    }
}

extension FreePickupScreen {
    private func updateFreePickup() {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.triangle.fill",
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showError = true
                },
                onSuccess: {
                    let message = viewModel.preferenceResponse.message ?? ""
                    hudMsg  = message
                    showhud = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showhud = true
                        presentationMode.wrappedValue.dismiss()
                        changeFreeToggle(isFreePickupEnabled)
                    }
                }
            ) {
                let request = UpdatePreferenceRequest(
                    free_shipping: isFreePickupEnabled
                )
                await viewModel.updatePreference(parameters: request)
            }
        }
    }
}
