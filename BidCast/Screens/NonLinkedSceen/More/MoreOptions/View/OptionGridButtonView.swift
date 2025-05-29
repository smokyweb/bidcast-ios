//
//  OptionGridButtonView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI


struct OptionGridButtonView: View {
    var label: String
    var icon: String
    var isSelected: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isSelected ? .red : .black)
                Text(label)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.red.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
