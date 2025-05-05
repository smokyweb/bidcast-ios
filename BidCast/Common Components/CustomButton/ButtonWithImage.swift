//
//  ButtonWithImage.swift
//  imperium
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI

struct ButtonWithImage: View {
    @State var title: String = "Sign In"
    @State var imageRes: ImageResource = .linkedIn
    
    var onButtonClick: (() -> Void)?
    
    var width: CGFloat = screenWidth - 30
    var height: CGFloat = 50
    
    var body: some View {
        Button(action: { withAnimation {
            self.onButtonClick?()
        } }, label: {
            HStack {
                Image(imageRes)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .tint(.blue)
                Text(title)
                    .font(.custom(nunitoBold, fixedSize: 18))
                    .bold()
                    .foregroundStyle(.text)
            }
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
            )
        })
    }
}

#Preview {
    ButtonWithImage()
}
