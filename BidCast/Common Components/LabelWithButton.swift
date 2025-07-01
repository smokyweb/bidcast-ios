//
//  LabelWithButton.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 15/05/25.
//

import SwiftUI

struct LabelWithButton: View {
    
    var title: String = "Header Title"
    
    var trailingImgArr: [ImageResource] = []
    var onClickTrailing: ((Int) -> Void)?
    
    var showAppIcon: Bool = false
    
    var body: some View {
        VStack{

            HStack {

                Text(title)
                    .font(.custom(poppinsSemiBold, fixedSize: 18))
                    .padding(.leading,8)
                    .foregroundStyle(.black)
                    
                Spacer()
                
                Spacer()
                
                if trailingImgArr.count > 0 {
                    ForEach(trailingImgArr.indices, id: \.self) {
                        ind in
                        if ind == 0 {
                            Button(action: { withAnimation { onClickTrailing?(ind) } }, label: {
                           
                                    Image(trailingImgArr[ind])
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .tint(.white)
                                        .padding(.all, 8)
                                
                            })
                        }else{
                            Button(action: { withAnimation { onClickTrailing?(ind) } }, label: {
                                
                                Image(trailingImgArr[ind])
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .tint(.white)
                                    .padding(.all, 8)
                                
                            })
                        }
                    }
                }
            }
            .frame(height: 40)
            .padding(.top, 10)
     
        }
        .frame(height: topPadding + 40)
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    LabelWithButton()
}

