//
//  SellScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI

struct SellScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    var imageName : [ImageResource] = [.tagBorder,.streamBorder,.sellerBorder]
    var tabName = ["List a Product","Scheduled a show","Seller Hub"]
    var subLabel = ["Create a listing for your item","Go live and sell to your audience","Manage your store and listings"]
    @State var navigateToLisProduct : Bool = false
    @State var navigateTolesson : Bool = false
    
    var body: some View {
        VStack{
         
            Spacer()
            VStack{
                LabelWithButton(
                    title: "Sell".localized,
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
                .frame(height: 50)
                .background(.white)
                ForEach(0 ..< tabName.count, id: \.self) { ind in
                    ListCell(image: imageName[ind], title: tabName[ind], vectorImg: .icArrowUp,subLabel : subLabel[ind],onTapMenuCell: {
                        if ind == 0{
                            navigateToLisProduct = true
                        }else if ind == 1{
                            navigateTolesson = true
                        }
                    })
                   
                }
            }
            .padding(.bottom,80)
            .background(.bg)
           
            
            CusNavLink(doNavigate: $navigateToLisProduct, destination: ListProductScreen())
//            CusNavLink(doNavigate: $navigateTolesson, destination: LessonScreen())
            CusNavLink(doNavigate: $navigateTolesson, destination: CombinedLessonTipsView())
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .padding(.all,2)
        .background(.black.opacity(0.5))
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SellScreen()
}
