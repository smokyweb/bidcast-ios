//
//  TwoVerticalLabelCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 15/05/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct TwoVerticalLabelCell<T: Hashable & CustomStringConvertible>: View {
    let dataModel : [T]
    let topLabel: (T) -> String
    let bottomLabel: (T) -> String
    var h1fontname = poppinsSemiBold
    var h1fontSize = 20.0
    var h2fontname = poppinsRegular
    var h2fontSize = 12.0
    
    var body: some View {
        HStack(alignment: .center,spacing: 6){
            ForEach(dataModel, id: \.self){ index in
               
                VStack(alignment: .center,spacing: 8){
                    Text(topLabel(index))
                        .font(.custom(h1fontname, fixedSize: h1fontSize))
//                        .bold()
                        .foregroundStyle(.text)
                        .foregroundColor(.black)
                    
                    Text(bottomLabel(index))
                        .font(.custom(h2fontname, fixedSize: h2fontSize))
//                        .bold()
                        .foregroundStyle(.text)
                        .foregroundColor(.lightText)
                    
                }
                .frame(width: 90, height: 90)
                
                .background(.white)
                .cornerRadius(12)
                .padding(.all,12)
            }
        }
        .padding([.leading,.trailing],8)
    }
}
