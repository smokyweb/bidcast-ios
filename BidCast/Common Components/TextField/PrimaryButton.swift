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
    @State var custFontName: String = poppinsBold
    @State var custFontSize: Double = buttonTitle
    
    //MARK: Properties
    var onButtonClick: (() -> Void)?
    
    var width: CGFloat = screenWidth - 60
    var height: CGFloat = 50
    var cornerRadius : CGFloat = 32.0
    var imageName : String = ""
    var btnTextColor : Color = .white
    var btnColor: ColorResource = .defaultTheme
    var foregroundColor : Color = .white
   
    
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
                            .font(.custom(custFontName, fixedSize: custFontSize))
//                            .bold()
                            .foregroundColor(.white)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }else{
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(btnColor))
                    .shadow(color: .gray, radius: 0, x: 0, y: 0)
                    .overlay {
                        HStack{
                            if !imageName.isEmpty {
                                Image(systemName: imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(isOutLine ? Color(btnColor) : .white)
                                    .frame(width: 18,height: 18)
                            }
                            Text(title)
                                .font(.custom(custFontName, fixedSize: custFontSize))
//                                .bold()
                                .foregroundColor(btnTextColor)
                            //                                .foregroundStyle()
                        }
                    }
            }
        })
        .frame(/*width: width, */height: height)
        .padding([.leading,.trailing],12)
    }
}

#Preview {
    PrimaryButton()
}


