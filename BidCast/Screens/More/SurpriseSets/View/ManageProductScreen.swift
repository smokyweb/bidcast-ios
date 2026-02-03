//
//  CreateSurpriseScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/02/26.
//

import SwiftUI
import SVProgressHUD

struct ProductRow: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var quantity: Int
}

struct ManageProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel = SurpriseViewModel()
    
    @State private var openShippingSheet = false
    
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var isCategoryLocked: Bool = false
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    var onCancel : () -> () = { }
    var onAdded : (String,[ProductRow]) -> () = {_,_ in }
    
    @State private var productFromInventory = false
    
    // MARK: - Buy-in Price
    @State private var buyInPrice = ""
    
    // MARK: - Product Rows State
    @State private var productRows: [ProductRow] = []   // starts empty
    @State private var productData : [ProductDataModel1] = []
    
    var body: some View {
        VStack{
            VStack{
                PrimarySheetHeader(title: "Add Products", onClose: {
                    onCancel()
                })
            }
            .frame(height:  60)
            .background(Color.white)

            ScrollView(showsIndicators:false){
                VStack(alignment:.leading,spacing:12){
                    AuthTextField(
                        floatingLabel: "Buy-in Price",
                        placeholder: "Enter price".localized,
                        icon: .menuProfile,
                        text: $buyInPrice,
                        isIconDisplay : false,
                        isForPrice: true,
                        custFontName : robotoMedium,
                        custFontSize : 14.0,
                        enteredText:  { title in
                            buyInPrice = title
                        })
                    .keyboardType(.numberPad)
                    .padding([.top,.bottom],4)
                    .padding(.horizontal,-12)
                    
                    // MARK: - Product Table
                    ProductTableView(rows: $productRows, onAdd: {
                        productFromInventory = true
                    })
                        .padding(.top, 8)
                    
                }
            }
            .padding(.horizontal)
            .background(.backGround)
            .zIndex(1000)
            VStack{
                PrimaryButton(title:"Confirm", onButtonClick: {
                    validateAndConfirm()
                })
            }
            .padding(.bottom,12)
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.backGround)
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $productFromInventory){
            AddProductRowScreen(onCancel: {
                productFromInventory = false
            }, onAdded: { product in
                productFromInventory = false
                productRows.append(product)
            })
            .presentationDetents([.fraction(0.60)])
            .presentationCornerRadius(25)
            .presentationDragIndicator(.hidden)
        }
        .overlay(
            CustomBottomSheetView(
                isPresented: $openShippingSheet,
                config: config,
                primaryAction: {
                    withAnimation {
                        openShippingSheet = false
                    }
                },
                secondaryAction: {
                    withAnimation {
                        openShippingSheet = false
                    }
                }
            )
            .ignoresSafeArea(.keyboard)
        )
        .bottomSheet(isPresented: $showError, height: screenHeight * 0.35, topBarCornerRadius: 25, showTopIndicator: false,
            onDismiss: {
            if let _ = viewModel.errorMessage {
                showError = false
                viewModel.errorMessage = nil
            }else{
                showError = true
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if let _ = viewModel.errorMessage {
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
    
    // MARK: - Validation
    
    private func validateAndConfirm() {
        let trimmedPrice = buyInPrice.trimmingCharacters(in: .whitespaces)
        
        // ---------- Buy-in Price ----------
        if trimmedPrice.isEmpty {
            showValidationError("Buy-in price is required.")
            return
        }
        guard let priceValue = Double(trimmedPrice) else {
            showValidationError("Buy-in price must be a valid number.")
            return
        }
        if priceValue <= 0 {
            showValidationError("Buy-in price must be greater than zero.")
            return
        }
        
        // ---------- At least one product ----------
        if productRows.isEmpty {
            showValidationError("Please add at least one product.")
            return
        }
        
        // ---------- Each product row ----------
        for (index, row) in productRows.enumerated() {
            let rowNum      = index + 1
            let trimmedName = row.name.trimmingCharacters(in: .whitespaces)
            let trimmedDesc = row.description.trimmingCharacters(in: .whitespaces)
            
            // Name
            if trimmedName.isEmpty {
                showValidationError("Product \(rowNum): Name is required.")
                return
            }
            if trimmedName.count < 2 {
                showValidationError("Product \(rowNum): Name must be at least 2 characters.")
                return
            }
            if trimmedName.count > 100 {
                showValidationError("Product \(rowNum): Name must be under 100 characters.")
                return
            }
            
            // Description — optional, but cap length if filled
            if !trimmedDesc.isEmpty && trimmedDesc.count > 500 {
                showValidationError("Product \(rowNum): Description must be under 500 characters.")
                return
            }
            
            // Quantity
            if row.quantity <= 0 {
                showValidationError("Product \(rowNum): Quantity must be greater than zero.")
                return
            }
            if row.quantity > 10000 {
                showValidationError("Product \(rowNum): Quantity must be 10,000 or less.")
                return
            }
        }
        onAdded(trimmedPrice,productRows)
        // ---------- All validations passed ----------
        // TODO: call your API / viewModel submit here
    }
    
    private func showValidationError(_ message: String) {
        alertType = .sheetType(
            icon:             .alert,
            title:            "Validation Error",
            message:          message,
            primaryBtnText:   "Okay",
            secondaryBtnText: ""
        )
        showError = true
    }
}

// MARK: - Product Table View
struct ProductTableView: View {
    @Binding var rows: [ProductRow]
    var onAdd : () -> () = { }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Row
            HStack(spacing: 0) {
                Spacer().frame(width: 28)
                Text("")
                    .frame(width: 24)
                Text("Product Name")
                    .font(.custom(robotoMedium, size: 13))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Description (optional)")
                    .font(.custom(robotoMedium, size: 13))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Quantity")
                    .font(.custom(robotoMedium, size: 13))
                    .foregroundColor(.gray)
                    .frame(width: 64, alignment: .center)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
            
            Divider()
                .padding(.horizontal, 4)
            
            // Data Rows
            ForEach(rows.indices, id: \.self) { index in
                HStack(spacing: 0) {
                    // Delete Button
                    Button(action: {
                        if rows.count > 0 {
                            withAnimation {
                                rows.remove(at: index)
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 28)
                    .disabled(rows.count <= 0)
                    .opacity(rows.count <= 0 ? 0.3 : 1.0)
                    
                    // Serial Number
                    Text("\(index + 1)")
                        .font(.custom(robotoMedium, size: 14))
                        .foregroundColor(.gray)
                        .frame(width: 24, alignment: .center)
                    
                    // Product Name
                    TextField("", text: $rows[index].name)
                        .font(.custom(robotoMedium, size: 14))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    // Description
                    TextField("", text: $rows[index].description)
                        .font(.custom(robotoRegular, size: 14))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    
                    // Quantity
                    TextField("", value: $rows[index].quantity, formatter: NumberFormatter())
                        .font(.custom(robotoMedium, size: 14))
                        .foregroundColor(.black)
                        .frame(width: 64)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                
                Divider()
                    .padding(.horizontal, 4)
            }
            
            // Add Row Button
            Button(action: {
                withAnimation {
                    onAdd()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .medium))
                    Text("Add Product")
                        .font(.custom(robotoMedium, size: 14))
                }
                .foregroundColor(.blue)
            }
            .padding(.top, 10)
            .padding(.horizontal, 8)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}


//#Preview {
//    CreateSurpriseScreen()
//}
