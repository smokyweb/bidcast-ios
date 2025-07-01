//
//  PrimaryButton.swift
// BidSwipe
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI

struct PrimaryButton: View {
    
    //MARK: inputs
    var title: String = "Sign In"
    var isOutLine = true
    
    //MARK: Properties
    var onButtonClick: (() -> Void)?
    
    var width: CGFloat = screenWidth - 30
    var height: CGFloat = 50
    var cornerRadius : CGFloat = 8.0
    var imageName : String = ""
    var btnTextColor : Color = .darkBlue
    var btnColor: ColorResource = .defaultTheme
    var foregroundColor : Color = .black
    
    var body: some View {
        Button(action: { withAnimation {
            self.onButtonClick?()
        } }, label: {
            if isOutLine{
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white, lineWidth: 2.0)
                    .background(Color.defaultTheme)
                    .overlay {
                        Text(title)
                            .font(.custom(poppinsBold, fixedSize: buttonTitle))
//                            .bold()
                            .foregroundColor(.white)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
//                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
            }else{
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(btnColor))
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
                    .overlay {
                        HStack{
                            if !imageName.isEmpty {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(isOutLine ? Color(btnColor) : .white)
                                    .frame(width: 24,height: 24)
                            }
                            Text(title)
                                .font(.custom(poppinsSemiBold, fixedSize: buttonTitle))
//                                .bold()
                                .foregroundColor(btnTextColor)
                            //                                .foregroundStyle()
                        }
                    }
            }
        })
        .frame(width: width, height: height)
        .padding([.bottom,.leading,.trailing],16)
    }
}

#Preview {
    PrimaryButton()
}


