//
//  ProductDetailSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct PaymentBottomSheet: View {
    
    @Binding var isPresented: Bool
    var paymentMethods: [PaymentMethod]
    var addresses: [AddressModel]
    
    /// Callbacks for edit actions
    var onEditPayment: (() -> Void)?
    var onEditAddress: (() -> Void)?
    
    // MARK: - Helpers
    var defaultPayment: PaymentMethod? {
        paymentMethods.first
    }
    
    var defaultAddress: AddressModel? {
        addresses.first(where: { $0.is_default == true })
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            // MARK: Header
            HStack {
                Text("Add Payment Method And Address")
                    .font(.custom(poppinsBold, size: 15.0))
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            
            // MARK: Payment Method
            if let card = defaultPayment?.creditCard {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Card")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                            .foregroundColor(.black)
                        Text("\(card.cardType ?? "") \(maskedCardNumber(card.cardNumber))")
                            .font(.custom(poppinsRegular, size: 13.0))
                    }
                    Spacer()
                    Button(action: { onEditPayment?() }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            } else {
                Button("Add Payment Method") {
                    onEditPayment?()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            
            // MARK: Address
            if let address = defaultAddress {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Shipping Address")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                            .foregroundColor(.black)
                        Text("\(address.name ?? ""), \(address.street_address ?? ""), \(address.pincode ?? "")")
                            .font(.custom(poppinsRegular, size: 12.0))
                            .foregroundColor(.gray)
                        Text("📞 \(address.phone_number ?? "")")
                            .font(.custom(poppinsRegular, size: 12.0))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: { onEditAddress?() }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            } else {
                Button("Add Address") {
                    onEditAddress?()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            }
            
//            Spacer()
            
            // MARK: Confirm Button
//            Button(action: {
//                print("Confirm tapped")
//                isPresented = false
//            }) {
//                Text("Confirm")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(12)
//            }
//            .padding(.bottom, 20) // safe area padding
        }
        .padding()
    }
    
    private func maskedCardNumber(_ number: String?) -> String {
        guard let number = number else { return "" }
        let last4 = number.suffix(4)
        return "•••• \(last4)"
    }
}
