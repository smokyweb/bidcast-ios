//
//  SellScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI

struct SellScreen: View {
    @Environment(\.presentationMode) var presentationMode
    var onTap: (SellTabOption) -> Void
    var onTapCancel :() -> Void? 
    var imageName =  ["tag","stream","shop"]
    var tabName = ["List a Product","Schedule a show","Seller Hub"]
    var subLabel = ["Create a listing for your item","Go live and sell to your audience","Manage your store and listings"]
    @State var navigateToLisProduct : Bool = false
    @State var navigateTolesson : Bool = false
  
    
    var body: some View {
        VStack{
            Spacer()
            VStack{
                LabelWithButton(
                    title: "Sell On Bidcast".localized,
                    trailingImgArr: [.icCancel],
                    onClickTrailing: { _ in
                        self.onTapCancel()
//                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
                .frame(height: 50)
                .background(.white)
                ForEach(0 ..< tabName.count, id: \.self) { ind in
                    ListCell(image: imageName[ind], title: tabName[ind], vectorImg: .icArrowUp,subLabel : subLabel[ind],
                             onTapMenuCell: {
                        switch ind {
                        case 0: onTap(.listProduct)
                        case 1: onTap(.lesson)
                        case 2: onTap(.sellerHub)
                        default: break
                        }
                    },isForIcon: true
                    )
                }
                .frame(height: 80)
                .padding([.leading,.trailing],12)

            }
            .padding(.bottom,20)
            .background(.white)
            CusNavLink(doNavigate: $navigateToLisProduct, destination: ListProductScreen())
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .padding(.all,2)
        .edgesIgnoringSafeArea(.all)
    }
}


enum SellTabOption {
    case listProduct
    case lesson
    case sellerHub
}
