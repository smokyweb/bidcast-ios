//
//  OutlinedButtonView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI


struct OutlinedButtonView: View {
    var title: String
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: {
            onTap()
        }) {
            Text(title)
                .font(.custom(poppinsSemiBold, size: 13.0))
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.defaultTheme)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.defaultThemeLight)
                )
                
        }
    }
}
