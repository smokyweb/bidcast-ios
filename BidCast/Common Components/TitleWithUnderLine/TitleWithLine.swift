//
//  TitleWithLine.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI

struct TitleWithLine: View {
    
    var title: String = "My Listing"
    var lineLength: CGFloat = 32
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom(nunitoBlack, fixedSize: 23))
                    .bold()
                    .foregroundStyle(.text)
                Divider()
                    .frame(width: lineLength, height: 5)
                    .background(.red)
            }
            Spacer()
        }
    }
}

#Preview {
    TitleWithLine()
}
