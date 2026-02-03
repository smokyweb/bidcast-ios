//
//  AddCardScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/06/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast
import Stripe

enum FormValidationResult: Equatable{
    case valid
    case invalid(message: String)
}

struct AddCardScreen: View {
    @State private var cardHolderName = ""
    @State private var cardNumber = ""
    @State private var cvv = ""
    @State private var expiryDate = ""
    var isNavFrom: String = ""
//    @State var viewModel = AddCardViewModel()
    var onSuccess: ((String) async -> Void)?
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel = StripeCardViewModel()

    @State private var cardId: String = ""
    @State private var isEditMode: Bool = false
    
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack{
                PrimaryHeader(
                    title: isEditMode ? "Update Payment Card" : "Add Payment Card".localized,
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"], // logo on left
                    trailingImgArr: [],
                    onClickLeading: { index in
                        self.presentationMode.wrappedValue.dismiss()
                        // maybe open menu or do nothing
                    },
                    onClickTrailing: nil,
                    count: .constant(0)
                )
            }
            
            // Card mockup
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black)
                    .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 12) {
//                    Text("BANK NAME")
//                        .font(.custom(poppinsMedium, size: 13.0))
//                        .foregroundColor(.gray)
                    Text(cardNumber.isEmpty ? "XXXX-XXXX-XXXX-XXXX" : cardNumber)
                        .font(.custom(poppinsMedium, size: 13.0))
                        .foregroundColor(.white)
                        .font(.headline)
                    
                 
                    Text(cardHolderName.isEmpty ? "NAME" : cardHolderName)
                        .font(.custom(poppinsMedium, size: 13.0))
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    HStack {
                        Text(cvv.isEmpty ? "CVV" : cvv)
                            .font(.custom(poppinsMedium, size: 13.0))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(expiryDate.isEmpty ? "MM/YY" : expiryDate)
                            .font(.custom(poppinsMedium, size: 13.0))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            
            // Input fields
            Group {
                AuthTextField(
                    floatingLabel: "Card Holder name",
                    placeholder: "Enter card holder name",
                    icon: .icMail,
                    text: $cardHolderName,
                    isIconDisplay : false,
                    enteredText: {
                        cardHolderName = $0.uppercased()
                    }
                )
                .keyboardType(.alphabet)
                //                .textContentType(.name)
                
                AuthTextField(
                    floatingLabel: "Card Number",
                    placeholder: "Enter card number",
                    icon: .icMail,
                    text: $cardNumber,
                    isIconDisplay : false,
                    isForCardNumber: true,
                    enteredText: {
                        cardNumber = formatCardNumber($0)
                    }
                )
                .keyboardType(.numberPad)
                .disabled(isEditMode)
                //                .textContentType(.name)
                
                HStack {
                    AuthTextField(
                        floatingLabel: "CVV",
                        placeholder: "xxx",
                        icon: .icMail,
                        text: $cvv,
                        isIconDisplay : false,
                        isForCVV: true,
                        enteredText: {
                            cvv = $0
                        }
                    )
                    .keyboardType(.numberPad)
                    .disabled(isEditMode)
                    //                    .textContentType(.name)
                    AuthTextField(
                        floatingLabel: "Expiry Date",
                        placeholder: "YYYY-MM",
                        icon: .icMail,
                        text: $expiryDate,
                        isIconDisplay : false,
                        isForExpiry : true,
                        enteredText: {
                            expiryDate = $0
                        }
                    )
                    .keyboardType(.numberPad)
                    //                    .textContentType(.name)
                }
            }
            .padding(.horizontal,16)
            
            Spacer()
            
            // Add Button
            
            PrimaryButton(title: isEditMode ? "Update Card" : "Add Card",
                          isOutLine: false,
                          onButtonClick: addCard)
            .padding(.horizontal,16)
            
//            PrimaryButton(
//                title: "Submit",
//                isOutLine: true,
//                onButtonClick: {
//                    guard !cardNumber.isEmpty else{
//                        hudMsg = "Please Enter card number"
//                        showhud = true
//                        return
//                    }
//                    guard !expiryDate.isEmpty else{
//                        hudMsg = "Please Enter expiry date"
//                        showhud = true
//                        return
//                    }
//                    guard !cvv.isEmpty else{
//                        hudMsg = "Please Enter cvv detials"
//                        showhud = true
//                        return
//                    }
//                    
//                    
//                    UIApplication.shared.endEditing()
//                    //                    isNavFrom = "SellerVerification"
//                    
//                    Task{
//                        SVProgressHUD.show()
//                        self.viewModel.errorMessage = ""
//                        let param = AddCardRequest(card_number: getUnformattedCardNumber(cardNumber),
//                                                   expiration_date: expiryDate,
//                                                   cvv: cvv)
//                        await viewModel.addCard(parameters: param)
//                        await SVProgressHUD.dismiss()
//                        
//                        if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
//                            handleResponse()
//                        }else{
//                            alertType = .sheetType(
//                                icon: .alert,
//                                title: "Failed",
//                                message: self.viewModel.errorMessage ?? "",
//                                primaryBtnText: "",
//                                secondaryBtnText: "OK"
//                            )
//                            showError = true
//                        }
//                    }
//                    
//                },
//                width: screenWidth - 40,
//                cornerRadius: 12.0, imageName: "",
//                btnTextColor : .defaultTheme, btnColor: .defaultTheme
//            )
//            .padding(.vertical, 10)
//            .background(Color.white)
        }
        
        .background(.backGround)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showError = true
        }) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if let msg = self.viewModel.errorMessage, msg != ""{
                        withAnimation { showError = false }
                    }else{
                        self.presentationMode.wrappedValue.dismiss()
                        withAnimation { showError = false }
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
        
        .onAppear {
            if let selectedCard = viewModel.selectedCard {
                self.cardId = selectedCard.cardID ?? ""
                isEditMode = true
                cardHolderName = selectedCard.cardHolderName ?? ""
                expiryDate = "\(selectedCard.expYear ?? 0)-\(selectedCard.expMonth ?? 0)"
            }
        }
    }
    
    private var validationResult: FormValidationResult {

        if cardHolderName.isEmpty {
            return .invalid(message: "Please enter card holder name")
        }

        if !isEditMode && cardNumber.isEmpty {
            return .invalid(message: "Please enter card number")
        }

        if expiryDate.isEmpty {
            return .invalid(message: "Please enter expiry date")
        }

        if !isEditMode && cvv.isEmpty {
            return .invalid(message: "Please enter CVV")
        }

        return .valid
    }

    
    private func validateAndShowToast() -> Bool {
        switch validationResult {
        case .valid:
            return true

        case .invalid(let message):
            hudMsg = message
            showhud = true
            return false
        }
    }

    private var isFormValid: Bool {
        if isEditMode {
            return !cardHolderName.isEmpty &&
            !expiryDate.isEmpty
        }
        else  {
            return !cardHolderName.isEmpty &&
            !cardNumber.isEmpty &&
            !expiryDate.isEmpty &&
            !cvv.isEmpty
        }
    }
        
    private func addCard() {
        hideKeyboard()
        guard validateAndShowToast() else { return }
        Task {
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: "OK"
                    )
                    showError = true
                },
                onSuccess: {
                    handleSellerCardResponse(cardId: "success")
                    alertType = .sheetType(
                        icon: .success,
                        title: "Success",
                        message: isEditMode ? "Card Added Successfully." : "Card Updated Successfully.",
                        primaryBtnText: "OK",
                        secondaryBtnText: ""
                    )
                    showError = true
                }
            ) {
                // Create mock card text field
                let date = expiryDate.split(separator: "-")
                let month = date[1]
                let year = date[0]
                
                if !isEditMode {
                    var cardTextField = StripeRequest(cardHolderName: cardHolderName,
                                                      cardNumber: getUnformattedCardNumber(cardNumber),
                                                      expirationMonth: UInt(month) ?? 0,
                                                      expirationYear: UInt(year) ?? 0,
                                                      cvc: cvv)
                    
                    // Get token
                    let token = try await viewModel.getStripeToken(from: cardTextField)
                    
                    // Add card
                    try await viewModel.addCard(request: AddCardRequest(card_token: token.tokenId))
                }
                else  {
                    try await viewModel.updateCard(request: UpdateCardRequest(card_id: cardId, name: cardHolderName, exp_month: "\(month)", exp_year: "\(year)"
                                                                            ))
                }
                
            }
        }
    }
    
    func handleSellerCardResponse(cardId:String) {
        Task {
            await onSuccess?(cardId)
        }
    }
    
    func formatCardNumber(_ cardNumber: String) -> String {
        // Remove all non-digit characters
        let cleaned = cardNumber.filter { $0.isNumber }
        
        // Check if the cleaned card number length is correct
        let formatted = cleaned.chunked(into: 4).joined(separator: " ")
        
        return formatted
    }
    
    func getUnformattedCardNumber(_ cardNumber: String) -> String {
        // Remove any dashes from the card number
        let unformattedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        return unformattedCardNumber
    }

}


