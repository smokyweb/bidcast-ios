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
    
    var body: some View {
        HStack(alignment: .center,spacing: 6){
            ForEach(dataModel, id: \.self){ index in
               
                VStack(alignment: .center,spacing: 8){
                    Text(topLabel(index))
                        .font(.custom(nunitoBold, fixedSize: 28.0))
                        .bold()
                        .foregroundStyle(.text)
                        .foregroundColor(.black)
                    
                    Text(bottomLabel(index))
                        .font(.custom(nunitoBlack, fixedSize: 15.0))
                        .bold()
                        .foregroundStyle(.text)
                        .foregroundColor(.lightGray)
                    
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
