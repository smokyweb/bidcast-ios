
//
//  ListCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct CustomSegmentedControl<T: Hashable & CustomStringConvertible>: View {
    @Binding var preselectedIndex: T
    var options: [T]
    // this color is coming theme library
    let color = Color.bg.opacity(0.5)
    var fontName = poppinsMedium
    var fontSize = 16.0

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options.indices, id:\.self) { index in
                let option = options[index]
                ZStack {
                    Rectangle()
                        .fill(color)

                    Rectangle()
                        .fill(.white)
                        .cornerRadius(8)
                        .padding(4)
                        .opacity(preselectedIndex == option ? 1 : 0.01)
                        .onTapGesture {
                                withAnimation(.interactiveSpring()) {
                                    preselectedIndex = option
                                }
                            }
                }
               
                .overlay(
                    Text(option.description)
                        .font(.custom(fontName, size: fontSize))
                        .foregroundColor(preselectedIndex == option ? .black : .gray)
                )
            }
        }
        .background(.white)
        .frame(height: 50)
        .cornerRadius(8)
//        .padding([.top,.bottom],8)
//        .padding([.leading,.trailing],20)
        .padding([.top, .bottom], 0)
    }
}
//
//#Preview {
////    CustomSegmentedControl(preselectedIndex: 0, options: ["Seller"])
//}
