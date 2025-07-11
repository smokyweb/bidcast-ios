//
//  OutlinedButtonView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

//struct OutlinedButtonView: View {
//    var title: String
//
//    var body: some View {
//        Text(title)
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color.defaultTheme, lineWidth: 1)
//            )
//            .foregroundColor(Color.defaultTheme)
//    }
//}


struct OutlinedButtonView: View {
    var title: String
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: {
            onTap()
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.defaultTheme, lineWidth: 1)
                )
                .foregroundColor(Color.defaultTheme)
        }
    }
}
