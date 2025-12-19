//
//  CreateShippingProfileScreen.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//

import SwiftUI

// MARK: - Create Shipping Profile Screen
struct CreateShippingProfileScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var weight: String = ""
    @State private var selectedScale: String = "Pound"
    @State private var maxItemsEnabled: Bool = false
    @State private var additionalWeightEnabled: Bool = false
    @State private var showScaleOptions: Bool = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError = false
    @State var showSuccess = false
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    
    let scales = ["Pound", "Kilogram", "Ounce"]
    
    @StateObject private var shippingViewModel = ShippingViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.custom(poppinsBold, size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Create Shipping Profile")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Details Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Details")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            
                            // Name Field
                            VStack(spacing: 8) {
                                TextField("Name", text: $name)
                                    .font(.system(size: 16))
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(name.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.5), lineWidth: name.isEmpty ? 1 : 2)
                                    )
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                            }
                            
                            HStack(spacing: 12) {
                                // Weight Field
                                VStack(spacing: 8) {
                                    TextField("Weight", text: $weight)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 16))
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(weight.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.5), lineWidth: weight.isEmpty ? 1 : 2)
                                        )
                                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                }
                                
                                // Scale Selector
                                Button(action: {
                                    showScaleOptions.toggle()
                                    UIApplication.shared.dismissKeyboard()
                                }) {
                                    HStack {
                                        Text(selectedScale)
                                            .font(.system(size: 16))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                }
                            }
                            
                            // Info Box
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                
                                Text("Please enter the weight of this item and packaging")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Bundling Options Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Bundling Options")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Text("Learn More")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            // Max Items Toggle
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $maxItemsEnabled) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Set the maximum number of items to put into one package")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Recommended for items that are unusually sized fragile , or you prefer to ship individually.")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(maxItemsEnabled ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                                        .animation(.easeInOut(duration: 0.2), value: maxItemsEnabled)
                                )
                            }
                            
                            // Additional Weight Toggle
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $additionalWeightEnabled) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Set a fixed weight for additional items in the same package")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Select an incremental weight for any additional items eligible for bundling")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(additionalWeightEnabled ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                                        .animation(.easeInOut(duration: 0.2), value: additionalWeightEnabled)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
                .background(Color(.systemGroupedBackground))
                
                // Bottom Button
                VStack(spacing: 0) {
                    Divider()
                    Button(action: {
                        UIApplication.shared.dismissKeyboard()
                        if let errorMsg = validateShippingProfile() {
                            // show message
                            hudMsg = errorMsg
                            showhud = true
                            return
                        }
                        
                        Task {
                            do {
                                try await createShippingProfile(
                                    name: name,
                                    weight: Double(weight) ?? 0,
                                    scale: selectedScale,
                                    maxItems: maxItemsEnabled,
                                    additionalWeight: additionalWeightEnabled
                                )
                                
                                
                            } catch {
                                print("Shipping creation failed:", error)
                                config = BottomSheetConfig(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "Error",
                                    message: errorDesc(error: error, message: shippingViewModel.errorMessage),
                                    primaryButtonTitle: AppString.ok.localized,
                                    secondaryButtonTitle: nil
                                )
                                showError = true
                            }
                        }
                    }) {
                        Text("Save Profile")
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
            .navigationBarHidden(true)
        }
        .toolbar(.hidden,for: .tabBar)
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
        .overlay(
            CustomBottomSheetView(
                isPresented: $showSuccess,
                config: config,
                primaryAction: {
                    withAnimation {
                        showSuccess = false
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showSuccess = false
                        // Success
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            )
        )
        .sheet(isPresented: $showScaleOptions) {
            ScaleSelectionSheet(selectedScale: $selectedScale, isPresented: $showScaleOptions, scales: scales)
        }
    }
}

extension CreateShippingProfileScreen {
    private func validateShippingProfile() -> String? {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Please enter profile name"
        }
        
        if weight.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Please enter weight"
        }
        
        if Double(weight) == nil || (Double(weight) ?? 0) <= 0 {
            return "Weight must be greater than 0"
        }
        
        if selectedScale.isEmpty {
            return "Please select a scale"
        }
        
        return nil // VALID
    }
    
    private func createShippingProfile(
        name: String,
        weight: Double,
        scale: String,
        maxItems: Bool?,
        additionalWeight: Bool?
    ) async throws {
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
                config = BottomSheetConfig(
                    icon: "checkmark.circle.fill",
                    title: "Success",
                    message: shippingViewModel.storeShippingResponse?.message ?? "Shipping profile created successfully.",
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil
                )
                showSuccess = true
            }
        ) {
            let request = StoreShippingRequest(
                name: name,
                size: scale,
                weight: weight.formattedString(decimalPlaces: 2)
                //            maxItems: maxItems,
                //            additionalWeight: additionalWeight
            )
            try await shippingViewModel.storeShippingProfile(request: request)
        }
    }
    
}

// MARK: - Scale Selection Sheet
struct ScaleSelectionSheet: View {
    @Binding var selectedScale: String
    @Binding var isPresented: Bool
    let scales: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            VStack(spacing: 20) {
                HStack {
                    Text("Select Scale")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                VStack(spacing: 12) {
                    ForEach(scales, id: \.self) { scale in
                        Button(action: {
                            selectedScale = scale
                            isPresented = false
                        }) {
                            HStack {
                                Text(scale)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedScale == scale {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGroupedBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: -5)
        )
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.hidden)
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Double {
    func formattedString(decimalPlaces: Int = 2) -> String {
        return String(format: "%.2f", self)
    }

}
