//
//  DomesticShipmentsScreen.swift
//  BidCast
//
//  Created by JamTech on 06/12/25.
//

import SwiftUI

struct DomesticShipmentsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedUnder3oz: Bool = false
    @State private var selected1to5lbs: ShippingMethod? = nil
    @State private var selectedOver5lbs: ShippingMethod? = nil
    @State private var applyToScheduled: Bool = false
    @StateObject private var viewModel = ShippingViewModel()
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false

    
    enum ShippingMethod {
        case firstClass
        case priorityMail
        case flatRate
        case groundAdvantage
    }
    
    var body: some View {
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
                
                Text("Domestic Shipments")
                    .font(.system(size: 20, weight: .bold))
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
                    // Info Banner
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        
                        Text("All orders falling outside of your shipping preferences will default to USPS Ground Advantage. Eligible sellers will default to Media Mail shipping.")
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
                            .stroke(Color.defaultThemeLight, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Under 3 oz Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Eligible Shipments under 3 oz")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        ShippingMethodCard(
                            icon: "envelope.fill",
                            title: "USPS First-Class Mail Letter",
                            description: "For shipments under $20 that weigh 3 oz or less in Trading Card Games, Sports Cards, or Stickers categories. View the full criteria ",
                            linkText: "here",
                            isSelected: selectedUnder3oz == true,
                            selectionType: .toggle
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if selectedUnder3oz == false {
                                    selectedUnder3oz = true
                                } else {
                                    selectedUnder3oz = false
                                }
                            }
                        }
                    }
                    
                    // 1 to 5 lbs Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Domestic Shipments from 1 to 5 lbs")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        ShippingMethodCard(
                            icon: "shippingbox.fill",
                            title: "USPS Priority Mail",
                            description: "Arrives in 1-3 business days. Best for time-sensitive shipments.",
                            linkText: nil,
                            isSelected: selected1to5lbs == .priorityMail,
                            selectionType: .radio
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selected1to5lbs = .priorityMail
                            }
                        }
                        
                        ShippingMethodCard(
                            icon: "cube.box.fill",
                            title: "USPS Flat-Rate Boxes",
                            description: "Ships at a fixed rate within the United States, regardless of weight or distance. ",
                            linkText: "Learn more",
                            isSelected: selected1to5lbs == .flatRate,
                            selectionType: .radio
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selected1to5lbs = .flatRate
                            }
                        }
                    }
                    
                    // Over 5 lbs Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Domestic Shipments over 5 lbs")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        ShippingMethodCard(
                            icon: "shippingbox.fill",
                            title: "USPS Priority Mail",
                            description: "Arrives in 1-3 business days. Best for time-sensitive shipments.",
                            linkText: nil,
                            isSelected: selectedOver5lbs == .priorityMail,
                            selectionType: .radio
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedOver5lbs = .priorityMail
                            }
                        }
                        
                        ShippingMethodCard(
                            icon: "cube.box.fill",
                            title: "USPS Flat-Rate Boxes",
                            description: "Ships at a fixed rate within the United States, regardless of weight or distance. ",
                            linkText: "Learn more",
                            isSelected: selectedOver5lbs == .flatRate,
                            selectionType: .radio
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedOver5lbs = .flatRate
                            }
                        }
                        
                        ShippingMethodCard(
                            icon: "truck.box.fill",
                            title: "USPS Ground Advantage",
                            description: "Best for shipping heavier items that aren't time-sensitive. ",
                            linkText: "Learn more",
                            isSelected: selectedOver5lbs == .groundAdvantage,
                            selectionType: .radio
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedOver5lbs = .groundAdvantage
                            }
                        }
                    }
                }
                .padding(.bottom, 140)
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
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                VStack(spacing: 0) {
                    PrimaryButton(title: "Save",
                                  isOutLine: false,
                                  onButtonClick: {
                        submit()
//                        presentationMode.wrappedValue.dismiss()
                    })
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden,for: .tabBar)
        .bottomSheet(isPresented: $showError, height: screenHeight * 0.35, topBarCornerRadius: 25, showTopIndicator: false,
            onDismiss: {
            if let errorMessage = viewModel.errorMessage {
                showError = false
                viewModel.errorMessage = nil
            }else{
                showError = true
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if let errorMessage = viewModel.errorMessage {
                        showError = false
                        viewModel.errorMessage = nil
                    }else{
                        self.presentationMode.wrappedValue.dismiss()
                        withAnimation {
                            showError = false
                            viewModel.errorMessage = nil
                        }
                    }
                }, onSecondaryClick: {
                    withAnimation {
                        showError = false
                        viewModel.errorMessage = nil
                    }
                })
            .ignoresSafeArea(.keyboard)
        })
    }
    private func shippingTitle(_ method: ShippingMethod?) -> String {
        switch method {
        case .priorityMail:
            return "USPS Priority Mail"
        case .flatRate:
            return "USPS Flat-Rate Boxes"
        case .groundAdvantage:
            return "USPS Ground Advantage"
        case .firstClass:
            return "USPS First-Class Mail Letter"
        case .none:
            return ""
        }
    }
    
    func submit() {
        Task {
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    let errorMessage = viewModel.errorMessage
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                },
                onSuccess: {
                    print("✅ Saved successfully")
                    presentationMode.wrappedValue.dismiss()
                }
            ) {
                
                let request = SaveDomesticShipmentRequest(
                    domesticShipmentForm1To5Lbs: shippingTitle(selected1to5lbs),
                    domesticShipmentOver5Lbs: shippingTitle(selectedOver5lbs),
                    alsoApplyScheduleShow: applyToScheduled,
                    uspsFirstClassMailLetter: selectedUnder3oz,
                    id: 2
                )
                
                try await viewModel.SaveDomesticShipmentFile(request: request)
            }
        }
    }
}

// MARK: - Shipping Method Card
struct ShippingMethodCard: View {
    let icon: String
    let title: String
    let description: String
    let linkText: String?
    let isSelected: Bool
    let selectionType: SelectionType
    let action: () -> Void
    
    enum SelectionType {
        case radio
        case toggle
    }
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(alignment: .top, spacing: 16) {
                // USPS Logo/Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.defaultThemeLight)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.defaultTheme)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    descriptionView
                }
                
                Spacer()
                
                // Selection Indicator
                selectionIndicator
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.defaultTheme.opacity(0.4) : Color.gray.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var selectionIndicator: some View {
        switch selectionType {
        case .radio:
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
            
        case .toggle:
            Toggle("", isOn: .constant(isSelected))
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .disabled(true)
                .allowsHitTesting(false)
        }
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        if let linkText = linkText {
            (
                Text(description)
                    .foregroundColor(.secondary)
                +
                Text(linkText)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                +
                Text(".")
                    .foregroundColor(.secondary)
            )
            .font(.system(size: 14))
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Alternative Version with Actual Images
struct DomesticShipmentsEnhancedScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedUnder3oz: Bool = false
    @State private var selected1to5lbs: ShippingMethod = .priorityMail
    @State private var selectedOver5lbs: ShippingMethod = .groundAdvantage
    @State private var applyToScheduled: Bool = false
    
    enum ShippingMethod {
        case priorityMail
        case flatRate
        case groundAdvantage
    }
    
    var body: some View {
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
                
                Text("Domestic Shipments")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.left")
                    .font(.custom(poppinsBold, size: 16))
                    .opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Info Banner
                    InfoBanner(
                        message: "All orders falling outside of your shipping preferences will default to USPS Ground Advantage. Eligible sellers will default to Media Mail shipping."
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Under 3 oz Section
                    ShippingSection(
                        title: "Eligible Shipments under 3 oz",
                        methods: [
                            ShippingMethodData(
                                icon: "envelope.fill",
                                title: "USPS First-Class Mail Letter",
                                description: "For shipments under $20 that weigh 3 oz or less in Trading Card Games, Sports Cards, or Stickers categories. View the full criteria ",
                                linkText: "here",
                                isSelected: selectedUnder3oz,
                                selectionType: .toggle,
                                action: {
                                    selectedUnder3oz.toggle()
                                }
                            )
                        ]
                    )
                    
                    // 1 to 5 lbs Section
                    ShippingSection(
                        title: "Domestic Shipments from 1 to 5 lbs",
                        methods: [
                            ShippingMethodData(
                                icon: "shippingbox.fill",
                                title: "USPS Priority Mail",
                                description: "Arrives in 1-3 business days. Best for time-sensitive shipments.",
                                linkText: nil,
                                isSelected: selected1to5lbs == .priorityMail,
                                selectionType: .radio,
                                action: {
                                    selected1to5lbs = .priorityMail
                                }
                            ),
                            ShippingMethodData(
                                icon: "cube.box.fill",
                                title: "USPS Flat-Rate Boxes",
                                description: "Ships at a fixed rate within the United States, regardless of weight or distance. ",
                                linkText: "Learn more",
                                isSelected: selected1to5lbs == .flatRate,
                                selectionType: .radio,
                                action: {
                                    selected1to5lbs = .flatRate
                                }
                            )
                        ]
                    )
                    
                    // Over 5 lbs Section
                    ShippingSection(
                        title: "Domestic Shipments over 5 lbs",
                        methods: [
                            ShippingMethodData(
                                icon: "shippingbox.fill",
                                title: "USPS Priority Mail",
                                description: "Arrives in 1-3 business days. Best for time-sensitive shipments.",
                                linkText: nil,
                                isSelected: selectedOver5lbs == .priorityMail,
                                selectionType: .radio,
                                action: {
                                    selectedOver5lbs = .priorityMail
                                }
                            ),
                            ShippingMethodData(
                                icon: "cube.box.fill",
                                title: "USPS Flat-Rate Boxes",
                                description: "Ships at a fixed rate within the United States, regardless of weight or distance. ",
                                linkText: "Learn more",
                                isSelected: selectedOver5lbs == .flatRate,
                                selectionType: .radio,
                                action: {
                                    selectedOver5lbs = .flatRate
                                }
                            ),
                            ShippingMethodData(
                                icon: "truck.box.fill",
                                title: "USPS Ground Advantage",
                                description: "Best for shipping heavier items that aren't time-sensitive. ",
                                linkText: "Learn more",
                                isSelected: selectedOver5lbs == .groundAdvantage,
                                selectionType: .radio,
                                action: {
                                    selectedOver5lbs = .groundAdvantage
                                }
                            )
                        ]
                    )
                }
                .padding(.bottom, 140)
            }
            .background(Color(.systemGroupedBackground))
            
            // Bottom Section
            VStack(spacing: 16) {
                Divider()
                
                // Checkbox
                CheckboxRowView(
                    text: "Also apply to scheduled shows",
                    isChecked: $applyToScheduled
                )
                .padding(.horizontal, 20)
                
                // Save Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.yellow)
                        )
                        .shadow(color: Color.yellow.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Supporting Components

struct InfoBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            Text(message)
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
                .stroke(Color.defaultThemeLight, lineWidth: 1)
        )
    }
}

struct ShippingMethodData {
    let icon: String
    let title: String
    let description: String
    let linkText: String?
    let isSelected: Bool
    let selectionType: ShippingMethodCard.SelectionType
    let action: () -> Void
}

struct ShippingSection: View {
    let title: String
    let methods: [ShippingMethodData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            ForEach(methods.indices, id: \.self) { index in
                ShippingMethodCard(
                    icon: methods[index].icon,
                    title: methods[index].title,
                    description: methods[index].description,
                    linkText: methods[index].linkText,
                    isSelected: methods[index].isSelected,
                    selectionType: methods[index].selectionType,
                    action: methods[index].action
                )
            }
        }
    }
}

struct CheckboxRowView: View {
    let text: String
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isChecked.toggle()
            }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isChecked ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isChecked {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.defaultTheme)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(text)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview
struct DomesticShipmentsScreen_Previews: PreviewProvider {
    static var previews: some View {
        DomesticShipmentsEnhancedScreen()
    }
}
