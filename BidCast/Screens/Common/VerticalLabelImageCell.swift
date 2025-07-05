//
//  TwoVerticalLabelCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 15/05/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct VerticalLabelImageCell: View {
    let topLabel : ImageResource
    let bottomLabel: String
    
    var fontName = poppinsRegular
    var fontSize = 13.0
    var onTap: (() -> Void)? = nil
    
    var body: some View {
           Button(action: {
               onTap?()
           }) {
               VStack(alignment: .center, spacing: 8) {
                   Image(topLabel)
                       .resizable()
                       .scaledToFit()
                       .frame(width: 32, height: 32)
                   
                   Text(bottomLabel)
                       .font(.custom(fontName, fixedSize: fontSize))
                       .foregroundStyle(.text)
               }
               .frame(maxWidth: .infinity, minHeight: 100)
               .background(Color.white)
               .cornerRadius(12)
               .padding(4)
               .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
           }
//           .padding(.horizontal, 4)
       }
}

#Preview {
    VerticalLabelImageCell(topLabel: .defaultUser, bottomLabel: "text", onTap: nil)
}
