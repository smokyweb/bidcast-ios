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
    @State private var selectedScale: String = "select scale"
    @State private var maxItemsEnabled: Bool = false
    @State private var additionalWeightEnabled: Bool = false
    @State private var showScaleOptions: Bool = false
    @State private var showboxScaleOptions: Bool = false
    @State private var showincrementScaleOptions: Bool = false

       
    
    
    
    @State private var maxItemsCount: String = ""
    @State private var boxLength: String = "12"
    @State private var boxWidth: String = "12"
    @State private var boxHeight: String = "12"
    
    @State private var incrementweightscale: String = "Pound"
    @State private var boxscale: String = "Inch"

    
    @State private var incrementalWeight: String = ""
//    @State private var selectedWeightScale: String = "Pound"
    @State private var showWeightScaleSheet: Bool = false

    var selectedProfile:StoreShippingModel?
    var nameVal, sizeVal: String?
    var weightVal: String?
    var shippingId: Int?
    var additionalWeight: Bool?
    var maxItems: Bool?
    
    @State private var isEditMode: Bool = false
    
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
    
    let scales = ["Pound","Ounce", "Gram","Kilogram" ]
    let incrementweightscaleotion = ["Pound","Ounce", "Gram","Kilogram" ]
    let boxscaleoption = ["Cm","Feet","Inch","Meter"]

    
    
    @StateObject private var shippingViewModel = ShippingViewModel()
    @State private var uspsPriceLoaded = false
    @State private var showUspsBoxSheet = false

    // Basecamp #9988324984 — USPS package-size preset picker state.
    @State private var selectedPackagePreset: USPSPackagePreset = .custom
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack{
                    
                    PrimaryHeader(
                        title: isEditMode ? "Edit Shipping Profile" : "Create Shipping Profile".localized,
                        isForLogo : false, leadingImgArr: ["chevron.left"],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                    
                }
                .frame(height: 50)
                .background(Color.white)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Details Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Details")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                            
                            // Name Field
                            VStack(spacing: 8) {
                                AuthTextField(floatingLabel: "",
                                              placeholder: "Enter Name",
                                              icon: .addresses,
                                              text: $name ,
                                              isIconDisplay : false,
                                              custFontName : poppinsMedium,
                                              custFontSize : 14.0,
                                              enteredText:  { val in
                                    name = val
                                })
                            }
                            
                            HStack(spacing: 4) {
                                // Weight Field
                                VStack(spacing: 8) {
                                    AuthTextField(floatingLabel: "",
                                                  placeholder: "Weight",
                                                  icon: .addresses,
                                                  text: $weight ,
                                                  isIconDisplay : false,
                                                  custFontName : poppinsMedium,
                                                  custFontSize : 14.0,
                                                  enteredText:  { val in
                                        weight = val
                                    })
                                    .keyboardType(.decimalPad)
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
                                    .cornerRadius(32)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                }
                                .padding(.trailing, 16)
                            }
                            
                            // Info Box
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.defaultTheme)
                                    
                                
                                Text("Please enter the weight of this item and packaging")
                                    .font(.custom(poppinsRegular, size: 13.0))
                                    .foregroundColor(.darkGray)
//                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.all,4)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.defaultTheme.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.defaultThemeLight, lineWidth: 1)
                            )
                            .padding(.horizontal,12)
                        }
//                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Bundling Options Section
                        // MARK: - Bundling Options
                        VStack(alignment: .leading, spacing: 16) {

                            HStack {
                                Text("Bundling Options")
                                    .font(.custom(poppinsBold, size: 20.0))

                                Spacer()

                                Button("Learn More") {
                                    // action
                                }
                                .foregroundColor(.blue)
                                .font(.system(size: 14, weight: .semibold))
                            }

                            // ✅ MAX ITEMS TOGGLE
                            VStack(alignment: .leading, spacing: 12) {

                                Toggle(isOn: $maxItemsEnabled) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Set the maximum number of items to put into one package")
                                            .font(.custom(poppinsSemiBold, size: 16.0))

                                        Text("Recommended for items that are unusually sized fragile, or you prefer to ship individually.")
                                            .font(.custom(poppinsRegular, size: 13.0))
                                            .foregroundColor(.darkGray)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .defaultTheme))

                                // ✅ SHOW WHEN ENABLED
                                if maxItemsEnabled {

                                    // Max items field
                                    AuthTextField(
                                        floatingLabel: "",
                                        placeholder: "Max # of items in one box",
                                        icon: .addresses,
                                        text: $maxItemsCount,
                                        isIconDisplay: false,
                                        custFontName: poppinsMedium,
                                        custFontSize: 14
                                    )
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal,-12)

                                    Text("For cost-effective bundling, we recommend setting the quantity based on box sizes smaller than 1 cubic foot.")
                                        .font(.custom(poppinsRegular, size: 13.0))
                                        .foregroundColor(.darkGray)

                                    // MARK: Box Dimensions

                                    Text("Box Dimensions")
                                        .font(.custom(poppinsSemiBold, size: 16.0))

                                    // Basecamp #9988324984 — USPS package-size preset picker.
                                    // Selecting a preset fills boxLength/boxWidth/boxHeight and
                                    // sets boxscale to "Inch". Fields remain editable afterwards.
                                    USPSPackagePresetPicker(selectedPreset: $selectedPackagePreset)
                                        .onChange(of: selectedPackagePreset) { newPreset in
                                            guard newPreset != .custom else { return }
                                            let fmt: (Double) -> String = { v in
                                                v.truncatingRemainder(dividingBy: 1) == 0
                                                    ? String(format: "%.0f", v)
                                                    : String(format: "%g", v)
                                            }
                                            boxLength = fmt(newPreset.length)
                                            boxWidth  = fmt(newPreset.width)
                                            boxHeight = fmt(newPreset.height)
                                            boxscale  = USPSPackagePreset.unitLabel
                                        }

                                    Button {
                                        showUspsBoxSheet = true
                                    } label: {
                                        HStack {
                                            Text("Select a Box Size (Optional)")
                                                .font(.custom(poppinsRegular, size: 13.0))
                                                .foregroundColor(.darkGray)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.black)
                                        }
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(30)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .stroke(Color.gray.opacity(0.2))
                                        )
                                    }

                                    // Dimensions grid
                                    HStack(spacing: 4) {
                                        AuthTextField(
                                            floatingLabel: "",
                                            placeholder: "Length",
                                            icon: .addresses,
                                            text: $boxLength,
                                            isIconDisplay: false,
                                            custFontName: poppinsMedium,
                                            custFontSize: 14
                                        )
                                        .padding(.horizontal,-12)

                                        AuthTextField(
                                            floatingLabel: "",
                                            placeholder: "Width",
                                            icon: .addresses,
                                            text: $boxWidth,
                                            isIconDisplay: false,
                                            custFontName: poppinsMedium,
                                            custFontSize: 14
                                        )
                                        .padding(.horizontal,-12)
                                    }

                                    HStack(spacing: 4) {
                                        AuthTextField(
                                            floatingLabel: "",
                                            placeholder: "Height",
                                            icon: .addresses,
                                            text: $boxHeight,
                                            isIconDisplay: false,
                                            custFontName: poppinsMedium,
                                            custFontSize: 14
                                        )
                                        .padding(.horizontal,-12)
                                    

//                                        Scale Selector
                                        Button(action: {
                                            showboxScaleOptions.toggle()
                                            UIApplication.shared.dismissKeyboard()
                                        }) {
//                                            HStack {
                                                Text(boxscale)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding()
                                            .background(Color(.systemBackground))
                                            .cornerRadius(32)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 32)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
//                                        }
//                                        .padding(.horizontal,-12)
                                        // Scale selector
                                      
                                    }
                                }
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemBackground))
                            )

                            // ✅ ADDITIONAL WEIGHT TOGGLE
                            VStack(alignment: .leading, spacing: 12) {

                                Toggle(isOn: $additionalWeightEnabled) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Set a fixed weight for additional items in the same package")
                                            .font(.custom(poppinsSemiBold, size: 16.0))

                                        Text("Select an incremental weight for any additional items eligible for bundling")
                                            .font(.custom(poppinsRegular, size: 13.0))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .defaultTheme))

                                // ✅ SHOW WHEN ENABLED
                                if additionalWeightEnabled {

                                    HStack(spacing: 4) {

                                        AuthTextField(
                                            floatingLabel: "",
                                            placeholder: "Incremental Weight",
                                            icon: .addresses,
                                            text: $incrementalWeight,
                                            isIconDisplay: false,
                                            custFontName: poppinsMedium,
                                            custFontSize: 14
                                        )
                                        .padding(.horizontal,-12)

//                                        Scale Selector
                                        Button(action: {
                                            showincrementScaleOptions.toggle()
                                            UIApplication.shared.dismissKeyboard()
                                        }) {
//                                            HStack {
                                                Text(incrementweightscale)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding()
                                            .background(Color(.systemBackground))
                                            .cornerRadius(32)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 32)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                                        }
                                        .padding(.horizontal,-12)
                                    
                                }
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemBackground))
                            )
                        }
                        .padding(.horizontal, 12)

                    }
                }
                .background(Color(.backGround))
                
                // Bottom Button
                VStack(spacing: 0) {
                    PrimaryButton(title: isEditMode ? "Update Profile" : "Save Profile",
                                  isOutLine: false,
                                  onButtonClick: {
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
                                    additionalWeight: additionalWeightEnabled,
                                    shippingId: isEditMode ? shippingId : nil
                                )
                                
                                
                            } catch {
                                print("Shipping creation failed:", error)
                                config = BottomSheetConfig(
                                    icon: "exclamationmark.circle",
                                    title: "Error",
                                    message: errorDesc(error: error, message: shippingViewModel.errorMessage),
                                    primaryButtonTitle: AppString.ok.localized,
                                    secondaryButtonTitle: nil
                                )
                                showError = true
                            }
                        }
                    })
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))
            }
            .navigationBarHidden(true)
            .onAppear {
                isEditMode = shippingId != nil
                name = nameVal ?? ""
                weight = weightVal ?? ""

                if let profile = selectedProfile {
                    selectedScale = profile.size ?? selectedScale
                    maxItemsCount = profile.maxItemUnit ?? ""
                    boxLength = profile.length ?? ""
                    boxWidth = profile.width ?? ""
                    boxHeight = profile.height ?? ""
                    incrementweightscale = profile.incrementWeightScale ?? incrementweightscale
                    boxscale = profile.scale ?? boxscale
                    incrementalWeight = profile.incrementWeight ?? ""
                }

                maxItemsEnabled = maxItems ?? false
                additionalWeightEnabled = additionalWeight ?? false

                // Fetch USPS shipping prices once (endpoint requires auth).
                if !uspsPriceLoaded {
                    uspsPriceLoaded = true
                    Task {
                        do {
                            try await shippingViewModel.getUspsShippingPrice()
                        } catch {
                            // Don't block profile creation; endpoint may be unavailable.
                            print("USPS price fetch failed:", error.localizedDescription)
                        }
                    }
                }
            }
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
        
        .sheet(isPresented: $showboxScaleOptions) {
            ScaleSelectionSheet(selectedScale: $boxscale, isPresented: $showboxScaleOptions, scales: boxscaleoption)
        }
        .sheet(isPresented: $showincrementScaleOptions) {
            ScaleSelectionSheet(selectedScale: $incrementweightscale, isPresented: $showincrementScaleOptions, scales: incrementweightscaleotion)
        }
        .sheet(isPresented: $showUspsBoxSheet) {
            UspsBoxSelectionSheet(
                isPresented: $showUspsBoxSheet,
                items: shippingViewModel.uspsShippingPriceResponse?.data ?? [],
                onSelect: { item in
                    boxLength = item.length ?? ""
                    boxWidth = item.width ?? ""
                    boxHeight = item.height ?? ""
                    boxscale = (item.unit ?? "").capitalizingFirstLetter()
                }
            )
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
        maxItems: Bool,
        additionalWeight: Bool,
        shippingId: Int? = nil
    ) async throws {
        let defaultSuccessMessage: String = isEditMode ? "Shipping profile Updated successfully." : "Shipping profile created successfully."
        await performAPICalls(
            isConcurrent: false,
            showLoader: true,
            onError: { (error: Error) in
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
                config = BottomSheetConfig(
                    icon: "checkmark.circle.fill",
                    title: "Success",
                    message: shippingViewModel.storeShippingResponse?.message ?? defaultSuccessMessage,
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil,
                    bottomPadding: -60,
                    backgroundDismissal: true
                )
                showSuccess = true
            },
            tasks: { () async throws -> Void in   // ⭐⭐⭐ MOST IMPORTANT FIX
                let request = StoreShippingRequest(
                    name: name,
                    size: scale.lowercased(),
                    weight: weight.formattedString(decimalPlaces: 2),
                    maxItems: maxItems,
                    additionalWeight: additionalWeight,
                    length: boxLength,
                    height: boxHeight,
                    width: boxWidth,
                    incrementWeight: incrementalWeight,
                    incrementWeightScale: incrementweightscale.lowercased(),
                    scale: boxscale.lowercased(),
                    maxItemUnit: maxItemsCount,
                    shippingProfileId: isEditMode ? shippingId : nil
                )

                try await shippingViewModel.storeShippingProfile(request: request)
            }
        )

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

private struct UspsBoxSelectionSheet: View {
    @Binding var isPresented: Bool
    let items: [UspsShippingPriceModel]
    let onSelect: (UspsShippingPriceModel) -> Void

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 12)

            HStack {
                Text("Select USPS Package")
                    .font(.custom(poppinsSemiBold, size: 18))
                    .foregroundColor(.black)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            if items.isEmpty {
                VStack(spacing: 10) {
                    Text("No USPS packages found.")
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(items, id: \.id) { item in
                            Button {
                                onSelect(item)
                                isPresented = false
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name ?? "USPS Package")
                                                .font(.custom(poppinsSemiBold, size: 14))
                                                .foregroundColor(.black)
                                                .lineLimit(2)
                                            Text(item.type ?? "")
                                                .font(.custom(poppinsRegular, size: 12))
                                                .foregroundColor(.darkGray)
                                        }
                                        Spacer()
                                        if let price = item.shippingPrice, !price.isEmpty {
                                            Text("$\(price)")
                                                .font(.custom(poppinsSemiBold, size: 14))
                                                .foregroundColor(.defaultTheme)
                                        }
                                    }

                                    let unit = item.unit ?? ""
                                    let dims = "\(item.length ?? "") × \(item.width ?? "") × \(item.height ?? "") \(unit)"
                                    Text(dims.trimmingCharacters(in: .whitespaces))
                                        .font(.custom(poppinsRegular, size: 12))
                                        .foregroundColor(.gray)

                                    if let gf = item.greatFor, !gf.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text(gf.replacingOccurrences(of: "\r\n", with: ", "))
                                            .font(.custom(poppinsRegular, size: 12))
                                            .foregroundColor(.gray)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .presentationDetents([.fraction(0.65)])
        .presentationDragIndicator(.visible)
        .background(Color(.systemGroupedBackground))
    }
}
