//
//  FreeShippingView.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

// MARK: - Free Pickup Screen
struct FreePickupScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var isFreePickupEnabled: Bool = false
    @StateObject var viewModel = PreferenceViewModel()
    @StateObject var shippingViewModel = ShippingViewModel()
    @State var shippingdeatil = AppSettingDataModel()

    @State var sampleAddresses = [AddressModel]()
    
    @State var freePickupAddresses = UpdatePreferenceRequest()
    @State private var showAddressSheet: Bool = false

    
    @State private var isSaved: Bool = false

    @State private var showError: Bool = false
    @State private var pickupAddressId: String = ""
    @State private var instructions: String = ""
    @State private var selectedAddressText: String = ""
    @State var AlertToastMsg: String = "Please fill in all the credentials"
    
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
    @State var showtoast: Bool = false

    
    @State var hudMsg: String = ""
    
//    private var isSaveEnabled: Bool {
//        isFreePickupEnabled && !pickupAddress.isEmpty && !instructions.isEmpty
//    }
//    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header
            VStack{
                PrimaryHeader(title: "Free Pickup",leadingImgArr: ["chevron.left"],
                              onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },count: .constant(0))
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
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
        .bottomSheet(isPresented: $isSaved, height: screenHeight * 0.35, topBarCornerRadius: 25, showTopIndicator: false,
            onDismiss: {
            if let errorMessage = viewModel.errorMessage {
                isSaved = false
                viewModel.errorMessage = nil
            }else{
                isSaved = true
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if let errorMessage = viewModel.errorMessage {
                        isSaved = false
                        viewModel.errorMessage = nil
                    }else{
                        self.presentationMode.wrappedValue.dismiss()
                        withAnimation {
                            isSaved = false
                            viewModel.errorMessage = nil
                        }
                    }
                }, onSecondaryClick: {
                    withAnimation {
                        isSaved = false
                        viewModel.errorMessage = nil
                        presentationMode.wrappedValue.dismiss()

                    }
                })
            .ignoresSafeArea(.keyboard)
        })
        .toast(isPresenting: $showtoast) {
            AlertToast(displayMode: .hud, type: .regular, title: AlertToastMsg, style: alertStlye)
        }

        .onAppear {
            getFreePickup()
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
    
    private func getFreePickup()  {
        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: false,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.circle",
                        title: "Error",
                        message: errorDesc(error: error, message: shippingViewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showError = true
                },
                onSuccess: {
                    guard let data = shippingViewModel.AppSettingDataResponsedict?.data else { return }
                    
                    self.shippingdeatil = data
                    
                    // ✅ PREFILL UI HERE (after API success)
                    self.isFreePickupEnabled = data.freeShipping ?? false
                    self.pickupAddressId = String(data.shippingAddressId ?? 0)
                    self.instructions = data.instruction ?? ""
                    self.selectedAddressText = data.shippingAddress?.streetAddress ?? ""
                }            ) {
                try await shippingViewModel.getfreepickup()
            }
        }
    }
    
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
//                        presentationMode.wrappedValue.dismiss()
                        changeFreeToggle(isFreePickupEnabled)
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Success",
                            message: "Data Saved Successfully",
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        
                        isSaved = true
                    }
                }
            ) {
                let freeShip = isFreePickupEnabled ? 1 : 0
                let freePickupAddresses = UpdatePreferenceRequest(
                    free_shipping: freeShip, shipping_address_id: pickupAddressId, instruction: instructions
                    
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
                    .font(.custom(poppinsSemiBold, size: 16.0))
                
                Text("Allow buyers to pick up any order from an address of your choice.")
                    .foregroundColor(.gray)
                    .font(.custom(poppinsRegular, size: 13.0))
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
                .font(.custom(poppinsSemiBold, size: 16.0))
            
            Text("Ensure that your pickup location is safe and easily accessible for both you and your buyers.")
                .foregroundColor(.gray)
                .font(.custom(poppinsRegular, size: 13.0))
            
            // ✅ Dropdown Field
            Button {
                showAddressSheet = true
            } label: {
                HStack {
                    Text(selectedAddressText.isEmpty ? "Pickup Address" : selectedAddressText)
                        .foregroundColor(selectedAddressText.isEmpty ? .gray : .black)
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
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
                    .font(.custom(poppinsRegular, size: 11.0))
            }
            .padding(12)
            .background(Color(.defaultThemeLight))
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
                .font(.custom(poppinsSemiBold, size: 16.0))
            
            Text("Let buyers know when to show up and how to reach you. Consider offering specific pickup time windows.")
                .foregroundColor(.gray)
                .font(.custom(poppinsRegular, size: 13.0))
            
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
                        .font(.custom(poppinsRegular, size: 13.0))
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
            if isFreePickupEnabled{
                if  pickupAddressId != "" , instructions != ""{
                    updateFreePickup()
                    
                }
                else {
                    showtoast = true
                }
                
            }
            else {
                updateFreePickup()

            }
            UIApplication.shared.endEditing()

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

