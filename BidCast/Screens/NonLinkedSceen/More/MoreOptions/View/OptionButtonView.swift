//
//  OptionButtonView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct OptionButtonView: View {
    var label: String
    var icon: String
    var color: Color = .black
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(color)
                Text(label)
                    .font(.custom(poppinsRegular, size: 11.0))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}



