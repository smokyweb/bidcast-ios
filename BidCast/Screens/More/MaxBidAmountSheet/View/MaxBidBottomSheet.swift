//
//  ProductDetailSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD

struct MaxBidBottomSheet: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var bidAmount: String = ""
    
    @Binding var showParentToast: Bool
    @Binding var parentToastMessage: String
    var currentProduct: ProductDataModel1
    var onSubmit: (_ amount: String) -> Void = { _ in }
    var onDismiss: (() -> Void)? = nil
    @State private var showHUD = false
    @State private var hudMsg = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Max Bid Amount")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Button {
                    onDismiss?()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.title2)
                }
            }
            
            // Label
            Text("Enter Bid Amount")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Input Field
            TextField("$ 0.00", text: $bidAmount)
                .keyboardType(.decimalPad)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 19)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            // Submit Button
            Button {
                guard let enteredAmount = Double(bidAmount), enteredAmount > 0 else {
                    showTemporaryHUD(message: "Please enter a valid amount")
                    return
                }
                
//                if let currentPrice = Double(currentProduct.pricing ?? ""), enteredAmount <= currentPrice {
//                    showTemporaryHUD(message: "Please enter an amount greater than current price $\(currentProduct.pricing ?? "")")
//                    return
//                }
                
                onSubmit(bidAmount)
                bidAmount = ""
                onDismiss?()
                
            } label: {
                Text("Submit")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Spacer(minLength: 0)
        }
        .padding(20)
        .frame(maxHeight: 250)
        .overlay(
            // Toast overlay
            Group {
                if showHUD {
                    Text(hudMsg)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(12)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        )
        .animation(.easeInOut, value: showHUD)
    }
    
    private func showTemporaryHUD(message: String) {
        hudMsg = message
        showHUD = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showHUD = false
        }
    }
}
