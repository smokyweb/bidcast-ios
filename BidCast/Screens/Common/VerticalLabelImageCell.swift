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
    var fontSize = 14.0
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center,spacing: 6){
           
                Button(action: {
                    onTap?()
                }) {
                    VStack(alignment: .center,spacing: 8){
                        Image(topLabel)
                            .resizable()
                            .frame(width: 32, height: 32)
                        
                        Text(bottomLabel)
                            .font(.custom(fontName, fixedSize: fontSize))
//                            .bold()
                            .foregroundStyle(.text)
                            .foregroundColor(.black)
                        
                    }
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.all,4)
                }
            }
//        .background(.red)
        .padding([.leading,.trailing],4)
    }
}

#Preview {
    VerticalLabelImageCell(topLabel: .defaultUser, bottomLabel: "text", onTap: nil)
}
