//
//  FreeShippingView.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//

import SwiftUI
import SVProgressHUD

// MARK: - Free Pickup Screen
struct FreePickupScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var isFreePickupEnabled: Bool = false
    @StateObject var viewModel = PreferenceViewModel()
    @State var sampleAddresses = [AddressModel]()
    @State var freePickupAddresses = UpdatePreferenceRequest()
    @State private var showAddressSheet: Bool = false

    
    @State private var showError: Bool = false
    @State private var pickupAddressId: String = ""
    @State private var instructions: String = ""
    @State private var selectedAddressText: String = ""

    
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
    
//    private var isSaveEnabled: Bool {
//        isFreePickupEnabled && !pickupAddress.isEmpty && !instructions.isEmpty
//    }
//    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            headerView
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // MARK: Toggle Section
                    toggleSection
                    
                    Divider().opacity(0.2)
                    if isFreePickupEnabled{
                        // MARK: Location Section
                        locationSection
                        
                        Divider().opacity(0.2)
                        
                        // MARK: Instructions Section
                        instructionSection
                        
                        // MARK: Bottom Info Card
                        bottomInfoCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            
            // MARK: Save Button
            saveButton
        }
        .background(Color(.backGround).ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await GetAddress()
            }
        }

    }
    
    @MainActor
    func GetAddress() async {
        SVProgressHUD.show()
        
        await viewModel.getAddresses()
        
        await SVProgressHUD.dismiss()
        
        let response = viewModel.getAddressDict
        if response.status == "success" {
            sampleAddresses = response.data ?? []
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
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
                        icon: "exclamationmark.circle",
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
                let freePickupAddresses = UpdatePreferenceRequest(
                    free_shipping: isFreePickupEnabled, shipping_address_id: pickupAddressId, instruction: instructions
                    
                )
                await viewModel.updatePreference(parameters: freePickupAddresses)
            }
        }
    }
}

private extension FreePickupScreen {
    var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Spacer()
            
            Text("Free Pickup")
                .foregroundColor(.black)
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            
            Image(systemName: "chevron.left")
                .opacity(0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }

}

private extension FreePickupScreen {
    var toggleSection: some View {
        Toggle(isOn: $isFreePickupEnabled) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Enable Free Pickup")
                    .foregroundColor(.black)
                    .font(.system(size: 17, weight: .semibold))
                
                Text("Allow buyers to pick up any order from an address of your choice.")
                    .foregroundColor(.gray)
                    .font(.system(size: 13))
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: .defaultTheme))
    }

}

private extension FreePickupScreen {
    var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Location")
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .bold))
            
            Text("Ensure that your pickup location is safe and easily accessible for both you and your buyers.")
                .foregroundColor(.gray)
                .font(.system(size: 13))
            
            // ✅ Dropdown Field
            Button {
                showAddressSheet = true
            } label: {
                HStack {
                    Text(selectedAddressText.isEmpty ? "Pickup Address" : selectedAddressText)
                        .foregroundColor(selectedAddressText.isEmpty ? .gray : .black)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.35))
                )
                .cornerRadius(12)
            }
            
            // Note box
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.gray)
                
                Text("Note: this address will be visible to viewers within shows when Free Pickup is enabled.")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showAddressSheet) {
            addressPickerSheet
        }
    }

    var addressPickerSheet: some View {
        NavigationView {
            List(sampleAddresses, id: \.id) { address in
                Button {
                    // ✅ SAVE ID
                    pickupAddressId = "\(address.id ?? 0)"
                    
                    // ✅ SHOW STREET
                    selectedAddressText = address.street_address ?? ""
                    
                    showAddressSheet = false
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(address.street_address ?? "")
                                .foregroundColor(.black)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text(address.pincode ?? "")
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                        }
                        
                        Spacer()
                        
                        if pickupAddressId == "\(address.id ?? 0)" {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Select Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        showAddressSheet = false
                    }
                }
            }
        }
    }


}

private extension FreePickupScreen {
    var instructionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("Instructions")
                .foregroundColor(.black)
                .font(.system(size: 18, weight: .bold))
            
            Text("Let buyers know when to show up and how to reach you. Consider offering specific pickup time windows.")
                .foregroundColor(.gray)
                .font(.system(size: 13))
            
            ZStack(alignment: .topLeading) {
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.35))
                    .frame(height: 140)
                    .background(Color.white.cornerRadius(12))
                
                TextEditor(text: $instructions)
                    .padding(8)
                    .frame(height: 140)
                
                if instructions.isEmpty {
                    Text("Instructions (0/250) *")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
        }
    }

}

private extension FreePickupScreen {
    var bottomInfoCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .foregroundColor(.black)
            
            Text("These pickup settings will apply to future and already scheduled shows.")
                .foregroundColor(.black)
                .font(.system(size: 13))
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }

}


private extension FreePickupScreen {
    var saveButton: some View {
        Button {
            // call API
            updateFreePickup()
            print("button click")
        } label: {
            Text("Save")
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.defaultTheme)
                .cornerRadius(28)
        }
//        .disabled(!isFreePickupEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color.white)
    }

}
