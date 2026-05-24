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
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager

enum FormValidationResult: Equatable{
    case valid
    case invalid(message: String)
}

// MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): explicit focus order
// for the AddCard form so the keyboard accessory bar's previous/next
// arrows walk fields in visual top-to-bottom + left-to-right order:
// Holder → Number → CVV → Expiry. Previously IQKeyboardManager's
// auto-toolbar walked the view hierarchy in an order that jumped from
// CVV (inside the HStack) BACK to Holder before reaching Expiry.
private enum AddCardField: Hashable {
    case holder
    case number
    case cvv
    case expiry
}

struct AddCardScreen: View {
    @State private var cardHolderName = ""
    @State private var cardNumber = ""
    @State private var cvv = ""
    @State private var expiryDate = ""
    @FocusState private var focusedField: AddCardField?
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
                    
                    // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): preview text
                    // is gray when empty (placeholder), white when the user
                    // has actually entered a value. Was previously always
                    // gray which made the filled CVV/expiry look faded next
                    // to the white card number + name.
                    HStack {
                        Text(cvv.isEmpty ? "CVV" : cvv)
                            .font(.custom(poppinsMedium, size: 13.0))
                            .foregroundColor(cvv.isEmpty ? .gray : .white)
                        Spacer()
                        Text(expiryDate.isEmpty ? "MM/YY" : expiryDate)
                            .font(.custom(poppinsMedium, size: 13.0))
                            .foregroundColor(expiryDate.isEmpty ? .gray : .white)
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
                .focused($focusedField, equals: .holder)
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
                .focused($focusedField, equals: .number)
                .disabled(isEditMode)
                //                .textContentType(.name)
                
                // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): vertical
                // stack instead of HStack. The previous side-by-side layout
                // kept the responder chain walking CVV → Holder → Expiry
                // even after both IQKeyboardManager and IQKeyboardToolbar-
                // Manager were disabled. The simplest robust fix is to put
                // CVV and Expiry on their own rows so there's no HStack
                // sibling confusion. Slight UI tradeoff (taller form) but
                // matches the field width of the other inputs.
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
                .focused($focusedField, equals: .cvv)
                .disabled(isEditMode)

                AuthTextField(
                    floatingLabel: "Expiry Date",
                    placeholder: "MM/YY",
                    icon: .icMail,
                    text: $expiryDate,
                    isIconDisplay : false,
                    isForExpiry : true,
                    enteredText: {
                        expiryDate = $0
                    }
                )
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .expiry)
            }
            .padding(.horizontal,16)
            // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): SwiftUI-native
            // previous/next toolbar above the keyboard so tab order is
            // explicit (Holder → Number → CVV → Expiry) instead of
            // letting IQKeyboardManager guess from the view hierarchy.
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button(action: { moveFocus(direction: -1) }) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(focusedField == nil || focusedField == .holder)
                    Button(action: { moveFocus(direction: 1) }) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(focusedField == nil || focusedField == .expiry)
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            
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
        // MC cmpfokf75001foohg7l8jcno4 (2026-05-22): same self-referential
        // onDismiss bug as TrustedBuyerScreen — setting showError = true on
        // dismiss creates a present/dismiss loop. Collapse to a clean
        // showError = false; the explicit onPrimaryClick/onSecondaryClick
        // handlers below already drive the close behavior.
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
            showError = false
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
            // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): disable
            // IQKeyboardManager + its auto-toolbar on this screen so the
            // SwiftUI `.toolbar(placement: .keyboard)` we set above is
            // the only keyboard accessory bar shown. Toolbar-only disable
            // (18:41 EDT attempt) wasn't enough — IQ still rebuilt the
            // toolbar walking the wrong order. Disabling the whole IQ
            // manager forces iOS / SwiftUI to use our explicit @FocusState
            // chain. Re-enable in onDisappear so other screens keep IQ.
            IQKeyboardManager.shared.isEnabled = false
            IQKeyboardToolbarManager.shared.isEnabled = false

            if let selectedCard = viewModel.selectedCard {
                self.cardId = selectedCard.cardID ?? ""
                isEditMode = true
                cardHolderName = selectedCard.cardHolderName ?? ""
                // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): MM/YY format
                // to match the new input style. Backend ints → zero-padded
                // strings so "5/27" → "05/27".
                let m = selectedCard.expMonth ?? 0
                let y = (selectedCard.expYear ?? 0) % 100 // take last 2 digits
                expiryDate = String(format: "%02d/%02d", m, y)
            }
        }
        .onDisappear {
            IQKeyboardManager.shared.isEnabled = true
            IQKeyboardToolbarManager.shared.isEnabled = true
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
        // MC cmpfokf75001foohg7l8jcno4 (2026-05-22): the body below
        // splits expiryDate and indexes the two components without
        // bounds-checking. Validate the shape up front so a malformed
        // expiry surfaces as a friendly error instead of crashing on
        // subscript-out-of-bounds.
        //
        // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): format is now MM/YY
        // (was YYYY-MM). Accept both for backwards-compat in case any
        // saved-card / draft state still carries the old format.
        let expirySeparator: Character = expiryDate.contains("/") ? "/" : "-"
        let expiryComponents = expiryDate.split(separator: expirySeparator)
        guard expiryComponents.count >= 2 else {
            hudMsg = "Please enter a valid expiry date"
            showhud = true
            return
        }
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
                // MC cmpfokf75001foohg7l8jcno4 (2026-05-22): expiry shape
                // is now pre-validated above (count >= 2), so this is
                // safe. Keeping the guard local here too for defensive
                // depth in case future refactors call into this closure
                // from a different validation path.
                //
                // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): format is now
                // MM/YY (was YYYY-MM); month comes first, year second. Year
                // arrives as 2 digits — normalize to a 4-digit year for the
                // Stripe / backend payload so "27" → 2027 not 27. Also keep
                // backwards-compat with any lingering YYYY-MM by detecting
                // 4-digit first component.
                let sep: Character = expiryDate.contains("/") ? "/" : "-"
                let date = expiryDate.split(separator: sep)
                guard date.count >= 2 else { return }
                let firstLen = date[0].count
                let month: Substring
                let yearShort: Substring
                if firstLen == 4 {
                    // Legacy YYYY-MM: date[0]=year, date[1]=month
                    yearShort = Substring(String(date[0]).suffix(2))
                    month = date[1]
                } else {
                    // New MM/YY: date[0]=month, date[1]=year (2-digit)
                    month = date[0]
                    yearShort = date[1]
                }
                // Expand 2-digit year to 4-digit (assume 21st century).
                let yearFull = "20\(yearShort)"
                let year = Substring(yearFull)
                
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
                    try await viewModel.updateCard(request: UpdateCardRequest(card_id: cardId, name: cardHolderName, exp_month: "\(String(month))", exp_year: "\(String(year))"
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
    
    // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24): explicit prev/next walk
    // for the AddCard focus chain so the keyboard toolbar arrows step in
    // visual order (Holder → Number → CVV → Expiry).
    private func moveFocus(direction: Int) {
        let order: [AddCardField] = [.holder, .number, .cvv, .expiry]
        guard let current = focusedField,
              let idx = order.firstIndex(of: current) else { return }
        let next = idx + direction
        guard next >= 0 && next < order.count else { return }
        focusedField = order[next]
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


