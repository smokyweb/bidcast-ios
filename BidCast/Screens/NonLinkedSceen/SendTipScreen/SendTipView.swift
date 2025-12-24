//
//  SendTipView.swift
//  BidCast
//
//  Created by Vivek_JAM-E_328 on 17/10/25.
//

//import SwiftUI
import SVProgressHUD
//
//struct SendTipView: View {
//    
//    @State private var selectedAmount: Double? = nil
//    @State private var customAmount: String = ""
//    @State private var selectedPaymentId: String? = nil
//    
//    @Environment(\.presentationMode) var presentationMode
//    
//    @StateObject var viewModel: PaymentViewModel = PaymentViewModel()
//    @StateObject private var tipsViewModel = TipsViewModel()
//    @State var cardResponse: CardModel?
//    
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State var showError: Bool = false
//    
//    var sellerId: String = ""
//    
//    let tipOptions = [5.0, 10.0, 25.0, 50.0]
//    
//    var onClose: () -> Void
//    var onSendTip: () -> Void
//    
//    var body: some View {
//        VStack(alignment:.leading, spacing: 20) {
//            ScrollView {
//                // Header
//                HStack {
//                    Text("Send a Tip 💸")
//                        .font(.custom(poppinsBold, size: 22.0))
//                    Spacer()
//                    Button {
//                        onClose()
//                    } label: {
//                        Image(systemName: "xmark")
//                            .foregroundColor(.gray)
//                    }
//                    
//                    Button(action: onClose) {
//                        
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 16)
//                
//                // Subtitle
//                Text("Support your seller during the live show")
//                    .font(.custom(poppinsRegular, size: 14.0))
//                    .foregroundColor(.gray)
//                    .padding(.horizontal)
//                
//                // Tip options
//                HStack(spacing: 12) {
//                    ForEach(tipOptions, id: \.self) { amount in
//                        Button {
//                            selectedAmount = amount
//                            customAmount = ""
//                        } label: {
//                            Text("$\(Int(amount))")
//                                .frame(width: 80, height: 45)
//                                .background(selectedAmount == amount ? Color.defaultTheme.opacity(0.2) : Color(.systemGray6))
//                                .foregroundColor(selectedAmount == amount ? .blue : .black)
//                                .cornerRadius(10)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(selectedAmount == amount ? Color.defaultTheme : Color.clear, lineWidth: 1.5)
//                                )
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                
//                // Custom tip field
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Custom Tip")
//                        .font(.system(size: 14, weight: .semibold))
//                    
//                    TextField("Enter your own amount", text: $customAmount)
//                        .keyboardType(.decimalPad)
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .cornerRadius(10)
//                        .onChange(of: customAmount) { _ in
//                            selectedAmount = nil
//                        }
//                }
//                .padding(.horizontal)
//                
//                // Payment options
//                VStack(spacing: 12) {
//                    if let cards = cardResponse?.paymentProfiles, !cards.isEmpty {
//                        ForEach(0 ..< cards.count) { i in
//                            let card = cards[i]
//                            let cardNum = card.payment?.creditCard?.cardNumber ?? ""
//                            let lastFourDigit = String(cardNum.suffix(4))
//                            PaymentOptionRow(cardDetails: card,
//                                             isSelected: selectedPaymentId == lastFourDigit) {
//                                selectedPaymentId = lastFourDigit
//                            }
//                        }
//                    } else {
//                        Text("No saved cards found.")
//                            .font(.custom(poppinsRegular, size: 14))
//                            .foregroundColor(.gray)
//                            .padding()
//                    }
//                    
//                }
//                .padding(.horizontal)
//                
//                // Send button
//                Button {
//                    let finalAmount = selectedAmount ?? Double(customAmount) ?? 0.0
//                    if finalAmount > 0, selectedPaymentId != nil, sellerId != "" {
//                        Task {
//                            await sendTipsAmountData(amount: finalAmount,
//                                                     cardId: selectedPaymentId!,
//                                                     sellerId: sellerId)
//                        }
//                    } else {
//                        // show alert to select payment
//                    }
//                } label: {
//                    Text("Send Tip")
//                        .font(.custom(poppinsBold, size: 16.0))
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(.defaultTheme)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                }
//                .padding(.horizontal)
//                .padding(.bottom, 20)
//            }
//        }
//        .padding(.top)
//        .background(Color.white)
//        .cornerRadius(20)
//        .ignoresSafeArea(edges: .bottom)
//        .onAppear  {
//            Task {
//                SVProgressHUD.show()
//                await viewModel.getCard()
//                await SVProgressHUD.dismiss()
//                successGetCardList()
//            }
//        }
//        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
//            CommonBottomSheet(
//                sheetType: $alertType,
//                onPrimaryClick: {
//                    withAnimation { showError = false }
//                    // Handle response when primary button clicked
//                },
//                onSecondaryClick: {
//                    withAnimation { showError = false }
//                }
//            )
//        }
//    }
//    
//    @MainActor
//    private func successGetCardList() {
//        let response = viewModel.cardDict
//        if response.status == "success" {
//            cardResponse = response.data
//        } else {
//            alertType = .sheetType(
//                icon: .alert,
//                title: response.error_type?.capitalized ?? "",
//                message: response.message?.capitalized ?? "",
//                primaryBtnText: "",
//                secondaryBtnText: AppString.ok.localized
//            )
//            showError = true
//        }
//    }
//    
//    private func sendTipsAmountData(amount: Double, cardId: String, sellerId: String) async {
//        guard Reachability.isConnectedToNetwork() else {
//            hudMsg = "No Internet Connection"
//            showhud = true
//            return
//        }
//        SVProgressHUD.show()
//        let request = TipAmountRequest(seller_id: sellerId,
//                                       amount: "\(amount)",
//                                       card_number: cardId)
//        await tipsViewModel.sendTipsAmountData(request: request)
//        await SVProgressHUD.dismiss()
//        
//        if tipsViewModel.sendTipAmountResponse?.status != "success" {
//            alertType = .sheetType(
//                icon: .alert,
//                title: "Error",
//                message: tipsViewModel.sendTipAmountResponse?.message ?? "Something went wrong.",
//                primaryBtnText: "",
//                secondaryBtnText: "OK",
//                sheetThemeColor: .pinkBtn
//            )
//            withAnimation(.snappy) { showError = true }
//        } else {
//            hudMsg = "Tip Amount Send successfully!!"
//            showhud = true
////            sendTipsData = tipsViewModel.sendTipAmountResponse?.data
//            onSendTip()
////            presentationMode.wrappedValue.dismiss()
//        }
//    }
//}
//
//struct PaymentOptionRow: View {
//    var cardDetails: PaymentProfile?
//    let isSelected: Bool
//    let onSelect: (() -> Void)?
//
//    var body: some View {
//        Button {
//            onSelect?()
//        } label: {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    // Card Number
//                    let maskedNumber = "XXXX XXXX XXXX " + (cardDetails?.payment?.creditCard?.cardNumber?.suffix(4) ?? "****")
//                    let expiry = cardDetails?.payment?.creditCard?.expirationDate ?? "MM/YY"
//
//                    Text(maskedNumber)
//                        .font(.custom(poppinsSemiBold, size: 16))
//                        .foregroundColor(.black)
//
//                    Text("Exp: \(expiry)")
//                        .font(.custom(poppinsRegular, size: 14))
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer()
//                
//                // Selection Circle
//                Circle()
//                    .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.4), lineWidth: 2)
//                    .frame(width: 22, height: 22)
//                    .overlay(
//                        Circle()
//                            .fill(isSelected ? Color.defaultTheme : Color.clear)
//                            .frame(width: 10, height: 10)
//                    )
//            }
//            .frame(height: 60)
//            .padding()
//            .background(isSelected ? .defaultTheme.opacity(0.4) : Color.gray.opacity(0.2))
//            .cornerRadius(12)
//        }
//    }
//}


//#Preview {
//    SendTipView(
//        onClose: {},
//        onSendTip: { amount, method in
//            print("Sent tip: \(amount) via \(method)")
//        }
//    )
//}

import SwiftUI

struct SendTipView: View {
    
    @State private var selectedAmount: Double? = nil
    @State private var customAmount: String = ""
    @State private var selectedPaymentId: String? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel: PaymentViewModel = PaymentViewModel()
    @StateObject private var tipsViewModel = TipsViewModel()
    @State var cardResponse: CardModel?
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    
    var sellerId: String = ""
    
    let tipOptions = [5.0, 10.0, 25.0, 50.0]
    
    var onClose: () -> Void
    var onSendTip: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    HStack(alignment: .center) {
                        Text("Send a Tip 💸")
                            .font(.custom(poppinsBold, size: 26))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: onClose) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray.opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Subtitle
                    Text("Support your seller during the live show")
                        .font(.custom(poppinsRegular, size: 15))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.top, -16)
                    
                    // MARK: - Tip Options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Amount")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                        
                        HStack(spacing: 12) {
                            ForEach(tipOptions, id: \.self) { amount in
                                TipOptionButton(
                                    amount: amount,
                                    isSelected: selectedAmount == amount,
                                    onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedAmount = amount
                                            customAmount = ""
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // MARK: - Custom Tip Field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Custom Amount")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Text("$")
                                .font(.custom(poppinsSemiBold, size: 20))
                                .foregroundColor(.primary)
                            
                            TextField("Enter amount", text: $customAmount)
                                .font(.custom(poppinsRegular, size: 16))
                                .keyboardType(.decimalPad)
                                .onChange(of: customAmount) { _ in
                                    selectedAmount = nil
                                }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(customAmount.isEmpty ? Color.clear : Color.defaultThemeLight, lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // MARK: - Payment Options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Payment Method")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                        
                        if let cards = cardResponse?.paymentProfiles, !cards.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(0 ..< cards.count, id: \.self) { i in
                                    let card = cards[i]
                                    let cardNum = card.payment?.creditCard?.cardNumber ?? ""
                                    let lastFourDigit = String(cardNum.suffix(4))
                                    
                                    ElegantPaymentOptionRow(
                                        cardDetails: card,
                                        isSelected: selectedPaymentId == lastFourDigit,
                                        onSelect: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedPaymentId = lastFourDigit
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        } else {
                            HStack {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                                
                                Text("No saved cards found")
                                    .font(.custom(poppinsRegular, size: 15))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6).opacity(0.5))
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // MARK: - Send Button
                    Button(action: {
                        let finalAmount = selectedAmount ?? Double(customAmount) ?? 0.0
                        if finalAmount > 0, selectedPaymentId != nil, sellerId != "" {
                            Task {
                                await sendTipsAmountData(
                                    amount: finalAmount,
                                    cardId: selectedPaymentId!,
                                    sellerId: sellerId
                                )
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                            
                            Text("Send Tip")
                                .font(.custom(poppinsBold, size: 17))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.defaultTheme )
                        .cornerRadius(16)
                        .shadow(color: Color.defaultThemeLight, radius: 12, x: 0, y: 6)
                    }
                    .disabled(
                        (selectedAmount == nil && customAmount.isEmpty) ||
                        selectedPaymentId == nil
                    )
                    .opacity(
                        (selectedAmount == nil && customAmount.isEmpty) ||
                        selectedPaymentId == nil ? 0.5 : 1.0
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            Task {
                SVProgressHUD.show()
                await viewModel.getCard()
                await SVProgressHUD.dismiss()
                successGetCardList()
            }
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    
    @MainActor
    private func successGetCardList() {
        let response = viewModel.cardDict
        if response.status == "success" {
            cardResponse = response.data
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
    
    private func sendTipsAmountData(amount: Double, cardId: String, sellerId: String) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        let request = TipAmountRequest(
            seller_id: sellerId,
            amount: "\(amount)",
            card_number: cardId
        )
        await tipsViewModel.sendTipsAmountData(request: request)
        await SVProgressHUD.dismiss()
        
        if tipsViewModel.sendTipAmountResponse?.status != "success" {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: tipsViewModel.sendTipAmountResponse?.message ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK",
                sheetThemeColor: .pinkBtn
            )
            withAnimation(.snappy) { showError = true }
        } else {
            hudMsg = "Tip sent successfully! 🎉"
            showhud = true
            onSendTip()
        }
    }
}

// MARK: - Tip Option Button
struct TipOptionButton: View {
    var amount: Double
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text("$\(Int(amount))")
                .font(.custom(poppinsSemiBold, size: 18))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isSelected ? .defaultTheme : Color(.systemGray6) )
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.defaultTheme : Color.clear, lineWidth: 2)
                )
                .shadow(
                    color: isSelected ? Color.defaultThemeLight : Color.clear,
                    radius: isSelected ? 8 : 0,
                    x: 0,
                    y: isSelected ? 4 : 0
                )
                .scaleEffect(isSelected ? 1.02 : 1.0)
                
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Elegant Payment Option Row
struct ElegantPaymentOptionRow: View {
    var cardDetails: PaymentProfile?
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Card Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.defaultTheme.opacity(0.8),
                                    Color.defaultTheme
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                // Card Details
                VStack(alignment: .leading, spacing: 4) {
                    let maskedNumber = "•••• •••• •••• " + (cardDetails?.payment?.creditCard?.cardNumber?.suffix(4) ?? "****")
                    let expiry = cardDetails?.payment?.creditCard?.expirationDate ?? "MM/YY"
                    
                    Text(maskedNumber)
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.primary)
                    
                    Text("Exp: \(expiry)")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.defaultTheme)
                            .frame(width: 12, height: 12)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.defaultTheme.opacity(0.06) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.defaultTheme.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
            .shadow(
                color: isSelected ? Color.defaultTheme.opacity(0.15) : Color.black.opacity(0.03),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct SendTipView_Previews: PreviewProvider {
    static var previews: some View {
        SendTipView(
            sellerId: "123",
            onClose: { print("Close") },
            onSendTip: { print("Tip sent") }
        )
    }
}
