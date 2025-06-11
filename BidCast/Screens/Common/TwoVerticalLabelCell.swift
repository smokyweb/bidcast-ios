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
    let dataModel: [T]
    let topLabel: (T) -> String
    let bottomLabel: (T) -> String

    @Binding var selection: T?

    var h1fontname = poppinsSemiBold
    var h1fontSize = 20.0
    var h2fontname = poppinsRegular
    var h2fontSize = 12.0
    
    init(
        dataModel: [T],
        topLabel: @escaping (T) -> String,
        bottomLabel: @escaping (T) -> String,
        selection: Binding<T?>? = nil, // ✅ optional parameter
        h1fontname: String = poppinsSemiBold,
        h1fontSize: Double = 20.0,
        h2fontname: String = poppinsRegular,
        h2fontSize: Double = 12.0
    ) {
        self.dataModel = dataModel
        self.topLabel = topLabel
        self.bottomLabel = bottomLabel
        self._selection = selection ?? .constant(nil) // ✅ fallback to .constant(nil)
        self.h1fontname = h1fontname
        self.h1fontSize = h1fontSize
        self.h2fontname = h2fontname
        self.h2fontSize = h2fontSize
    }

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            ForEach(dataModel, id: \.self) { item in
                VStack(alignment: .center, spacing: 8) {
                    Text(topLabel(item))
                        .font(.custom(h1fontname, fixedSize: h1fontSize))
                        .foregroundColor(.black)

                    Text(bottomLabel(item))
                        .font(.custom(h2fontname, fixedSize: h2fontSize))
                        .foregroundColor(.lightText)
                }
                .frame(width: 90, height: 90)
                .background(selection == item ? Color.blue.opacity(0.1) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selection == item ? Color.blue : Color.clear, lineWidth: 1)
                )
                .cornerRadius(12)
                .padding(12)
                .onTapGesture {
                    selection = item
                }
            }
        }
        .padding(.horizontal, 8)
    }
}
