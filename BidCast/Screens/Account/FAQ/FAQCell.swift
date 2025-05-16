//
//  FAQCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 16/05/25.
//


import SwiftUI

// FAQ Cell
struct FAQCell: View {
    var title: String
    var content: String
    var isExpanded: Bool
    var onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.mediumGray)
            }
            .onTapGesture {
                onTap()
            }

            if isExpanded {
                Text(content)
                    .font(.body)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .animation(.easeInOut, value: isExpanded)
    }
}
