//
//  AddCardScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/06/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct AddCardScreen: View {
    @State private var cardHolderName = ""
    @State private var cardNumber = ""
    @State private var cvv = ""
    @State private var expiryDate = ""
    var isNavFrom: String = ""
    @State var viewModel = AddCardViewModel()
    var onSuccess: ((String) async -> Void)?
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
            //            .padding(.horizontal)
            
            Spacer()
            
            PrimaryButton(
                title: "Submit",
                isOutLine: true,
                onButtonClick: {
                    guard !cardNumber.isEmpty else{
                        hudMsg = "Enter card number"
                        showhud = true
                        return
                    }
                    guard !expiryDate.isEmpty else{
                        hudMsg = "Enter card number"
                        showhud = true
                        return
                    }
                    guard !cvv.isEmpty else{
                        hudMsg = "Enter card number"
                        showhud = true
                        return
                    }
                    
                    
                    UIApplication.shared.endEditing()
                    //                    isNavFrom = "SellerVerification"
                    
                    Task{
                        SVProgressHUD.show()
                        self.viewModel.errorMessage = ""
                        let param = AddCardRequest(card_number: cardNumber, expiration_date: expiryDate, cvv: cvv)
                        await viewModel.addCard(parameters: param)
                        await SVProgressHUD.dismiss()
                        
                        if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                            handleResponse()
                        }else{
                            alertType = .sheetType(
                                icon: .alert,
                                title: "Failed",
                                message: self.viewModel.errorMessage ?? "",
                                primaryBtnText: "",
                                secondaryBtnText: "OK"
                            )
                            showError = true
                        }
                    }
                    
                },
                width: screenWidth - 40,
                cornerRadius: 12.0, imageName: "",
                btnTextColor : .defaultTheme, btnColor: .defaultTheme
            )
            .padding(.vertical, 10)
            .background(Color.white)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                        self.presentationMode.wrappedValue.dismiss()
                        withAnimation { showError = false }
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
            
            handleSellerCardResponse(cardId: self.viewModel.addCardDict.data?.first?.customerProfileId ?? "")
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
    
    func handleSellerCardResponse(cardId:String) {
        Task {
            await onSuccess?(cardId)
        }
    }
}
