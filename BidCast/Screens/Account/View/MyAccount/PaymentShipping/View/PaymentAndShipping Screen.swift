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
    @State var viewModel = PaymentViewModel()
    
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var sampleAddresses = [AddressModel]()
    @State var cardArr = [PaymentProfile]()
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var body: some View {
        VStack {
            VStack{
                PrimaryHeader(
                    title: "Payment & Shipping".localized,
                    isForLogo: false,
                    leadingImgArr: [.icBack],
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
                            ForEach(0 ..< cardArr.count, id: \.self) { index in
                                let data = cardArr[index]
                                let card = data.payment?.creditCard
                                CardCell(
                                    image: "creditcard.fill",
                                    cardNo: card?.cardNumber ?? "",
                                    expires: "\(card?.expirationDate ?? "")/\(card?.expirationDate ?? "")",
                                    onTapDefault: {
                                        Task {
                                            SVProgressHUD.show()
                                            await self.viewModel.setDefaultCard(parameters: CardDefaultRequest(card_id: data.customerPaymentProfileId ?? ""))
                                            await SVProgressHUD.dismiss()
                                            defaultSuccess()
                                        }
                                    },
                                    onTapDelete: {
                                        Task {
                                            SVProgressHUD.show()
                                            await self.viewModel.deleteCard(parameters: DeleteCardRequest(payment_profile_id: data.customerPaymentProfileId ?? ""))
                                            self.cardArr.removeAll()
                                            await self.viewModel.getCard()
                                            await self.viewModel.getAddresses()
                                            await SVProgressHUD.dismiss()
                                            AddressSuccess()
                                            cardSuccess()
                                        }
                                    }, isDefault: data.is_default ?? false
                                )
                            }
                        }
                        
                        Button(action: {
                            navigateToAddCard = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Payment Method")
                                    .font(.custom(poppinsSemiBold, size: 15))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.defaultTheme, lineWidth: 1)
                            )
                        }
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
                                                showError = true
                                                alertType = .sheetType(
                                                    icon: .alert,
                                                    title: "Failed",
                                                    message: self.viewModel.errorMessage ?? "",
                                                    primaryBtnText: "",
                                                    secondaryBtnText: AppString.ok.localized,
                                                    contentSize: 13.0
                                                )
                                            }
                                        }
                                    },
                                    isDefault: address.is_default ?? false
                                )
                            }
                        }
                        
                        Button(action: {
                            navigateToCreateAddress = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add New Address")
                                    .font(.custom(poppinsSemiBold, size: 15))
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.defaultTheme, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }


            CusNavLink(doNavigate: $navigateToCreateAddress, destination: CreateAddress())
            CusNavLink(doNavigate: $navigateToAddCard, destination: AddCardScreen())
        }
        .onAppear{
            Task{
                SVProgressHUD.show()
                await self.viewModel.getCard()
                await cardSuccess()
                await self.viewModel.getAddresses()
                await SVProgressHUD.dismiss()
                await AddressSuccess()
            }
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss:{
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
    }
    
    
    func cardSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.cardDict
        if response.status == "success" {
            cardArr = viewModel.cardDict.data?.paymentProfiles ?? [PaymentProfile]()
            
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
    
    func AddressSuccess(){
        
        SVProgressHUD.dismiss()
        let response = viewModel.getAddressDict
        if response.status == "success" {
            sampleAddresses = response.data ?? [AddressModel]()
            
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
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
                showError = true
                alertType = .sheetType(
                    icon: .alert,
                    title: response.error_type?.capitalized ?? "",
                    message: response.message?.capitalized ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
            }
        
        
    }
    
    
}

#Preview {
    PaymentAndShipping_Screen()
}

