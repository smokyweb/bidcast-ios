//
//  PaymentAndShipping Screen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI
import SVProgressHUD

//struct PaymentMethod: Identifiable {
//    let id = UUID()
//    let type: String
//    let last4: String
//    let expiry: String
//    let logo: String
//}
//
//struct ShippingAddress: Identifiable {
//    let id = UUID()
//    let label: String
//    let name: String
//    let addressLine1: String
//    let addressLine2: String
//    let isDefault: Bool
//}

struct PaymentAndShipping_Screen: View {
    @Environment(\.presentationMode) var presentationMode
    
    //    @State private var paymentMethods: [PaymentMethod] = [
    //          PaymentMethod(type: "Visa", last4: "4582", expiry: "08/2026", logo: "creditcard.fill"),
    //          PaymentMethod(type: "Mastercard", last4: "7890", expiry: "11/2025", logo: "creditcard")
    //      ]
    //
    //    @State private var addresses: [AddressModel] = [
    //           AddressModel(id: 1, user_id: 101, type: "Home", name: "John Smith", phone_number: "1234567890", street_address: "123 Main Street, Apt 4B", pincode: "10001", is_default: true),
    //           AddressModel(id: 2, user_id: 101, type: "Office", name: "John Smith", phone_number: "9876543210", street_address: "456 Business Ave, Suite 200", pincode: "10002", is_default: false)
    //       ]
    @State var navigateToCreateAddress = false
    @State var navigateToAddCard = false
    @State var viewModel = PaymentViewModel()
    
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var sampleAddresses = [AddressModel]()
    @State var cardArr = [CardModel]()
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var body: some View {
        VStack {
            //              PrimaryHeader(
            //                  title: "Preferences".localized,
            //                  isForLogo : false, leadingImgArr: [.icBack],
            //                  trailingImgArr: [],
            //                  onClickLeading: { _ in
            //                      self.presentationMode.wrappedValue.dismiss()
            //                  },
            //                  count: .constant(0)
            //              )
            //              .background(.white)
            //              .frame(height: 50)
            VStack{
                PrimaryHeader(
                    title: "Payment & Shipping".localized,
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
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Payment Methods Section
                    Section(header: Text("Payment Methods")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)) {
                            
                            ForEach(cardArr.indices, id: \.self) { index in
                                let card = cardArr[index]
                                CardCell(image: "creditcard.fill", cardNo: card.last4 ?? "", expires: "\(card.exp_month ?? 0)/\(card.exp_year ?? 0)",onTapDelete: {
                                    Task{
                                        SVProgressHUD.show()
                                        self.cardArr.removeAll()
                                       await  self.viewModel.deleteCard(parameters: DeleteCardRequest(card_id: card.card_id ?? ""))
                                        await self.viewModel.getCard()
                                        await self.viewModel.getAddresses()
                                        await SVProgressHUD.dismiss()
                                        await AddressSuccess()
                                        await cardSuccess()
                                    }
                                })
                            }
                            
                            Button(action: {
                                navigateToAddCard = true
                            }) {
                                Label("Add Payment Method", systemImage: "plus")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.blue))
                            }
                        }
                    
                    // MARK: - Shipping Addresses Section
                    Section(header: Text("Shipping Addresses")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)) {
                            
                            ForEach(sampleAddresses, id: \.id) { address in
                                //                                  let address = sampleAddresses[index]
                                AddressListCell(address: address,onTapDefault: {
                                    print("indexx \(index)")
                                    Task{
                                        SVProgressHUD.show()
                                       
                                        await self.viewModel.setDefaultAddress(parameters: AddressDefaultParam(address_id: "\(address.id ?? 0)"))
                                       await  SVProgressHUD.dismiss()
                                        await defaultSuccess()
                                    }
                                },onTapDelete: {
                                    Task{
                                        SVProgressHUD.show()
                                        self.sampleAddresses.removeAll()
                                        await  self.viewModel.deleteAddress(parameters: AddressDefaultParam(address_id:"\(address.id ?? 0)"))
                                        await SVProgressHUD.dismiss()
                                        await AddressSuccess()
                                    }
                                }, isDefault: address.is_default ?? false)
                            }
                            
                            Button(action: {
                                // Add new address action
                                navigateToCreateAddress = true
                            }) {
                                Label("Add New Address", systemImage: "plus")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.blue))
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
                await self.viewModel.getAddresses()
                await SVProgressHUD.dismiss()
                await AddressSuccess()
                await cardSuccess()
            }
        }
    }
    
    
    func cardSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.cardDict
        if response.status == "success" {
            cardArr = viewModel.cardDict.data ?? [CardModel]()
           
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
                await AddressSuccess()
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

