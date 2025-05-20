//
//  TitleWithLine.swift
// BidSwipe
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI

struct TitleWithLine: View {
    
    var title: String = "My Listing"
    var lineLength: CGFloat = 32
    var textColor : Color?
    var fontValue : CGFloat = 18
    var divderHeight : CGFloat = 5
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(poppinsBold, fixedSize: fontValue))
                    .bold()
                    .foregroundStyle(.text)
                    .foregroundColor(textColor)
                Divider()
                    .frame(width: lineLength, height: divderHeight)
                    .background(.red)
            }
            .padding([.leading ,.trailing], Leading)
            Spacer()
        }
    }
}

#Preview {
    TitleWithLine()
}
