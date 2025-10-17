//
//  TwoButton.swift
//  BidCast
//
//  Created by JAM-E-329 on 13/05/25.
//

import SwiftUI

struct TwoButton: View {
    
    // MARK: Inputs
    var titleOne: String = "Decline"
    var titleTwo: String = "Accept"
    
    // MARK: Properties
    var onFirstButtonClick: (() -> Void)?
    var onSecButtonClick: (() -> Void)?
    
    var height: CGFloat = 50
    var cornerRadius: CGFloat = 12.0
    
    var firstBtnTitleColor: ColorResource = .white
    var secBtnTitleColor: ColorResource = .white
    
    var firstBtnBgColor: Color = .red
    var secBtnBgColor: Color = .success
    
    var isHidefirstBtn = false
    var isHideSecBtn = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // Second Button
            if !isHideSecBtn {
                Button(action: {
                    withAnimation {
                        self.onSecButtonClick?()
                    }
                }) {
                    Text(titleTwo)
                        .font(.custom(robotoMedium, fixedSize: 18))
                        .foregroundStyle(Color(secBtnTitleColor))
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .background(secBtnBgColor)
                        .cornerRadius(cornerRadius)
                }
                .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
                //            .overlay(
                //                RoundedRectangle(cornerRadius: cornerRadius)
                //                    .stroke(Color.defaultTheme, lineWidth: 1)
                //            )
//                .padding(.trailing, 16)
            }
            if !isHidefirstBtn{
                // First Button
                Button(action: {
                    withAnimation {
                        self.onFirstButtonClick?()
                    }
                }) {
                    Text(titleOne)
                        .font(.custom(robotoMedium, fixedSize: 18))
                    .foregroundStyle(Color(firstBtnTitleColor))
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background(firstBtnBgColor)
                    .cornerRadius(cornerRadius)
            }
                .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
//                .padding(.horizontal, 16)
        }
        }
        .padding(.horizontal, 16)
    }
}
