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
    var cornerRadius: CGFloat = 34
    
    var firstBtnTitleColor: Color = .white
    var firstBtnBgColor: Color = .defaultTheme
    
    var secBtnTitleColor: Color = .defaultTheme
    var secBtnBgColor: Color = .defaultThemeLight
  

    
    var isHidefirstBtn = false
    var isHideSecBtn = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                //second button
                if !isHideSecBtn {
                    Button {
                        withAnimation {
                            self.onSecButtonClick?()
                        }
                    } label: {
                        Text(titleTwo)
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(secBtnTitleColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: height)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(secBtnBgColor)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(Color.defaultTheme, lineWidth: 1.5)
                            )
                    }
                }
                // First Button
                if !isHidefirstBtn{
                    Button {
                        withAnimation {
                            self.onFirstButtonClick?()
                        }
                    } label: {
                        Text(titleOne)
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(firstBtnTitleColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: height)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(firstBtnBgColor)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(firstBtnBgColor, lineWidth: 1.5)
                            )
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
}
