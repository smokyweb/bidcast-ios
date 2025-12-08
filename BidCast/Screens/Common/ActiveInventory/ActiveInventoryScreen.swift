//
//  ActiveInventoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import SwiftUI


struct ActiveInventoryScreen: View {
    var inventory: InventoryDataModel
    var didTapProduct : () -> () = { }
    var navigatedFrom: InventoryNavigation = .account
    @State var isSelected: Bool = false
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                let imageUrlString = inventory.thumbnail?.first ?? ""
                CustomProfileImage(url: imageUrlString, isCircular: false, size: 64, defaultImage: "photo")
                    .padding(.leading, 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    TitleWithLine(title: inventory.title ?? "No Title", lineLength: 0, textColor: .black, fontName: poppinsSemiBold,fontValue: 16, divderHeight: 0)
                    TitleWithLine(title: inventory.description ?? "No Description", lineLength: 0, textColor: .gray,fontName: poppinsRegular,fontValue: 13, divderHeight: 0)
                    TitleWithLine(title: "Quantity: \(inventory.quantity ?? "0")", lineLength: 0, textColor: .gray,fontName: poppinsSemiBold ,fontValue: 14, divderHeight: 0)
                }

                Spacer()

                SingleTitleLabel(title: inventory.status?.capitalizingFirstLetter() ?? "", lineLength: 0, textColor: .green,fontName: poppinsSemiBold, fontValue: 14)
                    .padding(.trailing, 20)
            }
            .padding([.top, .bottom], 8)
        }
        .background(Color.white)
        .cornerRadius(12.0)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    (navigatedFrom == .addProduct && isSelected) ? Color.blue : Color.clear,
                    lineWidth: 2
                )
        )
        .padding(5)
        .shadow(color: Color.gray.opacity(0.2), radius: 2, x: 0, y: 0)
        .onTapGesture {
            isSelected.toggle()
            self.didTapProduct()
        }
    }
}


#Preview {
    ActiveInventoryScreen(inventory: InventoryDataModel(id: 1, categoryID: 101, title: "Sample Item", description: "This is a sample description.", quantity: "10", pricing: "200", flashSale: true, acceptOffers: true, reserveForLive: false, shippingProfileID: 3, status: "Active", images: ["dummy1"]))
}
