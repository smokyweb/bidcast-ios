//
//  SendTipView.swift
//  BidCast
//
//  Created by JamTech on 17/10/25.
//

import SwiftUI
import SVProgressHUD

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
    var onSendTip: (Double, String) -> Void
    
    var body: some View {
        VStack(alignment:.leading, spacing: 20) {
            
            // Header
            HStack {
                Text("Send a Tip 💸")
                    .font(.custom(poppinsBold, size: 22.0))
                Spacer()
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }

                Button(action: onClose) {
                    
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Subtitle
            Text("Support your seller during the live show")
                .font(.custom(poppinsRegular, size: 14.0))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Tip options
            HStack(spacing: 12) {
                ForEach(tipOptions, id: \.self) { amount in
                    Button {
                        selectedAmount = amount
                        customAmount = ""
                    } label: {
                        Text("$\(Int(amount))")
                            .frame(width: 80, height: 45)
                            .background(selectedAmount == amount ? Color.blue.opacity(0.2) : Color(.systemGray6))
                            .foregroundColor(selectedAmount == amount ? .blue : .black)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedAmount == amount ? Color.blue : Color.clear, lineWidth: 1.5)
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            // Custom tip field
            VStack(alignment: .leading, spacing: 6) {
                Text("Custom Tip")
                    .font(.system(size: 14, weight: .semibold))
                
                TextField("Enter your own amount", text: $customAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: customAmount) { _ in
                        selectedAmount = nil
                    }
            }
            .padding(.horizontal)
            
            // Payment options
            VStack(spacing: 12) {
                if let cards = cardResponse?.paymentProfiles, !cards.isEmpty {
                    ForEach(0 ..< cards.count) { i in
                        let card = cards[i]
                        let cardNum = card.payment?.creditCard?.cardNumber ?? ""
                        let lastFourDigit = String(cardNum.suffix(4))
                        PaymentOptionRow(cardDetails: card,
                                         isSelected: selectedPaymentId == lastFourDigit) {
                            selectedPaymentId = lastFourDigit
                        }
                    }
                } else {
                    Text("No saved cards found.")
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.gray)
                        .padding()
                }
               
            }
            .padding(.horizontal)
            
            // Send button
            Button {
                let finalAmount = selectedAmount ?? Double(customAmount) ?? 0.0
              if finalAmount > 0, selectedPaymentId != nil, sellerId != "" {
                  Task {
                      await sendTipsAmountData(amount: finalAmount,
                                         cardId: selectedPaymentId!,
                                         sellerId: sellerId)
                  }
                } else {
                    // show alert to select payment
                }
            } label: {
                Text("Send Tip")
                    .font(.custom(poppinsBold, size: 16.0))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.defaultTheme)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .padding(.top)
        .background(Color.white)
        .cornerRadius(20)
        .ignoresSafeArea(edges: .bottom)
        .onAppear  {
            Task {
                SVProgressHUD.show()
                await viewModel.getCard()
                await SVProgressHUD.dismiss()
                successGetCardList()
            }
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    // Handle response when primary button clicked
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
        let request = TipAmountRequest(seller_id: sellerId,
                                       amount: "\(amount)",
                                       card_number: cardId)
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
            hudMsg = "Tip Amount Send successfully!!"
            showhud = true
//            sendTipsData = tipsViewModel.sendTipAmountResponse?.data
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct PaymentOptionRow: View {
    var cardDetails: PaymentProfile?
    let isSelected: Bool
    let onSelect: (() -> Void)?

    var body: some View {
        Button {
            onSelect?()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    // Card Number
                    let maskedNumber = "XXXX XXXX XXXX " + (cardDetails?.payment?.creditCard?.cardNumber?.suffix(4) ?? "****")
                    let expiry = cardDetails?.payment?.creditCard?.expirationDate ?? "MM/YY"

                    Text(maskedNumber)
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.black)

                    Text("Exp: \(expiry)")
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Selection Circle
                Circle()
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: 2)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.clear)
                            .frame(width: 10, height: 10)
                    )
            }
            .frame(height: 60)
            .padding()
            .background(isSelected ? .defaultTheme.opacity(0.4) : Color.gray.opacity(0.2))
            .cornerRadius(12)
        }
    }
}


#Preview {
    SendTipView(
        onClose: {},
        onSendTip: { amount, method in
            print("Sent tip: \(amount) via \(method)")
        }
    )
}
