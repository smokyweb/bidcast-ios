//
//  SelectableCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI

struct SelectableCell: View {
    var title: String
    var value: String
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.custom(poppinsSemiBold, size: 15.0))
                    .foregroundColor(.primary)
                Spacer()
                Text(value)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
//            .padding()
            .background(Color.white)
            .cornerRadius(12)
//            .shadow(color: .black.opacity(0.05), radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 4)
    }
}


