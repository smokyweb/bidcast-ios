//
//  SingleTitleLabel.swift
//  BidCast
//
//  Created by JAM-E-329 on 13/05/25.
//

import SwiftUI

struct SingleTitleLabel: View {
    
    var title: String = "My Listing"
    var lineLength: CGFloat = 32
    var textColor : Color?
    var fontName = poppinsSemiBold
    var fontValue : CGFloat = 18
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(fontName, fixedSize: fontValue))
                    .foregroundStyle(.text)
                    .foregroundColor(textColor)
            }
            .padding([.leading ,.trailing], 4)
//            Spacer()
        }
    }
}

#Preview {
    TitleWithLine()
}
