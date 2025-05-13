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
    var fontValue : CGFloat = 23
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(nunitoBlack, fixedSize: fontValue))
                    .bold()
                    .foregroundStyle(.text)
                    .foregroundColor(textColor)
            }
        }
    }
}

#Preview {
    TitleWithLine()
}
