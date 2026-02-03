//
//  CreateSurpriseScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/02/26.
//

import SwiftUI
import SVProgressHUD
import AlertToast


struct AddProductRowScreen: View {
    @Environment(\.presentationMode) var presentationMode

    var onCancel : () -> () = { }
    var onAdded : (ProductRow) -> () = {_ in}
    
    @State private var name = ""
    @State private var description = ""
    @State private var quantity = ""
    @State private var showHud = false
    @State private var hudMsg = ""
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    PrimarySheetHeader(title: "Add New Product", onClose: {
                        onCancel()
                    })
                }
                .frame(height: 60)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {

                        AuthTextField(
                            floatingLabel: "Product name",
                            placeholder: "Enter product name".localized,
                            icon: .menuProfile,
                            text: $name,
                            isIconDisplay: false,
                            custFontName: robotoMedium,
                            custFontSize: 14.0
                        )
                        .keyboardType(.alphabet)

                        DescriptionFieldView(
                            description: $description,
                            custFontName: robotoMedium,
                            custFontSize: 14.0
                        ) { message in
                            description = message
                        }

                        AuthTextField(
                            floatingLabel: "Quantity",
                            placeholder: "Enter quantity".localized,
                            icon: .menuProfile,
                            text: $quantity,
                            isIconDisplay: false,
                            custFontName: robotoMedium,
                            custFontSize: 14.0
                        )
                        .keyboardType(.numberPad)

                        PrimaryButton(title: "Add Product") {
                            validateAndSubmit()
                        }
                    }
                    .padding()
                }
            }
            .background(.backGround)
        }
        .toast(isPresenting: $showHud) {
            AlertToast(
                displayMode: .hud,
                type: .regular,
                title: hudMsg,
                style: alertStlye
            )
        }
        .edgesIgnoringSafeArea(.bottom)
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func validateAndSubmit() {
            let trimmedName        = name.trimmingCharacters(in: .whitespaces)
            let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
            let trimmedQuantity    = quantity.trimmingCharacters(in: .whitespaces)
            
            // --- Name validation ---
            if trimmedName.isEmpty {
                showHudMessage("Product name is required.")
                return
            }
            if trimmedName.count < 2 {
                showHudMessage("Product name must be at least 2 characters.")
                return
            }
            if trimmedName.count > 100 {
                showHudMessage("Product name must be under 100 characters.")
                return
            }
            
            // --- Description validation ---
            if trimmedDescription.isEmpty {
                showHudMessage("Description is required.")
                return
            }
            if trimmedDescription.count < 5 {
                showHudMessage("Description must be at least 5 characters.")
                return
            }
            if trimmedDescription.count > 500 {
                showHudMessage("Description must be under 500 characters.")
                return
            }
            
            // --- Quantity validation ---
            if trimmedQuantity.isEmpty {
                showHudMessage("Quantity is required.")
                return
            }
            guard let quantityValue = Int(trimmedQuantity) else {
                showHudMessage("Quantity must be a valid number.")
                return
            }
            if quantityValue <= 0 {
                showHudMessage("Quantity must be greater than zero.")
                return
            }
            if quantityValue > 10000 {
                showHudMessage("Quantity must be 10,000 or less.")
                return
            }
            
            // --- All validations passed ---
            let product = ProductRow(
                name: trimmedName,
                description: trimmedDescription,
                quantity: quantityValue
            )
            onAdded(product)
        }
        
        private func showHudMessage(_ message: String) {
            hudMsg  = message
            showHud = true
        }
}
