//
//  PrimaryButton.swift
//  imperium
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
    
    var body: some View {
        Button(action: { withAnimation {
            self.onButtonClick?()
        } }, label: {
            if isOutLine{
                RoundedRectangle(cornerRadius: cornerRadius)
//                    .stroke(btnColor, lineWidth: 2.0)
                    .overlay {
                        Text(title)
                            .font(.custom(nunitoBold, fixedSize: 18))
                            .bold()
                            .foregroundStyle(Color(btnColor))
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
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
                                .font(.custom(nunitoBold, fixedSize: 18))
                                .bold()
                                .foregroundColor(btnTextColor)
//                                .foregroundStyle()
                        }
                    }
                    
            
            }
        })
        .frame(width: width, height: height)
        .padding(.all,16)
    }
}

#Preview {
    PrimaryButton()
}


