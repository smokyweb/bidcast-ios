//
//  AddCardScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/06/25.
//

import SwiftUI
import SVProgressHUD

struct AddCardScreen: View {
    @State private var cardHolderName = ""
    @State private var cardNumber = ""
    @State private var cvv = ""
    @State private var expiryDate = ""
    var isNavFrom: String = ""
    @State var viewModel = AddCardViewModel()
    var onSuccess: ((String) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var stpCard = StripeCardViewModel()
    
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack{
                PrimaryHeader(
                    title: "Add Payment Card".localized,
                    isForLogo: false,
                    leadingImgArr: [.icBack], // logo on left
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
                    Text("BANK NAME")
                        .font(.custom(poppinsMedium, size: 13.0))
                        .foregroundColor(.gray)
                    Text(cardNumber.isEmpty ? "XXXX-XXXX-XXXX-XXXX" : cardNumber)
                        .font(.custom(poppinsMedium, size: 13.0))
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    TextField("Enter Name", text: $cardHolderName)
                        .foregroundColor(.white)
                        .font(.custom(poppinsMedium, size: 13.0))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.bottom, 10)
                    
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
                        cardHolderName = $0
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
                        cardNumber = $0
                    }
                )
                .keyboardType(.numberPad)
                //                .textContentType(.name)
                
                HStack {
                    AuthTextField(
                        floatingLabel: "CVV",
                        placeholder: "Enter CVV",
                        icon: .icMail,
                        text: $cvv,
                        isIconDisplay : false,
                        isForCVV: true,
                        enteredText: {
                            cvv = $0
                        }
                    )
                    .keyboardType(.numberPad)
                    //                    .textContentType(.name)
                    AuthTextField(
                        floatingLabel: "Expiry Date",
                        placeholder: "Enter expiry Date",
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
            //            .padding(.horizontal)
            
            Spacer()
            
            PrimaryButton(
                title: "Submit",
                isOutLine: true,
                onButtonClick: {
                    withAnimation {
                        SVProgressHUD.show()
                        UIApplication.shared.endEditing()
                        stpCard.addCard(cardNumber: cardNumber, exp: expiryDate, cvc: cvv) { result in
                            switch result {
                            case .success(let token):
                                print("Stripe token: \(token)")
                                SVProgressHUD.dismiss()
                                Task {
                                    if isNavFrom == "SellerVerification" {
                                        await viewModel.addSellerCard(parameters: StorePaymentMethodRequest(card_token: token))
                                        await SVProgressHUD.dismiss()
                                        handleSellerCardResponse(stripeToken: token)
                                    } else {
                                        await viewModel.addCard(parameters: AddCardRequest(card_token: token))
                                        await SVProgressHUD.dismiss()
                                        handleResponse()
                                    }
                                }
                                
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                        //                        guard !request.type.isEmpty else {
                        //                            hudMsg = "Please select address type"
                        //                            showhud = true
                        //                            return
                        //                        }
                        //
                        //                        guard !request.name.isEmpty else {
                        //                            hudMsg = "Please enter name of address"
                        //                                showhud = true
                        //                                return
                        //                            }
                        //
                        //                        guard !request.phone_number.isEmpty else {
                        //                            hudMsg = "Please enter phone number"
                        //                                showhud = true
                        //                                return
                        //                            }
                        //                        guard !request.street_address.isEmpty else {
                        //                            hudMsg = "Please enter street address"
                        //                                showhud = true
                        //                                return
                        //                            }
                        //                        guard !request.pincode.isEmpty else {
                        //                            hudMsg = "Please enter pin code"
                        //                                showhud = true
                        //                                return
                        //                            }
                        //                        let request = self.request
                        //                        self.viewModel.storeAddress(parameters: request)
                    }
                },
                width: screenWidth - 40,
                cornerRadius: 12.0, imageName: "",
                btnTextColor : .defaultTheme, btnColor: .defaultTheme
            )
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    let response = viewModel.cardDict
                    if response.status == "success" {
                        self.presentationMode.wrappedValue.dismiss()
                    }else{
                        withAnimation { showError = false }
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    
    
    func handleResponse() {
        let response = viewModel.addCardDict
        if response.status == "success" {
            alertType = .sheetType(
                icon: .success,
                title: response.error_type?.capitalized ?? "Success",
                message: response.message?.capitalized ?? "Card added successfully.",
                primaryBtnText: "OK",
                secondaryBtnText: ""
            )
            showError = true
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "Error",
                message: response.message?.capitalized ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK"
            )
            showError = true
        }
    }
    
    private func handleSellerCardResponse(stripeToken: String) {
        let response = viewModel.sellerStorePaymentDict
        if response.status == "success" {
            DispatchQueue.main.async {
                hudMsg = "Card added successfully"
                showhud = true
                onSuccess?(stripeToken) // ✅ Pass Stripe token instead of cardID
                self.presentationMode.wrappedValue.dismiss()
            }
        } else {
            DispatchQueue.main.async {
                alertType = .sheetType(
                    icon: .alert,
                    title: response.error_type?.capitalized ?? "Error",
                    message: response.message?.capitalized ?? "Something went wrong.",
                    primaryBtnText: "",
                    secondaryBtnText: "OK"
                )
                showError = true
            }
        }
    }
}

//struct AddDebitCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddCardScreen()
//    }
//}
