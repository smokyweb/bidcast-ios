//
//  PaymentAndShipping Screen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI
import SVProgressHUD


struct PaymentAndShipping_Screen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var navigateToCreateAddress = false
    @State var navigateToAddCard = false
    @State private var navigateToEditCard = false
    @State var viewModel = PaymentViewModel()
    @StateObject private var cardviewModel = StripeCardViewModel()
    
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var sampleAddresses = [AddressModel]()
    @State private var cardArr:[CardDataModel] = []
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var showDeleteProduct: Bool = false
    
    @State private var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    
    var body: some View {
        VStack {
            VStack{
                PrimaryHeader(
                    title: "Payment & Shipping".localized,
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { index in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    onClickTrailing: nil,
                    count: .constant(0)
                )
                
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Payment Methods
                    Text("Payment Methods")
                        .font(.custom(poppinsSemiBold, size: 15))
                    VStack{
                        if cardArr.isEmpty {
                            HStack{
                                Spacer()
                                Text("No Card added")
                                    .font(.custom(poppinsSemiBold,fixedSize:13.0))
                                Spacer()
                            }
                        } else {
                            ForEach(cardArr, id: \.cardID) { cardVal in
                                let card = cardVal
                                CardCell(
                                    image: "creditcard.fill",
                                    cardNo: card.last4 ?? "",
                                    expires: "\(card.expMonth ?? 00)/\(card.expYear ?? 0000)",
                                    onTapDefault: {
                                       setDefaultCard(with: cardVal.cardID ?? "")
                                    },
                                    onTapEdit:  {
                                        navigateToEditCard = true
                                      
                                    },
                                    onTapDelete: {
                                        config = BottomSheetConfig(
                                            icon: "trash.circle.fill",
                                            title: "Delete Card?",
                                            message:  "Are you sure you want to remove this card?",
                                            primaryButtonTitle: "Delete",
                                            secondaryButtonTitle: "Cancel",
                                            bottomPadding: -80
                                        )
                                        showDeleteProduct = true
                                        cardviewModel.selectCard(cardVal)
                                    }, isDefault: card.isDefault ?? false
                                )
                            }
                        }
                        
//                        PrimaryButton(title: "Add Payment Method",
//                                      isOutLine: false,
//                                      onButtonClick: {
//                                        navigateToAddCard = true
//                                      },
//                                      cornerRadius: 32,
//                                      imageName: "plus",
//                                      btnTextColor: .white)
                        
                        PrimaryButton(title: "Add Payment Method",
                                      isOutLine: false,
                                      onButtonClick: {
                                            navigateToAddCard = true
                                        },
                                      imageName: "plus")
                        .padding(.top , 10)
                        
//                        Button(action: {
//                            navigateToAddCard = true
//                        }) {
//                            HStack {
//                                Image(systemName: "plus")
//                                Text("Add Payment Method")
//                                    .font(.custom(poppinsSemiBold, size: 15))
//                            }
//                           
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .foregroundColor(.defaultTheme)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.defaultTheme, lineWidth: 1)
//                            )
//                        }
                    }
                    
                    // MARK: - Shipping Addresses
                    Text("Shipping Addresses")
                        .font(.custom(poppinsSemiBold, size: 15))
                    VStack{
                        if sampleAddresses.isEmpty {
                            HStack{
                                Spacer()
                                Text("No Address added")
                                    .font(.custom(poppinsSemiBold,fixedSize:13.0))
                                Spacer()
                            }
                        } else {
                            ForEach(sampleAddresses, id: \.id) { address in
                                AddressListCell(
                                    address: address,
                                    onTapDefault: {
                                        Task {
                                            SVProgressHUD.show()
                                            await self.viewModel.setDefaultAddress(parameters: AddressDefaultParam(address_id: "\(address.id ?? 0)"))
                                            await SVProgressHUD.dismiss()
                                            defaultSuccess()
                                        }
                                    },
                                    onTapDelete: {
                                        Task {
                                            SVProgressHUD.show()
                                            await self.viewModel.deleteAddress(parameters: AddressDefaultParam(address_id: "\(address.id ?? 0)"))
                                            await SVProgressHUD.dismiss()
                                            if self.viewModel.errorMessage?.isEmpty ?? true {
                                                self.sampleAddresses.removeAll()
                                                AddressSuccess()
                                            } else {
                                                alertType = .sheetType(
                                                    icon: .alert,
                                                    title: "Failed",
                                                    message: self.viewModel.errorMessage ?? "",
                                                    primaryBtnText: "",
                                                    secondaryBtnText: AppString.ok.localized,
                                                    contentSize: 13.0
                                                )
                                                showError = true
                                            }
                                        }
                                    },
                                    isDefault: address.is_default ?? false
                                )
                            }
                        }
                        PrimaryButton(title: "Add New Address",
                                      onButtonClick: {
                                            navigateToCreateAddress = true
                                        },
                                      imageName: "plus")
                        .padding(.top , 10)
                    }
                }
                .padding()
            }


            CusNavLink(doNavigate: $navigateToCreateAddress, destination: CreateAddress())
            CusNavLink(doNavigate: $navigateToAddCard, destination: AddCardScreen())
            CusNavLink(doNavigate: $navigateToEditCard, destination: AddCardScreen(viewModel: cardviewModel))
        }
        .background(.backGround)
        .onAppear{
            Task {
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: errorDesc(error: error, message: viewModel.errorMessage ?? cardviewModel .errorMessage),
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        // On success
                        cardSuccess()
                        AddressSuccess()
                    }
                    
                ) {
                    async let t1: () = self.cardviewModel.getCards()
                    async let t2: () = self.viewModel.getAddresses()
                    
                    _ = try await (t1, t2)
                }
            }
        }
//        .bottomSheet(
//            isPresented: $showError,
//            height: screenHeight / 2.3,
//            topBarCornerRadius: 25,
//            showTopIndicator: false,
//            onDismiss:{
//                withAnimation { showError = false }
//            }
//        ) {
//            CommonBottomSheet(
//                sheetType: $alertType,
//                onPrimaryClick: {
//                    withAnimation { showError = false }
//                },
//                onSecondaryClick: {
//                    withAnimation { showError = false }
//                }
//            )
//        }
        .bottomSheetView(
            isPresented: $showError,
            height: screenHeight / 3.0,
            cornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                print("Sheet dismissed")
                withAnimation { showError = false }
            }
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
        
        .overlay(
            CustomBottomSheetView(
                isPresented: $showDeleteProduct,
                config: config,
                primaryAction: {
                    withAnimation {
                        showDeleteProduct = false
                        deleteCard(with: cardviewModel.selectedCard?.cardID ?? "")
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showDeleteProduct = false
                    }
                }
            )
        )
    }
    
    func deleteCard(with cardId: String) {
        Task {
            await performAPICalls(
                isConcurrent: true,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: cardviewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }, onSuccess: {
                    // On success
                    Task {
                        self.cardArr.removeAll()
                        SVProgressHUD.show()
                        try await self.cardviewModel.getCards()
                        cardSuccess()
                    }
                    cardviewModel.clearSelection()
                }
            ) {
                try await self.cardviewModel.deleteCard(request: DeleteCardRequest(card_id: cardId))
            }
        }
    }
    
    func setDefaultCard(with cardId: String) {
        Task {
            await performAPICalls(
                isConcurrent: true,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: cardviewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }, onSuccess: {
                    // On success
                    Task {
                        self.cardArr.removeAll()
                        SVProgressHUD.show()
                        try await self.cardviewModel.getCards()
                        cardSuccess()
                    }
                }
            ) {
                try await self.cardviewModel.setDefaultCard(request: DeleteCardRequest(card_id: cardId))
            }
        }
    }
    
    
    func cardSuccess() {
        SVProgressHUD.dismiss()
        let response = cardviewModel.cards
        if response?.status == "success" {
            cardArr = response?.data ?? []
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: cardviewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText:  AppString.ok.localized
            )
            showError = true
        }
    }
    
    func AddressSuccess(){
        
        SVProgressHUD.dismiss()
        let response = viewModel.getAddressDict
        if response.status == "success" {
            sampleAddresses = response.data ?? [AddressModel]()
            
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
    
    func defaultSuccess(){
        SVProgressHUD.dismiss()
         let response = viewModel.addressDict
            if response.status == "success" {
                Task{
                    SVProgressHUD.show()
                    await self.viewModel.getAddresses()
                    await SVProgressHUD.dismiss()
                    AddressSuccess()
                }
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
    
    
}

//#Preview {
//    PaymentAndShipping_Screen()
//}

