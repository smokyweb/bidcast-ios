//
//  PaymentAndShipping Screen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI

struct PaymentMethod: Identifiable {
    let id = UUID()
    let type: String
    let last4: String
    let expiry: String
    let logo: String
}

struct ShippingAddress: Identifiable {
    let id = UUID()
    let label: String
    let name: String
    let addressLine1: String
    let addressLine2: String
    let isDefault: Bool
}

struct PaymentAndShipping_Screen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var paymentMethods: [PaymentMethod] = [
          PaymentMethod(type: "Visa", last4: "4582", expiry: "08/2026", logo: "creditcard.fill"),
          PaymentMethod(type: "Mastercard", last4: "7890", expiry: "11/2025", logo: "creditcard")
      ]
      
    @State private var addresses: [AddressModel] = [
           AddressModel(id: 1, user_id: 101, type: "Home", name: "John Smith", phone_number: "1234567890", street_address: "123 Main Street, Apt 4B", pincode: "10001", is_default: true),
           AddressModel(id: 2, user_id: 101, type: "Office", name: "John Smith", phone_number: "9876543210", street_address: "456 Business Ave, Suite 200", pincode: "10002", is_default: false)
       ]
    @State var navigateToCreateAddress = false
      var body: some View {
          VStack {
              PrimaryHeader(
                  title: "Preferences".localized,
                  isForLogo : false, leadingImgArr: [.icBack],
                  trailingImgArr: [],
                  onClickLeading: { _ in
                      self.presentationMode.wrappedValue.dismiss()
                  },
                  count: .constant(0)
              )
              .background(.white)
              .frame(height: 50)
              ScrollView {
                  VStack(spacing: 24) {
                      
                      // MARK: - Payment Methods Section
                      Section(header: Text("Payment Methods")
                          .font(.headline)
                          .frame(maxWidth: .infinity, alignment: .leading)) {
                          
                          ForEach(paymentMethods) { method in
                              CardCell(image: method.logo, cardNo: method.last4, expires: method.expiry)
                          }
                          
                          Button(action: {
                              // Add payment method action
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
                          
                              ForEach(Array(addresses.enumerated()), id: \.element.id) { index, address in
                              AddressListCell(address: address,onTapDefault: {
                                  print("indexx \(index)")
                                  
                              },isDefault: address.is_default ?? false)
                              .padding(.horizontal,-12)
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
          }
      }
  }

#Preview {
    PaymentAndShipping_Screen()
}

