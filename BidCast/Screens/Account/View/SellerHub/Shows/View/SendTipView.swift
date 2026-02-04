//
//  SendTipView.swift
//  BidCast
//
//  Created by Vivek_JAM-E_328 on 17/10/25.
//

//import SwiftUI
import SVProgressHUD
import SwiftUI

struct SendTipView: View {
    
    @State private var selectedAmount: Double? = nil
    @State private var customAmount: String = ""
    @State private var selectedPaymentId: String? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel: PaymentViewModel = PaymentViewModel()
    @StateObject var cardViewModel: StripeCardViewModel = StripeCardViewModel()
    @StateObject private var tipsViewModel = TipsViewModel()
    @State private var cardResponse: [CardDataModel] = []
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    
    var sellerId: String = ""
    
    let tipOptions = [5.0, 10.0, 25.0, 50.0]
    
    var onClose: () -> Void
    var onSendTip: () -> Void
    
    var body: some View {
        VStack{
            PrimarySheetHeader(title:"Send a Tip 💸",onClose:{
                onClose()
            })

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    // MARK: - Subtitle
                    Text("Support your seller during the live show")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
//                        .padding(.top,)
                    
                    // MARK: - Tip Options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Amount")
                            .font(.custom(poppinsSemiBold, size: 13))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                        
                        HStack(spacing: 12) {
                            ForEach(tipOptions, id: \.self) { amount in
                                TipOptionButton(
                                    amount: amount,
                                    isSelected: selectedAmount == amount,
                                    onTap: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedAmount = amount
                                            customAmount = String(selectedAmount ?? 0.0)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // MARK: - Custom Tip Field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Custom Amount")
                            .font(.custom(poppinsSemiBold, size: 13))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 12) {
                            Text("$")
                                .font(.custom(poppinsSemiBold, size: 16))
                                .foregroundColor(.black)
                            
                            TextField("Enter amount", text: $customAmount)
                                .font(.custom(poppinsRegular, size: 11))
                                .keyboardType(.decimalPad)
                                .onChange(of: customAmount) { _ in
                                    selectedAmount = nil
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.white))
                                .shadow(color: .lightGray ,radius: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(customAmount.isEmpty ? Color.clear : Color.defaultThemeLight, lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    // MARK: - Payment Options
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Payment Method")
                            .font(.custom(poppinsSemiBold, size: 13))
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                        
                        if !cardResponse.isEmpty {
                            VStack(spacing: 12) {
                                ForEach(0 ..< cardResponse.count, id: \.self) { i in
                                    let card = cardResponse[i]
                                    let cardNum = card.last4 ?? ""
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
                            .padding(.horizontal, 16)
                        } else {
                            HStack {
//                                Image(systemName: "creditcard")
//                                    .font(.system(size: 20))
//                                    .foregroundColor(.gray)
                                
                                Text("No saved cards found")
                                    .font(.custom(poppinsRegular, size: 13))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.white))
                                    .shadow(color: .lightGray ,radius: 3)
                            )
                            .padding(.horizontal, 16)
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
                                .font(.custom(poppinsSemiBold, size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.defaultTheme )
                        .cornerRadius(32)
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
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.backGround))
        .onAppear {
            Task {
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: cardViewModel.errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        // On success
                        successGetCardList()
                    }
                    
                ) {
                    try await cardViewModel.getCards()
                }
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
        let response = cardViewModel.cards
        if response?.status == "success" {
            cardResponse = response?.data ?? []
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: cardViewModel.errorMessage ?? "",
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
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(isSelected ? .white : .defaultTheme)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isSelected ? .defaultTheme : Color(.defaultThemeLight) )
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

    // MARK: - Inputs
    let cardDetails: CardDataModel?
    let isSelected: Bool
    let onSelect: () -> Void

    // MARK: - Computed Properties
    private var maskedNumber: String {
        let last4 = cardDetails?.last4?.suffix(4) ?? "****"
        return "•••• •••• •••• \(last4)"
    }

    private var expiryText: String {
        "\(cardDetails?.expMonth ?? 0)/\(cardDetails?.expYear ?? 0)"
    }

    // MARK: - Body
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {

                cardIconView

                cardDetailsView

                Spacer()

                selectionIndicatorView
            }
            .padding(16)
            .background(backgroundView)
            .overlay(borderView)
            .shadow(
                color: isSelected
                    ? Color.defaultThemeLight
                    : Color.black.opacity(0.03),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews
private extension ElegantPaymentOptionRow {

    // Card Icon
    var cardIconView: some View {
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
    }

    // Card Details
    var cardDetailsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(maskedNumber)
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(.black)

            Text("Exp: \(expiryText)")
                .font(.custom(poppinsRegular, size: 11))
                .foregroundColor(.darkGray)
        }
    }

    // Selection Indicator
    var selectionIndicatorView: some View {
        ZStack {
            Circle()
                .stroke(
                    isSelected
                        ? Color.defaultTheme
                        : Color.gray.opacity(0.3),
                    lineWidth: 2
                )
                .frame(width: 24, height: 24)

            if isSelected {
                Circle()
                    .fill(Color.defaultTheme)
                    .frame(width: 12, height: 12)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(
            .spring(response: 0.3, dampingFraction: 0.6),
            value: isSelected
        )
    }

    // Background
    var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                isSelected
                    ? Color.defaultThemeLight
                    : Color(.white)
            )
    }

    // Border
    var borderView: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isSelected
                    ? Color.defaultTheme
                    : Color.clear,
                lineWidth: 1.5
            )
    }
}

// MARK: - Preview
//struct SendTipView_Previews: PreviewProvider {
//    static var previews: some View {
//        SendTipView(
//            sellerId: "123",
//            onClose: { print("Close") },
//            onSendTip: { print("Tip sent") }
//        )
//    }
//}
